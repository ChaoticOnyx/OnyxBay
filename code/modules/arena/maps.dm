/datum/map_template/arena_map/init_atoms(list/atoms)
	. = ..()
	for(var/atom/A in atoms)
		if(!istype(A, /turf))
			continue

		SSarena.ghost_arena_turfs += A
