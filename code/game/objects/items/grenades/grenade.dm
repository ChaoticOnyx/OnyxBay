/obj/item/grenade
	name = "grenade"
	desc = "A hand held grenade, with an adjustable timer."
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	item_state = "grenade"
	throw_range = 20
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT|SLOT_MASK
	var/active = FALSE
	var/broken = FALSE // For if we would like to reuse assembly
	var/det_time = null
	var/arm_sound = 'sound/weapons/armbomb.ogg'
	var/obj/item/safety_pin/safety_pin = null
	var/has_pin = TRUE // Currently else only for grenade/spawnergrenade
	var/obj/item/device/assembly_holder/detonator = null

/obj/item/grenade/proc/clown_check(mob/living/user)
	if((MUTATION_CLUMSY in user.mutations) && prob(50))
		to_chat(user, SPAN("warning", "Huh? How does this thing work?"))
		activate(user)
		add_fingerprint(user)
		return 0
	return 1

/obj/item/grenade/Initialize()
	. = ..()
	if(has_pin)
		safety_pin = new /obj/item/safety_pin
	detonator = new /obj/item/device/assembly_holder/timer_igniter(src)
	var/obj/item/device/assembly/timer/T = detonator.a_left
	det_time = 10*T.time

/obj/item/grenade/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) <= 0)
		if(!isnull(safety_pin) && has_pin)
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
	if(safety_pin && has_pin)
		user.put_in_hands(safety_pin)
		safety_pin = null;
		playsound(loc, 'sound/weapons/pin_pull.ogg', 40, 1)
		to_chat(user, SPAN("warning", "You remove the safety pin!"))
		update_icon()
		return
	if(detonator)
		if(!isigniter(detonator.a_left))
			detonator.a_left.activate()
			active = TRUE
		if(!isigniter(detonator.a_right))
			detonator.a_right.activate()
			active = TRUE

	broken = TRUE
	if(user)
		msg_admin_attack("[user.name] ([user.ckey]) primed \a [src] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	
	update_icon()
	playsound(loc, arm_sound, 75, 0, -3)

/obj/item/grenade/proc/detonate()
	var/turf/T = get_turf(src)
	if(T)
		T.hotspot_expose(700,125)

/obj/item/grenade/attackby(obj/item/W, mob/user)
	if(isScrewdriver(W))
		if(isnull(detonator))
			to_chat(user, SPAN("notice", "There is no detonator inside."))
			return 
		if(isnull(safety_pin) && has_pin && !active)
			if(prob(5))
				to_chat(user, SPAN("warning", "Your hand slips off the lever, triggering grenade!"))
				detonate()
				return
			broken = TRUE
			to_chat(user, SPAN("warning", "You broke grenade, while trying to remove detonator!"))
		if(active) 
			to_chat(user, SPAN("notice", "You begin to remove detonator from grenade chamber."))
			if(do_after(usr, 50, src))
				active = FALSE
				update_icon()
			else 
				to_chat(user, SPAN("warning", "You fail to fix assembly, and activate it instead."))
				detonate()
				return
		to_chat(user, SPAN("notice", "You carefully remove [detonator] from grenade chamber."))
		user.put_in_hands(detonator)
		detonator = null;
	if(istype(W, /obj/item/safety_pin) && user.is_item_in_hands(W) && has_pin)
		if(isnull(safety_pin) && has_pin)
			if(broken) broken = FALSE
			to_chat(user, SPAN("notice", "You insert [W] in place."))
			playsound(loc, 'sound/weapons/pin_insert.ogg', 40, 1)
			safety_pin = W
			user.remove_from_mob(W)
			W.forceMove(src)
			update_icon()
		else if(has_pin)
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
		playsound(loc, 'sound/items/Screwdriver2.ogg', 25, -3)
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
	if(isnull(safety_pin) && has_pin)
		icon_state = initial(icon_state) + "_primed"
		return
	icon_state = initial(icon_state)

/obj/item/grenade/attack_hand()
	walk(src, null, null)
	..()

/obj/item/grenade/dropped()
	..()
	if(isnull(safety_pin) && has_pin)
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
		if(!S.has_pin) return
		if(isnull(S.safety_pin))
			to_chat(user, SPAN("notice", "You insert [src] in place."))
			playsound(loc, 'sound/weapons/pin_insert.ogg', 40, 1)
			S.safety_pin = src
			user.remove_from_mob(src)
			src.forceMove(S)
			S.update_icon()
		else
			to_chat(user, SPAN("notice", "There is no need for second pin."))
