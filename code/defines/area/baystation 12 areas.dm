/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/bs12/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = "ICON FILENAME" 			(defaults to areas.dmi)
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = 0 				(defaults to 1)
	music = "music/music.ogg"		(defaults to "music/music.ogg")

*/

/*
This has been cleaned up from prior versions.  A few were kept, which could either not be replaced
due to being required, or were not understood well enough to rist removal  It was also categorized
for easier modification.
	- Trorbes 27/12/09
*/

/*Ok, ported from the BS12 codebase
I don't want to break the other map, so BS12 map specific stuff should only apply to the area/bs12 typepath
-Googolplexed 17/June/10
*/

area/bs12/
	var/dooraccess = ""

area/bs12/New()
	..()
	for(var/obj/machinery/door/D in src)
		if(D.req_access_txt == "" || D.req_access_txt == "0")
			D.req_access_txt = src.dooraccess
		else if(D.req_access_txt == "NA")
			D.req_access_txt = ""
	for(var/obj/machinery/power/APC in src)
		APC.name = src.name + " APC"


area/closet
	name = "Closet"
	music = ""

area/closet/save
	name = "Stasis"
	music = ""


// Primary Hallways
area/bs12/hallway/east
	name = "East Hallway"
	icon_state = "ehallway"
	music = ""

area/bs12/hallway/north
	name = "North Hallway"
	icon_state = "nhallway"
	music = ""

area/bs12/hallway/south
	name = "South Hallway"
	icon_state = "shallway"
	music = ""

area/bs12/hallway/west
	name = "West Hallway"
	icon_state = "whallway"
	music = ""

/area/bs12/hallway/southwest
	name = "Southwest Hallway"
	icon_state = "shallway" //TODO make icon
	music = ""

// MedBay and related
area/bs12/medical/medbay
	name = "Medical Bay"
	icon_state = "medical"
	music = ""
	dooraccess = "5"

area/bs12/medical/morgue
	name = "Morgue"
	icon_state = "morgue"
	music = ""
	dooraccess = "6"

area/bs12/medical/autopsy
	name = "Autopsy Room"
	icon_state = "morgue"
	music = ""
	dooraccess = "6"

area/bs12/medical/waiting
	name = "Medical Bay Waiting Room"
	icon_state = "medical"
	music = ""

area/bs12/medical/office
	name = "Medical Bay Office"
	icon_state = "medical"
	music = ""
	dooraccess = "5"

area/bs12/medical/patientA
	name = "In-Patient Room A"
	icon_state = "medical"
	music = ""
	dooraccess = "5"

area/bs12/medical/patientB
	name = "In-Patient Room B"
	icon_state = "medical"
	music = ""
	dooraccess = "5"

area/bs12/medical/patientC // For the crazies
	name = "Unstable Patient Room"
	icon_state = "medical"
	music = ""
	dooraccess = "5"

area/bs12/storage/medstorage
	name = "Medical Storage"
	icon_state = "medstorage"
	music = ""
	dooraccess = "5"

// Research labs
area/bs12/research/medical // Chemical and Genetic Research - usually considered one area
	name = "Medical Research Labs"
	icon_state = "research"
	music = ""
	dooraccess = "9"

area/bs12/research/toxins
	name = "Plasma Research Lab"
	icon_state = "toxlab"
	music = ""
	dooraccess = "7"

area/bs12/research/toxins/external
	name = "External Explosives Test Range"
	icon_state = "toxlab"
	requires_power = 0
	music = ""
	dooraccess = "7"

area/bs12/research/toxins/test_lab
	name = "Test Facility"
	requires_power=0
	icon_state = "toxlab"
	music = ""
	dooraccess = "7"

// Security and related
area/bs12/security/security
	name = "Security Headquarters"
	icon_state = "security"
	music = ""
	dooraccess =  "1"

area/bs12/security/brig
	name = "Brig"
	icon_state = "brig"
	music = ""
	dooraccess = "2"

area/bs12/security/checkpoint
	name = "Arrival Checkpoint"
	icon_state = "security"
	music = ""
	dooraccess = "1"

