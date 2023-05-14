GLOBAL_LIST_INIT(armor_by_type, generate_armor_type_cache())

/proc/generate_armor_type_cache()
	var/list/armor_cache = list()
	for(var/datum/armor/armor_type as anything in subtypesof(/datum/armor))
		armor_type = new armor_type
		armor_cache[armor_type.type] = armor_type
		armor_type.GenerateTag()
	return armor_cache

/proc/get_armor_by_type(armor_type)
	var/datum/armor/armor = locate(replacetext("[armor_type]", "/", "-"))
	if(armor)
		return armor
	if(armor_type == /datum/armor)
		CRASH("Attempted to get the base armor type, you probably meant to use /datum/armor/none")
	CRASH("Attempted to get an armor type that did not exist! '[armor_type]'")

/datum/armor
	var/bio = 0
	var/bomb = 0
	var/bullet = 0
	var/energy = 0
	var/laser = 0
	var/melee = 0

/// A version of armor with no protection
/datum/armor/none

/// A version of armor that cannot be modified and will always return itself when modified
/datum/armor/immune

/datum/armor/Destroy()
	tag = null
	return ..()

/datum/armor/proc/GenerateTag()
	tag = replacetext("[type]", "/", "-")

/datum/armor/proc/generate_new_with_modifiers(list/modifiers)
	var/datum/armor/new_armor = new

	var/all_keys = ARMOR_LIST_DAMAGE()
	if(ARMOR_ALL in modifiers)
		var/modifier_all = modifiers[ARMOR_ALL]
		if(!modifier_all)
			return src
		for(var/mod in all_keys)
			new_armor.vars[mod] += modifier_all
		return new_armor

	for(var/modifier in modifiers)
		if(modifier in all_keys)
			new_armor.vars[modifier] += modifiers[modifier]
		else
			CRASH("Attempt to call generate_new_with_modifiers with illegal modifier '[modifier]'! Ignoring it")
	return new_armor

/datum/armor/immune/generate_new_with_modifiers(list/modifiers)
	return src

/datum/armor/proc/generate_new_with_multipliers(list/multipliers)
	var/datum/armor/new_armor = new

	var/all_keys = ARMOR_LIST_DAMAGE()
	if(ARMOR_ALL in multipliers)
		var/multiplier_all = multipliers[ARMOR_ALL]
		if(!multiplier_all)
			return src
		for(var/mult in all_keys)
			new_armor.vars[mult] *= multiplier_all
		return new_armor

	for(var/multiplier in multipliers)
		if(multiplier in all_keys)
			new_armor.vars[multiplier] *= multipliers[multiplier]
		else
			CRASH("Attempt to call generate_new_with_multipliers with illegal modifier '[multiplier]'! Ignoring it")
	return new_armor

/datum/armor/immune/generate_new_with_multipliers(list/multiplier)
	return src

/datum/armor/proc/generate_new_with_specific(list/values)
	var/datum/armor/new_armor = new

	var/all_keys = ARMOR_LIST_DAMAGE()
	if(ARMOR_ALL in values)
		var/value_all = values[ARMOR_ALL]
		if(!value_all)
			return src
		for(var/val in all_keys)
			new_armor.vars[val] = value_all
		return new_armor

	for(var/value in values)
		if(value in all_keys)
			new_armor.vars[value] = values[value]
		else
			new_armor.vars[value] = vars[value]
	return new_armor

/datum/armor/immune/generate_new_with_specific(list/values)
	return src

/datum/armor/proc/get_rating(rating)
	if(!(rating in ARMOR_LIST_DAMAGE()))
		CRASH("Attempted to get a non-existant rating '[rating]'")
	return vars[rating]

/datum/armor/immune/get_rating(rating)
	return 100

/datum/armor/proc/get_rating_list(inverse = FALSE)
	var/list/ratings = list()
	for(var/rating in ARMOR_LIST_DAMAGE())
		var/value = vars[rating]
		if(inverse)
			value *= -1
		ratings[rating] = value
	return ratings

/datum/armor/immune/get_rating_list(inverse)
	var/list/ratings = ..()
	for(var/rating in ratings)
		ratings[rating] = 100
	return ratings

/datum/armor/proc/add_other_armor(datum/armor/other)
	if(ispath(other))
		other = get_armor_by_type(other)
	return generate_new_with_modifiers(other.get_rating_list())

/datum/armor/proc/substract_other_armor(datum/armor/other)
	if(ispath(other))
		other = get_armor_by_type(other)
	return generate_new_with_modifiers(other.get_rating_list(TRUE))
