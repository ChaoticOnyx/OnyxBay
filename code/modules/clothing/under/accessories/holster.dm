/obj/item/clothing/accessory/holster
	name = "shoulder holster"
	desc = "A handgun holster."
	icon_state = "holster"
	slot = ACCESSORY_SLOT_HOLSTER
	high_visibility = 1
	var/obj/item/holstered = null
	var/list/can_hold
	var/datum/action/item_action/holster_action

	var/sound_holster_in = SFX_HOLSTERIN
	var/sound_holster_out = SFX_HOLSTEROUT

/datum/action/item_action/holster
	name = "Holster"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_ALIVE

/datum/action/item_action/holster/CheckRemoval(mob/living/user)
	var/obj/item/clothing/accessory/A = target
	if(!istype(A))
		return TRUE

	if(..() && isnull(A.has_suit))
		return TRUE

	if(!isnull(A.has_suit) && !(A.has_suit in user))
		return TRUE

/obj/item/clothing/accessory/holster/Initialize()
	. = ..()
	holster_action = new /datum/action/item_action/holster
	holster_action.target = src

/obj/item/clothing/accessory/holster/Destroy()
	if(has_suit)
		has_suit.verbs -= /obj/item/clothing/accessory/holster/verb/holster_verb
	QDEL_NULL(holstered)
	QDEL_NULL(holster_action)
	return ..()

/obj/item/clothing/accessory/holster/equipped(mob/user)
	. = ..()
	holster_action.Grant(user)

/obj/item/clothing/accessory/holster/ui_action_click()
	holster_verb()

/obj/item/clothing/accessory/holster/proc/holster(obj/item/I, mob/living/user)
	var/new_w_class = max(w_class, I.w_class)
	if(holstered && istype(user))
		to_chat(user, SPAN("warning", "There is already \a [holstered] holstered here!"))
		return

	if(can_hold)
		if(!is_type_in_list(I, can_hold))
			to_chat(user, SPAN("warning", "[I] won't fit in [src]!"))
			return

	else if((user.get_inventory_slot(src) in list(slot_r_store, slot_l_store))  && (new_w_class > ITEM_SIZE_SMALL))
		to_chat(user, SPAN("warning", "[I] too big to fit in [src] inside pocket!"))
		return

	else if (!(I.slot_flags & SLOT_HOLSTER))
		to_chat(user, SPAN("warning", "[I] won't fit in [src]!"))
		return

	if(istype(user))
		user.stop_aiming(no_message=1)

	if(!user.drop(I, src))
		return

	holstered = I
	holstered.add_fingerprint(user)
	w_class = max(w_class, holstered.w_class)
	user.visible_message(SPAN("notice", "[user] holsters \the [holstered]."), SPAN("notice", "You holster \the [holstered]."))
	name = "occupied [initial(name)]"

	playsound(src, sound_holster_in, rand(40,60))

/obj/item/clothing/accessory/holster/proc/clear_holster()
	holstered = null
	SetName(initial(name))

/obj/item/clothing/accessory/holster/proc/unholster(mob/user)
	if(!holstered)
		return

	if(istype(user.get_active_hand(), /obj) && istype(user.get_inactive_hand(), /obj))
		to_chat(user, SPAN("warning", "You need an empty hand to draw \the [holstered]!"))
	else
		if(user.a_intent == I_HURT)
			usr.visible_message(
				SPAN("danger", "[user] draws \the [holstered], ready to go!"),
				SPAN("warning", "You draw \the [holstered], ready to go!")
				)
		else
			user.visible_message(
				SPAN("notice", "[user] draws \the [holstered], pointing it at the ground."),
				SPAN("notice", "You draw \the [holstered], pointing it at the ground.")
				)
		user.pick_or_drop(holstered)
		holstered.add_fingerprint(user)
		w_class = initial(w_class)
		clear_holster()
		playsound(src, sound_holster_out, rand(40,60))

/obj/item/clothing/accessory/holster/attackby(obj/item/W, mob/user)
	holster(W, user)

/obj/item/clothing/accessory/holster/attack_hand(mob/user)
	if (has_suit)
		unholster(user)
	else
		..()

/obj/item/clothing/accessory/holster/emp_act(severity)
	if (holstered)
		holstered.emp_act(severity)
	..()

/obj/item/clothing/accessory/holster/examine(mob/user, infix)
	. = ..()

	if(holstered)
		. += "A [holstered] is holstered here."
	else
		. += "It is empty."

/obj/item/clothing/accessory/holster/on_attached(obj/item/clothing/under/S, mob/user)
	..()
	has_suit.verbs += /obj/item/clothing/accessory/holster/verb/holster_verb

/obj/item/clothing/accessory/holster/on_removed(mob/user)
	if(has_suit)
		has_suit.verbs -= /obj/item/clothing/accessory/holster/verb/holster_verb
	..()

//For the holster hotkey
/obj/item/clothing/accessory/holster/verb/holster_verb()
	set name = "Holster"
	set category = "Object"
	set src in usr

	if(!istype(usr, /mob/living))
		return

	if(usr.stat)
		return

	//can't we just use src here?
	var/obj/item/clothing/accessory/holster/H = null
	if (istype(src, /obj/item/clothing/accessory/holster))
		H = src
	else if (istype(src, /obj/item/clothing/under))
		var/obj/item/clothing/under/S = src
		if(LAZYLEN(S.accessories))
			H = locate() in S.accessories

	if (!H)
		to_chat(usr, SPAN("warning", "Something is very wrong."))

	if(!H.holstered)
		var/obj/item/I = usr.get_active_hand()
		if(!istype(I, /obj/item))
			to_chat(usr, SPAN("warning", "You're not holding anything to holster."))
			return
		H.holster(I, usr)
	else
		H.unholster(usr)

/obj/item/clothing/accessory/holster/armpit
	name = "armpit holster"
	desc = "A worn-out handgun holster. Perfect for concealed carry."
	icon_state = "holster"

/obj/item/clothing/accessory/holster/waist
	name = "waist holster"
	desc = "A handgun holster. Made of expensive leather."
	icon_state = "holster"
	overlay_state = "holster_low"

/obj/item/clothing/accessory/holster/hip
	name = "hip holster"
	desc = "A handgun holster slung low on the hip, draw pardner!"
	icon_state = "holster_hip"
	sound_holster_in = SFX_TACHOLSTERIN
	sound_holster_out = SFX_TACHOLSTEROUT

/obj/item/clothing/accessory/holster/thigh
	name = "thigh holster"
	desc = "A drop leg holster made of a durable synthetic fiber."
	icon_state = "holster_thigh"
	sound_holster_in = SFX_TACHOLSTERIN
	sound_holster_out = SFX_TACHOLSTEROUT

/obj/item/clothing/accessory/holster/machete
	name = "machete sheath"
	desc = "A handsome synthetic leather sheath with matching belt."
	icon_state = "holster_machete"
	can_hold = list(/obj/item/material/hatchet/machete)
	sound_holster_in = SFX_SHEATHIN
	sound_holster_out = SFX_SHEATHOUT
