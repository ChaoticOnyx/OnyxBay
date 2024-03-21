/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = 1
	anchored = 1.0
	idle_power_usage = 300 WATTS
	active_power_usage = 300 WATTS

	/// Typepath of the circuit board. If `null` computer can't be disassembled.
	var/circuit = null
	var/processing = 0

	var/icon_keyboard = "generic_key"
	var/icon_screen = "generic"
	var/light_max_bright_on = 1.0
	var/light_inner_range_on = 0.5
	var/light_outer_range_on = 4
	atom_flags = ATOM_FLAG_CLIMBABLE
	turf_height_offset = 12
	clicksound = 'sound/effects/using/console/press10.ogg'

	var/static/list/computer_overlays = list()

/obj/machinery/computer/Initialize()
	. = ..()
	GLOB.computer_list += src
	power_change()
	update_icon()

/obj/machinery/computer/Destroy()
	GLOB.computer_list -= src

	return ..()

/obj/machinery/computer/emp_act(severity)
	if(prob(20/severity)) set_broken(TRUE)
	..()

/obj/machinery/computer/ex_act(severity)
	playsound(src, SFX_BREAK_CONSOLE, 75, FALSE)

	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(25))
				qdel(src)
				return
			if (prob(50))
				for(var/x in verbs)
					verbs -= x
				set_broken(TRUE)
		if(3.0)
			if (prob(25))
				for(var/x in verbs)
					verbs -= x
				set_broken(TRUE)

/obj/machinery/computer/blob_act(damage)
	if(stat & BROKEN)
		return

	playsound(src, SFX_BREAK_CONSOLE, 75, FALSE)
	set_broken(TRUE)

/obj/machinery/computer/bullet_act(obj/item/projectile/Proj)
	if(prob(Proj.get_structure_damage()))
		set_broken(TRUE)
	..()

/obj/machinery/computer/on_update_icon()
	ClearOverlays()
	if(stat & NOPOWER)
		if(icon_keyboard)
			AddOverlays(OVERLAY(icon, "[icon_keyboard]_off"))
		set_light(0)
		return

	if(stat & BROKEN)
		AddOverlays(OVERLAY(icon, "[icon_state]_broken"))
	else
		AddOverlays(OVERLAY(icon, icon_screen))
		if(icon_keyboard)
			AddOverlays(OVERLAY(icon, icon_keyboard))

	var/should_glow = update_glow()
	if(should_glow)
		AddOverlays(emissive_appearance(icon, icon_screen))
		if(icon_keyboard)
			AddOverlays(emissive_appearance(icon, icon_keyboard))

/obj/machinery/computer/proc/update_glow()
	if(stat & (NOPOWER | BROKEN))
		set_light(0)
		return FALSE
	else
		set_light(light_max_bright_on, light_inner_range_on, light_outer_range_on, 3.5, light_color)
		return TRUE

/obj/machinery/computer/proc/decode(text)
	// Adds line breaks
	text = replacetext(text, "\n", "<BR>")
	return text

/obj/machinery/computer/attackby(obj/item/I, user)
	if(isScrewdriver(I) && circuit)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, 20, src))
			var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
			var/obj/item/circuitboard/M = new circuit( A )
			A.circuit = M
			A.anchored = 1
			for (var/obj/C in src)
				C.dropInto(loc)
			if (src.stat & BROKEN)
				to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				new /obj/item/material/shard( src.loc )
				A.state = 3
				A.icon_state = "3"
			else
				to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
				A.state = 4
				A.icon_state = "4"
			M.deconstruct(src)
			qdel(src)
	else
		..()

/obj/machinery/computer/attack_ghost(mob/ghost)
	attack_hand(ghost)

/obj/machinery/computer/proc/locate_unit(unit_type)
	return locate(unit_type) in orange(2, src)
