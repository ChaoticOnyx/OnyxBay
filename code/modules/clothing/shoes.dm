///////////////////////////////////////////////////////////////////////
//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	force = 2

	permeability_coefficient = 0.50
	siemens_coefficient = 0.7
	body_parts_covered = FEET
	slot_flags = SLOT_FEET
	armor = list(melee = 40, bullet = 10, laser = 10,energy = 15, bomb = 25, bio = 20)
	coverage = 1.0

	species_restricted = list("exclude", SPECIES_UNATHI, SPECIES_TAJARA, SPECIES_VOX)
	blood_overlay_type = "shoeblood"

	drop_sound = SFX_DROP_SHOES
	pickup_sound = SFX_PICKUP_SHOES

	item_state_slots = list(
		slot_l_hand_str = "shoes",
		slot_r_hand_str = "shoes",
		)

	var/overshoes = 0
	var/can_hold_knife
	var/obj/item/holding
	var/track_blood = 0

/obj/item/clothing/shoes/Destroy()
	if(holding)
		holding.forceMove(get_turf(src))
		holding = null
	QDEL_NULL(holding)
	return ..()

/obj/item/clothing/shoes/proc/draw_knife()
	set name = "Draw Boot Knife"
	set desc = "Pull out your boot knife."
	set category = "IC"
	set src in usr

	if(usr.stat || usr.restrained() || usr.incapacitated())
		return

	holding.forceMove(get_turf(usr))

	if(usr.put_in_hands(holding))
		usr.visible_message("<span class='warning'>\The [usr] pulls \the [holding] out of \the [src]!</span>", range = 1)
		holding = null
	else
		to_chat(usr, "<span class='warning'>Your need an empty, unbroken hand to do that.</span>")
		holding.forceMove(src)

	if(!holding)
		verbs -= /obj/item/clothing/shoes/proc/draw_knife

	update_icon()
	return

/obj/item/clothing/shoes/attack_hand(mob/living/M)
	if(can_hold_knife && holding && src.loc == M)
		draw_knife()
		return
	..()

/obj/item/clothing/shoes/attackby(obj/item/I, mob/user)
	if(can_hold_knife && is_type_in_list(I, list(/obj/item/material/shard, /obj/item/material/butterfly, /obj/item/material/kitchen/utensil, /obj/item/material/hatchet/tacknife, /obj/item/material/knife/shiv)))
		if(holding)
			to_chat(user, "<span class='warning'>\The [src] is already holding \a [holding].</span>")
			return
		if(!user.drop(I, src))
			return
		holding = I
		user.visible_message("<span class='notice'>\The [user] shoves \the [I] into \the [src].</span>", range = 1)
		verbs |= /obj/item/clothing/shoes/proc/draw_knife
		update_icon()
	else if(istype(I, /obj/item/flame/match))
		var/obj/item/flame/match/M = I
		M.light_by_shoes(user)
	else
		return ..()

/obj/item/clothing/shoes/on_update_icon()
	ClearOverlays()
	if(holding)
		AddOverlays(image(icon, "[icon_state]_knife"))
	return ..()

/obj/item/clothing/shoes/proc/handle_movement(turf/walking, running)
	return

/obj/item/clothing/shoes/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_shoes()

/obj/item/clothing/shoes/add_blood(source, new_track_blood = 0)
	. = ..(source)
	if(.)
		track_blood = max(new_track_blood, track_blood)

/obj/item/clothing/shoes/clean_blood()
	. = ..()
	if(.)
		track_blood = 0
