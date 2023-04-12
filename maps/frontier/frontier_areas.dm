// Security

/area/security/armory_lobby
	name = "\improper Security Lobby"
	icon_state = "brig"

/area/security/sec_locker
	name = "\improper Security Locker Room"
	icon_state = "brig"

/area/security/brig/solitary
	name = "Solitary Confinement"
	icon_state = "brig"

// Chapel

/area/chapel/main/mass_driver
	name = "\improper Chapel Funeral Hall"
	icon_state = "chapel"

// Engineering

/area/engineering/singularity
	name = "\improper Singularity Generator"
	icon_state = "engine"

//event

/area/event
	name = "\improper SCS Infiltrator"
	icon_state = "party"
	ambience_powered = list()
	ambience_off = list()
	ambient_music_tags = list()
	base_turf = /turf/simulated/floor/plating/rough
	requires_power = 0

//exterior

/area/event/exterior
	name = "\improper Colony Exterior"
	icon_state = "green"
	base_turf = /turf/simulated/floor/natural/jungle/dirt

/area/event/exterior/lake
	name = "\improper Azure lake"
	icon_state = "bluenew"
	base_turf = /turf/simulated/floor/natural/jungle/water

/area/event/exterior/cave
	name = "\improper Cave System"
	icon_state = "unexplored"
	base_turf = /turf/simulated/floor/natural/sand/darksand

/area/event/exterior/cave/prestation
	icon_state = "explored"

//interior

/area/event/interior
	name = "\improper Colony Reception"
	icon_state = "blue-red"
	base_turf = /turf/simulated/floor/plating

/area/event/interior/living
	name = "\improper Colony Living Space"
	icon_state = "mining_living"

/area/event/interior/warehouse
	name = "\improper Warehouse"
	icon_state = "storage"

/area/event/interior/miningship
	name = "\improper Creaker II"
	icon_state = "mining"

/area/event/interior/administrative
	name = "\improper Administration Wing"
	icon_state = "blueold"

/area/event/interior/rnd
	name = "\improper Colony RND"
	icon_state = "outpost_research"

/area/event/interior/tramstation
	name = "\improper Tram Station"
	icon_state = "voron"
	base_turf = /turf/simulated/floor/natural/sand/darksand

/area/event/interior/archeology
	name = "\improper Archeology"
	icon_state = "anomaly"

/area/event/interior/fort
	name = "\improper The Clown Fort"
	icon_state = "Tactical"

//old

/area/event/interior/old
	name = "\improper Ancient Section"
	icon_state = "cryo"
	base_turf = /turf/simulated/floor/natural/sand/darksand

/area/event/interior/old/med
	name = "\improper Ancient Medbay"
	icon_state = "voron_infirmary"

/area/event/interior/old/civ
	name = "\improper Ancient Living Space"
	icon_state = "amaint"

/area/event/interior/old/rnd
	name = "\improper Ancient Research Division"
	icon_state = "uresearchxeno"

/area/event/interior/old/cryo
	name = "\improper Ancient Cryo"
	icon_state = "ghettostrangeplace"
