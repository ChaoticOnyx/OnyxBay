/turf/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'

/turf/beach/sand
	name = "Sand"
	icon_state = "sand"

/turf/beach/coastline
	name = "Coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/beach/water
	name = "Water"
	icon_state = "water"

/turf/beach/water/New()
	..()
	AddOverlays(image("icon"='icons/misc/beach.dmi',"icon_state"="water2","layer"=MOB_LAYER+0.1))
