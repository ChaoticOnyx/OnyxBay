/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	density = 1
	unacidable = 1//Can't destroy energy portals.
	var/obj/item/target = null
	var/creator = null
	anchored = 1.0
	var/dangerous = 0
	var/failchance = 0

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

/obj/effect/portal/proc/teleport(atom/movable/M)
	if(iseffect(M))
		return
	if(M.anchored && !ismech(M))
		return
	if(!ismovable(M))
		return
	if (!target)
		qdel(src)
		return

	if(dangerous && prob(failchance))
		var/destination_z = GLOB.using_map.get_transit_zlevel(src.z)
		do_teleport(M, locate(rand(TRANSITION_EDGE, world.maxx - TRANSITION_EDGE), rand(TRANSITION_EDGE, world.maxy -TRANSITION_EDGE), destination_z), 0)
	else
		do_teleport(M, target, 1)
