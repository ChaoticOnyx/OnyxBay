/datum/announcer
	var/sounds = list()
	var/required_tier = PATREON_NONE

/datum/announcer/default
	sounds = list(
		/datum/announce/ion_storm 						= 'sound/announcer/default/ion_storm.ogg',
		/datum/announce/gravity_failure 				= 'sound/announcer/default/gravity_start.ogg',
		/datum/announce/solar_storm_approach 			= 'sound/announcer/default/solar_storm.ogg',
		/datum/announce/solar_storm_start	 			= 'sound/announcer/default/solar_storm_start.ogg',
		/datum/announce/solar_storm_end 				= 'sound/announcer/default/solar_storm_end.ogg',
		/datum/announce/unknown_biological_entities 	= 'sound/announcer/default/unknown_biological_entities.ogg',
		/datum/announce/unidentified_lifesigns 			= 'sound/announcer/default/unidentified_lifesigns.ogg',
		/datum/announce/space_time_anomaly 				= 'sound/announcer/default/space_time_anomaly.ogg',
		/datum/announce/radiation_detected 				= 'sound/announcer/default/radiation_detected.ogg',
		/datum/announce/radiation_start 				= 'sound/announcer/default/radiation_start.ogg',
		/datum/announce/radiation_end 					= 'sound/announcer/default/radiation_end.ogg',
		/datum/announce/meteors_major_detected 			= 'sound/announcer/default/meteors_major_detected.ogg',
		/datum/announce/meteors_detected 				= 'sound/announcer/default/meteors_detected.ogg',
		/datum/announce/meteors_end 					= 'sound/announcer/default/meteors_end.ogg',
		/datum/announce/grid_restored 					= 'sound/announcer/default/grid_restored.ogg',
		/datum/announce/grid_check 						= 'sound/announcer/default/grid_check.ogg',
		/datum/announce/electrical_storm_mundane 		= 'sound/announcer/default/electrical_storm_mundane.ogg',
		/datum/announce/electrical_storm_moderate 		= 'sound/announcer/default/electrical_storm_moderate.ogg',
		/datum/announce/electrical_storm_major	 		= 'sound/announcer/default/electrical_storm_major.ogg',
		/datum/announce/electrical_storm_clear	 		= 'sound/announcer/default/electrical_storm_clear.ogg',
		/datum/announce/shuttle_called 					= 'sound/announcer/default/shuttle_called.ogg',
		/datum/announce/emergency_shuttle_called 		= 'sound/announcer/default/emergency_shuttle_called.ogg',
		/datum/announce/shuttle_recalled 				= 'sound/announcer/default/shuttle_recalled.ogg',
		/datum/announce/emergency_shuttle_recalled 		= 'sound/announcer/default/emergency_shuttle_recalled.ogg',
		/datum/announce/shuttle_docked 					= 'sound/announcer/default/shuttle_docked.ogg',
		/datum/announce/emergency_shuttle_docked 		= 'sound/announcer/default/emergency_shuttle_docked.ogg',
		/datum/announce/shuttle_leaving_dock 			= 'sound/announcer/default/shuttle_leaving_dock.ogg',
		/datum/announce/emergency_shuttle_leaving_dock 	= 'sound/announcer/default/emergency_shuttle_leaving_dock.ogg',
		/datum/announce/cascade_evacuation_canceled 	= 'sound/announcer/default/cascade_evacuation_canceled.ogg',
		/datum/announce/level_7_biohazard 				= 'sound/announcer/default/level_7_biohazard.ogg',
		/datum/announce/suspicious_cargo 				= 'sound/announcer/default/suspicious_cargo.ogg',
		/datum/announce/command_report 					= 'sound/announcer/default/command_report.ogg',
		/datum/announce/brand_intelligence_start 		= 'sound/announcer/default/brand_intelligence_start.ogg',
		/datum/announce/brand_intelligence_end 			= 'sound/announcer/default/brand_intelligence_end.ogg',
		/datum/announce/carp_migration_major 			= 'sound/announcer/default/carp_migration_major.ogg',
		/datum/announce/carp_migration 					= 'sound/announcer/default/carp_migration_major.ogg',
		/datum/announce/communications_blackout 		= 'sound/announcer/default/communications_blackout.ogg',
		/datum/announce/infestation 					= 'sound/announcer/default/infestation.ogg',
		/datum/announce/money_hack_start 				= 'sound/announcer/default/money_hack_start.ogg',
		/datum/announce/money_hack_success 				= 'sound/announcer/default/money_hack_success.ogg',
		/datum/announce/money_hack_fail 				= 'sound/announcer/default/money_hack_fail.ogg',
		/datum/announce/prison_break 					= 'sound/announcer/default/prison_break.ogg',
		/datum/announce/rogue_drones_start 				= 'sound/announcer/default/rogue_drones_start.ogg',
		/datum/announce/rogue_drones_end 				= 'sound/announcer/default/rogue_drones_end.ogg',
		/datum/announce/space_dust_start 				= 'sound/announcer/default/space_dust_start.ogg',
		/datum/announce/space_dust_end 					= 'sound/announcer/default/space_dust_end.ogg',
		/datum/announce/wallrot 						= 'sound/announcer/default/wallrot.ogg',
		/datum/announce/code_delta 						= 'sound/announcer/default/code_delta.ogg',
		/datum/announce/wormholes 						= 'sound/announcer/default/wormholes.ogg',
		/datum/announce/wormholes_end 					= 'sound/announcer/default/wormholes_end.ogg',
		/datum/announce/cascade 						= 'sound/announcer/default/cascade.ogg',
		/datum/announce/ert_cancelled 					= 'sound/announcer/default/ert_cancelled.ogg',
		/datum/announce/nuclear_bomb 					= 'sound/announcer/default/nuclear_bomb.ogg',
		/datum/announce/supply_drop 					= 'sound/announcer/default/supply_drop.ogg',
		/datum/announce/ert_unable_to_send 				= 'sound/announcer/default/ert_unable_to_send.ogg',
		/datum/announce/ert_send 						= 'sound/announcer/default/ert_send.ogg',
		/datum/announce/bluespace_artillery 			= 'sound/announcer/default/bluespace_artillery.ogg',
		/datum/announce/ictus 							= 'sound/announcer/default/ictus.ogg',
		/datum/announce/nukeops_arrival 				= 'sound/announcer/default/nukeops_arrival.ogg',
		/datum/announce/nukeops_departure 				= 'sound/announcer/default/nukeops_departure.ogg',
		/datum/announce/merchants_arrival 				= 'sound/announcer/default/merchants_arrival.ogg',
		/datum/announce/skipjack_arrival 				= 'sound/announcer/default/nukeops_arrival.ogg',
		/datum/announce/skipjack_departure 				= 'sound/announcer/default/nukeops_departure.ogg',
	)

