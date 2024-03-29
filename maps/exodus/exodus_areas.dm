// SHUTTLES
// Shuttle areas must contain at least two areas in a subgroup if you want to move a shuttle from one place to another.
// Look at escape shuttle for example.
// All shuttles should now be under shuttle since we have smooth-wall code.
/area/AAshuttle/administration/centcom
	name = "\improper Administration Shuttle"
	icon_state = "shuttlered"

/area/AAshuttle/administration/station
	name = "\improper Administration Shuttle"
	icon_state = "shuttlered2"

/area/AAshuttle/supply/elevator
	name = "Cargo Elevator"
	icon_state = "shuttle3"

/area/AAshuttle/supply/elevator/upper
	name = "Cargo Elevator Upper Deck"
	base_turf = /turf/simulated/open

/area/AAshuttle/supply/elevator/lower
	name = "Cargo Elevator Lower Deck"
	base_turf = /turf/simulated/floor/plating

/area/AAshuttle/merchant
	icon_state = "shuttlegrn"

/area/AAshuttle/merchant/home
	name = "\improper Merchant Van - Home"

/area/AAshuttle/merchant/transit
	icon_state = "shuttlegrn"
	base_turf = /turf/space/transit/south

/area/AAshuttle/merchant/away
	name = "\improper Merchant Van - Station North East"

/area/AAshuttle/merchant/dock
	name = "\improper Merchant Van - Station Docking Bay"

/area/AAshuttle/merchant/ghetto
	name = "\improper Merchant Van - Station Ghetto Dock"

/area/AAshuttle/merchant/outpost
	name = "\improper Merchant Van - Outpost"

// Command
/area/AAcrew_quarters/heads/chief
	name = "\improper Engineering - CE's Office"

/area/AAcrew_quarters/heads/hos
	name = "\improper Security - HoS' Office"

/area/AAcrew_quarters/heads/hop
	name = "\improper Command - HoP's Office"

/area/AAcrew_quarters/heads/hor
	name = "\improper Research - RD's Office"

/area/AAcrew_quarters/heads/cmo
	name = "\improper Command - CMO's Office"

/area/AAbridge
	name = "\improper Bridge"
	icon_state = "bridge"

/area/AAbridge/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	sound_env = MEDIUM_SOFTFLOOR

/area/AAbridge/meeting_room/cafe
	name = "\improper Heads of Staff Cafeteria"

// Shuttles

/area/AAshuttle/constructionsite
	name = "Construction Site Shuttle"
	icon_state = "yellow"

/area/AAshuttle/constructionsite/station
	name = "Construction Site Shuttle"

/area/AAshuttle/constructionsite/transit
	name = "Construction Site Shuttle Transit"
	icon_state = "shuttle"

/area/AAshuttle/mining
	name = "\improper Mining Shuttle"

/area/AAshuttle/mining/outpost
	icon_state = "shuttle"
	base_turf = /turf/simulated/floor/asteroid

/area/AAshuttle/mining/station
	icon_state = "shuttle2"

/area/AAshuttle/mining/transit
	name = "Mining Shuttle Transit"
	icon_state = "shuttle"

/area/AAshuttle/security
	name = "\improper Security Shuttle"

/area/AAshuttle/security/outpost
	icon_state = "shuttle"
	base_turf = /turf/simulated/floor/asteroid

/area/AAshuttle/security/station
	icon_state = "shuttle2"

/area/AAshuttle/security/transit
	name = "Mining Security Transit"
	icon_state = "shuttle"

/area/AAshuttle/deathsquad/centcom
	name = "Deathsquad Shuttle"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/AAshuttle/deathsquad/transit
	name = "Deathsquad Shuttle Internim"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/AAshuttle/deathsquad/station
	name = "Deathsquad Shuttle Station"

/area/AAshuttle/administration
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/AAshuttle/syndicate_elite
	name = "\improper Syndicate Elite Shuttle"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/AAshuttle/transport/centcom
	icon_state = "shuttle"
	name = "\improper Transport Shuttle Centcom"

/area/AAshuttle/transport/transit
	icon_state = "shuttle"
	name = "\improper Transport Shuttle Transit"

/area/AAshuttle/transport/station
	icon_state = "shuttle"
	name = "\improper Transport Shuttle"

/area/AAshuttle/alien/mine
	icon_state = "shuttle"
	name = "\improper Alien Shuttle Mine"
	requires_power = 1

/area/AAshuttle/alien/base
	icon_state = "shuttle"
	name = "\improper Alien Shuttle Base"
	requires_power = 1

/area/AAshuttle/arrival
	name = "\improper Arrival Shuttle"

/area/AAshuttle/arrival/station
	icon_state = "shuttle"

/area/AAshuttle/escape/centcom
	name = "\improper Emergency Shuttle Centcom"
	icon_state = "shuttle"

/area/AAshuttle/escape
	name = "\improper Emergency Shuttle"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/AAshuttle/escape/station
	name = "\improper Emergency Shuttle Station"
	icon_state = "shuttle2"

/area/AAshuttle/escape/transit // the area to pass through for 3 minute transit
	name = "\improper Emergency Shuttle Transit"
	icon_state = "shuttle"

/area/AAshuttle/escape_pod1
	name = "\improper Escape Pod One"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/AAshuttle/escape_pod1/station
	icon_state = "shuttle2"

/area/AAshuttle/escape_pod1/transit
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

/area/AAshuttle/escape_pod2
	name = "\improper Escape Pod Two"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/AAshuttle/escape_pod2/station
	icon_state = "shuttle2"

/area/AAshuttle/escape_pod2/transit
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

/area/AAshuttle/escape_pod3
	name = "\improper Escape Pod Three"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/AAshuttle/escape_pod3/station
	icon_state = "shuttle2"

/area/AAshuttle/escape_pod3/transit
	icon_state = "shuttle"
	base_turf = /turf/space/transit/east

/area/AAshuttle/escape_pod5 // Pod 4 was lost to meteors
	name = "\improper Escape Pod Five"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/AAshuttle/escape_pod5/station
	icon_state = "shuttle2"

/area/AAshuttle/escape_pod5/transit
	icon_state = "shuttle"
	base_turf = /turf/space/transit/east

/area/AAshuttle/administration/transit
	name = "Administration Shuttle Transit"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/east

// === Trying to remove these areas:

/area/AAshuttle/research
	name = "\improper Research Shuttle"

/area/AAshuttle/research/station
	icon_state = "shuttle2"

/area/AAshuttle/research/outpost
	icon_state = "shuttle"
	base_turf = /turf/simulated/floor/asteroid

/area/AAshuttle/research/transit
	name = "Research Shuttle Transit"
	icon_state = "shuttle"

// SYNDICATES

/area/AAsyndicate_mothership
	name = "\improper Syndicate Base"
	icon_state = "syndie-ship"
	requires_power = 0
	dynamic_lighting = 0

/area/AAsyndicate_mothership/ninja
	name = "\improper Ninja Base"
	requires_power = 0
	base_turf = /turf/space/transit/north

// RESCUE

// names are used
/area/AArescue_base
	name = "\improper Response Team Base"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = 1
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/AArescue_base/base
	name = "\improper Barracks"
	icon_state = "yellow"
	dynamic_lighting = 0

/area/AArescue_base/start
	name = "\improper Response Team Base"
	icon_state = "shuttlered"

/area/AArescue_base/southwest
	name = "south-west of SS13"
	icon_state = "southwest"

/area/AArescue_base/northwest
	name = "north-west of SS13"
	icon_state = "northwest"

/area/AArescue_base/northeast
	name = "north-east of SS13"
	icon_state = "northeast"

/area/AArescue_base/southeast
	name = "south-east of SS13"
	icon_state = "southeast"

/area/AArescue_base/north
	name = "north of SS13"
	icon_state = "north"

/area/AArescue_base/south
	name = "south of SS13"
	icon_state = "south"

/area/AArescue_base/arrivals_dock
	name = "docked with station"
	icon_state = "shuttle"

/area/AArescue_base/transit
	name = "\proper bluespace"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

// MINING MOTHERSHIP

/area/AAcreaker
	name = "\improper Mining Ship 'Creaker'"
	icon_state = "yellow"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/AAcreaker/station
	name = "\improper Mining Ship 'Creaker'"
	icon_state = "shuttlered"

/area/AAcreaker/north
	name = "northern asteroid field"
	icon_state = "southwest"

/area/AAcreaker/west
	name = "western asteroid field"
	icon_state = "northwest"

/area/AAcreaker/east
	name = "eastern asteroid field"
	icon_state = "northeast"

// ENEMY

// names are used
/area/AAsyndicate_station
	name = "\improper Independant Station"
	icon_state = "yellow"
	requires_power = 0
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/AAsyndicate_station/start
	name = "\improper Syndicate Forward Operating Base"
	icon_state = "yellow"

/area/AAsyndicate_station/southwest
	name = "south-west of SS13"
	icon_state = "southwest"

/area/AAsyndicate_station/northwest
	name = "north-west of SS13"
	icon_state = "northwest"

/area/AAsyndicate_station/northeast
	name = "north-east of SS13"
	icon_state = "northeast"

/area/AAsyndicate_station/southeast
	name = "south-east of SS13"
	icon_state = "southeast"

/area/AAsyndicate_station/north
	name = "north of SS13"
	icon_state = "north"

/area/AAsyndicate_station/south
	name = "south of SS13"
	icon_state = "south"

/area/AAsyndicate_station/transit
	name = "\proper bluespace"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

/area/AAshuttle/syndicate_elite/northwest
	icon_state = "northwest"

/area/AAshuttle/syndicate_elite/northeast
	icon_state = "northeast"

/area/AAshuttle/syndicate_elite/southwest
	icon_state = "southwest"

/area/AAshuttle/syndicate_elite/southeast
	icon_state = "southeast"

/area/AAshuttle/syndicate_elite/transit
	name = "\proper bluespace"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

/area/AAskipjack_station
	name = "\improper Skipjack"
	icon_state = "yellow"
	requires_power = 0
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)

/area/AAskipjack_station/southwest_solars
	name = "aft port solars"
	icon_state = "southwest"

/area/AAskipjack_station/northwest_solars
	name = "fore port solars"
	icon_state = "northwest"

/area/AAskipjack_station/northeast_solars
	name = "fore starboard solars"
	icon_state = "northeast"

/area/AAskipjack_station/southeast_solars
	name = "aft starboard solars"
	icon_state = "southeast"

/area/AAskipjack_station/base
	name = "Raider Base"
	icon_state = "yellow"
	base_turf = /turf/simulated/floor/asteroid

/area/AAskipjack_station/start
	name = "\improper Skipjack"
	icon_state = "shuttlered"

/area/AAskipjack_station/transit
	name = "Skipjack Transit"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

// SUBSTATIONS (Subtype of maint, that should let them serve as shielded area during radstorm)

/area/AAmaintenance/substation
	name = "Substation"
	icon_state = "substation"
	sound_env = SMALL_ENCLOSED

/area/AAmaintenance/substation/command // AI and central cluster. This one will be between HoP office and meeting room (probably).
	name = "Command Substation"

/area/AAmaintenance/substation/engineering // Probably will be connected to engineering SMES room, as wires cannot be crossed properly without them sharing powernets.
	name = "Engineering Substation"

/area/AAmaintenance/substation/medical // Medbay
	name = "Medical Substation"

/area/AAmaintenance/substation/research // Research
	name = "Research Substation"

/area/AAmaintenance/substation/civilian_east // Bar, kitchen, dorms, ...
	name = "Civilian East Substation"

/area/AAmaintenance/substation/civilian_west // Cargo, PTS, locker room, probably arrivals, ...)
	name = "Civilian West Substation"

/area/AAmaintenance/substation/security // Security, Brig, Permabrig, etc.
	name = "Security Substation"

/area/AAmaintenance/substation/atmospherics
	name = "Atmospherics Substation"

/area/AAmaintenance/substation/cargo
	name = "Cargo Substation"

/area/AAmaintenance/substation/starport
	name = "Starport Substation"

/area/AAmaintenance/substation/hydro
	name = "Hydroponics Substation"

/area/AAmaintenance/substation/emergency
	name = "Emergency Substation"

// Maintenance

/area/AAmaintenance/disposal
	name = "\improper Trash Disposal"
	icon_state = "disposal"

/area/AAmaintenance/ghetto_medbay
	name = "\improper Ghetto Medbay"
	icon_state = "ghettomedbay"

/area/AAmaintenance/ghetto_minicasino
	name = "\improper Ghetto Mini Casino"
	icon_state = "ghettominicasino"

/area/AAmaintenance/ghetto_rnd
	name = "\improper Ghetto RnD"
	icon_state = "ghettornd"

/area/AAmaintenance/ghetto_janitor
	name = "\improper Ghetto Janitor Room"
	icon_state = "ghettojanitor"

/area/AAmaintenance/ghetto_virology
	name = "\improper Ghetto Virology"
	icon_state = "ghettovirology"

/area/AAmaintenance/ghetto_shop
	name = "\improper Ghetto Shop"
	icon_state = "ghettoshop"

/area/AAmaintenance/ghetto_bar
	name = "\improper Ghetto Bar"
	icon_state = "ghettobar"

/area/AAmaintenance/ghetto_library
	name = "\improper Ghetto Library"
	icon_state = "ghettolibrary"

/area/AAmaintenance/ghetto_toilet
	name = "\improper Underground Toilets"
	icon_state = "ghettotoilets"

/area/AAmaintenance/ghetto_dorm
	name = "\improper Abandoned Dorm"
	icon_state = "ghettodorm"

/area/AAmaintenance/ghetto_main
	name = "\improper Underground Main"
	icon_state = "ghettomain"

/area/AAmaintenance/ghetto_main_south
	name = "\improper Underground Main - South"
	icon_state = "ghettomainsouth"

/area/AAmaintenance/ghetto_main_west
	name = "\improper Underground Main - West"
	icon_state = "ghettomainsouth"

/area/AAmaintenance/ghetto_eva
	name = "\improper Ghetto EVA"
	icon_state = "ghettoeva"

/area/AAmaintenance/ghetto_eva_maint
	name = "\improper Ghetto EVA Maintenance"
	icon_state = "ghettoevamaint"

/area/AAmaintenance/ghetto_casino
	name = "\improper Ghetto Casino"
	icon_state = "ghettocasino"

/area/AAmaintenance/ghetto_syndie
	name = "\improper Ghetto Syndie"
	icon_state = "ghettosyndie"

/area/AAmaintenance/ghetto_dockhall
	name = "\improper Underground Dock Hall"
	icon_state = "ghettodockhall"

/area/AAmaintenance/ghetto_cafe
	name = "\improper Underground Cafe"
	icon_state = "ghettocafe"

/area/AAmaintenance/ghetto_strangeplace
	name = "\improper Underground Bar"
	icon_state = "ghettostrangeplace"

/area/AAmaintenance/ghetto_detective
	name = "\improper Abandoned Detective's Office"
	icon_state = "ghettodetective"

/area/AAmaintenance/underground/central_one
	name = "\improper Underground Central Primary Hallway SE"
	icon_state = "uhall1"

/area/AAmaintenance/underground/central_two
	name = "\improper Underground Central Primary Hallway SW"
	icon_state = "uhall2"

/area/AAmaintenance/underground/central_three
	name = "\improper Underground Central Primary Hallway NW"
	icon_state = "uhall3"

/area/AAmaintenance/underground/central_four
	name = "\improper Underground Central Primary Hallway NE"
	icon_state = "uhall4"

/area/AAmaintenance/underground/central_five
	name = "\improper Underground Central Primary Hallway E"
	icon_state = "uhall5"

/area/AAmaintenance/underground/central_six
	name = "\improper Underground Central Primary Hallway N"
	icon_state = "uhall6"

/area/AAmaintenance/underground/cargo
	name = "\improper Underground Cargo Maintenance"
	icon_state = "ucargo"

/area/AAmaintenance/underground/atmospherics
	name = "\improper Underground Atmospherics Maintenance"
	icon_state = "uatmos"


/area/AAmaintenance/underground/arrivals
	name = "\improper Underground Arrivals Maintenance"
	icon_state = "uarrival"

/area/AAmaintenance/underground/locker_room
	name = "\improper Underground Locker Room Maintenance"
	icon_state = "ulocker"

/area/AAmaintenance/underground/EVA
	name = "\improper Underground EVA Maintenance"
	icon_state = "uEVA"

/area/AAmaintenance/underground/security
	name = "\improper Underground Security Maintenance"
	icon_state = "usecurity"