area/bs12/security/nstation
	name = "North Security Station"
	icon_state = "security"
	music = ""
	dooraccess = "1"

area/bs12/security/holding
	name = "North Security Station Holding Cells"
	icon_state = "brig"
	music = ""
	dooraccess = "2"

area/bs12/security/sstation
	name = "South Security Station"
	icon_state = "security"
	music = ""
	dooraccess = "1"

area/bs12/storage/secstorage
	name = "Security Storage"
	icon_state = "securitystorage"
	music = ""
	dooraccess = "3"

area/bs12/security/forensics
	name = "Forensics Lab"
	icon_state = "security"
	music = ""
	dooraccess = "4"

// administrative areas
area/bs12/administrative/bridge
	name = "Bridge"
	icon_state = "bridge"
//	music = 'music/bridge.ogg'
	dooraccess = "19"
area/bs12/administrative/court/courtroom
	name = "Courtroom"
	icon_state = "bridge"
	music = ""

area/bs12/administrative/court/counsel
	name = "Consultation Room"
	icon_state = "bridge"
	music = ""


//Elevators
area/bs12/elevators
	icon_state = "yellow"

area/bs12/elevators/centcom
	name = "Centcom Elevator"

//Airlocks
area/bs12/airlocks
	icon_state = "yellow"

area/bs12/airlocks/northwest
	music = ""
	name = "Northwest Airlock"

area/bs12/airlocks/west
	music = ""
	name = "West Airlock"

area/bs12/airlocks/northeast
	music = ""
	name = "Northeast Airlock"

area/bs12/airlocks/east
	music = ""
	name = "East Airlock"

area/bs12/airlocks/eva
	music = ""
	name = "EVA Airlock"

// Crew Quarters
area/bs12/crewquarters
	name = "Crew Quarters"
	icon_state = "crew_quarters"
	music = ""

area/bs12/headquarters/captain
	name = "Captain's Quarters"
	icon_state = "crew_quarters"
	music = ""
	dooraccess = "20"

area/bs12/headquarters/hop // Near Arrival Checkpoint
	name = "Head of Personnel's Quarters"
	icon_state = "crew_quarters"
	music = ""
	dooraccess = "19"

area/bs12/headquarters/hos // Above Courtroom
	name = "Head of Security's Quarters"
	icon_state = "crew_quarters"
	music = ""
	dooraccess = "19"

area/bs12/headquarters/hor // In Medical Research
	name = "Head of Research's Quarters"
	icon_state = "crew_quarters"
	music = ""
	dooraccess = "19"

area/bs12/headquarters/hom // Above Atmospherics
	name = "Head of Maintenance's Quarters"
	icon_state = "crew_quarters"
	music = ""
	dooraccess = "19"

// Crew Facilities
area/bs12/facilities/bar
	name = "Lounge"
	icon_state = "crew_quarters"
	music = ""
	dooraccess = "25"

area/bs12/facilities/observation
	name = "Observation Deck"
	icon_state = "crew_quarters"
	music = ""

area/bs12/facilities/meeting
	name = "Meeting Room"
	icon_state = "bridge"
	music = ""

//Quartermaster's Office
area/bs12/supply/office
	name = "Supplies Office"
	icon_state = "supplies"
	music = ""


area/bs12/supply/warehouse
	name = "Supply Warehouse"
	icon_state = "supplies"
	music = ""

area/bs12/supply/dock
	name = "Supply Shuttle Dock"
	icon_state = "supplies"
	music = ""

// Chapel
area/bs12/chapel/chapel
	name = "Chapel"
	icon_state = "chapel"
	music = ""

area/bs12/chapel/office
	name = "Counselor Office"
	icon_state = "chapel"
	music = ""
	dooraccess = "22"
area/bs12/chapel/coffin
	name = "Coffin Storage Area"
	icon_state = "chapel"
	music = ""
	dooraccess = "27"

// Station Maintenance
area/bs12/maintenance/hall
	name = "Maintenance Hallway"
	icon_state = "green"
	music = ""
	dooraccess = "12"

