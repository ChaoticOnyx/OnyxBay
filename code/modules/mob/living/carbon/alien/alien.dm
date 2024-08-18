/mob/living/carbon/alien

	name = "alien"
	desc = "What IS that?"
	icon = 'icons/mob/alien.dmi'
	icon_state = "alien"
	pass_flags = PASS_FLAG_TABLE
	health = 100
	maxHealth = 100
	mob_size = 4
	species_language = "Xenomorph"

	var/adult_form = null
	var/dead_icon
	var/amount_grown = 0
	var/max_grown = 200
	var/time_of_birth
	var/language
	var/death_msg = "lets out a waning guttural screech, green blood bubbling from its maw."
	var/can_namepick_as_adult = 0
	var/adult_name
	var/instance_num

/mob/living/carbon/alien/New()

	time_of_birth = world.time

	verbs += /mob/living/proc/ventcrawl
	verbs += /mob/living/proc/hide

	instance_num = rand(1, 1000)
	name = "[initial(name)] ([instance_num])"
	real_name = name
	regenerate_icons()

	if(language)
		add_language(language)

	gender = NEUTER

	..()

/mob/living/carbon/alien/__unequip(obj/W)
	return

/mob/living/carbon/alien/Stat()
	. = ..()

/mob/living/carbon/alien/restrained()
	return 0

/mob/living/carbon/alien/show_inv(mob/user)
	return FALSE//Consider adding cuffs and hats to this, for the sake of fun.
