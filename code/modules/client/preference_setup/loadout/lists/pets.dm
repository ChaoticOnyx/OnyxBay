/datum/gear/pet
	sort_category = "Pets"
	path = /mob/living/simple_animal/corgi/pet
	var/list/paths
	// patron_tier = PATREON_WIZARD
	// cost = 200

/datum/gear/pet/New()
	..()
	if(length(paths))
		gear_tweaks += new /datum/gear_tweak/contents/atoms(paths)

/datum/gear/pet/spawn_item(location, metadata)
	var/datum/gear_data/gd = new(path, location)
	for(var/datum/gear_tweak/gt in gear_tweaks)
		gt.tweak_gear_data(metadata["[gt]"], gd)
	var/item = new gd.path(gd.location)
	for(var/datum/gear_tweak/gt in gear_tweaks)
		gt.tweak_item(item, metadata["[gt]"])
	return item

/datum/gear/pet/spawn_on_mob(mob/living/carbon/human/H, metadata)
	return FALSE

/datum/gear/pet/spawn_as_accessory_on_mob(mob/living/carbon/human/H, metadata)
	return FALSE

/datum/gear/pet/spawn_in_storage_or_drop(mob/living/carbon/human/H, metadata)
	var/mob/living/simple_animal/animal = spawn_item(H, metadata)

	if(animal)
		to_chat(H, SPAN_DANGER("Dropping \the [animal] on the ground!"))
		animal.forceMove(get_turf(H))
		animal.add_fingerprint(H)
		var/datum/mob_ai/pet/mob_ai = animal.mob_ai
		if(!istype(mob_ai))
			return FALSE
		mob_ai.master = H
		to_chat(H, SPAN_NOTICE("\The [animal] waiting for your commands."))

	return !!animal

/datum/gear/pet/capital
	cost = 200
	display_name = "Capitalist's pets"
	paths = list(/mob/living/simple_animal/lizard/pet)

/datum/gear/pet/wizard
	patron_tier = PATREON_WIZARD
	display_name = "Patron's pets"
	paths = list(
		/mob/living/simple_animal/cat/fluff/pet,
		/mob/living/simple_animal/cat/kitten/pet,
		/mob/living/simple_animal/corgi/pet,
		/mob/living/simple_animal/lizard/pet
	)