area/bs12/maintenance/network
	name = "Network Centre"
	icon_state = "network"
	music = ""

area/bs12/maintenance/atmos
	name = "Atmospherics"
	icon_state = "atmoss"
	music = "music/atmos.wav"
	dooraccess = "24"

area/bs12/maintenance/atmos/mixing
	name = "Atmospherics Mixing Chamber"
	icon_state = "atmoss"
	music = "music/atmos.wav"
	dooraccess = "24"

area/bs12/maintenance/atmos/mixingroom
	name = "Atmospherics Mixing room"
	icon_state = "atmoss"
	music = "music/atmos.wav"
	dooraccess = "24"

area/bs12/maintenance/atmos/canister
	name = "Atmospherics Canister Storage"
	icon_state = "atmoss"
	music = "music/atmos.wav"
	dooraccess = "24"

area/bs12/maintenance/atmostanks/oxygen
	name = "Oxygen Tank"
	icon_state = "atmoss"
	dooraccess = "24"
area/bs12/maintenance/atmostanks/plasma
	name = "Plasma Tank"
	icon_state = "atmoss"
	dooraccess = "24"
area/bs12/maintenance/atmostanks/carbondioxide
	name = "CO2 Tank"
	icon_state = "atmoss"
	dooraccess = "24"
area/bs12/maintenance/atmostanks/anesthetic
	name = "N2O Tank"
	icon_state = "atmoss"
	dooraccess = "24"
area/bs12/maintenance/atmostanks/nitrogen
	name = "N2 Tank"
	icon_state = "atmoss"
	dooraccess = "24"
area/bs12/maintenance/atmostanks/other
	name = "Waste Tank"
	icon_state = "atmoss"
	dooraccess = "24"
area/bs12/maintenance/atmostanks/burn
	name = "Burnoff Chamber"
	icon_state = "atmoss"
	dooraccess = "24"
area/bs12/maintenance/janitor
	name = "Custodial Closet"
	icon_state = "green"
	music = ""
	dooraccess = "26"
area/bs12/storage/toolstorage
	name = "Tool Storage"
	icon_state = "toolstorage"
	music = ""
area/bs12/storage/elecstorage
	name = "Electrical Storage"
	icon_state = "elecstorage"
	music = ""
	dooraccess = "23"

area/bs12/storage/northspare
	name = "Spare Storage"
	icon_state = "toolstorage"
	music = ""


area/bs12/storage/emergency
	name = "Emergency Storage"
	icon_state = "toolstorage"
	music = ""

area/bs12/storage/network
	name = "Network Storage"
	icon_state = "network"
	music = ""

area/bs12/storage/southspare
	name = "Spare Storage"
	icon_state = "toolstorage"
	music = ""

// Maintenance corridors
area/bs12/maintenance
	dooraccess = "12"
area/bs12/maintenance/corridor/necorridor
	name = "Northeast Maintenance Corridor"
	icon_state = "green"
	music = ""

area/bs12/maintenance/corridor/nwcorridor
	name = "Northwest Maintenance Corridor"
	icon_state = "green"
	music = ""

area/bs12/maintenance/corridor/secorridor
	name = "Southeast Maintenance Corridor"
	icon_state = "green"
	music = ""

area/bs12/maintenance/corridor/supcorridor
	name = "Warehouse Maintenance Corridor"
	icon_state = "green"
	music = ""

area/bs12/maintenance/corridor/swcorridor
	name = "Southeast Maintenance Corridor"
	icon_state = "green"
	music = ""

area/bs12/maintenance/corridor/eastcorridor
	name = "East Maintenance Corridor"
	icon_state = "green"
	music = ""

area/bs12/maintenance/corridor/westcorridor
	name = "West Maintenance Corridor"
	music = ""
	icon_state = "green"

area/bs12/maintenance/corridor/northconnector
	name = "North Understation Maintenance Corridor"
	music = ""
	icon_state = "green"

area/bs12/maintenance/corridor/westconnector
	name = "West Understation Maintenance Corridor"
	music = ""
	icon_state = "green"

