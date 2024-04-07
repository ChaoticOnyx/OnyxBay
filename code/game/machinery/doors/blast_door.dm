// BLAST DOORS
//
// Refactored 27.12.2014 by Atlantis
//
// Blast doors are supposed to be reinforced versions of regular doors. Instead of being manually
// controlled they use buttons or other means of remote control. This is why they cannot be emagged
// as they lack any ID scanning system, they just handle remote control signals. Subtypes have
// different icons, which are defined by set of variables. Subtypes are on bottom of this file.

/obj/machinery/door/blast
	name = "Blast Door"
	desc = "That looks like it doesn't open easily."
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = null

	// Icon states for different shutter types. Simply change this instead of rewriting the update_icon proc.
	var/icon_state_open = null
	var/icon_state_opening = null
	var/icon_state_closed = null
	var/icon_state_closing = null

	explosion_block = 3

	var/open_sound = 'sound/machines/blastdoor_open.ogg'
	var/close_sound = 'sound/machines/blastdoor_close.ogg'

	closed_layer = ABOVE_WINDOW_LAYER
	var/id = 1.0
	dir = 1
	explosion_resistance = 25
	atom_flags = ATOM_FLAG_ADJACENT_EXCEPTION | ATOM_FLAG_FULLTILE_OBJECT
	var/keep_items_on_close = FALSE

	//Most blast doors are infrequently toggled and sometimes used with regular doors anyways,
	//turning this off prevents awkward zone geometry in places like medbay lobby, for example.
	block_air_zones = 0

	var/begins_closed = TRUE
	var/_wifi_id
	var/datum/wifi/receiver/button/door/wifi_receiver
	var/material/implicit_material

	var/code = null
	var/frequency = null
	var/datum/frequency/radio_connection

	var/assembly_path = /obj/structure/secure_door_assembly/blast

	rad_resist_type = /datum/rad_resist/door_blast

/datum/rad_resist/door_blast
	alpha_particle_resist = 600 MEGA ELECTRONVOLT
	beta_particle_resist = 10 MEGA ELECTRONVOLT
	hawking_resist = 1.5 ELECTRONVOLT

/obj/machinery/door/blast/Initialize(loc, code, frequency, dir)
	. = ..()
	if(_wifi_id)
		wifi_receiver = new(_wifi_id, src)

	if(!begins_closed)
		icon_state = icon_state_open
		set_density(0)
		set_opacity(0)
		layer = open_layer
		atom_flags &= ~ATOM_FLAG_FULLTILE_OBJECT

	implicit_material = get_material_by_name(MATERIAL_PLASTEEL)

	src.dir = dir

	src.code = code
	src.frequency = frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, RADIO_CHAT)

/obj/machinery/door/airlock/Destroy()
	qdel(wifi_receiver)
	wifi_receiver = null
	return ..()

// Proc: Bumped()
// Parameters: 1 (AM - Atom that tried to walk through this object)
// Description: If we are open returns zero, otherwise returns result of parent function.
/obj/machinery/door/blast/Bumped(atom/AM)
	if(!density)
		return ..()
	else
		return 0

// Proc: update_icon()
// Parameters: None
// Description: Updates icon of this object. Uses icon state variables.
/obj/machinery/door/blast/on_update_icon()
	if(density)
		icon_state = icon_state_closed
	else
		icon_state = icon_state_open
	return

// Proc: force_open()
// Parameters: None
// Description: Opens the door. No checks are done inside this proc.
/obj/machinery/door/blast/proc/force_open()
	operating = TRUE
	playsound(loc, open_sound, 100, 1)
	flick(icon_state_opening, src)
	set_density(FALSE)
	update_nearby_tiles()
	update_icon()
	set_opacity(FALSE)
	sleep(15)
	layer = open_layer
	operating = FALSE
	atom_flags &= ~ATOM_FLAG_FULLTILE_OBJECT

// Proc: force_close()
// Parameters: None
// Description: Closes the door. No checks are done inside this proc.
/obj/machinery/door/blast/proc/force_close()
	operating = TRUE
	playsound(loc, close_sound, 100, 1)
	src.layer = closed_layer
	flick(icon_state_closing, src)
	set_density(TRUE)
	update_nearby_tiles()
	update_icon()
	set_opacity(TRUE)
	sleep(15)
	shove_everything(shove_items = !keep_items_on_close)
	operating = FALSE
	atom_flags |= ATOM_FLAG_FULLTILE_OBJECT

// Proc: force_toggle()
// Parameters: None
// Description: Opens or closes the door, depending on current state. No checks are done inside this proc.
/obj/machinery/door/blast/proc/force_toggle()
	if(density)
		force_open()
	else
		force_close()

/obj/machinery/door/blast/get_material()
	return implicit_material

