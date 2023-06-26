/turf/simulated/open/ocean
	name = "ocean"


	var/replacement_turf = /turf/simulated/floor/natural/ocean

/turf/simulated/open/ocean/Initialize(mapload)
	. = ..()

	for(var/obj/structure/flora/plant in contents)
		qdel(plant)
	var/turf/T = GetBelow()
	if(T)
		if(T.turf_flags & TURF_FLAG_NORUINS)
			ChangeTurf(replacement_turf)
			return
		if(!istype(T,/turf/simulated/mineral))
			return
		var/turf/simulated/mineral/M = T
		M.ore_left = 0
		M.GetDrilled()


/turf/simulated/open/ocean/Initialize(mapload)
	. = ..()
	if(liquids)
		if(liquids.immutable)
			liquids.remove_turf(src)
		else
			qdel(liquids, TRUE)
	var/obj/effect/abstract/liquid_turf/immutable/new_immmutable = SSliquids.get_immutable(/obj/effect/abstract/liquid_turf/immutable/ocean)
	new_immmutable.add_turf(src)

/turf/simulated/misc/ironsand/ocean



/turf/simulated/misc/ironsand/ocean/Initialize(mapload)
	. = ..()
	if(liquids)
		if(liquids.immutable)
			liquids.remove_turf(src)
		else
			qdel(liquids, TRUE)
	var/obj/effect/abstract/liquid_turf/immutable/new_immmutable = SSliquids.get_immutable(/obj/effect/abstract/liquid_turf/immutable/ocean)
	new_immmutable.add_turf(src)


/turf/simulated/floor/natural/ocean/rock
	name = "rock"

	icon = 'icons/turf/seafloor.dmi'
	icon_state = "seafloor"
	base_icon_state = "seafloor"
	rand_variants = 0

/turf/simulated/floor/natural/ocean/rock/warm
	liquid_type = /obj/effect/abstract/liquid_turf/immutable/ocean/warm

/turf/simulated/floor/natural/ocean/rock/warm/fissure
	name = "fissure"
	icon = 'icons/turf/fissure.dmi'
	icon_state = "fissure-0"
	base_icon_state = "fissure"
	light_outer_range = 3
	light_color = "#C48A18"

/turf/simulated/floor/natural/ocean/rock/medium
	icon_state = "seafloor_med"
	base_icon_state = "seafloor_med"


/turf/simulated/floor/natural/ocean/rock/heavy
	icon_state = "seafloor_heavy"
	base_icon_state = "seafloor_heavy"


/turf/simulated/floor/natural/ocean
	gender = PLURAL
	name = "ocean sand"

	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	base_icon_state = "asteroid"
	footstep_sound = SFX_FOOTSTEP_ASTEROID

	var/rand_variants = 12
	var/rand_chance = 30
	var/liquid_type = /obj/effect/abstract/liquid_turf/immutable/ocean

/turf/simulated/floor/natural/ocean/Initialize(mapload)
	. = ..()
	if(liquids)
		if(liquids.immutable)
			liquids.remove_turf(src)
		else
			qdel(liquids, TRUE)
	var/obj/effect/abstract/liquid_turf/immutable/new_immmutable = SSliquids.get_immutable(liquid_type)
	new_immmutable.add_turf(src)

	if(rand_variants && prob(rand_chance))
		var/random = rand(1,rand_variants)
		icon_state = "[icon_state][random]"
		base_icon_state = "[icon_state][random]"

/turf/simulated/floor/plating/ocean_plating/Initialize(mapload)
	. = ..()
	if(liquids)
		if(liquids.immutable)
			liquids.remove_turf(src)
		else
			qdel(liquids, TRUE)
	var/obj/effect/abstract/liquid_turf/immutable/new_immmutable = SSliquids.get_immutable(/obj/effect/abstract/liquid_turf/immutable/ocean)
	new_immmutable.add_turf(src)

/turf/simulated/floor/iron/ocean



/turf/simulated/floor/iron/ocean/Initialize(mapload)
	. = ..()
	if(liquids)
		if(liquids.immutable)
			liquids.remove_turf(src)
		else
			qdel(liquids, TRUE)
	var/obj/effect/abstract/liquid_turf/immutable/new_immmutable = SSliquids.get_immutable(/obj/effect/abstract/liquid_turf/immutable/ocean)
	new_immmutable.add_turf(src)

/turf/simulated/mineral/random/ocean
	mined_turf = /turf/simulated/floor/natural/ocean/rock/heavy
	color = "#58606b"

/turf/simulated/mineral/random/high_chance/ocean
	mined_turf = /turf/simulated/floor/natural/ocean/rock/heavy
	color = "#58606b"

/turf/simulated/mineral/random/stationside/ocean
	mined_turf = /turf/simulated/floor/natural/ocean/rock/heavy
	color = "#58606b"

/obj/effect/abstract/liquid_turf/immutable/canal
	starting_mixture = list(/datum/reagent/water = 100)

/turf/simulated/floor/natural/sand/canal
	gender = PLURAL
	name = "canal"

	footstep_sound = SFX_FOOTSTEP_ASTEROID
	liquid_height = -30
	turf_height = -30

/turf/simulated/floor/natural/sand/canal/Initialize(mapload)
	. = ..()
	if(liquids)
		if(liquids.immutable)
			liquids.remove_turf(src)
		else
			qdel(liquids, TRUE)
	var/obj/effect/abstract/liquid_turf/immutable/new_immmutable = SSliquids.get_immutable(/obj/effect/abstract/liquid_turf/immutable/canal)
	new_immmutable.add_turf(src)

/turf/simulated/floor/natural/sand/canal_mutable
	gender = PLURAL
	name = "canal"

	footstep_sound = SFX_FOOTSTEP_ASTEROID
	liquid_height = -30
	turf_height = -30

/turf/simulated/floor/iron/submarine
	name = "submarine floor"
	icon = 'icons/turf/submarine.dmi'
	base_icon_state = "submarine_floor"
	icon_state = "submarine_floor"
	liquid_height = -30
	turf_height = -30

/turf/simulated/floor/iron/submarine_vents
	name = "submarine floor"
	icon = 'icons/turf/submarine.dmi'
	base_icon_state = "submarine_vents"
	icon_state = "submarine_vents"
	liquid_height = -30
	turf_height = -30

/turf/simulated/floor/iron/submarine_perf
	name = "submarine floor"
	icon = 'icons/turf/submarine.dmi'
	base_icon_state = "submarine_perf"
	icon_state = "submarine_perf"
	liquid_height = -30
	turf_height = -30

//For now just a titanium wall. I'll make sprites for it later /// They did not, in fact, make sprites for it later
/turf/closed/wall/mineral/titanium/submarine
	name = "submarine wall"
