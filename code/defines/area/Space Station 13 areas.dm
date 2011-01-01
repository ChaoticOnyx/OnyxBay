/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = "ICON FILENAME" 			(defaults to areas.dmi)
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = 0 				(defaults to 1)
	music = "music/music.ogg"		(defaults to "music/music.ogg")

*/


/area
	var/fire = null
	var/atmos = 1
	var/poweralm = 1
	var/party = null
	var/air_doors_activated = 0
	var/air_door_close_delay = 0
	level = null
	name = "Space"
	icon = 'areas.dmi'
	icon_state = "unknown"
	layer = 10
	mouse_opacity = 0
	var/lightswitch = 1

	var/redalert = 0
	var/applyalertstatus = 1

	var/eject = null

	var/requires_power = 1
	var/power_equip = 1
	var/power_light = 1
	var/power_environ = 1
	var/music = null
	var/used_equip = 0
	var/used_light = 0
	var/used_environ = 0


	var/no_air = null
	var/area/master				// master area used for power calcluations
								// (original area before splitting due to sd_DAL)
	var/list/related			// the other areas of the same type as this

	var/list/alldoors         // Doors which are not in the area, but should still be closed in case of emergency.
	var/auxdoors = list()		//Added by Strumpetplaya - Alarm Change - Contains a list of doors adjacent to this area

/area/engine/

/area/bengine/
	name = "Backup Engine"
	icon_state = "engine"

/area/turret_protected/

/area/arrival
	requires_power = 0

/area/arrival/start
	name = "Arrival Area"
	icon_state = "start"

/area/admin
	name = "Admin room"
	icon_state = "start"
	applyalertstatus = 0
	requires_power = 0
	ul_Lighting = 1

//These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.

/area/shuttle //DO NOT TURN THE ul_Lighting STUFF ON FOR SHUTTLES. IT BREAKS THINGS.
	requires_power = 0
	luminosity = 1
	ul_Lighting = 0
	applyalertstatus = 0

/area/shuttle/arrival
	name = "Arrival Shuttle"

/area/shuttle/arrival/pre_game
	icon_state = "shuttle2"

/area/shuttle/arrival/station
	icon_state = "shuttle"

/area/shuttle/escape
	name = "Escape Pod"
	music = "music/escape.ogg"

/area/shuttle/escape/transit
	icon_state = "shuttle2"

/area/shuttle/escape/transit/pod1
	name = "Escape Pod A"

/area/shuttle/escape/transit/pod2
	name = "Escape Pod B"

/area/shuttle/escape/station/pod1
	name = "Escape Pod A"

/area/shuttle/escape/station/pod2
	name = "Escape Pod B"

/area/shuttle/escape/centcom/pod1
	name = "Escape Pod A"

/area/shuttle/escape/centcom/pod2
	name = "Escape Pod B"

/area/shuttle/escape/station
	icon_state = "shuttle2"

/area/shuttle/escape/centcom
	icon_state = "shuttle"

/area/shuttle/prison/
	name = "Prison Shuttle"

/area/shuttle/prison/station
	icon_state = "shuttle"

/area/shuttle/prison/prison
	icon_state = "shuttle2"

// === Trying to remove these areas:

/area/airtunnel1/      // referenced in airtunnel.dm:759

/area/dummy/           // Referenced in engine.dm:261

/area/start            // will be unused once kurper gets his login interface patch done
	name = "start area"
	icon_state = "start"

// === end remove

/area/prison
	applyalertstatus = 0

/area/prison/arrival_airlock
	name = "Prison Station Airlock"
	icon_state = "green"
	requires_power = 0

/area/prison/control
	name = "Prison Security Checkpoint"
	icon_state = "security"

/area/prison/crew_quarters
	name = "Prison Security Quarters"
	icon_state = "security"

/area/prison/closet
	name = "Prison Supply Closet"
	icon_state = "dk_yellow"

/area/prison/hallway/fore
	name = "Prison Fore Hallway"
	icon_state = "yellow"