/area/AAmaintenance/underground/security_west
	name = "\improper Underground Security Maintenance - West"
	icon_state = "usecuritywest"

/area/AAmaintenance/underground/security_port
	name = "\improper Underground Security Port Maintenance"
	icon_state = "usecurityport"

/area/AAmaintenance/underground/security_main
	name = "\improper Underground Security Main Maintenance"
	icon_state = "usecuritymain"

/area/AAmaintenance/underground/security_lobby
	name = "\improper Underground Security Lobby Maintenance"
	icon_state = "usecuritylobby"

/area/AAmaintenance/underground/security_firefighting
	name = "\improper Underground Security Tech Room"
	icon_state = "usecurityfirefighting"

/area/AAmaintenance/underground/security_dorms
	name = "\improper Underground Security Dormitories"
	icon_state = "usecuritybreak"

/area/AAmaintenance/underground/security_breakroom
	name = "\improper Underground Security Break Room"
	icon_state = "usecuritybreak"

/area/AAmaintenance/underground/security_storage
	name = "\improper Underground Security Storage Room"
	icon_state = "usecuritystorage"

/area/AAmaintenance/underground/security_mainhall
	name = "\improper Underground Security Main Hall"
	icon_state = "usecuritylobby"

/area/AAmaintenance/underground/security_hallway
	name = "\improper Underground Security Hallway"
	icon_state = "usecurityhall"

/area/AAmaintenance/underground/security_meeting
	name = "\improper Underground Security Meeting Maintenance"
	icon_state = "usecuritymeeting"

/area/AAmaintenance/underground/engineering
	name = "\improper Underground Engineering Maintenance"
	icon_state = "uengineering"

/area/AAmaintenance/underground/engineering_lower
	name = "\improper Underground Engineering"
	icon_state = "uengineering"

/area/AAmaintenance/underground/research
	name = "\improper Underground Research Maintenance"
	icon_state = "uresearch"

/area/AAmaintenance/underground/robotics_lab
	name = "\improper Underground Robotics Lab Maintenance"
	icon_state = "urobotics"

/area/AAmaintenance/underground/research_port
	name = "\improper Underground Research Port Maintenance"
	icon_state = "uresearchport"

/area/AAmaintenance/underground/research_shuttle
	name = "\improper Underground Research Shuttle Dock Maintenance"
	icon_state = "uresearchshuttle"

/area/AAmaintenance/underground/research_utility_room
	name = "\improper Underground Utility Room"
	icon_state = "uresearchutilityroom"

/area/AAmaintenance/underground/research_starboard
	name = "\improper Underground Research Maintenance - Starboard"
	icon_state = "uresearchstarboard"

/area/AAmaintenance/underground/research_xenobiology
	name = "\improper Underground Research Xenobiology Maintenance"
	icon_state = "uresearchxeno"

/area/AAmaintenance/underground/research_misc
	name = "\improper Underground Research Miscellaneous Maintenance"
	icon_state = "uresearchmisc"

/area/AAmaintenance/underground/civilian_NE
	name = "\improper Underground Civilian NE Maintenance"
	icon_state = "ucivne"

/area/AAmaintenance/underground/medbay
	name = "\improper Underground Medbay Maintenance"
	icon_state = "umedbay"

/area/AAmaintenance/underground/medbay/south
	name = "\improper Underground Medbay Maintenance - South"
	icon_state = "umedbay"

/area/AAmaintenance/underground/dormitories
	name = "\improper Underground Dormitories Maintenance"
	icon_state = "udorm"

/area/AAmaintenance/underground/warehouse
	name = "\improper Underground Warehouse Maintenance"
	icon_state = "uwarehouse"

/area/AAmaintenance/underground/vault
	name = "\improper Underground Vault Maintenance"
	icon_state = "uvault"

/area/AAmaintenance/underground/tool_storage
	name = "\improper Underground Tool Storage Maintenance"
	icon_state = "utoolstorage"

/area/AAmaintenance/underground/janitor
	name = "\improper Underground Custodial Closet Maintenance"
	icon_state = "ujanitor"

/area/AAmaintenance/underground/vaccant_office
	name = "\improper Underground Vaccant Office Maintenance"
	icon_state = "uvaccant"

/area/AAmaintenance/underground/engine
	name = "\improper Underground Engine Maintenance"
	icon_state = "uengine"

/area/AAmaintenance/underground/incinerator
	name = "\improper Underground Incinerator Maintenance"
	icon_state = "uincinerator"

/area/AAmaintenance/underground/port_primary_hallway
	name = "\improper Underground Port Primary Hallway Maintenance"
	icon_state = "uportprim"

/area/AAmaintenance/underground/board_games_club
	name = "\improper Underground Board Games Club"
	icon_state = "uportprim"

/area/AAmaintenance/underground/gateway
	name = "\improper Underground Gateway Maintenance"
	icon_state = "ugateway"

/area/AAmaintenance/underground/fitness
	name = "\improper Underground Fitness Room Maintenance"
	icon_state = "ufitness"

/area/AAmaintenance/underground/bar
	name = "\improper Underground Bar Maintenance"
	icon_state = "ubar"

/area/AAmaintenance/underground/kitchen
	name = "\improper Underground Kitchen Maintenance"
	icon_state = "ukitchen"

/area/AAmaintenance/underground/hydroponics
	name = "\improper Underground Hydroponics Maintenance"
	icon_state = "uhydro"

/area/AAmaintenance/underground/library
	name = "\improper Underground Library Maintenance"
	icon_state = "ulibrary"

/area/AAmaintenance/underground/starboard_primary_hallway
	name = "\improper Starboard Primary Hallway Maintenance"
	icon_state = "ustarboard"

/area/AAmaintenance/underground/cloning_entrance
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/AAmaintenance/underground/cloning_checkpoint
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/AAmaintenance/underground/cloning_storage
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/AAmaintenance/underground/cloning_lobby
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/AAmaintenance/underground/cloning_laboratory
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/AAmaintenance/underground/cloning_surgery
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/AAmaintenance/underground/cloning_morgue
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/AAmaintenance/underground/cloning_cells
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/AAmaintenance/atmos_control
	name = "\improper Atmospherics Maintenance"
	icon_state = "fpmaint"

/area/AAmaintenance/arrivals
	name = "\improper Arrivals Maintenance"
	icon_state = "maint_arrivals"

/area/AAmaintenance/bar
	name = "\improper Bar Maintenance"
	icon_state = "maint_bar"

/area/AAmaintenance/cargo
	name = "\improper Cargo Maintenance"
	icon_state = "maint_cargo"

/area/AAmaintenance/engi_engine
	name = "\improper Engine Maintenance"
	icon_state = "maint_engine"

/area/AAmaintenance/engi_shuttle
	name = "\improper Engineering Shuttle Access"
	icon_state = "maint_e_shuttle"

/area/AAmaintenance/engineering
	name = "\improper Engineering Maintenance"
	icon_state = "maint_engineering"

/area/AAmaintenance/evahallway
	name = "\improper EVA Maintenance"
	icon_state = "maint_eva"

/area/AAmaintenance/dormitory
	name = "\improper Dormitory Maintenance"
	icon_state = "maint_dormitory"

/area/AAmaintenance/library
	name = "\improper Library Maintenance"
	icon_state = "maint_library"

/area/AAmaintenance/locker
	name = "\improper Locker Room Maintenance"
	icon_state = "maint_locker"

/area/AAmaintenance/medbay
	name = "\improper Medbay Maintenance"
	icon_state = "maint_medbay"

/area/AAmaintenance/bridge
	name = "\improper Bridge Maintenance"
	icon_state = "maint_eva"

/area/AAmaintenance/bridge/west
	name = "\improper Bridge Maintenance - West"

/area/AAmaintenance/bridge/east
	name = "\improper Bridge Maintenance - East"

/area/AAmaintenance/research_port
	name = "\improper Research Maintenance - Port"
	icon_state = "maint_research_port"

/area/AAmaintenance/research_shuttle
	name = "\improper Research Shuttle Dock Maintenance"
	icon_state = "maint_research_shuttle"

/area/AAmaintenance/research_starboard
	name = "\improper Research Maintenance - Starboard"
	icon_state = "maint_research_starboard"

/area/AAmaintenance/security_port
	name = "\improper Security Maintenance - Port"
	icon_state = "maint_security_port"

/area/AAmaintenance/security_starboard
	name = "\improper Security Maintenance - Starboard"
	icon_state = "maint_security_starboard"

/area/AAmaintenance/exterior
	name = "\improper Exterior Reinforcements"
	icon_state = "maint_security_starboard"
	area_flags = AREA_FLAG_EXTERNAL & AREA_FLAG_NO_STATION
	has_gravity = FALSE
	turf_initializer = /decl/turf_initializer/maintenance/space

/area/AAmaintenance/research_atmos
	name = "\improper Research Atmospherics Maintenance"
	icon_state = "maint_engineering"

/area/AAmaintenance/medbay_north
	name = "\improper North Medbay Maintenance"
	icon_state = "maint_medbay"

/area/AAmaintenance/hydro
	name = "\improper Hydroponics Maintenance"
	icon_state = "maint_medbay"

/area/AAmaintenance/chapel
	name = "\improper Chapel Maintenance"
	icon_state = "maint_security_port"

/area/AAmaintenance/chapel/north
	name = "\improper Chapel Maintenance - North"

/area/AAmaintenance/chapel/south
	name = "\improper Chapel Maintenance - South"

/area/AAmaintenance/abandoned_casino
	name = "\improper Abandoned Casino"
	icon_state = "ghettocasino"


/area/AAmaintenance/getto_rnd
	name = "\improper RnD Maintenance"
	icon_state = "maint_cargo"

/area/AAmaintenance/disposal/underground
	name = "Underground Waste Disposal"
	icon_state = "disposal"

// Dank Maintenance
/area/AAmaintenance/sub
	turf_initializer = /decl/turf_initializer/maintenance/heavy

/area/AAmaintenance/sub/relay_station
	name = "\improper Sublevel Maintenance - Relay Station"
	icon_state = "blue2"
	turf_initializer = null

/area/AAmaintenance/sub/fore
	name = "\improper Sublevel Maintenance - Fore"
	icon_state = "sub_maint_fore"

/area/AAmaintenance/sub/aft
	name = "\improper Sublevel Maintenance - Aft"
	icon_state = "sub_maint_aft"

/area/AAmaintenance/sub/port
	name = "\improper Sublevel Maintenance - Port"
	icon_state = "sub_maint_port"

/area/AAmaintenance/sub/starboard
	name = "\improper Sublevel Maintenance - Starboard"
	icon_state = "sub_maint_starboard"

/area/AAmaintenance/sub/central
	name = "\improper Sublevel Maintenance - Central"
	icon_state = "sub_maint_central"

/area/AAmaintenance/sub/command
	name = "\improper Sublevel Maintenance - Command"
	icon_state = "sub_maint_command"
	turf_initializer = null

// Hallway

/area/AAhallway/primary/
	sound_env = LARGE_ENCLOSED

/area/AAhallway/primary/fore
	name = "\improper Fore Primary Hallway"
	icon_state = "hallF"

/area/AAhallway/primary/starboard
	name = "\improper Starboard Primary Hallway"
	icon_state = "hallS"

/area/AAhallway/primary/aft
	name = "\improper Aft Primary Hallway"
	icon_state = "hallA"

/area/AAhallway/primary/port
	name = "\improper Port Primary Hallway"
	icon_state = "hallP"

/area/AAhallway/primary/seclobby
	name = "\improper Security Lobby"
	icon_state = "security"

/area/AAhallway/primary/englobby
	name = "\improper Engineering Foyer"
	icon_state = "engineering_foyer"

/area/AAhallway/primary/central_one
	name = "\improper Central Primary Hallway"
	icon_state = "hallC1"

/area/AAhallway/primary/central_two
	name = "\improper Central Primary Hallway"
	icon_state = "hallC2"

/area/AAhallway/primary/central_three
	name = "\improper Central Primary Hallway"
	icon_state = "hallC3"

/area/AAhallway/primary/central_fore
	name = "\improper Central Primary Hallway"
	icon_state = "hallC3"

/area/AAhallway/primary/central_fife
	name = "\improper Central Primary Hallway"
	icon_state = "hallC3"

/area/AAhallway/primary/central_six
	name = "\improper Central Primary Hallway"
	icon_state = "hallC3"

/area/AAhallway/primary/central_seven
	name = "\improper Central Primary Hallway"
	icon_state = "hallC3"

/area/AAhallway/primary/frontier
	name = "\improper Central Hallway"
	icon_state = "hallC1"

/area/AAhallway/primary/frontier/ring_north
	name = "\improper Ring Hallway - North"
	icon_state = "hallF"

/area/AAhallway/primary/frontier/ring_south
	name = "\improper Ring Hallway - South"
	icon_state = "hallP"

/area/AAhallway/primary/frontier/central_mideast
	name = "\improper Central Hallway - Mideast"
	icon_state = "hallC2"

/area/AAhallway/primary/frontier/central_east
	name = "\improper Central Hallway - East"
	icon_state = "hallC2"

/area/AAhallway/primary/frontier/central_midwest
	name = "\improper Central Hallway - Midwest"
	icon_state = "hallC3"

/area/AAhallway/primary/frontier/central_west
	name = "\improper Central Hallway - West"
	icon_state = "hallC3"

/area/AAhallway/primary/frontier/brighall
	name = "\improper Brig Hallway"
	icon_state = "security"

/area/AAhallway/primary/frontier/dormhall
	name = "\improper Dormitory Hallway"
	icon_state = "Sleep"




/area/AAhallway/secondary/exit
	name = "\improper Escape Shuttle Hallway"
	icon_state = "escape"

/area/AAhallway/secondary/entry/pods
	name = "\improper Arrival Shuttle Hallway - Escape Pods"
	icon_state = "entry_pods"

/area/AAhallway/secondary/entry/fore
	name = "\improper Arrival Shuttle Hallway - Fore"
	icon_state = "entry_1"

/area/AAhallway/secondary/entry/port
	name = "\improper Arrival Shuttle Hallway - Port"
	icon_state = "entry_2"

/area/AAhallway/secondary/entry/starboard
	name = "\improper Arrival Shuttle Hallway - Starboard"
	icon_state = "entry_3"

/area/AAhallway/secondary/entry/aft
	name = "\improper Arrival Shuttle Hallway - Aft"
	icon_state = "entry_4"

// Command

/area/AAcrew_quarters/captain
	name = "\improper Command - Captain's Office"
	icon_state = "captain"
	sound_env = MEDIUM_SOFTFLOOR

// Crew


/area/AAcrew_quarters
	name = "\improper Dormitories"
	icon_state = "Sleep"

/area/AAcrew_quarters/locker
	name = "\improper Locker Room"
	icon_state = "locker"

/area/AAcrew_quarters/toilet
	name = "\improper Dormitory Toilets"
	icon_state = "toilet"
	sound_env = SMALL_ENCLOSED

/area/AAcrew_quarters/toilet/bar
	name = "\improper Bar Toilet"

/area/AAcrew_quarters/toilet/west
	name = "\improper West Hallway Bathroom"

/area/AAcrew_quarters/sleep
	name = "\improper Dormitories"
	icon_state = "Sleep"

/area/AAcrew_quarters/sleep/cryo
	name = "\improper Cryogenic Storage"
	icon_state = "Cryopods"

/area/AAcrew_quarters/sleep2
	name = "\improper Dormitories Hallway North"
	icon_state = "Sleep"

/area/AAcrew_quarters/sleep3
	name = "\improper Dormitories Hallway West"
	icon_state = "Sleep"

/area/AAcrew_quarters/sleep/lobby
	name = "\improper Dormitory Lobby"
	icon_state = "Sleep"

/area/AAcrew_quarters/sleep/cave
	name = "\improper Dormitory Cave"
	icon_state = "explored"

/area/AAcrew_quarters/underdorm
	name = "\improper Underground Dormitories"
	icon_state = "underdorm"

/area/AAcrew_quarters/underdorm/boxing
	name = "\improper Boxing Club"
	icon_state = "fitness"

/area/AAcrew_quarters/underdorm/maint
	name = "\improper Underground Dormitories Maintenance"
	icon_state = "underdormmaint"

/area/AAcrew_quarters/underdorm/theater
	name = "\improper Theater"
	icon_state = "Theatre"

/area/AAcrew_quarters/underdorm/theater/clown
	name = "\improper Clown's Bedroom"
	icon_state = "Theatre"

/area/AAcrew_quarters/underdorm/theater/mime
	name = "\improper Mime's Bedroom"
	icon_state = "Theatre"