area/bs12/maintenance/corridor/centercorridor
	name = "Central Maintenance Corridor"
	icon_state = "green"
	music = ""

area/bs12/escape/pods1
	name = "Escape Pod Bay"
	icon_state = "escape"
	music = ""

area/bs12/escape/pods2
	name = "Escape Pod Bay"
	icon_state = "escape"
	music = ""

// Engine
area/bs12/engine/enginehall
	name = "Engine Hallway"
	icon_state = "engine"
	music = ""
	dooraccess = "10"

area/bs12/engine/SMES
	name = "Engine SMES Room"
	icon_state = "engine"
	music = "music/smesroom.wav"
	dooraccess = "11"

area/bs12/engine/equipment
	name = "Engine Equipment Room"
	icon_state = "engine"
	music = ""
	dooraccess = "11"

area/bs12/engine/canstorage
	name = "Engine Canister Storage Room"
	icon_state = "engine"
	music = ""
	dooraccess = "11"

area/bs12/engine/monitoring
	name = "Engine Monitoring Room"
	icon_state = "engine"
	music = ""
	dooraccess = "11"
area/bs12/engine/control
	name = "Engine Control Room"
	icon_state = "engine"
	music = ""
	dooraccess = "11"

area/bs12/engine/engine_walls
	name = "Engine Walls"
	icon_state = "engine"
	music = ""

area/bs12/engine/combustion
	name = "Engine Combustion"
	icon_state = "engine"
	music = ""
	dooraccess = "11"

area/bs12/engine/cooling
	name = "Engine Cooling"
	icon_state = "engine"
	music = ""
	dooraccess = "11"

// Fire Station
area/bs12/rescue/firestation
	name = "Fire Station"
	icon_state = "fire_station"
	music = ""

// Solar Panels
area/bs12/solar
	icon_state = "yellow"
	lightswitch = 0
	music = ""

area/bs12/solar/east
	name = "East Solar Panels"

area/bs12/solar/west
	name = "West Solar Panels"

// Prison Station
/area/bs12/prison/arrival
	name = "Prison Arrival Corridor"
	icon_state = "green"
	requires_power = 0
	music = ""

/area/bs12/prison/security/checkpoint
	name = "Prison Checkpoint"
	icon_state = "security"
	music = ""

/area/bs12/prison/security/security
	name = "Prison Security"
	icon_state = "security"
	music = ""

/area/bs12/prison/crew_quarters
	name = "Prison Security Barracks"
	icon_state = "security"
	music = ""

/area/bs12/prison/closet
	name = "Prison Supply Closet"
	icon_state = "dk_yellow"
	music = ""

/area/bs12/prison/foyer
	name = "Prison Foyer"
	icon_state = "yellow"
	music = ""

/area/bs12/prison/morgue // Unused
	name = "Prison Morgue"
	icon_state = "morgue"
	music = ""

/area/bs12/prison/medical_research
	name = "Prison Medical Research"
	icon_state = "research"
	music = ""

/area/bs12/prison/medical
	name = "Prison Medical Bay"
	icon_state = "medical"
	music = ""

/area/bs12/prison/solar
	name = "Prison Solar Array"
	icon_state = "storage"
	requires_power = 0
	music = ""

/area/bs12/prison/solar_control
	name = "Prison Solar Array Control"
	icon_state = "dk_yellow"
	music = ""

/area/bs12/prison/cell_block
	name = "Prison Cell Block"
	icon_state = "brig"
	music = ""

//Comm Center
/area/bs12/comcenter
	name = "Commmunications Control"
	icon_state = "purple"
//	linkarea = "comdish"
	music = ""

/area/bs12/comdish
	name = "Communications Dish"
	icon_state = "purple"
	music = ""

// CentComm
/area/bs12/centcomm
	name = "Centcomm"
	icon_state = "purple"
	music = "music/ending.ogg"

/area/bs12/centcomm/medical
	name = "Centcomm Medical"
	icon_state = "purple"
	music = "music/ending.ogg"

/area/bs12/centcomm/bar
	name = "Bar"
	icon_state = "purple"
	music = "music/ending.ogg"

