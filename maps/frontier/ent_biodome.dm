/obj/map_ent/biodome
	name = "util_biodome"
	icon_state = "util_bio"

	var/ev_biodome
	var/ev_result

/obj/map_ent/biodome/activate()
	var/target_biodome = ev_biodome

	if(!target_biodome)
		target_biodome = config.mapping.preferable_biodome

	// TODO: add check for target_biodome still not being picked, possibly force random
	if(target_biodome == MAP_BIO_RANDOM)
		target_biodome = pick(MAP_BIO_FOREST, MAP_BIO_BEACH, MAP_BIO_CONCERT, MAP_BIO_WINTER, MAP_BIO_NANOTRASEN)

	ev_result = "maps/frontier/biodome/[target_biodome].dmm"
