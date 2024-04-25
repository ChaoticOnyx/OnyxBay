/datum/universal_state/averno
	name = "Averno"
	desc = "Averno penetrated normal reality."

/datum/universal_state/averno/OnShuttleCall()
	return TRUE

/datum/universal_state/averno/OnEnter()
	set background = TRUE

	var/list/areas = area_repository.get_areas_by_z_level(GLOB.station_areas)
	for(var/i in areas)
		var/area/A = areas[i]
		for(var/turf/simulated/floor/T in A)
			if(T.holy)
				explosion(T, 1, 1, 1, 3)
			else if (prob(1))
				switch(rand(100))
					if(0 to 80)
						T.cultify_floor()
					else
						new /mob/living/simple_animal/hostile/faithless(T)
