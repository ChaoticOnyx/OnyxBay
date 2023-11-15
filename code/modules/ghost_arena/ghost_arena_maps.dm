/datum/map_template/arena_map/init_atoms(list/atoms)
	. = ..()
	for(var/atom/A in atoms)
		if(!istype(A, /turf))
			continue

		SSarena.ghost_arena_turfs += A

/datum/map_template/arena_map/dust2
	name = "Dust 2"
	width = 46
	height = 46
	mappaths = list("maps/ghost_arena/de_dust2.dmm")

/datum/map_template/arena_map/inferno
	name = "Inferno"
	width = 46
	height = 46
	mappaths = list("maps/ghost_arena/de_inferno.dmm")

/datum/map_template/arena_map/brig
	name = "Brig"
	width = 46
	height = 46
	mappaths = list("maps/ghost_arena/de_brig.dmm")
