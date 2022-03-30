#define PAD_COOLDOWN 20
/obj/machinery/abductor/pad
	name = "Alien Telepad"
	desc = "Use this to transport to and from the humans' habitat."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "alien-pad-idle"
	var/turf/teleport_target
	var/obj/machinery/abductor/console/console
	var/teleporter_cooldown

/obj/machinery/abductor/pad/Destroy()
	if(console)
		console.pad = null
		console = null
	return ..()

/obj/machinery/abductor/pad/proc/Warp(mob/living/target)
	target.forceMove(get_turf(src))

/obj/machinery/abductor/pad/proc/Send()
	if(teleport_target == null)
		teleport_target = teleportlocs[pick(teleportlocs)]
	if(cooldown())
		flick("alien-pad", src)
		for(var/mob/living/target in loc)
			target.forceMove(pick(get_area_turfs(teleport_target)))
			playsound(get_turf(target), 'sound/effects/phasein.ogg', 20, 1)
			anim(get_turf(target), target,'icons/mob/mob.dmi',,"phasein",,target.dir)
			to_chat(target, SPAN_WARNING("The instability of the warp leaves you disoriented!"))
			target.Stun(10)
			teleporter_cooldown = world.time+PAD_COOLDOWN

/obj/machinery/abductor/pad/proc/Retrieve(mob/living/target)
	if(cooldown())
		flick("alien-pad", src)
		playsound(get_turf(target), 'sound/effects/phasein.ogg', 20, 1)
		anim(get_turf(target), target,'icons/mob/mob.dmi',,"phaseout",,target.dir)
		Warp(target)
		teleporter_cooldown = world.time+PAD_COOLDOWN
/obj/machinery/abductor/pad/proc/doMobToLoc(place, atom/movable/target)
		flick("alien-pad", src)
		src.console.camera.release(target)
		target.forceMove(place)
		playsound(get_turf(target), 'sound/effects/phasein.ogg', 20, 1)
		anim(get_turf(target), target,'icons/mob/mob.dmi',,"phaseout",,target.dir)


/obj/machinery/abductor/pad/proc/MobToLoc(place,mob/living/target)
	if(cooldown())
		new /obj/effect/temporary/teleport_abductor(place)
		playsound(get_turf(target), 'sound/effects/phasein.ogg', 20, 1)
		addtimer(CALLBACK(src, .proc/doMobToLoc, place, target), 30)


/obj/machinery/abductor/pad/proc/doPadToLoc(place)
	flick("alien-pad", src)
	for(var/mob/living/target in get_turf(src))
		target.forceMove(place)
		playsound(place, 'sound/effects/phasein.ogg', 50, 1)
		new /obj/effect/temporary/teleport_abductor(place)

/obj/machinery/abductor/pad/proc/PadToLoc(place)
	if(cooldown())
		new /obj/effect/temporary/teleport_abductor(place)
		playsound(place, 'sound/effects/phasein.ogg', 20, 1)
		addtimer(CALLBACK(src, .proc/doPadToLoc, place), 30)

/obj/effect/temporary/teleport_abductor
	name = "Huh"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "teleport"

/obj/effect/temporary/teleport_abductor/Initialize(mapload, duration = 80)
	. = ..()
	var/datum/effect/effect/system/spark_spread/S = new
	S.set_up(10,0,loc)
	S.start()

/obj/machinery/abductor/pad/proc/cooldown()
	if(world.time > teleporter_cooldown)
		teleporter_cooldown = world.time+PAD_COOLDOWN
		return TRUE
	else
		state("Teleport pad is recalibrating please wait [(teleporter_cooldown-world.time)*0.1] seconds")
		return FALSE

#undef PAD_COOLDOWN
