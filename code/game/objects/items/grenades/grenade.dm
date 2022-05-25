/obj/item/grenade
	name = "grenade"
	desc = "A hand held grenade, with an adjustable timer."
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	item_state = "grenade"
	throw_speed = 1
	throw_range = 20
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT|SLOT_MASK
	var/active = 0
	var/broken = FALSE // For if we would like to reuse assembly
	var/timer_id = null // Timer ID for bomb defusal
	var/det_time = null
	var/fail_det_time = 5 // If you are clumsy and fail, you get this time.
	var/arm_sound = 'sound/weapons/armbomb.ogg'
	var/obj/item/safety_pin/safety_pin = null
	var/have_pin = TRUE // Currently else only for grenade/spawnergrenade
	var/obj/item/device/assembly_holder/detonator = null

/obj/item/grenade/proc/clown_check(mob/living/user)
	if((MUTATION_CLUMSY in user.mutations) && prob(50))
		to_chat(user, SPAN("warning", "Huh? How does this thing work?"))
		det_time = fail_det_time
		activate(user)
		add_fingerprint(user)
		return 0
	return 1

/obj/item/grenade/Initialize()
	. = ..()
	detonator = new /obj/item/device/assembly_holder/timer_igniter(src)
	safety_pin = new /obj/item/safety_pin
	var/obj/item/device/assembly/timer/T = detonator.a_left
	det_time = 10*T.time

/obj/item/grenade/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) <= 0)
		if(!isnull(safety_pin) && have_pin)
			. += "\nThe safety pin is in place."
		else
			. += "\nThere is no safety pin in place."
		if(det_time > 1)
			. += "\nThe timer is set to [det_time/10] seconds."
			return
		if(det_time == null)
			return
		. += "\n\The [src] is set for instant detonation."

/obj/item/grenade/attack_self(mob/user)
	if(!active)
		if(clown_check(user))
			activate(user)
			add_fingerprint(user)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()

/obj/item/grenade/proc/activate(mob/user)
	if(broken) 
		to_chat(user, SPAN("notice", "You need to reinsert safety pin to use it one more time!"))
		return
	if(active) return
	if(isnull(detonator))
		to_chat(user, SPAN("warning", "The grenade is missing a detonator!"))
		return
	if(safety_pin && have_pin)
		user.put_in_hands(safety_pin)
		safety_pin = null;
		playsound(src.loc, 'sound/weapons/pin_pull.ogg', 40, 1)
		to_chat(user, SPAN("warning", "You remove the safety pin!"))
		update_icon()
		return

	active = 1
	broken = TRUE
	if(user)
		msg_admin_attack("[user.name] ([user.ckey]) primed \a [src] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	
	update_icon()
	playsound(loc, arm_sound, 75, 0, -3)
	timer_id = addtimer(CALLBACK(src, .proc/detonate), det_time)

/obj/item/grenade/proc/detonate()
	var/turf/T = get_turf(src)
	if(T)
		T.hotspot_expose(700,125)

/obj/item/grenade/attackby(obj/item/W, mob/user)
	if(isScrewdriver(W))
		if(isnull(detonator))
			to_chat(user, SPAN("notice", "There is no detonator inside."))
			return 
		if(active) 
			to_chat(user, SPAN("notice", "You begin to remove [detonator] from grenade chamber."))
			if(do_after(usr, 50, src))
				active = 0
				deltimer(timer_id)
				update_icon()
			else 
				to_chat(user, SPAN("warning", "You fail to fix assembly, and activate it instead."))
				detonate()
				return
			if(isnull(safety_pin))
				to_chat(user, SPAN("notice", "The assembly is not going off without safety pin."))
				return
		user.put_in_hands(detonator)
		detonator = null;
		to_chat(user, SPAN("notice", "You carefully remove [detonator] from grenade chamber."))
	if(istype(W, /obj/item/safety_pin) && user.is_item_in_hands(W) && have_pin)
		if(isnull(safety_pin))
			if(broken) broken = FALSE
			to_chat(user, SPAN("notice", "You insert [W] in place."))
			playsound(src.loc, 'sound/weapons/pin_insert.ogg', 40, 1)
			safety_pin = W
			user.remove_from_mob(W)
			W.forceMove(src)
			update_icon()
		else
			to_chat(user, SPAN("notice", "There is no need for second pin."))
	if(istype(W,/obj/item/device/assembly_holder) && isnull(detonator))
		var/obj/item/device/assembly_holder/det = W
		if(istype(det.a_left,det.a_right.type) || (!isigniter(det.a_left) && !isigniter(det.a_right)))
			to_chat(user, SPAN("warning", "Assembly must contain one igniter."))
			return
		if(!det.secured)
			to_chat(user, SPAN("warning", "Assembly must be secured with screwdriver."))
			return
		to_chat(user, SPAN("notice", "You add [W] to the metal casing."))
		playsound(src.loc, 'sound/items/Screwdriver2.ogg', 25, -3)
		user.remove_from_mob(det)
		det.loc = src
		detonator = det
		if(istimer(detonator.a_left))
			var/obj/item/device/assembly/timer/T = detonator.a_left
			det_time = 10*T.time
		else if(istimer(detonator.a_right))
			var/obj/item/device/assembly/timer/T = detonator.a_right
			det_time = 10*T.time
		else 
			det_time = null
	add_fingerprint(user)
	..()

/obj/item/grenade/update_icon()
	if(active)
		icon_state = initial(icon_state) + "_active"
		return
	if(isnull(safety_pin) && have_pin)
		icon_state = initial(icon_state) + "_primed"
		return
	icon_state = initial(icon_state)

/obj/item/grenade/attack_hand()
	walk(src, null, null)
	..()

/obj/item/grenade/dropped()
	..()
	if(isnull(safety_pin) && have_pin)
		activate()

/obj/item/safety_pin
	name = "safety pin"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "safety_pin"
	item_state = "safety_pin"
	desc = "A grenade safety pin."
	w_class = ITEM_SIZE_TINY

/obj/item/safety_pin/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/grenade) && user.is_item_in_hands(W))
		var/obj/item/grenade/S = W
		if(!S.have_pin) return
		if(isnull(S.safety_pin))
			to_chat(user, SPAN("notice", "You insert [src] in place."))
			playsound(src.loc, 'sound/weapons/pin_insert.ogg', 40, 1)
			S.safety_pin = src
			user.remove_from_mob(src)
			src.forceMove(S)
			S.update_icon()
		else
			to_chat(user, SPAN("notice", "There is no need for second pin."))
