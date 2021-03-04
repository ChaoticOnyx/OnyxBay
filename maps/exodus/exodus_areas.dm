/datum/map/exodus
	post_round_safe_areas = list (
		/area/centcom,
		/area/shuttle/escape/centcom,
		/area/shuttle/escape_pod1,
		/area/shuttle/escape_pod2,
		/area/shuttle/escape_pod3,
		/area/shuttle/escape_pod5,
		/area/shuttle/transport/centcom,
		/area/shuttle/administration/,
		/area/shuttle/specops/centcom,
	)


////////////
//SHUTTLES//
////////////
//shuttle areas must contain at least two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.
//All shuttles should now be under shuttle since we have smooth-wall code.
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
	base_turf = /turf/simulated/floor

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

/area/shuttle/escape_pod5 //Pod 4 was lost to meteors
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

//SYNDICATES

/area/syndicate_mothership
	name = "\improper Syndicate Base"
	icon_state = "syndie-ship"
	requires_power = 0
	dynamic_lighting = 0

/area/syndicate_mothership/ninja
	name = "\improper Ninja Base"
	requires_power = 0
	base_turf = /turf/space/transit/north

//RESCUE

//names are used
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

//MINING MOTHERSHIP

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

//ENEMY

//names are used
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
	name = "\improper Exterior"

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

/area/maintenance/getto_rnd
	name = "\improper RnD Maintenance"
	icon_state = "maint_cargo"


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

/////////////
//ELEVATORS//
/////////////
/area/turbolift/security_station
	name = "Station - By Security"
	lift_announce_str = "Arriving at the station level, by the Security department."

/area/turbolift/security_maintenance
	name = "Maintenance - Below Security"
	lift_announce_str = "Arriving at the maintenance level, below the Security department."
	base_turf = /turf/simulated/floor/plating

/area/turbolift/research_station
	name = "Station - By Research"
	lift_announce_str = "Arriving at the station level, by the R&D department."

/area/turbolift/research_maintenance
	name = "Maintenance - Below Research"
	lift_announce_str = "Arriving at the maintenance level, below the R&D department."
	base_turf = /turf/simulated/floor/plating

/area/turbolift/engineering_station
	name = "Station - By Engineering"
	lift_announce_str = "Arriving at the station level, by the Engineering department."

/area/turbolift/engineering_maintenance
	name = "Maintenance - Below Engineering"
	lift_announce_str = "Arriving at the maintenance level, below the Engineering department."
	base_turf = /turf/simulated/floor/plating

/area/turbolift/cargo_station
	name = "Station - By Cargo"
	lift_announce_str = "Arriving at the station level, by the Cargo department."

/area/turbolift/cargo_maintenance
	name = "Maintenance - Below Cargo"
	lift_announce_str = "Arriving at the maintenance level, below the Cargo department."
	base_turf = /turf/simulated/floor/plating

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

/area/crew_quarters/sleep
	name = "\improper Dormitories"
	icon_state = "Sleep"

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

/area/crew_quarters/ubarbackroom //new room for bartender
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

/area/chapel/office
	name = "\improper Chapel Office"
	icon_state = "chapeloffice"

/area/chapel/crematorium
	name = "\improper Crematorium"
	icon_state = "chapelcrematorium"

/area/lawoffice
	name = "\improper Internal Affairs"
	icon_state = "law"

//Engineering

/area/engineering/
	name = "\improper Engineering"
	icon_state = "engineering"
	ambience = list("engineering_ambient")

/area/engineering/lower
	name = "\improper Engineering Lower Deck"
	icon_state = "lower_engi"
	ambience = list("engineering_ambient")

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
	ambience = list('sound/ambience/atmospherics/ambiatm1.ogg')

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


// Medbay

/area/medical/genetics
	name = "\improper Genetics Lab"
	icon_state = "genetics"

/area/medical/genetics_cloning
	name = "\improper Cloning Lab"
	icon_state = "cloning"

// Solars

/area/solar/starboard
	name = "\improper Starboard Auxiliary Solar Array"
	icon_state = "panelsS"

/area/solar/auxport
	name = "\improper Fore Port Solar Array"
	icon_state = "panelsA"

/area/solar/fore
	name = "\improper Fore Solar Array"
	icon_state = "yellow"

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

//Teleporter

/area/teleporter
	name = "\improper Teleporter"
	icon_state = "teleporter"

/area/gateway
	name = "\improper Gateway"
	icon_state = "teleporter"

//MedBay

/area/medical/medbay
	name = "\improper Medbay Hallway - Port"
	icon_state = "medbay"

//Medbay is a large area, these additional areas help level out APC load.
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
	ambience = list('sound/ambience/signal.ogg')

/area/crew_quarters/medbreak
	name = "\improper Break Room"
	icon_state = "medbay3"
	ambience = list('sound/ambience/signal.ogg')

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
	ambience = list('sound/ambience/signal.ogg')

