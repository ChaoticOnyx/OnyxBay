/turf/simulated/openspace/ocean
	name = "ocean"
	planetary_atmos = TRUE
	baseturfs = /turf/simulated/openspace/ocean
	var/replacement_turf = /turf/simulated/misc/ocean

/turf/simulated/openspace/ocean/Initialize(mapload)
	. = ..()

	for(var/obj/structure/flora/plant in contents)
		qdel(plant)
	var/turf/T = below()
	if(T)
		if(T.turf_flags & NO_RUINS)
			ChangeTurf(replacement_turf, null, CHANGETURF_IGNORE_AIR)
			return
		if(!ismineralturf(T))
			return
		var/turf/closed/mineral/M = T
		M.mineralAmt = 0
		M.gets_drilled()
		baseturfs = /turf/simulated/openspace/ocean //This is to ensure that IF random turf generation produces a openturf, there won't be other turfs assigned other than openspace.

/turf/simulated/openspace/ocean/Initialize(mapload)
	. = ..()
	if(liquids)
		if(liquids.immutable)
			liquids.remove_turf(src)
		else
			qdel(liquids, TRUE)
	var/obj/effect/abstract/liquid_turf/immutable/new_immmutable = SSliquids.get_immutable(/obj/effect/abstract/liquid_turf/immutable/ocean)
	new_immmutable.add_turf(src)

/turf/simulated/misc/ironsand/ocean
	planetary_atmos = TRUE
	baseturfs = /turf/simulated/misc/ocean

/turf/simulated/misc/ironsand/ocean/Initialize(mapload)
	. = ..()
	if(liquids)
		if(liquids.immutable)
			liquids.remove_turf(src)
		else
			qdel(liquids, TRUE)
	var/obj/effect/abstract/liquid_turf/immutable/new_immmutable = SSliquids.get_immutable(/obj/effect/abstract/liquid_turf/immutable/ocean)
	new_immmutable.add_turf(src)


/turf/simulated/misc/ocean/rock
	name = "rock"
	baseturfs = /turf/simulated/misc/ocean/rock
	icon = 'icons/turf/seafloor.dmi'
	icon_state = "seafloor"
	base_icon_state = "seafloor"
	rand_variants = 0

/turf/simulated/misc/ocean/rock/warm
	liquid_type = /obj/effect/abstract/liquid_turf/immutable/ocean/warm

/turf/simulated/misc/ocean/rock/warm/fissure
	name = "fissure"
	icon = 'icons/turf/fissure.dmi'
	icon_state = "fissure-0"
	base_icon_state = "fissure"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_FISSURE
	canSmoothWith = SMOOTH_GROUP_FISSURE
	light_range = 3
	light_color = LIGHT_COLOR_LAVA

/turf/simulated/misc/ocean/rock/medium
	icon_state = "seafloor_med"
	base_icon_state = "seafloor_med"
	baseturfs = /turf/simulated/misc/ocean/rock/medium

/turf/simulated/misc/ocean/rock/heavy
	icon_state = "seafloor_heavy"
	base_icon_state = "seafloor_heavy"
	baseturfs = /turf/simulated/misc/ocean/rock/heavy

/turf/simulated/misc/ocean
	gender = PLURAL
	name = "ocean sand"
	baseturfs = /turf/simulated/misc/ocean
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	base_icon_state = "asteroid"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	planetary_atmos = TRUE
	var/rand_variants = 12
	var/rand_chance = 30
	var/liquid_type = /obj/effect/abstract/liquid_turf/immutable/ocean

/turf/simulated/misc/ocean/Initialize(mapload)
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

/turf/simulated/floor/plating/ocean_plating
	planetary_atmos = TRUE
	baseturfs = /turf/simulated/misc/ocean

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
	planetary_atmos = TRUE
	baseturfs = /turf/simulated/floor/iron/ocean

/turf/simulated/floor/iron/ocean/Initialize(mapload)
	. = ..()
	if(liquids)
		if(liquids.immutable)
			liquids.remove_turf(src)
		else
			qdel(liquids, TRUE)
	var/obj/effect/abstract/liquid_turf/immutable/new_immmutable = SSliquids.get_immutable(/obj/effect/abstract/liquid_turf/immutable/ocean)
	new_immmutable.add_turf(src)

/turf/closed/mineral/random/ocean
	baseturfs = /turf/simulated/misc/ocean/rock/heavy
	turf_type = /turf/simulated/misc/ocean/rock/heavy
	color = "#58606b"

/turf/closed/mineral/random/high_chance/ocean
	baseturfs = /turf/simulated/misc/ocean/rock/heavy
	turf_type = /turf/simulated/misc/ocean/rock/heavy
	color = "#58606b"

/turf/closed/mineral/random/low_chance/ocean
	baseturfs = /turf/simulated/misc/ocean/rock/heavy
	turf_type = /turf/simulated/misc/ocean/rock/heavy
	color = "#58606b"

/turf/closed/mineral/random/stationside/ocean
	baseturfs = /turf/simulated/misc/ocean/rock/heavy
	turf_type = /turf/simulated/misc/ocean/rock/heavy
	color = "#58606b"

/obj/effect/abstract/liquid_turf/immutable/canal
	starting_mixture = list(/datum/reagent/water = 100)

/turf/simulated/misc/canal
	gender = PLURAL
	name = "canal"
	baseturfs = /turf/simulated/misc/canal
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	base_icon_state = "asteroid"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	liquid_height = -30
	turf_height = -30

/turf/simulated/misc/canal/Initialize(mapload)
	. = ..()
	if(liquids)
		if(liquids.immutable)
			liquids.remove_turf(src)
		else
			qdel(liquids, TRUE)
	var/obj/effect/abstract/liquid_turf/immutable/new_immmutable = SSliquids.get_immutable(/obj/effect/abstract/liquid_turf/immutable/canal)
	new_immmutable.add_turf(src)

/turf/simulated/misc/canal_mutable
	gender = PLURAL
	name = "canal"
	baseturfs = /turf/simulated/misc/canal_mutable
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	base_icon_state = "asteroid"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	liquid_height = -30
	turf_height = -30

/turf/simulated/floor/iron/submarine
	name = "submarine floor"
	icon = 'icons/turf/submarine.dmi'
	base_icon_state = "submarine_floor"
	icon_state = "submarine_floor"
	liquid_height = -30
	turf_height = -30

/turf/simulated/floor/iron/submarine/rust_heretic_act()
	return

/turf/simulated/floor/iron/submarine_vents
	name = "submarine floor"
	icon = 'icons/turf/submarine.dmi'
	base_icon_state = "submarine_vents"
	icon_state = "submarine_vents"
	liquid_height = -30
	turf_height = -30

/turf/simulated/floor/iron/submarine_vents/rust_heretic_act()
	return

/turf/simulated/floor/iron/submarine_perf
	name = "submarine floor"
	icon = 'icons/turf/submarine.dmi'
	base_icon_state = "submarine_perf"
	icon_state = "submarine_perf"
	liquid_height = -30
	turf_height = -30

/turf/simulated/floor/iron/submarine_perf/rust_heretic_act()
	return

//For now just a titanium wall. I'll make sprites for it later /// They did not, in fact, make sprites for it later
/turf/closed/wall/mineral/titanium/submarine
	name = "submarine wall"
