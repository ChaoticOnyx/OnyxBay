//Base Armor Values

#define OM_ARMOR list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 80, "bio" = 100, "rad" = 100, "acid" = 100, "stamina" = 100)

#define isovermap(A) (istype(A, /obj/structure/overmap))
#define isasteroid(A) (istype(A, /obj/structure/overmap/asteroid))
#define isanomaly(A) (istype(A, /obj/effect/overmap_anomaly))

//Assigning player ships goes here

#define NORMAL_OVERMAP 1
#define MAIN_OVERMAP 2
#define MAIN_MINING_SHIP 3
#define PVP_SHIP 4
#define INSTANCED_MIDROUND_SHIP 5

//Sensor resolution

GLOBAL_LIST_INIT(overmap_objects, list())
GLOBAL_LIST_INIT(overmap_anomalies, list())

//Northeast, Northwest, Southeast, Southwest
#define ARMOUR_FORWARD_PORT "forward_port"
#define ARMOUR_FORWARD_STARBOARD "forward_starboard"
#define ARMOUR_AFT_PORT "aft_port"
#define ARMOUR_AFT_STARBOARD "aft_starboard"

//Ship mass
#define MASS_TINY 1 //1 Player - Fighters
#define MASS_SMALL 2 //2-5 Players - FoB/Mining Ship
#define MASS_MEDIUM 3 //10-20 Players - Small Capital Ships
#define MASS_MEDIUM_LARGE 5 //10-20 Players - Small Capital Ships
#define MASS_LARGE 7 //20-40 Players - Medium Capital Ships
#define MASS_TITAN 150 //40+ Players - Large Capital Ships
#define MASS_IMMOBILE 200 //Things that should not be moving. See: stations

//Fun tools
#define SHIELD_NOEFFECT 0 //!Shield failed to absorb hit.
#define SHIELD_ABSORB 1 //!Shield absorbed hit.
#define SHIELD_FORCE_DEFLECT 2 //!Shield absorbed hit and is redirecting projectile with slightly turned vector.
#define SHIELD_FORCE_REFLECT 3 //!Shield absorbed hit and is redirecting projectile in reverse direction.

//Time between each 'combat cycle' of starsystems. Every combat cycle, every system that has opposing fleets in it gets iterated through, with the fleets firing at eachother.
#define COMBAT_CYCLE_INTERVAL 180 SECONDS

//Threat level of star systems
#define THREAT_LEVEL_NONE 0
#define THREAT_LEVEL_UNSAFE 2
#define THREAT_LEVEL_DANGEROUS 4

//The different sectors, keep this updated
#define ALL_STARMAP_SECTORS 1,2,3

//Overmap deletion behavior - Occupants are defined as non-simple mobs.
/// Not a real bitflag, just here for readability. If no damage flags are set, damage will delete the overmap immediately regardless of anyone in it
#define DAMAGE_ALWAYS_DELETES 		    0
/// When the overmap takes enough damage to be destroyed, begin a countdown after which it will be deleted
#define DAMAGE_STARTS_COUNTDOWN		    (1<<0)
/// When the overmap takes enough damage to be destroyed, if there are no occupants, delete it immediately. Modifies DAMAGE_STARTS_COUNTDOWN
#define DAMAGE_DELETES_UNOCCUPIED	    (1<<1)
/// Even if the overmap takes enough damage to be destroyed, never delete it if it's occupied. I don't know when we'd use this it just seems useful
#define NEVER_DELETE_OCCUPIED		    (1<<2)
/// When a fighter/dropship leaves the map level for the overmap level, look for remaining occupants. If none exist, delete
#define DELETE_UNOCCUPIED_ON_DEPARTURE 	(1<<3)
/// Docked overmaps count as occupants when deciding whether to delete something
#define FIGHTERS_ARE_OCCUPANTS		    (1<<4)