/area/medical/storage2
	name = "\improper Medbay Storage"
	icon_state = "medbay3"
	ambience = list('sound/ambience/signal.ogg')

/area/medical/resleever
	name = "\improper Neural Lace Resleever"
	icon_state = "cloning"

//Security

/area/security/main
	name = "\improper Security Office"
	icon_state = "security"

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

/area/rnd/mixing
	name = "\improper Toxins Mixing Room"
	icon_state = "toxmix"

/area/rnd/storage
	name = "\improper Toxins Storage"
	icon_state = "toxstorage"

area/rnd/test_area
	name = "\improper Toxins Test Area"
	icon_state = "toxtest"

/area/server
	name = "\improper Research Server Room"
	icon_state = "server"

//Storage

/area/storage/art
	name = "Art Supply Storage"
	icon_state = "storage"

/area/storage/emergency
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/emergency2
	name = "Port Emergency Storage"
	icon_state = "emergencystorage"

//HALF-BUILT STATION (REPLACES DERELICT IN BAYCODE, ABOVE IS LEFT FOR DOWNSTREAM)

/area/shuttle/constructionsite/site
	name = "\improper Construction Site Shuttle"
	base_turf = /turf/simulated/floor/asteroid

//AI

/area/turret_protected
	ambience = list("ai_ambient", "science_ambient")

/area/turret_protected/ai_server_room
	name = "Messaging Server Room"
	icon_state = "ai_server"
	sound_env = SMALL_ENCLOSED

/area/turret_protected/tcomsat/port
	name = "\improper Telecoms Satellite - Port"

/area/turret_protected/tcomsat/starboard
	name = "\improper Telecoms Satellite - Starboard"

//Misc

// Telecommunications Satellite

/area/tcommsat
	ambience = list("ai_ambient", "science_ambient")

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

/area/outpost/main_outpost/shallway
	name = "Outpost Southern Hallway"

/area/outpost/main_outpost/challway
	name = "Outpost Central Hallway"

/area/outpost/main_outpost/nhallway
	name = "Outpost Northern Hallway"

/area/outpost/main_outpost/dock
	name = "Outpost Dock"
	icon_state = "bluenew"

/area/outpost/main_outpost/infirmary
	name = "Outpost Infirmary"

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

/area/outpost/mining_west
	name = "West Mining Outpost"
	icon_state = "outpost_mine_west"

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

//CentComm
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

//Thunderdr
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

/area/holodeck/source_boxingcourt
	name = "\improper Holodeck - Boxing Court"
	sound_env = ARENA

/area/holodeck/source_desert
	name = "\improper Holodeck - Desert"
	sound_env = PLAIN

/area/holodeck/source_picnicarea
	name = "\improper Holodeck - Picnic Area"
	sound_env = PLAIN

/area/holodeck/source_wildlife
	name = "\improper Holodeck - Wildlife Simulation"

/area/holodeck/source_courtroom
	name = "\improper Holodeck - Courtroom"
	sound_env = AUDITORIUM

/area/holodeck/source_basketball
	name = "\improper Holodeck - Basketball Court"
	sound_env = ARENA

/area/holodeck/source_plating
	name = "\improper Holodeck - Off"

/area/holodeck/source_emptycourt
	name = "\improper Holodeck - Empty Court"
	sound_env = ARENA

/area/holodeck/source_theatre
	name = "\improper Holodeck - Theatre"
	sound_env = CONCERT_HALL

/area/holodeck/source_thunderdomecourt
	name = "\improper Holodeck - Thunderdome Court"
	sound_env = ARENA

/area/holodeck/source_beach
	name = "\improper Holodeck - Beach"
	sound_env = PLAIN

/area/holodeck/source_snowfield
	name = "\improper Holodeck - Snow Field"
	sound_env = FOREST

/area/holodeck/source_meetinghall
	name = "\improper Holodeck - Meeting Hall"
	sound_env = AUDITORIUM

/area/holodeck/source_space
	name = "\improper Holodeck - Space"
	has_gravity = 0
	sound_env = SPACE

/area/holodeck/source_chess
	name = "\improper Holodeck - Chess Field"

/area/prison/solitary
	name = "Solitary Confinement"
	icon_state = "brig"

/area/security/range
	name = "\improper Security - Firing Range"
	icon_state = "firingrange"

/area/mine
	icon_state = "mining"
	sound_env = 5 //stoneroom

/area/mine/explored
	name = "Mine"
	icon_state = "explored"
	ambience = list('sound/ambience/mine/ambimine.ogg', 'sound/ambience/song_game.ogg')

/area/mine/unexplored
	name = "Mine"
	icon_state = "unexplored"
	ambience = list('sound/ambience/mine/ambimine.ogg', 'sound/ambience/song_game.ogg')

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
	ambience = list("ai_ambient")
	has_gravity = FALSE

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
	dynamic_lighting = 1
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

/area/solar/auxstarboard
	name = "\improper Fore Starboard Solar Array"
	icon_state = "panelsA"
