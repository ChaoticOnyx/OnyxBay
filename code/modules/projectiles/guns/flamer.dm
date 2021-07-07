//FLAMETHROWER

/obj/item/weapon/gun/flamer
	name = "\improper unbranded flamerthrower"
	desc = "Unbranded agricultural flamethrower. Used to burn weeds and pests or, you know, humans?"
	icon = 'icons/obj/flamer.dmi'
	icon_state = "flamer"
	item_state = "flamer"
	wielded_item_state = "flamer-wielded"
	slot_flags = SLOT_BACK
	w_class = ITEM_SIZE_HUGE
	origin_tech = list(TECH_COMBAT = 2)
	matter = list(MATERIAL_STEEL = 56250)
	force = 10
	fire_sound = 'sound/weapons/gunshot/flamethrower/flamer_fire.ogg'
	var/ignite_sound = list('sound/weapons/gunshot/flamethrower/ignite_flamethrower1.ogg', 'sound/weapons/gunshot/flamethrower/ignite_flamethrower2.ogg', 'sound/weapons/gunshot/flamethrower/ignite_flamethrower3.ogg')
	var/obj/item/weapon/welder_tank/fuel_tank = null
	var/obj/item/weapon/tank/oxygen/pressure_tank = null
	var/obj/item/device/assembly/igniter/igniter = null
	var/obj/item/device/analyzer/gauge = null
	var/max_range = 5
	var/pressure_for_shot = 150
	var/fuel_for_shot = 3
	one_hand_penalty = 2
	var/lit = FALSE //Turn the flamer on/off
	var/attached_electronics = list() //For gauge/igniter or other stuff
	action_button_name = "Remove fuel tank"
	var/last_use = 0
	var/last_fired = 0
	fire_delay = 35

/obj/item/weapon/gun/flamer/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/gun/flamer/examine(mob/user)
	. = ..()

	if(igniter)
		. += "\nIt's turned [lit? "on" : "off"]."
	else
		. += "\n[SPAN("warning", "Igniter not installed in [src]!")]"

	if(pressure_tank)
		. += "\nThe pressure tank wrenched into the [src]."

	if(gauge)
		if(fuel_tank)
			. += "\nThe fuel tank contains [round(get_fuel())]/[fuel_tank.max_fuel] units of fuel."
		else
			. += "\n[SPAN("warning", "There's no fuel tank in [src]!")]"

		if(pressure_tank)
			. += "\nThe pressure gauge shows the current tank is [pressure_tank.air_contents.return_pressure()]."
		else
			. += "\n[SPAN("warning", "There's no pressure tank in [src]!")]"

	else
		. += "\n[SPAN("warning", "Gauge not installed, you have no idea how much fuel left in [src]!")]"

/obj/item/weapon/gun/flamer/update_icon()
	overlays.Cut()
	if(igniter)
		overlays += "+igniter"
	if(fuel_tank)
		overlays += "+fuel_tank"
	if(pressure_tank)
		overlays += "+pressure_tank"
	if(gauge)
		overlays += "+gauge"
	if (lit && fuel_tank)
		overlays += "+lit"
	. = ..()

/obj/item/weapon/gun/flamer/proc/remove_fuel_tank(mob/user)
	if(!fuel_tank)
		to_chat(user, "There's no fuel tank in [src].")
		return
	lit = 0
	to_chat(user, "You twist the valve and pop the fuel tank out of [src].")
	playsound(loc, 'sound/weapons/flipblade.ogg', 50, 1)
	user.put_in_hands(fuel_tank)
	fuel_tank = null
	update_icon()
	return

/obj/item/weapon/gun/flamer/ui_action_click()
	remove_fuel_tank(usr)

/obj/item/weapon/gun/flamer/attack_hand(mob/user)
	if(user.get_inactive_hand() == src)
		remove_fuel_tank(user)
		return
	. = ..()
	update_icon()

