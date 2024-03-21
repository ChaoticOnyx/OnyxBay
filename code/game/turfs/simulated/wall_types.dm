/turf/simulated/wall/r_wall
	icon_state = "rgeneric"

	explosion_block = 2

/turf/simulated/wall/r_wall/Initialize(mapload)
	. = ..(mapload, MATERIAL_PLASTEEL, MATERIAL_PLASTEEL) //3strong

/turf/simulated/wall/r_wall/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.canRturf || the_rcd.construction_mode == RCD_WALLFRAME)
		return ..()

/turf/simulated/wall/r_wall/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(the_rcd.canRturf || rcd_data["[RCD_DESIGN_MODE]"] == RCD_WALLFRAME)
		return ..()
/turf/simulated/wall/ocp_wall
	icon_state = "rgeneric"

	explosion_block = 2
/turf/simulated/wall/ocp_wall/Initialize(mapload)
	. = ..(mapload, MATERIAL_OSMIUM_CARBIDE_PLASTEEL, MATERIAL_OSMIUM_CARBIDE_PLASTEEL)

/turf/simulated/wall/cult
	icon_state = "cult"
	var/previous_type = /turf/simulated/wall

/turf/simulated/wall/cult/Initialize(mapload, reinforce)
	. = ..(mapload, MATERIAL_CULT, reinforce ? MATERIAL_REINFORCED_CULT : null)

/turf/simulated/wall/cult/reinf/Initialize(mapload, reinforce)
	. = ..(mapload, 1)

/turf/simulated/wall/cult/dismantle_wall(devastated, explode, no_product)
	GLOB.cult.remove_cultiness(CULTINESS_PER_TURF)
	..()

/turf/unsimulated/wall/cult
	name = "cult wall"
	desc = "Hideous images dance beneath the surface."
	icon = 'icons/turf/wall_masks.dmi'
	icon_state = "cult"

/turf/simulated/wall/iron/Initialize(mapload)
	. = ..(mapload, MATERIAL_IRON)

/turf/simulated/wall/uranium/Initialize(mapload)
	. = ..(mapload, MATERIAL_URANIUM)

/turf/simulated/wall/diamond/Initialize(mapload)
	. = ..(mapload, MATERIAL_DIAMOND)

/turf/simulated/wall/gold/Initialize(mapload)
	. = ..(mapload, MATERIAL_GOLD)

/turf/simulated/wall/silver/Initialize(mapload)
	. = ..(mapload, MATERIAL_SILVER)

/turf/simulated/wall/plasma/Initialize(mapload)
	. = ..(mapload, MATERIAL_PLASMA)

/turf/simulated/wall/sandstone/Initialize(mapload)
	. = ..(mapload, MATERIAL_SANDSTONE)

/turf/simulated/wall/wood/Initialize(mapload)
	. = ..(mapload, MATERIAL_WOOD)

/turf/simulated/wall/ironplasma/Initialize(mapload)
	. = ..(mapload, MATERIAL_IRON, MATERIAL_PLASMA)

/turf/simulated/wall/golddiamond/Initialize(mapload)
	. = ..(mapload, MATERIAL_GOLD, MATERIAL_DIAMOND)

/turf/simulated/wall/silvergold/Initialize(mapload)
	. = ..(mapload, MATERIAL_SILVER, MATERIAL_GOLD)

/turf/simulated/wall/sandstonediamond/Initialize(mapload)
	explosion_block = 2
	. = ..(mapload, MATERIAL_SANDSTONE, MATERIAL_DIAMOND)

// Kind of wondering if this is going to bite me in the butt.
/turf/simulated/wall/voxshuttle/Initialize(mapload)
	. = ..(mapload, MATERIAL_VOX)

/turf/simulated/wall/voxshuttle/attackby()
	return

/turf/simulated/wall/titanium/Initialize(mapload)
	. = ..(mapload, MATERIAL_TITANIUM)

/turf/simulated/wall/alium
	icon_state = "jaggy"
	floor_type = /turf/simulated/floor/misc/fixed/alium

/turf/simulated/wall/alium/Initialize(mapload)
	. = ..(mapload, MATERIAL_ALIUMIUM)

/turf/simulated/wall/alium/ex_act(severity)
	if(prob(explosion_resistance))
		return
	..()
