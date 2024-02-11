//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/device/assembly/infra
	name = "infrared emitter"
	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted."
	icon_state = "infrared"
	origin_tech = list(TECH_MAGNET = 2)
	matter = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 500, MATERIAL_WASTE = 100)

	wires = WIRE_PULSE

	secured = FALSE

	var/on = FALSE
	var/visible = FALSE

	var/list/beams
	var/list/seen_turfs
	var/datum/proximity_trigger/line/transparent/proximity_trigger

	drop_sound = SFX_DROP_COMPONENT
	pickup_sound = SFX_PICKUP_COMPONENT

/obj/item/device/assembly/infra/New()
	..()
	beams = list()
	seen_turfs = list()
	proximity_trigger = new(src, /obj/item/device/assembly/infra/proc/on_beam_entered, /obj/item/device/assembly/infra/proc/on_visibility_change, world.view, PROXIMITY_EXCLUDE_HOLDER_TURF)

/obj/item/device/assembly/infra/Destroy()
	qdel(proximity_trigger)
	proximity_trigger = null

	. = ..()

/obj/item/device/assembly/infra/activate()
	if(!..())
		return FALSE
	set_active(!on)
	return TRUE

/obj/item/device/assembly/infra/proc/set_active(new_on)
	if(new_on == on)
		return
	on = new_on
	if(on)
		proximity_trigger.register_turfs()
	else
		proximity_trigger.unregister_turfs()
	update_icon()
	update_beams()

/obj/item/device/assembly/infra/toggle_secure()
	secured = !secured
	set_active(secured ? on : FALSE)
	return secured

/obj/item/device/assembly/infra/on_update_icon()
	ClearOverlays()
	if(on)
		AddOverlays("infrared_on")
	if(holder)
		holder.update_icon()

/obj/item/device/assembly/infra/interact(mob/user)//TODO: change this this to the wire control panel
	if(!secured)
		return
	if(!CanInteract(user, GLOB.physical_state))
		return

	user.set_machine(src)
	var/dat = "<meta charset=\"utf-8\">"
	dat += "<TT><B>Infrared Laser</B><br>"
	dat += "<B>Status</B>: <A href='?src=\ref[src];state=1'>[on ? "On" : "Off"]</A><br>"
	dat += "<B>Visibility</B>: <A href='?src=\ref[src];visible=1'>[visible ? "Visible" : "Invisible"]</A><br>"
	dat += "<A href='?src=\ref[src];rotate=1'>Rotate</A><br>"
	dat += "</TT>"
	dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
	dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
	show_browser(user, jointext(dat, null), "window=infra")
	onclose(user, "infra")

/obj/item/device/assembly/infra/Topic(href, href_list, state = GLOB.physical_state)
	var/mob/user = usr
	if(CanUseTopic(user) != STATUS_INTERACTIVE)
		return
	if(..())
		close_browser(user, "window=infra")
		onclose(user, "infra")
		return 1

	if(href_list["state"])
		set_active(!on)
	else if(href_list["visible"])
		visible = !visible
		update_beams()
	else if(href_list["rotate"])
		rotate()
	else if(href_list["close"])
		close_browser(usr, "window=infra")
		return

	if(user)
		attack_self(user)

	return TOPIC_REFRESH

/obj/item/device/assembly/infra/verb/rotate()//This could likely be better
	set name = "Rotate Infrared Laser"
	set category = "Object"
	set src in usr

	set_dir(turn(dir, 90))

/obj/item/device/assembly/infra/retransmit_moved(mover, old_loc, new_loc)
	if(on)
		..()
		update_beams()

/obj/item/device/assembly/infra/proc/on_beam_entered(atom/enterer)
	if(enterer == src)
		return
	if(enterer.invisibility > INVISIBILITY_LEVEL_TWO)
		return
	if(!secured || !on || cooldown > 0)
		return 0
	if(!isliving(enterer)) // Observers and their ilk don't count even if visible
		return
	pulse(0)
	if(!holder)
		visible_message("\icon[src] *beep* *beep*")
	cooldown = 2
	addtimer(CALLBACK(src, nameof(.proc/process_cooldown)), 1 SECOND)

/obj/item/device/assembly/infra/proc/on_visibility_change(list/old_turfs, list/new_turfs)
	seen_turfs = new_turfs
	update_beams()

/obj/item/device/assembly/infra/proc/update_beams()
	if(on && check_locs(src, stop_on = list(/turf), checking_proc = /obj/item/device/assembly/infra/proc/check_loc))
		proximity_trigger.set_range(world.view)
		proximity_trigger.register_turfs()
		create_update_and_delete_beams(on, visible, dir, seen_turfs, beams)
	else
		proximity_trigger.set_range(0)
		QDEL_LIST(beams)

/obj/item/device/assembly/infra/proc/check_loc(atom/A)
	var/list/opacity_locs = list(
	  /obj/item/storage,
	  /obj/structure/closet,
	  /obj/machinery,
	  /obj/item/portable_destructive_analyzer,
	  /obj/item/robot_rack
	)
	for(var/type in opacity_locs)
		if(istype(A, type))
			return FALSE
	return TRUE

/proc/create_update_and_delete_beams(active, visible, dir, list/seen_turfs, list/existing_beams)
	if(!active)
		QDEL_LIST(existing_beams)
		return

	var/list/turfs_that_need_beams = seen_turfs.Copy()

	for(var/b in existing_beams)
		var/obj/effect/beam/ir_beam/beam = b
		if(beam.loc in turfs_that_need_beams)
			beam.set_dir(dir)
			turfs_that_need_beams -= beam.loc
			beam.set_invisibility(visible ? 0 : INVISIBILITY_MAXIMUM)
		else
			existing_beams -= beam
			qdel(beam)

	if(!visible)
		return

	for(var/t in turfs_that_need_beams)
		var/obj/effect/beam/ir_beam/beam = new(t)
		existing_beams += beam
		beam.set_dir(dir)

/obj/effect/beam/ir_beam
	name = "ir beam"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ibeam"
	anchored = TRUE
	simulated = FALSE
