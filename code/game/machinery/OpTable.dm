/obj/machinery/optable
	name = "Operating Table"
	desc = "Used for advanced medical procedures."

	icon = 'icons/obj/machines/surgery_table.dmi'
	icon_state = "surgery_table-idle"
	base_icon_state = "surgery_table"

	density = 1
	anchored = 1.0
	idle_power_usage = 1 WATTS
	active_power_usage = 5 WATTS
	var/strapped = 0.0
	var/busy = FALSE
	var/time_to_strip = 5 SECONDS
	/// Weakref to an operating computer
	var/weakref/opcomp
	/// Weakref to a patient on this table
	var/weakref/victim_ref

	component_types = list(
		/obj/item/circuitboard/optable,
		/obj/item/stock_parts/manipulator = 4
	)

	var/static/image/emissive_overlay
	beepsounds = SFX_BEEP_MEDICAL

/obj/machinery/optable/Initialize()
	. = ..()

	var/obj/machinery/computer/operating/comp = locate(/obj/machinery/computer/operating) in orange(2, src)
	if(istype(comp) && !comp.optable)
		comp.optable = weakref(src)
		opcomp = weakref(comp)

	register_signal(src, SIGNAL_MOVED, nameof(.proc/on_moved))
	var/turf/turf_to_listen = get_turf(src)
	if(istype(turf_to_listen))
		register_signal(turf_to_listen, SIGNAL_EXITED, nameof(.proc/atom_exited))

	RefreshParts()

	emissive_overlay = emissive_appearance(icon, "surgery_table_ea")
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/optable/LateInitialize()
	update_icon()

/obj/machinery/optable/on_update_icon()
	CutOverlays(emissive_overlay)
	var/should_glow = update_glow()
	if(should_glow)
		AddOverlays(emissive_overlay)

	if(stat & (BROKEN | NOPOWER) || isnull(victim_ref))
		icon_state = "[base_icon_state]-idle"
		return

	var/mob/living/carbon/human/victim = victim_ref?.resolve()
	icon_state = "[base_icon_state][victim?.pulse() ? "-active" : "-idle"]"

/obj/machinery/optable/proc/update_glow()
	if(inoperable(MAINT))
		set_light(0)
		return FALSE

	set_light(0.5, 0.1, 1, 3.5, COLOR_PALE_GREEN_GRAY)
	return TRUE

/obj/machinery/optable/proc/on_moved()
	var/turf/turf_to_listen = get_turf(src)
	if(istype(turf_to_listen))
		register_signal(turf_to_listen, SIGNAL_EXITED, nameof(.proc/atom_exited))

/obj/machinery/optable/proc/atom_exited(atom, atom/movable/exitee)
	if(ishuman(exitee) && exitee == victim_ref?.resolve())
		victim_ref = null
		update_icon()
		STOP_PROCESSING(SSmachines, src)

/obj/machinery/optable/Process()
	var/mob/living/carbon/human/H = victim_ref?.resolve()
	if(!istype(H) || H.loc != loc)
		STOP_PROCESSING(SSmachines, src)
		return

	play_beep()
	update_icon()

/obj/machinery/optable/RefreshParts()
    var/default_strip = 6 SECONDS
    var/efficiency = 0
    for(var/obj/item/stock_parts/P in component_parts)
        if(ismanipulator(P))
            efficiency += 0.25 * P.rating
    time_to_strip = clamp(default_strip - efficiency, 1 SECONDS, 5 SECONDS)

/obj/machinery/optable/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel_self()
		if(EXPLODE_HEAVY)
			if(prob(50))
				qdel_self()
		if(EXPLODE_LIGHT)
			if(prob(25))
				src.set_density(FALSE)

/obj/machinery/optable/attack_hand(mob/user as mob)
	if(MUTATION_HULK in usr.mutations)
		visible_message(SPAN_DANGER("\The [usr] destroys \the [src]!"))
		qdel_self()

/obj/machinery/optable/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASS_FLAG_TABLE)
		return TRUE

	return FALSE