/area/AAcrew_quarters/underdorm/theater/actor
	name = "\improper Actors' Break Room"
	icon_state = "Theatre"

/area/AAcrew_quarters/underdorm/sauna
	name = "\improper Sauna"
	icon_state = "toilet"


/area/AAcrew_quarters/sleep/cabin1
	name = "\improper Private Bedroom One"
	icon_state = "PrivDormOne"
	sound_env = SMALL_SOFTFLOOR

/area/AAcrew_quarters/sleep/cabin2
	name = "\improper Private Bedroomn Two"
	icon_state = "PrivDormTwo"
	sound_env = SMALL_SOFTFLOOR

/area/AAcrew_quarters/sleep/cabin3
	name = "\improper Private Bedroom Three"
	icon_state = "PrivDormThree"
	sound_env = SMALL_SOFTFLOOR

/area/AAcrew_quarters/sleep/cabin4
	name = "\improper Private Bedroom Four"
	icon_state = "PrivDormFour"
	sound_env = SMALL_SOFTFLOOR

/area/AAcrew_quarters/sleep/cabin5
	name = "\improper Private Bedroom Five"
	icon_state = "PrivDormFive"
	sound_env = SMALL_SOFTFLOOR

/area/AAcrew_quarters/sleep/cabin6
	name = "\improper Private Bedroom Six"
	icon_state = "PrivDormSix"
	sound_env = SMALL_SOFTFLOOR

/area/AAcrew_quarters/sleep/underg_cabin1
	name = "\improper Underground Bedroom One"
	icon_state = "UndergroundDormOne"
	sound_env = SMALL_SOFTFLOOR

/area/AAcrew_quarters/sleep/underg_cabin2
	name = "\improper Underground Bedroom Two"
	icon_state = "UndergroundDormTwo"
	sound_env = SMALL_SOFTFLOOR

/area/AAcrew_quarters/sleep/underg_cabin3
	name = "\improper Underground Bedroom Three"
	icon_state = "UndergroundDormThree"
	sound_env = SMALL_SOFTFLOOR

/area/AAcrew_quarters/sleep/engi_wash
	name = "\improper Engineering Washroom"
	icon_state = "toilet"
	sound_env = SMALL_ENCLOSED

/area/AAcrew_quarters/sleep/bedrooms
	name = "\improper Dormitory Bedroom One"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/AAcrew_quarters/sleep/dorms
	name = "\improper Dormitory Shared Bedroom"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/AAcrew_quarters/sleep/quartes1
	name = "\improper Dormitory Quartes One"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/AAcrew_quarters/sleep/quartes2
	name = "\improper Dormitory Quartes Two"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/AAcrew_quarters/sleep/quartes3
	name = "\improper Dormitory Quartes Three"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/AAcrew_quarters/sleep/quartes4
	name = "\improper Dormitory Quartes Four"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/AAcrew_quarters/locker/locker_toilet
	name = "\improper Locker Toilets"
	icon_state = "toilet"
	sound_env = SMALL_ENCLOSED

/area/AAcrew_quarters/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"

/area/AAcrew_quarters/fitness/arcade
	name = "\improper Arcade"
	icon_state = "arcade"

/area/AAcrew_quarters/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/AAcrew_quarters/bar
	name = "\improper Bar"
	icon_state = "bar"
	sound_env = LARGE_SOFTFLOOR

/area/AAcrew_quarters/barbackroom
	name = "\improper Bar Backroom"
	icon_state = "barBR"

/area/AAcrew_quarters/ubarbackroom // new room for bartender
	name = "\improper Underground Bar Backroom"
	icon_state = "ubarBR"

/area/AAcrew_quarters/mess
	name = "\improper Mess Hall"
	icon_state = "cafeteria"
	sound_env = LARGE_SOFTFLOOR

/area/AAlibrary
 	name = "\improper Library"
 	icon_state = "library"
 	sound_env = LARGE_SOFTFLOOR

/area/AAjanitor
	name = "\improper Custodial Closet"
	icon_state = "janitor"

/area/AAchapel/main
	name = "\improper Chapel"
	icon_state = "chapel"
	ambience_off = list(SFX_AMBIENT_OFF_GLOBAL)
	ambience_powered = list(SFX_AMBIENT_CHAPEL)
	sound_env = LARGE_ENCLOSED

/area/AAchapel/office
	name = "\improper Chapel Office"
	icon_state = "chapeloffice"

/area/AAchapel/crematorium
	name = "\improper Crematorium"
	icon_state = "chapelcrematorium"

/area/AAiaoffice
	name = "\improper Internal Affairs"
	icon_state = "law"

/area/AAlawoffice
	name = "\improper Law Office"
	icon_state = "law"


// Engineering

/area/AAengineering/
	name = "\improper Engineering"
	icon_state = "engineering"
	ambience_powered = list(SFX_AMBIENT_ENGINEERING)

/area/AAengineering/grav_generator
	name = "\improper Gravitational Generator Room"
	icon_state = "engine"
	sound_env = LARGE_ENCLOSED

/area/AAengineering/lower
	name = "\improper Engineering Lower Deck"
	icon_state = "lower_engi"

/area/AAengineering/lower/rust
	name = "\improper R-UST Engine"
	icon_state = "rust"

/area/AAengineering/lower/rust/core
	name = "\improper R-UST Core"
	icon_state = "rust"

/area/AAengineering/lower/rust/control
	name = "\improper R-UST Control Room"
	icon_state = "rust"

/area/AAengineering/engine_airlock
	name = "\improper Engine Room Airlock"
	icon_state = "engine"

/area/AAengineering/singularity_engine
	name = "\improper Singularity Engine"
	icon_state = "engine"

/area/AAengineering/singularity_control
	name = "\improper Singularity Engine Control Room"
	icon_state = "engine_monitoring"

/area/AAengineering/singularity_storage
	name = "\improper Singularity Engine Storage"
	icon_state = "engineering_storage"

/area/AAengineering/engine_waste
	name = "\improper Engine Waste Handling"
	icon_state = "engine_waste"

/area/AAengineering/break_room
	name = "\improper Engineering Break Room"
	icon_state = "engineering_break"
	sound_env = MEDIUM_SOFTFLOOR

/area/AAengineering/workshop
	name = "\improper Engineering Workshop"
	icon_state = "engineering_workshop"

/area/AAengineering/sublevel_access
	name = "\improper Engineering Sublevel Access"

/area/AAengineering/atmos
	name = "\improper Atmospherics"
	icon_state = "atmos"
	ambience_powered = list(SFX_AMBIENT_ENGINEERING, SFX_AMBIENT_ATMOSPHERICS)

/area/AAengineering/atmos/storage
	name = "\improper Atmospherics Storage"
	icon_state = "atmos_storage"

/area/AAengineering/toilet
	name = "\improper Atmospherics"
	icon_state = "engineering_break"

/area/AAengineering/eva_airlock
	name = "\improper Engineering Airlock"
	icon_state = "engineering_break"

/area/AAengineering/atmos_monitoring
	name = "\improper Atmospherics Monitoring Room"
	icon_state = "engine_monitoring"

/area/AAengineering/storage
	name = "\improper Engineering Storage"
	icon_state = "engineering_storage"

/area/AAengineering/engine_eva
	name = "\improper Engine EVA"
	icon_state = "engine_eva"

/area/AAengineering/engine_monitoring
	name = "\improper Engine Monitoring Room"
	icon_state = "engine_monitoring"

/area/AAengineering/locker_room
	name = "\improper Engineering Locker Room"
	icon_state = "engineering_locker"

/area/AAengineering/engineering_monitoring
	name = "\improper Engineering Monitoring Room"
	icon_state = "engine_monitoring"

/area/AAengineering/drone_fabrication
	name = "\improper Engineering Drone Fabrication"
	icon_state = "drone_fab"
	sound_env = SMALL_ENCLOSED

/area/AAengineering/engine_smes
	name = "\improper Engineering SMES"
	icon_state = "engine_smes"
	sound_env = SMALL_ENCLOSED

/area/AAengineering/engine_room
	name = "\improper Engine Room"
	icon_state = "engine"
	sound_env = LARGE_ENCLOSED

// Medbay

/area/AAmedical/virology
	name = "\improper Virology"
	icon_state = "virology"

/area/AAmedical/genetics
	name = "\improper Genetics Lab"
	icon_state = "genetics"

/area/AAmedical/genetics_cloning
	name = "\improper Cloning Lab"
	icon_state = "cloning"

/area/AAmedical/biostorage/underground
	name = "\improper Undergound Medbay Storage"
	icon_state = "medbay4"

/area/AAmedical/sleeper
	name = "\improper Emergency Treatment Room"
	icon_state = "exam_room"

/area/AAmedical/sleeper/underground
	name = "\improper Underground Emergency Treatment Room"
	icon_state = "exam_room"

/area/AAmedical/chemistry
	name = "\improper Chemistry"
	icon_state = "chem"

/area/AAmedical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"

/area/AAmedical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"
	ambience_powered = list(SFX_AMBIENT_MORGUE, SFX_AMBIENT_SCIENCE)

/area/AAmedical/surgery
	name = "\improper Operating Theatre"
	icon_state = "surgery"

// Solars

/area/AAsolar
	ambient_music_tags = list(MUSIC_TAG_SPACE)

/area/AAsolar/starboard
	name = "\improper Starboard Auxiliary Solar Array"
	icon_state = "panelsS"

/area/AAsolar/auxport
	name = "\improper Fore Port Solar Array"
	icon_state = "panelsA"

/area/AAsolar/fore
	name = "\improper Fore Solar Array"
	icon_state = "yellow"

/area/AAsolar/port
	name = "\improper Port Auxiliary Solar Array"
	icon_state = "panelsP"

/area/AAmaintenance/foresolar
	name = "\improper Solar Maintenance - Fore"
	icon_state = "SolarcontrolA"
	sound_env = SMALL_ENCLOSED

/area/AAmaintenance/portsolar
	name = "\improper Solar Maintenance - Aft Port"
	icon_state = "SolarcontrolP"
	sound_env = SMALL_ENCLOSED

/area/AAmaintenance/starboardsolar
	name = "\improper Solar Maintenance - Aft Starboard"
	icon_state = "SolarcontrolS"
	sound_env = SMALL_ENCLOSED

// Teleporter

/area/AAteleporter
	name = "\improper Teleporter"
	icon_state = "teleporter"
	ambient_music_tags = list(MUSIC_TAG_SPACE)

/area/AAgateway
	name = "\improper Gateway"
	icon_state = "teleporter"
	ambient_music_tags = list(MUSIC_TAG_SPACE)

// MedBay

/area/AAmedical/medbay
	name = "\improper Medbay Hallway - Port"
	icon_state = "medbay"

// Medbay is a large area, these additional areas help level out APC load.
/area/AAmedical/medbay2
	name = "\improper Medbay Hallway - Starboard"
	icon_state = "medbay2"

/area/AAmedical/medbay3
	name = "\improper Medbay Hallway - Fore"
	icon_state = "medbay3"

/area/AAmedical/medbay3/underground
	name = "\improper Underground Medbay Hallway - Fore"
	icon_state = "medbay3"

/area/AAmedical/medbay4
	name = "\improper Medbay Hallway - Aft"
	icon_state = "medbay4"

/area/AAmedical/medbay4/underground
	name = "\improper Underground Medbay Hallway - Aft"
	icon_state = "medbay4"

/area/AAmedical/reception
	name = "\improper Medbay Reception"
	icon_state = "medbay"

/area/AAmedical/psych
	name = "\improper Psych Room"
	icon_state = "medbay3"

/area/AAcrew_quarters/medbreak
	name = "\improper Break Room"
	icon_state = "medbay3"

/area/AAmedical/ward
	name = "\improper Recovery Ward"
	icon_state = "patients"

/area/AAmedical/patient_a
	name = "\improper Isolation A"
	icon_state = "patients"

/area/AAmedical/patient_b
	name = "\improper Isolation B"
	icon_state = "patients"

/area/AAmedical/patient_c
	name = "\improper Isolation C"
	icon_state = "patients"

/area/AAmedical/patient_d
	name = "\improper Isolation D"
	icon_state = "patients"

/area/AAmedical/patient_wing
	name = "\improper Underground Patient Ward"
	icon_state = "patients"

/area/AAmedical/patient_wing/garden
	name = "\improper Medbay Garden"
	icon_state = "patients"

/area/AAmedical/patient_wing/washroom
	name = "\improper Patient Wing Washroom"

/area/AAmedical/surgery2
	name = "\improper Operating Theatre 2"
	icon_state = "surgery"

/area/AAmedical/surgery_storage
	name = "\improper Surgery Storage"
	icon_state = "surgery"

/area/AAmedical/surgeryobs
	name = "\improper Operation Observation Room"
	icon_state = "surgery"

/area/AAmedical/surgeryprep
	name = "\improper Pre-Op Prep Room"
	icon_state = "surgery"

/area/AAmedical/cryo
	name = "\improper Cryogenics"
	icon_state = "cryo"

/area/AAmedical/med_toilet
	name = "\improper Medbay Toilets"
	icon_state = "medbay"

/area/AAmedical/med_mech
	name = "\improper Medbay Mech Room"
	icon_state = "medbay3"

/area/AAmedical/storage1
	name = "\improper Primary Storage"
	icon_state = "medbay4"

/area/AAmedical/storage2
	name = "\improper Medbay Storage"
	icon_state = "medbay3"

/area/AAmedical/resleever
	name = "\improper Neural Lace Resleever"
	icon_state = "cloning"

// Security

/area/AAsecurity/main
	name = "\improper Security Office"
	icon_state = "security"

/area/AAsecurity/briefingroom
	name = "\improper Security - Briefing Room"
	icon_state = "briefroom"

/area/AAsecurity/storage
	name = "\improper Security Storage"
	icon_state = "brigstorage"

/area/AAsecurity/execution
	name = "\improper Security - Execution Room"
	icon_state = "execution"

/area/AAsecurity/evidence
	name = "\improper Security - Evidence Storage"
	icon_state = "evidence"

/area/AAsecurity/brigmorgue
	name = "\improper Security - Morgue"
	icon_state = "brigmorgue"

/area/AAsecurity/brigswstorage
	name = "\improper Security - S-W Storage"
	icon_state = "brigswstorage"

/area/AAsecurity/meeting
	name = "\improper Security Meeting Room"
	icon_state = "security"

/area/AAsecurity/lobby
	name = "\improper Security Lobby"
	icon_state = "security"

/area/AAsecurity/brig/processing
	name = "\improper Security - Processing Room 1"
	icon_state = "proc1"

/area/AAsecurity/brig/processing2
	name = "\improper Security - Processing Room 2"
	icon_state = "proc2"

/area/AAsecurity/brig/interrogation
	name = "\improper Security - Interrogation"
	icon_state = "interrogation"

/area/AAsecurity/brig/solitaryA
	name = "\improper Security - Solitary 1"
	icon_state = "sec_prison"

/area/AAsecurity/brig/solitaryB
	name = "\improper Security - Solitary 2"
	icon_state = "sec_prison"

/area/AAsecurity/brig/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.icon_state = temp_closet.icon_closed
	for(var/obj/machinery/door_timer/temp_timer in src)
		temp_timer.releasetime = 1
	..()

/area/AAsecurity/prison/restroom
	name = "\improper Security - Prison Wing Restroom"
	icon_state = "sec_prison"

/area/AAsecurity/prison/dorm
	name = "\improper Security - Prison Wing Dormitory"
	icon_state = "sec_prison"

/area/AAsecurity/prison/monitoring
	name = "\improper Security - Prison Wing Monitoring"

/area/AAsecurity/prison/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.icon_state = temp_closet.icon_closed
	for(var/obj/machinery/door_timer/temp_timer in src)
		temp_timer.releasetime = 1
	..()

/area/AAsecurity/warden
	name = "\improper Security - Warden's Office"
	icon_state = "Warden"

/area/AAsecurity/tactical
	name = "\improper Security - Tactical Equipment"
	icon_state = "Tactical"

/area/AAsecurity/vacantoffice
	name = "\improper Vacant Office"
	icon_state = "security"

/area/AAsecurity/nuke_storage
	name = "\improper Vault"
	icon_state = "nuke_storage"

/area/AAsecurity/checkpoint2
	name = "\improper Command Security - Checkpoint"
	icon_state = "checkpoint1"

/area/AAquartermaster
	name = "\improper Quartermasters"
	icon_state = "quart"

/area/AAquartermaster/breakroom
	name = "\improper Cargo Break Room"
	icon_state = "cargobreak"