/datum/announcer/vgstation
	required_tier = PATREON_NONE

	sounds = list(
		/datum/announce/command_report 			= 'sound/announcer/vgstation/command_report.ogg',
		/datum/announce/ion_storm 				= 'sound/announcer/vgstation/ion_storm.ogg',
		/datum/announce/level_7_biohazard 		= 'sound/announcer/vgstation/level_7_biohazard.ogg',
		/datum/announce/meteors_major_detected 	= 'sound/announcer/vgstation/meteors_major_detected.ogg',
		/datum/announce/meteors_detected 		= 'sound/announcer/vgstation/meteors_major_detected.ogg',
		/datum/announce/radiation_detected 		= 'sound/announcer/vgstation/radiation_detected.ogg',
		/datum/announce/unidentified_lifesigns 	= 'sound/announcer/vgstation/unidentified_lifesigns.ogg',
	)

/datum/announcer/baystation12
	required_tier = PATREON_NONE

	sounds = list(
		/datum/announce/command_report 				= 'sound/announcer/baystation12/command_report.ogg',
		/datum/announce/ion_storm 					= 'sound/announcer/baystation12/ion_storm.ogg',
		/datum/announce/level_7_biohazard 			= 'sound/announcer/baystation12/level_7_biohazard.ogg',
		/datum/announce/meteors_major_detected 		= 'sound/announcer/baystation12/meteors_major_detected.ogg',
		/datum/announce/meteors_detected 			= 'sound/announcer/baystation12/meteors_major_detected.ogg',
		/datum/announce/radiation_detected 			= 'sound/announcer/baystation12/radiation_detected.ogg',
		/datum/announce/unidentified_lifesigns 		= 'sound/announcer/baystation12/unidentified_lifesigns.ogg',
		/datum/announce/emergency_shuttle_called 	= 'sound/announcer/baystation12/emergency_shuttle_called.ogg',
		/datum/announce/emergency_shuttle_recalled 	= 'sound/announcer/baystation12/emergency_shuttle_recalled.ogg',
		/datum/announce/emergency_shuttle_docked 	= 'sound/announcer/baystation12/emergency_shuttle_docked.ogg',
		/datum/announce/grid_restored 				= 'sound/announcer/baystation12/grid_restored.ogg',
		/datum/announce/grid_check 					= 'sound/announcer/baystation12/grid_check.ogg',
		/datum/announce/space_time_anomaly 			= 'sound/announcer/baystation12/space_time_anomaly.ogg',
	)


