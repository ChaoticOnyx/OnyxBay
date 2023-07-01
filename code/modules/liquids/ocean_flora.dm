/obj/structure/flora/ocean
	icon = 'icons/obj/liquids/flora/ocean_flora.dmi'
	var/random_variants = 0

/obj/structure/flora/ocean/Initialize(mapload)
	. = ..()
	if(random_variants)
		icon_state = "[icon_state][rand(1,random_variants)]"

/obj/structure/flora/ocean/glowweed
	name = "glow weed"
	icon_state = "glowweed"
	desc = "A plant with glowing bulbs at the end of it."
	random_variants = 3
	light_color = COLOR_CYAN
	light_outer_range = 1.5

/obj/structure/flora/ocean/seaweed
	name = "sea weed"
	icon_state = "seaweed"
	desc = "Just your regular seaweed."
	random_variants = 5

/obj/structure/flora/ocean/longseaweed
	name ="sea weed"
	icon_state = "longseaweed"
	desc = "Less so regular seaweed. This one is very long."
	random_variants = 4

/obj/structure/flora/ocean/coral
	name = "coral"
	icon_state = "coral"
	desc = "Beautiful coral."
	random_variants = 3
	density = TRUE

#define SCRAP_WELD_LOW 7
#define SCRAP_WELD_HIGH 12

#define SCRAP_METAL_YIELD_LOW 12
#define SCRAP_METAL_YIELD_HIGH 20

/obj/structure/flora/scrap
	name = "scrap metal"
	desc = "A huge chunk of metal, rusted and worn. Perhaps it can still be salvaged into something useful."
	icon = 'icons/obj/liquids/flora/scrap.dmi'
	icon_state = "scrap"
	anchored = FALSE
	density = TRUE
	var/random_variants = 3
	var/welds_remaining = 0

/obj/structure/flora/scrap/Initialize(mapload)
	. = ..()
	welds_remaining = rand(SCRAP_WELD_LOW, SCRAP_WELD_HIGH)
	if(random_variants)
		icon_state = "[icon_state][rand(1,random_variants)]"

/obj/structure/flora/scrap/attackby(obj/item/O, mob/user)
	..()
	if(isWelder(O))
		welder_act(user, O, TRUE)


/obj/structure/flora/scrap/proc/welder_act(mob/living/user, obj/item/weldingtool/WT, first = FALSE)
	if(!WT.isOn()) return
	if (WT.get_fuel() <5) // uses up 5 fuel.
		return

	playsound(src, 'sound/items/welder2.ogg', 50, TRUE)
	if(first)
		to_chat(user, SPAN_NOTICE("You start slicing the [src]..."))

	if(do_after(user, 20, src))
		if(!src || !user || !WT.remove_fuel(5, user)) return
		welds_remaining--
		if(welds_remaining <= 0)
			to_chat(user, SPAN_NOTICE("You successfully salvage [src]."))
			new /obj/item/stack/material/steel(get_turf(src), rand(SCRAP_METAL_YIELD_LOW, SCRAP_METAL_YIELD_HIGH))
			qdel(src)
		else
			welder_act(user, WT)
	return TRUE

#undef SCRAP_WELD_LOW
#undef SCRAP_WELD_HIGH

#undef SCRAP_METAL_YIELD_LOW
#undef SCRAP_METAL_YIELD_HIGH

/obj/effect/spawner/liquids_spawner
	name = "Liquids Spawner (Water, Waist-Deep)"
	icon = 'icons/effects/liquid.dmi'
	icon_state = "spawner"
	color = "#AAAAAA77"
	var/reagent_list = list(/datum/reagent/water = ONE_LIQUIDS_HEIGHT*LIQUID_WAIST_LEVEL_HEIGHT)
	var/temp = 20 CELSIUS

/obj/effect/spawner/liquids_spawner/Initialize(mapload)
	. = ..()

	if(!isturf(loc))
		return
	var/turf/T = loc
	T.add_liquid_list(reagent_list, FALSE, temp)

/obj/effect/spawner/liquids_spawner/puddle
	name = "Liquids Spawner (Water, Puddle)"
	reagent_list = list(/datum/reagent/water = ONE_LIQUIDS_HEIGHT)

/obj/effect/spawner/liquids_spawner/ankles
	name = "Liquids Spawner (Water, Ankle-Deep)"
	reagent_list = list(/datum/reagent/water = ONE_LIQUIDS_HEIGHT*LIQUID_ANKLES_LEVEL_HEIGHT)

/obj/effect/spawner/liquids_spawner/shoulders
	name = "Liquids Spawner (Water, Shoulder-Deep)"
	reagent_list = list(/datum/reagent/water = ONE_LIQUIDS_HEIGHT*LIQUID_SHOULDERS_LEVEL_HEIGHT)

/obj/effect/spawner/liquids_spawner/fulltile
	name = "Liquids Spawner (Water, Fulltile)"
	reagent_list = list(/datum/reagent/water = ONE_LIQUIDS_HEIGHT*LIQUID_FULLTILE_LEVEL_HEIGHT)

/obj/effect/spawner/liquids_spawner/acid
	name = "Liquids Spawner (Sulfuric Acid, Waist-Deep)"
	color = "#00FF32"
	reagent_list = list(/datum/reagent/acid = ONE_LIQUIDS_HEIGHT*LIQUID_WAIST_LEVEL_HEIGHT)

/obj/effect/spawner/liquids_spawner/acid/puddle
	name = "Liquids Spawner (Sulfuric Acid, Puddle)"
	reagent_list = list(/datum/reagent/acid = ONE_LIQUIDS_HEIGHT)

/obj/effect/spawner/ocean_curio
	name = "Ocean Curio Spawner"
	var/default_1 = /obj/structure/flora/ocean/seaweed
	var/default_2 = /obj/structure/flora/ocean/longseaweed
	var/allowed_area_types = list(/area/ocean = TRUE, /area/ocean/generated = TRUE)

/obj/effect/spawner/ocean_curio/Initialize(mapload)
	. = ..()

	//Way to not spawn stuff inside ruins etc.
	var/area/A = get_area(src)
	if(!allowed_area_types[A.type])
		return
	var/turf/T = get_turf(src)
	if(T.turf_flags & TURF_FLAG_NORUINS)
		return

	var/to_spawn_path

	var/random = rand(1,80)
	switch(random)
		if(1 to 3)
			to_spawn_path = /obj/structure/flora/scrap
		if(4 to 6) //Ocean trash, I guess
			to_spawn_path = /obj/random/maintenance
		else
			if(prob(50))
				to_spawn_path = default_1
			else
				to_spawn_path = default_2
	new to_spawn_path(T)

/obj/effect/spawner/ocean_curio/rock
	default_1 = /obj/structure/rock/flora
	default_2 = /obj/structure/rock/flora/pile
