/obj/item/device/assembly/prox_sensor
	name = "proximity sensor"
	desc = "Used for scanning and alerting when someone enters a certain proximity."
	icon_state = "prox"
	origin_tech = list(TECH_MAGNET = 1)
	matter = list(MATERIAL_STEEL = 800, MATERIAL_GLASS = 200, MATERIAL_WASTE = 50)
	wires = WIRE_PULSE

	secured = FALSE

	var/scanning = FALSE
	var/timing = FALSE
	var/time = 10

	var/range = 2

	drop_sound = SFX_DROP_COMPONENT
	pickup_sound = SFX_PICKUP_COMPONENT

/obj/item/device/assembly/prox_sensor/Initialize()
	. = ..()
	proximity_monitor = new(src, range, FALSE)

/obj/item/device/assembly/prox_sensor/activate()
	if(!..())
		return FALSE
	timing = !timing
	set_next_think(world.time)
	update_icon()
	return TRUE


/obj/item/device/assembly/prox_sensor/toggle_secure()
	secured = !secured
	if(secured)
		set_next_think(world.time)
	else
		scanning = FALSE
		timing = FALSE
		set_next_think(0)
	update_icon()
	return secured

/obj/item/device/assembly/prox_sensor/HasProximity(atom/movable/AM)
	if(!istype(AM))
		return

	if(!scanning)
		return
	if(istype(AM, /obj/effect/beam))
		return
	if(istype(AM, /obj/effect/dummy/spell_jaunt))
		return
	if(isobserver(AM))
		return
	if(AM.move_speed < 12)
		sense()

/obj/item/device/assembly/prox_sensor/proc/sense()
	var/turf/mainloc = get_turf(src)
	if((!holder && !secured) || !scanning)
		return FALSE

	THROTTLE(sense_cooldown, 0.2 SECONDS)
	if(!sense_cooldown)
		return FALSE

	pulse(0)
	if(!holder)
		mainloc.visible_message(SPAN("danger" ,"\icon[src] *beep* *beep*"), SPAN("danger" ,"*beep* *beep*"))
	playsound(mainloc, 'sound/signals/warning8.ogg', 35)
	set_next_think(world.time + 1 SECOND)

/obj/item/device/assembly/prox_sensor/think()
	if(!timing)
		return
	if(time > 0)
		time--
		set_next_think(world.time + 1 SECOND)
	else
		timing = FALSE
		toggle_scan()
		time = 10

/obj/item/device/assembly/prox_sensor/dropped()
	sense()

/obj/item/device/assembly/prox_sensor/retransmit_moved(mover, old_loc, new_loc)
	if(scanning)
		..()

/obj/item/device/assembly/prox_sensor/proc/toggle_scan()
	if(!secured)
		return
	scanning = !scanning
	update_icon()

/obj/item/device/assembly/prox_sensor/on_update_icon()
	ClearOverlays()
	attached_overlays = list()
	if(timing)
		AddOverlays("prox_timing")
		attached_overlays += "prox_timing"
	if(scanning)
		AddOverlays("prox_scanning")
		attached_overlays += "prox_scanning"
	if(holder)
		holder.update_icon()
	if(holder && istype(holder.loc,/obj/item/grenade/chem_grenade))
		var/obj/item/grenade/chem_grenade/grenade = holder.loc
		grenade.update_icon()
	return


/obj/item/device/assembly/prox_sensor/Move(newloc, direct)
	. = ..()
	if(!.)
		return

	sense()


/obj/item/device/assembly/prox_sensor/interact(mob/user)//TODO: Change this to the wires thingy
	if(!secured)
		user.show_message(SPAN("warning", "\the [src] is unsecured!"))
		return
	var/second = time % 60
	var/minute = (time - second) / 60
	var/dat = "<meta charset=\"utf-8\">"
	dat += "<TT><B>Proximity Sensor</B><br>"
	dat += "<A href='?src=\ref[src];time=1'>[timing ? "Timing":"Not timing"]</A><br>"
	dat += "<A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A>"
	dat += " [minute]:[second] "
	dat += "<A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A><br>"
	dat += "</TT>"
	dat += "<BR>Range: <A href='?src=\ref[src];range=-1'>-</A> [range] <A href='?src=\ref[src];range=1'>+</A>"
	dat += "<BR><A href='?src=\ref[src];scanning=1'>[scanning ? "Armed":"Unarmed"]</A> (Movement sensor active when armed!)"
	dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
	dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
	show_browser(user, dat, "window=prox")
	onclose(user, "prox")
	return


/obj/item/device/assembly/prox_sensor/Topic(href, href_list, state = GLOB.physical_state)
	var/mob/user = usr
	if(CanUseTopic(user) != STATUS_INTERACTIVE)
		return
	if((. = ..()))
		close_browser(user, "window=prox")
		onclose(user, "prox")
		return

	if(href_list["scanning"])
		toggle_scan()

	if(href_list["time"])
		activate()

	if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = min(max(round(time), 0), 600)

	if(href_list["range"])
		var/r = text2num(href_list["range"])
		var/old_range = range
		range += r
		range = Clamp(range, 1, 5)
		if(range != old_range)
			proximity_monitor.set_range(range, TRUE)

	if(href_list["close"])
		close_browser(usr, "window=prox")
		return

	if(user)
		attack_self(user)

	return TOPIC_REFRESH
