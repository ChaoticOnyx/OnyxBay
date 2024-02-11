/obj/item/device/assembly/timer
	name = "timer"
	desc = "Used to time things. Works well with contraptions which have to count down. Tick tock."
	icon_state = "timer"
	origin_tech = list(TECH_MAGNET = 1)
	matter = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 50, MATERIAL_WASTE = 10)

	wires = WIRE_PULSE

	secured = FALSE

	var/timing = FALSE
	var/time = 10

	drop_sound = SFX_DROP_COMPONENT
	pickup_sound = SFX_PICKUP_COMPONENT

/obj/item/device/assembly/timer/proc/timer_end()
	if(!secured)
		return 0
	pulse(0)
	if(!holder)
		visible_message("\icon[src] *beep* *beep*", "*beep* *beep*")
	update_icon()
	return

/obj/item/device/assembly/timer/activate()
	if(!..())
		return FALSE
	timing = !timing
	set_next_think(world.time)
	update_icon()
	return TRUE


/obj/item/device/assembly/timer/toggle_secure()
	secured = !secured
	if(secured)
		set_next_think(world.time)
	else
		timing = FALSE
		set_next_think(0)
	update_icon()
	return secured

/obj/item/device/assembly/timer/think()
	if(!timing)
		return
	if(time > 0)
		time--
		set_next_think(world.time + 1 SECOND)
	else
		timing = FALSE
		timer_end()
		time = 10

/obj/item/device/assembly/timer/on_update_icon()
	ClearOverlays()
	attached_overlays = list()
	if(timing)
		AddOverlays("timer_timing")
		attached_overlays += "timer_timing"
	if(holder)
		holder.update_icon()
	return


/obj/item/device/assembly/timer/interact(mob/user)//TODO: Have this use the wires
	if(!secured)
		user.show_message(SPAN("warning", "\The [name] is unsecured!"))
		return 0
	var/second = time % 60
	var/minute = (time - second) / 60
	var/dat = "<meta charset=\"utf-8\"><TT>"
	dat += "<B>Timing Unit</B><br>"
	dat += "<A href='?src=\ref[src];time=1'>[timing ? "Timing" : "Not timing"]</A><br>"
	dat += "<A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A>"
	dat += " [minute]:[second] "
	dat += "<A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A><br></TT>"
	dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
	dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
	show_browser(user, dat, "window=timer")
	onclose(user, "timer")
	return


/obj/item/device/assembly/timer/Topic(href, href_list, state = GLOB.physical_state)
	var/mob/user = usr
	if(CanUseTopic(user) != STATUS_INTERACTIVE)
		return
	if((. = ..()))
		close_browser(usr, "window=timer")
		onclose(usr, "timer")
		return

	if(href_list["time"])
		activate()

	if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = min(max(round(time), 0), 600)

	if(href_list["close"])
		close_browser(usr, "window=timer")
		return

	if(user)
		attack_self(user)

	return TOPIC_REFRESH
