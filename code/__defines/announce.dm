#define DEFAULT_ANNOUNCER /datum/announcer/default

GLOBAL_VAR_CONST(PREF_ANNOUNCER_DEFAULT, "Default")
GLOBAL_VAR_CONST(PREF_ANNOUNCER_VGSTATION, "\[Cargo\] /VG/station (Legacy)")
GLOBAL_VAR_CONST(PREF_ANNOUNCER_BAYSTATION12, "\[Cargo\] BayStation12 (Legacy)")
GLOBAL_VAR_CONST(PREF_ANNOUNCER_BAYSTATION12_TORCH, "\[Cargo\] BayStation12-Torch (Legacy)")
GLOBAL_VAR_CONST(PREF_ANNOUNCER_TGSTATION, "\[Cargo\] /TG/station (Legacy)")

/datum/announce
	var/text = null
	var/title = "Attention"
	var/sender = "Common"
	var/channel_name = "Announcements"
	var/announcement_type = "Announcement"
	var/sound = null

/datum/announce/ion_storm
	text = "It has come to our attention that the %STATION_NAME% passed through an ion storm. Please monitor all electronic equipment for malfunctions."
	title = "Anomaly Alert"

/datum/announce/gravity_failure
	text = "Feedback surge detected in mass-distributions systems. Engineers are strongly advised to deal with the problem."
	title = "Gravity Failure"

/datum/announce/solar_storm_approach
	text = "A solar storm has been detected approaching the %STATION_NAME%. Please halt all EVA activities immediately and return inside."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/solar_storm_start
	text = "The solar storm has reached the %STATION_NAME%. Please refain from EVA and remain inside until it has passed."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/solar_storm_end
	text = "The solar storm has passed the %STATION_NAME%. It is now safe to resume EVA activities."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/unknown_biological_entities
	text = "Unknown biological entities have been detected near the %STATION_NAME%, please stand-by."
	title = "Lifesign Alert"

/datum/announce/unidentified_lifesigns
	text = "Unidentified lifesigns detected coming aboard the %STATION_NAME%. Please lockdown all exterior access points, including ducting and ventilation."
	title = "Lifesign Alert"

/datum/announce/space_time_anomaly
	text = "Space-time anomalies detected on the station. There is no additional data."
	title = "Anomaly Alert"

/datum/announce/radiation_detected
	text = "High levels of radiation has been detected in proximity of the %STATION_NAME%. Please report to the medical bay if any strange symptoms occur."
	title = "Anomaly Alert"

/datum/announce/radiation_start
	text = "The %STATION_NAME% has entered the beta rays belt. Please remain in a sheltered area until we have passed the belt."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/radiation_end
	text = "The %STATION_NAME% has passed the beta rays belt. Please allow for up to one minute while radiation levels dissipate, and report to the infirmary if you experience any unusual symptoms. Maintenance will lose all access again shortly."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/meteors_major_detected
	text = "Meteors have been detected on a collision course with the %STATION_NAME%."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/meteors_detected
	text = "The %STATION_NAME% is now in a meteor shower."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/meteors_major_end
	text = "The %STATION_NAME% has cleared the meteor storm."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/meteors_end
	text = "The %STATION_NAME% has cleared the meteor shower"
	title = "%STATION_NAME% Sensor Array"

/datum/announce/grid_restored
	text = "Station power to the %STATION_NAME% will be restored at this time. We apologize for the inconvenience."
	title = "Power Systems Nominal"

/datum/announce/grid_check
	text = "Abnormal activity detected in the %STATION_NAME%'s power system. As a precaution, the %STATION_NAME%'s power must be shut down for an indefinite duration."
	title = "Automated Grid Check"

/datum/announce/electrical_storm_mundane
	text = "A minor electrical storm has been detected near the %STATION_NAME%. Please watch out for possible electrical discharges."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/electrical_storm_moderate
	text = "The %STATION_NAME% is about to pass through an electrical storm. Please secure sensitive electrical equipment until the storm passes."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/electrical_storm_major
	text = "Alert. A strong electrical storm has been detected in proximity of the %STATION_NAME%. It is recommended to immediately secure sensitive electrical equipment until the storm passes."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/electrical_storm_clear
	text = "The %STATION_NAME% has cleared the electrical storm. Please repair any electrical overloads."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/shuttle_called

/datum/announce/emergency_shuttle_called

/datum/announce/shuttle_recalled
	text = "The scheduled crew transfer has been cancelled."

/datum/announce/emergency_shuttle_recalled
	text = "The emergency shuttle has been recalled."

/datum/announce/shuttle_docked

/datum/announce/emergency_shuttle_docked

/datum/announce/shuttle_leaving_dock

/datum/announce/emergency_shuttle_leaving_dock

/datum/announce/cascade_evacuation_canceled
	text = "The evacuation has been aborted due to bluespace distortion."

