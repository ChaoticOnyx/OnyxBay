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

	var/list/accessories = list()
	var/list/valid_accessory_slots
	var/list/restricted_accessory_slots
	var/list/starting_accessories
	var/blood_overlay_type = "uniformblood"
	var/visible_name = "Unknown"

	/// How much of rays this clothing can save.
	/// Value should be in range between 0 and 1.
	rad_resist = list(
		RADIATION_ALPHA_PARTICLE = 17 MEGA ELECTRONVOLT,
		RADIATION_BETA_PARTICLE = 3 MEGA ELECTRONVOLT,
		RADIATION_HAWKING = 1 ELECTRONVOLT
	)

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

	var/image/ret = .

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

	if(length(accessories))
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

/obj/item/clothing/examine(mob/user, infix)
	. = ..()

	. += "<a href='?src=[ref(src)];examine_protection=1'>Show protection classes.</a>"

/obj/item/clothing/get_examine_line(is_visible=TRUE)
	. = ..()
	if(is_visible)
		var/list/ties = list()
		for(var/obj/item/clothing/accessory/accessory in accessories)
			if(accessory.high_visibility)
				ties += "\icon[accessory] \a [accessory]"
		if(ties.len)
			.+= " with [english_list(ties)] attached"
		if(accessories.len > ties.len)
			.+= ". <a href='?src=\ref[src];list_ungabunga=1'>\[See accessories\]</a>"

/obj/item/clothing/Topic(href, href_list, datum/topic_state/state)
	. = ..()

	if(href_list["examine_protection"])
		to_chat(usr, EXAMINE_BLOCK(get_protection_stats().Join("\n")))

/obj/item/clothing/CanUseTopic(mob/user, datum/topic_state/state, href_list)
	if(href_list && href_list["list_ungabunga"] && (user in view(get_turf(src)))) //))))))
		return STATUS_INTERACTIVE
	else
		return ..()

/obj/item/clothing/OnTopic(user, list/href_list, datum/topic_state/state)
	if(href_list["list_ungabunga"])
		if(accessories.len)
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

/obj/item/clothing/proc/get_protection_stats(mob/user)
	RETURN_TYPE(/list)

	. = list()

	for(var/armor_type in armor)
		var/armor_value = armor[armor_type]

		if(armor_value == 0)
			continue

		. += _describe_armor(armor_type, GLOB.descriptive_attack_types[armor_type])

	. += ""

	if(item_flags & ITEM_FLAG_AIRTIGHT)
		. += "It is airtight."

	if(item_flags & ITEM_FLAG_STOPPRESSUREDAMAGE)
		. += "Wearing this will protect you from the vacuum of space."

	if(item_flags & ITEM_FLAG_THICKMATERIAL)
		. += "The material is exceptionally thick."

	if(max_heat_protection_temperature >= FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE)
		. += "It provides very good protection against fire and heat."

	if(min_cold_protection_temperature == SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE)
		. += "It provides very good protection against very cold temperatures."

	var/list/covers
	for(var/name in string_part_flags)
		if(body_parts_covered & string_part_flags[name])
			LAZYADD(covers, name)

	var/list/slots
	for(var/name in string_slot_flags)
		if(slot_flags & string_slot_flags[name])
			LAZYADD(slots, name)

	if(length(covers))
		. += "It grants [round(coverage * 100)]% protection of the [english_list(covers)]."

	if(length(slots))
		. += "It can be worn on your [english_list(slots)]."

/obj/item/clothing/proc/_describe_armor(armor_type, descriptive_attack_type)
	switch(armor[armor_type])
		if(1 to 9)
			return "It barely protects against [descriptive_attack_type]."
		if(10 to 19)
			return "It provides a very small defense against [descriptive_attack_type]."
		if(20 to 39)
			return "It offers a small amount of protection against [descriptive_attack_type]."
		if(40 to 59)
			return "It offers a moderate defense against [descriptive_attack_type]."
		if(60 to 79)
			return "It provides a strong defense against [descriptive_attack_type]."
		if(80 to 99)
			return "It is very strong against [descriptive_attack_type]."
		if(100 to 124)
			return "This gives a very robust defense against [descriptive_attack_type]."
		if(125 to 149)
			return "Wearing this would make you nigh-invulerable against [descriptive_attack_type]."
		if(150 to INFINITY)
			return "You would be practically immune to [descriptive_attack_type] if you wore this."
