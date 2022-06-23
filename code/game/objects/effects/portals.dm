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

/obj/effect/portal/Bumped(mob/M)
	teleport(M)

/obj/effect/portal/Crossed(AM)
	teleport(AM)

/obj/effect/portal/attack_hand(mob/user)
	teleport(user)

/obj/effect/portal/Initialize(mapload, end, delete_after = 300, failure_rate)
	. = ..()
	setup_portal(end, delete_after, failure_rate)
	addtimer(CALLBACK(src, .proc/move_all_objects), 1.5 SECONDS)

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
	return TRUE

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

	overlays += portal_cache["icon[initial(T.icon)]_iconstate[T.icon_state]_[type]"]

/obj/effect/portal/linked/teleport(atom/movable/M, ignore_checks = FALSE)
	if(!target)
		return
	return ..()

/obj/effect/portal/linked/move_all_objects()
	if(!target || QDELETED(src))
		return
	var/turf/T = get_turf(src)
	for(var/atom/movable/M in T)
		teleport(M)
