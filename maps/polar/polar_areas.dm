/area/polarplanet
	name = "polarplanet"
	base_turf = /turf/simulated/floor/natural/frozenground

/area/polarplanet/street
	name = "Polarplanet - street"
	environment_type = ENVIRONMENT_OUTSIDE
	always_unpowered = TRUE

// Security

/area/polarplanet/security/armory_lobby
	name = "\improper Security Lobby"
	icon_state = "brig"

/area/polarplanet/security/sec_locker
	name = "\improper Security Locker Room"
	icon_state = "brig"

/area/polarplanet/security/brig/solitary
	name = "Solitary Confinement"
	icon_state = "brig"

// Chapel

/area/polarplanet/chapel/main/mass_driver
	name = "\improper Chapel Funeral Hall"
	icon_state = "chapel"

// Engineering

/area/polarplanet/engineering/singularity
	name = "\improper Singularity Generator"
	icon_state = "engine"

// SHUTTLES
// Shuttle areas must contain at least two areas in a subgroup if you want to move a shuttle from one place to another.
// Look at escape shuttle for example.
// All shuttles should now be under shuttle since we have smooth-wall code.
/area/polarplanet/shuttle/administration/centcom
	name = "\improper Administration Shuttle"
	icon_state = "shuttlered"
	base_turf = /turf/unsimulated/floor

/area/polarplanet/shuttle/administration/station
	name = "\improper Administration Shuttle"
	icon_state = "shuttlered2"
	base_turf = /turf/simulated/floor/plating

/area/polarplanet/shuttle/supply/elevator/upper
	name = "Cargo Elevator Upper Deck"
	base_turf = /turf/simulated/open

/area/polarplanet/shuttle/supply/elevator/lower
	name = "Cargo Elevator Lower Deck"
	base_turf = /turf/simulated/floor/plating

/area/polarplanet/shuttle/merchant
	icon_state = "shuttlegrn"

/area/polarplanet/shuttle/merchant/home
	name = "\improper Merchant Van - Home"
	base_turf = /turf/space

/area/polarplanet/shuttle/merchant/transit
	icon_state = "shuttlegrn"
	base_turf = /turf/space/transit/south

/area/polarplanet/shuttle/merchant/dock
	name = "\improper Merchant Van - Planet Landing Site"
	environment_type = ENVIRONMENT_OUTSIDE
	base_turf = /turf/simulated/floor/natural/frozenground

// Command
/area/polarplanet/crew_quarters/heads/chief
	name = "\improper Engineering - CE's Office"

/area/polarplanet/crew_quarters/heads/hos
	name = "\improper Security - HoS' Office"

/area/polarplanet/crew_quarters/heads/hop
	name = "\improper Command - HoP's Office"

/area/polarplanet/crew_quarters/heads/hor
	name = "\improper Research - RD's Office"

/area/polarplanet/crew_quarters/heads/cmo
	name = "\improper Command - CMO's Office"

/area/polarplanet/bridge
	name = "\improper Bridge"
	icon_state = "bridge"

/area/polarplanet/bridge/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	sound_env = MEDIUM_SOFTFLOOR

/area/polarplanet/bridge/meeting_room/cafe
	name = "\improper Heads of Staff Cafeteria"

// Shuttles

/area/polarplanet/shuttle/deathsquad/centcom
	name = "Deathsquad Shuttle"
	area_flags = AREA_FLAG_RAD_SHIELDED
	base_turf = /turf/space

/area/polarplanet/shuttle/deathsquad/transit
	name = "Deathsquad Shuttle Internim"
	area_flags = AREA_FLAG_RAD_SHIELDED
	base_turf = /turf/space/transit/east

/area/polarplanet/shuttle/deathsquad/station
	name = "Deathsquad Shuttle Station"
	base_turf = /turf/simulated/floor/natural/frozenground
	environment_type = ENVIRONMENT_OUTSIDE

/area/polarplanet/shuttle/administration
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/polarplanet/shuttle/syndicate_elite
	name = "\improper Syndicate Elite Shuttle"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/polarplanet/shuttle/arrival
	name = "\improper Arrival Shuttle"

/area/polarplanet/shuttle/arrival/station
	icon_state = "shuttle"

/area/polarplanet/shuttle/escape/centcom
	name = "\improper Emergency Shuttle Centcom"
	icon_state = "shuttle"
	base_turf = /turf/space

/area/polarplanet/shuttle/escape
	name = "\improper Emergency Shuttle"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/polarplanet/shuttle/escape/station
	name = "\improper Emergency Shuttle Station"
	icon_state = "shuttle2"
	base_turf = /turf/simulated/floor/plating

/area/polarplanet/shuttle/escape/transit // the area/polarplanet to pass through for 3 minute transit
	name = "\improper Emergency Shuttle Transit"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

/area/polarplanet/shuttle/administration/transit
	name = "Administration Shuttle Transit"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/east

// SYNDICATES

/area/polarplanet/syndicate_mothership
	name = "\improper Syndicate Base"
	icon_state = "syndie-ship"
	requires_power = 0
	dynamic_lighting = 0

/area/polarplanet/syndicate_mothership/ninja
	name = "\improper Ninja Base"
	requires_power = 0
	base_turf = /turf/space/transit/north

// RESCUE

// names are used
/area/polarplanet/rescue_base
	name = "\improper Response Team Base"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = 1
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/polarplanet/rescue_base/base
	name = "\improper Barracks"
	icon_state = "yellow"
	dynamic_lighting = 0

/area/polarplanet/rescue_base/start
	name = "\improper Response Team Base"
	icon_state = "shuttlered"
	base_turf = /turf/unsimulated/floor

/area/polarplanet/rescue_base/southwest
	name = "south west"
	icon_state = "southwest"
	base_turf = /turf/simulated/floor/natural/frozenground
	environment_type = ENVIRONMENT_OUTSIDE

/area/polarplanet/rescue_base/northwest
	name = "north west"
	icon_state = "northwest"
	base_turf = /turf/simulated/floor/natural/frozenground
	environment_type = ENVIRONMENT_OUTSIDE

/area/polarplanet/rescue_base/northeast
	name = "north east"
	icon_state = "northeast"
	base_turf = /turf/simulated/floor/natural/frozenground
	environment_type = ENVIRONMENT_OUTSIDE

/area/polarplanet/rescue_base/southeast
	name = "south east"
	icon_state = "southeast"
	base_turf = /turf/simulated/floor/natural/frozenground
	environment_type = ENVIRONMENT_OUTSIDE

/area/polarplanet/rescue_base/transit
	name = "\proper bluespace"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

// MINING MOTHERSHIP

/area/polarplanet/creaker
	name = "\improper Mining Ship 'Creaker'"
	icon_state = "yellow"
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/polarplanet/creaker/station
	name = "\improper Mining Ship 'Creaker'"
	icon_state = "shuttlered"

/area/polarplanet/creaker/north
	name = "northern asteroid field"
	icon_state = "southwest"

/area/polarplanet/creaker/west
	name = "western asteroid field"
	icon_state = "northwest"

/area/polarplanet/creaker/east
	name = "eastern asteroid field"
	icon_state = "northeast"

// ENEMY

// names are used
/area/polarplanet/syndicate_station
	name = "\improper Independant Station"
	icon_state = "yellow"
	requires_power = 0
	area_flags = AREA_FLAG_RAD_SHIELDED

/area/polarplanet/syndicate_station/start
	name = "\improper Syndicate Forward Operating Base"
	icon_state = "yellow"
	base_turf = /turf/space

/area/polarplanet/syndicate_station/southwest
	name = "south west"
	icon_state = "southwest"
	environment_type = ENVIRONMENT_OUTSIDE
	base_turf = /turf/simulated/floor/natural/frozenground

/area/polarplanet/syndicate_station/northwest
	name = "north west"
	icon_state = "northwest"
	environment_type = ENVIRONMENT_OUTSIDE
	base_turf = /turf/simulated/floor/natural/frozenground

/area/polarplanet/syndicate_station/northeast
	name = "north east"
	icon_state = "northeast"
	environment_type = ENVIRONMENT_OUTSIDE
	base_turf = /turf/simulated/floor/natural/frozenground

/area/polarplanet/syndicate_station/southeast
	name = "south east"
	icon_state = "southeast"
	environment_type = ENVIRONMENT_OUTSIDE
	base_turf = /turf/simulated/floor/natural/frozenground

/area/polarplanet/syndicate_station/transit
	name = "\proper bluespace"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

/area/polarplanet/shuttle/syndicate_elite/northwest
	icon_state = "northwest"
	base_turf = /turf/simulated/floor/natural/frozenground
	environment_type = ENVIRONMENT_OUTSIDE

/area/polarplanet/shuttle/syndicate_elite/northeast
	icon_state = "northeast"
	base_turf = /turf/simulated/floor/natural/frozenground
	environment_type = ENVIRONMENT_OUTSIDE

/area/polarplanet/shuttle/syndicate_elite/southwest
	icon_state = "southwest"
	base_turf = /turf/simulated/floor/natural/frozenground
	environment_type = ENVIRONMENT_OUTSIDE

/area/polarplanet/shuttle/syndicate_elite/southeast
	icon_state = "southeast"
	base_turf = /turf/simulated/floor/natural/frozenground
	environment_type = ENVIRONMENT_OUTSIDE

/area/polarplanet/shuttle/syndicate_elite/transit
	name = "\proper bluespace"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

/area/polarplanet/skipjack_station
	name = "\improper Skipjack"
	icon_state = "yellow"
	requires_power = 0
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)
	base_turf = /turf/space

/area/polarplanet/skipjack_station/southwest
	name = "south west"
	icon_state = "southwest"
	base_turf = /turf/simulated/floor/natural/frozenground
	environment_type = ENVIRONMENT_OUTSIDE

/area/polarplanet/skipjack_station/northwest
	name = "north west"
	icon_state = "northwest"
	base_turf = /turf/simulated/floor/natural/frozenground
	environment_type = ENVIRONMENT_OUTSIDE

/area/polarplanet/skipjack_station/northeast
	name = "north east"
	icon_state = "northeast"
	base_turf = /turf/simulated/floor/natural/frozenground
	environment_type = ENVIRONMENT_OUTSIDE

/area/polarplanet/skipjack_station/southeast
	name = "south east"
	icon_state = "southeast"
	base_turf = /turf/simulated/floor/natural/frozenground
	environment_type = ENVIRONMENT_OUTSIDE

/area/polarplanet/skipjack_station/base
	name = "Raider Base"
	icon_state = "yellow"
	base_turf = /turf/simulated/floor/asteroid

/area/polarplanet/skipjack_station/start
	name = "\improper Skipjack"
	icon_state = "shuttlered"
	base_turf = /turf/space

/area/polarplanet/skipjack_station/transit
	name = "Skipjack Transit"
	icon_state = "shuttle"
	base_turf = /turf/space/transit/north

// Train

