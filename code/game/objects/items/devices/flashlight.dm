/obj/item/device/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	w_class = ITEM_SIZE_SMALL
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT

	matter = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 20)

	action_button_name = "Toggle Flashlight"
	var/on = 0
	var/activation_sound = 'sound/effects/flashlight.ogg'
	var/spam_flag = FALSE // spamming can possibly overload lighting SS

	var/flashlight_max_bright    = 0.5 // brightness of light when on, must be no greater than 1.
	var/flashlight_inner_range   = 1   // inner range of light when on, can be negative
	var/flashlight_outer_range   = 4   // outer range of light when on, can be negative
	var/flashlight_falloff_curve = 4.0
	var/brightness_color = "#fff3b2" // color of light when on
	var/light_overlay = TRUE

/obj/item/device/flashlight/Initialize()
	. = ..()
	if(on)
		switch_light(TRUE)

/obj/item/device/flashlight/update_icon()
	overlays.Cut()
	if(on)
		icon_state = "[initial(icon_state)]-on"
		if(light_overlay)
			var/image/LO = overlay_image(icon, "[initial(icon_state)]-overlay", flags=RESET_COLOR)
			LO.color = brightness_color
			LO.layer = ABOVE_LIGHTING_LAYER
			LO.plane = EFFECTS_ABOVE_LIGHTING_PLANE
			overlays += LO
	else
		icon_state = "[initial(icon_state)]"

/obj/item/device/flashlight/proc/switch_light(state = FALSE)
	on = state
	if(on)
		set_light(flashlight_max_bright, flashlight_inner_range, flashlight_outer_range, flashlight_falloff_curve, brightness_color)
	else
		set_light(0)

	if(activation_sound)
		playsound(src.loc, activation_sound, 50, 1)
	update_icon()

/obj/item/device/flashlight/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn \the [src] [on ? "off" : "on"] in this [user.loc].") //To prevent some lighting anomalities.
		return 0
	if(spam_flag)
		return 0
	spam_flag = TRUE
	switch_light(!on)
	user.update_action_buttons()
	spawn(5)
		spam_flag = FALSE
	return 1

/obj/item/device/flashlight/AltClick(mob/user)
	if(CanPhysicallyInteract(user))
		return attack_self(user)
	else
		return ..()

/obj/item/device/flashlight/attack(mob/living/M, mob/living/user)
	add_fingerprint(user)
	if(on && user.zone_sel.selecting == BP_EYES)

		if((MUTATION_CLUMSY in user.mutations) && prob(50))	//too dumb to use flashlight properly
			return ..()	//just hit them in the head

		var/mob/living/carbon/human/H = M	//mob has protective eyewear
		if(istype(H))
			for(var/obj/item/clothing/C in list(H.head,H.wear_mask,H.glasses))
				if(istype(C) && (C.body_parts_covered & EYES))
					to_chat(user, "<span class='warning'>You're going to need to remove [C] first.</span>")
					return

			var/obj/item/organ/vision
			if(!H.species.vision_organ || !H.should_have_organ(H.species.vision_organ))
				to_chat(user, "<span class='warning'>You can't find anything on [H] to direct [src] into!</span>")
				return

			vision = H.internal_organs_by_name[H.species.vision_organ]
			if(!vision)
				vision = H.species.has_organ[H.species.vision_organ]
				to_chat(user, "<span class='warning'>\The [H] is missing \his [initial(vision.name)]!</span>")
				return

			user.visible_message("<span class='notice'>\The [user] directs [src] into [M]'s [vision.name].</span>", \
								 "<span class='notice'>You direct [src] into [M]'s [vision.name].</span>")

			inspect_vision(vision, user)

			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN) //can be used offensively
			M.flash_eyes()
	else
		return ..()

