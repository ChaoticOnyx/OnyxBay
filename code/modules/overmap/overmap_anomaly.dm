/obj/effect/overmap_anomaly

/obj/structure/overmap/asteroid
	var/required_tier = 0

/obj/effect/overmap_anomaly/star
	name = "Star"
	icon = 'icons/overmap/stellarbodies/stars.dmi'
	icon_state = "purple"

/obj/effect/overmap_anomaly/visitable
	var/datum/map_generator/planet_generator/mapgen

/obj/effect/overmap_anomaly/visitable/planetoid
	name = "Planetoid"
	icon = 'icons/overmap/stellarbodies/planetoids.dmi'
	icon_state = "planet"
