/turf/simulated/floor
	name = "plating"
	icon = 'icons/turf/flooring/plating.dmi'
	icon_state = "plating"

	// Damage to flooring.
	var/broken
	var/burnt

	// Plating data.
	var/base_name = "plating"
	var/base_desc = "The naked hull."
	var/base_icon = 'icons/turf/flooring/plating.dmi'
	var/base_icon_state = "plating"
	var/base_color = null

	// Flooring data.
	var/flooring_override
	var/initial_flooring
	var/decl/flooring/flooring
	var/mineral = DEFAULT_WALL_MATERIAL

	thermal_conductivity = 0.040
	heat_capacity = 10000
	var/lava = 0

/turf/simulated/floor/proc/dismantle_floor()
	ChangeTurf(get_base_turf_by_area(src))

/turf/simulated/floor/is_plating()
	return !flooring

/turf/simulated/floor/protects_atom(atom/A)
	return (A.level <= 1 && !is_plating()) || ..()

/turf/simulated/floor/New(newloc, floortype)
	..(newloc)
	if(!floortype && initial_flooring)
		floortype = initial_flooring
	if(floortype)
		set_flooring(get_flooring_data(floortype))

/turf/simulated/floor/proc/set_flooring(decl/flooring/newflooring)
	make_plating(defer_icon_update = 1)
	flooring = newflooring
	update_icon(1)
	levelupdate()

//This proc will set floor_type to null and the update_icon() proc will then change the icon_state of the turf
//This proc auto corrects the grass tiles' siding.
/turf/simulated/floor/proc/make_plating(place_product, defer_icon_update)

	overlays.Cut()

	SetName(base_name)
	desc = base_desc
	icon = base_icon
	icon_state = base_icon_state


	if(flooring)
		flooring.on_remove()
		if(flooring.build_type && place_product)
			var/obj/F =  new flooring.build_type(src)
			if (color)
				F.color = color
			var/obj/item/stack/tile/T = null
			if (istype(F,/obj/item/stack/tile))	//checking if stack is a tile cause only tiles can store decals
				T = F
				T.stored_decals = src.decals
				src.decals = null
				if(T.stored_decals)
					F.overlays += icon("icons/obj/tiles.dmi", "decal_state")
		flooring = null

	if (base_color)
		color = base_color

	set_light(0)
	broken = null
	burnt = null
	flooring_override = null
	levelupdate()

	if(!defer_icon_update)
		update_icon(1)

/turf/simulated/floor/levelupdate()
	for(var/obj/O in src)
		O.hide(O.hides_under_flooring() && src.flooring)

	if(flooring)
		layer = TURF_LAYER
	else
		layer = PLATING_LAYER