/datum/announcer/baystation12_torch
	required_tier = PATREON_NONE

	sounds = list(
		/datum/announce/command_report 			= 'sound/announcer/baystation12-torch/command_report.ogg',
		/datum/announce/level_7_biohazard 		= 'sound/announcer/baystation12-torch/level_7_biohazard.ogg',
		/datum/announce/meteors_major_detected 	= 'sound/announcer/baystation12-torch/meteors_major_detected.ogg',
		/datum/announce/meteors_detected 		= 'sound/announcer/baystation12-torch/meteors_major_detected.ogg',
		/datum/announce/radiation_detected 		= 'sound/announcer/baystation12-torch/radiation_detected.ogg',
		/datum/announce/grid_restored 			= 'sound/announcer/baystation12-torch/grid_restored.ogg',
		/datum/announce/grid_check 				= 'sound/announcer/baystation12-torch/grid_check.ogg',
		/datum/announce/space_time_anomaly 		= 'sound/announcer/baystation12-torch/space_time_anomaly.ogg',
	)

/datum/announcer/tgstation
	required_tier = PATREON_NONE

	sounds = list(
		/datum/announce/command_report 				= 'sound/announcer/tgstation/command_report.ogg',
		/datum/announce/ion_storm 					= 'sound/announcer/tgstation/ion_storm.ogg',
		/datum/announce/level_7_biohazard 			= 'sound/announcer/tgstation/level_7_biohazard.ogg',
		/datum/announce/meteors_major_detected 		= 'sound/announcer/tgstation/meteors_major_detected.ogg',
		/datum/announce/meteors_detected 			= 'sound/announcer/tgstation/meteors_major_detected.ogg',
		/datum/announce/radiation_detected 			= 'sound/announcer/tgstation/radiation_detected.ogg',
		/datum/announce/grid_restored 				= 'sound/announcer/tgstation/grid_restored.ogg',
		/datum/announce/grid_check 					= 'sound/announcer/tgstation/grid_check.ogg',
		/datum/announce/space_time_anomaly 			= 'sound/announcer/tgstation/space_time_anomaly.ogg',
		/datum/announce/emergency_shuttle_called 	= 'sound/announcer/tgstation/emergency_shuttle_called.ogg',
		/datum/announce/emergency_shuttle_recalled 	= 'sound/announcer/tgstation/emergency_shuttle_recalled.ogg',
		/datum/announce/emergency_shuttle_docked 	= 'sound/announcer/tgstation/emergency_shuttle_docked.ogg',
		/datum/announce/unidentified_lifesigns 		= 'sound/announcer/tgstation/unidentified_lifesigns.ogg',
	)