/obj/item/device/flashlight/proc/inspect_vision(obj/item/organ/vision, mob/living/user)
	var/mob/living/carbon/human/H = vision.owner

	if(H == user)	//can't look into your own eyes buster
		return

	if(!BP_IS_ROBOTIC(vision))

		if(vision.owner.stat == DEAD || H.blinded)	//mob is dead or fully blind
			to_chat(user, SPAN("warning", "\The [H]'s pupils do not react to the light!"))
			return
		if(MUTATION_XRAY in H.mutations)
			to_chat(user, SPAN("notice", "\The [H]'s pupils give an eerie glow!"))
		if(vision.damage)
			to_chat(user, SPAN("warning", "There's visible damage to [H]'s [vision.name]!"))
		else if(H.eye_blurry)
			to_chat(user, SPAN("notice", "\The [H]'s pupils react slower than normally."))
		if(H.getBrainLoss() > 15)
			to_chat(user, SPAN("notice", "There's visible lag between left and right pupils' reactions."))

		var/list/pinpoint = list(/datum/reagent/painkiller/tramadol/oxycodone = 1, /datum/reagent/painkiller/tramadol = 5, /datum/reagent/painkiller = 2, /datum/reagent/painkiller/opium = 3, /datum/reagent/painkiller/opium/tarine = 1)
		var/list/dilating = list(/datum/reagent/space_drugs = 5, /datum/reagent/mindbreaker = 1, /datum/reagent/adrenaline = 1)
		var/datum/reagents/ingested = H.get_ingested_reagents()
		if(H.reagents.has_any_reagent(pinpoint) || ingested.has_any_reagent(pinpoint))
			to_chat(user, SPAN("notice", "\The [H]'s pupils are already pinpoint and cannot narrow any more."))
		else if(H.shock_stage >= 30 || H.reagents.has_any_reagent(dilating) || ingested.has_any_reagent(dilating))
			to_chat(user, SPAN("notice", "\The [H]'s pupils narrow slightly, but are still very dilated."))
		else
			to_chat(user, SPAN("notice", "\The [H]'s pupils narrow."))

	//if someone wants to implement inspecting robot eyes here would be the place to do it.

/obj/item/device/flashlight/upgraded
	name = "\improper LED flashlight"
	desc = "An energy efficient flashlight."
	icon_state = "biglight"
	item_state = "biglight"

	flashlight_max_bright = 0.75
	flashlight_outer_range = 5
	flashlight_falloff_curve = 3.0
	brightness_color = "#afffff"

/obj/item/device/flashlight/flashdark
	name = "flashdark"
	desc = "A strange device manufactured with mysterious elements that somehow emits darkness. Or maybe it just sucks in light? Nobody knows for sure."
	icon_state = "flashdark"
	item_state = "flashdark"
	w_class = ITEM_SIZE_NORMAL

	flashlight_max_bright = -3
	flashlight_outer_range = 4
	flashlight_inner_range = 1
	flashlight_falloff_curve = 3.0
	brightness_color = "#ffffff"

/obj/item/device/flashlight/pen
	name = "penlight"
	desc = "A pen-sized light, used by medical staff."
	icon_state = "penlight"
	item_state = ""
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_EARS
	w_class = ITEM_SIZE_TINY

	flashlight_max_bright = 0.25
	flashlight_inner_range = 0.1
	flashlight_outer_range = 2

/obj/item/device/flashlight/maglight
	name = "maglight"
	desc = "A very, very heavy duty flashlight."
	icon_state = "maglight"
	item_state = "maglight"
	force = 10
	attack_verb = list ("smacked", "thwacked", "thunked")
	matter = list(MATERIAL_STEEL = 200, MATERIAL_GLASS = 50)
	hitsound = SFX_FIGHTING_SWING

	brightness_color = "#ffffff"

/obj/item/device/flashlight/drone
	name = "low-power flashlight"
	desc = "A miniature lamp, that might be used by small robots."
	icon_state = "penlight"
	item_state = ""
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	w_class = ITEM_SIZE_TINY

	flashlight_max_bright = 0.25
	flashlight_inner_range = 0.1
	flashlight_outer_range = 2

