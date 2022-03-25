/obj/machinery/abductor/pad
	name = "Alien Telepad"
	desc = "Use this to transport to and from the humans' habitat."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "alien-pad-idle"
	var/turf/teleport_target
	var/obj/machinery/abductor/console/console

/obj/machinery/abductor/pad/Destroy()
	if(console)
		console.pad = null
		console = null
	return ..()

/obj/machinery/abductor/pad/proc/Warp(mob/living/target)
	if(!target.buckled)
		target.forceMove(get_turf(src))

/obj/machinery/abductor/pad/proc/Send()
	if(teleport_target == null)
		teleport_target = teleportlocs[pick(teleportlocs)]
	flick("alien-pad", src)
	for(var/mob/living/target in loc)
		target.forceMove(pick(get_area_turfs(teleport_target)))
		playsound(get_turf(target), 'sound/effects/phasein.ogg', 50, 1)
		anim(get_turf(target), target,'icons/mob/mob.dmi',,"phasein",,target.dir)
		to_chat(target, SPAN_WARNING("The instability of the warp leaves you disoriented!"))
		target.Stun(20)

/obj/machinery/abductor/pad/proc/Retrieve(mob/living/target)
	flick("alien-pad", src)
	playsound(get_turf(target), 'sound/effects/phasein.ogg', 50, 1)
	anim(get_turf(target), target,'icons/mob/mob.dmi',,"phaseout",,target.dir)
	Warp(target)

/obj/machinery/abductor/pad/proc/doMobToLoc(place, atom/movable/target)
	flick("alien-pad", src)
	src.console.camera.release(target)
	target.forceMove(place)
	playsound(get_turf(target), 'sound/effects/phasein.ogg', 50, 1)
	anim(get_turf(target), target,'icons/mob/mob.dmi',,"phaseout",,target.dir)

/obj/machinery/abductor/pad/proc/MobToLoc(place,mob/living/target)
	new /obj/effect/temporary/teleport_abductor(place)
	playsound(get_turf(target), 'sound/effects/phasein.ogg', 50, 1)
	addtimer(CALLBACK(src, .proc/doMobToLoc, place, target), 80)

/obj/machinery/abductor/pad/proc/doPadToLoc(place)
	flick("alien-pad", src)
	for(var/mob/living/target in get_turf(src))
		src.console.camera.release(target)
		target.forceMove(place)
		playsound(place, 'sound/effects/phasein.ogg', 50, 1)
		new /obj/effect/temporary/teleport_abductor(place)

/obj/machinery/abductor/pad/proc/PadToLoc(place)
	new /obj/effect/temporary/teleport_abductor(place)
	playsound(place, 'sound/effects/phasein.ogg', 50, 1)
	addtimer(CALLBACK(src, .proc/doPadToLoc, place), 80)

/obj/effect/temporary/teleport_abductor
	name = "Huh"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "teleport"

/obj/effect/temporary/teleport_abductor/Initialize(mapload, duration = 80)
	. = ..()
	var/datum/effect/effect/system/spark_spread/S = new
	S.set_up(10,0,loc)
	S.start()