// Proc: attackby()
// Parameters: 2 (C - Item this object was clicked with, user - Mob which clicked this object)
// Description: If we are clicked with crowbar or wielded fire axe, try to manually open the door.
// This only works on broken doors or doors without power. Also allows repair with Plasteel.
/obj/machinery/door/blast/attackby(obj/item/C, mob/user)
	src.add_fingerprint(user, 0, C)

	if(!density)
		if(default_deconstruction_screwdriver(user, C))
			return

		if(default_deconstruction_crowbar(user, C))
			return

	if((isCrowbar(C) && !istype(C, /obj/item/crowbar/emergency)) || (istype(C, /obj/item/material/twohanded/fireaxe) && C:wielded == 1))
		if(((stat & NOPOWER) || (stat & BROKEN)) && !( src.operating ))
			force_toggle()
		else
			to_chat(user, SPAN_NOTICE("[src]'s motors resist your effort."))
		return

	if(istype(C, /obj/item/stack/material) && C.get_material_name() == MATERIAL_PLASTEEL)
		var/amt = Ceiling((maxhealth - health)/150)
		if(!amt)
			to_chat(user, SPAN_NOTICE("\The [src] is already fully repaired."))
			return

		var/obj/item/stack/P = C
		if(P.amount < amt)
			to_chat(user, SPAN_WARNING("You don't have enough sheets to repair this! You need at least [amt] sheets."))
			return

		to_chat(usr, SPAN_NOTICE("You begin repairing [src]..."))
		if(do_after(user, 30, src))
			if(P.use(amt))
				to_chat(user, SPAN_NOTICE("You have repaired \the [src]"))
				repair()
			else
				to_chat(user, SPAN_WARNING("You don't have enough sheets to repair this! You need at least [amt] sheets."))

/obj/machinery/door/blast/dismantle()
	playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
	var/turf/T = get_turf(src)
	var/obj/structure/secure_door_assembly/A =  new assembly_path(T)
	A.dir = dir
	A.make_just_dismantled()
	var/obj/item/device/assembly/signaler/S = new /obj/item/device/assembly/signaler(T)
	if(code && frequency)
		S.code = code
		S.set_frequency(frequency)
	qdel(src)
	return

/obj/machinery/door/blast/receive_signal(datum/signal/signal)
	if(signal?.encryption != code)
		return FALSE

	if(density)
		open()
	else
		close()



// Proc: open()
// Parameters: None
// Description: Opens the door. Does necessary checks. Automatically closes if autoclose is true
/obj/machinery/door/blast/open()
	if (src.operating || (stat & BROKEN || stat & NOPOWER))
		return
	force_open()
	if(autoclose)
		spawn(150)
			close()
	return 1

// Proc: close()
// Parameters: None
// Description: Closes the door. Does necessary checks.
/obj/machinery/door/blast/close()
	if (src.operating || (stat & BROKEN || stat & NOPOWER))
		return
	force_close()


// Proc: repair()
// Parameters: None
// Description: Fully repairs the blast door.
/obj/machinery/door/blast/proc/repair()
	health = maxhealth
	set_broken(FALSE)


// SUBTYPE: Regular
// Your classical blast door, found almost everywhere.
/obj/machinery/door/blast/regular
	icon_state_open = "pdoor0"
	icon_state_opening = "pdoorc0"
	icon_state_closed = "pdoor1"
	icon_state_closing = "pdoorc1"
	icon_state = "pdoor1"
	maxhealth = 600
	block_air_zones = 1

/obj/machinery/door/blast/regular/open
	begins_closed = FALSE

/obj/machinery/door/blast/regular/singulo/emp_act()
	return

/obj/machinery/door/blast/regular/retro
	desc = "That looks like it doesn't open easily. However, it's probably not as durable as the modern ones."
	icon_state_open = "old_pdoor0"
	icon_state_opening = "old_pdoorc0"
	icon_state_closed = "old_pdoor1"
	icon_state_closing = "old_pdoorc1"
	icon_state = "old_pdoor1"
	maxhealth = 300

// SUBTYPE: Shutters
// Nicer looking, and also weaker, shutters. Found in kitchen and similar areas.
/obj/machinery/door/blast/shutters
	icon_state_open = "shutter0"
	icon_state_opening = "shutterc0"
	icon_state_closed = "shutter1"
	icon_state_closing = "shutterc1"
	icon_state = "shutter1"
	open_sound = 'sound/machines/shutters_open.ogg'
	close_sound = 'sound/machines/shutters_close.ogg'
	keep_items_on_close = TRUE // These are placed over tables often, so let's keep items be.
	assembly_path = /obj/structure/secure_door_assembly/shutters

/obj/machinery/door/blast/shutters/open
	begins_closed = FALSE