/area/AAquartermaster/storage
	name = "\improper Warehouse"
	icon_state = "quartstorage"
	sound_env = LARGE_ENCLOSED

/area/AAquartermaster/storage/under
	name = "\improper Underground Cargo Warehouse"
	icon_state = "cargounder"

/area/AAquartermaster/storage/under/secure
	name = "\improper Underground Cargo Storage"
	icon_state = "cargounderstorage"

/area/AAquartermaster/qm
	name = "\improper Cargo - Quartermaster's Office"
	icon_state = "quart"

/area/AAquartermaster/miningdock
	name = "\improper Cargo Mining Dock"
	icon_state = "mining"

/area/AAquartermaster/office
	name = "\improper Supply Office"
	icon_state = "quartoffice"

/area/AAhydroponics
	name = "\improper Hydroponics"
	icon_state = "hydro"

/area/AAhydroponics/garden
	name = "\improper Garden"
	icon_state = "garden"

/area/AAhydroponics/lower
	name = "\improper Lower Hydroponics"
	icon_state = "garden"

/area/AAhydroponics/biodome
	name = "\improper Central Biodome"
	icon_state = "garden"

// Research

/area/AArnd/xenobiology
	name = "\improper Xenobiology Lab"
	icon_state = "xeno_lab"

/area/AArnd/xenobiology/dorm
	name = "\improper Xenobiology Lab Dormitories"
	icon_state = "xeno_lab_dorm"


/area/AArnd/xenobiology/xenoflora
	name = "\improper Xenoflora Lab"
	icon_state = "xeno_f_lab"

/area/AArnd/xenobiology/xenoflora_storage
	name = "\improper Xenoflora Storage"
	icon_state = "xeno_f_store"

/area/AArnd/docking
	name = "\improper Research Dock"
	icon_state = "research_dock"

/area/AAassembly/robotics
	name = "\improper Robotics Lab"
	icon_state = "robotics"

/area/AAassembly/chargebay
	name = "\improper Mech Bay"
	icon_state = "mechbay"

/area/AArnd/lab
	name = "\improper Research Lab"
	icon_state = "toxlab"

/area/AArnd/misc_lab
	name = "\improper Miscellaneous Research"
	icon_state = "toxmisc"

/area/AArnd/mixing
	name = "\improper Toxins Mixing Room"
	icon_state = "toxmix"

/area/AArnd/storage
	name = "\improper Toxins Storage"
	icon_state = "toxstorage"

/area/AArnd/test_area
	name = "\improper Toxins Test Area"
	icon_state = "toxtest"

/area/AAserver
	name = "\improper Research Server Room"
	icon_state = "server"
	ambient_music_tags = list(MUSIC_TAG_SPACE)

/area/AArnd/research_under
	name = "\improper Underground Research Wing"
	icon_state = "uresearch"

/area/AArnd/research_under/breakroom
	name = "\improper Underground Research Wing - Break Room"
	icon_state = "uresearchbreak"

/area/AArnd/restroom
	name = "\improper Research Restroom"
	icon_state = "research"

/area/AArnd/research
	name = "\improper Research and Development"
	icon_state = "research"

// Storage

/area/AAstorage/art
	name = "Art Supply Storage"
	icon_state = "storage"

/area/AAstorage/emergency
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"

/area/AAstorage/emergency2
	name = "Port Emergency Storage"
	icon_state = "emergencystorage"

/area/AAstorage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/AAstorage/tools
	name = "Auxiliary Tool Storage"
	icon_state = "auxstorage"

/area/AAstorage/tech
	name = "Technical Storage"
	icon_state = "storage"

// HALF-BUILT STATION (REPLACES DERELICT IN BAYCODE, ABOVE IS LEFT FOR DOWNSTREAM)

/area/AAshuttle/constructionsite/site
	name = "\improper Construction Site Shuttle"
	base_turf = /turf/simulated/floor/asteroid

// AI

/area/AAturret_protected
	ambience_powered = list(SFX_AMBIENT_AI, SFX_AMBIENT_SCIENCE)

/area/AAturret_protected/ai
	name = "\improper AI Chamber"
	icon_state = "ai_chamber"
	ambience_powered = list(SFX_AMBIENT_AI)

/area/AAturret_protected/ai_server_room
	name = "Messaging Server Room"
	icon_state = "ai_server"
	sound_env = SMALL_ENCLOSED

/area/AAturret_protected/ai_cyborg_station
	name = "\improper Cyborg Station"
	icon_state = "ai_cyborg"
	sound_env = SMALL_ENCLOSED
	ambience_powered = list(SFX_AMBIENT_AI)

/area/AAturret_protected/ai_upload
	name = "\improper AI Upload Chamber"
	icon_state = "ai_upload"
	ambience_powered = list(SFX_AMBIENT_AI)

/area/AAturret_protected/ai_upload_foyer
	name = "\improper  AI Upload Access"
	icon_state = "ai_foyer"
	ambience_powered = list(SFX_AMBIENT_AI)
	sound_env = SMALL_ENCLOSED

/area/AAturret_protected/tcomsat/port
	name = "\improper Telecoms Satellite - Port"

/area/AAturret_protected/tcomsat/starboard
	name = "\improper Telecoms Satellite - Starboard"

/area/AAai_monitored/storage/eva
	name = "\improper EVA Storage"
	icon_state = "eva"

// Misc

/area/AAalien
	name = "\improper Alien base"
	icon_state = "yellow"
	requires_power = 0
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)

// Telecommunications Satellite

/area/AAtcommsat
	ambient_music_tags = list(MUSIC_TAG_SPACE)
	ambience_powered = list(SFX_AMBIENT_AI, SFX_AMBIENT_COMMS)

/area/AAtcommsat/entrance
	name = "\improper Telecoms Teleporter"
	icon_state = "tcomsatentrance"

/area/AAturret_protected/tcomsat
	name = "\improper Telecoms Satellite"
	icon_state = "tcomsatlob"

/area/AAturret_protected/tcomfoyer
	name = "\improper Telecoms Foyer"
	icon_state = "tcomsatentrance"

/area/AAtcommsat/powercontrol
	name = "\improper Telecommunications Power Control"
	icon_state = "tcomsatwest"

/area/AAtcommsat/chamber
	name = "\improper Telecoms Central Compartment"
	icon_state = "tcomsatcham"

/area/AAtcommsat/computer
	name = "\improper Telecoms Control Room"
	icon_state = "tcomsatcomp"

/*******
* Moon *
*******/

// Mining main outpost

/area/AAoutpost
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)

/area/AAoutpost/mining_main
	icon_state = "outpost_mine_main"

/area/AAoutpost/mining_main/east_hall
	name = "Mining Outpost East Hallway"

/area/AAoutpost/mining_main/eva
	name = "Mining Outpost EVA storage"

/area/AAoutpost/mining_main/dorms
	name = "Mining Outpost Dormitory"

/area/AAoutpost/mining_main/medbay
	name = "Mining Outpost Medical"

/area/AAoutpost/mining_main/refinery
	name = "Mining Outpost Refinery"

/area/AAoutpost/mining_main/west_hall
	name = "Mining Outpost West Hallway"

/area/AAoutpost/mining_main/mechbay
	name = "Mining Outpost Mech Bay"

// Mining outpost
/area/AAoutpost/mining_main/maintenance
	name = "Mining Outpost Maintenance"

// Main Outpost
/area/AAoutpost/main_outpost
	icon_state = "green"
	ambience_off = list(SFX_AMBIENT_OFF_GLOBAL, SFX_AMBIENT_OFF_MAINTENANCE)
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE, SFX_AMBIENT_OUTPOST)

/area/AAoutpost/main_outpost/shallway
	name = "Outpost Southern Hallway"

/area/AAoutpost/main_outpost/challway
	name = "Outpost Central Hallway"

/area/AAoutpost/main_outpost/nhallway
	name = "Outpost Northern Hallway"

/area/AAoutpost/main_outpost/dock
	name = "Outpost Dock"
	icon_state = "bluenew"

/area/AAoutpost/main_outpost/dock/security
	name = "Outpost Security Dock"
	icon_state = "bluenew"

/area/AAoutpost/security/shallway
	name = "Outpost Security Hallway"
	icon_state = "green"

/area/AAoutpost/security/mining_main
	name = "Mining Outpost Prisoner Refinery"
	icon_state = "outpost_mine_main"

/area/AAoutpost/security/dorms
	name = "Outpost Prison Dorm"
	icon_state = "blue2"

/area/AAoutpost/security/prison
	name = "Outpost Prison"
	icon_state = "sec_prison"

/area/AAoutpost/security/post
	name = "Outpost Security Post"
	icon_state = "brig"

/area/AAoutpost/security/eva
	name = "Outpost Security EVA"
	icon_state = "brig"

/area/AAmine/explored/prison
	name = "Mine Prison"
	icon_state = "explored"

/area/AAoutpost/main_outpost/infirmary
	name = "Outpost Infirmary"
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_SCIENCE, SFX_AMBIENT_OUTPOST)

/area/AAoutpost/main_outpost/canteen
	name = "Outpost Canteen"
	icon_state = "kitchen"

/area/AAoutpost/main_outpost/bar
	name = "Outpost Bar"
	icon_state = "bar"

/area/AAoutpost/main_outpost/dorms
	name = "Outpost Living Quarters"
	icon_state = "blue2"

/area/AAoutpost/main_outpost/dorms/substation
	name = "Outpost Living Quarters Substation"

/area/AAoutpost/main_outpost/dorms/proom1
	name = "Outpost Private Room One"

/area/AAoutpost/main_outpost/dorms/proom2
	name = "Outpost Private Room Two"

/area/AAoutpost/main_outpost/dorms/proom3
	name = "Outpost Private Room Three"

/area/AAoutpost/main_outpost/dorms/proom4
	name = "Outpost Private Room Four"

// Small outposts
/area/AAoutpost/mining_north
	name = "North Mining Outpost"
	icon_state = "outpost_mine_north"
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE, SFX_AMBIENT_OUTPOST)

/area/AAoutpost/mining_west
	name = "West Mining Outpost"
	icon_state = "outpost_mine_west"
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE, SFX_AMBIENT_OUTPOST)

/area/AAoutpost/abandoned
	name = "Abandoned Outpost"
	icon_state = "dark"

/area/AAoutpost/abandonedpost
	name = "Abandoned Post"
	icon_state = "dark"

/area/AAoutpost/prydwen
	name = "NSC Prydwen"
	icon_state = "green"

// Engineering outpost

/area/AAoutpost/engineering
	icon_state = "outpost_engine"
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE, SFX_AMBIENT_ENGINEERING)

/area/AAoutpost/engineering/atmospherics
	name = "Engineering Outpost Atmospherics"

/area/AAoutpost/engineering/hallway
	name = "Engineering Outpost Hallway"

/area/AAoutpost/engineering/power
	name = "Engineering Outpost Power Distribution"

/area/AAoutpost/engineering/telecomms
	name = "Engineering Outpost Telecommunications"

/area/AAoutpost/engineering/storage
	name = "Engineering Outpost Storage"

/area/AAoutpost/engineering/meeting
	name = "Engineering Outpost Meeting Room"

// Research Outpost
/area/AAoutpost/research
	icon_state = "outpost_research"

/area/AAoutpost/research/hallway
	name = "Research Outpost Hallway"

/area/AAoutpost/research/dock
	name = "Research Outpost Shuttle Dock"

/area/AAoutpost/research/eva
	name = "Research Outpost EVA"

/area/AAoutpost/research/analysis
	name = "Research Outpost Sample Analysis"

/area/AAoutpost/research/chemistry
	name = "Research Outpost Chemistry"

/area/AAoutpost/research/medical
	name = "Research Outpost Medical"

/area/AAoutpost/research/power
	name = "Research Outpost Maintenance"

/area/AAoutpost/research/isolation_a
	name = "Research Outpost Isolation A"

/area/AAoutpost/research/isolation_b
	name = "Research Outpost Isolation B"

/area/AAoutpost/research/isolation_c
	name = "Research Outpost Isolation C"

/area/AAoutpost/research/isolation_monitoring
	name = "Research Outpost Isolation Monitoring"

/area/AAoutpost/research/lab
	name = "Research Outpost Laboratory"

/area/AAoutpost/research/emergency_storage
	name = "Research Outpost Emergency Storage"

/area/AAoutpost/research/anomaly_storage
	name = "Research Outpost Anomalous Storage"

/area/AAoutpost/research/anomaly_analysis
	name = "Research Outpost Anomaly Analysis"

/area/AAoutpost/research/kitchen
	name = "Research Outpost Kitchen"

/area/AAoutpost/research/disposal
	name = "Research Outpost Waste Disposal"

/area/AAoutpost/research/brainstorm
	name = "Research Outpost Brainstorm Room"

/area/AAconstruction
	name = "\improper Engineering Construction Area"
	icon_state = "yellow"

// CentComm
/area/AAcentcom/control
	name = "\improper Centcom Control"

/area/AAtdome
	name = "\improper Thunderdome"
	icon_state = "thunder"
	requires_power = 0
	dynamic_lighting = 0
	sound_env = ARENA

/area/AAcentcom/museum
	name = "\improper Museum"
	icon_state = "museum"

// Thunderdr
/area/AAtdome/tdome1
	name = "\improper Thunderdome (Team 1)"
	icon_state = "green"

/area/AAtdome/tdome2
	name = "\improper Thunderdome (Team 2)"
	icon_state = "yellow"

/area/AAtdome/tdomeadmin
	name = "\improper Thunderdome (Admin.)"
	icon_state = "purple"

/area/AAtdome/tdomeobserve
	name = "\improper Thunderdome (Observer.)"
	icon_state = "purple"

/area/AAholodeck
	name = "\improper Holodeck"
	icon_state = "Holodeck"
	requires_power = FALSE
	dynamic_lighting = FALSE
	sound_env = LARGE_ENCLOSED

/area/AAprison/solitary
	name = "Solitary Confinement"
	icon_state = "brig"

/area/AAsecurity/range
	name = "\improper Security - Firing Range"
	icon_state = "firingrange"

/area/AAmine
	icon_state = "mining"
	sound_env = 5 // stoneroom
	ambience_off = list(SFX_AMBIENT_MINE)
	ambience_powered = list(SFX_AMBIENT_MINE)
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)

/area/AAmine/explored
	name = "Mine"
	icon_state = "explored"

/area/AAmine/unexplored
	name = "Mine"
	icon_state = "unexplored"

/area/AAmine/unexplored/medium
	name = "Medium mine"
	icon_state = "unexplored_medium"

/area/AAmine/unexplored/deep
	name = "Deep mine"
	icon_state = "unexplored_deep"

/area/AAconstructionsite
	name = "\improper Construction Site"
	icon_state = "yellow"
	has_gravity = FALSE

/area/AAconstructionsite/maintenance
	name = "\improper Construction Site Maintenance"
	icon_state = "yellow"

/area/AAconstructionsite/bridge
	name = "\improper Construction Site Bridge"
	icon_state = "bridge"

/area/AAconstructionsite/hallway/fore
	name = "\improper Construction Site Fore Hallway"
	icon_state = "hallS"

/area/AAconstructionsite/storage
	name = "\improper Construction Site Storage Area"

/area/AAconstructionsite/medical
	name = "\improper Construction Site Medbay"
	icon_state = "medbay"

/area/AAconstructionsite/engineering
	name = "\improper Construction Site Engine Bay"
	icon_state = "engine"

/area/AAsolar/constructionsite
	name = "\improper Construction Site Solars"
	icon_state = "aft"

/area/AAconstructionsite/teleporter
	name = "Construction Site Teleporter"
	icon_state = "yellow"

/area/AAconstructionsite/ai
	name = "\improper Construction Computer Core"
	icon_state = "ai"

/area/AAconstructionsite/hallway/aft
	name = "\improper Construction Site Aft Hallway"
	icon_state = "hallP"

/area/AAmaintenance/auxsolarstarboard
	name = "Solar Maintenance - Fore Starboard"
	icon_state = "SolarcontrolS"

/area/AAmaintenance/incinerator
	name = "\improper Incinerator"
	icon_state = "disposal"

/area/AAmaintenance/auxsolarport
	name = "Solar Maintenance - Fore Port"
	icon_state = "SolarcontrolP"

/area/AAderelict/ship
	name = "\improper Abandoned Ship"
	icon_state = "yellow"

/area/AAderelict/snowasteroid
	name = "\improper Hidden Outpost"
	icon_state = "yellow"
	has_gravity = TRUE

/area/AAderelict/snowasteroid/bunker
	name = "\improper Hidden Outpost Bunker"
	icon_state = "red"
	has_gravity = TRUE

