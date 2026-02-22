/// Utility proc that allows easy overriding of hull vars during instantiation.
/proc/create_hull_with_overrides(list/overrides)
	var/datum/robot_hull/new_hull = new

	for (var/list/override as anything in overrides)
		if (override in new_hull.vars)
			new_hull.vars[override] = overrides[override]
		else
			util_crash_with("Attempted to override inexistent `[override]` var during hull creation!")

	return new_hull

/datum/robot_hull
	// Bitfield used in multiple places to enable or disable certain hull features.
	var/hull_flags = ROBOT_HULL_FLAG_HAS_EYES | ROBOT_HULL_FLAG_HAS_PANEL | ROBOT_HULL_FLAG_HAS_FOOTSTEPS
	// Path to the file containing the `icon_state`.
	var/icon = 'icons/mob/silicon/robot.dmi'
	// String used as the `icon_state` for the robot.
	var/icon_state = "robot"
	/// Sound played on every robot movement.
	var/footstep_sound = SFX_FOOTSTEP_ROBOT_SPIDER
	/// List of custom emote typepaths assoicated with this hull.
	var/list/default_emotes
	/// Prefix used during panel `icon_state` generation. Cannot be used from the start due to some robots having unique panels.
	VAR_PROTECTED/panel_icon_state_prefix = ROBOT_HULL_PANEL_DEFAULT

/datum/robot_hull/proc/is_panel_custom()
	return panel_icon_state_prefix == ROBOT_HULL_PANEL_CUSTOM

/datum/robot_hull/proc/get_panel_icon()
	return is_panel_custom() ? icon : ROBOT_HULL_PANEL_ICON

/datum/robot_hull/proc/get_panel_icon_state(wires = FALSE, cell = FALSE)
	var/icon_state_prefix = is_panel_custom() ? icon_state : panel_icon_state_prefix
	var/icon_state_postfix = wires ? "+w" : cell ? "+c" : "-c"

	return "[icon_state_prefix]-openpanel [icon_state_postfix]"

/datum/robot_hull/spider
	footstep_sound = SFX_FOOTSTEP_ROBOT_SPIDER

/datum/robot_hull/spider/robot
	icon_state = "robot"

/datum/robot_hull/spider/droid
	icon_state = "droid"

/datum/robot_hull/spider/robot_service
	icon_state = "robot-service"

/datum/robot_hull/spider/robot_janitor
	icon_state = "robot-janitor"

/datum/robot_hull/spider/robot_security
	icon_state = "robot-security"

/datum/robot_hull/spider/bloodhound
	icon_state = "bloodhound"

/datum/robot_hull/spider/robot_mining
	icon_state = "robot-mining"

/datum/robot_hull/spider/robot_science
	icon_state = "robot-science"

/datum/robot_hull/spider/droid_combat
	icon_state = "droid-combat"

/datum/robot_hull/spider/robot_medical
	icon_state = "robot-medical"

/datum/robot_hull/spider/robot_engineer
	icon_state = "robot-engineer"

/datum/robot_hull/spider/landmate
	icon_state = "landmate"

/datum/robot_hull/legs
	footstep_sound = SFX_FOOTSTEP_ROBOT_LEGS

/datum/robot_hull/legs/robot_old
	icon_state = "robot_old"

/datum/robot_hull/legs/service
	icon_state = "Service"

/datum/robot_hull/legs/service2
	icon_state = "Service2"

/datum/robot_hull/legs/brobot
	icon_state = "Brobot"

/datum/robot_hull/legs/maximillion
	icon_state = "maximillion"

/datum/robot_hull/legs/maidbot
	icon_state = "maidbot"

/datum/robot_hull/legs/janbot2
	icon_state = "JanBot2"

/datum/robot_hull/legs/janitorrobot
	icon_state = "janitorrobot"

/datum/robot_hull/legs/secborg
	icon_state = "secborg"

/datum/robot_hull/legs/security
	icon_state = "Security"

/datum/robot_hull/legs/securityrobot
	icon_state = "securityrobot"

/datum/robot_hull/legs/miner_old
	icon_state = "Miner_old"

/datum/robot_hull/legs/droid_miner
	icon_state = "droid-miner"