/area/prison/hallway/aft
	name = "Prison Aft Hallway"
	icon_state = "yellow"

/area/prison/hallway/port
	name = "Prison Port Hallway"
	icon_state = "yellow"

/area/prison/hallway/starboard
	name = "Prison Starboard Hallway"
	icon_state = "yellow"

/area/prison/morgue
	name = "Prison Morgue"
	icon_state = "morgue"

/area/prison/medical_research
	name = "Prison Genetic Research"
	icon_state = "medresearch"

/area/prison/medical
	name = "Prison Medbay"
	icon_state = "medbay"

/area/medical/robotics
	name = "Robotics"
	icon_state = "medresearch"

/area/prison/solar
	name = "Prison Solar Array"
	icon_state = "storage"
	requires_power = 0

/area/prison/podbay
	name = "Prison Podbay"
	icon_state = "dk_yellow"

/area/prison/solar_control
	name = "Prison Solar Array Control"
	icon_state = "dk_yellow"

/area/prison/solitary
	name = "Solitary Confinement"
	icon_state = "brig"

/area/prison/cell_block/A
	name = "Prison Cell Block A"
	icon_state = "brig"

/area/prison/cell_block/B
	name = "Prison Cell Block B"
	icon_state = "brig"

/area/prison/cell_block/C
	name = "Prison Cell Block C"
	icon_state = "brig"

//

/area/centcom
	name = "Centcom"
	icon_state = "purple"
	requires_power = 0
	applyalertstatus = 0

/area/atmos
 	name = "Atmospherics"
 	icon_state = "atmos"
 	music = list('ambiatm1.ogg')


/area/maintenance/fpmaint1
	name = "Sub Deck Fore Port Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fpmaint2
	name = "Main Deck Fore Port Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fpmaint3
	name = "Engineering Deck Fore Port Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fpmaint4
	name = "Bridge Deck Fore Port Maintenance"
	icon_state = "fpmaint"


/area/maintenance/fsmaint1
	name = "Sub Deck Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/maintenance/fsmaint2
	name = "Main Deck Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/maintenance/fsmaint3
	name = "Engineering Deck Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/maintenance/fsmaint4
	name = "Bridge Deck Fore Starboard Maintenance"
	icon_state = "fsmaint"


/area/maintenance/asmaint1
	name = "Sub Deck Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/maintenance/asmaint2
	name = "Main Deck Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/maintenance/asmaint3
	name = "Engineering Deck Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/maintenance/asmaint4
	name = "Bridge Deck Aft Starboard Maintenance"
	icon_state = "asmaint"


/area/maintenance/apmaint1
	name = "Sub Deck Aft Port Maintenance"
	icon_state = "apmaint"

/area/maintenance/apmaint2
	name = "Main Deck Aft Port Maintenance"
	icon_state = "apmaint"

/area/maintenance/apmaint3
	name = "Engineering Deck Aft Port Maintenance"
	icon_state = "apmaint"

/area/maintenance/apmaint4
	name = "Bridge Deck Aft Port Maintenance"
	icon_state = "apmaint"


/area/maintenance/maintcentral1
	name = "Sub Deck Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/maintcentral2
	name = "Main Deck Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/maintcentral3
	name = "Engineering Deck Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/maintcentral4
	name = "Bridge Deck Central Maintenance"
	icon_state = "maintcentral"


/area/maintenance/fmaintcentral1
	name = "Sub Deck Fore Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/fmaintcentral2
	name = "Main Deck Fore Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/fmaintcentral3
	name = "Engineering Deck Fore Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/fmaintcentral4
	name = "Bridge Deck Fore Central Maintenance"
	icon_state = "maintcentral"


/area/maintenance/pmaintcentral1
	name = "Sub Deck Port Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/pmaintcentral2
	name = "Main Deck Port Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/pmaintcentral3
	name = "Engineering Port Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/pmaintcentral4
	name = "Bridge Deck Port Central Maintenance"
	icon_state = "maintcentral"