/area/AAderelict/snowasteroid/shuttle
	name = "\improper Hidden Outpost Shuttle"
	icon_state = "blue"
	has_gravity = TRUE

/area/AAderelict/djstation
	name = "\improper DJ Station"
	icon_state = "yellow"
	has_gravity = TRUE

/area/AAAIsattele
	name = "\improper AI Satellite Teleporter Room"
	icon_state = "teleporter"
	ambience_powered = list(SFX_AMBIENT_AI)
	has_gravity = FALSE
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)

/area/AAconstructionsite/atmospherics
	name = "\improper Construction Site Atmospherics"
	icon_state = "green"

/area/AAsupply
	name = "Supply Shuttle"
	icon_state = "shuttle3"

/area/AAsupply/dock
	name = "Supply Shuttle"
	icon_state = "shuttle3"
	requires_power = 0

/area/AAsupply/station
	name = "Supply Shuttle"
	icon_state = "shuttle3"
	requires_power = 0

/area/AAsecurity/armory
	name = "\improper Security - Armory"
	icon_state = "armory"

/area/AAsecurity/detectives_office
	name = "\improper Security - Forensic Office"
	icon_state = "detective"
	sound_env = MEDIUM_SOFTFLOOR

/area/AAshuttle/escape_pod1/centcom
	icon_state = "shuttle"

/area/AAshuttle/escape_pod2/centcom
	icon_state = "shuttle"

/area/AAshuttle/escape_pod3/centcom
	icon_state = "shuttle"

/area/AAshuttle/escape_pod5/centcom
	icon_state = "shuttle"

/area/AAcentcom/evac
	name = "\improper Centcom Emergency Shuttle"

/area/AAcentcom/ferry
	name = "\improper Centcom Transport Shuttle"

/area/AAcentcom/living
	name = "\improper Centcom Living Quarters"

/area/AAcentcom/suppy
	name = "\improper Centcom Supply Shuttle"

/area/AAcentcom/test
	name = "\improper Centcom Testing Facility"

/area/AAcentcom/creed
	name = "Creed's Office"

/area/AAacting/stage
	name = "\improper Stage"
	dynamic_lighting = 0
	requires_power = 0
	icon_state = "yellow"

/area/AAmerchant_station
	name = "\improper Merchant Station"
	icon_state = "LP"
	requires_power = 0

/area/AAthunder_rock
	name = "\improper Thunder Rock"
	icon_state = "LP"
	luminosity = 1
	dynamic_lighting = 0
	requires_power = 0

/area/AAacting/backstage
	name = "\improper Backstage"
	luminosity = 1
	dynamic_lighting = 0
	requires_power = 0

/area/AAsolar/auxstarboard
	name = "\improper Fore Starboard Solar Array"
	icon_state = "panelsA"

// SHUTTLES
// Shuttle areas must contain at least two areas in a subgroup if you want to move a shuttle from one place to another.
// Look at escape shuttle for example.
// All shuttles should now be under shuttle since we have smooth-wall code.
/area/shuttle/administration/centcom
	name = "\improper Administration Shuttle"
	icon_state = "shuttlered"

/area/shuttle/administration/station
	name = "\improper Administration Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/supply/elevator
	name = "Cargo Elevator"
	icon_state = "shuttle3"

/area/shuttle/supply/elevator/upper
	name = "Cargo Elevator Upper Deck"
	base_turf = /turf/simulated/open

/area/shuttle/supply/elevator/lower
	name = "Cargo Elevator Lower Deck"
	base_turf = /turf/simulated/floor/plating

/area/shuttle/merchant
	icon_state = "shuttlegrn"

/area/shuttle/merchant/home
	name = "\improper Merchant Van - Home"

/area/shuttle/merchant/transit
	icon_state = "shuttlegrn"
	base_turf = /turf/space/transit/south

/area/shuttle/merchant/away
	name = "\improper Merchant Van - Station North East"

/area/shuttle/merchant/dock
	name = "\improper Merchant Van - Station Docking Bay"

/area/shuttle/merchant/ghetto
	name = "\improper Merchant Van - Station Ghetto Dock"

/area/shuttle/merchant/outpost
	name = "\improper Merchant Van - Outpost"

// Command
/area/crew_quarters/heads/chief
	name = "\improper Engineering - CE's Office"

/area/crew_quarters/heads/hos
	name = "\improper Security - HoS' Office"

/area/crew_quarters/heads/hop
	name = "\improper Command - HoP's Office"

/area/crew_quarters/heads/hor
	name = "\improper Research - RD's Office"

/area/crew_quarters/heads/cmo
	name = "\improper Command - CMO's Office"

/area/bridge
	name = "\improper Bridge"
	icon_state = "bridge"

/area/bridge/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	sound_env = MEDIUM_SOFTFLOOR

/area/bridge/meeting_room/cafe
	name = "\improper Heads of Staff Cafeteria"

// Shuttles

/area/shuttle/constructionsite
	name = "Construction Site Shuttle"
	icon_state = "yellow"

/area/shuttle/constructionsite/station
	name = "Construction Site Shuttle"

/area/shuttle/constructionsite/transit
	name = "Construction Site Shuttle Transit"
	icon_state = "shuttle"

/area/shuttle/mining
	name = "\improper Mining Shuttle"

/area/shuttle/mining/outpost
	icon_state = "shuttle"
	base_turf = /turf/simulated/floor/asteroid

/area/shuttle/mining/station
	icon_state = "shuttle2"

/area/shuttle/mining/transit
	name = "Mining Shuttle Transit"
	icon_state = "shuttle"

/area/shuttle/security
	name = "\improper Security Shuttle"

/area/shuttle/security/outpost
	icon_state = "shuttle"
	base_turf = /turf/simulated/floor/asteroid

/area/shuttle/security/station
	icon_state = "shuttle2"

/area/shuttle/security/transit
	name = "Mining Security Transit"
	icon_state = "shuttle"

/area/shuttle/deathsquad/centcom
	name = "Deathsquad Shuttle"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/shuttle/deathsquad/transit
	name = "Deathsquad Shuttle Internim"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/shuttle/deathsquad/station
	name = "Deathsquad Shuttle Station"

/area/shuttle/administration
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/shuttle/syndicate_elite
	name = "\improper Syndicate Elite Shuttle"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/shuttle/transport/centcom
	icon_state = "shuttle"
	name = "\improper Transport Shuttle Centcom"

/area/shuttle/transport/transit
	icon_state = "shuttle"
	name = "\improper Transport Shuttle Transit"

/area/shuttle/transport/station
	icon_state = "shuttle"
	name = "\improper Transport Shuttle"

/area/shuttle/alien/mine
	icon_state = "shuttle"
	name = "\improper Alien Shuttle Mine"
	requires_power = 1

/area/shuttle/alien/base
	icon_state = "shuttle"
	name = "\improper Alien Shuttle Base"
	requires_power = 1

/area/shuttle/arrival
	name = "\improper Arrival Shuttle"

/area/shuttle/arrival/station
	icon_state = "shuttle"

/area/shuttle/escape/centcom
	name = "\improper Emergency Shuttle Centcom"
	icon_state = "shuttle"

/area/shuttle/escape
	name = "\improper Emergency Shuttle"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/shuttle/escape/station
	name = "\improper Emergency Shuttle Station"
	icon_state = "shuttle2"

/area/shuttle/escape/transit // the area to pass through for 3 minute transit
	name = "\improper Emergency Shuttle Transit"
	icon_state = "shuttle"

/area/shuttle/escape_pod1
	name = "\improper Escape Pod One"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/shuttle/escape_pod1/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod1/transit
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

/area/shuttle/escape_pod2
	name = "\improper Escape Pod Two"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/shuttle/escape_pod2/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod2/transit
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

/area/shuttle/escape_pod3
	name = "\improper Escape Pod Three"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/shuttle/escape_pod3/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod3/transit
	icon_state = "shuttle"
	base_turf = /turf/space/transit/east

/area/shuttle/escape_pod5 // Pod 4 was lost to meteors
	name = "\improper Escape Pod Five"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/shuttle/escape_pod5/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod5/transit
	icon_state = "shuttle"
	base_turf = /turf/space/transit/east

/area/shuttle/administration/transit
	name = "Administration Shuttle Transit"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/east

// === Trying to remove these areas:

/area/shuttle/research
	name = "\improper Research Shuttle"

/area/shuttle/research/station
	icon_state = "shuttle2"

/area/shuttle/research/outpost
	icon_state = "shuttle"
	base_turf = /turf/simulated/floor/asteroid

/area/shuttle/research/transit
	name = "Research Shuttle Transit"
	icon_state = "shuttle"

// SYNDICATES

/area/syndicate_mothership
	name = "\improper Syndicate Base"
	icon_state = "syndie-ship"
	requires_power = 0
	dynamic_lighting = 0

/area/syndicate_mothership/ninja
	name = "\improper Ninja Base"
	requires_power = 0
	base_turf = /turf/space/transit/north

// RESCUE

// names are used
/area/rescue_base
	name = "\improper Response Team Base"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = 1
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/rescue_base/base
	name = "\improper Barracks"
	icon_state = "yellow"
	dynamic_lighting = 0

/area/rescue_base/start
	name = "\improper Response Team Base"
	icon_state = "shuttlered"

/area/rescue_base/southwest
	name = "south-west of SS13"
	icon_state = "southwest"

/area/rescue_base/northwest
	name = "north-west of SS13"
	icon_state = "northwest"

/area/rescue_base/northeast
	name = "north-east of SS13"
	icon_state = "northeast"

/area/rescue_base/southeast
	name = "south-east of SS13"
	icon_state = "southeast"

/area/rescue_base/north
	name = "north of SS13"
	icon_state = "north"

/area/rescue_base/south
	name = "south of SS13"
	icon_state = "south"

/area/rescue_base/arrivals_dock
	name = "docked with station"
	icon_state = "shuttle"

/area/rescue_base/transit
	name = "\proper bluespace"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

// MINING MOTHERSHIP

/area/creaker
	name = "\improper Mining Ship 'Creaker'"
	icon_state = "yellow"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/creaker/station
	name = "\improper Mining Ship 'Creaker'"
	icon_state = "shuttlered"

/area/creaker/north
	name = "northern asteroid field"
	icon_state = "southwest"

/area/creaker/west
	name = "western asteroid field"
	icon_state = "northwest"

/area/creaker/east
	name = "eastern asteroid field"
	icon_state = "northeast"

// ENEMY

// names are used
/area/syndicate_station
	name = "\improper Independant Station"
	icon_state = "yellow"
	requires_power = 0
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/syndicate_station/start
	name = "\improper Syndicate Forward Operating Base"
	icon_state = "yellow"

/area/syndicate_station/southwest
	name = "south-west of SS13"
	icon_state = "southwest"

/area/syndicate_station/northwest
	name = "north-west of SS13"
	icon_state = "northwest"

/area/syndicate_station/northeast
	name = "north-east of SS13"
	icon_state = "northeast"

/area/syndicate_station/southeast
	name = "south-east of SS13"
	icon_state = "southeast"

/area/syndicate_station/north
	name = "north of SS13"
	icon_state = "north"

/area/syndicate_station/south
	name = "south of SS13"
	icon_state = "south"

/area/syndicate_station/transit
	name = "\proper bluespace"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

/area/shuttle/syndicate_elite/northwest
	icon_state = "northwest"

/area/shuttle/syndicate_elite/northeast
	icon_state = "northeast"

/area/shuttle/syndicate_elite/southwest
	icon_state = "southwest"

/area/shuttle/syndicate_elite/southeast
	icon_state = "southeast"

/area/shuttle/syndicate_elite/transit
	name = "\proper bluespace"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

/area/skipjack_station
	name = "\improper Skipjack"
	icon_state = "yellow"
	requires_power = 0
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)

/area/skipjack_station/southwest_solars
	name = "aft port solars"
	icon_state = "southwest"

/area/skipjack_station/northwest_solars
	name = "fore port solars"
	icon_state = "northwest"

/area/skipjack_station/northeast_solars
	name = "fore starboard solars"
	icon_state = "northeast"

/area/skipjack_station/southeast_solars
	name = "aft starboard solars"
	icon_state = "southeast"

/area/skipjack_station/base
	name = "Raider Base"
	icon_state = "yellow"
	base_turf = /turf/simulated/floor/asteroid

/area/skipjack_station/start
	name = "\improper Skipjack"
	icon_state = "shuttlered"

/area/skipjack_station/transit
	name = "Skipjack Transit"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

// SUBSTATIONS (Subtype of maint, that should let them serve as shielded area during radstorm)

/area/maintenance/substation
	name = "Substation"
	icon_state = "substation"
	sound_env = SMALL_ENCLOSED

/area/maintenance/substation/command // AI and central cluster. This one will be between HoP office and meeting room (probably).
	name = "Command Substation"

/area/maintenance/substation/engineering // Probably will be connected to engineering SMES room, as wires cannot be crossed properly without them sharing powernets.
	name = "Engineering Substation"

/area/maintenance/substation/medical // Medbay
	name = "Medical Substation"

/area/maintenance/substation/research // Research
	name = "Research Substation"

/area/maintenance/substation/civilian_east // Bar, kitchen, dorms, ...
	name = "Civilian East Substation"

/area/maintenance/substation/civilian_west // Cargo, PTS, locker room, probably arrivals, ...)
	name = "Civilian West Substation"

/area/maintenance/substation/security // Security, Brig, Permabrig, etc.
	name = "Security Substation"

/area/maintenance/substation/atmospherics
	name = "Atmospherics Substation"

/area/maintenance/substation/cargo
	name = "Cargo Substation"

/area/maintenance/substation/starport
	name = "Starport Substation"

/area/maintenance/substation/hydro
	name = "Hydroponics Substation"

/area/maintenance/substation/emergency
	name = "Emergency Substation"

// Maintenance

/area/maintenance/disposal
	name = "\improper Trash Disposal"
	icon_state = "disposal"

/area/maintenance/ghetto_medbay
	name = "\improper Ghetto Medbay"
	icon_state = "ghettomedbay"

/area/maintenance/ghetto_minicasino
	name = "\improper Ghetto Mini Casino"
	icon_state = "ghettominicasino"

/area/maintenance/ghetto_rnd
	name = "\improper Ghetto RnD"
	icon_state = "ghettornd"

/area/maintenance/ghetto_janitor
	name = "\improper Ghetto Janitor Room"
	icon_state = "ghettojanitor"

/area/maintenance/ghetto_virology
	name = "\improper Ghetto Virology"
	icon_state = "ghettovirology"

/area/maintenance/ghetto_shop
	name = "\improper Ghetto Shop"
	icon_state = "ghettoshop"

/area/maintenance/ghetto_bar
	name = "\improper Ghetto Bar"
	icon_state = "ghettobar"

/area/maintenance/ghetto_library
	name = "\improper Ghetto Library"
	icon_state = "ghettolibrary"

/area/maintenance/ghetto_toilet
	name = "\improper Underground Toilets"
	icon_state = "ghettotoilets"

/area/maintenance/ghetto_dorm
	name = "\improper Abandoned Dorm"
	icon_state = "ghettodorm"

/area/maintenance/ghetto_main
	name = "\improper Underground Main"
	icon_state = "ghettomain"

/area/maintenance/ghetto_main_south
	name = "\improper Underground Main - South"
	icon_state = "ghettomainsouth"

/area/maintenance/ghetto_main_west
	name = "\improper Underground Main - West"
	icon_state = "ghettomainsouth"

/area/maintenance/ghetto_eva
	name = "\improper Ghetto EVA"
	icon_state = "ghettoeva"

/area/maintenance/ghetto_eva_maint
	name = "\improper Ghetto EVA Maintenance"
	icon_state = "ghettoevamaint"

/area/maintenance/ghetto_casino
	name = "\improper Ghetto Casino"
	icon_state = "ghettocasino"

/area/maintenance/ghetto_syndie
	name = "\improper Ghetto Syndie"
	icon_state = "ghettosyndie"

/area/maintenance/ghetto_dockhall
	name = "\improper Underground Dock Hall"
	icon_state = "ghettodockhall"

/area/maintenance/ghetto_cafe
	name = "\improper Underground Cafe"
	icon_state = "ghettocafe"

/area/maintenance/ghetto_strangeplace
	name = "\improper Underground Bar"
	icon_state = "ghettostrangeplace"

/area/maintenance/ghetto_detective
	name = "\improper Abandoned Detective's Office"
	icon_state = "ghettodetective"

/area/maintenance/underground/central_one
	name = "\improper Underground Central Primary Hallway SE"
	icon_state = "uhall1"