/obj/item/device/flashlight/lantern
	name = "lantern"
	icon_state = "lantern"
	item_state = "lantern"
	desc = "A mining lantern."

	flashlight_max_bright = 0.75
	flashlight_outer_range = 5
	flashlight_falloff_curve = 2.5
	brightness_color = "#ffc58f"
	light_overlay = FALSE

/obj/item/device/flashlight/lantern/active
	flashlight_outer_range = 4
	on = TRUE

/obj/item/device/flashlight/lantern/active/Initialize()
	. = ..()
	switch_light(TRUE)
	update_icon()

// the desk lamps are a bit special
/obj/item/device/flashlight/lamp
	name = "desk lamp"
	desc = "A desk lamp with an adjustable mount."
	icon_state = "lamp"
	item_state = "lamp"
	w_class = ITEM_SIZE_LARGE
	obj_flags = OBJ_FLAG_CONDUCTIBLE

	flashlight_max_bright = 0.3
	flashlight_inner_range = 2
	flashlight_outer_range = 4
	flashlight_falloff_curve = 4.0
	on = 1

// green-shaded desk lamp
/obj/item/device/flashlight/lamp/green
	desc = "A classic green-shaded desk lamp."
	icon_state = "lampgreen"
	item_state = "lampgreen"

	flashlight_inner_range = 1.5
	flashlight_outer_range = 3
	brightness_color = "#efac75"

/obj/item/device/flashlight/lamp/brown
	desc = "A classic brown-shaded desk lamp."
	icon_state = "lampbrown"
	item_state = "lampbrown"

	flashlight_inner_range = 1.5
	flashlight_outer_range = 3
	brightness_color = "#efac75"


/obj/item/device/flashlight/lamp/verb/toggle_light()
	set name = "Toggle light"
	set category = "Object"
	set src in oview(1)

	if(!usr.stat)
		attack_self(usr)

// FLARES

/obj/item/device/flashlight/flare
	name = "flare"
	desc = "A red standard-issue flare. There are instructions on the side reading 'pull cord, make light'."
	w_class = ITEM_SIZE_TINY
	icon_state = "flare"
	item_state = "flare"

	flashlight_max_bright = 0.8
	flashlight_inner_range = 2
	flashlight_outer_range = 7
	flashlight_falloff_curve = 2.5
	brightness_color = "#e58775"

	action_button_name = null //just pull it manually, neckbeard.
	var/fuel = 0
	var/on_damage = 7
	var/produce_heat = 1500
	activation_sound = 'sound/effects/flare.ogg'

/obj/item/device/flashlight/flare/New()
	fuel = rand(800, 1000) // Sorry for changing this so much but I keep under-estimating how long X number of ticks last in seconds.
	..()

/obj/item/device/flashlight/flare/update_icon()
	overlays.Cut()
	if(on)
		icon_state = "[initial(icon_state)]-on"
		var/image/LO = overlay_image(icon, "[initial(icon_state)]-overlay", flags=RESET_COLOR)
		LO.layer = ABOVE_LIGHTING_LAYER
		LO.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		overlays += LO
	else
		icon_state = "[initial(icon_state)][fuel ? "" : "-empty"]"

/obj/item/device/flashlight/flare/Process()
	var/turf/pos = get_turf(src)
	if(pos)
		pos.hotspot_expose(produce_heat, 5)
	fuel = max(fuel - 1, 0)
	if(!fuel || !on)
		turn_off()
		STOP_PROCESSING(SSobj, src)

/obj/item/device/flashlight/flare/proc/turn_off()
	force = initial(src.force)
	damtype = initial(src.damtype)
	switch_light(FALSE)

/obj/item/device/flashlight/flare/attack_self(mob/user)
	if(turn_on(user))
		user.visible_message("<span class='notice'>\The [user] activates \the [src].</span>", "<span class='notice'>You pull the cord on the flare, activating it!</span>")

/obj/item/device/flashlight/flare/proc/turn_on(mob/user)
	if(on)
		return FALSE
	if(!fuel)
		if(user)
			to_chat(user, "<span class='notice'>It's out of fuel.</span>")
		return FALSE
	force = on_damage
	damtype = "fire"
	START_PROCESSING(SSobj, src)
	switch_light(TRUE)
	return 1