/area/polarplanet/shuttle/train/station
	name = "Pathos I - Train Station"
	icon_state = "shuttle2"
	base_turf = /turf/simulated/open
	environment_type = ENVIRONMENT_ROOM
	ambient_music_tags = list(MUSIC_TAG_NORMAL, MUSIC_TAG_SPACE)

/area/polarplanet/shuttle/train/transit
	name = "Pathos I - Train Transit"
	icon_state = "shuttle"
	base_turf = /turf/simulated/floor/plating
	environment_type = ENVIRONMENT_ROOM
	ambient_music_tags = list(MUSIC_TAG_NORMAL, MUSIC_TAG_SPACE)

/area/polarplanet/shuttle/train/dock
	name = "Pathos I - Train Dock"
	icon_state = "shuttle2"
	base_turf = /turf/simulated/floor/plating
	environment_type = ENVIRONMENT_ROOM
	ambient_music_tags = list(MUSIC_TAG_NORMAL, MUSIC_TAG_SPACE)

// SUBSTATIONS (Subtype of maint, that should let them serve as shielded area/polarplanet during radstorm)

/area/polarplanet/maintenance/substation
	name = "Substation"
	icon_state = "substation"
	sound_env = SMALL_ENCLOSED

/area/polarplanet/maintenance/substation/command // AI and central cluster. This one will be between HoP office and meeting room (probably).
	name = "Command Substation"

/area/polarplanet/maintenance/substation/engineering // Probably will be connected to engineering SMES room, as wires cannot be crossed properly without them sharing powernets.
	name = "Engineering Substation"

/area/polarplanet/maintenance/substation/medical // Medbay
	name = "Medical Substation"

/area/polarplanet/maintenance/substation/research // Research
	name = "Research Substation"

/area/polarplanet/maintenance/substation/civilian_east // Bar, kitchen, dorms, ...
	name = "Civilian East Substation"

/area/polarplanet/maintenance/substation/civilian_west // Cargo, PTS, locker room, probably arrivals, ...)
	name = "Civilian West Substation"

/area/polarplanet/maintenance/substation/security // Security, Brig, Permabrig, etc.
	name = "Security Substation"

/area/polarplanet/maintenance/substation/atmospherics
	name = "Atmospherics Substation"

/area/polarplanet/maintenance/substation/cargo
	name = "Cargo Substation"

/area/polarplanet/maintenance/substation/starport
	name = "Starport Substation"

/area/polarplanet/maintenance/substation/hydro
	name = "Hydroponics Substation"

/area/polarplanet/maintenance/substation/emergency
	name = "Emergency Substation"

// Maintenance
/area/polarplanet/maintenance/fsmaint2
	name = "\improper Fore Starboard Maintenance - 2"
	icon_state = "fsmaint"

/area/polarplanet/maintenance/disposal
	name = "\improper Trash Disposal"
	icon_state = "disposal"

/area/polarplanet/maintenance/ghetto_medbay
	name = "\improper Ghetto Medbay"
	icon_state = "ghettomedbay"

/area/polarplanet/maintenance/ghetto_minicasino
	name = "\improper Ghetto Mini Casino"
	icon_state = "ghettominicasino"

/area/polarplanet/maintenance/ghetto_rnd
	name = "\improper Ghetto RnD"
	icon_state = "ghettornd"

/area/polarplanet/maintenance/ghetto_janitor
	name = "\improper Ghetto Janitor Room"
	icon_state = "ghettojanitor"

/area/polarplanet/maintenance/ghetto_virology
	name = "\improper Ghetto Virology"
	icon_state = "ghettovirology"

/area/polarplanet/maintenance/ghetto_shop
	name = "\improper Ghetto Shop"
	icon_state = "ghettoshop"

/area/polarplanet/maintenance/ghetto_bar
	name = "\improper Ghetto Bar"
	icon_state = "ghettobar"

/area/polarplanet/maintenance/ghetto_library
	name = "\improper Ghetto Library"
	icon_state = "ghettolibrary"

/area/polarplanet/maintenance/ghetto_toilet
	name = "\improper Underground Toilets"
	icon_state = "ghettotoilets"

/area/polarplanet/maintenance/ghetto_dorm
	name = "\improper Abandoned Dorm"
	icon_state = "ghettodorm"

/area/polarplanet/maintenance/ghetto_main
	name = "\improper Underground Main"
	icon_state = "ghettomain"

/area/polarplanet/maintenance/ghetto_main_south
	name = "\improper Underground Main - South"
	icon_state = "ghettomainsouth"

/area/polarplanet/maintenance/ghetto_main_west
	name = "\improper Underground Main - West"
	icon_state = "ghettomainsouth"

/area/polarplanet/maintenance/ghetto_eva
	name = "\improper Ghetto EVA"
	icon_state = "ghettoeva"

/area/polarplanet/maintenance/ghetto_eva_maint
	name = "\improper Ghetto EVA Maintenance"
	icon_state = "ghettoevamaint"

/area/polarplanet/maintenance/ghetto_casino
	name = "\improper Ghetto Casino"
	icon_state = "ghettocasino"

/area/polarplanet/maintenance/ghetto_syndie
	name = "\improper Ghetto Syndie"
	icon_state = "ghettosyndie"

/area/polarplanet/maintenance/ghetto_dockhall
	name = "\improper Underground Dock Hall"
	icon_state = "ghettodockhall"

/area/polarplanet/maintenance/ghetto_cafe
	name = "\improper Underground Cafe"
	icon_state = "ghettocafe"

/area/polarplanet/maintenance/ghetto_strangeplace
	name = "\improper Underground Bar"
	icon_state = "ghettostrangeplace"

/area/polarplanet/maintenance/ghetto_detective
	name = "\improper Abandoned Detective's Office"
	icon_state = "ghettodetective"

/area/polarplanet/maintenance/underground/central_one
	name = "\improper Underground Central Primary Hallway SE"
	icon_state = "uhall1"

/area/polarplanet/maintenance/underground/central_two
	name = "\improper Underground Central Primary Hallway SW"
	icon_state = "uhall2"

/area/polarplanet/maintenance/underground/central_three
	name = "\improper Underground Central Primary Hallway NW"
	icon_state = "uhall3"

/area/polarplanet/maintenance/underground/central_four
	name = "\improper Underground Central Primary Hallway NE"
	icon_state = "uhall4"

/area/polarplanet/maintenance/underground/central_five
	name = "\improper Underground Central Primary Hallway E"
	icon_state = "uhall5"

/area/polarplanet/maintenance/underground/central_six
	name = "\improper Underground Central Primary Hallway N"
	icon_state = "uhall6"

/area/polarplanet/maintenance/underground/cargo
	name = "\improper Underground Cargo Maintenance"
	icon_state = "ucargo"

/area/polarplanet/maintenance/underground/atmospherics
	name = "\improper Underground Atmospherics Maintenance"
	icon_state = "uatmos"


/area/polarplanet/maintenance/underground/arrivals
	name = "\improper Underground Arrivals Maintenance"
	icon_state = "uarrival"

/area/polarplanet/maintenance/underground/locker_room
	name = "\improper Underground Locker Room Maintenance"
	icon_state = "ulocker"

/area/polarplanet/maintenance/underground/EVA
	name = "\improper Underground EVA Maintenance"
	icon_state = "uEVA"

/area/polarplanet/maintenance/underground/security
	name = "\improper Underground Security Maintenance"
	icon_state = "usecurity"

/area/polarplanet/maintenance/underground/security_west
	name = "\improper Underground Security Maintenance - West"
	icon_state = "usecuritywest"

/area/polarplanet/maintenance/underground/security_port
	name = "\improper Underground Security Port Maintenance"
	icon_state = "usecurityport"

/area/polarplanet/maintenance/underground/security_main
	name = "\improper Underground Security Main Maintenance"
	icon_state = "usecuritymain"

/area/polarplanet/maintenance/underground/security_lobby
	name = "\improper Underground Security Lobby Maintenance"
	icon_state = "usecuritylobby"

/area/polarplanet/maintenance/underground/security_firefighting
	name = "\improper Underground Security Tech Room"
	icon_state = "usecurityfirefighting"

/area/polarplanet/maintenance/underground/security_dorms
	name = "\improper Underground Security Dormitories"
	icon_state = "usecuritybreak"

/area/polarplanet/maintenance/underground/security_breakroom
	name = "\improper Underground Security Break Room"
	icon_state = "usecuritybreak"

/area/polarplanet/maintenance/underground/security_storage
	name = "\improper Underground Security Storage Room"
	icon_state = "usecuritystorage"

/area/polarplanet/maintenance/underground/security_mainhall
	name = "\improper Underground Security Main Hall"
	icon_state = "usecuritylobby"

/area/polarplanet/maintenance/underground/security_hallway
	name = "\improper Underground Security Hallway"
	icon_state = "usecurityhall"

/area/polarplanet/maintenance/underground/security_meeting
	name = "\improper Underground Security Meeting Maintenance"
	icon_state = "usecuritymeeting"

/area/polarplanet/maintenance/underground/engineering
	name = "\improper Underground Engineering Maintenance"
	icon_state = "uengineering"

/area/polarplanet/maintenance/underground/engineering_lower
	name = "\improper Underground Engineering"
	icon_state = "uengineering"

/area/polarplanet/maintenance/underground/research
	name = "\improper Underground Research Maintenance"
	icon_state = "uresearch"

/area/polarplanet/maintenance/underground/robotics_lab
	name = "\improper Underground Robotics Lab Maintenance"
	icon_state = "urobotics"

/area/polarplanet/maintenance/underground/research_port
	name = "\improper Underground Research Port Maintenance"
	icon_state = "uresearchport"

/area/polarplanet/maintenance/underground/research_shuttle
	name = "\improper Underground Research Shuttle Dock Maintenance"
	icon_state = "uresearchshuttle"

/area/polarplanet/maintenance/underground/research_utility_room
	name = "\improper Underground Utility Room"
	icon_state = "uresearchutilityroom"

/area/polarplanet/maintenance/underground/research_starboard
	name = "\improper Underground Research Maintenance - Starboard"
	icon_state = "uresearchstarboard"

/area/polarplanet/maintenance/underground/research_xenobiology
	name = "\improper Underground Research Xenobiology Maintenance"
	icon_state = "uresearchxeno"

/area/polarplanet/maintenance/underground/research_misc
	name = "\improper Underground Research Miscellaneous Maintenance"
	icon_state = "uresearchmisc"

/area/polarplanet/maintenance/underground/civilian_NE
	name = "\improper Underground Civilian NE Maintenance"
	icon_state = "ucivne"

/area/polarplanet/maintenance/underground/medbay
	name = "\improper Underground Medbay Maintenance"
	icon_state = "umedbay"

/area/polarplanet/maintenance/underground/medbay/south
	name = "\improper Underground Medbay Maintenance - South"
	icon_state = "umedbay"

/area/polarplanet/maintenance/underground/dormitories
	name = "\improper Underground Dormitories Maintenance"
	icon_state = "udorm"