/area/maintenance/underground/central_two
	name = "\improper Underground Central Primary Hallway SW"
	icon_state = "uhall2"

/area/maintenance/underground/central_three
	name = "\improper Underground Central Primary Hallway NW"
	icon_state = "uhall3"

/area/maintenance/underground/central_four
	name = "\improper Underground Central Primary Hallway NE"
	icon_state = "uhall4"

/area/maintenance/underground/central_five
	name = "\improper Underground Central Primary Hallway E"
	icon_state = "uhall5"

/area/maintenance/underground/central_six
	name = "\improper Underground Central Primary Hallway N"
	icon_state = "uhall6"

/area/maintenance/underground/cargo
	name = "\improper Underground Cargo Maintenance"
	icon_state = "ucargo"

/area/maintenance/underground/atmospherics
	name = "\improper Underground Atmospherics Maintenance"
	icon_state = "uatmos"


/area/maintenance/underground/arrivals
	name = "\improper Underground Arrivals Maintenance"
	icon_state = "uarrival"

/area/maintenance/underground/locker_room
	name = "\improper Underground Locker Room Maintenance"
	icon_state = "ulocker"

/area/maintenance/underground/EVA
	name = "\improper Underground EVA Maintenance"
	icon_state = "uEVA"

/area/maintenance/underground/security
	name = "\improper Underground Security Maintenance"
	icon_state = "usecurity"

/area/maintenance/underground/security_west
	name = "\improper Underground Security Maintenance - West"
	icon_state = "usecuritywest"

/area/maintenance/underground/security_port
	name = "\improper Underground Security Port Maintenance"
	icon_state = "usecurityport"

/area/maintenance/underground/security_main
	name = "\improper Underground Security Main Maintenance"
	icon_state = "usecuritymain"

/area/maintenance/underground/security_lobby
	name = "\improper Underground Security Lobby Maintenance"
	icon_state = "usecuritylobby"

/area/maintenance/underground/security_firefighting
	name = "\improper Underground Security Tech Room"
	icon_state = "usecurityfirefighting"

/area/maintenance/underground/security_dorms
	name = "\improper Underground Security Dormitories"
	icon_state = "usecuritybreak"

/area/maintenance/underground/security_breakroom
	name = "\improper Underground Security Break Room"
	icon_state = "usecuritybreak"

/area/maintenance/underground/security_storage
	name = "\improper Underground Security Storage Room"
	icon_state = "usecuritystorage"

/area/maintenance/underground/security_mainhall
	name = "\improper Underground Security Main Hall"
	icon_state = "usecuritylobby"

/area/maintenance/underground/security_hallway
	name = "\improper Underground Security Hallway"
	icon_state = "usecurityhall"

/area/maintenance/underground/security_meeting
	name = "\improper Underground Security Meeting Maintenance"
	icon_state = "usecuritymeeting"

/area/maintenance/underground/engineering
	name = "\improper Underground Engineering Maintenance"
	icon_state = "uengineering"

/area/maintenance/underground/engineering_lower
	name = "\improper Underground Engineering"
	icon_state = "uengineering"

/area/maintenance/underground/research
	name = "\improper Underground Research Maintenance"
	icon_state = "uresearch"

/area/maintenance/underground/robotics_lab
	name = "\improper Underground Robotics Lab Maintenance"
	icon_state = "urobotics"

/area/maintenance/underground/research_port
	name = "\improper Underground Research Port Maintenance"
	icon_state = "uresearchport"

/area/maintenance/underground/research_shuttle
	name = "\improper Underground Research Shuttle Dock Maintenance"
	icon_state = "uresearchshuttle"

/area/maintenance/underground/research_utility_room
	name = "\improper Underground Utility Room"
	icon_state = "uresearchutilityroom"

/area/maintenance/underground/research_starboard
	name = "\improper Underground Research Maintenance - Starboard"
	icon_state = "uresearchstarboard"

/area/maintenance/underground/research_xenobiology
	name = "\improper Underground Research Xenobiology Maintenance"
	icon_state = "uresearchxeno"

/area/maintenance/underground/research_misc
	name = "\improper Underground Research Miscellaneous Maintenance"
	icon_state = "uresearchmisc"

/area/maintenance/underground/civilian_NE
	name = "\improper Underground Civilian NE Maintenance"
	icon_state = "ucivne"

/area/maintenance/underground/medbay
	name = "\improper Underground Medbay Maintenance"
	icon_state = "umedbay"

/area/maintenance/underground/medbay/south
	name = "\improper Underground Medbay Maintenance - South"
	icon_state = "umedbay"

/area/maintenance/underground/dormitories
	name = "\improper Underground Dormitories Maintenance"
	icon_state = "udorm"

/area/maintenance/underground/warehouse
	name = "\improper Underground Warehouse Maintenance"
	icon_state = "uwarehouse"

/area/maintenance/underground/vault
	name = "\improper Underground Vault Maintenance"
	icon_state = "uvault"

/area/maintenance/underground/tool_storage
	name = "\improper Underground Tool Storage Maintenance"
	icon_state = "utoolstorage"

/area/maintenance/underground/janitor
	name = "\improper Underground Custodial Closet Maintenance"
	icon_state = "ujanitor"

/area/maintenance/underground/vaccant_office
	name = "\improper Underground Vaccant Office Maintenance"
	icon_state = "uvaccant"

/area/maintenance/underground/engine
	name = "\improper Underground Engine Maintenance"
	icon_state = "uengine"

/area/maintenance/underground/incinerator
	name = "\improper Underground Incinerator Maintenance"
	icon_state = "uincinerator"

/area/maintenance/underground/port_primary_hallway
	name = "\improper Underground Port Primary Hallway Maintenance"
	icon_state = "uportprim"

/area/maintenance/underground/board_games_club
	name = "\improper Underground Board Games Club"
	icon_state = "uportprim"

/area/maintenance/underground/gateway
	name = "\improper Underground Gateway Maintenance"
	icon_state = "ugateway"

/area/maintenance/underground/fitness
	name = "\improper Underground Fitness Room Maintenance"
	icon_state = "ufitness"

/area/maintenance/underground/bar
	name = "\improper Underground Bar Maintenance"
	icon_state = "ubar"

/area/maintenance/underground/kitchen
	name = "\improper Underground Kitchen Maintenance"
	icon_state = "ukitchen"

/area/maintenance/underground/hydroponics
	name = "\improper Underground Hydroponics Maintenance"
	icon_state = "uhydro"

/area/maintenance/underground/library
	name = "\improper Underground Library Maintenance"
	icon_state = "ulibrary"

/area/maintenance/underground/starboard_primary_hallway
	name = "\improper Starboard Primary Hallway Maintenance"
	icon_state = "ustarboard"

/area/maintenance/underground/cloning_entrance
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/maintenance/underground/cloning_checkpoint
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/maintenance/underground/cloning_storage
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/maintenance/underground/cloning_lobby
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/maintenance/underground/cloning_laboratory
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/maintenance/underground/cloning_surgery
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/maintenance/underground/cloning_morgue
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/maintenance/underground/cloning_cells
	name = "\improper Undefined Area"
	icon_state = "dark"

/area/maintenance/atmos_control
	name = "\improper Atmospherics Maintenance"
	icon_state = "fpmaint"

/area/maintenance/arrivals
	name = "\improper Arrivals Maintenance"
	icon_state = "maint_arrivals"

/area/maintenance/bar
	name = "\improper Bar Maintenance"
	icon_state = "maint_bar"

/area/maintenance/cargo
	name = "\improper Cargo Maintenance"
	icon_state = "maint_cargo"

/area/maintenance/engi_engine
	name = "\improper Engine Maintenance"
	icon_state = "maint_engine"

/area/maintenance/engi_shuttle
	name = "\improper Engineering Shuttle Access"
	icon_state = "maint_e_shuttle"

/area/maintenance/engineering
	name = "\improper Engineering Maintenance"
	icon_state = "maint_engineering"

/area/maintenance/evahallway
	name = "\improper EVA Maintenance"
	icon_state = "maint_eva"

/area/maintenance/dormitory
	name = "\improper Dormitory Maintenance"
	icon_state = "maint_dormitory"

/area/maintenance/library
	name = "\improper Library Maintenance"
	icon_state = "maint_library"

/area/maintenance/locker
	name = "\improper Locker Room Maintenance"
	icon_state = "maint_locker"

/area/maintenance/medbay
	name = "\improper Medbay Maintenance"
	icon_state = "maint_medbay"

/area/maintenance/bridge
	name = "\improper Bridge Maintenance"
	icon_state = "maint_eva"

/area/maintenance/bridge/west
	name = "\improper Bridge Maintenance - West"

/area/maintenance/bridge/east
	name = "\improper Bridge Maintenance - East"

/area/maintenance/research_port
	name = "\improper Research Maintenance - Port"
	icon_state = "maint_research_port"

/area/maintenance/research_shuttle
	name = "\improper Research Shuttle Dock Maintenance"
	icon_state = "maint_research_shuttle"

/area/maintenance/research_starboard
	name = "\improper Research Maintenance - Starboard"
	icon_state = "maint_research_starboard"

/area/maintenance/security_port
	name = "\improper Security Maintenance - Port"
	icon_state = "maint_security_port"

/area/maintenance/security_starboard
	name = "\improper Security Maintenance - Starboard"
	icon_state = "maint_security_starboard"

/area/maintenance/exterior
	name = "\improper Exterior Reinforcements"
	icon_state = "maint_security_starboard"
	area_flags = AREA_FLAG_EXTERNAL & AREA_FLAG_NO_STATION
	has_gravity = FALSE
	turf_initializer = /decl/turf_initializer/maintenance/space

/area/maintenance/research_atmos
	name = "\improper Research Atmospherics Maintenance"
	icon_state = "maint_engineering"

/area/maintenance/medbay_north
	name = "\improper North Medbay Maintenance"
	icon_state = "maint_medbay"

/area/maintenance/hydro
	name = "\improper Hydroponics Maintenance"
	icon_state = "maint_medbay"

/area/maintenance/chapel
	name = "\improper Chapel Maintenance"
	icon_state = "maint_security_port"

/area/maintenance/chapel/north
	name = "\improper Chapel Maintenance - North"

/area/maintenance/chapel/south
	name = "\improper Chapel Maintenance - South"

/area/maintenance/abandoned_casino
	name = "\improper Abandoned Casino"
	icon_state = "ghettocasino"


/area/maintenance/getto_rnd
	name = "\improper RnD Maintenance"
	icon_state = "maint_cargo"

/area/maintenance/disposal/underground
	name = "Underground Waste Disposal"
	icon_state = "disposal"

// Dank Maintenance
/area/maintenance/sub
	turf_initializer = /decl/turf_initializer/maintenance/heavy

/area/maintenance/sub/relay_station
	name = "\improper Sublevel Maintenance - Relay Station"
	icon_state = "blue2"
	turf_initializer = null

/area/maintenance/sub/fore
	name = "\improper Sublevel Maintenance - Fore"
	icon_state = "sub_maint_fore"

/area/maintenance/sub/aft
	name = "\improper Sublevel Maintenance - Aft"
	icon_state = "sub_maint_aft"

/area/maintenance/sub/port
	name = "\improper Sublevel Maintenance - Port"
	icon_state = "sub_maint_port"

/area/maintenance/sub/starboard
	name = "\improper Sublevel Maintenance - Starboard"
	icon_state = "sub_maint_starboard"

/area/maintenance/sub/central
	name = "\improper Sublevel Maintenance - Central"
	icon_state = "sub_maint_central"

/area/maintenance/sub/command
	name = "\improper Sublevel Maintenance - Command"
	icon_state = "sub_maint_command"
	turf_initializer = null

// Hallway

/area/hallway/primary/
	sound_env = LARGE_ENCLOSED

/area/hallway/primary/fore
	name = "\improper Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/primary/starboard
	name = "\improper Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/aft
	name = "\improper Aft Primary Hallway"
	icon_state = "hallA"

/area/hallway/primary/port
	name = "\improper Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/primary/seclobby
	name = "\improper Security Lobby"
	icon_state = "security"

/area/hallway/primary/englobby
	name = "\improper Engineering Foyer"
	icon_state = "engineering_foyer"

/area/hallway/primary/central_one
	name = "\improper Central Primary Hallway"
	icon_state = "hallC1"

/area/hallway/primary/central_two
	name = "\improper Central Primary Hallway"
	icon_state = "hallC2"

/area/hallway/primary/central_three
	name = "\improper Central Primary Hallway"
	icon_state = "hallC3"

/area/hallway/primary/central_fore
	name = "\improper Central Primary Hallway"
	icon_state = "hallC3"

/area/hallway/primary/central_fife
	name = "\improper Central Primary Hallway"
	icon_state = "hallC3"

/area/hallway/primary/central_six
	name = "\improper Central Primary Hallway"
	icon_state = "hallC3"

/area/hallway/primary/central_seven
	name = "\improper Central Primary Hallway"
	icon_state = "hallC3"

/area/hallway/primary/frontier
	name = "\improper Central Hallway"
	icon_state = "hallC1"

/area/hallway/primary/frontier/ring_north
	name = "\improper Ring Hallway - North"
	icon_state = "hallF"

/area/hallway/primary/frontier/ring_south
	name = "\improper Ring Hallway - South"
	icon_state = "hallP"

/area/hallway/primary/frontier/central_mideast
	name = "\improper Central Hallway - Mideast"
	icon_state = "hallC2"

/area/hallway/primary/frontier/central_east
	name = "\improper Central Hallway - East"
	icon_state = "hallC2"

/area/hallway/primary/frontier/central_midwest
	name = "\improper Central Hallway - Midwest"
	icon_state = "hallC3"

/area/hallway/primary/frontier/central_west
	name = "\improper Central Hallway - West"
	icon_state = "hallC3"

/area/hallway/primary/frontier/brighall
	name = "\improper Brig Hallway"
	icon_state = "security"

/area/hallway/primary/frontier/dormhall
	name = "\improper Dormitory Hallway"
	icon_state = "Sleep"




/area/hallway/secondary/exit
	name = "\improper Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/secondary/entry/pods
	name = "\improper Arrival Shuttle Hallway - Escape Pods"
	icon_state = "entry_pods"

/area/hallway/secondary/entry/fore
	name = "\improper Arrival Shuttle Hallway - Fore"
	icon_state = "entry_1"

/area/hallway/secondary/entry/port
	name = "\improper Arrival Shuttle Hallway - Port"
	icon_state = "entry_2"

/area/hallway/secondary/entry/starboard
	name = "\improper Arrival Shuttle Hallway - Starboard"
	icon_state = "entry_3"

/area/hallway/secondary/entry/aft
	name = "\improper Arrival Shuttle Hallway - Aft"
	icon_state = "entry_4"

// Command

/area/crew_quarters/captain
	name = "\improper Command - Captain's Office"
	icon_state = "captain"
	sound_env = MEDIUM_SOFTFLOOR

// Crew


/area/crew_quarters
	name = "\improper Dormitories"
	icon_state = "Sleep"

/area/crew_quarters/locker
	name = "\improper Locker Room"
	icon_state = "locker"

/area/crew_quarters/toilet
	name = "\improper Dormitory Toilets"
	icon_state = "toilet"
	sound_env = SMALL_ENCLOSED

/area/crew_quarters/toilet/bar
	name = "\improper Bar Toilet"

/area/crew_quarters/toilet/west
	name = "\improper West Hallway Bathroom"

/area/crew_quarters/sleep
	name = "\improper Dormitories"
	icon_state = "Sleep"

/area/crew_quarters/sleep/cryo
	name = "\improper Cryogenic Storage"
	icon_state = "Cryopods"

/area/crew_quarters/sleep2
	name = "\improper Dormitories Hallway North"
	icon_state = "Sleep"

/area/crew_quarters/sleep3
	name = "\improper Dormitories Hallway West"
	icon_state = "Sleep"

/area/crew_quarters/sleep/lobby
	name = "\improper Dormitory Lobby"
	icon_state = "Sleep"

/area/crew_quarters/sleep/cave
	name = "\improper Dormitory Cave"
	icon_state = "explored"

/area/crew_quarters/underdorm
	name = "\improper Underground Dormitories"
	icon_state = "underdorm"

/area/crew_quarters/underdorm/boxing
	name = "\improper Boxing Club"
	icon_state = "fitness"

/area/crew_quarters/underdorm/maint
	name = "\improper Underground Dormitories Maintenance"
	icon_state = "underdormmaint"

/area/crew_quarters/underdorm/theater
	name = "\improper Theater"
	icon_state = "Theatre"

