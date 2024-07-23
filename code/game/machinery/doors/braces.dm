
// BRACE - Can be installed on airlock to reinforce it and keep it closed.
/obj/item/airlock_brace
	name = "airlock brace"
	desc = "A sturdy device that can be attached to an airlock to reinforce it and provide additional security."
	w_class = ITEM_SIZE_LARGE
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "brace_open"
	var/cur_health
	var/max_health = 450
	var/obj/machinery/door/airlock/airlock = null
	var/obj/item/airlock_electronics/brace/electronics


/obj/item/airlock_brace/examine(mob/user, infix)
	. = ..()
	. += "[examine_health()]"


// This is also called from airlock's examine, so it's a different proc to prevent code copypaste.
/obj/item/airlock_brace/proc/examine_health()
	switch(health_percentage())
		if(-100 to 25)
			return "<span class='danger'>\The [src] looks seriously damaged, and probably won't last much more.</span>"
		if(25 to 50)
			return "<span class='notice'>\The [src] looks damaged.</span>"
		if(50 to 75)
			return "\The [src] looks slightly damaged."
		if(75 to 99)
			return "\The [src] has few dents."
		if(99 to INFINITY)
			return "\The [src] is in excellent condition."


/obj/item/airlock_brace/on_update_icon()
	if(airlock)
		icon_state = "brace_closed"
	else
		icon_state = "brace_open"


/obj/item/airlock_brace/New()
	..()
	cur_health = max_health
	electronics = new /obj/item/airlock_electronics/brace(src)
	update_access()

/obj/item/airlock_brace/Destroy()
	if(airlock)
		airlock.brace = null
		airlock = null
	qdel(electronics)
	electronics = null

	return..()

// Interact with the electronics to set access requirements.
/obj/item/airlock_brace/attack_self(mob/user as mob)
	electronics.attack_self(user)


/obj/item/airlock_brace/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W.get_id_card(), /obj/item/card/id))
		if(!airlock)
			attack_self(user)
			return
		else
			var/obj/item/card/id/C = W.get_id_card()
			update_access()
			if(check_access(C))
				to_chat(user, "You swipe \the [C] through \the [src].")
				if(do_after(user, 10, airlock, luck_check_type = LUCK_CHECK_ENG))
					to_chat(user, "\The [src] clicks a few times and detaches itself from \the [airlock]!")
					unlock_brace(usr)
			else
				to_chat(user, "You swipe \the [C] through \the [src], but it does not react.")
		return

	if (istype(W, /obj/item/crowbar/brace_jack))
		if(!airlock)
			return
		var/obj/item/crowbar/brace_jack/C = W
		to_chat(user, "You begin forcibly removing \the [src] with \the [C].")
		if(do_after(user, rand(150,300), airlock, luck_check_type = LUCK_CHECK_ENG))
			to_chat(user, "You finish removing \the [src].")
			unlock_brace(user)
		return

	if(isWelder(W))
		if(cur_health == max_health)
			to_chat(user, "\The [src] does not require repairs.")
			return

		var/obj/item/weldingtool/WT = W

		if(!WT.use_tool(src, user, amount = 1))
			return FALSE

		cur_health = min(cur_health + rand(80,120), max_health)
		if(cur_health == max_health)
			to_chat(user, "You repair some dents on \the [src]. It is in perfect condition now.")
		else
			to_chat(user, "You repair some dents on \the [src].")


/obj/item/airlock_brace/proc/take_damage(amount)
	cur_health = between(0, cur_health - amount, max_health)
	if(!cur_health)
		if(airlock)
			airlock.visible_message("<span class='danger'>\The [src] breaks off of \the [airlock]!</span>")
		unlock_brace(null)
		qdel(src)


/obj/item/airlock_brace/proc/unlock_brace(mob/user)
	if(!airlock)
		return
	if(user)
		user.pick_or_drop(src)
		airlock.visible_message("\The [user] removes \the [src] from \the [airlock]!")
	else
		forceMove(get_turf(src))
	airlock.brace = null
	airlock.update_icon()
	airlock = null
	update_icon()


/obj/item/airlock_brace/proc/health_percentage()
	if(!max_health)
		return 0
	return (cur_health / max_health) * 100

/obj/item/airlock_brace/proc/update_access()
	if(!electronics)
		return
	if(electronics.one_access)
		req_access = list()
		req_one_access = electronics.conf_access
	else
		req_access = electronics.conf_access
		req_one_access = list()
