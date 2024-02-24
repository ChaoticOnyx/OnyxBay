/obj/item/clothing/proc/describe_armor(armor_type, descriptive_attack_type)
	if(armor[armor_type])
		switch(armor[armor_type])
			if(1 to 20)
				return "It barely protects against [descriptive_attack_type]."
			if(21 to 30)
				return "It provides a very small defense against [descriptive_attack_type]."
			if(31 to 40)
				return "It offers a small amount of protection against [descriptive_attack_type]."
			if(41 to 55)
				return "It offers a moderate defense against [descriptive_attack_type]."
			if(56 to 70)
				return "It provides a strong defense against [descriptive_attack_type]."
			if(81 to 100)
				return "It is very strong against [descriptive_attack_type]."
			if(101 to 120)
				return "This gives a very robust defense against [descriptive_attack_type]."
			if(121 to 150)
				return "Wearing this would make you nigh-invulerable against [descriptive_attack_type]."
			if(151 to INFINITY)
				return "You would be practically immune to [descriptive_attack_type] if you wore this."



/obj/item/clothing/get_description_info()
	. = list()
	. += description_info + "\
		<br>"

	if(armor["melee"])
		. += "[describe_armor("melee","blunt force")] \n"
	if(armor["bullet"])
		. += "[describe_armor("bullet","ballistics")] \n"
	if(armor["laser"])
		. += "[describe_armor("laser","lasers")] \n"
	if(armor["energy"])
		. += "[describe_armor("energy","energy")] \n"
	if(armor["bomb"])
		. += "[describe_armor("bomb","explosions")] \n"
	if(armor["bio"])
		. += "[describe_armor("bio","biohazards")] \n"

	. += "\n"

	if(item_flags & ITEM_FLAG_AIRTIGHT)
		. += "It is airtight. \n"

	if(item_flags & ITEM_FLAG_STOPPRESSUREDAMAGE)
		. += "Wearing this will protect you from the vacuum of space. \n"

	if(item_flags & ITEM_FLAG_THICKMATERIAL)
		. += "The material is exceptionally thick. \n"

	if(max_heat_protection_temperature == FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE)
		. += "It provides very good protection against fire and heat. \n"

	if(min_cold_protection_temperature == SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE)
		. += "It provides very good protection against very cold temperatures. \n"

	var/islist_coverage = islist(coverage)
	var/list/covers = list()
	var/list/slots = list()

	for(var/name in string_part_flags)
		if(body_parts_covered & string_part_flags[name])
			var/coverage_entry = name
			if(islist_coverage)
				for(var/entry in coverage)
					if(entry == name)
						coverage_entry += " ([round(coverage[entry] * 100)]%)"
			covers += coverage_entry

	for(var/name in string_slot_flags)
		if(slot_flags & string_slot_flags[name])
			slots += name

	if(covers.len)
		. += "It covers [islist_coverage ? ("[round(coverage * 100)] of ") : ""]the [english_list(covers)]. \n"

	if(slots.len)
		. += "It can be worn on your [english_list(slots)]. \n"

	return jointext(., null)