/area/crew_quarters/underdorm/theater/clown
	name = "\improper Clown's Bedroom"
	icon_state = "Theatre"

/area/crew_quarters/underdorm/theater/mime
	name = "\improper Mime's Bedroom"
	icon_state = "Theatre"

/area/crew_quarters/underdorm/theater/actor
	name = "\improper Actors' Break Room"
	icon_state = "Theatre"

/area/crew_quarters/underdorm/sauna
	name = "\improper Sauna"
	icon_state = "toilet"


/area/crew_quarters/sleep/cabin1
	name = "\improper Private Bedroom One"
	icon_state = "PrivDormOne"
	sound_env = SMALL_SOFTFLOOR

/area/crew_quarters/sleep/cabin2
	name = "\improper Private Bedroomn Two"
	icon_state = "PrivDormTwo"
	sound_env = SMALL_SOFTFLOOR

/area/crew_quarters/sleep/cabin3
	name = "\improper Private Bedroom Three"
	icon_state = "PrivDormThree"
	sound_env = SMALL_SOFTFLOOR

/area/crew_quarters/sleep/cabin4
	name = "\improper Private Bedroom Four"
	icon_state = "PrivDormFour"
	sound_env = SMALL_SOFTFLOOR

/area/crew_quarters/sleep/cabin5
	name = "\improper Private Bedroom Five"
	icon_state = "PrivDormFive"
	sound_env = SMALL_SOFTFLOOR

/area/crew_quarters/sleep/cabin6
	name = "\improper Private Bedroom Six"
	icon_state = "PrivDormSix"
	sound_env = SMALL_SOFTFLOOR

/area/crew_quarters/sleep/underg_cabin1
	name = "\improper Underground Bedroom One"
	icon_state = "UndergroundDormOne"
	sound_env = SMALL_SOFTFLOOR

/area/crew_quarters/sleep/underg_cabin2
	name = "\improper Underground Bedroom Two"
	icon_state = "UndergroundDormTwo"
	sound_env = SMALL_SOFTFLOOR

/area/crew_quarters/sleep/underg_cabin3
	name = "\improper Underground Bedroom Three"
	icon_state = "UndergroundDormThree"
	sound_env = SMALL_SOFTFLOOR

/area/crew_quarters/sleep/engi_wash
	name = "\improper Engineering Washroom"
	icon_state = "toilet"
	sound_env = SMALL_ENCLOSED

/area/crew_quarters/sleep/bedrooms
	name = "\improper Dormitory Bedroom One"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/crew_quarters/sleep/dorms
	name = "\improper Dormitory Shared Bedroom"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/crew_quarters/sleep/quartes1
	name = "\improper Dormitory Quartes One"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/crew_quarters/sleep/quartes2
	name = "\improper Dormitory Quartes Two"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/crew_quarters/sleep/quartes3
	name = "\improper Dormitory Quartes Three"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/crew_quarters/sleep/quartes4
	name = "\improper Dormitory Quartes Four"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/crew_quarters/locker/locker_toilet
	name = "\improper Locker Toilets"
	icon_state = "toilet"
	sound_env = SMALL_ENCLOSED

/area/crew_quarters/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"

/area/crew_quarters/fitness/arcade
	name = "\improper Arcade"
	icon_state = "arcade"

/area/crew_quarters/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/crew_quarters/bar
	name = "\improper Bar"
	icon_state = "bar"
	sound_env = LARGE_SOFTFLOOR

/area/crew_quarters/barbackroom
	name = "\improper Bar Backroom"
	icon_state = "barBR"

/area/crew_quarters/ubarbackroom // new room for bartender
	name = "\improper Underground Bar Backroom"
	icon_state = "ubarBR"

/area/crew_quarters/mess
	name = "\improper Mess Hall"
	icon_state = "cafeteria"
	sound_env = LARGE_SOFTFLOOR

/area/library
 	name = "\improper Library"
 	icon_state = "library"
 	sound_env = LARGE_SOFTFLOOR

/area/janitor
	name = "\improper Custodial Closet"
	icon_state = "janitor"

/area/chapel/main
	name = "\improper Chapel"
	icon_state = "chapel"
	ambience_off = list(SFX_AMBIENT_OFF_GLOBAL)
	ambience_powered = list(SFX_AMBIENT_CHAPEL)
	sound_env = LARGE_ENCLOSED

/area/chapel/office
	name = "\improper Chapel Office"
	icon_state = "chapeloffice"

/area/chapel/crematorium
	name = "\improper Crematorium"
	icon_state = "chapelcrematorium"

/area/iaoffice
	name = "\improper Internal Affairs"
	icon_state = "law"

/area/lawoffice
	name = "\improper Law Office"
	icon_state = "law"


// Engineering

/area/engineering/
	name = "\improper Engineering"
	icon_state = "engineering"
	ambience_powered = list(SFX_AMBIENT_ENGINEERING)

/area/engineering/grav_generator
	name = "\improper Gravitational Generator Room"
	icon_state = "engine"
	sound_env = LARGE_ENCLOSED

/area/engineering/lower
	name = "\improper Engineering Lower Deck"
	icon_state = "lower_engi"

/area/engineering/lower/rust
	name = "\improper R-UST Engine"
	icon_state = "rust"

/area/engineering/lower/rust/core
	name = "\improper R-UST Core"
	icon_state = "rust"

/area/engineering/lower/rust/control
	name = "\improper R-UST Control Room"
	icon_state = "rust"

/area/engineering/engine_airlock
	name = "\improper Engine Room Airlock"
	icon_state = "engine"

/area/engineering/singularity_engine
	name = "\improper Singularity Engine"
	icon_state = "engine"

/area/engineering/singularity_control
	name = "\improper Singularity Engine Control Room"
	icon_state = "engine_monitoring"

/area/engineering/singularity_storage
	name = "\improper Singularity Engine Storage"
	icon_state = "engineering_storage"

/area/engineering/engine_waste
	name = "\improper Engine Waste Handling"
	icon_state = "engine_waste"

/area/engineering/break_room
	name = "\improper Engineering Break Room"
	icon_state = "engineering_break"
	sound_env = MEDIUM_SOFTFLOOR

/area/engineering/workshop
	name = "\improper Engineering Workshop"
	icon_state = "engineering_workshop"

/area/engineering/sublevel_access
	name = "\improper Engineering Sublevel Access"

/area/engineering/atmos
	name = "\improper Atmospherics"
	icon_state = "atmos"
	ambience_powered = list(SFX_AMBIENT_ENGINEERING, SFX_AMBIENT_ATMOSPHERICS)

/area/engineering/atmos/storage
	name = "\improper Atmospherics Storage"
	icon_state = "atmos_storage"

/area/engineering/toilet
	name = "\improper Atmospherics"
	icon_state = "engineering_break"

/area/engineering/eva_airlock
	name = "\improper Engineering Airlock"
	icon_state = "engineering_break"

/area/engineering/atmos_monitoring
	name = "\improper Atmospherics Monitoring Room"
	icon_state = "engine_monitoring"

/area/engineering/storage
	name = "\improper Engineering Storage"
	icon_state = "engineering_storage"

/area/engineering/engine_eva
	name = "\improper Engine EVA"
	icon_state = "engine_eva"

/area/engineering/engine_monitoring
	name = "\improper Engine Monitoring Room"
	icon_state = "engine_monitoring"

/area/engineering/locker_room
	name = "\improper Engineering Locker Room"
	icon_state = "engineering_locker"

/area/engineering/engineering_monitoring
	name = "\improper Engineering Monitoring Room"
	icon_state = "engine_monitoring"

/area/engineering/drone_fabrication
	name = "\improper Engineering Drone Fabrication"
	icon_state = "drone_fab"
	sound_env = SMALL_ENCLOSED

/area/engineering/engine_smes
	name = "\improper Engineering SMES"
	icon_state = "engine_smes"
	sound_env = SMALL_ENCLOSED

/area/engineering/engine_room
	name = "\improper Engine Room"
	icon_state = "engine"
	sound_env = LARGE_ENCLOSED

// Medbay

/area/medical/genetics
	name = "\improper Genetics Lab"
	icon_state = "genetics"

/area/medical/genetics_cloning
	name = "\improper Cloning Lab"
	icon_state = "cloning"

/area/medical/biostorage/underground
	name = "\improper Undergound Medbay Storage"
	icon_state = "medbay4"

/area/medical/sleeper
	name = "\improper Emergency Treatment Room"
	icon_state = "exam_room"

/area/medical/sleeper/underground
	name = "\improper Underground Emergency Treatment Room"
	icon_state = "exam_room"

/area/medical/chemistry
	name = "\improper Chemistry"
	icon_state = "chem"

/area/medical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"

/area/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"
	ambience_powered = list(SFX_AMBIENT_MORGUE, SFX_AMBIENT_SCIENCE)

/area/medical/surgery
	name = "\improper Operating Theatre"
	icon_state = "surgery"

// Solars

/area/solar
	ambient_music_tags = list(MUSIC_TAG_SPACE)

/area/solar/starboard
	name = "\improper Starboard Auxiliary Solar Array"
	icon_state = "panelsS"

/area/solar/auxport
	name = "\improper Fore Port Solar Array"
	icon_state = "panelsA"

/area/solar/fore
	name = "\improper Fore Solar Array"
	icon_state = "yellow"

/area/solar/port
	name = "\improper Port Auxiliary Solar Array"
	icon_state = "panelsP"

/area/maintenance/foresolar
	name = "\improper Solar Maintenance - Fore"
	icon_state = "SolarcontrolA"
	sound_env = SMALL_ENCLOSED

/area/maintenance/portsolar
	name = "\improper Solar Maintenance - Aft Port"
	icon_state = "SolarcontrolP"
	sound_env = SMALL_ENCLOSED

/area/maintenance/starboardsolar
	name = "\improper Solar Maintenance - Aft Starboard"
	icon_state = "SolarcontrolS"
	sound_env = SMALL_ENCLOSED

// Teleporter

/area/teleporter
	name = "\improper Teleporter"
	icon_state = "teleporter"
	ambient_music_tags = list(MUSIC_TAG_SPACE)

/area/gateway
	name = "\improper Gateway"
	icon_state = "teleporter"
	ambient_music_tags = list(MUSIC_TAG_SPACE)

// MedBay

/area/medical/medbay
	name = "\improper Medbay Hallway - Port"
	icon_state = "medbay"

// Medbay is a large area, these additional areas help level out APC load.
/area/medical/medbay2
	name = "\improper Medbay Hallway - Starboard"
	icon_state = "medbay2"

/area/medical/medbay3
	name = "\improper Medbay Hallway - Fore"
	icon_state = "medbay3"

/area/medical/medbay3/underground
	name = "\improper Underground Medbay Hallway - Fore"
	icon_state = "medbay3"

/area/medical/medbay4
	name = "\improper Medbay Hallway - Aft"
	icon_state = "medbay4"

/area/medical/medbay4/underground
	name = "\improper Underground Medbay Hallway - Aft"
	icon_state = "medbay4"

/area/medical/reception
	name = "\improper Medbay Reception"
	icon_state = "medbay"

/area/medical/psych
	name = "\improper Psych Room"
	icon_state = "medbay3"

/area/crew_quarters/medbreak
	name = "\improper Break Room"
	icon_state = "medbay3"

/area/medical/ward
	name = "\improper Recovery Ward"
	icon_state = "patients"

/area/medical/patient_a
	name = "\improper Isolation A"
	icon_state = "patients"

/area/medical/patient_b
	name = "\improper Isolation B"
	icon_state = "patients"

/area/medical/patient_c
	name = "\improper Isolation C"
	icon_state = "patients"

/area/medical/patient_d
	name = "\improper Isolation D"
	icon_state = "patients"

/area/medical/patient_wing
	name = "\improper Underground Patient Ward"
	icon_state = "patients"

/area/medical/patient_wing/garden
	name = "\improper Medbay Garden"
	icon_state = "patients"

/area/medical/patient_wing/washroom
	name = "\improper Patient Wing Washroom"

/area/medical/surgery2
	name = "\improper Operating Theatre 2"
	icon_state = "surgery"

/area/medical/surgery_storage
	name = "\improper Surgery Storage"
	icon_state = "surgery"

/area/medical/surgeryobs
	name = "\improper Operation Observation Room"
	icon_state = "surgery"

/area/medical/surgeryprep
	name = "\improper Pre-Op Prep Room"
	icon_state = "surgery"

/area/medical/cryo
	name = "\improper Cryogenics"
	icon_state = "cryo"

/area/medical/med_toilet
	name = "\improper Medbay Toilets"
	icon_state = "medbay"

/area/medical/med_mech
	name = "\improper Medbay Mech Room"
	icon_state = "medbay3"

/area/medical/storage1
	name = "\improper Primary Storage"
	icon_state = "medbay4"

/area/medical/storage2
	name = "\improper Medbay Storage"
	icon_state = "medbay3"

/area/medical/resleever
	name = "\improper Neural Lace Resleever"
	icon_state = "cloning"

// Security

/area/security/main
	name = "\improper Security Office"
	icon_state = "security"

/area/security/briefingroom
	name = "\improper Security - Briefing Room"
	icon_state = "briefroom"

/area/security/storage
	name = "\improper Security Storage"
	icon_state = "brigstorage"

/area/security/execution
	name = "\improper Security - Execution Room"
	icon_state = "execution"

/area/security/evidence
	name = "\improper Security - Evidence Storage"
	icon_state = "evidence"

/area/security/brigmorgue
	name = "\improper Security - Morgue"
	icon_state = "brigmorgue"

/area/security/brigswstorage
	name = "\improper Security - S-W Storage"
	icon_state = "brigswstorage"

/area/security/meeting
	name = "\improper Security Meeting Room"
	icon_state = "security"

/area/security/lobby
	name = "\improper Security Lobby"
	icon_state = "security"

/area/security/brig/processing
	name = "\improper Security - Processing Room 1"
	icon_state = "proc1"

/area/security/brig/processing2
	name = "\improper Security - Processing Room 2"
	icon_state = "proc2"

/area/security/brig/interrogation
	name = "\improper Security - Interrogation"
	icon_state = "interrogation"

/area/security/brig/solitaryA
	name = "\improper Security - Solitary 1"
	icon_state = "sec_prison"

/area/security/brig/solitaryB
	name = "\improper Security - Solitary 2"
	icon_state = "sec_prison"

/area/security/brig/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.icon_state = temp_closet.icon_closed
	for(var/obj/machinery/door_timer/temp_timer in src)
		temp_timer.releasetime = 1
	..()

/area/security/prison/restroom
	name = "\improper Security - Prison Wing Restroom"
	icon_state = "sec_prison"

/area/security/prison/dorm
	name = "\improper Security - Prison Wing Dormitory"
	icon_state = "sec_prison"

/area/security/prison/monitoring
	name = "\improper Security - Prison Wing Monitoring"

/area/security/prison/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.icon_state = temp_closet.icon_closed
	for(var/obj/machinery/door_timer/temp_timer in src)
		temp_timer.releasetime = 1
	..()

/area/security/warden
	name = "\improper Security - Warden's Office"
	icon_state = "Warden"

/area/security/tactical
	name = "\improper Security - Tactical Equipment"
	icon_state = "Tactical"

/area/security/vacantoffice
	name = "\improper Vacant Office"
	icon_state = "security"

/area/security/nuke_storage
	name = "\improper Vault"
	icon_state = "nuke_storage"

/area/security/checkpoint2
	name = "\improper Command Security - Checkpoint"
	icon_state = "checkpoint1"

/area/quartermaster
	name = "\improper Quartermasters"
	icon_state = "quart"

/area/quartermaster/breakroom
	name = "\improper Cargo Break Room"
	icon_state = "cargobreak"

/area/quartermaster/storage
	name = "\improper Warehouse"
	icon_state = "quartstorage"
	sound_env = LARGE_ENCLOSED

/area/quartermaster/storage/under
	name = "\improper Underground Cargo Warehouse"
	icon_state = "cargounder"

/area/quartermaster/storage/under/secure
	name = "\improper Underground Cargo Storage"
	icon_state = "cargounderstorage"

/area/quartermaster/qm
	name = "\improper Cargo - Quartermaster's Office"
	icon_state = "quart"

/area/quartermaster/miningdock
	name = "\improper Cargo Mining Dock"
	icon_state = "mining"

/area/quartermaster/office
	name = "\improper Supply Office"
	icon_state = "quartoffice"

/area/hydroponics
	name = "\improper Hydroponics"
	icon_state = "hydro"

/area/hydroponics/garden
	name = "\improper Garden"
	icon_state = "garden"

