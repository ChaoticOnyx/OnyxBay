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
		var/destination_z = GLOB.using_map.get_transit_zlevel(src.z)
		do_teleport(M, locate(rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE), rand(TRANSITIONEDGE, world.maxy -TRANSITIONEDGE), destination_z), 0)
	else
		do_teleport(M, target, 1)

/obj/effect/red_portal
	name = "scary red portal"
	desc = "Looks unstable, scary and holographic. Best to test it with your target."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "redportal"
	density = 0
	unacidable = 1//Can't destroy energy portals.
	anchored = 1.0
	var/obj/item/device/uplink/linked_uplink

/obj/effect/red_portal/Initialize(mapload, delete_after = 300, obj/item/device/uplink/new_uplink)
	. = ..()
	if(!new_uplink)
		QDEL_IN(src, 0) // next tick deletion
		return
	playsound(src, 'sound/effects/phasein.ogg', 25, 1)
	linked_uplink = new_uplink
	QDEL_IN(src, delete_after)

/obj/effect/red_portal/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/grab))
		var/obj/item/grab/grab = W
		if(!ismob(grab.affecting))
			return

		if(!grab.force_danger())
			return

		if(!linked_uplink)
			return

		var/mob/living/carbon/human/H = grab.affecting

		if(!istype(H))
			return

		visible_message("[user] starts putting [H.name] into \the [src].", 3)

		if(do_after(user, 1 MINUTE, src))
			var/kidnapped = FALSE
			for(var/datum/antag_contract/kidnap/kidnap in linked_uplink.accepted_contracts)
				if(kidnap.check_mob(H))
					if(!H || !grab || !grab.affecting)
						return
					kidnap.complete(linked_uplink)
					H.forceMove(src)
					qdel(H)
					kidnapped = TRUE
					break
			if(!kidnapped)
				to_chat(user, SPAN("notice", "\The [src] doesn't accept target."))