/datum/announce/level_7_biohazard
	text = "Confirmed outbreak of level 7 biohazard aboard the %STATION_NAME%. All personnel must contain the outbreak."
	title = "Biohazard Alert"

/datum/announce/captain_arrival
	sound = 'sound/misc/boatswain.ogg'

/datum/announce/suspicious_cargo
	text = "Suspicious cargo shipment has been detected. Security intervention is recommended in the supply department."

/datum/announce/command_report
	text = "Attention! A new command report created."

/datum/announce/slot_machine
	title = "NanoTrasen Welfare Department"

/datum/announce/brand_intelligence_start
	title = "Machine Learning Alert"

/datum/announce/brand_intelligence_end
	text = "All traces of the rampant brand intelligence have disappeared from the systems."
	title = "%STATION_NAME% Firewall Subroutines"

/datum/announce/carp_migration_major
	text = "Massive migration of unknown biological entities has been detected near the %STATION_NAME%, please stand-by."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/carp_migration
	title = "%STATION_NAME% Sensor Array"

/datum/announce/communications_blackout

/datum/announce/infestation
	title = "Major Bill's Shipping Critter Sensor"

/datum/announce/money_hack_start
	title = "%STATION_NAME% Firewall Subroutines"

/datum/announce/money_hack_success
	text = "The hack attempt has succeeded."
	title = "%STATION_NAME% Firewall Subroutines"

/datum/announce/money_hack_fail
	text = "The hack attempt has failed."
	title = "%STATION_NAME% Firewall Subroutines"

/datum/announce/prison_break

/datum/announce/rogue_drones_start
	title = "%STATION_NAME% Sensor Array"

/datum/announce/rogue_drones_end
	text = "Be advised: sensors indicate the unidentified drone swarm has left the immediate proximity of the %STATION_NAME%."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/space_dust_start
	text = "The %STATION_NAME% is now passing through a belt of space dust."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/space_dust_end
	text = "The %STATION_NAME% has now passed through the belt of space dust."
	title = "%STATION_NAME% Sensor Array"

/datum/announce/wallrot
	text = "Harmful fungi detected on %STATION_NAME%. Structures may be contaminated."
	title = "Biohazard Alert"

/datum/announce/security_level_elevated
	sound = 'sound/signals/alarm2.ogg'

/datum/announce/security_level_down
	sound = 'sound/signals/start1.ogg'

/datum/announce/code_delta
	text = "The self-destruct mechanism has been engaged. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill."
	title = "Attention! Delta security level reached!"

/datum/announce/wormholes

/datum/announce/wormholes_end
	text = "Bluespace anomaly has ceased."

/datum/announce/cascade

/datum/announce/immovable_rod
	text = "What the fuck was that?!"
	title = "General Alert"

/datum/announce/ert_cancelled
	title = "Emergency Transmission"

/datum/announce/meteor_mode_alert

/datum/announce/meteor_mode_start

/datum/announce/nuclear_bomb
	text = "The self-destruct sequence has reached terminal countdown, abort systems have been disabled."
	title = "Self-Destruct Control Computer"

/datum/announce/request_console_announce

/datum/announce/supply_drop
	title = "Thank You For Your Patronage"

/datum/announce/ert_unable_to_send
	text = "It would appear that an emergency response team was requested for %STATION_NAME%. Unfortunately, we were unable to send one at this time."

/datum/announce/ert_send
	text = "It would appear that an emergency response team was requested for %STATION_NAME%. We will prepare and send one as soon as possible."

/datum/announce/bluespace_artillery
	text = "Bluespace artillery fire detected. Brace for impact."

/datum/announce/ai
	title = "A.I. Announcement"
	announcement_type = "A.I. Announcement"

/datum/announce/comm_program

/datum/announce/ictus
	text = "Suspicious biological activity was noticed at the station. The medical crew should immediately prepare for the fight against the pathogen. Infected crew members must not leave the station under any circumstances."
	title = "Biohazard Alert"

/datum/announce/nukeops_arrival
	text = "Attention, you have a large signature approaching the station - looks unarmed to surface scans. We're too far out to intercept - brace for visitors."
	title = "NMV Icarus Sensor Array"

/datum/announce/nukeops_departure
	text = "Your visitors are on their way out of the system, burning delta-v like it's nothing. Good riddance."
	title = "NMV Icarus Sensor Array"

/datum/announce/merchants_arrival
	text = "Attention, you have an unarmed cargo vessel, which appears to be a merchant ship, approaching the station."
	title = "NMV Icarus Sensor Array"

/datum/announce/skipjack_arrival
	text =  "Attention, you have a large signature approaching the station - looks unarmed to surface scans. We're too far out to intercept - brace for visitors."
	title = "NMV Icarus Sensor Array"

/datum/announce/skipjack_departure
	text = "Your visitors are on their way out of the system, burning delta-v like it's nothing. Good riddance."
	title = "NMV Icarus Sensor Array"