/obj/machinery/optable/MouseDrop_T(obj/O, mob/user)
	if((!istype(O, /obj/item) || user.get_active_hand() != O) || !user.drop(O))
		return

	if(O.loc != loc)
		step(O, get_dir(O, src))

/obj/machinery/optable/verb/remove_clothes()
	set name = "Remove Clothes"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return

	if(inoperable(MAINT))
		show_splash_text(usr, "no power!", "\The [src] is unpowered!")
		return

	var/mob/living/carbon/human/patient = victim_ref?.resolve()
	if(!istype(patient))
		show_splash_text(usr, "no patient detected!")
		return

	if(istype(patient?.back, /obj/item/rig) && !patient?.back.can_be_unequipped_by(patient, slot_back, TRUE))
		show_splash_text(usr, "manual undressing required!")
		return

	if(!locate(/obj/item/clothing) in patient?.contents)
		show_splash_text(usr, "no clothes found!")
		return

	if(busy)
		show_splash_text(usr, "action already in progress!")
		return

	busy = TRUE
	usr.visible_message(SPAN_DANGER("[usr] begins to undress [patient] on the table with the built-in tool."),
						SPAN_NOTICE("You begin to undress [patient] on the table with the built-in tool."))
	if(do_after(usr, time_to_strip, patient))
		if(!patient)
			busy = FALSE
			return

		for(var/obj/item/clothing/C in patient?.contents)
			if(istype(C, /obj/item/clothing/mask/breath/anesthetic))
				continue

			patient?.drop(C)
			use_power_oneoff(100)
		usr.visible_message(SPAN_DANGER("[usr] successfully removes all clothing from [patient]."),
							SPAN_NOTICE("You successfully remove all clothing from [patient]."))

	busy = FALSE

/obj/machinery/optable/proc/take_victim_ref(mob/living/carbon/C, mob/living/carbon/user as mob)
	if(C == user)
		user.visible_message("[user] climbs on \the [src].","You climb on \the [src].")
	else
		visible_message("<span class='notice'>\The [C] has been laid on \the [src] by [user].</span>")

	if(C.client)
		C.client.perspective = EYE_PERSPECTIVE
		C.client.eye = src

	C.resting = TRUE
	C.dropInto(loc)
	add_fingerprint(user)

	if(ishuman(C))
		victim_ref = weakref(C)
		START_PROCESSING(SSmachines, src)

/obj/machinery/optable/MouseDrop_T(mob/target, mob/user)
	var/mob/living/M = user
	if(user.is_ic_dead() || user.incapacitated(INCAPACITATION_ALL) || !check_table(user) || !iscarbon(target))
		return

	if(istype(M))
		take_victim_ref(target,user)
	else
		return ..()

/obj/machinery/optable/climb_on()
	if(usr.is_ic_dead() || !ishuman(usr) || usr.incapacitated() || !check_table(usr))
		return

	take_victim_ref(usr, usr)

/obj/machinery/optable/attackby(obj/item/W, mob/living/carbon/user)
	if(default_deconstruction_screwdriver(user, W))
		return

	if(default_deconstruction_crowbar(user, W))
		return

	if(default_part_replacement(user, W))
		return

	if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(iscarbon(G.affecting) && check_table(G.affecting))
			take_victim_ref(G.affecting, usr)
			qdel(W)

/obj/machinery/optable/proc/check_table(mob/living/carbon/patient)
	var/mob/living/carbon/human/occupant = victim_ref?.resolve()
	if(istype(occupant) && get_turf(occupant) == get_turf(src) && occupant.lying)
		show_splash_text(usr, "already occupied!", "\The [src] is already occupied!")
		return FALSE

	if(patient.buckled)
		show_splash_text(usr, "unbuckle the patient first!", "You must unbuckle [patient] first!")
		return FALSE

	return TRUE

/obj/machinery/optable/Destroy()
	opcomp = null
	victim_ref = null
	return ..()