//Starsystem Traits
#define STARSYSTEM_NO_ANOMALIES (1<<0)//Prevents Anomalies Spawning
#define STARSYSTEM_NO_ASTEROIDS (1<<1)	//Prevents Asteroids Spawning
#define STARSYSTEM_NO_WORMHOLE  (1<<2)//Prevents Incoming Wormholes
#define STARSYSTEM_END_ON_ENTER (1<<3) //End the round after entering this system (Outpost 45)

// FTL Drive Computer States. (Legacy only)
#define FTL_STATE_IDLE 1
#define FTL_STATE_SPOOLING 2
#define FTL_STATE_READY 3
#define FTL_STATE_JUMPING 4

#define OVERMAP_USER_ROLE_PILOT    (1<<0)
#define OVERMAP_USER_ROLE_OBSERVER (1<<1)

#define HARDPOINT_SLOT_PRIMARY "Primary"
#define HARDPOINT_SLOT_SECONDARY "Secondary"
#define HARDPOINT_SLOT_UTILITY "Utility"
#define HARDPOINT_SLOT_ARMOUR "Armour"
#define HARDPOINT_SLOT_DOCKING "Docking Module"
#define HARDPOINT_SLOT_CANOPY "Canopy"
#define HARDPOINT_SLOT_FUEL "Fuel Tank"
#define HARDPOINT_SLOT_ENGINE "Engine"
#define HARDPOINT_SLOT_RADAR "Radar"
#define HARDPOINT_SLOT_OXYGENATOR "Atmospheric Regulator"
#define HARDPOINT_SLOT_BATTERY "Battery"
#define HARDPOINT_SLOT_APU "APU"
#define HARDPOINT_SLOT_FTL "FTL"
#define HARDPOINT_SLOT_COUNTERMEASURE "Countermeasure"
#define HARDPOINT_SLOT_UTILITY_PRIMARY "Primary Utility"
#define HARDPOINT_SLOT_UTILITY_SECONDARY "Secondary Utility"

#define ALL_HARDPOINT_SLOTS list(HARDPOINT_SLOT_PRIMARY, HARDPOINT_SLOT_SECONDARY,HARDPOINT_SLOT_UTILITY, HARDPOINT_SLOT_ARMOUR, HARDPOINT_SLOT_FUEL, HARDPOINT_SLOT_ENGINE, HARDPOINT_SLOT_RADAR, HARDPOINT_SLOT_CANOPY, HARDPOINT_SLOT_OXYGENATOR,HARDPOINT_SLOT_DOCKING, HARDPOINT_SLOT_BATTERY, HARDPOINT_SLOT_APU, HARDPOINT_SLOT_FTL, HARDPOINT_SLOT_COUNTERMEASURE)
#define HARDPOINT_SLOTS_STANDARD list(HARDPOINT_SLOT_PRIMARY, HARDPOINT_SLOT_SECONDARY, HARDPOINT_SLOT_ARMOUR, HARDPOINT_SLOT_FUEL, HARDPOINT_SLOT_ENGINE, HARDPOINT_SLOT_RADAR,HARDPOINT_SLOT_CANOPY, HARDPOINT_SLOT_OXYGENATOR,HARDPOINT_SLOT_DOCKING, HARDPOINT_SLOT_BATTERY, HARDPOINT_SLOT_APU, HARDPOINT_SLOT_FTL, HARDPOINT_SLOT_COUNTERMEASURE)
#define HARDPOINT_SLOTS_UTILITY list(HARDPOINT_SLOT_UTILITY_PRIMARY,HARDPOINT_SLOT_UTILITY_SECONDARY, HARDPOINT_SLOT_ARMOUR, HARDPOINT_SLOT_FUEL, HARDPOINT_SLOT_ENGINE, HARDPOINT_SLOT_RADAR, HARDPOINT_SLOT_DOCKING, HARDPOINT_SLOT_BATTERY, HARDPOINT_SLOT_APU, HARDPOINT_SLOT_FTL, HARDPOINT_SLOT_COUNTERMEASURE)

#define LOADOUT_DEFAULT_FIGHTER /datum/component/ship_loadout
#define LOADOUT_UTILITY_ONLY /datum/component/ship_loadout/utility

#define ENGINE_RPM_SPUN 8000