/obj/item/weapon/gun/flamer/attackby(obj/item/W, mob/user)
	if(user.stat || user.restrained() || user.lying)
		return

	if(istype(W, /obj/item/weapon/welder_tank))
		if(fuel_tank)
			to_chat(user, "Remove the current fuel tank first.")
			return
		user.drop_from_inventory(W, src)
		fuel_tank = W
		playsound(loc, 'sound/weapons/flipblade.ogg', 50, 1)
		user.visible_message("[user] slot \a [W] into \the [src].", "You slot \a [W] into \the [src].")
		update_icon()
		return

	if(isWrench(W))
		if(!pressure_tank)
			to_chat(user, "There's no pressure tank in [src].")
			return
		var/turf/T = get_turf(src)
		to_chat(user, "You twist the valve and pop the pressure tank out of [src].")
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		pressure_tank.loc = T
		pressure_tank = null
		update_icon()
		return

	if(istype(W, /obj/item/device/assembly/igniter))
		if(igniter)
			to_chat(user, "Remove the current igniter first.")
			return
		user.drop_from_inventory(W, src)
		igniter = W
		playsound(loc, 'sound/weapons/flipblade.ogg', 50, 1)
		attached_electronics += new /obj/item/device/assembly/igniter
		user.visible_message("[user] slots \a [W] into \the [src].", "You slot \a [W] into \the [src].")
		update_icon()
		return

	if(istype(W, /obj/item/device/analyzer))
		if(gauge)
			to_chat(user, "Remove the current analyzer first.")
			return
		user.drop_from_inventory(W, src)
		gauge = W
		playsound(loc, 'sound/weapons/flipblade.ogg', 50, 1)
		attached_electronics += new /obj/item/device/analyzer
		user.visible_message("[user] slots \a [W] into \the [src].", "You slot \a [W] into \the [src].")
		update_icon()
		return

	if(istype(W, /obj/item/weapon/tank/oxygen))
		if(pressure_tank)
			to_chat(user, "Remove the current pressure tank first.")
			return
		user.drop_from_inventory(W, src)
		pressure_tank = W
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		user.visible_message("[user] wrench \a [W] into \the [src].", "You wrench \a [W] into \the [src].")
		update_icon()
		return

	if(isScrewdriver(W))//Taking this apart
		var/electonics_to_remove = input(user, "Which part do you want to remove?") as null|anything in attached_electronics
		if(!electonics_to_remove)
			return

		if(istype(electonics_to_remove, /obj/item/device/assembly/igniter))
			igniter.loc = user.loc
			igniter = null
			playsound(loc, 'sound/weapons/flipblade.ogg', 50, 1)
			attached_electronics -= electonics_to_remove

		if(istype(electonics_to_remove, /obj/item/device/analyzer))
			gauge.loc = user.loc
			gauge = null
			playsound(loc, 'sound/weapons/flipblade.ogg', 50, 1)
			attached_electronics -= electonics_to_remove
		update_icon()
		return
	update_icon()
	. = ..()

/obj/item/weapon/gun/flamer/attack_self(mob/user)
	return toggle_flame(user)

/obj/item/weapon/gun/flamer/proc/toggle_flame(mob/user)

	if(!igniter)
		to_chat(user, SPAN("warning", "Install ingiter first!"))
		playsound(loc, 'sound/signals/warning3.ogg', 50, 0)
		return
	if(!fuel_tank)
		to_chat(user, SPAN("warning", "Install fuel tank first!"))
		playsound(loc, 'sound/signals/warning3.ogg', 50, 0)
		return
	if(!lit)
		playsound(user, pick(ignite_sound), 100,1)
	lit = !lit
	update_icon()
	return TRUE

/obj/item/weapon/gun/flamer/Fire(atom/target, mob/living/user, params, pointblank=0, reflex=0)
	var/turf/curloc = get_turf(user) //In case the target or we are expired.
	var/turf/targloc = get_turf(target)
	if(!targloc || !curloc)
		return //Something has gone wrong...

	if(!is_held_twohanded(user))
		to_chat(user, SPAN("warning", "You cant fire on target with just one hand"))
		return

	if(is_flamer_can_fire(user))
		if(world.time > last_use + fire_delay)
			last_fired = world.time
			last_use = world.time
			unleash_flame(target, user)
			targloc.hotspot_expose(700,125)
			log_attack("[user] start spreadding fire with \ref[src].")
			return
		else
			to_chat(user, SPAN("warning", "[src] is not ready to fire again!"))
			playsound(loc, 'sound/signals/warning3.ogg', 50, 0)
			return


