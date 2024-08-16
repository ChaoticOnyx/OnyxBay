/obj/item/device/assembly_holder
	name = "Assembly"
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "holder"
	item_state = "assembly"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	throw_range = 10

	var/secured = 0
	var/obj/item/device/assembly/a_left = null
	var/obj/item/device/assembly/a_right = null
	var/obj/special_assembly = null

/obj/item/device/assembly_holder/New()
	..()
	GLOB.listening_objects += src

/obj/item/device/assembly_holder/Destroy()
	GLOB.listening_objects -= src
	return ..()

/obj/item/device/assembly_holder/proc/detached()
	return


/obj/item/device/assembly_holder/IsAssemblyHolder()
	return 1

/obj/item/device/assembly_holder/proc/attach(obj/item/device/assembly/D, obj/item/device/assembly/D2, mob/user)
	if(!istype(D) || !istype(D2))
		return FALSE
	if(D.secured || D2.secured)
		return FALSE
	if(user)
		if(D.loc == user)
			user.drop(D)
		if(D2.loc == user)
			user.drop(D2)
	D.forceMove(src)
	D2.forceMove(src)
	D.holder = src
	D2.holder = src
	D.forceMove(src)
	D2.forceMove(src)
	if(D.proximity_monitor)
		D.proximity_monitor.set_host(src, D)
	if(D2.proximity_monitor)
		D2.proximity_monitor.set_host(src, D2)
	a_left = D
	a_right = D2
	SetName("[D.name]-[D2.name] assembly")
	update_icon()
	user.pick_or_drop(src)
	return 1

/obj/item/device/assembly_holder/proc/attach_special(obj/O, mob/user)
	if(!O)	return
	if(!O.IsSpecialAssembly())	return 0
	return


/obj/item/device/assembly_holder/on_update_icon()
	ClearOverlays()
	if(a_left)
		AddOverlays("[a_left.icon_state]_left")
		for(var/O in a_left.attached_overlays)
			AddOverlays("[O]_l")
	if(a_right)
		AddOverlays("[a_right.icon_state]_right")
		for(var/O in a_right.attached_overlays)
			AddOverlays("[O]_r")
	if(master)
		master.update_icon()

/obj/item/device/assembly_holder/examine(mob/user, infix)
	. = ..()

	if((in_range(src, user) || src.loc == user))
		if(src.secured)
			. += "\The [src] is ready!"
		else
			. += "\The [src] can be attached!"

/obj/item/device/assembly_holder/HasProximity(atom/movable/AM)
	if(a_left)
		a_left.HasProximity(AM)
	if(a_right)
		a_right.HasProximity(AM)
	if(special_assembly)
		special_assembly.HasProximity(AM)


/obj/item/device/assembly_holder/Crossed(atom/movable/AM)
	if(a_left)
		a_left.Crossed(AM)
	if(a_right)
		a_right.Crossed(AM)
	if(special_assembly)
		special_assembly.Crossed(AM)


/obj/item/device/assembly_holder/on_found(mob/finder)
	if(a_left)
		a_left.on_found(finder)
	if(a_right)
		a_right.on_found(finder)
	if(special_assembly)
		if(istype(special_assembly, /obj/item))
			var/obj/item/S = special_assembly
			S.on_found(finder)

/obj/item/device/assembly_holder/forceMove(atom/new_loc)
	if(istype(loc, /atom/movable))
		if(istype(loc, /obj/item/gripper) && isrobot(loc.loc))
			unregister_signal(loc.loc, SIGNAL_MOVED)
		else
			unregister_signal(loc, SIGNAL_MOVED)
	if(istype(new_loc, /atom/movable))
		if(istype(new_loc, /obj/item/gripper) && isrobot(new_loc.loc))
			register_signal(new_loc.loc, SIGNAL_MOVED, nameof(.proc/retransmit_moved))
		else
			register_signal(new_loc, SIGNAL_MOVED, nameof(.proc/retransmit_moved))
	..()

/obj/item/device/assembly_holder/proc/retransmit_moved(mover, old_loc, new_loc)
	SEND_SIGNAL(src, SIGNAL_MOVED, src, old_loc, new_loc)

/obj/item/device/assembly_holder/attack_hand(mob/user)//Perhapse this should be a holder_pickup proc instead, can add if needbe I guess
	if(a_left && a_right)
		a_left.holder_movement()
		a_right.holder_movement()
	..()
	return