/area/maintenance/fore1
	name = "Sub Deck Fore Maintenance"
	icon_state = "fmaint"

/area/maintenance/fore2
	name = "Main Deck Fore Maintenance"
	icon_state = "fmaint"

/area/maintenance/fore3
	name = "Engineering Deck Fore Maintenance"
	icon_state = "fmaint"

/area/maintenance/fore4
	name = "Bridge Deck Fore Maintenance"
	icon_state = "fmaint"


/area/maintenance/starboard1
	name = "Sub Deck Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/starboard2
	name = "Main Deck Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/starboard3
	name = "Engineering Deck Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/starboard4
	name = "Bridge Deck Starboard Maintenance"
	icon_state = "smaint"


/area/maintenance/hangarequip
	name = "Hangar Equipment Room"
	icon_state = "smaint"


/area/maintenance/port1
	name = "Sub Deck Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/port2
	name = "Main Deck Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/port3
	name = "Engineering Deck Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/port4
	name = "Bridge Deck Port Maintenance"
	icon_state = "pmaint"


/area/maintenance/aft1
	name = "Sub Deck Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/aft2
	name = "Main Deck Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/aft3
	name = "Engineering Deck Aft Maintenance"
	icon_state = "amaint"

/*/area/maintenance/aft4					// Moved under ai_monitored
	name = "Bridge Deck Aft Maintenance"
	icon_state = "amaint"*/


/area/maintenance/starboardsolar
	name = "Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/maintenance/portsolar
	name = "Port Solar Maintenance"
	icon_state = "SolarcontrolP"


/area/maintenance/storage
	name = "Atmospherics"
	icon_state = "green"


/area/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"


/area/hallway/primary/admin
	name = "Administrative Block Hallway"
	icon_state = "hallAdmin"

/area/hallway/primary/aftadmin
	name = "Administrative Block Hallway Aft"
	icon_state = "hallaftAdmin"

/area/hallway/primary/fore
	name = "Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/primary/services
	name = "Vessel Services Hallway"
	icon_state = "hallV"

/area/hallway/primary/starboard
	name = "Starboard Primary Hallway"
	icon_state = "hallS"


/area/hallway/primary/aft
	name = "Aft Primary Hallway"
	icon_state = "hallA"

/area/hallway/primary/forestarboard
	name = "Fore Starboard Primary Hallway"
	icon_state = "hallS"


/area/hallway/primary/port
	name = "Port Primary Hallway"
	icon_state = "hallP"


/area/hallway/primary/central
	name = "Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/primary/aftportcentral
	name = "Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/primary/aftstarboardcentral
	name = "Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/primary/portcentral
	name = "Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/primary/starboardcentral
	name = "Central Primary Hallway"
	icon_state = "hallC"


/area/hallway/secondary/exit
	name = "Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/secondary/construction
	name = "Construction Area"
	icon_state = "construction"


/area/hallway/secondary/entry
	name = "Arrival Shuttle Hallway"
	icon_state = "entry"

/area/shieldgen
	name = "Shield Generation"
	icon_state = "shield"
	music = 'hiss.ogg'


/area/bridge
	name = "Bridge"
	icon_state = "bridge"
	music = 'signal.ogg'


/area/crew_quarters/locker
	name = "Locker Room"
	icon_state = "locker"

/area/crew_quarters/sleeping/
	icon_state = "bedroom"

/area/crew_quarters/sleeping/A
	name = "Dormitory A"

/area/crew_quarters/sleeping/B
	name = "Dormitory B"

/area/crew_quarters/sleeping/C
	name = "Dormitory C"

/area/crew_quarters/fitness
	name = "Fitness Room"
	icon_state = "fitness"

/area/crew_quarters/laundromat
	name = "Laundromat"
	icon_state = "fitness"

/area/crew_quarters/lounge
	name = "Crew Lounge"
	icon_state = "crewlounge"

/area/crew_quarters/captain
	name = "Captain's Quarters"
	icon_state = "captain"

/area/crew_quarters/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"


/area/crew_quarters/kitchen
	name = "Kitchen"
	icon_state = "kitchen"