/area/polarplanet/maintenance/underground/warehouse
	name = "\improper Underground Warehouse Maintenance"
	icon_state = "uwarehouse"

/area/polarplanet/maintenance/underground/vault
	name = "\improper Underground Vault Maintenance"
	icon_state = "uvault"

/area/polarplanet/maintenance/underground/tool_storage
	name = "\improper Underground Tool Storage Maintenance"
	icon_state = "utoolstorage"

/area/polarplanet/maintenance/underground/janitor
	name = "\improper Underground Custodial Closet Maintenance"
	icon_state = "ujanitor"

/area/polarplanet/maintenance/underground/vaccant_office
	name = "\improper Underground Vaccant Office Maintenance"
	icon_state = "uvaccant"

/area/polarplanet/maintenance/underground/engine
	name = "\improper Underground Engine Maintenance"
	icon_state = "uengine"

/area/polarplanet/maintenance/underground/incinerator
	name = "\improper Underground Incinerator Maintenance"
	icon_state = "uincinerator"

/area/polarplanet/maintenance/underground/port_primary_hallway
	name = "\improper Underground Port Primary Hallway Maintenance"
	icon_state = "uportprim"

/area/polarplanet/maintenance/underground/board_games_club
	name = "\improper Underground Board Games Club"
	icon_state = "uportprim"

/area/polarplanet/maintenance/underground/gateway
	name = "\improper Underground Gateway Maintenance"
	icon_state = "ugateway"

/area/polarplanet/maintenance/underground/fitness
	name = "\improper Underground Fitness Room Maintenance"
	icon_state = "ufitness"

/area/polarplanet/maintenance/underground/bar
	name = "\improper Underground Bar Maintenance"
	icon_state = "ubar"

/area/polarplanet/maintenance/underground/kitchen
	name = "\improper Underground Kitchen Maintenance"
	icon_state = "ukitchen"

/area/polarplanet/maintenance/underground/hydroponics
	name = "\improper Underground Hydroponics Maintenance"
	icon_state = "uhydro"

/area/polarplanet/maintenance/underground/library
	name = "\improper Underground Library Maintenance"
	icon_state = "ulibrary"

/area/polarplanet/maintenance/underground/starboard_primary_hallway
	name = "\improper Starboard Primary Hallway Maintenance"
	icon_state = "ustarboard"

/area/polarplanet/maintenance/underground/cloning_entrance
	name = "\improper Undefined area/polarplanet"
	icon_state = "dark"

/area/polarplanet/maintenance/underground/cloning_checkpoint
	name = "\improper Undefined area/polarplanet"
	icon_state = "dark"

/area/polarplanet/maintenance/underground/cloning_storage
	name = "\improper Undefined area/polarplanet"
	icon_state = "dark"

/area/polarplanet/maintenance/underground/cloning_lobby
	name = "\improper Undefined area/polarplanet"
	icon_state = "dark"

/area/polarplanet/maintenance/underground/cloning_laboratory
	name = "\improper Undefined area/polarplanet"
	icon_state = "dark"

/area/polarplanet/maintenance/underground/cloning_surgery
	name = "\improper Undefined area/polarplanet"
	icon_state = "dark"

/area/polarplanet/maintenance/underground/cloning_morgue
	name = "\improper Undefined area/polarplanet"
	icon_state = "dark"

/area/polarplanet/maintenance/underground/cloning_cells
	name = "\improper Undefined area/polarplanet"
	icon_state = "dark"

/area/polarplanet/maintenance/atmos_control
	name = "\improper Atmospherics Maintenance"
	icon_state = "fpmaint"

/area/polarplanet/maintenance/arrivals
	name = "\improper Arrivals Maintenance"
	icon_state = "maint_arrivals"

/area/polarplanet/maintenance/bar
	name = "\improper Bar Maintenance"
	icon_state = "maint_bar"

/area/polarplanet/maintenance/cargo
	name = "\improper Cargo Maintenance"
	icon_state = "maint_cargo"

/area/polarplanet/maintenance/engi_engine
	name = "\improper Engine Maintenance"
	icon_state = "maint_engine"

/area/polarplanet/maintenance/engi_shuttle
	name = "\improper Engineering Shuttle Access"
	icon_state = "maint_e_shuttle"

/area/polarplanet/maintenance/engineering
	name = "\improper Engineering Maintenance"
	icon_state = "maint_engineering"

/area/polarplanet/maintenance/evahallway
	name = "\improper EVA Maintenance"
	icon_state = "maint_eva"

/area/polarplanet/maintenance/dormitory
	name = "\improper Dormitory Maintenance"
	icon_state = "maint_dormitory"

/area/polarplanet/maintenance/library
	name = "\improper Library Maintenance"
	icon_state = "maint_library"

/area/polarplanet/maintenance/locker
	name = "\improper Locker Room Maintenance"
	icon_state = "maint_locker"

/area/polarplanet/maintenance/medbay
	name = "\improper Medbay Maintenance"
	icon_state = "maint_medbay"

/area/polarplanet/maintenance/bridge
	name = "\improper Bridge Maintenance"
	icon_state = "maint_eva"

/area/polarplanet/maintenance/bridge/west
	name = "\improper Bridge Maintenance - West"

/area/polarplanet/maintenance/bridge/east
	name = "\improper Bridge Maintenance - East"

/area/polarplanet/maintenance/research_port
	name = "\improper Research Maintenance - Port"
	icon_state = "maint_research_port"

/area/polarplanet/maintenance/research_shuttle
	name = "\improper Research Shuttle Dock Maintenance"
	icon_state = "maint_research_shuttle"

/area/polarplanet/maintenance/research_starboard
	name = "\improper Research Maintenance - Starboard"
	icon_state = "maint_research_starboard"

/area/polarplanet/maintenance/security_port
	name = "\improper Security Maintenance - Port"
	icon_state = "maint_security_port"

/area/polarplanet/maintenance/security_starboard
	name = "\improper Security Maintenance - Starboard"
	icon_state = "maint_security_starboard"

/area/polarplanet/maintenance/exterior
	name = "\improper Exterior Reinforcements"
	icon_state = "maint_security_starboard"
	area_flags = AREA_FLAG_EXTERNAL & AREA_FLAG_NO_STATION
	has_gravity = FALSE
	turf_initializer = /decl/turf_initializer/maintenance/space

/area/polarplanet/maintenance/research_atmos
	name = "\improper Research Atmospherics Maintenance"
	icon_state = "maint_engineering"

/area/polarplanet/maintenance/medbay_north
	name = "\improper North Medbay Maintenance"
	icon_state = "maint_medbay"

/area/polarplanet/maintenance/hydro
	name = "\improper Hydroponics Maintenance"
	icon_state = "maint_medbay"

/area/polarplanet/maintenance/chapel
	name = "\improper Chapel Maintenance"
	icon_state = "maint_security_port"

/area/polarplanet/maintenance/chapel/north
	name = "\improper Chapel Maintenance - North"

/area/polarplanet/maintenance/chapel/south
	name = "\improper Chapel Maintenance - South"

/area/polarplanet/maintenance/abandoned_casino
	name = "\improper Abandoned Casino"
	icon_state = "ghettocasino"


/area/polarplanet/maintenance/getto_rnd
	name = "\improper RnD Maintenance"
	icon_state = "maint_cargo"

/area/polarplanet/maintenance/disposal/underground
	name = "Underground Waste Disposal"
	icon_state = "disposal"

// Dank Maintenance
/area/polarplanet/maintenance/sub
	turf_initializer = /decl/turf_initializer/maintenance/heavy

/area/polarplanet/maintenance/sub/relay_station
	name = "\improper Sublevel Maintenance - Relay Station"
	icon_state = "blue2"
	turf_initializer = null

/area/polarplanet/maintenance/sub/fore
	name = "\improper Sublevel Maintenance - Fore"
	icon_state = "sub_maint_fore"

/area/polarplanet/maintenance/sub/aft
	name = "\improper Sublevel Maintenance - Aft"
	icon_state = "sub_maint_aft"

/area/polarplanet/maintenance/sub/port
	name = "\improper Sublevel Maintenance - Port"
	icon_state = "sub_maint_port"

/area/polarplanet/maintenance/sub/starboard
	name = "\improper Sublevel Maintenance - Starboard"
	icon_state = "sub_maint_starboard"

/area/polarplanet/maintenance/sub/central
	name = "\improper Sublevel Maintenance - Central"
	icon_state = "sub_maint_central"

/area/polarplanet/maintenance/sub/command
	name = "\improper Sublevel Maintenance - Command"
	icon_state = "sub_maint_command"
	turf_initializer = null

// Hallway

/area/polarplanet/hallway/primary/
	sound_env = LARGE_ENCLOSED

/area/polarplanet/hallway/primary/fore
	name = "\improper Fore Primary Hallway"
	icon_state = "hallF"

/area/polarplanet/hallway/primary/starboard
	name = "\improper Starboard Primary Hallway"
	icon_state = "hallS"

/area/polarplanet/hallway/primary/aft
	name = "\improper Aft Primary Hallway"
	icon_state = "hallA"

/area/polarplanet/hallway/primary/port
	name = "\improper Port Primary Hallway"
	icon_state = "hallP"

/area/polarplanet/hallway/primary/seclobby
	name = "\improper Security Lobby"
	icon_state = "security"

/area/polarplanet/hallway/primary/englobby
	name = "\improper Engineering Foyer"
	icon_state = "engineering_foyer"

/area/polarplanet/hallway/primary/central_one
	name = "\improper Central Primary Hallway"
	icon_state = "hallC1"
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/hallway/primary/central_two
	name = "\improper Central Primary Hallway"
	icon_state = "hallC2"
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/hallway/primary/central_three
	name = "\improper Central Primary Hallway"
	icon_state = "hallC3"
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/hallway/primary/central_fore
	name = "\improper Central Primary Hallway"
	icon_state = "hallC3"
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/hallway/primary/central_fife
	name = "\improper Central Primary Hallway"
	icon_state = "hallC3"
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/hallway/primary/central_six
	name = "\improper Central Primary Hallway"
	icon_state = "hallC3"

/area/polarplanet/hallway/primary/central_seven
	name = "\improper Central Primary Hallway"
	icon_state = "hallC3"

/area/polarplanet/hallway/primary/frontier
	name = "\improper Central Hallway"
	icon_state = "hallC1"

/area/polarplanet/hallway/primary/frontier/ring_north
	name = "\improper Ring Hallway - North"
	icon_state = "hallF"

/area/polarplanet/hallway/primary/frontier/ring_south
	name = "\improper Ring Hallway - South"
	icon_state = "hallP"

/area/polarplanet/hallway/primary/frontier/central_mideast
	name = "\improper Central Hallway - Mideast"
	icon_state = "hallC2"

/area/polarplanet/hallway/primary/frontier/central_east
	name = "\improper Central Hallway - East"
	icon_state = "hallC2"