/obj/item/device/assembly_holder/attackby(obj/item/W, mob/user)
	if(isScrewdriver(W))
		if(!a_left || !a_right)
			to_chat(user, "<span class='warning'>BUG:Assembly part missing, please report this!</span>")
			return
		a_left.toggle_secure()
		a_right.toggle_secure()
		secured = !secured
		if(secured)
			to_chat(user, SPAN("notice", "\The [src] is ready!"))
		else
			to_chat(user, SPAN("notice", "\The [src] can now be taken apart!"))
		update_icon()
		return
	else if(W.IsSpecialAssembly())
		attach_special(W, user)
	else
		..()
	return


/obj/item/device/assembly_holder/attack_self(mob/user)
	src.add_fingerprint(user)
	if(src.secured)
		if(!a_left || !a_right)
			to_chat(user, SPAN("warning", "Assembly part missing!"))
			return
		if(istype(a_left,a_right.type))//If they are the same type it causes issues due to window code
			switch(alert("Which side would you like to use?",,"Left","Right"))
				if("Left")	a_left.attack_self(user)
				if("Right")	a_right.attack_self(user)
			return
		else
			if(!istype(a_left,/obj/item/device/assembly/igniter))
				a_left.attack_self(user)
			if(!istype(a_right,/obj/item/device/assembly/igniter))
				a_right.attack_self(user)
	else
		var/turf/T = get_turf(src)
		if(!T)	return 0
		if(a_left)
			a_left.holder = null
			a_left.forceMove(T)
			if(a_left.proximity_monitor)
				a_left.proximity_monitor.set_host(a_left, a_left)
		if(a_right)
			a_right.holder = null
			a_right.forceMove(T)
			if(a_right.proximity_monitor)
				a_right.proximity_monitor.set_host(a_right, a_right)
		spawn(0)
			user.drop(src)
			qdel(src)
	return


/obj/item/device/assembly_holder/proc/process_activation(obj/D, normal = 1, special = 1)
	if(!D)
		return 0
	if(!secured)
		visible_message("\icon[src] *beep* *beep*", "*beep* *beep*")
	if(normal && a_right && a_left)
		if(a_right != D)
			a_right.pulsed(0)
		if(a_left != D)
			a_left.pulsed(0)
	if(master)
		master.receive_signal()
	return 1

/obj/item/device/assembly_holder/hear_talk(mob/living/M, msg, verb, datum/language/language)
	if(a_right)
		a_right.hear_talk(M,msg, verb, language)
	if(a_left)
		a_left.hear_talk(M,msg, verb, language)


/obj/item/device/assembly_holder/timer_igniter
	name = "timer-igniter assembly"

/obj/item/device/assembly_holder/timer_igniter/New()
	..()

	var/obj/item/device/assembly/igniter/ign = new(src)
	ign.secured = TRUE
	ign.holder = src
	var/obj/item/device/assembly/timer/tmr = new(src)
	tmr.time = 5
	tmr.secured = TRUE
	tmr.holder = src
	a_left = tmr
	a_right = ign
	secured = TRUE
	update_icon()
	SetName(initial(name) + " ([tmr.time] secs)")

	loc.verbs += /obj/item/device/assembly_holder/timer_igniter/verb/configure

/obj/item/device/assembly_holder/timer_igniter/detached()
	loc.remove_verb(loc.loc, /obj/item/device/assembly_holder/timer_igniter/verb/configure)
	..()

/obj/item/device/assembly_holder/timer_igniter/verb/configure()
	set name = "Set Timer"
	set category = "Object"
	set src in usr

	if(!(usr.stat || usr.restrained()))
		var/obj/item/device/assembly_holder/holder
		if(istype(src,/obj/item/grenade/chem_grenade))
			var/obj/item/grenade/chem_grenade/gren = src
			holder=gren.detonator
		var/obj/item/device/assembly/timer/tmr = holder.a_left
		if(!istype(tmr,/obj/item/device/assembly/timer))
			tmr = holder.a_right
		if(!istype(tmr,/obj/item/device/assembly/timer))
			to_chat(usr, SPAN("notice", "This detonator has no timer."))
			return

		if(tmr.timing)
			to_chat(usr, SPAN("notice", "Clock is ticking already."))
		else
			var/ntime = input("Enter desired time in seconds", "Time", "5") as num
			if (ntime > 0 && ntime < 1000)
				tmr.time = ntime
				SetName(initial(name) + "([tmr.time] secs)")
				to_chat(usr, SPAN("notice", "Timer set to [tmr.time] seconds."))
			else
				to_chat(usr, SPAN("notice", "Timer can't be [ntime <= 0? "negative" : "more than 1000 seconds"]."))
	else
		to_chat(usr, SPAN("notice", "You cannot do this while [usr.stat ? "unconscious/dead" : "restrained"]."))
