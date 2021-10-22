/datum/gear/pet
	sort_category = "Pets"
	patron_tier = PATREON_WIZARD
	cost = 5

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

/datum/gear/pet/cat
	display_name = "Nice cat"
	path = /mob/living/simple_animal/cat/fluff/pet

/datum/gear/pet/kitten
	display_name = "Cute kitten"
	path = /mob/living/simple_animal/cat/kitten/pet

/datum/gear/pet/corgi
	display_name = "Cool corgi"
	path = /mob/living/simple_animal/corgi/pet

/datum/gear/pet/lizard
	display_name = "Сold-blooded lizard"
	path = /mob/living/simple_animal/lizard/pet