/datum/robot_hull/legs/droid_science
	icon_state = "droid-science"

/datum/robot_hull/legs/medbot
	icon_state = "Medbot"

/datum/robot_hull/legs/droid_medical
	icon_state = "droid-medical"

/datum/robot_hull/legs/engineering
	icon_state = "Engineering"

/datum/robot_hull/legs/engineerrobot
	icon_state = "engineerrobot"

/datum/robot_hull/truck
	// TODO: Add truck sound
	hull_flags = parent_type::hull_flags && (~ROBOT_HULL_FLAG_HAS_FOOTSTEPS)

/datum/robot_hull/truck/mopgearrex
	icon_state = "mopgearrex"

/datum/robot_hull/truck/secborg_tread
	icon_state = "secborg+tread"

/datum/robot_hull/truck/miner
	icon_state = "Miner"

/datum/robot_hull/truck/engiborg_tread
	icon_state = "engiborg+tread"

/datum/robot_hull/flying
	hull_flags = parent_type::hull_flags && (~ROBOT_HULL_FLAG_HAS_FOOTSTEPS)

/datum/robot_hull/flying/drone_standard
	icon_state = "drone-standard"

/datum/robot_hull/flying/eyebot_standard
	icon_state = "eyebot-standard"

/datum/robot_hull/flying/toiletbot
	icon_state = "toiletbot"

/datum/robot_hull/flying/drone_service
	icon_state = "drone-service"

/datum/robot_hull/flying/drone_hydro
	icon_state = "drone-hydro"

/datum/robot_hull/flying/drone_janitor
	icon_state = "drone-janitor"

/datum/robot_hull/flying/eyebot_janitor
	icon_state = "eyebot-janitor"

/datum/robot_hull/flying/drone_sec
	icon_state = "drone-sec"

/datum/robot_hull/flying/eyebot_security
	icon_state = "eyebot-security"

/datum/robot_hull/flying/orb_security
	icon_state = "orb-security"

/datum/robot_hull/flying/drone_miner
	icon_state = "drone-miner"

/datum/robot_hull/flying/eyebot_miner
	icon_state = "eyebot-miner"

/datum/robot_hull/flying/drone_science
	icon_state = "drone-science"

/datum/robot_hull/flying/eyebot_science
	icon_state = "eyebot-science"

/datum/robot_hull/flying/surgeon
	icon_state = "surgeon"

/datum/robot_hull/flying/drone_medical
	icon_state = "drone-medical"

/datum/robot_hull/flying/eyebot_medical
	icon_state = "eyebot-medical"

/datum/robot_hull/flying/drone_engineer
	icon_state = "drone-engineer"

/datum/robot_hull/flying/eyebot_engineering
	icon_state = "eyebot-engineering"

/datum/robot_hull/drone
	hull_flags = parent_type::hull_flags && (~ROBOT_HULL_FLAG_HAS_PANEL)
	icon_state = "repairbot"
	footstep_sound = SFX_FOOTSTEP_ROBOT_SPIDER

/datum/robot_hull/drone/construction
	icon_state = "constructiondrone"

/datum/robot_hull/sphere
	hull_flags = parent_type::hull_flags | ROBOT_HULL_FLAG_TILTABLE
	footstep_sound = SFX_FOOTSTEP_ROBOT_UNICYCLE

/datum/robot_hull/sphere/kerfur_standart
	icon_state = "kerfur-standard"
	default_emotes = list(
		/datum/emote/synth/meow,
	)

/datum/robot_hull/sphere/kerfur_engineer
	parent_type = /datum/robot_hull/sphere/kerfur_standart
	icon_state = "kerfur-engineer"

/datum/robot_hull/sphere/kerfur_security
	parent_type = /datum/robot_hull/sphere/kerfur_standart
	icon_state = "kerfur-security"

/datum/robot_hull/sphere/kerfur_service
	parent_type = /datum/robot_hull/sphere/kerfur_standart
	icon_state = "kerfur-service"

/datum/robot_hull/sphere/kerfur_science
	parent_type = /datum/robot_hull/sphere/kerfur_standart
	icon_state = "kerfur-science"
