GLOBAL_LIST_EMPTY(revolution_posters)

/datum/game_mode/revolution
	name = "Revolution"
	config_tag = "revolution"
	round_description = "Some crewmembers are attempting to start a revolution!"
	extended_round_description = "Revolutionaries - Remove the heads of staff from power. Convert other crewmembers to your cause using the 'Convert Bourgeoise' verb. Protect your leaders."
	required_players = 4
	required_enemies = 2
	auto_recall_shuttle = 0
	end_on_antag_death = 0
	shuttle_delay = 2
	antag_tags = list(MODE_REVOLUTIONARY)
	require_all_templates = 1

	var/last_poster_update
	var/points = 0

/datum/game_mode/revolution/post_setup()
	..()
	last_poster_update = round_duration_in_ticks + 1 MINUTES


/datum/game_mode/revolution/process()
	if(last_poster_update <= round_duration_in_ticks)
		for(var/obj/structure/P in GLOB.revolution_posters)
			if(P && (P.z in GLOB.using_map.station_levels))
				points += get_area(P.loc).score
			else
				GLOB.revolution_posters -= P
		last_poster_update = round_duration_in_ticks + 1 MINUTES