/area/hydroponics/lower
	name = "\improper Lower Hydroponics"
	icon_state = "garden"

/area/hydroponics/biodome
	name = "\improper Central Biodome"
	icon_state = "garden"

// Research
/area/rnd/docking
	name = "\improper Research Dock"
	icon_state = "research_dock"

/area/assembly/robotics
	name = "\improper Robotics Lab"
	icon_state = "robotics"

/area/assembly/chargebay
	name = "\improper Mech Bay"
	icon_state = "mechbay"

/area/rnd/lab
	name = "\improper Research Lab"
	icon_state = "toxlab"

/area/rnd/misc_lab
	name = "\improper Miscellaneous Research"
	icon_state = "toxmisc"

/area/rnd/mixing
	name = "\improper Toxins Mixing Room"
	icon_state = "toxmix"

/area/rnd/storage
	name = "\improper Toxins Storage"
	icon_state = "toxstorage"

/area/rnd/test_area
	name = "\improper Toxins Test Area"
	icon_state = "toxtest"

/area/server
	name = "\improper Research Server Room"
	icon_state = "server"
	ambient_music_tags = list(MUSIC_TAG_SPACE)

/area/rnd/research_under
	name = "\improper Underground Research Wing"
	icon_state = "uresearch"

/area/rnd/research_under/breakroom
	name = "\improper Underground Research Wing - Break Room"
	icon_state = "uresearchbreak"

/area/rnd/restroom
	name = "\improper Research Restroom"
	icon_state = "research"

/area/rnd/research
	name = "\improper Research and Development"
	icon_state = "research"

// Storage

/area/storage/art
	name = "Art Supply Storage"
	icon_state = "storage"

/area/storage/emergency
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/emergency2
	name = "Port Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/storage/tools
	name = "Auxiliary Tool Storage"
	icon_state = "auxstorage"

/area/storage/tech
	name = "Technical Storage"
	icon_state = "storage"

// HALF-BUILT STATION (REPLACES DERELICT IN BAYCODE, ABOVE IS LEFT FOR DOWNSTREAM)

/area/shuttle/constructionsite/site
	name = "\improper Construction Site Shuttle"
	base_turf = /turf/simulated/floor/asteroid

// AI

/area/turret_protected
	ambience_powered = list(SFX_AMBIENT_AI, SFX_AMBIENT_SCIENCE)

/area/turret_protected/ai
	name = "\improper AI Chamber"
	icon_state = "ai_chamber"
	ambience_powered = list(SFX_AMBIENT_AI)

/area/turret_protected/ai_server_room
	name = "Messaging Server Room"
	icon_state = "ai_server"
	sound_env = SMALL_ENCLOSED

/area/turret_protected/ai_cyborg_station
	name = "\improper Cyborg Station"
	icon_state = "ai_cyborg"
	sound_env = SMALL_ENCLOSED
	ambience_powered = list(SFX_AMBIENT_AI)

/area/turret_protected/ai_upload
	name = "\improper AI Upload Chamber"
	icon_state = "ai_upload"
	ambience_powered = list(SFX_AMBIENT_AI)

/area/turret_protected/ai_upload_foyer
	name = "\improper  AI Upload Access"
	icon_state = "ai_foyer"
	ambience_powered = list(SFX_AMBIENT_AI)
	sound_env = SMALL_ENCLOSED

/area/turret_protected/tcomsat/port
	name = "\improper Telecoms Satellite - Port"

/area/turret_protected/tcomsat/starboard
	name = "\improper Telecoms Satellite - Starboard"

/area/ai_monitored/storage/eva
	name = "\improper EVA Storage"
	icon_state = "eva"

// Misc

/area/alien
	name = "\improper Alien base"
	icon_state = "yellow"
	requires_power = 0
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)

// Telecommunications Satellite

/area/tcommsat
	ambient_music_tags = list(MUSIC_TAG_SPACE)
	ambience_powered = list(SFX_AMBIENT_AI, SFX_AMBIENT_COMMS)

/area/tcommsat/entrance
	name = "\improper Telecoms Teleporter"
	icon_state = "tcomsatentrance"

/area/turret_protected/tcomsat
	name = "\improper Telecoms Satellite"
	icon_state = "tcomsatlob"

/area/turret_protected/tcomfoyer
	name = "\improper Telecoms Foyer"
	icon_state = "tcomsatentrance"

/area/tcommsat/powercontrol
	name = "\improper Telecommunications Power Control"
	icon_state = "tcomsatwest"

/area/tcommsat/chamber
	name = "\improper Telecoms Central Compartment"
	icon_state = "tcomsatcham"

/area/tcommsat/computer
	name = "\improper Telecoms Control Room"
	icon_state = "tcomsatcomp"

/*******
* Moon *
*******/

// Mining main outpost

/area/outpost
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)

/area/outpost/mining_main
	icon_state = "outpost_mine_main"

/area/outpost/mining_main/east_hall
	name = "Mining Outpost East Hallway"

/area/outpost/mining_main/eva
	name = "Mining Outpost EVA storage"

/area/outpost/mining_main/dorms
	name = "Mining Outpost Dormitory"

/area/outpost/mining_main/medbay
	name = "Mining Outpost Medical"

/area/outpost/mining_main/refinery
	name = "Mining Outpost Refinery"

/area/outpost/mining_main/west_hall
	name = "Mining Outpost West Hallway"

/area/outpost/mining_main/mechbay
	name = "Mining Outpost Mech Bay"

// Mining outpost
/area/outpost/mining_main/maintenance
	name = "Mining Outpost Maintenance"

// Main Outpost
/area/outpost/main_outpost
	icon_state = "green"
	ambience_off = list(SFX_AMBIENT_OFF_GLOBAL, SFX_AMBIENT_OFF_MAINTENANCE)
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE, SFX_AMBIENT_OUTPOST)

/area/outpost/main_outpost/shallway
	name = "Outpost Southern Hallway"

/area/outpost/main_outpost/challway
	name = "Outpost Central Hallway"

/area/outpost/main_outpost/nhallway
	name = "Outpost Northern Hallway"

/area/outpost/main_outpost/dock
	name = "Outpost Dock"
	icon_state = "bluenew"

/area/outpost/main_outpost/dock/security
	name = "Outpost Security Dock"
	icon_state = "bluenew"

/area/outpost/security/shallway
	name = "Outpost Security Hallway"
	icon_state = "green"

/area/outpost/security/mining_main
	name = "Mining Outpost Prisoner Refinery"
	icon_state = "outpost_mine_main"

/area/outpost/security/dorms
	name = "Outpost Prison Dorm"
	icon_state = "blue2"

/area/outpost/security/prison
	name = "Outpost Prison"
	icon_state = "sec_prison"

/area/outpost/security/post
	name = "Outpost Security Post"
	icon_state = "brig"

/area/outpost/security/eva
	name = "Outpost Security EVA"
	icon_state = "brig"

/area/mine/explored/prison
	name = "Mine Prison"
	icon_state = "explored"

/area/outpost/main_outpost/infirmary
	name = "Outpost Infirmary"
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_SCIENCE, SFX_AMBIENT_OUTPOST)

/area/outpost/main_outpost/canteen
	name = "Outpost Canteen"
	icon_state = "kitchen"

/area/outpost/main_outpost/bar
	name = "Outpost Bar"
	icon_state = "bar"

/area/outpost/main_outpost/dorms
	name = "Outpost Living Quarters"
	icon_state = "blue2"

/area/outpost/main_outpost/dorms/substation
	name = "Outpost Living Quarters Substation"

/area/outpost/main_outpost/dorms/proom1
	name = "Outpost Private Room One"

/area/outpost/main_outpost/dorms/proom2
	name = "Outpost Private Room Two"

/area/outpost/main_outpost/dorms/proom3
	name = "Outpost Private Room Three"

/area/outpost/main_outpost/dorms/proom4
	name = "Outpost Private Room Four"

// Small outposts
/area/outpost/mining_north
	name = "North Mining Outpost"
	icon_state = "outpost_mine_north"
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE, SFX_AMBIENT_OUTPOST)

/area/outpost/mining_west
	name = "West Mining Outpost"
	icon_state = "outpost_mine_west"
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE, SFX_AMBIENT_OUTPOST)

/area/outpost/abandoned
	name = "Abandoned Outpost"
	icon_state = "dark"

/area/outpost/abandonedpost
	name = "Abandoned Post"
	icon_state = "dark"

/area/outpost/prydwen
	name = "NSC Prydwen"
	icon_state = "green"

// Engineering outpost

/area/outpost/engineering
	icon_state = "outpost_engine"
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE, SFX_AMBIENT_ENGINEERING)

/area/outpost/engineering/atmospherics
	name = "Engineering Outpost Atmospherics"

/area/outpost/engineering/hallway
	name = "Engineering Outpost Hallway"

/area/outpost/engineering/power
	name = "Engineering Outpost Power Distribution"

/area/outpost/engineering/telecomms
	name = "Engineering Outpost Telecommunications"

/area/outpost/engineering/storage
	name = "Engineering Outpost Storage"

/area/outpost/engineering/meeting
	name = "Engineering Outpost Meeting Room"

// Research Outpost
/area/outpost/research
	icon_state = "outpost_research"

/area/outpost/research/hallway
	name = "Research Outpost Hallway"

/area/outpost/research/dock
	name = "Research Outpost Shuttle Dock"

/area/outpost/research/eva
	name = "Research Outpost EVA"

/area/outpost/research/analysis
	name = "Research Outpost Sample Analysis"

/area/outpost/research/chemistry
	name = "Research Outpost Chemistry"

/area/outpost/research/medical
	name = "Research Outpost Medical"

/area/outpost/research/power
	name = "Research Outpost Maintenance"

/area/outpost/research/isolation_a
	name = "Research Outpost Isolation A"

/area/outpost/research/isolation_b
	name = "Research Outpost Isolation B"

/area/outpost/research/isolation_c
	name = "Research Outpost Isolation C"

/area/outpost/research/isolation_monitoring
	name = "Research Outpost Isolation Monitoring"

/area/outpost/research/lab
	name = "Research Outpost Laboratory"

/area/outpost/research/emergency_storage
	name = "Research Outpost Emergency Storage"

/area/outpost/research/anomaly_storage
	name = "Research Outpost Anomalous Storage"

/area/outpost/research/anomaly_analysis
	name = "Research Outpost Anomaly Analysis"

/area/outpost/research/kitchen
	name = "Research Outpost Kitchen"

/area/outpost/research/disposal
	name = "Research Outpost Waste Disposal"

/area/outpost/research/brainstorm
	name = "Research Outpost Brainstorm Room"

/area/construction
	name = "\improper Engineering Construction Area"
	icon_state = "yellow"

// CentComm
/area/centcom/control
	name = "\improper Centcom Control"

/area/tdome
	name = "\improper Thunderdome"
	icon_state = "thunder"
	requires_power = 0
	dynamic_lighting = 0
	sound_env = ARENA

/area/centcom/museum
	name = "\improper Museum"
	icon_state = "museum"

// Thunderdr
/area/tdome/tdome1
	name = "\improper Thunderdome (Team 1)"
	icon_state = "green"

/area/tdome/tdome2
	name = "\improper Thunderdome (Team 2)"
	icon_state = "yellow"

/area/tdome/tdomeadmin
	name = "\improper Thunderdome (Admin.)"
	icon_state = "purple"

/area/tdome/tdomeobserve
	name = "\improper Thunderdome (Observer.)"
	icon_state = "purple"

/area/holodeck
	name = "\improper Holodeck"
	icon_state = "Holodeck"
	requires_power = FALSE
	dynamic_lighting = FALSE
	sound_env = LARGE_ENCLOSED

/area/prison/solitary
	name = "Solitary Confinement"
	icon_state = "brig"

/area/security/range
	name = "\improper Security - Firing Range"
	icon_state = "firingrange"

/area/mine
	icon_state = "mining"
	sound_env = 5 // stoneroom
	ambience_off = list(SFX_AMBIENT_MINE)
	ambience_powered = list(SFX_AMBIENT_MINE)
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)

/area/mine/explored
	name = "Mine"
	icon_state = "explored"

/area/mine/unexplored
	name = "Mine"
	icon_state = "unexplored"

/area/mine/unexplored/medium
	name = "Medium mine"
	icon_state = "unexplored_medium"

/area/mine/unexplored/deep
	name = "Deep mine"
	icon_state = "unexplored_deep"

/area/constructionsite
	name = "\improper Construction Site"
	icon_state = "yellow"
	has_gravity = FALSE

/area/constructionsite/maintenance
	name = "\improper Construction Site Maintenance"
	icon_state = "yellow"

/area/constructionsite/bridge
	name = "\improper Construction Site Bridge"
	icon_state = "bridge"

/area/constructionsite/hallway/fore
	name = "\improper Construction Site Fore Hallway"
	icon_state = "hallS"

/area/constructionsite/storage
	name = "\improper Construction Site Storage Area"

/area/constructionsite/medical
	name = "\improper Construction Site Medbay"
	icon_state = "medbay"

/area/constructionsite/engineering
	name = "\improper Construction Site Engine Bay"
	icon_state = "engine"

/area/solar/constructionsite
	name = "\improper Construction Site Solars"
	icon_state = "aft"

/area/constructionsite/teleporter
	name = "Construction Site Teleporter"
	icon_state = "yellow"

/area/constructionsite/ai
	name = "\improper Construction Computer Core"
	icon_state = "ai"

/area/constructionsite/hallway/aft
	name = "\improper Construction Site Aft Hallway"
	icon_state = "hallP"

/area/maintenance/auxsolarstarboard
	name = "Solar Maintenance - Fore Starboard"
	icon_state = "SolarcontrolS"

/area/maintenance/incinerator
	name = "\improper Incinerator"
	icon_state = "disposal"

/area/maintenance/auxsolarport
	name = "Solar Maintenance - Fore Port"
	icon_state = "SolarcontrolP"

/area/derelict/ship
	name = "\improper Abandoned Ship"
	icon_state = "yellow"

/area/derelict/snowasteroid
	name = "\improper Hidden Outpost"
	icon_state = "yellow"
	has_gravity = TRUE

/area/derelict/snowasteroid/bunker
	name = "\improper Hidden Outpost Bunker"
	icon_state = "red"
	has_gravity = TRUE

/area/derelict/snowasteroid/shuttle
	name = "\improper Hidden Outpost Shuttle"
	icon_state = "blue"
	has_gravity = TRUE

/area/derelict/djstation
	name = "\improper DJ Station"
	icon_state = "yellow"
	has_gravity = TRUE

/area/AIsattele
	name = "\improper AI Satellite Teleporter Room"
	icon_state = "teleporter"
	ambience_powered = list(SFX_AMBIENT_AI)
	has_gravity = FALSE
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)

/area/constructionsite/atmospherics
	name = "\improper Construction Site Atmospherics"
	icon_state = "green"

/area/supply
	name = "Supply Shuttle"
	icon_state = "shuttle3"

/area/supply/dock
	name = "Supply Shuttle"
	icon_state = "shuttle3"
	requires_power = 0

/area/supply/station
	name = "Supply Shuttle"
	icon_state = "shuttle3"
	requires_power = 0

/area/security/armory
	name = "\improper Security - Armory"
	icon_state = "armory"

/area/security/detectives_office
	name = "\improper Security - Forensic Office"
	icon_state = "detective"
	sound_env = MEDIUM_SOFTFLOOR

/area/shuttle/escape_pod1/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod2/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod3/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod5/centcom
	icon_state = "shuttle"

/area/centcom/evac
	name = "\improper Centcom Emergency Shuttle"

/area/centcom/ferry
	name = "\improper Centcom Transport Shuttle"

/area/centcom/living
	name = "\improper Centcom Living Quarters"

/area/centcom/suppy
	name = "\improper Centcom Supply Shuttle"

/area/centcom/test
	name = "\improper Centcom Testing Facility"

/area/centcom/creed
	name = "Creed's Office"

/area/acting/stage
	name = "\improper Stage"
	dynamic_lighting = 0
	requires_power = 0
	icon_state = "yellow"

/area/merchant_station
	name = "\improper Merchant Station"
	icon_state = "LP"
	requires_power = 0

/area/thunder_rock
	name = "\improper Thunder Rock"
	icon_state = "LP"
	luminosity = 1
	dynamic_lighting = 0
	requires_power = 0

/area/acting/backstage
	name = "\improper Backstage"
	luminosity = 1
	dynamic_lighting = 0
	requires_power = 0

/area/solar/auxstarboard
	name = "\improper Fore Starboard Solar Array"
	icon_state = "panelsA"
