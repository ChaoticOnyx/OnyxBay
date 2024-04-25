GLOBAL_DATUM_INIT(deity, /datum/antagonist/deity, new)

/datum/antagonist/deity
	id = MODE_DEITY
	role_text = "Deity"
	role_text_plural = "Deities"
	mob_path = /mob/living/deity
	welcome_text = "This is not your world. This is not your reality. But here you exist. Use your powers, feed off the faith of others.<br>You have to click on yourself to choose your form.<br>Everything you say will be heard by your cultists!<br>To get points your cultists need to build!<br>Build Shrine and Construction are the best starting boons!"
	landmark_id = "Deity"

	flags = ANTAG_OVERRIDE_MOB | ANTAG_OVERRIDE_JOB

	hard_cap = 2
	hard_cap_round = 2
	initial_spawn_req = 1
	initial_spawn_target = 1

	station_crew_involved = FALSE

/datum/antagonist/deity/New()
	GLOB.all_antag_types_[id] = src
	GLOB.all_antag_spawnpoints_[landmark_id] = list()
	GLOB.antag_names_to_ids_[role_text] = id
	..()

/datum/antagonist/deity/Initialize()
	. = ..()
	if(config.game.deity_min_age)
		min_player_age = config.game.deity_min_age
