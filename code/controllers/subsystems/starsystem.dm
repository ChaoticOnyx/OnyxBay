/// Subsystem to control overmap events and the greater gameworld
SUBSYSTEM_DEF(star_system)
	name = "star_system"
	wait = 1 SECOND
	init_order = SS_INIT_STARMAP
	flags = SS_NO_FIRE

	/// Last time an AI controlled ship attacked the players
	var/last_combat_enter = 0
	var/list/systems = list()
	var/list/traders = list()
	/// Bounties pool to be delivered for destroying syndicate ships
	var/bounty_pool = 0
	var/list/enemy_types = list()
	/// 2-d array. Format: list("ship" = ship, "x" = 0, "y" = 0, "current_system" = null, "target_system" = null, "transit_time" = 0)
	var/list/ships = list()
	//Starmap 2
	var/time_limit = FALSE //Do we want to end the round after a specific time?
	var/datum/star_system/return_system //Which system should we jump to at the end of the round?

	/// The main overmap (players' ship)
	var/obj/structure/overmap/main_overmap = null
	var/saving = FALSE

/datum/controller/subsystem/star_system/Initialize(start_timeofday)
	load_systems()
	lateload_systems()
	. = ..()
	return_system = system_by_id(config.overmap.return_system)

/datum/controller/subsystem/star_system/proc/load_systems()
	for(var/list/sys_info in config.overmap.systems)
		systems += new /datum/star_system(
			name = sys_info["name"],
			desc = sys_info["desc"],
			x = sys_info["x"],
			y = sys_info["y"],
			alignment = sys_info["alignment"],
			owner = sys_info["owner"],
			hidden = sys_info["hidden"] || FALSE,
			sector = sys_info["sector"],
			adjacency_list = sys_info["adjacency_list"] || list(),
			threat_level = sys_info["threat_level"] || THREAT_LEVEL_NONE,
			is_capital = sys_info["is_capital"] || FALSE,
			parallax_property = sys_info["parallax_property"] || null,
			visitable = sys_info["visitable"] || FALSE,
			is_hypergate = sys_info["is_hypergate"] || FALSE,
			system_traits = sys_info["system_traits"] || 0,
			system_type = sys_info["system_type"] || list(),
			audio_cues = sys_info["audio_cues"] || list(),
			wormhole_connections = sys_info["wormhole_connections"] || list(),
		)

/datum/controller/subsystem/star_system/proc/lateload_systems()
	for(var/datum/star_system/system in systems)
		if(!(system.system_traits & STARSYSTEM_NO_ANOMALIES))
			system.generate_anomaly()

		if(!(system.system_traits & STARSYSTEM_NO_ASTEROIDS))
			system.spawn_asteroids()

/datum/controller/subsystem/star_system/proc/system_by_id(id)
	for(var/datum/star_system/sys in systems)
		if(sys.name != id)
			continue

		return sys

/datum/controller/subsystem/star_system/proc/find_main_overmap() //Find the main ship
	if(main_overmap)
		return main_overmap

	for(var/obj/structure/overmap/OM in GLOB.overmap_objects) //We shouldn't have to do this, but fallback
		if(OM.role == MAIN_OVERMAP)
			return OM

/datum/controller/subsystem/star_system/proc/add_ship(obj/structure/overmap/OM, turf/target)
	ships[OM] = list("ship" = OM, "x" = 0, "y" = 0, "current_system" = system_by_id(OM.starting_system), "last_system" = system_by_id(OM.starting_system), "target_system" = null, "from_time" = 0, "to_time" = 0, "occupying_z" = OM.z)
	var/datum/star_system/curr = ships[OM]["current_system"]
	curr.add_ship(OM, target)

//Used to determine what system a ship is currently in
/datum/controller/subsystem/star_system/proc/find_system(obj/O)
	var/datum/star_system/system
	if(isovermap(O))
		var/obj/structure/overmap/OM = O
		system = system_by_id(OM.starting_system)
		if(!ships[OM])
			return

		else if(!ships[OM]["current_system"])
			ships[OM]["current_system"] = system
		else
			system = ships[OM]["current_system"]
	return system
