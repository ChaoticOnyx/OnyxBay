/atom/proc/get_armor()
	return armor || get_armor_by_type(armor_type)

/atom/proc/get_armor_rating(damage_type)
	var/datum/armor/armor = get_armor()
	return armor.get_rating(damage_type)

/atom/proc/set_armor(datum/armor/armor)
	if(src.armor == armor)
		return
	if(!(src.armor?.type in GLOB.armor_by_type))
		qdel(src.armor)
	src.armor = ispath(armor) ? get_armor_by_type(armor) : armor

/atom/proc/set_armor_rating(damage_type, rating)
	var/datum/armor/armor = get_armor()
	set_armor(armor.generate_new_with_specific(list("[damage_type]" = rating)))
