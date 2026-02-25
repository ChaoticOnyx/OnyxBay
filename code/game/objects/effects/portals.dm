/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/portals.dmi'
	icon_state = "portal"
	density = TRUE
	unacidable = TRUE // Can't destroy energy portals.
	var/atom/target = null
	var/creator = null
	anchored = 1.0
	var/dangerous = 0
	var/failchance = 0
	var/teleport_type = /decl/teleport/sparks

/obj/effect/portal/Bumped(AM)
	. = ..()
	teleport(AM)

/obj/effect/portal/attack_hand(mob/user)
	teleport(user)

/obj/effect/portal/Initialize(mapload, end, delete_after = 300, failure_rate)
	. = ..()
	setup_portal(end, delete_after, failure_rate)
	set_next_think(world.time + 1.5 SECONDS)

/obj/effect/portal/think()
	move_all_objects()

/obj/effect/portal/Destroy()
	target = null
	return ..()

/obj/effect/portal/proc/move_all_objects()
	if(QDELETED(src))
		return
	var/turf/T = get_turf(src)
	for(var/atom/movable/M in T)
		if(iseffect(M))
			continue
		if(M.anchored && !ismech(M))
			continue
		if(!ismovable(M))
			continue
		if (!target)
			qdel(src)
			return
		if(!ismob(M) && !M.density)
			continue
		for(var/cardinal in shuffle(GLOB.cardinal))
			if(step(M, cardinal))
				break
	// if any objcets still in loc, teleport them, e.g. crates abuse
	for(var/atom/movable/M in T)
		teleport(M)

/obj/effect/portal/proc/setup_portal(end, delete_after, failure_rate)
	if(failure_rate)
		failchance = failure_rate
		if(prob(failchance))
			icon_state = "portal1"
			dangerous = 1
	target = end
	playsound(src, 'sound/effects/phasein.ogg', 25, 1)
	QDEL_IN(src, delete_after)

/obj/effect/portal/proc/teleport(atom/movable/M, ignore_checks = FALSE)
	if(istype(M, /obj/item/projectile))
		ignore_checks = TRUE

	if(iseffect(M) && !ignore_checks)
		return
	if(M.anchored && !ismech(M) && !ignore_checks)
		return
	if(!ismovable(M) && !ignore_checks)
		return
	if (!target)
		qdel(src)
		return

	if(dangerous && prob(failchance))
		var/destination_z = GLOB.using_map.get_transit_zlevel(src.z)
		do_teleport(M, locate(rand(TRANSITION_EDGE, world.maxx - TRANSITION_EDGE), rand(TRANSITION_EDGE, world.maxy -TRANSITION_EDGE), destination_z), 0)
	else
		do_teleport(M, target, type = teleport_type)
	return TRUE

/obj/effect/portal/proc/on_projectile_impact(obj/item/projectile/P, use_impact = TRUE)
	P.on_impact(src, use_impact)
	return FALSE

/obj/effect/portal/linked
	var/mask = "portal_mask"
	var/connection/atmos_connection
	var/weakref/portal_creator_weakref
	var/owner
	var/setting = 0
	var/atmos_connected = FALSE
	var/list/static/portal_cache = list()
	teleport_type = /decl/teleport/sparks/precision

/obj/effect/portal/linked/Initialize()
	. = ..()
	if(istype(loc, /obj/item/gun/portalgun))
		portal_creator_weakref = weakref(loc)
	// stable enough
	dangerous = FALSE
	failchance = FALSE

/obj/effect/portal/linked/Destroy()
	disconnect_atmospheres()
	var/obj/item/gun/portalgun/portal_creator = portal_creator_weakref?.resolve()
	if(portal_creator)
		if(src == portal_creator.blue_portal)
			portal_creator.blue_portal = null
			portal_creator.sync_portals()
		else if(src == portal_creator.red_portal)
			portal_creator.red_portal = null
			portal_creator.sync_portals()
	target = null
	log_debug("Portal created by [owner] was deleted, portal ref - \ref[src]")
	return ..()

/obj/effect/portal/linked/proc/connect_atmospheres()
	if(!atmos_connected && istype(target, /obj/effect/portal/linked))
		var/obj/effect/portal/linked/P = target
		var/turf/src_turf = get_turf(src)
		var/turf/target_turf = get_turf(P)
		if(src_turf && target_turf)
			var/has_valid_connection = FALSE
			if(TURF_HAS_VALID_ZONE(src_turf))
				atmos_connection = new (src_turf, target_turf)
				has_valid_connection = TRUE
			if(TURF_HAS_VALID_ZONE(target_turf))
				P.atmos_connection = new (target_turf, src_turf)
				has_valid_connection = TRUE
			if(has_valid_connection)
				P.atmos_connected = TRUE
				atmos_connected = TRUE

