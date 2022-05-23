/obj/effect/train_motion
	icon = 'icons/effects/train_motion.dmi'
	icon_state = "animation"
	plane = EFFECTS_ABOVE_LIGHTING_PLANE
	anchored = TRUE

/obj/machinery/train_display
	icon = 'icons/obj/train_display.dmi'
	icon_state = "empty"
	name = "train display"
	layer = ABOVE_WINDOW_LAYER
	anchored = 1
	density = 0
	idle_power_usage = 10

	var/train_tag
	var/weakref/train

/obj/machinery/train_display/Initialize()
	. = ..()
	
	if(!train_tag)
		crash_with("train display without `train_tag`!")
		qdel(src)
		return

/obj/machinery/train_display/Destroy()
	qdel(train)

	. = ..()

/obj/machinery/train_display/Process()
	if(stat & NOPOWER)
		set_light(0)

		return

	if(!train)
		for(var/tag in SSshuttle.shuttles)
			if(tag == train_tag)
				train = weakref(SSshuttle.shuttles[tag])
				break

	if(QDELETED(train))
		crash_with("train with tag [train_tag] not found!")
		qdel(src)
		return PROCESS_KILL

	var/datum/shuttle/autodock/ferry/T = train.resolve()

	if(T.moving_status != SHUTTLE_INTRANSIT)
		icon_state = "empty"
		return

	var/total = T.move_time
	var/timeleft = round((T.arrive_time - world.time) / 10, 1)
	var/stage = max(1, min((1 - timeleft / total) * 10, 8))

	icon_state = "[num2text(stage)[1]]"
	// If going to station
	if(!T.direction)
		icon_state = "-[icon_state]"

	set_light(0.8, 1, 1.6, l_color = "#ca3232")