/area/bs12/centcomm/resupply
	name = "Resupply Hangar"
	music = "music/ending.ogg"

/area/bs12/centcomm/podbay1
	name = "Pod Bay"
	music = "music/ending.ogg"

/area/bs12/centcomm/podbay2
	name = "Pod Bay"
	music = "music/ending.ogg"

/area/bs12/centcomm/podbay3
	name = "Pod Bay"
	music = "music/ending.ogg"

/area/bs12/centcomm/podbay4
	name = "Pod Bay"
	music = "music/ending.ogg"

/area/bs12/centcomm/podbay5
	name = "Pod Bay"
	music = "music/ending.ogg"

/area/bs12/centcomm/podbay6
	name = "Pod Bay"
	music = "music/ending.ogg"

/area/bs12/centcomm/podbay7
	name = "Pod Bay"
	music = "music/ending.ogg"

/area/bs12/centcomm/podbay8
	name = "Pod Bay"
	music = "music/ending.ogg"

/area/bs12/centcomm/podbay9
	name = "Pod Bay"
	music = "music/ending.ogg"

// Misc.
area/bs12/tele
	name = "Teleporter Room"
	icon_state = "teleporter"
	music = ""
	dooraccess = "17"

area/bs12/prototype
	name = "Prototype Engine"
	icon_state = "engine"
	music = ""

//
//Unmodified areas
//

// AI-monitored areas
/area/bs12/ai_monitored/storage/eva
	name = "EVA Storage"
	icon_state = "evastorage"
	music = ""
	dooraccess = "18"

/area/bs12/ai_monitored/storage/secure
	name = "Secure Storage"
	icon_state = "storage"
	music = ""
	dooraccess = "18"

/area/bs12/ai_monitored/storage/emergency
	name = "Emergency Storage"
	icon_state = "storage"
	music = ""

// Turret-protected areas
/area/bs12/turret_protected/ai_upload
	name = "AI Upload Chamber"
	icon_state = "ai"
	music = ""
	dooraccess = "16"

/area/bs12/turret_protected/ai_upload_foyer
	name = "AI Upload Foyer"
	icon_state = "ai"
	music = ""
	dooraccess = "16"
/area/bs12/turret_protected/ai
	name = "AI Chamber"
	icon_state = "ai"
	music = ""
	dooraccess = "16"

/area/bs12/turret_protected/aisat
	name = "AI Satellite"
	icon_state = "ai"
	music = ""
	dooraccess = "16"

/area/bs12/turret_protected/AIsolar
	name = "AI Sat Solar"
	icon_state = "south"
	music = ""
	dooraccess = "16"

/area/bs12/turret_protected/AIsatext
	name = "AI Sat Ext"
	icon_state = "storage"
	music = ""
	dooraccess = "16"

/area/bs12/turret_protected/maze/turret
	name = "Space"
	icon_state = "yellow"
	music = ""

/area/bs12/turret_protected/maze/turret2
	name = "Space"
	icon_state = "yellow"
	music = ""

// Auto-protected areas (?)
/area/bs12/auto_protected/north
	name = "Northern Space Zone"
	icon_state = "dk_yellow"
	music = ""

// Thunderdome
/area/bs12/tdome
	name = "Thunderdome"
	icon_state = "medical"
	music = "music/THUNDERDOME.ogg"

/area/bs12/tdome/tdome1
	name = "Thunderdome (Team 1)"
	icon_state = "green"

/area/bs12/tdome/tdome2
	name = "Thunderdome (Team 2)"
	icon_state = "yellow"

/area/bs12/tdome/tdomea
	name = "Thunderdome (Admin.)"
	icon_state = "purple"

// Syndicate
/area/bs12/syndicate_ship
	name = "Mysterious Vessel"
	icon_state = "yellow"
	requires_power = 0
	music = ""

/area/bs12/execution
	name = "Execution Chamber"
	icon_state = "yellow"
	music = ""

/area/bs12/highrisk
	name = "High risk storage"
	icon_state = "yellow"