/obj/effect/portal/linked/proc/disconnect_atmospheres()
	atmos_connected = FALSE
	if(atmos_connection)
		atmos_connection.erase()
		atmos_connection = null

/obj/effect/portal/linked/proc/blend_icon(obj/effect/portal/P)
	var/turf/T = P.loc

	if(!("icon[initial(T.icon)]_iconstate[T.icon_state]_[type]" in portal_cache)) // If the icon has not been added yet
		var/icon/I1 = icon(icon,mask)//Generate it.
		var/icon/I2 = icon(initial(T.icon),T.icon_state)
		I1.Blend(I2,ICON_MULTIPLY)
		portal_cache["icon[initial(T.icon)]_iconstate[T.icon_state]_[type]"] = I1 // And cache it!

	AddOverlays(portal_cache["icon[initial(T.icon)]_iconstate[T.icon_state]_[type]"])

// In layman's terms, speedy thing goes in, speedy thing comes out.
// projectile redirect is not cool, I made my own cool method!
/obj/effect/portal/linked/on_projectile_impact(obj/item/projectile/P, use_impact = TRUE)
	if(QDELETED(P) || P.kill_count < 1 || !P.dir || !target || P.original == src || P.original == get_turf(src) || P.original == target || (!P.x && !P.y && !P.z))
		return FALSE
	// save vars from something
	var/turf/loc_turf = get_turf(src)
	var/turf/target_turf = get_turf(P.original)
	var/target_dist = get_dist(loc_turf, target_turf)
	var/projectile_dir = get_dir(P, src)
	// Sometimes a projectile during the "momentum saving"
	// does not meet any object for impact and hits the portals over and over again,
	// which causes the wildest lags, this should fix this bug
	if(!P.hitscan)
		stoplag(1)
	// move projectile to linked portal
	var/previous_dir = P.dir
	P.dir = projectile_dir
	if(!teleport(P, TRUE))
		return
	P.dir = previous_dir
	// get turf of linked portal; get x, y of this turf
	var/turf/linked_turf = get_turf(target)
	// get new target turf
	target_turf = linked_turf
	while(!QDELING(src))
		target_dist -= 1
		target_turf = get_step(target_turf, projectile_dir)
		if(target_dist <= 0)
			break
	// set new target turf as projectile target
	P.original = target_turf
	// rebuild trajectory by calling P.setup_projectory and our work there is done
	P.redirect(P.original.x, P.original.y, linked_turf, target)
	return TRUE

/obj/effect/portal/linked/proc/on_throw_impact(atom/movable/hit_atom, datum/thrownthing/TT)
	// save throw vars before "sleep"
	var/atom/thrower = TT.thrower
	var/throw_range = TT.maxrange
	var/dist_travelled = TT.dist_travelled
	var/thrown_dir = TT.init_dir
	var/previous_dir = hit_atom.dir
	var/turf/loc_turf = get_turf(src)
	var/turf/target_turf = TT.target_turf
	var/speed = TT.speed
	// sometimes the thrown object during the "momentum saving"
	// does not meet any object to hit and falls into the portals over and over again,
	// which causes the wildest lags, this should fix this bug
	stoplag(1)
	if(!target_turf || !loc_turf || target_turf == loc_turf)
		teleport(hit_atom, TRUE)
		return
	var/target_dist = get_dist(loc_turf, target_turf)
	hit_atom.dir = thrown_dir
	var/result = teleport(hit_atom, TRUE)
	hit_atom.dir = previous_dir
	if(!result)
		return
	TT.init_dir = reverse_direction(TT.init_dir)
	target_turf = get_turf(target)
	while(!QDELING(src))
		target_dist -= 1
		target_turf = get_step(target_turf, thrown_dir)
		if(target_dist <= 0)
			break
	INVOKE_ASYNC(hit_atom, nameof(/atom/movable.proc/throw_at), target_turf, throw_range-dist_travelled, speed, thrower)

/obj/effect/portal/linked/teleport(atom/movable/M, ignore_checks = FALSE, datum/thrownthing/TT = null)
	if(!target)
		return
	if(!QDELETED(TT) && !ignore_checks)
		return on_throw_impact(M, TT)
	return ..()

/obj/effect/portal/linked/move_all_objects()
	if(!target || QDELETED(src))
		return
	var/turf/T = get_turf(src)
	for(var/atom/movable/M in T)
		teleport(M)
