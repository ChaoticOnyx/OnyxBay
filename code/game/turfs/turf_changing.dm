/turf/proc/ReplaceWithLattice()
	var base_turf = get_base_turf_by_area(src)
	if(type != base_turf)
		ChangeTurf(get_base_turf_by_area(src))
	if(!locate(/obj/structure/lattice) in src)
		new /obj/structure/lattice(src)

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		qdel(L)
// Called after turf replaces old one
/turf/proc/post_change()
	levelupdate()
	var/turf/simulated/open/T = GetAbove(src)
	if(istype(T))
		T.update_icon()

//Creates a new turf
/turf/proc/ChangeTurf(turf/N, tell_universe = TRUE, force_lighting_update = FALSE, keep_air = FALSE)
	if(!ispath(N))
		CRASH("Wrong turf-type submitted to ChangeTurf()")

	// Spawning space in the middle of a multiz stack should just spawn an open turf.
	if(ispath(N, /turf/space))
		var/turf/below = GetBelow(src)
		if(istype(below) && !isspaceturf(below))
			var/area/A = get_area(src)
			N = A?.open_turf || open_turf_type || /turf/simulated/open

	if (!(atom_flags & ATOM_FLAG_INITIALIZED))
		return new N(src)

	// This makes sure that turfs are not changed to space when one side is part of a zone
	if(ispath(N, /turf/space))
		var/turf/below = GetBelow(src)
		if(istype(below) && !istype(below,/turf/space))
			N = below.density ? /turf/simulated/floor/plating/airless : /turf/simulated/open

	var/obj/fire/old_fire = fire
	var/old_density = density
	var/old_opacity = opacity
	var/old_dynamic_lighting = dynamic_lighting
	var/old_affecting_lights = affecting_lights
	var/old_lighting_overlay = lighting_overlay
	var/old_corners = corners
	var/old_outside = is_outside
	var/old_is_open = is_open()
	var/old_zone_membership_candidate = zone_membership_candidate

	var/datum/gas_mixture/old_air
	if(keep_air)
		if(zone)
			c_copy_air()
			old_air = air
		else
			old_air = return_air()

	changing_turf = TRUE

	if(connections) connections.erase_all()

	ClearOverlays()
	underlays.Cut()
	if(istype(src,/turf/simulated))
		//Yeah, we're just going to rebuild the whole thing.
		//Despite this being called a bunch during explosions,
		//the zone will only really do heavy lifting once.
		var/turf/simulated/S = src
		if(S.zone) S.zone.rebuild()

	// Closest we can do as far as giving sane alerts to listeners. In particular, this calls Exited and moved events in a self-consistent way.
	var/list/old_contents = list()
	for(var/atom/movable/A in src)
		if(QDELING(A))
			continue
		old_contents += A
		A.forceMove(null)

	var/old_opaque_counter = opaque_counter

	var/old_lookups = comp_lookup?.Copy()
	var/old_components = datum_components?.Copy()
	var/old_signals = signal_procs?.Copy()
	comp_lookup?.Cut()
	datum_components?.Cut()
	signal_procs?.Cut()

	// Run the Destroy() chain.
	qdel(src)

	var/turf/simulated/W = new N(src)

	// Update ZAS, atmos and fire.
	if(W.can_inherit_air)
		W.air = old_air
	if(old_fire)
		if(W.simulated)
			W.fire = old_fire
		else if(old_fire)
			qdel(old_fire)

	comp_lookup = old_lookups
	datum_components = old_components
	signal_procs = old_signals

	for(var/atom/movable/A in old_contents)
		A.forceMove(W)

	W.opaque_counter = old_opaque_counter
	W.RecalculateOpacity()

	if(tell_universe)
		GLOB.universe.OnTurfChange(W)

	SSair.mark_for_update(src) //handle the addition of the new turf.

	for(var/turf/space/S in range(W,1))
		S.update_starlight()

	W.post_change()
	. = W

	if(lighting_overlays_initialised)
		lighting_overlay = old_lighting_overlay
		if (lighting_overlay && lighting_overlay.loc != src)
			// This is a hack, but I can't figure out why the fuck they're not on the correct turf in the first place.
			lighting_overlay.forceMove(src)

		affecting_lights = old_affecting_lights
		corners = old_corners

		if ((old_opacity != opacity) || (dynamic_lighting != old_dynamic_lighting) || force_lighting_update)
			reconsider_lights()

		if (dynamic_lighting != old_dynamic_lighting)
			if (dynamic_lighting)
				lighting_build_overlay()
			else
				lighting_clear_overlay()

	// In case the turf isn't marked for update in Initialize (e.g. space), we call this to create any unsimulated edges necessary.
	if(W.zone_membership_candidate != old_zone_membership_candidate)
		SSair.mark_for_update(src)

	// we check the var rather than the proc, because area outside values usually shouldn't be set on turfs
	W.last_outside_check = OUTSIDE_UNCERTAIN
	if(W.is_outside != old_outside)
		// This will check the exterior atmos participation of this turf and all turfs connected by open space below.
		W.set_outside(old_outside)
	else if(HasBelow(z) && (W.is_open() != old_is_open)) // Otherwise, we do it here if the open status of the turf has changed.
		var/turf/checking = src
		while(HasBelow(checking.z))
			checking = GetBelow(checking)
			if(!isturf(checking))
				break

			checking.update_external_atmos_participation()
			if(!checking.is_open())
				break

	for(var/turf/T in RANGE_TURFS(1, src))
		T.update_icon()

	SEND_SIGNAL(src, SIGNAL_TURF_CHANGED, src, old_density, density, old_opacity, opacity)

/turf/proc/transport_properties_from(turf/other)
	if(!istype(other, src.type))
		return 0
	src.set_dir(other.dir)
	src.icon_state = other.icon_state
	src.icon = other.icon
	CopyOverlays(other)
	src.underlays = other.underlays.Copy()
	if(other.decals)
		src.decals = other.decals.Copy()
		src.update_icon()
	return 1

//I would name this copy_from() but we remove the other turf from their air zone for some reason
/turf/simulated/transport_properties_from(turf/simulated/other)
	if(!..())
		return 0

	if(other.zone)
		if(!src.air)
			src.make_air()
		src.air.copy_from(other.zone.air)
		other.zone.remove(other)
	return 1


//No idea why resetting the base appearence from New() isn't enough, but without this it doesn't work
/turf/simulated/shuttle/wall/corner/transport_properties_from(turf/simulated/other)
	. = ..()
	reset_base_appearance()