/area/crew_quarters/bar
	name= "Bar"
	icon_state = "bar"


/area/crew_quarters/hop
	name = "Head of Personnel's Quarters"
	icon_state = "head_quarters"


/area/crew_quarters/hor
	name = "Head of Research's Office"
	icon_state = "head_quarters"


/area/crew_quarters/chief
	name = "Chief Engineer's Office"
	icon_state = "head_quarters"



/area/crew_quarters/courtlobby
	name = "Courtroom Lobby"
	icon_state = "courtroom"

/area/crew_quarters/courtroom
	name = "Courtroom"
	icon_state = "courtroom"


/area/engine/engine_smes
	name = "Engine SMES Room"
	icon_state = "engine"


/area/engine/engine_walls
	name = "Engine Walls"
	icon_state = "engine"

/area/engine/engine_gas_storage
	name = "Engine Storage"
	icon_state = "engine_gas_storage"


/area/engine/engine_hallway
	name = "Engine Hallway"
	icon_state = "engine_hallway"


/area/engine/engine_mon
	name = "Engine Monitoring"
	icon_state = "engine_monitoring"


/area/engine/combustion
	name = "Engine Combustion Chamber"
	icon_state = "engine"
	music = "signal"


/area/engine/engine_control
	name = "Engine Control"
	icon_state = "engine_control"
	music = list('ambieng1.ogg')

/area/engine/launcher
	name = "Engine Launcher Room"
	icon_state = "engine_monitoring"


/area/AIsattele
	name = "AI Satellite Teleporter Room"
	icon_state = "teleporter"
	music = "signal"
	applyalertstatus = 0


/area/tdome
	name = "Thunderdome"
	icon_state = "medbay"
	requires_power = 0

/area/tdome
	applyalertstatus = 0

/area/tdome/tdome1
	name = "Thunderdome (Team 1)"
	icon_state = "green"

/area/tdome/tdome2
	name = "Thunderdome (Team 2)"
	icon_state = "yellow"

/area/tdome/tdomea
	name = "Thunderdome (Admin.)"
	icon_state = "purple"

/area/medical/medbay
	name = "Medbay"
	icon_state = "medbay"
	music = 'signal.ogg'

/area/medical/medbay/office
	name = "Medbay"
	icon_state = "medbayoffice"

/area/medical/research
	name = "Medical Research"
	icon_state = "medresearch"


/area/medical/morgue
	name = "Morgue"
	icon_state = "morgue"
	music = list('ambimo1.ogg','ambimo2.ogg')
/area/medical/morgue/autopsy
	name = "Autopsy"
	icon_state = "morgue"
	music = list('ambimo1.ogg','ambimo2.ogg')


/area/security/main
	name = "Security"
	icon_state = "security"


/area/security/checkpoint
	name = "Arrivals Checkpoint"
	icon_state = "checkpoint1"


/area/security/checkpoint2
	name = "Laboratories Security Checkpoint"
	icon_state = "security"

/area/security/checkpoint3
	name = "Docking Checkpoint"
	icon_state = "security"


/area/security/brig
	name = "Brig"
	icon_state = "brig"

/area/security/prison
	name = "Prison"
	icon_state = "brig"

/area/security/checkpointp
	name = "Prison Checkpoint"
	icon_state = "security"


/area/security/detectives_office
	name = "Detectives Office"
	icon_state = "detective"

/area/solar
	requires_power = 0
	luminosity = 1
	ul_Lighting = 0

/area/solar/fore
	name = "Fore Solar Array"
	icon_state = "yellow"


/area/solar/asteroid
	name = "Mining Base Solar Array"
	icon_state = "yellow"


/area/solar/aft
	name = "Aft Solar Array"
	icon_state = "aft"


/area/solar/starboard
	name = "Starboard Solar Array"
	icon_state = "panelsS"


/area/solar/port
	name = "Port Solar Array"
	icon_state = "panelsP"

