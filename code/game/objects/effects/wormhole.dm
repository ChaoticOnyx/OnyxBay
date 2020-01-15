GLOBAL_LIST_EMPTY(all_wormholes)

/obj/effect/portal/wormhole
	name = "wormhole"
	desc = "It looks highly unstable; It could close at any moment."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"

/obj/effect/portal/wormhole/Initialize()
	. = ..()
	GLOB.all_wormholes += src

/obj/effect/portal/wormhole/Destroy()
	GLOB.all_wormholes -= src
	return ..()

/obj/effect/portal/wormhole/setup_portal()
	return

/obj/effect/portal/wormhole/teleport(atom/movable/M)
	if(iseffect(M))
		return
	if(M.anchored && !ismech(M))
		return
	if(!ismovable(M))
		return

	var/turf/target
	if(GLOB.all_wormholes.len)
		var/obj/effect/portal/wormhole/P = pick(GLOB.all_wormholes)
		if(P && isturf(P.loc))
			target = P.loc
	if(!target)
		return
	do_teleport(M, target, TRUE)
