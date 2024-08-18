/obj/item/clothing
	name = "clothing"
	siemens_coefficient = 0.9

	/// How much of a bodypart we cover
	/// Can be either a number (a common coverage rate for every bodypart we use)
	/// or a dictionary (i.e. list(UPPER_TORSO = 1.0, LOWER_TORSO = 0.5))
	var/coverage = 1.0

	var/flash_protection = FLASH_PROTECTION_NONE	// Sets the item's level of flash protection.
	var/tint = TINT_NONE							// Sets the item's level of visual impairment tint.
	/// Only these species can wear this kit.
	var/list/species_restricted = null
	var/gunshot_residue //Used by forensics.

	var/list/accessories
	var/list/valid_accessory_slots
	var/list/restricted_accessory_slots
	var/list/starting_accessories
	var/blood_overlay_type = "uniformblood"
	var/visible_name = "Unknown"

	/// How much of rays this clothing can save.
	/// Value should be in range between 0 and 1.
	rad_resist_type = /datum/rad_resist/clothing

/datum/rad_resist/clothing
	alpha_particle_resist = 17 MEGA ELECTRONVOLT
	beta_particle_resist = 3 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

// Updates the icons of the mob wearing the clothing item, if any.
/obj/item/clothing/proc/update_clothing_icon()
	return

// Updates the vision of the mob wearing the clothing item, if any
/obj/item/clothing/proc/update_vision()
	if(isliving(src.loc))
		var/mob/living/L = src.loc
		L.handle_vision()

// Checked when equipped, returns true when the wearing mob's vision should be updated
/obj/item/clothing/proc/needs_vision_update()
	return flash_protection || tint

GLOBAL_LIST_EMPTY(clothing_blood_icons)

/obj/item/clothing/get_mob_overlay(mob/user_mob, slot)
	. = ..()

	if(slot == slot_l_hand_str || slot == slot_r_hand_str)
		return

	var/image/ret = . ? . : image('icons/effects/blank.dmi')

	if(ishuman(user_mob))
		var/mob/living/carbon/human/user_human = user_mob
		if(blood_overlay_type && is_bloodied && user_human.body_build.blood_icon)
			var/mob_state = get_icon_state(slot)
			var/mob_icon = user_human.body_build.get_mob_icon(slot, mob_state)
			var/cache_index = "[mob_icon]/[mob_state]/[blood_color]"
			if(!GLOB.clothing_blood_icons[cache_index])
				var/mutable_appearance/bloodover = mutable_appearance(user_human.body_build.blood_icon, blood_overlay_type, color = blood_color, flags = DEFAULT_APPEARANCE_FLAGS|RESET_COLOR)
				bloodover.filters += filter(type = "alpha", icon = icon(mob_icon, mob_state))
				GLOB.clothing_blood_icons[cache_index] = bloodover

			ret.AddOverlays(GLOB.clothing_blood_icons[cache_index])

	for(var/obj/item/clothing/accessory/A in accessories)
		ret.AddOverlays(A.get_mob_overlay(user_mob, slot_tie_str))
	return ret

// Aurora forensics port.
/obj/item/clothing/clean_blood()
	. = ..()
	if(.)
		gunshot_residue = null

/obj/item/clothing/proc/get_fibers()
	var/fiber_id = copytext(md5("\ref[src] fiber"), 1, 6)

	. = "material from \a [name] ([fiber_id])"
	var/list/acc = list()
	for(var/obj/item/clothing/accessory/A in accessories)
		if(prob(40) && A.get_fibers())
			acc += A.get_fibers()
	if(acc.len)
		. += " with traces of [english_list(acc)]"

/obj/item/clothing/New()
	..()
	if(starting_accessories)
		for(var/T in starting_accessories)
			var/obj/item/clothing/accessory/tie = new T(src)
			src.attach_accessory(null, tie)

/obj/item/clothing/Destroy()
	QDEL_NULL_LIST(accessories)
	return ..()

//BS12: Species-restricted clothing check.
/obj/item/clothing/mob_can_equip(M as mob, slot, disable_warning = 0)

	//if we can't equip the item anyway, don't bother with species_restricted (cuts down on spam)
	if (!..())
		return 0

	if(species_restricted && istype(M,/mob/living/carbon/human))
		var/exclusive = null
		var/wearable = null
		var/mob/living/carbon/human/H = M

		if("exclude" in species_restricted)
			exclusive = 1

		if(H.species)
			if(exclusive)
				if(!(H.species.name in species_restricted))
					wearable = 1
			else
				if(H.species.name in species_restricted)
					wearable = 1

			if(!wearable && !(slot in list(slot_l_store, slot_r_store, slot_s_store)))
				if(!disable_warning)
					to_chat(H, "<span class='danger'>Your species cannot wear [src].</span>")
				return 0
	return 1

