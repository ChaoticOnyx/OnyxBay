///////////////////////////////////////////////////////////////////////
//Head
/obj/item/clothing/head
	name = "head"
	icon = 'icons/obj/clothing/hats.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_hats.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_hats.dmi',
		)
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	w_class = ITEM_SIZE_SMALL
	coverage = 1.0

	var/light_overlay = "helmet_light"
	var/light_applied
	var/brightness_on
	var/on = 0

	blood_overlay_type = "helmetblood"

	drop_sound = SFX_DROP_HAT
	pickup_sound = SFX_PICKUP_HAT

/obj/item/clothing/head/get_mob_overlay(mob/user_mob, slot)
	. = ..()

	if(slot == slot_l_hand_str || slot == slot_r_hand_str)
		return

	var/image/ret = .

	var/species_name = "Default"
	if(ishuman(user_mob))
		var/mob/living/carbon/human/user_human = user_mob
		species_name = user_human.species.name
	var/cache_key = "[light_overlay]_[species_name]"
	if(on && light_overlay_cache[cache_key] && slot == slot_head_str)
		ret.AddOverlays(light_overlay_cache[cache_key])
	return ret

/obj/item/clothing/head/attack_self(mob/user)
	if(brightness_on)
		if(!isturf(user.loc))
			to_chat(user, "You cannot turn the light on while in this [user.loc]")
			return
		playsound(src, 'sound/effects/flashlight2.ogg', 75, FALSE)
		on = !on
		to_chat(user, "You [on ? "enable" : "disable"] the helmet light.")
		update_flashlight(user)
	else
		return ..(user)

/obj/item/clothing/head/proc/update_flashlight(mob/user = null)
	if(on && !light_applied)
		set_light(0.5, 1, 3)
		light_applied = 1
	else if(!on && light_applied)
		set_light(0)
		light_applied = 0
	update_icon(user)
	user.update_action_buttons()

/obj/item/clothing/head/attack_ai(mob/user)
	if(!mob_wear_hat(user))
		return ..()

/obj/item/clothing/head/attack_generic(mob/user)
	if(!istype(user) || !mob_wear_hat(user))
		return ..()

/obj/item/clothing/head/proc/mob_wear_hat(mob/user)
	if(!Adjacent(user))
		return 0
	var/success
	if(istype(user, /mob/living/silicon/robot/drone))
		var/mob/living/silicon/robot/drone/D = user
		if(D.hat)
			success = 2
		else
			D.wear_hat(src)
			success = 1
	else if(istype(user, /mob/living/carbon/alien/diona))
		var/mob/living/carbon/alien/diona/D = user
		if(D.hat)
			success = 2
		else
			D.wear_hat(src)
			success = 1

	if(!success)
		return 0
	else if(success == 2)
		to_chat(user, "<span class='warning'>You are already wearing a hat.</span>")
	else if(success == 1)
		to_chat(user, "<span class='notice'>You crawl under \the [src].</span>")
	return 1

/obj/item/clothing/head/on_update_icon(mob/user)

	ClearOverlays()
	var/mob/living/carbon/human/H
	if(istype(user,/mob/living/carbon/human))
		H = user

	if(on)

		// Generate object icon.
		if(!light_overlay_cache["[light_overlay]_icon"])
			light_overlay_cache["[light_overlay]_icon"] = image("icon" = 'icons/obj/light_overlays.dmi', "icon_state" = "[light_overlay]")
		AddOverlays(light_overlay_cache["[light_overlay]_icon"])

		// Generate and cache the on-mob icon, which is used in update_inv_head().
		var/cache_key = "[light_overlay][H ? "_[H.species.name]" : ""]"
		if(!light_overlay_cache[cache_key])
			var/use_icon = 'icons/mob/light_overlays.dmi'
			light_overlay_cache[cache_key] = image("icon" = use_icon, "icon_state" = "[light_overlay]")

	if(H)
		H.update_inv_head()

/obj/item/clothing/head/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_head()
