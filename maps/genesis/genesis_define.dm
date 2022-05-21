/datum/map/genesis
	name = "Genesis"
	full_name = "NSS Genesis"
	path = "genesis"
	legacy_mode = TRUE

	shuttle_types = list(
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod1,
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod2,
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod3,
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod5,
		/datum/shuttle/autodock/ferry/supply/drone,
		/datum/shuttle/autodock/ferry/elevator,
		/datum/shuttle/autodock/multi/antag/mining,
		/datum/shuttle/autodock/ferry/research,
		/datum/shuttle/autodock/ferry/engie,
		/datum/shuttle/autodock/ferry/mining,
		/datum/shuttle/autodock/multi/antag/rescue,
		/datum/shuttle/autodock/ferry/emergency/centcom,
		/datum/shuttle/autodock/ferry/administration,
		/datum/shuttle/autodock/multi/antag/syndicate,
		/datum/shuttle/autodock/multi/antag/elite_syndicate,
		/datum/shuttle/autodock/ferry/deathsquad,
		/datum/shuttle/autodock/multi/antag/merchant,
		/datum/shuttle/autodock/multi/antag/skipjack,
	)

	map_levels = list(
		new /datum/space_level/genesis_1,
		new /datum/space_level/genesis_2,
		new /datum/space_level/genesis_3,
		new /datum/space_level/genesis_4,
		new /datum/space_level/telecomms
	)

	station_name  = "NSS Genesis"
	station_short = "Genesis"
	dock_name     = "NAS Crescent"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "NanoTrasen"
	company_short = "NT"
	system_name   = "Nyx"

	shuttle_docked_message = "The scheduled Crew Transfer Shuttle to %Dock_name% has docked with the station. It will depart in approximately %ETD%"
	shuttle_leaving_dock = "The Crew Transfer Shuttle has left the station. Estimate %ETA% until the shuttle docks at %dock_name%."
	shuttle_called_message = "A crew transfer to %Dock_name% has been scheduled. The shuttle has been called. It will arrive in approximately %ETA%"
	shuttle_recall_message = "The scheduled crew transfer has been cancelled."

	evac_controller_type = /datum/evacuation_controller/shuttle

	species_to_job_whitelist = list(
		/datum/species/tajaran = list(
									/datum/job/assistant,
									/datum/job/bartender,
									/datum/job/chef,
									/datum/job/hydro,
									/datum/job/cargo_tech,
									/datum/job/mining,
									/datum/job/janitor,
									/datum/job/librarian,
									/datum/job/merchant
									),
		/datum/species/unathi = list(
									/datum/job/assistant,
									/datum/job/bartender,
									/datum/job/chef,
									/datum/job/hydro,
									/datum/job/cargo_tech,
									/datum/job/mining,
									/datum/job/janitor,
									/datum/job/librarian,
									/datum/job/officer,
									/datum/job/merchant
									),
		/datum/species/skrell = list(/datum/job/assistant,
									/datum/job/bartender,
									/datum/job/chef,
									/datum/job/hydro,
									/datum/job/janitor,
									/datum/job/librarian,
									/datum/job/doctor,
									/datum/job/virologist,
									/datum/job/chemist,
									/datum/job/psychiatrist,
									/datum/job/scientist,
									/datum/job/xenobiologist,
									/datum/job/roboticist,
									/datum/job/merchant
									)
	)