/area/polarplanet/hallway/primary/frontier/central_midwest
	name = "\improper Central Hallway - Midwest"
	icon_state = "hallC3"

/area/polarplanet/hallway/primary/frontier/central_west
	name = "\improper Central Hallway - West"
	icon_state = "hallC3"

/area/polarplanet/hallway/primary/frontier/brighall
	name = "\improper Brig Hallway"
	icon_state = "security"

/area/polarplanet/hallway/primary/frontier/dormhall
	name = "\improper Dormitory Hallway"
	icon_state = "Sleep"

/area/polarplanet/hallway/secondary/exit
	name = "\improper Escape Shuttle Hallway"
	icon_state = "escape"

/area/polarplanet/hallway/secondary/entry
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/hallway/secondary/entry/pods
	name = "\improper Arrival Shuttle Hallway - Escape Pods"
	icon_state = "entry_pods"

/area/polarplanet/hallway/secondary/entry/fore
	name = "\improper Arrival Shuttle Hallway - Fore"
	icon_state = "entry_1"

/area/polarplanet/hallway/secondary/entry/port
	name = "\improper Arrival Shuttle Hallway - Port"
	icon_state = "entry_2"
	base_turf = /turf/simulated/open

/area/polarplanet/hallway/secondary/entry/starboard
	name = "\improper Arrival Shuttle Hallway - Starboard"
	icon_state = "entry_3"

/area/polarplanet/hallway/secondary/entry/aft
	name = "\improper Arrival Shuttle Hallway - Aft"
	icon_state = "entry_4"

// Command

/area/polarplanet/crew_quarters/captain
	name = "\improper Command - Captain's Office"
	icon_state = "captain"
	sound_env = MEDIUM_SOFTFLOOR

// Crew


/area/polarplanet/crew_quarters
	name = "\improper Dormitories"
	icon_state = "Sleep"

/area/polarplanet/crew_quarters/locker
	name = "\improper Locker Room"
	icon_state = "locker"

/area/polarplanet/crew_quarters/toilet
	name = "\improper Dormitory Toilets"
	icon_state = "toilet"
	sound_env = SMALL_ENCLOSED

/area/polarplanet/crew_quarters/toilet/bar
	name = "\improper Bar Toilet"

/area/polarplanet/crew_quarters/toilet/west
	name = "\improper West Hallway Bathroom"

/area/polarplanet/crew_quarters/sleep
	name = "\improper Dormitories"
	icon_state = "Sleep"

/area/polarplanet/crew_quarters/sleep/cryo
	name = "\improper Cryogenic Storage"
	icon_state = "Cryopods"

/area/polarplanet/crew_quarters/sleep2
	name = "\improper Dormitories Hallway North"
	icon_state = "Sleep"

/area/polarplanet/crew_quarters/sleep3
	name = "\improper Dormitories Hallway West"
	icon_state = "Sleep"

/area/polarplanet/crew_quarters/sleep/lobby
	name = "\improper Dormitory Lobby"
	icon_state = "Sleep"

/area/polarplanet/crew_quarters/sleep/cave
	name = "\improper Dormitory Cave"
	icon_state = "explored"

/area/polarplanet/crew_quarters/underdorm
	name = "\improper Underground Dormitories"
	icon_state = "underdorm"

/area/polarplanet/crew_quarters/underdorm/boxing
	name = "\improper Boxing Club"
	icon_state = "fitness"

/area/polarplanet/crew_quarters/underdorm/maint
	name = "\improper Underground Dormitories Maintenance"
	icon_state = "underdormmaint"

/area/polarplanet/crew_quarters/underdorm/theater
	name = "\improper Theater"
	icon_state = "Theatre"

/area/polarplanet/crew_quarters/underdorm/theater/clown
	name = "\improper Clown's Bedroom"
	icon_state = "Theatre"

/area/polarplanet/crew_quarters/underdorm/theater/mime
	name = "\improper Mime's Bedroom"
	icon_state = "Theatre"

/area/polarplanet/crew_quarters/underdorm/theater/actor
	name = "\improper Actors' Break Room"
	icon_state = "Theatre"

/area/polarplanet/crew_quarters/underdorm/sauna
	name = "\improper Sauna"
	icon_state = "toilet"


/area/polarplanet/crew_quarters/sleep/cabin1
	name = "\improper Private Bedroom One"
	icon_state = "PrivDormOne"
	sound_env = SMALL_SOFTFLOOR

/area/polarplanet/crew_quarters/sleep/cabin2
	name = "\improper Private Bedroomn Two"
	icon_state = "PrivDormTwo"
	sound_env = SMALL_SOFTFLOOR

/area/polarplanet/crew_quarters/sleep/cabin3
	name = "\improper Private Bedroom Three"
	icon_state = "PrivDormThree"
	sound_env = SMALL_SOFTFLOOR

/area/polarplanet/crew_quarters/sleep/cabin4
	name = "\improper Private Bedroom Four"
	icon_state = "PrivDormFour"
	sound_env = SMALL_SOFTFLOOR

/area/polarplanet/crew_quarters/sleep/cabin5
	name = "\improper Private Bedroom Five"
	icon_state = "PrivDormFive"
	sound_env = SMALL_SOFTFLOOR

/area/polarplanet/crew_quarters/sleep/cabin6
	name = "\improper Private Bedroom Six"
	icon_state = "PrivDormSix"
	sound_env = SMALL_SOFTFLOOR

/area/polarplanet/crew_quarters/sleep/underg_cabin1
	name = "\improper Underground Bedroom One"
	icon_state = "UndergroundDormOne"
	sound_env = SMALL_SOFTFLOOR

/area/polarplanet/crew_quarters/sleep/underg_cabin2
	name = "\improper Underground Bedroom Two"
	icon_state = "UndergroundDormTwo"
	sound_env = SMALL_SOFTFLOOR

/area/polarplanet/crew_quarters/sleep/underg_cabin3
	name = "\improper Underground Bedroom Three"
	icon_state = "UndergroundDormThree"
	sound_env = SMALL_SOFTFLOOR

/area/polarplanet/crew_quarters/sleep/engi_wash
	name = "\improper Engineering Washroom"
	icon_state = "toilet"
	sound_env = SMALL_ENCLOSED

/area/polarplanet/crew_quarters/sleep/bedrooms
	name = "\improper Dormitory Bedroom One"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/polarplanet/crew_quarters/sleep/dorms
	name = "\improper Dormitory Shared Bedroom"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/polarplanet/crew_quarters/sleep/quartes1
	name = "\improper Dormitory Quartes One"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/polarplanet/crew_quarters/sleep/quartes2
	name = "\improper Dormitory Quartes Two"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/polarplanet/crew_quarters/sleep/quartes3
	name = "\improper Dormitory Quartes Three"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/polarplanet/crew_quarters/sleep/quartes4
	name = "\improper Dormitory Quartes Four"
	icon_state = "Sleep"
	sound_env = SMALL_SOFTFLOOR

/area/polarplanet/crew_quarters/locker/locker_toilet
	name = "\improper Locker Toilets"
	icon_state = "toilet"
	sound_env = SMALL_ENCLOSED

/area/polarplanet/crew_quarters/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/crew_quarters/fitness/arcade
	name = "\improper Arcade"
	icon_state = "arcade"

/area/polarplanet/crew_quarters/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/polarplanet/crew_quarters/bar
	name = "\improper Bar"
	icon_state = "bar"
	sound_env = LARGE_SOFTFLOOR
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/crew_quarters/barbackroom
	name = "\improper Bar Backroom"
	icon_state = "barBR"

/area/polarplanet/crew_quarters/ubarbackroom // new room for bartender
	name = "\improper Underground Bar Backroom"
	icon_state = "ubarBR"

/area/polarplanet/crew_quarters/mess
	name = "\improper Mess Hall"
	icon_state = "cafeteria"
	sound_env = LARGE_SOFTFLOOR
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/library
 	name = "\improper Library"
 	icon_state = "library"
 	sound_env = LARGE_SOFTFLOOR

/area/polarplanet/janitor
	name = "\improper Custodial Closet"
	icon_state = "janitor"

/area/polarplanet/chapel
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/chapel/main
	name = "\improper Chapel"
	icon_state = "chapel"
	ambience_off = list(SFX_AMBIENT_OFF_GLOBAL)
	ambience_powered = list(SFX_AMBIENT_CHAPEL)
	sound_env = LARGE_ENCLOSED

/area/polarplanet/chapel/office
	name = "\improper Chapel Office"
	icon_state = "chapeloffice"

/area/polarplanet/chapel/crematorium
	name = "\improper Crematorium"
	icon_state = "chapelcrematorium"

/area/polarplanet/iaoffice
	name = "\improper Internal Affairs"
	icon_state = "law"

/area/polarplanet/lawoffice
	name = "\improper Law Office"
	icon_state = "law"


// Engineering

/area/polarplanet/engineering/
	name = "\improper Engineering"
	icon_state = "engineering"
	ambience_powered = list(SFX_AMBIENT_ENGINEERING)

/area/polarplanet/engineering/preengine
	name = "\improper Pre-Engine Room"
	icon_state = "engine"

/area/polarplanet/engineering/grav_generator
	name = "\improper Gravitational Generator Room"
	icon_state = "engine"
	sound_env = LARGE_ENCLOSED

/area/polarplanet/engineering/lower
	name = "\improper Engineering Lower Deck"
	icon_state = "lower_engi"

/area/polarplanet/engineering/lower/rust
	name = "\improper R-UST Engine"
	icon_state = "rust"

/area/polarplanet/engineering/lower/rust/core
	name = "\improper R-UST Core"
	icon_state = "rust"

/area/polarplanet/engineering/lower/rust/control
	name = "\improper R-UST Control Room"
	icon_state = "rust"

/area/polarplanet/engineering/engine_airlock
	name = "\improper Engine Room Airlock"
	icon_state = "engine"

/area/polarplanet/engineering/singularity_engine
	name = "\improper Singularity Engine"
	icon_state = "engine"

/area/polarplanet/engineering/singularity_control
	name = "\improper Singularity Engine Control Room"
	icon_state = "engine_monitoring"

/area/polarplanet/engineering/singularity_storage
	name = "\improper Singularity Engine Storage"
	icon_state = "engineering_storage"

/area/polarplanet/engineering/engine_waste
	name = "\improper Engine Waste Handling"
	icon_state = "engine_waste"

/area/polarplanet/engineering/break_room
	name = "\improper Engineering Break Room"
	icon_state = "engineering_break"
	sound_env = MEDIUM_SOFTFLOOR

/area/polarplanet/engineering/workshop
	name = "\improper Engineering Workshop"
	icon_state = "engineering_workshop"

/area/polarplanet/engineering/sublevel_access
	name = "\improper Engineering Sublevel Access"

/area/polarplanet/engineering/atmos
	name = "\improper Atmospherics"
	icon_state = "atmos"
	ambience_powered = list(SFX_AMBIENT_ENGINEERING, SFX_AMBIENT_ATMOSPHERICS)

