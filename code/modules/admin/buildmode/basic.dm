/datum/build_mode/basic
	the_default = TRUE
	name = "Basic"
	icon_state = "buildmode1"

/datum/build_mode/basic/Help()
	to_chat(user, "<span class='notice'>***********************************************************</span>", confidential = TRUE)
	to_chat(user, "<span class='notice'>Left Click        = Construct / Upgrade</span>", confidential = TRUE)
	to_chat(user, "<span class='notice'>Right Click       = Deconstruct / Delete / Downgrade</span>", confidential = TRUE)
	to_chat(user, "<span class='notice'>Left Click + Ctrl = R-Window</span>", confidential = TRUE)
	to_chat(user, "<span class='notice'>Left Click + Alt  = Airlock</span>", confidential = TRUE)
	to_chat(user, "", confidential = TRUE)
	to_chat(user, "<span class='notice'>Use the directional button in the upper left corner to</span>", confidential = TRUE)
	to_chat(user, "<span class='notice'>change the direction of built objects.</span>", confidential = TRUE)
	to_chat(user, "<span class='notice'>***********************************************************</span>", confidential = TRUE)

/datum/build_mode/basic/OnClick(atom/object, list/pa)
	if(istype(object,/turf) && pa["left"] && !pa["alt"] && !pa["ctrl"] )
		if(istype(object,/turf/space))
			var/turf/T = object
			Log("Upgraded - [log_info_line(object)]")
			T.ChangeTurf(/turf/simulated/floor)
			return
		else if(istype(object,/turf/simulated/floor))
			var/turf/T = object
			Log("Upgraded - [log_info_line(object)]")
			T.ChangeTurf(/turf/simulated/wall)
			return
		else if(istype(object,/turf/simulated/wall))
			var/turf/T = object
			Log("Upgraded - [log_info_line(object)]")
			T.ChangeTurf(/turf/simulated/wall/r_wall)
			return
	else if(pa["right"])
		if(istype(object,/turf/simulated/wall))
			var/turf/T = object
			Log("Downgraded - [log_info_line(object)]")
			T.ChangeTurf(/turf/simulated/floor)
			return
		else if(istype(object,/turf/simulated/floor))
			var/turf/T = object
			Log("Downgraded - [log_info_line(object)]")
			T.ChangeTurf(/turf/space)
			return
		else if(istype(object,/turf/simulated/wall/r_wall))
			var/turf/T = object
			Log("Downgraded - [log_info_line(object)]")
			T.ChangeTurf(/turf/simulated/wall)
			return
		else if(istype(object,/obj))
			Log("Deleted - [log_info_line(object)]")
			qdel(object)
			return
	else if(istype(object,/turf) && pa["alt"] && pa["left"])
		var/airlock = new /obj/machinery/door/airlock(get_turf(object))
		Log("Created - [log_info_line(airlock)]")
	else if(istype(object,/turf) && pa["ctrl"] && pa["left"])
		var/obj/structure/window/reinforced/WIN = new /obj/structure/window/reinforced(get_turf(object))
		Log("Created - [log_info_line(object)]")
		switch(host.dir)
			if(NORTH)
				WIN.set_dir(NORTH)
			if(SOUTH)
				WIN.set_dir(SOUTH)
			if(EAST)
				WIN.set_dir(EAST)
			if(WEST)
				WIN.set_dir(WEST)
			if(NORTHWEST)
				WIN.set_dir(NORTHWEST)
