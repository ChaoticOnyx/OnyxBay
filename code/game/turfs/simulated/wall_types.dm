/turf/simulated/wall/r_wall
	icon_state = "rgeneric"

	explosion_block = 2
/turf/simulated/wall/r_wall/New(newloc)
	..(newloc, MATERIAL_PLASTEEL, MATERIAL_PLASTEEL) //3strong

/turf/simulated/wall/ocp_wall
	icon_state = "rgeneric"

	explosion_block = 2
/turf/simulated/wall/ocp_wall/New(newloc)
	..(newloc, MATERIAL_OSMIUM_CARBIDE_PLASTEEL, MATERIAL_OSMIUM_CARBIDE_PLASTEEL)

/turf/simulated/wall/cult
	icon_state = "cult"
	var/previous_type = /turf/simulated/wall

/turf/simulated/wall/cult/New(newloc, reinforce = 0)
	..(newloc, MATERIAL_CULT, reinforce ? MATERIAL_REINFORCED_CULT : null)

/turf/simulated/wall/cult/reinf/New(newloc)
	..(newloc, 1)

/turf/simulated/wall/cult/dismantle_wall()
	GLOB.cult.remove_cultiness(CULTINESS_PER_TURF)
	..()

/turf/unsimulated/wall/cult
	name = "cult wall"
	desc = "Hideous images dance beneath the surface."
	icon = 'icons/turf/wall_masks.dmi'
	icon_state = "cult"

/turf/simulated/wall/iron/New(newloc)
	..(newloc, MATERIAL_IRON)

/turf/simulated/wall/uranium/New(newloc)
	..(newloc, MATERIAL_URANIUM)

/turf/simulated/wall/diamond/New(newloc)
	..(newloc, MATERIAL_DIAMOND)

/turf/simulated/wall/gold/New(newloc)
	..(newloc, MATERIAL_GOLD)

/turf/simulated/wall/silver/New(newloc)
	..(newloc, MATERIAL_SILVER)

/turf/simulated/wall/plasma/New(newloc)
	..(newloc, MATERIAL_PLASMA)

/turf/simulated/wall/sandstone/New(newloc)
	..(newloc, MATERIAL_SANDSTONE)

/turf/simulated/wall/wood/New(newloc)
	..(newloc, MATERIAL_WOOD)

/turf/simulated/wall/ironplasma/New(newloc)
	..(newloc, MATERIAL_IRON, MATERIAL_PLASMA)

/turf/simulated/wall/golddiamond/New(newloc)
	..(newloc, MATERIAL_GOLD, MATERIAL_DIAMOND)

/turf/simulated/wall/silvergold/New(newloc)
	..(newloc, MATERIAL_SILVER, MATERIAL_GOLD)

/turf/simulated/wall/sandstonediamond/New(newloc)
	explosion_block = 2
	..(newloc, MATERIAL_SANDSTONE, MATERIAL_DIAMOND)

// Kind of wondering if this is going to bite me in the butt.
/turf/simulated/wall/voxshuttle/New(newloc)
	..(newloc, MATERIAL_VOX)

/turf/simulated/wall/voxshuttle/attackby()
	return

/turf/simulated/wall/titanium/New(newloc)
	..(newloc, MATERIAL_TITANIUM)

/turf/simulated/wall/alium
	icon_state = "jaggy"
	floor_type = /turf/simulated/floor/misc/fixed/alium

/turf/simulated/wall/alium/New(newloc)
	..(newloc, MATERIAL_ALIUMIUM)

/turf/simulated/wall/alium/ex_act(severity)
	if(prob(explosion_resistance))
		return
	..()