/area/solar/derelict_starboard
	name = "Derelict Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/derelict_aft
	name = "Derelict Aft Solar Array"
	icon_state = "aft"

/area/syndicate_station
	name = "Syndicate Station"
	icon_state = "yellow"
	requires_power = 0

/area/wizard_station
	name = "Wizard's Den"
	icon_state = "yellow"
	requires_power = 0


/area/quartermaster/office
	name = "Quartermaster's Office"
	icon_state = "quartoffice"


/area/quartermaster/storage
	name = "Quartermaster's Storage"
	icon_state = "quartstorage"


/area/quartermaster/
	name = "Quartermasters"
	icon_state = "quart"

/area/network/
	name = "Network Centre"
	icon_state = "networkcenter"

/area/janitor/
	name = "Janitors Closet"
	icon_state = "janitor"

/area/firefighting
	name = "Fire Station"
	icon_state = "fire"

/area/hangar
	name = "Hangar"
	icon_state = "hangar"

/area/hangar/derelict
	icon_state = "hangar"
	name = "DERELICT HANGAR OBJECT TEMPLATE"

/area/hangar/supply
	name = "Supply Shuttle Hangar"
	icon_state = "hangar"

/area/hangar/exposed
	name = "Hangar"
	icon_state = "hangar"

/area/hangar/escape
	name = "Escape Hangar"
	icon_state = "hangar"

/area/hangar/escape/crew //TODO more after I place them



/area/chemistry
	name = "Chemistry"
	icon_state = "chem"


/area/toxins/lab
	name = "Toxin Lab"
	icon_state = "toxlab"


/area/toxins/storage
	name = "Toxin Storage"
	icon_state = "toxstorage"


/area/toxins/test_area
	name = "Toxin Test Area"
	icon_state = "toxtest"


/area/chapel/main
	name = "Chapel"
	icon_state = "chapel"
	music = list('ambicha1.ogg','ambicha2.ogg','ambicha3.ogg','ambicha4.ogg')


/area/chapel/office
	name = "Counselor's Office"
	icon_state = "chapeloffice"


/area/storage/tools
	name = "Tool Storage"
	icon_state = "storage"


/area/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/storage/network
	name = "Network Equipment Storage"
	icon_state = "networkstorage"

/area/storage/autolathe
	name = "Autolathe Storage"
	icon_state = "storage"

/area/storage/electrical
	name = "Electrical Storage"
	icon_state = "elecstorage"

/area/storage/auxillary
	name = "Auxillary Storage"
	icon_state = "auxstorage"

/area/storage/eva
	name = "EVA Storage"
	icon_state = "eva"

/area/storage/library
	name = "Library"
	icon_state = "library"

/area/storage/secure
	name = "Secure Storage"
	icon_state = "storage"

/area/storage/emergency
	name = "Emergency Storage A"
	icon_state = "emergencystorage"

/area/storage/emergency2
	name = "Emergency Storage B"
	icon_state = "emergencystorage"

/area/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"

/area/storage/testroom
	requires_power = 0
	name = "Test Room"
	icon_state = "storage"

/area/derelict
	name = "Derelict Station"
	icon_state = "storage"
	applyalertstatus = 0

/area/derelict/hallway/primary
	name = "Derelict Primary Hallway"
	icon_state = "hallP"

/area/derelict/hallway/secondary
	name = "Derelict Secondary Hallway"
	icon_state = "hallS"

/area/derelict/arrival
	name = "Arrival Centre"
	icon_state = "yellow"

/area/derelict/storage/equipment
	name = "Derelict Equipment Storage"

/area/derelict/storage/storage_access
	name = "Derelict Storage Access"

/area/derelict/storage/engine_storage
	name = "Derelict Engine Storage"
	icon_state = "green"

/area/derelict/bridge
	name = "Control Room"
	icon_state = "bridge"

/area/derelict/bridge/access
	name = "Control Room Access"
	icon_state = "auxstorage"

/area/derelict/bridge/ai_upload
	name = "Ruined Computer Core"
	icon_state = "ai"

