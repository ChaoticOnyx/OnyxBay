/obj/item/device/glucose
	name = "blood glucose meter"
	desc = "A handheld device used for testing and monitoring blood glucose level."
	description_info = "By using this item, you may toggle its mode on and off. Toggling meter on link meter with patient. Examine it while it's on to read blood glucose level. You also can scan someone with this to determine patient glucose level.swapmap"

	icon_state = "glucose_off"
	item_state = "multitool"
	action_button_name = "Toggle geiger counter"

	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_speed = 5
	throw_range = 10
	matter = list(MATERIAL_STEEL = 200)
	origin_tech = list(TECH_MAGNET = 1, TECH_BIO = 1)

	var/mob/living/carbon/human/attached = null
	var/on = FALSE

	icon = 'icons/obj/device2.dmi'
	var/glucose = 0

/obj/item/device/glucose/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/device/glucose/attack(mob/living/carbon/human/M, mob/living/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	if (!user.IsAdvancedToolUser())
		to_chat(user, SPAN_WARNING("You are not nimble enough to use this device."))
		return

	if (!istype(M) || M.isSynthetic())
		to_chat(user, SPAN_WARNING("\The [src] is designed for organic humanoid patients only."))
		return

	var/glucose = M.reagents.get_reagent_amount(/datum/reagent/hormone/glucose)
	to_chat(user, "\icon[src] [M.name] have [glucose] Gu")

/obj/item/device/glucose/Process()
	if(!on | !ishuman(attached))
		return

	glucose = attached.reagents.get_reagent_amount(/datum/reagent/hormone/glucose)

	if(glucose > BLOOD_SUGAR_HCRITICAL || glucose < BLOOD_SUGAR_LCRITICAL)
		if(attached.life_tick % 3 == 0)
			for(var/mob/O in hearers(1, attached.loc))
				O.show_message(text("\icon[src] *beep*"), 3, "*beep*", 2)

	update_icon()

/obj/item/device/glucose/examine(mob/user)
	. = ..()
	var/msg = "[attached.name] have [glucose] Gu"
	if(glucose > BLOOD_SUGAR_HCRITICAL || glucose < BLOOD_SUGAR_LCRITICAL)
		. += "\n<span class='warning'>[msg]</span>"
	else
		. += "\n<span class='notice'>[msg]</span>"

/obj/item/device/glucose/attack_self(mob/user)
	on = !on
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	update_icon()

	var/mob/living/carbon/human/H = user

	if(!ishuman(H))
		STOP_PROCESSING(SSobj, src)
		return

	attached = H

	to_chat(user, "<span class='notice'>\icon[src] You switch [on? "on for [H.name]" : "off"].</span>")

/obj/item/device/glucose/update_icon()
	if(!on)
		icon_state = "glucose_off"
		return 1

	switch(glucose)
		if(-INFINITY to BLOOD_SUGAR_LCRITICAL) icon_state = "glucose_lcritical"
		if(BLOOD_SUGAR_LCRITICAL to BLOOD_SUGAR_LBAD) icon_state = "glucose_lbad"
		if(BLOOD_SUGAR_LBAD to BLOOD_SUGAR_HBAD) icon_state = "glucose_ok"
		if(BLOOD_SUGAR_HBAD to BLOOD_SUGAR_HCRITICAL) icon_state = "glucose_hbad"
		if(BLOOD_SUGAR_HCRITICAL to INFINITY) icon_state = "glucose_hcritical"