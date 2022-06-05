/datum/gear/pet
	sort_category = "Pets"
	path = /mob/living/simple_animal/corgi/pet
	var/list/paths

/datum/gear/pet/New()
	..()
	if(length(paths))
		gear_tweaks += new /datum/gear_tweak/path/specified_types_list/atoms(paths)

/datum/gear/pet/is_allowed_to_equip(mob/user)
	. = ..()
	if(.)
		var/list/gears = user.client.prefs.gear_list[user.client.prefs.gear_slot]
		var/list/pets = list()
		for(var/pet_type in subtypesof(/datum/gear/pet))
			var/datum/gear/pet/pet = new pet_type()
			pets.Add(pet.display_name)
			qdel(pet)
		pets.Remove(display_name)
		for(var/gear in gears)
			if(gear in pets)
				return FALSE

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

/datum/gear/pet/wizard
	patron_tier = PATREON_WIZARD
	display_name = "Patron's pets"
	paths = list(
		/mob/living/simple_animal/cat/fluff/pet,
		/mob/living/simple_animal/cat/kitten/pet,
		/mob/living/simple_animal/corgi/pet,
		/mob/living/simple_animal/lizard/pet
	)
