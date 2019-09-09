/turf/simulated/wall/r_wall
	icon_state = "rgeneric"
/turf/simulated/wall/r_wall/New(var/newloc)
	..(newloc, MATERIAL_PLASTEEL, MATERIAL_PLASTEEL) //3strong

/turf/simulated/wall/ocp_wall
	icon_state = "rgeneric"
/turf/simulated/wall/ocp_wall/New(var/newloc)
	..(newloc, MATERIAL_OSMIUM_CARBIDE_PLASTEEL, MATERIAL_OSMIUM_CARBIDE_PLASTEEL)

/turf/simulated/wall/cult
	icon_state = "cult"

/turf/simulated/wall/cult/New(var/newloc, var/reinforce = 0)
	..(newloc, MATERIAL_CULT, reinforce ? MATERIAL_REINFORCED_CULT : null)

/turf/simulated/wall/cult/reinf/New(var/newloc)
	..(newloc, 1)

/turf/simulated/wall/cult/dismantle_wall()
	GLOB.cult.remove_cultiness(CULTINESS_PER_TURF)
	..()

/turf/unsimulated/wall/cult
	name = "cult wall"
	desc = "Hideous images dance beneath the surface."
	icon = 'icons/turf/wall_masks.dmi'
	icon_state = "cult"

/turf/simulated/wall/iron/New(var/newloc)
	..(newloc, MATERIAL_IRON)

/turf/simulated/wall/uranium/New(var/newloc)
	..(newloc, MATERIAL_URANIUM)

/turf/simulated/wall/diamond/New(var/newloc)
	..(newloc, MATERIAL_DIAMOND)

/turf/simulated/wall/gold/New(var/newloc)
	..(newloc, MATERIAL_GOLD)

/turf/simulated/wall/silver/New(var/newloc)
	..(newloc, MATERIAL_SILVER)

/turf/simulated/wall/phoron/New(var/newloc)
	..(newloc, MATERIAL_PHORON)

/turf/simulated/wall/sandstone/New(var/newloc)
	..(newloc, MATERIAL_SANDSTONE)

/turf/simulated/wall/wood/New(var/newloc)
	..(newloc, MATERIAL_WOOD)

/turf/simulated/wall/ironphoron/New(var/newloc)
	..(newloc, MATERIAL_IRON, MATERIAL_PHORON)

/turf/simulated/wall/golddiamond/New(var/newloc)
	..(newloc, MATERIAL_GOLD, MATERIAL_DIAMOND)

/turf/simulated/wall/silvergold/New(var/newloc)
	..(newloc, MATERIAL_SILVER, MATERIAL_GOLD)

/turf/simulated/wall/sandstonediamond/New(var/newloc)
	..(newloc, MATERIAL_SANDSTONE, MATERIAL_DIAMOND)

// Kind of wondering if this is going to bite me in the butt.
/turf/simulated/wall/voxshuttle/New(var/newloc)
	..(newloc, MATERIAL_VOX)

/turf/simulated/wall/voxshuttle/attackby()
	return

/turf/simulated/wall/titanium/New(var/newloc)
	..(newloc, MATERIAL_TITANIUM)

/turf/simulated/wall/alium
	icon_state = "jaggy"
	floor_type = /turf/simulated/floor/misc/fixed/alium

/turf/simulated/wall/alium/New(var/newloc)
	..(newloc, MATERIAL_ALIUMIUM)

/turf/simulated/wall/alium/ex_act(severity)
	if(prob(explosion_resistance))
		return
	..()
