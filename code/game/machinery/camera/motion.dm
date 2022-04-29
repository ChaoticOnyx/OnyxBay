/obj/machinery/camera
	var/list/weakref/motionTargets = list()
	var/detectTime = 0
	var/alarm_delay = 100 // Don't forget, there's another 10 seconds in queueAlarm()

/obj/machinery/camera/Initialize()
	. = ..()
	proximity_monitor = new(src, 2)

/obj/machinery/camera/internal_process()
	..()
	// motion camera event loop
	if (stat & (EMPED|NOPOWER))
		return
	if(!isMotion())
		. = PROCESS_KILL
		return
	if (detectTime > 0)
		var/elapsed = world.time - detectTime
		if (elapsed > alarm_delay)
			triggerAlarm()
	else if (detectTime == -1)
		for (var/weakref/targetref in motionTargets)
			var/mob/target = targetref?.resolve()
			if(QDELETED(target) || target.stat == DEAD || !in_range(src, target))
				lostTargetRef(targetref)

/obj/machinery/camera/proc/newTarget(mob/target)
	if(istype(target, /mob/living/silicon/ai))
		return FALSE
	if(detectTime == 0)
		detectTime = world.time // start the clock
	var/targetref = weakref(target)
	if(!(targetref in motionTargets))
		motionTargets |= targetref
	return TRUE

/obj/machinery/camera/proc/lostTargetRef(weakref/R)
	if(R in motionTargets)
		motionTargets -= R
	if(motionTargets.len == 0)
		cancelAlarm()

/obj/machinery/camera/proc/cancelAlarm()
	if (!status || (stat & NOPOWER))
		return 0
	if (detectTime == -1)
		motion_alarm.clearAlarm(loc, src)
	detectTime = 0
	return 1

/obj/machinery/camera/proc/triggerAlarm()
	if (!status || (stat & NOPOWER))
		return 0
	if (!detectTime) return 0
	motion_alarm.triggerAlarm(loc, src)
	detectTime = -1
	return 1

/obj/machinery/camera/HasProximity(atom/movable/AM as mob|obj)
	if(isliving(AM))
		newTarget(AM)