/obj/item/weapon/gun/flamer/proc/is_flamer_can_fire(mob/user)

	if(!fuel_tank)
		to_chat(user, SPAN("warning", "[src] isn't has a fuel tank"))
		playsound(loc, 'sound/signals/warning3.ogg', 50, 0)
		return
	if(!pressure_tank)
		to_chat(user, SPAN("warning", "[src] isn't has a pressure tank"))
		playsound(loc, 'sound/signals/warning3.ogg', 50, 0)
		return
	if(!lit)
		to_chat(user, SPAN("warning", "[src] isn't lit to fire"))
		return
	if(get_fuel() < fuel_for_shot)
		to_chat(user, SPAN("warning", "Not enough fuel!"))
		playsound(loc, 'sound/signals/warning3.ogg', 50, 0)
		return

	if(pressure_tank.air_contents.return_pressure() > 200)
		pressure_tank.air_contents.remove_ratio(0.02*(pressure_for_shot/100))
	else
		to_chat(user, SPAN("warning", "Not enough pressure!"))
		playsound(loc, 'sound/signals/warning3.ogg', 50, 0)
		return
	return TRUE

/obj/item/weapon/gun/flamer/handle_suicide(mob/living/user)
	if(!is_flamer_can_fire(user))
		return
	. = ..()

/obj/item/weapon/gun/flamer/Destroy()
	QDEL_NULL(fuel_tank)
	QDEL_NULL(pressure_tank)
	QDEL_NULL(igniter)
	QDEL_NULL(gauge)
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/weapon/gun/flamer/Process()
	if(lit)
		if(!lited(0.05))
			lit = FALSE

/obj/item/weapon/gun/flamer/proc/lited(amount) //remove fuel from fuel_tank
	if(!lit && !fuel_tank)
		return FALSE
	if(get_fuel() >= amount)
		fuel_tank.reagents.remove_reagent(/datum/reagent/fuel, amount)
		return TRUE

/obj/item/weapon/gun/flamer/proc/unleash_flame(atom/target, mob/living/user)

	last_fired = world.time
	var/burnlevel
	var/burntime

	var/list/turf/turfs = getline(user,target)
	playsound(user, fire_sound, 50, 1)
	var/distance = 1
	var/turf/prev_T

	for(var/F in turfs)
		var/blocked = FALSE
		var/turf/T = F

		if(T == user.loc)
			prev_T = T
			continue
		if(loc != user)
			break
		if(istype(T, /turf/simulated/wall))
			blocked = TRUE
		if(distance > max_range)
			break

		for(var/obj/O in T)
			if(O.density && !O.throwpass)
				blocked = TRUE
				break

		var/turf/TF
		if(!prev_T.Adjacent(T) && (T.x != prev_T.x || T.y != prev_T.y)) //diagonally blocked, it will seek for a cardinal turf by the former target.
			blocked = TRUE
			var/turf/Ty = locate(prev_T.x, T.y, prev_T.z)
			var/turf/Tx = locate(T.x, prev_T.y, prev_T.z)
			for(var/turf/TB in shuffle(list(Ty, Tx)))
				if(prev_T.Adjacent(TB) && ((!TB.density && !isspace(T))))
					TF = TB
					break
			if(!TF)
				break
		else
			TF = T

		flame_turf(TF,user, burntime, burnlevel)
		if(blocked)
			break
		distance++
		lited(distance/3)
		prev_T = T
		sleep(1)

//Returns the amount of fuel in the flamer
/obj/item/weapon/gun/flamer/proc/get_fuel()
	return fuel_tank ? fuel_tank.reagents.get_reagent_amount(/datum/reagent/fuel) : 0


/obj/item/weapon/gun/flamer/proc/flame_turf(turf/T, mob/living/user, heat, burn)
	if(!istype(T))
		return

	T.ignite(heat, burn)

	for(var/mob/living/M in T) //Deal bonus damage if someone's caught directly in initial stream
		M.adjust_fire_stacks(rand(2, burn))
		M.IgniteMob()

/obj/item/weapon/gun/flamer/get_temperature_as_from_ignitor()
	if(lit)
		return 3800
	return 0

/turf/proc/ignite(fire_lvl, burn_lvl, fire_stacks = 0, fire_damage = 0)
	//extinguish any flame present
	var/obj/flamer_fire/F = locate(/obj/flamer_fire) in src
	if(F)
		qdel(F)
	new /obj/flamer_fire(src, fire_lvl, burn_lvl, fire_stacks, fire_damage)
