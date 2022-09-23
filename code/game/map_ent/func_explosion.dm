/obj/map_ent/func_explosion
	name = "func_explosion"
	icon_state = "func_explosion"

	var/ev_devastation_range = 1
	var/ev_heavy_impact_range = 2
	var/ev_light_impact_range = 3
	var/ev_flash_range = 4
	var/ev_z_transfer = TRUE
	var/ev_shaped = TRUE
	var/ev_sfx = SFX_EXPLOSION

/obj/map_ent/func_explosion/activate()
	var/turf/T = get_turf(src)

	explosion(
		T,
		ev_devastation_range,
		ev_heavy_impact_range,
		ev_light_impact_range,
		ev_flash_range,
		TRUE,
		ev_z_transfer,
		ev_shaped,
		ev_sfx
	)
