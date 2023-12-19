/datum/deity_power/structure/starlight/pylon
	name = "Pylon"
	desc = "A pylon to communicate with your followers."
	health_max = 300
	power_path = /obj/structure/deity/pylon/starlight

/obj/structure/deity/pylon/starlight
	icon_state = "starlight_pylon"

/datum/deity_power/structure/starlight/altar
	name = "Altar"
	desc = "An altar for your worshippers."
	health_max = 300
	power_path = /obj/structure/deity/altar/starlight

/obj/structure/deity/altar/starlight
	icon_state = "churchaltar"

/datum/deity_power/structure/starlight/statue
	name = "Radiant Statue"
	desc = "A statue."
	health_max = 500
	power_path = /obj/structure/deity/radiant_statue

/obj/structure/deity/radiant_statue
	name = "radiant statue"
	icon_state = "statue"
	var/charge = 0
	var/charging = FALSE

/obj/structure/deity/radiant_statue/on_update_icon()
	if(charging)
		icon_state = "statue_charging"
	else if(charge)
		icon_state = "statue_active"
	else
		icon_state = "statue"

/obj/structure/deity/radiant_statue/attack_hand(mob/living/L)
	if(!istype(L))
		return

/obj/structure/deity/radiant_statue/attackby(obj/item/I, mob/user)
	if(charging && (istype(I, /obj/item/material/knife/ritual/shadow) || istype(I, /obj/item/gun/energy/staff/beacon)) && charge_item(I, user))
		return FALSE

	return ..()

/obj/structure/deity/radiant_statue/proc/charge_item(obj/item/I, mob/user)
	if(istype(I, /obj/item/gun/energy))
		var/obj/item/gun/energy/energy = I
		if(energy.power_supply)
			energy.power_supply.give(energy.charge_cost * energy.max_shots)
			to_chat(user, SPAN_NOTICE("\The [src]'s glow envelops \the [I], restoring it to proper use."))
			charge--
			return TRUE

	else if(istype(I ,/obj/item/material/knife/ritual/shadow))
		var/obj/item/material/knife/ritual/shadow/shad = I
		shad.charge = initial(shad.charge)
		to_chat(user, SPAN_NOTICE("\The [src]'s glow envelops \the [I], restoring it to proper use."))
		charge--
		return TRUE

/obj/structure/deity/radiant_statue/activate(mob/living/deity/D)
	if(activate_charging())
		to_chat(D, SPAN_NOTICE("You activate \the [src], and it begins to charge as long as at least one of your followers is nearby."))
	else
		to_chat(D, SPAN_WARNING("\The [src] is either already activated, or there are no followers nearby to charge it."))

/obj/structure/deity/radiant_statue/proc/activate_charging()
	if(charging)
		return FALSE

	var/list/followers = get_followers_nearby()
	if(!followers.len)
		return FALSE

	charging = TRUE
	set_next_think(world.time + 1 SECOND)
	visible_message(SPAN_NOTICE("<b>\The [src]</b> hums, activating."))
	update_icon()
	return TRUE

/obj/structure/deity/radiant_statue/proc/get_followers_nearby()
	. = list()
	if(linked_deity)
		for(var/datum/mind/M in linked_deity.followers)
			if(get_dist(get_turf(M.current), get_turf(src)) <= 3)
				. += M.current

/obj/structure/deity/radiant_statue/think()
	if(charging)
		charge++
		var/list/followers = get_followers_nearby()
		if(!followers.len)
			stop_charging()

		if(charge == 40)
			visible_message(SPAN_NOTICE("<b>\The [src]</b> lights up, pulsing with energy."))
			stop_charging()
			update_icon()
	else
		charge -= 0.5
		var/list/followers = get_followers_nearby()
		if(!followers.len)
			return
		for(var/mob/living/L in followers)
			L.adjustFireLoss(-5)
			if(prob(80))
				to_chat(L, SPAN_NOTICE("You feel a pleasant warmth spread throughout your body..."))
			for(var/datum/spell/S in L.mind.learned_spells)
				S.charge_counter = S.charge_max
		if(charge == 0)
			stop_charging()
	set_next_think(world.time + 1 SECOND)

/obj/structure/deity/radiant_statue/proc/stop_charging()
	set_next_think(0)
	visible_message(SPAN_NOTICE("<b>\The [src]</b> powers down, returning to it's dormant form."))
	charging = FALSE
	update_icon()
