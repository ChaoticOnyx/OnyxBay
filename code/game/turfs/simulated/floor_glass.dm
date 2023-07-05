
/turf/simulated/floor/plating/transparent
	name = "window floor"
	desc = "Or is it a floor window?"
	icon = 'icons/turf/flooring/glass.dmi'
	base_icon = 'icons/turf/flooring/glass.dmi'
	icon_state = "glass_preview"
	base_icon_state = "blank"
	tile_type = /obj/item/stack/tile/floor_rough
	var/turf/below
	var/over_icon = "over"
	var/glass_icon = "glass"
	var/damage_state = 0

/turf/simulated/floor/plating/transparent/post_change()
	..()
	update()

/turf/simulated/floor/plating/transparent/Initialize()
	. = ..()
	update()

/turf/simulated/floor/plating/transparent/update_icon()
	overlays.Cut()
	icon_state = base_icon_state

	if(below)
		vis_contents += below

	var/image/under = image(icon, glass_icon)
	under.plane = FLOOR_PLANE
	under.layer = PLATING_LAYER
	overlays += under

	var/list/dirs = list()
	for(var/turf/simulated/floor/plating/transparent/GF in orange(src, 1))
		dirs += get_dir(src, GF)

	var/list/connections = dirs_to_corner_states(dirs)

	for(var/i = 1 to 4)
		var/image/I = image(icon, "[over_icon][connections[i]]", dir = 1<<(i-1))
		I.plane = FLOOR_PLANE
		I.layer = PLATING_LAYER
		overlays += I

	if(damage_state)
		var/image/I = image(icon, "damage[damage_state]")
		I.plane = FLOOR_PLANE
		I.layer = PLATING_LAYER
		overlays += I

/turf/simulated/floor/plating/transparent/proc/update()
	if(below)
		unregister_signal(below, SIGNAL_TURF_CHANGED)
		unregister_signal(below, SIGNAL_EXITED)
		unregister_signal(below, SIGNAL_ENTERED)
	below = GetBelow(src)
	if(!below)
		plane = SPACE_PLANE
		if(config.misc.starlight)
			if(locate(/turf/simulated) in orange(src,1))
				set_light(min(0.1*config.misc.starlight, 1), 1, 2.5, 1.5, "#74dcff")
	else
		plane = OPENSPACE_PLANE
		if(istype(below, /turf/space))
			if(config.misc.starlight)
				if(locate(/turf/simulated) in orange(src,1))
					set_light(min(0.1*config.misc.starlight, 1), 1, 2.5, 1.5, "#74dcff")
	//	else
	//		set_light(0)

	register_signal(below, SIGNAL_TURF_CHANGED, /turf/simulated/floor/plating/transparent/proc/turf_change)
	register_signal(below, SIGNAL_EXITED, /turf/simulated/floor/plating/transparent/proc/handle_move)
	register_signal(below, SIGNAL_ENTERED, /turf/simulated/floor/plating/transparent/proc/handle_move)
	levelupdate()
	SSopen_space.add_turf(src, 1)
	update_icon()

/turf/simulated/floor/plating/transparent/proc/handle_move(atom/current_loc, atom/movable/am, atom/changed_loc)
	//First handle objs and such
	if(!am.invisibility && isobj(am))
	//Update icons
		SSopen_space.add_turf(src, 1)
	//Check for mobs and create/destroy their shadows
	if(isliving(am))
		var/mob/living/M = am
		M.check_shadow()

//When turf changes, a bunch of things can take place
/turf/simulated/floor/plating/transparent/proc/turf_change(turf/affected)
	if(!(isopenspace(affected) || isTurfTransparent(affected)))//If affected is openspace it will add itself
		SSopen_space.add_turf(src, 1)