/obj/item/clothing/equipped(mob/user, slot)
	SHOULD_CALL_PARENT(TRUE)
	for(var/obj/item/clothing/accessory/accessory in accessories)
		accessory.equipped(user)
	if(needs_vision_update())
		update_vision()
	return ..()

/obj/item/clothing/play_handling_sound(slot)
	if(!pickup_sound)
		return

	if(slot == slot_l_hand || slot == slot_r_hand)
		var/volume = clamp(rand(5,15) * w_class, PICKUP_SOUND_VOLUME_MIN, PICKUP_SOUND_VOLUME_MAX)
		playsound(src, pickup_sound, volume, TRUE, extrarange = -5)
	else
		playsound(src, SFX_USE_OUTFIT, 75, TRUE, extrarange = -5)

/obj/item/clothing/proc/refit_for_species(target_species)
	if(!species_restricted)
		return //this item doesn't use the species_restricted system

	//Set species_restricted list
	switch(target_species)
		if(SPECIES_HUMAN, SPECIES_SKRELL)	//humanoid bodytypes
			species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL) //skrell/humans can wear each other's suits
		else
			species_restricted = list(target_species)

	if (sprite_sheets_obj && (target_species in sprite_sheets_obj))
		icon = sprite_sheets_obj[target_species]
	else
		icon = initial(icon)

/obj/item/clothing/head/helmet/refit_for_species(target_species)
	if(!species_restricted)
		return //this item doesn't use the species_restricted system

	//Set species_restricted list
	switch(target_species)
		if(SPECIES_SKRELL)
			species_restricted = list(SPECIES_HUMAN, SPECIES_SKRELL) //skrell helmets fit humans too
		if(SPECIES_HUMAN)
			species_restricted = list(SPECIES_HUMAN)
		else
			species_restricted = list(target_species)

	if (sprite_sheets_obj && (target_species in sprite_sheets_obj))
		icon = sprite_sheets_obj[target_species]
	else
		icon = initial(icon)

/obj/item/clothing/get_examine_line(is_visible=TRUE)
	. = ..()
	if(is_visible)
		var/list/ties
		for(var/obj/item/clothing/accessory/accessory in accessories)
			if(accessory.high_visibility)
				LAZYADD(ties, "\icon[accessory] \a [accessory]")
		if(LAZYLEN(ties))
			.+= " with [english_list(ties)] attached"
		if(LAZYLEN(accessories) > LAZYLEN(ties))
			.+= ". <a href='?src=\ref[src];list_ungabunga=1'>\[See accessories\]</a>"

/obj/item/clothing/CanUseTopic(mob/user, datum/topic_state/state, href_list)
	if(href_list && href_list["list_ungabunga"] && (user in view(get_turf(src)))) //))))))
		return STATUS_INTERACTIVE
	else
		return ..()

/obj/item/clothing/OnTopic(user, list/href_list, datum/topic_state/state)
	if(href_list["list_ungabunga"])
		if(LAZYLEN(accessories))
			var/list/ties = list()
			for(var/accessory in accessories)
				ties += "\icon[accessory] \a [accessory]"
			to_chat(user, "Attached to \the [src] are [english_list(ties)].")
		return TOPIC_HANDLED

/obj/item/clothing/proc/get_armor_coverage(def_zone, type, mob/living/carbon/human/H)
	if(!coverage)
		return

	if(!type || !def_zone)
		return

	var/obj/item/organ/external/affecting = isorgan(def_zone) ? def_zone : H?.get_organ(check_zone(def_zone))

	if(!affecting)
		return

	// If a BP is specified (or nonspecified) in 'coverage' but not in 'body_parts_covered'
	// i.e. something like pauldrons providing protection for arms without actually covering them for non-combat logic
	// then the former takes priority
	if(islist(coverage))
		for(var/entry in coverage)
			if(entry & affecting.body_part)
				return list(armor[type], coverage[entry])

	else if(body_parts_covered & affecting.body_part)
		return list(armor[type], coverage)

	return