//Glowsticks
/obj/item/device/flashlight/glowstick
	name = "green glowstick"
	desc = "A military-grade glowstick."
	w_class = 2.0
	icon_state = "glowstick"
	item_state = "glowstick"
	randpixel = 12
	var/fuel = 0
	activation_sound = null

	flashlight_max_bright = 0.6
	flashlight_inner_range = 0.1
	flashlight_outer_range = 3
	brightness_color = "#49f37c"
	color = "#49f37c"
	light_overlay = FALSE

/obj/item/device/flashlight/glowstick/New()
	fuel = rand(1600, 2000)
	brightness_color = color
	..()

/obj/item/device/flashlight/glowstick/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/device/flashlight/glowstick/Process()
	fuel = max(fuel - 1, 0)
	if(!fuel)
		turn_off()
		STOP_PROCESSING(SSobj, src)
		update_icon()

/obj/item/device/flashlight/glowstick/proc/turn_off()
	on = 0
	update_icon()

/obj/item/device/flashlight/glowstick/update_icon()
	item_state = "glowstick"
	overlays.Cut()
	if(!fuel)
		icon_state = "glowstick-empty"
		set_light(0)
	else if (on)
		var/image/I = overlay_image(icon, "glowstick-on", brightness_color)
		I.blend_mode = BLEND_ADD
		overlays += I
		item_state = "glowstick-on"
		set_light(flashlight_max_bright, flashlight_inner_range, flashlight_outer_range, 2, brightness_color)
	else
		icon_state = "glowstick"
	var/mob/M = loc
	if(istype(M))
		if(M.l_hand == src)
			M.update_inv_l_hand()
		if(M.r_hand == src)
			M.update_inv_r_hand()

/obj/item/device/flashlight/glowstick/attack_self(mob/user)

	if(!fuel)
		to_chat(user,"<span class='notice'>\The [src] is spent.</span>")
		return
	if(on)
		to_chat(user,"<span class='notice'>\The [src] is already lit.</span>")
		return

	. = ..()
	if(.)
		user.visible_message("<span class='notice'>[user] cracks and shakes the glowstick.</span>", "<span class='notice'>You crack and shake the glowstick, turning it on!</span>")
		START_PROCESSING(SSobj, src)

/obj/item/device/flashlight/glowstick/red
	name = "red glowstick"
	color = "#fc0f29"

/obj/item/device/flashlight/glowstick/blue
	name = "blue glowstick"
	color = "#599dff"

/obj/item/device/flashlight/glowstick/orange
	name = "orange glowstick"
	color = "#fa7c0b"

/obj/item/device/flashlight/glowstick/yellow
	name = "yellow glowstick"
	color = "#fef923"

/obj/item/device/flashlight/glowstick/random
	name = "glowstick"
	desc = "A party-grade glowstick."
	color = "#ff00ff"

/obj/item/device/flashlight/glowstick/random/New()
	color = rgb(rand(50, 255), rand(50, 255), rand(50, 255))
	..()

/obj/item/device/flashlight/metroid
	gender = PLURAL
	name = "glowing metroid extract"
	desc = "A glowing ball of what appears to be amber."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "slime-on"
	item_state = "slime"
	w_class = ITEM_SIZE_TINY

	flashlight_max_bright = 1
	flashlight_inner_range = 0.1
	flashlight_outer_range = 4
	brightness_color = "#ffff00"
	light_overlay = FALSE
	on = 1 //Bio-luminesence has one setting, on.

/obj/item/device/flashlight/metroid/New()
	..()
	set_light(flashlight_max_bright, flashlight_inner_range, flashlight_outer_range, 2, brightness_color)

/obj/item/device/flashlight/metroid/update_icon()
	return

/obj/item/device/flashlight/metroid/attack_self(mob/user)
	return //Bio-luminescence does not toggle.