/area/polarplanet/engineering/atmos/storage
	name = "\improper Atmospherics Storage"
	icon_state = "atmos_storage"

/area/polarplanet/engineering/toilet
	name = "\improper Atmospherics"
	icon_state = "engineering_break"

/area/polarplanet/engineering/eva_airlock
	name = "\improper Engineering Airlock"
	icon_state = "engineering_break"

/area/polarplanet/engineering/atmos_monitoring
	name = "\improper Atmospherics Monitoring Room"
	icon_state = "engine_monitoring"

/area/polarplanet/engineering/storage
	name = "\improper Engineering Storage"
	icon_state = "engineering_storage"

/area/polarplanet/engineering/engine_eva
	name = "\improper Engine EVA"
	icon_state = "engine_eva"

/area/polarplanet/engineering/engine_monitoring
	name = "\improper Engine Monitoring Room"
	icon_state = "engine_monitoring"

/area/polarplanet/engineering/locker_room
	name = "\improper Engineering Locker Room"
	icon_state = "engineering_locker"

/area/polarplanet/engineering/engineering_monitoring
	name = "\improper Engineering Monitoring Room"
	icon_state = "engine_monitoring"

/area/polarplanet/engineering/drone_fabrication
	name = "\improper Engineering Drone Fabrication"
	icon_state = "drone_fab"
	sound_env = SMALL_ENCLOSED

/area/polarplanet/engineering/engine_smes
	name = "\improper Engineering SMES"
	icon_state = "engine_smes"
	sound_env = SMALL_ENCLOSED

/area/polarplanet/engineering/engine_room
	name = "\improper Engine Room"
	icon_state = "engine"
	sound_env = LARGE_ENCLOSED

// Medbay

/area/polarplanet/medical/genetics
	name = "\improper Genetics Lab"
	icon_state = "genetics"

/area/polarplanet/medical/genetics_cloning
	name = "\improper Cloning Lab"
	icon_state = "cloning"

/area/polarplanet/medical/biostorage/underground
	name = "\improper Undergound Medbay Storage"
	icon_state = "medbay4"

/area/polarplanet/medical/sleeper
	name = "\improper Emergency Treatment Room"
	icon_state = "exam_room"

/area/polarplanet/medical/sleeper/underground
	name = "\improper Underground Emergency Treatment Room"
	icon_state = "exam_room"

/area/polarplanet/medical/chemistry
	name = "\improper Chemistry"
	icon_state = "chem"

/area/polarplanet/medical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"

/area/polarplanet/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"
	ambience_powered = list(SFX_AMBIENT_MORGUE, SFX_AMBIENT_SCIENCE)

/area/polarplanet/medical/surgery
	name = "\improper Operating Theatre"
	icon_state = "surgery"

// Solars

/area/polarplanet/solar
	ambient_music_tags = list(MUSIC_TAG_SPACE)

/area/polarplanet/solar/starboard
	name = "\improper Starboard Auxiliary Solar Array"
	icon_state = "panelsS"

/area/polarplanet/solar/auxport
	name = "\improper Fore Port Solar Array"
	icon_state = "panelsA"

/area/polarplanet/solar/fore
	name = "\improper Fore Solar Array"
	icon_state = "yellow"

/area/polarplanet/solar/port
	name = "\improper Port Auxiliary Solar Array"
	icon_state = "panelsP"

/area/polarplanet/maintenance/foresolar
	name = "\improper Solar Maintenance - Fore"
	icon_state = "SolarcontrolA"
	sound_env = SMALL_ENCLOSED

/area/polarplanet/maintenance/portsolar
	name = "\improper Solar Maintenance - Aft Port"
	icon_state = "SolarcontrolP"
	sound_env = SMALL_ENCLOSED

/area/polarplanet/maintenance/starboardsolar
	name = "\improper Solar Maintenance - Aft Starboard"
	icon_state = "SolarcontrolS"
	sound_env = SMALL_ENCLOSED

// Teleporter

/area/polarplanet/teleporter
	name = "\improper Teleporter"
	icon_state = "teleporter"
	ambient_music_tags = list(MUSIC_TAG_SPACE)

/area/polarplanet/gateway
	name = "\improper Gateway"
	icon_state = "teleporter"
	ambient_music_tags = list(MUSIC_TAG_SPACE)

// MedBay

/area/polarplanet/medical/medbay
	name = "\improper Medbay Hallway - Port"
	icon_state = "medbay"

// Medbay is a large area/polarplanet, these additional areas help level out APC load.
/area/polarplanet/medical/medbay2
	name = "\improper Medbay Hallway - Starboard"
	icon_state = "medbay2"

/area/polarplanet/medical/medbay3
	name = "\improper Medbay Hallway - Fore"
	icon_state = "medbay3"

/area/polarplanet/medical/medbay3/underground
	name = "\improper Underground Medbay Hallway - Fore"
	icon_state = "medbay3"

/area/polarplanet/medical/medbay4
	name = "\improper Medbay Hallway - Aft"
	icon_state = "medbay4"

/area/polarplanet/medical/medbay4/underground
	name = "\improper Underground Medbay Hallway - Aft"
	icon_state = "medbay4"

/area/polarplanet/medical/reception
	name = "\improper Medbay Reception"
	icon_state = "medbay"

/area/polarplanet/medical/psych
	name = "\improper Psych Room"
	icon_state = "medbay3"

/area/polarplanet/crew_quarters/medbreak
	name = "\improper Break Room"
	icon_state = "medbay3"

/area/polarplanet/medical/ward
	name = "\improper Recovery Ward"
	icon_state = "patients"

/area/polarplanet/medical/patient_a
	name = "\improper Isolation A"
	icon_state = "patients"

/area/polarplanet/medical/patient_b
	name = "\improper Isolation B"
	icon_state = "patients"

/area/polarplanet/medical/patient_c
	name = "\improper Isolation C"
	icon_state = "patients"

/area/polarplanet/medical/patient_d
	name = "\improper Isolation D"
	icon_state = "patients"

/area/polarplanet/medical/patient_wing
	name = "\improper Underground Patient Ward"
	icon_state = "patients"

/area/polarplanet/medical/patient_wing/garden
	name = "\improper Medbay Garden"
	icon_state = "patients"

/area/polarplanet/medical/patient_wing/washroom
	name = "\improper Patient Wing Washroom"

/area/polarplanet/medical/surgery2
	name = "\improper Operating Theatre 2"
	icon_state = "surgery"

/area/polarplanet/medical/surgery_storage
	name = "\improper Surgery Storage"
	icon_state = "surgery"

/area/polarplanet/medical/surgeryobs
	name = "\improper Operation Observation Room"
	icon_state = "surgery"

/area/polarplanet/medical/surgeryprep
	name = "\improper Pre-Op Prep Room"
	icon_state = "surgery"

/area/polarplanet/medical/cryo
	name = "\improper Cryogenics"
	icon_state = "cryo"

/area/polarplanet/medical/med_toilet
	name = "\improper Medbay Toilets"
	icon_state = "medbay"

/area/polarplanet/medical/med_mech
	name = "\improper Medbay Mech Room"
	icon_state = "medbay3"

/area/polarplanet/medical/storage1
	name = "\improper Primary Storage"
	icon_state = "medbay4"

/area/polarplanet/medical/storage2
	name = "\improper Medbay Storage"
	icon_state = "medbay3"

/area/polarplanet/medical/resleever
	name = "\improper Neural Lace Resleever"
	icon_state = "cloning"

// Security

/area/polarplanet/security/main
	name = "\improper Security Office"
	icon_state = "security"

/area/polarplanet/security/briefingroom
	name = "\improper Security - Briefing Room"
	icon_state = "briefroom"

/area/polarplanet/security/storage
	name = "\improper Security Storage"
	icon_state = "brigstorage"

/area/polarplanet/security/execution
	name = "\improper Security - Execution Room"
	icon_state = "execution"

/area/polarplanet/security/evidence
	name = "\improper Security - Evidence Storage"
	icon_state = "evidence"

/area/polarplanet/security/brigmorgue
	name = "\improper Security - Morgue"
	icon_state = "brigmorgue"

/area/polarplanet/security/brigswstorage
	name = "\improper Security - S-W Storage"
	icon_state = "brigswstorage"

/area/polarplanet/security/meeting
	name = "\improper Security Meeting Room"
	icon_state = "security"

/area/polarplanet/security/lobby
	name = "\improper Security Lobby"
	icon_state = "security"

/area/polarplanet/security/brig/processing
	name = "\improper Security - Processing Room 1"
	icon_state = "proc1"

/area/polarplanet/security/brig/processing2
	name = "\improper Security - Processing Room 2"
	icon_state = "proc2"

/area/polarplanet/security/brig/interrogation
	name = "\improper Security - Interrogation"
	icon_state = "interrogation"

/area/polarplanet/security/brig/solitaryA
	name = "\improper Security - Solitary 1"
	icon_state = "sec_prison"

/area/polarplanet/security/brig/solitaryB
	name = "\improper Security - Solitary 2"
	icon_state = "sec_prison"

/area/polarplanet/security/brig/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.icon_state = temp_closet.icon_closed
	for(var/obj/machinery/door_timer/temp_timer in src)
		temp_timer.releasetime = 1
	..()

/area/polarplanet/security/prison/restroom
	name = "\improper Security - Prison Wing Restroom"
	icon_state = "sec_prison"

/area/polarplanet/security/prison/dorm
	name = "\improper Security - Prison Wing Dormitory"
	icon_state = "sec_prison"

/area/polarplanet/security/prison/monitoring
	name = "\improper Security - Prison Wing Monitoring"

/area/polarplanet/security/prison/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.icon_state = temp_closet.icon_closed
	for(var/obj/machinery/door_timer/temp_timer in src)
		temp_timer.releasetime = 1
	..()

/area/polarplanet/security/warden
	name = "\improper Security - Warden's Office"
	icon_state = "Warden"

/area/polarplanet/security/tactical
	name = "\improper Security - Tactical Equipment"
	icon_state = "Tactical"

/area/polarplanet/security/vacantoffice
	name = "\improper Vacant Office"
	icon_state = "security"

/area/polarplanet/security/nuke_storage
	name = "\improper Vault"
	icon_state = "nuke_storage"

/area/polarplanet/security/checkpoint2
	name = "\improper Command Security - Checkpoint"
	icon_state = "checkpoint1"

/area/polarplanet/quartermaster
	name = "\improper Quartermasters"
	icon_state = "quart"
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/quartermaster/breakroom
	name = "\improper Cargo Break Room"
	icon_state = "cargobreak"

/area/polarplanet/quartermaster/storage
	name = "\improper Warehouse"
	icon_state = "quartstorage"
	sound_env = LARGE_ENCLOSED

/area/polarplanet/quartermaster/storage/under
	name = "\improper Underground Cargo Warehouse"
	icon_state = "cargounder"