/area/derelict/solar_control
	name = "Solar Control"
	icon_state = "engine"

/area/derelict/crew_quarters
	name = "Derelict Crew Quarters"
	icon_state = "fitness"

/area/derelict/medical
	name = "Derelict Medbay"
	icon_state = "medbay"

/area/derelict/medical/morgue
	name = "Derelict Morgue"
	icon_state = "morgue"

/area/derelict/medical/chapel
	name = "Derelict Chapel"
	icon_state = "chapel"

/area/derelict/teleporter
	name = "Derelict Teleporter"
	icon_state = "teleporter"

/area/derelict/eva
	name = "Derelict EVA Storage"
	icon_state = "eva"

/area/derelict/ship
	name = "Abandoned ship"
	icon_state = "yellow"


/area/ai_monitored/teleporter
	name = "Teleporter"
	icon_state = "teleporter"
	music = "signal"

/area/ai_monitored/maintenance/aft4
	name = "Bridge Deck Aft Maintenance"
	icon_state = "amaint"

/area/ai_monitored/storage/eva
	name = "EVA Storage"
	icon_state = "eva"

/area/ai_monitored/storage/secure
	name = "Secure Storage"
	icon_state = "storage"

/area/ai_monitored/storage/emergency
	name = "Emergency Storage"
	icon_state = "storage"


/area/turret_protected/ai_upload
	name = "AI Upload Chamber"
	icon_state = "ai_upload"
	var/obj/machinery/camera/motion/motioncamera = null

/area/turret_protected/ai_upload/New()
	..()
	// locate and store the motioncamera
	spawn (20) // spawn on a delay to let turfs/objs load
		for (var/obj/machinery/camera/motion/M in src)
			motioncamera = M
			return
	return

/area/turret_protected/ai_upload/Entered(atom/movable/O)
	..()
	if (istype(O, /mob) && motioncamera)
		motioncamera.newTarget(O)

/area/turret_protected/ai_upload/Exited(atom/movable/O)
	..()
	if (istype(O, /mob) && motioncamera)
		motioncamera.lostTarget(O)

/area/turret_protected/ai_upload_foyer
	name = "AI Upload Foyer"
	icon_state = "ai_foyer"

/area/turret_protected/ai
	name = "AI Chamber"
	icon_state = "ai_chamber"

/area/turret_protected/aisat
	name = "AI Satellite"
	icon_state = "ai"
	applyalertstatus = 0

/area/turret_protected/aisat_interior
	name = "AI Satellite"
	icon_state = "ai"
	applyalertstatus = 0

/area/turret_protected/AIsatextFP
	name = "AI Sat Ext"
	icon_state = "storage"
	applyalertstatus = 0

/area/turret_protected/AIsatextFS
	name = "AI Sat Ext"
	icon_state = "storage"
	applyalertstatus = 0

/area/turret_protected/AIsatextAS
	name = "AI Sat Ext"
	icon_state = "storage"
	applyalertstatus = 0

/area/turret_protected/AIsatextAP
	name = "AI Sat Ext"
	icon_state = "storage"
	applyalertstatus = 0


/area/asteroid
	name = "Asteroid"
	icon_state = "asteroid"
	applyalertstatus = 0

/area/asteroid/base
	name = "Mining base"
	icon_state = "asbase"
	applyalertstatus = 0


/area/asteroid/base/Refinery
	name = "Refinery"
	icon_state = "asbase"
	applyalertstatus = 0


/area/dockingbay/admin
	name = "Docking Bay D"
	icon_state = "ai_chamber"
	var/shuttle = ""

/area/dockingbay/main
	name = "External Airlocks"


/area/syndicateshuttle
	name = "Syndicate shuttle"
	icon_state = "ai_chamber"
/area/nanotrasenshuttle
	name = "Nanotrasen shuttle"
	icon_state = "nt_shuttle"
/area/alienshuttle
	name = "Alien shuttle"
	icon_state = "ai_chamber"
