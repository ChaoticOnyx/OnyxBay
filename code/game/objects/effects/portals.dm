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

/obj/effect/portal/Destroy()
	target = null
	return ..()

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
		do_teleport(M, locate(rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE), rand(TRANSITIONEDGE, world.maxy -TRANSITIONEDGE), pick(GLOB.using_map.player_levels)), 0)
	else
		do_teleport(M, target, 1)