/area/polarplanet/quartermaster/storage/under/secure
	name = "\improper Underground Cargo Storage"
	icon_state = "cargounderstorage"

/area/polarplanet/quartermaster/qm
	name = "\improper Cargo - Quartermaster's Office"
	icon_state = "quart"

/area/polarplanet/quartermaster/miningdock
	name = "\improper Cargo Mining Dock"
	icon_state = "mining"

/area/polarplanet/quartermaster/office
	name = "\improper Supply Office"
	icon_state = "quartoffice"

/area/polarplanet/hydroponics
	name = "\improper Hydroponics"
	icon_state = "hydro"

/area/polarplanet/hydroponics/garden
	name = "\improper Garden"
	icon_state = "garden"

/area/polarplanet/hydroponics/lower
	name = "\improper Lower Hydroponics"
	icon_state = "garden"

/area/polarplanet/hydroponics/biodome
	name = "\improper Central Biodome"
	icon_state = "garden"

// Research
/area/polarplanet/rnd/docking
	name = "\improper Research Dock"
	icon_state = "research_dock"

/area/polarplanet/assembly/robotics
	name = "\improper Robotics Lab"
	icon_state = "robotics"

/area/polarplanet/assembly/chargebay
	name = "\improper Mech Bay"
	icon_state = "mechbay"

/area/polarplanet/rnd/lab
	name = "\improper Research Lab"
	icon_state = "toxlab"

/area/polarplanet/rnd/misc_lab
	name = "\improper Miscellaneous Research"
	icon_state = "toxmisc"

/area/polarplanet/rnd/mixing
	name = "\improper Toxins Mixing Room"
	icon_state = "toxmix"

/area/polarplanet/rnd/storage
	name = "\improper Toxins Storage"
	icon_state = "toxstorage"

/area/polarplanet/rnd/test_area/polarplanet
	name = "\improper Toxins Test area/polarplanet"
	icon_state = "toxtest"

/area/polarplanet/server
	name = "\improper Research Server Room"
	icon_state = "server"
	ambient_music_tags = list(MUSIC_TAG_SPACE)

/area/polarplanet/rnd/research_under
	name = "\improper Underground Research Wing"
	icon_state = "uresearch"

/area/polarplanet/rnd/research_under/breakroom
	name = "\improper Underground Research Wing - Break Room"
	icon_state = "uresearchbreak"

/area/polarplanet/rnd/restroom
	name = "\improper Research Restroom"
	icon_state = "research"

/area/polarplanet/rnd/research
	name = "\improper Research and Development"
	icon_state = "research"

// Storage

/area/polarplanet/storage/art
	name = "Art Supply Storage"
	icon_state = "storage"

/area/polarplanet/storage/emergency
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"

/area/polarplanet/storage/emergency2
	name = "Port Emergency Storage"
	icon_state = "emergencystorage"

/area/polarplanet/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/polarplanet/storage/tools
	name = "Auxiliary Tool Storage"
	icon_state = "auxstorage"

/area/polarplanet/storage/tech
	name = "Technical Storage"
	icon_state = "storage"

// HALF-BUILT STATION (REPLACES DERELICT IN BAYCODE, ABOVE IS LEFT FOR DOWNSTREAM)

/area/polarplanet/shuttle/constructionsite/site
	name = "\improper Construction Site Shuttle"
	base_turf = /turf/simulated/floor/asteroid

// AI

/area/polarplanet/turret_protected
	ambience_powered = list(SFX_AMBIENT_AI, SFX_AMBIENT_SCIENCE)

/area/polarplanet/turret_protected/ai
	name = "\improper AI Chamber"
	icon_state = "ai_chamber"
	ambience_powered = list(SFX_AMBIENT_AI)

/area/polarplanet/turret_protected/ai_server_room
	name = "Messaging Server Room"
	icon_state = "ai_server"
	sound_env = SMALL_ENCLOSED

/area/polarplanet/turret_protected/ai_cyborg_station
	name = "\improper Cyborg Station"
	icon_state = "ai_cyborg"
	sound_env = SMALL_ENCLOSED
	ambience_powered = list(SFX_AMBIENT_AI)

/area/polarplanet/turret_protected/ai_upload
	name = "\improper AI Upload Chamber"
	icon_state = "ai_upload"
	ambience_powered = list(SFX_AMBIENT_AI)

/area/polarplanet/turret_protected/ai_upload_foyer
	name = "\improper  AI Upload Access"
	icon_state = "ai_foyer"
	ambience_powered = list(SFX_AMBIENT_AI)
	sound_env = SMALL_ENCLOSED

/area/polarplanet/turret_protected/tcomsat/port
	name = "\improper Telecoms Satellite - Port"

/area/polarplanet/turret_protected/tcomsat/starboard
	name = "\improper Telecoms Satellite - Starboard"

/area/polarplanet/ai_monitored/storage/eva
	name = "\improper EVA Storage"
	icon_state = "eva"

// Misc

/area/polarplanet/alien
	name = "\improper Alien base"
	icon_state = "yellow"
	requires_power = 0
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)

// Telecommunications Satellite

/area/polarplanet/tcommsat
	ambient_music_tags = list(MUSIC_TAG_SPACE)
	ambience_powered = list(SFX_AMBIENT_AI, SFX_AMBIENT_COMMS)

/area/polarplanet/tcommsat/entrance
	name = "\improper Telecoms Teleporter"
	icon_state = "tcomsatentrance"

/area/polarplanet/turret_protected/tcomsat
	name = "\improper Telecoms Satellite"
	icon_state = "tcomsatlob"

/area/polarplanet/turret_protected/tcomfoyer
	name = "\improper Telecoms Foyer"
	icon_state = "tcomsatentrance"

/area/polarplanet/tcommsat/powercontrol
	name = "\improper Telecommunications Power Control"
	icon_state = "tcomsatwest"

/area/polarplanet/tcommsat/chamber
	name = "\improper Telecoms Central Compartment"
	icon_state = "tcomsatcham"

/area/polarplanet/tcommsat/computer
	name = "\improper Telecoms Control Room"
	icon_state = "tcomsatcomp"

/*******
* Moon *
*******/

// Mining main outpost

/area/polarplanet/outpost
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)

/area/polarplanet/outpost/mining_main
	icon_state = "outpost_mine_main"

/area/polarplanet/outpost/mining_main/east_hall
	name = "Mining Outpost East Hallway"

/area/polarplanet/outpost/mining_main/eva
	name = "Mining Outpost EVA storage"

/area/polarplanet/outpost/mining_main/dorms
	name = "Mining Outpost Dormitory"

/area/polarplanet/outpost/mining_main/medbay
	name = "Mining Outpost Medical"

/area/polarplanet/outpost/mining_main/refinery
	name = "Mining Outpost Refinery"

/area/polarplanet/outpost/mining_main/west_hall
	name = "Mining Outpost West Hallway"

/area/polarplanet/outpost/mining_main/mechbay
	name = "Mining Outpost Mech Bay"

// Mining outpost
/area/polarplanet/outpost/mining_main/maintenance
	name = "Mining Outpost Maintenance"

// Main Outpost
/area/polarplanet/outpost/main_outpost
	icon_state = "green"
	ambience_off = list(SFX_AMBIENT_OFF_GLOBAL, SFX_AMBIENT_OFF_MAINTENANCE)
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE, SFX_AMBIENT_OUTPOST)

/area/polarplanet/outpost/main_outpost/shallway
	name = "Outpost Southern Hallway"

/area/polarplanet/outpost/main_outpost/challway
	name = "Outpost Central Hallway"

/area/polarplanet/outpost/main_outpost/nhallway
	name = "Outpost Northern Hallway"

/area/polarplanet/outpost/main_outpost/dock
	name = "Outpost Dock"
	icon_state = "bluenew"

/area/polarplanet/outpost/main_outpost/infirmary
	name = "Outpost Infirmary"
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_SCIENCE, SFX_AMBIENT_OUTPOST)

/area/polarplanet/outpost/main_outpost/canteen
	name = "Outpost Canteen"
	icon_state = "kitchen"

/area/polarplanet/outpost/main_outpost/bar
	name = "Outpost Bar"
	icon_state = "bar"

/area/polarplanet/outpost/main_outpost/dorms
	name = "Outpost Living Quarters"
	icon_state = "blue2"

/area/polarplanet/outpost/main_outpost/dorms/substation
	name = "Outpost Living Quarters Substation"

/area/polarplanet/outpost/main_outpost/dorms/proom1
	name = "Outpost Private Room One"

/area/polarplanet/outpost/main_outpost/dorms/proom2
	name = "Outpost Private Room Two"

/area/polarplanet/outpost/main_outpost/dorms/proom3
	name = "Outpost Private Room Three"

/area/polarplanet/outpost/main_outpost/dorms/proom4
	name = "Outpost Private Room Four"

// Small outposts
/area/polarplanet/outpost/mining_north
	name = "North Mining Outpost"
	icon_state = "outpost_mine_north"
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE, SFX_AMBIENT_OUTPOST)

/area/polarplanet/outpost/mining_west
	name = "West Mining Outpost"
	icon_state = "outpost_mine_west"
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE, SFX_AMBIENT_OUTPOST)

/area/polarplanet/outpost/abandoned
	name = "Abandoned Outpost"
	icon_state = "dark"

/area/polarplanet/outpost/abandonedpost
	name = "Abandoned Post"
	icon_state = "dark"

/area/polarplanet/outpost/prydwen
	name = "NSC Prydwen"
	icon_state = "green"

// Engineering outpost

/area/polarplanet/engineering
	icon_state = "outpost_engine"
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE, SFX_AMBIENT_ENGINEERING)

/area/polarplanet/engineering/atmospherics
	name = "Engineering Atmospherics"

/area/polarplanet/engineering/hallway
	name = "Engineering Hallway"

/area/polarplanet/engineering/power
	name = "Engineering Power Distribution"

/area/polarplanet/engineering/telecomms
	name = "Engineering Telecommunications"

/area/polarplanet/engineering/storage
	name = "Engineering Storage"

/area/polarplanet/engineering/meeting
	name = "Engineering Meeting Room"

// Research Outpost
/area/polarplanet/outpost/research
	icon_state = "outpost_research"

/area/polarplanet/outpost/research/hallway
	name = "Research Outpost Hallway"

/area/polarplanet/outpost/research/dock
	name = "Research Outpost Shuttle Dock"

/area/polarplanet/outpost/research/eva
	name = "Research Outpost EVA"

/area/polarplanet/outpost/research/analysis
	name = "Research Outpost Sample Analysis"

/area/polarplanet/outpost/research/chemistry
	name = "Research Outpost Chemistry"

/area/polarplanet/outpost/research/medical
	name = "Research Outpost Medical"

/area/polarplanet/outpost/research/power
	name = "Research Outpost Maintenance"

/area/polarplanet/outpost/research/isolation_a
	name = "Research Outpost Isolation A"

