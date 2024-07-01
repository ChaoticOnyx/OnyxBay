/area/ship
	name = "\improper Ship Area"

/area/ship/cargo_hangar
	name = "\improper Cargo Hangar"
	icon_state = "cargo_hangar"

/area/ship/hallway/Initialize()
	. = ..()
	GLOB.hallway += src

/area/ship/hallway/deck
	sound_env = LARGE_ENCLOSED

/area/ship/hallway/deck/lower
	name = "\improper Lower Deck Hallway 1"
	icon_state = "hallC1"

/area/ship/hallway/deck/lower/two
	name = "\improper Lower Deck Hallway 2"
	icon_state = "hallC1"

/area/ship/hallway/deck/lower/three
	name = "\improper Lower Deck Hallway 3"
	icon_state = "hallC1"

/area/ship/hallway/deck/lower/four
	name = "\improper Lower Deck Hallway 4"
	icon_state = "hallC1"

/area/ship/hallway/deck/lower/five
	name = "\improper Lower Deck Hallway 5"
	icon_state = "hallC1"

/area/ship/hallway/deck/lower/six
	name = "\improper Lower Deck Hallway 6"
	icon_state = "hallC1"

/area/ship/hallway/deck/lower/seven
	name = "\improper Lower Deck Hallway 7"
	icon_state = "hallC1"

/area/ship/hallway/deck/lower/eight
	name = "\improper Lower Deck Hallway 8"
	icon_state = "hallC1"

/area/ship/hallway/deck/lower/nine
	name = "\improper Lower Deck Hallway 9"
	icon_state = "hallC1"

/area/ship/hallway/deck/lower/ten
	name = "\improper Lower Deck Hallway 10"
	icon_state = "hallC1"

/area/ship/hallway/deck/lower/eleven
	name = "\improper Lower Deck Hallway 11"
	icon_state = "hallC1"

/area/ship/hydroponics
	name = "\improper Hydroponics"
	icon_state = "hydro"

/area/ship/hydroponics/garden
	name = "\improper Garden"
	icon_state = "garden"

/area/ship/crew_quarters/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/ship/crew_quarters/kitchen_storage
	name = "\improper Kitchen Storage"
	icon_state = "kitchen"

/area/ship/crew_quarters/mess
	name = "\improper Mess Hall"
	icon_state = "cafeteria"

/area/ship/crew_quarters/bar
	name = "\improper Bar"
	icon_state = "bar"
	sound_env = LARGE_SOFTFLOOR

/area/ship/crew_quarters/barbackroom
	name = "\improper Bar Backroom"
	icon_state = "barBR"

/area/ship/crew_quarters/sauna
	name = "\improper Sauna"
	icon_state = "toilet"

/area/ship/server
	name = "\improper Research Server Room"
	icon_state = "server"
	ambient_music_tags = list(MUSIC_TAG_SPACE)

/area/ship/rnd
	name = "\improper Research and Development"
	icon_state = "research"
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_SCIENCE)

/area/ship/rnd/robotics
	name = "\improper Robotics Lab"
	icon_state = "robotics"

/area/ship/rnd/lab
	name = "\improper Research"
	icon_state = "toxlab"

/area/ship/medical
	ambience_powered = list(SFX_AMBIENT_SCIENCE)

/area/ship/medical/patient_a
	name = "\improper Isolation A"
	icon_state = "patients"

/area/ship/medical/patient_b
	name = "\improper Isolation B"
	icon_state = "patients"

/area/ship/medical/storage_primary
	name = "\improper Primary Storage"
	icon_state = "medbay4"

/area/ship/medical/storage_secondary
	name = "\improper Secondary Storage"
	icon_state = "medbay3"

/area/ship/medical/sleeper
	name = "\improper Emergency Treatment Room"
	icon_state = "exam_room"

/area/ship/medical/surgery
	name = "\improper Operating Theatre"
	icon_state = "surgery"

/area/ship/medical/chemistry
	name = "\improper Chemistry"
	icon_state = "chem"

/area/ship/medical/medbay_lower
	name = "\improper Medbay Hallway - Lower Deck"
	icon_state = "medbay4"

/area/ship/medical/medbreak
	name = "\improper Break Room"
	icon_state = "medbay3"

/area/ship/medical/virology
	name = "\improper Virology"
	icon_state = "virology"

/area/ship/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"
	ambience_powered = list(SFX_AMBIENT_MORGUE, SFX_AMBIENT_SCIENCE)

/area/ship/logi

/area/ship/logi/warehouse
	name = "\improper Warehouse"
	icon_state = "quartstorage"
	sound_env = LARGE_ENCLOSED

/area/ship/logi/storage
	name = "\improper Cargo Warehouse"
	icon_state = "cargounder"

/area/ship/logi/int
	name = "\improper Superintendant's Office"
	icon_state = "quart"

/area/ship/logi/office
	name = "\improper Logistics Office"
	icon_state = "quartoffice"

/area/ship/logi/breakroom
	name = "\improper Logi Break Room"
	icon_state = "cargobreak"

/area/ship/engineering/lower/engine_port
	name = "\improper Lower Port Engine"
	icon_state = "port_engine_lower"

/area/ship/engineering/lower/engine_starboard
	name = "\improper Lower Starboard Engine"
	icon_state = "starboardport_engine_lower"

/area/ship/engineering/upper/engine_port
	name = "\improper Upper Port Engine"
	icon_state = "port_engine_upper"

/area/ship/engineering/upper/engine_starboard
	name = "\improper Upper Starboard Engine"
	icon_state = "starboardport_engine_upper"

/area/ship/engineering/generator_room
	name = "\improper Generator Room"
	icon_state = "engine"
	sound_env = LARGE_ENCLOSED

/area/ship/engineering/main_smes
	name = "\improper Main SMES"
	icon_state = "engine_smes"
	sound_env = SMALL_ENCLOSED

/area/ship/engineering/linac
	name = "\improper LINAC"
	icon_state = "LINAC"
	sound_env = LARGE_ENCLOSED

/area/ship/engineering/generator_monitoring
	name = "\improper Generator Monitoring Room"
	icon_state = "engine_monitoring"

/area/ship/engineering/workshop
	name = "\improper Engineering Workshop"
	icon_state = "engineering_workshop"

/area/ship/engineering/storage
	name = "\improper Engineering Storage"
	icon_state = "engineering_storage"

/area/ship/engineering/storage
	name = "\improper Engineering Storage"
	icon_state = "engineering_storage"

/area/ship/civ/janitor
	name = "\improper Custodial Closet"
	icon_state = "janitor"

/area/ship/civ/lounge_lower
	name = "\improper Lounge - Lower Deck"
	icon_state = "louinge"

/area/ship/bridge
	name = "\improper Bridge"
	icon_state = "bridge"

/area/ship/bridge/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	sound_env = MEDIUM_SOFTFLOOR
