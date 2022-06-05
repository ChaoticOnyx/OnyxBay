/*
	SYNDICATE ROUNDTYPE
*/

var/list/nuke_disks = list()

/datum/game_mode/nuclear
	name = "Nuclear Emergency"
	round_description = "A Syndicate Strike Force is approaching!"
	extended_round_description = "The Company's majority control of plasma in Nyx has marked the \
		station to be a highly valuable target for many competing organizations and individuals. Being a \
		colony of sizable population and considerable wealth causes it to often be the target of various \
		attempts of robbery, fraud and other malicious actions."
	config_tag = "nuke"
	required_players = 15
	required_enemies = 1
	end_on_antag_death = 1
	var/nuke_off_station = 0 //Used for tracking if the syndies actually haul the nuke to the station
	var/syndies_didnt_escape = 0 //Used for tracking if the syndies got the shuttle off of the z-level
	antag_tags = list(MODE_NUKE)
	cinematic_icon_states = list(
		"intro_nuke" = 35,
		"summary_nukewin",
		"summary_nukefail"
	)

//checks if L has a nuke disk on their person
/datum/game_mode/nuclear/proc/check_mob(mob/living/L)
	for(var/obj/item/disk/nuclear/N in nuke_disks)
		if(N.storage_depth(L) >= 0)
			return 1
	return 0

/datum/game_mode/nuclear/special_report()
	var/datum/antagonist/syndi = GLOB.all_antag_types_[MODE_NUKE]
	if(config.gamemode.disable_objectives == CONFIG_OBJECTIVE_ALL || (syndi && !syndi.global_objectives.len))
		return ..()
	var/disk_rescued = 1
	for(var/obj/item/disk/nuclear/D in nuke_disks)
		var/disk_area = get_area(D)
		if(!is_type_in_list(disk_area, GLOB.using_map.post_round_safe_areas))
			disk_rescued = 0
			break
	var/crew_evacuated = (evacuation_controller.has_evacuated())

	var/list/parts = list()

	if(!disk_rescued &&  station_was_nuked && !syndies_didnt_escape)
		feedback_set_details("round_end_result","win - syndicate nuke")
		parts += "<FONT size = 3><B>Syndicate Major Victory!</B></FONT>"
		parts += "<B>[syndicate_name()] operatives have destroyed [station_name()]!</B>"

	else if (!disk_rescued &&  station_was_nuked && syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - syndicate nuke - did not evacuate in time")
		parts += "<FONT size = 3><B>Total Annihilation</B></FONT>"
		parts += "<B>[syndicate_name()] operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</B> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station && !syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - blew wrong station")
		parts += "<FONT size = 3><B>Crew Minor Victory</B></FONT>"
		parts += "<B>[syndicate_name()] operatives secured the authentication disk but blew up something that wasn't [station_name()].</B> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station && syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - blew wrong station - did not evacuate in time")
		parts += "<FONT size = 3><B>[syndicate_name()] operatives have earned Darwin Award!</B></FONT>"
		parts += "<B>[syndicate_name()] operatives blew up something that wasn't [station_name()] and got caught in the explosion.</B> Next time, don't lose the disk!"

	else if (disk_rescued && GLOB.syndies.antags_are_dead())
		feedback_set_details("round_end_result","loss - evacuation - disk secured - syndi team dead")
		parts += "<FONT size = 3><B>Crew Major Victory!</B></FONT>"
		parts += "<B>The Research Staff has saved the disc and killed the [syndicate_name()] Operatives</B>"

	else if ( disk_rescued                                        )
		feedback_set_details("round_end_result","loss - evacuation - disk secured")
		parts += "<FONT size = 3><B>Crew Major Victory</B></FONT>"
		parts += "<B>The Research Staff has saved the disc and stopped the [syndicate_name()] Operatives!</B>"

	else if (!disk_rescued && GLOB.syndies.antags_are_dead())
		feedback_set_details("round_end_result","loss - evacuation - disk not secured")
		parts += "<FONT size = 3><B>Syndicate Minor Victory!</B></FONT>"
		parts += "<B>The Research Staff failed to secure the authentication disk but did manage to kill most of the [syndicate_name()] Operatives!</B>"

	else if (!disk_rescued && crew_evacuated)
		feedback_set_details("round_end_result","halfwin - detonation averted")
		parts += "<FONT size = 3><B>Syndicate Minor Victory!</B></FONT>"
		parts += "<B>[syndicate_name()] operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</B> Next time, don't lose the disk!"

	else if (!disk_rescued && !crew_evacuated)
		feedback_set_details("round_end_result","halfwin - interrupted")
		parts += "<FONT size = 3><B>Neutral Victory</B></FONT>"
		parts += "<B>Round was mysteriously interrupted!</B>"

	parts += ..()

	listclearnulls(parts)

	return parts.len ? "<div class='panel stationborder'>[parts.Join("<br>")]</div>" : null