/area/polarplanet/outpost/research/isolation_b
	name = "Research Outpost Isolation B"

/area/polarplanet/outpost/research/isolation_c
	name = "Research Outpost Isolation C"

/area/polarplanet/outpost/research/isolation_monitoring
	name = "Research Outpost Isolation Monitoring"

/area/polarplanet/outpost/research/lab
	name = "Research Outpost Laboratory"

/area/polarplanet/outpost/research/emergency_storage
	name = "Research Outpost Emergency Storage"

/area/polarplanet/outpost/research/anomaly_storage
	name = "Research Outpost Anomalous Storage"

/area/polarplanet/outpost/research/anomaly_analysis
	name = "Research Outpost Anomaly Analysis"

/area/polarplanet/outpost/research/kitchen
	name = "Research Outpost Kitchen"

/area/polarplanet/outpost/research/disposal
	name = "Research Outpost Waste Disposal"

/area/polarplanet/outpost/research/brainstorm
	name = "Research Outpost Brainstorm Room"

/area/polarplanet/construction
	name = "\improper Engineering Construction area/polarplanet"
	icon_state = "yellow"

// CentComm
/area/polarplanet/centcom/control
	name = "\improper Centcom Control"

/area/polarplanet/tdome
	name = "\improper Thunderdome"
	icon_state = "thunder"
	requires_power = 0
	dynamic_lighting = 0
	sound_env = ARENA

/area/polarplanet/centcom/museum
	name = "\improper Museum"
	icon_state = "museum"

// Thunderdr
/area/polarplanet/tdome/tdome1
	name = "\improper Thunderdome (Team 1)"
	icon_state = "green"

/area/polarplanet/tdome/tdome2
	name = "\improper Thunderdome (Team 2)"
	icon_state = "yellow"

/area/polarplanet/tdome/tdomeadmin
	name = "\improper Thunderdome (Admin.)"
	icon_state = "purple"

/area/polarplanet/tdome/tdomeobserve
	name = "\improper Thunderdome (Observer.)"
	icon_state = "purple"

/area/polarplanet/holodeck
	name = "\improper Holodeck"
	icon_state = "Holodeck"
	dynamic_lighting = 0
	sound_env = LARGE_ENCLOSED

/area/polarplanet/holodeck/source_boxingcourt
	name = "\improper Holodeck - Boxing Court"
	sound_env = ARENA

/area/polarplanet/holodeck/source_desert
	name = "\improper Holodeck - Desert"
	sound_env = PLAIN

/area/polarplanet/holodeck/source_picnicarea/polarplanet
	name = "\improper Holodeck - Picnic area/polarplanet"
	sound_env = PLAIN

/area/polarplanet/holodeck/source_wildlife
	name = "\improper Holodeck - Wildlife Simulation"

/area/polarplanet/holodeck/source_courtroom
	name = "\improper Holodeck - Courtroom"
	sound_env = AUDITORIUM

/area/polarplanet/holodeck/source_basketball
	name = "\improper Holodeck - Basketball Court"
	sound_env = ARENA

/area/polarplanet/holodeck/source_plating
	name = "\improper Holodeck - Off"

/area/polarplanet/holodeck/source_emptycourt
	name = "\improper Holodeck - Empty Court"
	sound_env = ARENA

/area/polarplanet/holodeck/source_theatre
	name = "\improper Holodeck - Theatre"
	sound_env = CONCERT_HALL

/area/polarplanet/holodeck/source_thunderdomecourt
	name = "\improper Holodeck - Thunderdome Court"
	sound_env = ARENA

/area/polarplanet/holodeck/source_beach
	name = "\improper Holodeck - Beach"
	sound_env = PLAIN

/area/polarplanet/holodeck/source_snowfield
	name = "\improper Holodeck - Snow Field"
	sound_env = FOREST

/area/polarplanet/holodeck/source_meetinghall
	name = "\improper Holodeck - Meeting Hall"
	sound_env = AUDITORIUM

/area/polarplanet/holodeck/source_space
	name = "\improper Holodeck - Space"
	has_gravity = 0
	sound_env = SPACE

/area/polarplanet/holodeck/source_chess
	name = "\improper Holodeck - Chess Field"

/area/polarplanet/holodeck/alphadeck
	name = "\improper Holodeck Alpha"

/area/polarplanet/prison/solitary
	name = "Solitary Confinement"
	icon_state = "brig"

/area/polarplanet/security/range
	name = "\improper Security - Firing Range"
	icon_state = "firingrange"

/area/polarplanet/mine
	base_turf = /turf/simulated/floor/natural/frozenground/cave
	icon_state = "mining"
	sound_env = 5 // stoneroom
	ambience_off = list(SFX_AMBIENT_MINE)
	ambience_powered = list(SFX_AMBIENT_MINE)
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)

/area/polarplanet/mine/explored
	name = "Mine"
	icon_state = "explored"

/area/polarplanet/mine/unexplored
	name = "Mine"
	icon_state = "unexplored"

/area/polarplanet/constructionsite
	name = "\improper Construction Site"
	icon_state = "yellow"
	has_gravity = FALSE

/area/polarplanet/constructionsite/maintenance
	name = "\improper Construction Site Maintenance"
	icon_state = "yellow"

/area/polarplanet/constructionsite/bridge
	name = "\improper Construction Site Bridge"
	icon_state = "bridge"

/area/polarplanet/constructionsite/hallway/fore
	name = "\improper Construction Site Fore Hallway"
	icon_state = "hallS"

/area/polarplanet/constructionsite/storage
	name = "\improper Construction Site Storage area/polarplanet"

/area/polarplanet/constructionsite/medical
	name = "\improper Construction Site Medbay"
	icon_state = "medbay"

/area/polarplanet/constructionsite/engineering
	name = "\improper Construction Site Engine Bay"
	icon_state = "engine"

/area/polarplanet/solar/constructionsite
	name = "\improper Construction Site Solars"
	icon_state = "aft"

/area/polarplanet/constructionsite/teleporter
	name = "Construction Site Teleporter"
	icon_state = "yellow"

/area/polarplanet/constructionsite/ai
	name = "\improper Construction Computer Core"
	icon_state = "ai"

/area/polarplanet/constructionsite/hallway/aft
	name = "\improper Construction Site Aft Hallway"
	icon_state = "hallP"

/area/polarplanet/maintenance/auxsolarstarboard
	name = "Solar Maintenance - Fore Starboard"
	icon_state = "SolarcontrolS"

/area/polarplanet/maintenance/incinerator
	name = "\improper Incinerator"
	icon_state = "disposal"

/area/polarplanet/maintenance/auxsolarport
	name = "Solar Maintenance - Fore Port"
	icon_state = "SolarcontrolP"

/area/polarplanet/derelict/ship
	name = "\improper Abandoned Ship"
	icon_state = "yellow"

/area/polarplanet/derelict/snowasteroid
	name = "\improper Hidden Outpost"
	icon_state = "yellow"
	has_gravity = TRUE

/area/polarplanet/derelict/snowasteroid/bunker
	name = "\improper Hidden Outpost Bunker"
	icon_state = "red"
	has_gravity = TRUE

/area/polarplanet/derelict/snowasteroid/shuttle
	name = "\improper Hidden Outpost Shuttle"
	icon_state = "blue"
	has_gravity = TRUE

/area/polarplanet/derelict/djstation
	name = "\improper DJ Station"
	icon_state = "yellow"
	has_gravity = TRUE

/area/polarplanet/AIsattele
	name = "\improper AI Satellite Teleporter Room"
	icon_state = "teleporter"
	ambience_powered = list(SFX_AMBIENT_AI)
	has_gravity = FALSE
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)

/area/polarplanet/constructionsite/atmospherics
	name = "\improper Construction Site Atmospherics"
	icon_state = "green"

/area/polarplanet/supply
	name = "Supply Shuttle"
	icon_state = "shuttle3"

/area/polarplanet/supply/dock
	name = "Supply Shuttle"
	icon_state = "shuttle3"
	requires_power = 0
	base_turf = /turf/unsimulated/floor

/area/polarplanet/supply/station
	name = "Supply Shuttle"
	icon_state = "shuttle3"
	requires_power = 0
	environment_type = ENVIRONMENT_OUTSIDE
	base_turf = /turf/simulated/floor/natural/frozenground
	environment_type = ENVIRONMENT_OUTSIDE

/area/polarplanet/security/armory
	name = "\improper Security - Armory"
	icon_state = "armory"

/area/polarplanet/security/detectives_office
	name = "\improper Security - Forensic Office"
	icon_state = "detective"
	sound_env = MEDIUM_SOFTFLOOR

/area/polarplanet/shuttle/escape_pod1/centcom
	icon_state = "shuttle"

/area/polarplanet/shuttle/escape_pod2/centcom
	icon_state = "shuttle"

/area/polarplanet/shuttle/escape_pod3/centcom
	icon_state = "shuttle"

/area/polarplanet/shuttle/escape_pod5/centcom
	icon_state = "shuttle"

/area/polarplanet/centcom/evac
	name = "\improper Centcom Emergency Shuttle"

/area/polarplanet/centcom/ferry
	name = "\improper Centcom Transport Shuttle"

/area/polarplanet/centcom/living
	name = "\improper Centcom Living Quarters"

/area/polarplanet/centcom/suppy
	name = "\improper Centcom Supply Shuttle"

/area/polarplanet/centcom/test
	name = "\improper Centcom Testing Facility"

/area/polarplanet/centcom/creed
	name = "Creed's Office"

/area/polarplanet/acting/stage
	name = "\improper Stage"
	dynamic_lighting = 0
	requires_power = 0
	icon_state = "yellow"

/area/polarplanet/merchant_station
	name = "\improper Merchant Station"
	icon_state = "LP"
	requires_power = 0

/area/polarplanet/thunder_rock
	name = "\improper Thunder Rock"
	icon_state = "LP"
	luminosity = 1
	dynamic_lighting = 0
	requires_power = 0

/area/polarplanet/acting/backstage
	name = "\improper Backstage"
	luminosity = 1
	dynamic_lighting = 0
	requires_power = 0

/area/polarplanet/solar/auxstarboard
	name = "\improper Fore Starboard Solar Array"
	icon_state = "panelsA"

//////////////////////
//area/polarplanets USED BY CODE//
//////////////////////
/area/polarplanet/centcom
	name = "\improper Centcom"
	icon_state = "centcom"
	requires_power = 0
	dynamic_lighting = 0
	ambient_music_tags = list(MUSIC_TAG_CENTCOMM)

/area/polarplanet/centcom/holding
	name = "\improper Holding Facility"

/area/polarplanet/chapel
	name = "\improper Chapel"
	icon_state = "chapel"
	holy = TRUE

/area/polarplanet/centcom/specops
	name = "\improper Centcom Special Ops"

/area/polarplanet/hallway
	name = "hallway"

/area/polarplanet/hallway/Initialize()
	. = ..()
	GLOB.hallway += src

