/turf/simulated/floor/iron/pool
	name = "pool floor"
	floor_tile = /obj/item/stack/tile/iron/pool
	icon = 'modules/liquids/assets/turf/pool_tile.dmi'
	base_icon_state = "pool_tile"
	icon_state = "pool_tile"
	liquid_height = -30
	turf_height = -30

/turf/simulated/floor/iron/pool/rust_heretic_act()
	return

/turf/simulated/floor/iron/elevated
	name = "elevated floor"
	floor_tile = /obj/item/stack/tile/iron/elevated
	icon = 'modules/liquids/assets/turf/elevated_plasteel.dmi'
	icon_state = "elevated_plasteel-0"
	base_icon_state = "elevated_plasteel"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_ELEVATED_PLASTEEL
	canSmoothWith = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_ELEVATED_PLASTEEL
	liquid_height = 30
	turf_height = 30

/turf/simulated/floor/iron/elevated/rust_heretic_act()
	return

/turf/simulated/floor/iron/lowered
	name = "lowered floor"
	floor_tile = /obj/item/stack/tile/iron/lowered
	icon = 'modules/liquids/assets/turf/lowered_plasteel.dmi'
	icon_state = "lowered_plasteel-0"
	base_icon_state = "lowered_plasteel"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_ELEVATED_PLASTEEL
	canSmoothWith = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_ELEVATED_PLASTEEL
	liquid_height = -30
	turf_height = -30

/turf/simulated/floor/iron/lowered/rust_heretic_act()
	return