/area/polarplanet/medical
	ambience_powered = list(SFX_AMBIENT_SCIENCE)

/area/polarplanet/medical/virology
	name = "\improper Virology"
	icon_state = "virology"

/area/polarplanet/medical/virologyaccess
	name = "\improper Virology Access"
	icon_state = "virology"

/area/polarplanet/security/brig
	name = "\improper Security - Brig"
	icon_state = "brig"

/area/polarplanet/security/prison
	name = "\improper Security - Prison Wing"
	icon_state = "sec_prison"
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/maintenance
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = TUNNEL_ENCLOSED
	turf_initializer = /decl/turf_initializer/maintenance
	ambience_off = list(SFX_AMBIENT_OFF_GLOBAL, SFX_AMBIENT_OFF_MAINTENANCE)
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE)
	ambient_music_tags = list(MUSIC_TAG_MYSTIC)

/area/polarplanet/rnd
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_SCIENCE)

/area/polarplanet/rnd/xenobiology
	name = "\improper Xenobiology Lab"
	icon_state = "xeno_lab"

/area/polarplanet/rnd/xenobiology/dorm
	name = "\improper Xenobiology Lab Dormitories"
	icon_state = "xeno_lab_dorm"


/area/polarplanet/rnd/xenobiology/xenoflora
	name = "\improper Xenoflora Lab"
	icon_state = "xeno_f_lab"

/area/polarplanet/rnd/xenobiology/xenoflora_storage
	name = "\improper Xenoflora Storage"
	icon_state = "xeno_f_store"

/area/polarplanet/shuttle/escape/centcom
	name = "\improper Emergency Shuttle Centcom"
	icon_state = "shuttle"

/area/polarplanet/shuttle/specops/centcom
	icon_state = "shuttlered"

/area/polarplanet/shuttle/syndicate_elite/mothership
	icon_state = "shuttlered"
	base_turf = /turf/space

/area/polarplanet/shuttle/syndicate_elite/station
	icon_state = "shuttlered2"

/area/polarplanet/supply
	name = "Supply Shuttle"
	icon_state = "shuttle3"

/area/polarplanet/syndicate_mothership/elite_squad
	name = "\improper Syndicate Elite Squad"
	icon_state = "syndie-elite"
	base_turf = /turf/space

////////////
//SHUTTLES//
////////////
//shuttles only need starting area/polarplanet, movement is handled by landmarks
//All shuttles should now be under shuttle since we have smooth-wall code.

/area/polarplanet/shuttle
	requires_power = 0
	sound_env = SMALL_ENCLOSED
	ambience_off = list(SFX_AMBIENT_OFF_GLOBAL, SFX_AMBIENT_OFF_MAINTENANCE)
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE)
	ambient_music_tags = list(MUSIC_TAG_SPACE, MUSIC_TAG_MYSTIC)

/*
* Special areas
*/
/area/polarplanet/wizard_station
	name = "\improper Wizard's Den"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = 0

/area/polarplanet/beach
	name = "Keelin's private beach"
	icon_state = "null"
	luminosity = 1
	dynamic_lighting = 0
	requires_power = 0
	var/sound/mysound = null

/area/polarplanet/beach/New()
	..()
	var/sound/S = new /sound()
	mysound = S
	S.file = 'sound/ambient/shore.ogg'
	S.repeat = 1
	S.wait = 0
	S.channel = 123
	S.volume = 100
	S.priority = 255
	S.status = SOUND_UPDATE
	process()

/area/polarplanet/beach/Entered(atom/movable/Obj,atom/OldLoc)
	if(ismob(Obj))
		var/mob/M = Obj
		if(M.client)
			mysound.status = SOUND_UPDATE
			sound_to(M, mysound)

/area/polarplanet/beach/Exited(atom/movable/Obj)
	. = ..()
	if(ismob(Obj))
		var/mob/M = Obj
		if(M.client)
			mysound.status = SOUND_PAUSED | SOUND_UPDATE
			sound_to(M, mysound)

/area/polarplanet/beach/proc/process()
	set background = 1

	var/sound/S = null
	var/sound_delay = 0
	if(prob(25))
		S = sound(file=pick('sound/ambient/seag1.ogg','sound/ambient/seag2.ogg','sound/ambient/seag3.ogg'), volume=100)
		sound_delay = rand(0, 50)

	for(var/mob/living/carbon/human/H in src)
		if(H.client)
			mysound.status = SOUND_UPDATE
			if(S)
				spawn(sound_delay)
					sound_to(H, S)

	spawn(60) .()

/area/polarplanet/thunderfield
	name = "Thunderfield"
	icon_state = "yellow"
	luminosity = 1
	dynamic_lighting = 0
	requires_power = 0

//Abductors
/area/polarplanet/abductor_ship
	name = "Abductor Ship"
	icon_state = "yellow"
	requires_power = FALSE
	requires_power = 0
	dynamic_lighting = 0
	luminosity = 1

/area/polarplanet/derelict
	name = "\improper Derelict Station"
	icon_state = "storage"
	has_gravity = FALSE
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_SPACE)

/area/polarplanet/derelict/hallway/primary
	name = "\improper Derelict Primary Hallway"
	icon_state = "hallP"

/area/polarplanet/derelict/hallway/secondary
	name = "\improper Derelict Secondary Hallway"
	icon_state = "hallS"

/area/polarplanet/derelict/arrival
	name = "\improper Derelict Arrival Centre"
	icon_state = "yellow"

/area/polarplanet/derelict/storage/equipment
	name = "Derelict Equipment Storage"

/area/polarplanet/derelict/storage/storage_access
	name = "Derelict Storage Access"

/area/polarplanet/derelict/storage/engine_storage
	name = "Derelict Engine Storage"
	icon_state = "green"

/area/polarplanet/derelict/bridge
	name = "\improper Derelict Control Room"
	icon_state = "bridge"

/area/polarplanet/derelict/secret
	name = "\improper Derelict Secret Room"
	icon_state = "library"

/area/polarplanet/derelict/bridge/access
	name = "Derelict Control Room Access"
	icon_state = "auxstorage"

/area/polarplanet/bridge/ai_upload
	name = "\improper Computer Core"
	icon_state = "ai"

/area/polarplanet/derelict/solar_control
	name = "\improper Derelict Solar Control"
	icon_state = "engine"

/area/polarplanet/derelict/crew_quarters
	name = "\improper Derelict Crew Quarters"
	icon_state = "fitness"

/area/polarplanet/derelict/medical
	name = "Derelict Medbay"
	icon_state = "medbay"

/area/polarplanet/derelict/medical/morgue
	name = "\improper Derelict Morgue"
	icon_state = "morgue"

/area/polarplanet/derelict/medical/chapel
	name = "\improper Derelict Chapel"
	icon_state = "chapel"

/area/polarplanet/derelict/teleporter
	name = "\improper Derelict Teleporter"
	icon_state = "teleporter"

/area/polarplanet/derelict/eva
	name = "Derelict EVA Storage"
	icon_state = "eva"

/area/polarplanet/derelict/ship
	name = "\improper Abandoned Ship"
	icon_state = "yellow"

/area/polarplanet/solar/derelict_starboard
	name = "\improper Derelict Starboard Solar Array"
	icon_state = "panelsS"

/area/polarplanet/solar/derelict_aft
	name = "\improper Derelict Aft Solar Array"
	icon_state = "aft"

/area/polarplanet/derelict/singularity_engine
	name = "\improper Derelict Singularity Engine"
	icon_state = "engine"

//Nuclear shelters
/area/polarplanet/shelter/nuclear1
	name = "\improper Nuclear Shelter One"
/area/polarplanet/shelter/nuclear2
	name = "\improper Nuclear Shelter Two"

// Voron
/area/polarplanet/voron/
	name = "\improper Apparat Voron"
	icon_state = "voron"
	ambient_music_tags = list(MUSIC_TAG_MYSTIC, MUSIC_TAG_NORMAL)
	ambience_off = list(SFX_AMBIENT_OFF_GLOBAL, SFX_AMBIENT_OFF_MAINTENANCE)
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE, SFX_AMBIENT_OUTPOST)

/area/polarplanet/voron/cargo_bay
	name = "\improper Apparat Voron - Cargo Bay"
	icon_state = "voron_cargo_bay"
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/voron/hangar
	name = "\improper Apparat Voron - Hangar"
	icon_state = "voron_hangar"

/area/polarplanet/voron/dormitory
	name = "\improper Apparat Voron - Dormitory"
	icon_state = "voron_dormitory"
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/voron/closets
	name = "\improper Apparat Voron - Closets"
	icon_state = "voron_closets"

/area/polarplanet/voron/restroom
	name = "\improper Apparat Voron - Restroom"
	icon_state = "voron_restroom"
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/voron/maintenance
	name = "\improper Apparat Voron - Maintenance"
	icon_state = "voron_maintenance"

/area/polarplanet/voron/quartermaster
	name = "\improper Apparat Voron - Quartermaster"
	icon_state = "voron_quartermaster"

/area/polarplanet/voron/quartermaster_room
	name = "\improper Apparat Voron - Quartermaster Room"
	icon_state = "voron_quartermaster_room"

/area/polarplanet/voron/bridge
	name = "\improper Apparat Voron - Bridge"
	icon_state = "voron_bridge"
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/voron/cargo_warehouse
	name = "\improper Apparat Voron - Cargo Warehouse"
	icon_state = "voron_cargo_warehouse"

/area/polarplanet/voron/entrance
	name = "\improper Apparat Voron - Entrance"
	icon_state = "voron_entrance"
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/voron/supply_entrance
	name = "\improper Apparat Voron - Supply Entrance"
	icon_state = "voron_supply_entrance"
	environment_type = ENVIRONMENT_ROOM

/area/polarplanet/voron/break_room
	name = "\improper Apparat Voron - Break Room"
	icon_state = "voron_break_room"

/area/polarplanet/voron/infirmary
	name = "\improper Apparat Voron - Infirmary"
	icon_state = "voron_infirmary"

/area/polarplanet/voron/mining_closets
	name = "\improper Apparat Voron - Mining Closets"
	icon_state = "voron_mining_closets"

/area/polarplanet/voron/substation
	name = "\improper Apparat Voron - Substation"
	icon_state = "voron_substation"

/area/polarplanet/voron/refinery_line
	name = "\improper Apparat Voron - Refinery Line"
	icon_state = "voron_refinery_line"

/area/polarplanet/voron/mech_bay
	name = "\improper Apparat Voron - Mech Bay"
	icon_state = "voron_mech_bay"

/area/polarplanet/voron/mining_warehouse
	name = "\improper Apparat Voron - Mining Warehouse"
	icon_state = "voron_mining_warehouse"

/area/polarplanet/voron/hallway2
	name = "\improper Apparat Voron - Hallway Deck 2"
	icon_state = "voron_hallway2"

/area/polarplanet/voron/hallway1
	name = "\improper Apparat Voron - Hallway Deck 1"
	icon_state = "voron_hallway1"
