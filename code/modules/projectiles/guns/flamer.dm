//FLAMETHROWER

/obj/item/weapon/gun/flamer
	name = "\improper unbranded flamerthrower"
	desc = "Unbranded agricultural flamethrower. Used to burn weeds and pests or, you know, humans?"
	icon = 'icons/obj/flamer.dmi'
	icon_state = "flamer"
	item_state = "flamer"
	slot_flags = SLOT_BACK
	w_class = ITEM_SIZE_HUGE
	origin_tech = list(TECH_COMBAT = 2)
	matter = list(MATERIAL_STEEL = 1500)
	force = 15
	fire_sound = 'sound/weapons/gunshot/flamethrower/flamer_fire.ogg'
	var/ignite_sound = list('sound/weapons/gunshot/flamethrower/ignite_flamethrower1.ogg', 'sound/weapons/gunshot/flamethrower/ignite_flamethrower2.ogg', 'sound/weapons/gunshot/flamethrower/ignite_flamethrower3.ogg')
	var/obj/item/weapon/welder_tank/fuel_tank = null
	var/obj/item/weapon/tank/oxygen/preassure_tank = null
	var/obj/item/device/assembly/igniter/igniter = null
	var/obj/item/device/analyzer/gauge = null
	var/max_range = 5
	var/pressure_for_shot = 150
	var/fuel_for_shot = 3
	var/lit = FALSE //Turn the flamer on/off
	var/attached_electronics = list() //For gauge/igniter or other stuff
	action_button_name = "Remove fuel tank"

/obj/item/weapon/gun/flamer/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/gun/flamer/examine(mob/user)
	. = ..(user)

	if(igniter)
		to_chat(user, "It's turned [lit? "on" : "off"].")
	else
		to_chat(user, SPAN_WARN("Igniter not installed in [src]!"))

	if(gauge)
		if(fuel_tank)
			to_chat(user, "The fuel tank contains [get_fuel()]/[fuel_tank.max_fuel] units of fuel.")
		else
			to_chat(user, SPAN_WARN("There's no fuel tank in [src]!"))

		if(preassure_tank)
			to_chat(user, "The preassure gauge shows the current tank is [preassure_tank.air_contents.return_pressure()].")
		else
			to_chat(user, SPAN_WARN("There's no preassure tank in [src]!"))

	else
		to_chat(user, SPAN_WARN("Gauge not installed, you have no idea how much fuel left in [src]!"))

/obj/item/weapon/gun/flamer/update_icon()
	overlays.Cut()
	if(igniter)
		overlays += "+igniter"
	if(fuel_tank)
		overlays += "+fuel_tank"
	if(preassure_tank)
		overlays += "+preassure_tank"
	if(gauge)
		overlays += "+gauge"
	return

/obj/item/weapon/gun/flamer/proc/remove_fuel_tank(mob/user)
	if(!fuel_tank)
		to_chat(user, "There's no fuel tank in [src].")
		return

	to_chat(user, "You twist the valve and pop the fuel tank out of [src].")
	user.put_in_hands(fuel_tank)
	fuel_tank = null
	update_icon()

/obj/item/weapon/gun/flamer/ui_action_click()
	remove_fuel_tank(usr)

/obj/item/weapon/gun/flamer/attackby(obj/item/W, mob/user)
	if(user.stat || user.restrained() || user.lying)
		return

	if(istype(W, /obj/item/weapon/welder_tank))
		if(fuel_tank)
			to_chat(user, "Remove the current fuel tank first.")
			return
		user.drop_from_inventory(W, src)
		fuel_tank = W
		user.visible_message("[user] slots \a [W] into \the [src].", "You slot \a [W] into \the [src].")
		update_icon()
		return

	if(isWrench(W))
		if(!preassure_tank)
			to_chat(user, "There's no preassure tank in [src].")
			return
		var/turf/T = get_turf(src)
		to_chat(user, "You twist the valve and pop the preassure tank out of [src].")
		preassure_tank.loc = T
		preassure_tank = null
		update_icon()

	if(istype(W, /obj/item/device/assembly/igniter))
		if(igniter)
			to_chat(user, "Remove the current igniter first.")
			return
		user.drop_from_inventory(W, src)
		igniter = W
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
		attached_electronics += new /obj/item/device/analyzer
		user.visible_message("[user] slots \a [W] into \the [src].", "You slot \a [W] into \the [src].")
		update_icon()
		return

	if(istype(W, /obj/item/weapon/tank/oxygen))
		if(preassure_tank)
			to_chat(user, "Remove the current preassure tank first.")
			return
		user.drop_from_inventory(W, src)
		preassure_tank = W
		user.visible_message("[user] slots \a [W] into \the [src].", "You slot \a [W] into \the [src].")
		update_icon()
		return

	if(isScrewdriver(W))//Taking this apart
		var/turf/T = get_turf(src)
		var/electonics_to_remove = input(user, "Which part do you want to remove?") as null|anything in attached_electronics

		if(!electonics_to_remove) return
		if(istype(electonics_to_remove, /obj/item/device/assembly/igniter))
			igniter.loc = T
			igniter = null
			attached_electronics -= electonics_to_remove

		if(istype(electonics_to_remove, /obj/item/device/analyzer))
			gauge.loc = T
			gauge = null
			attached_electronics -= electonics_to_remove
		return



/obj/item/weapon/gun/flamer/attack_self(mob/user)
	return toggle_flame(user)

/obj/item/weapon/gun/flamer/proc/toggle_flame(mob/user)

	if(!lit)
		playsound(user, pick(ignite_sound), 100,1)
	if(!igniter)
		to_chat(user, SPAN_WARN("Install ingiter first!"))
		return
	lit = !lit

	var/image/I = image('icons/obj/flamer.dmi', src, "+lit")
	if (lit)
		overlays += I
	else
		overlays -= I
		qdel(I)

	return TRUE

/obj/item/weapon/gun/flamer/Fire(atom/target, mob/living/user, params, pointblank=0, reflex=0)

	var/turf/curloc = get_turf(user) //In case the target or we are expired.
	var/turf/targloc = get_turf(target)
	if(!targloc || !curloc)
		return //Something has gone wrong...

	if(is_flamer_can_fire(user))
		unleash_flame(target, user)
		log_attack("[user] start spreadding fire with \ref[src].")

/obj/item/weapon/gun/flamer/proc/is_flamer_can_fire(mob/user)

	if(!lit)
		to_chat(user, SPAN_WARN("[src] isn't lit to fire"))
		return
	if(!fuel_tank)
		to_chat(user, SPAN_WARN("[src] isn't has a fuel tank"))
		return
	if(!preassure_tank)
		to_chat(user, SPAN_WARN("[src] isn't has a preassure tank"))
		return

	if(get_fuel() < fuel_for_shot)
		to_chat(user, SPAN_WARN("Not enough fuel!"))
		return

	if(preassure_tank.air_contents.return_pressure() > 200)
		preassure_tank.air_contents.remove_ratio(0.02*(pressure_for_shot/100))
	else
		to_chat(user, SPAN_WARN("Not enough pressure!"))
		return
	return TRUE

/obj/item/weapon/gun/flamer/Destroy()
	QDEL_NULL(fuel_tank)
	QDEL_NULL(preassure_tank)
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

	var/burnlevel
	var/burntime

	var/list/turf/turfs = getline(user,target)
	playsound(user, fire_sound, 75, 1)
	var/distance = 1
	var/turf/prev_T

	for(var/F in turfs)
		var/turf/T = F

		if(T == user.loc)
			prev_T = T
			continue
		if(loc != user)
			break
		if(distance > max_range)
			break

		var/blocked = FALSE
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

	for(var/obj/effect/vine/V in T)
		qdel(V)

	for(var/mob/living/M in T) //Deal bonus damage if someone's caught directly in initial stream
		if(M.stat == DEAD)
			continue

		M.adjust_fire_stacks(rand(5,burn*2))
		M.IgniteMob()

/turf/proc/ignite(fire_lvl, burn_lvl, f_color, fire_stacks = 0, fire_damage = 0)
	//extinguish any flame present
	var/obj/flamer_fire/F = locate(/obj/flamer_fire) in src
	if(F)
		qdel(F)

	new /obj/flamer_fire(src, fire_lvl, burn_lvl, f_color, fire_stacks, fire_damage)

/obj/item/weapon/gun/flamer/proc/triangular_flame(atom/target, mob/living/user, burntime, burnlevel)
	set waitfor = 0

	var/unleash_dir = user.dir //don't want the player to turn around mid-unleash to bend the fire.
	var/list/turf/turfs = getline(user,target)
	playsound(user, fire_sound, 75, 1)
	var/distance = 1
	var/turf/prev_T

	for(var/turf/T in turfs)
		if(T == user.loc)
			prev_T = T
			continue
		if(T.density)
			break
		if(loc != user)
			break
		if(distance > max_range)
			break
		if(prev_T && LinkBlocked(prev_T, T))
			break
		flame_turf(T,user, burntime, burnlevel)
		prev_T = T
		addtimer(CALLBACK(src, .proc/triagular_list, unleash_dir, prev_T, T, user, distance, burntime, burnlevel), 1)

/obj/item/weapon/gun/flamer/proc/triagular_list(unleash_dir, prev_T, T, user, distance, burntime, burnlevel)
	var/list/turf/right = list()
	var/list/turf/left = list()
	var/turf/right_turf = T
	var/turf/left_turf = T
	var/right_dir = turn(unleash_dir, 90)
	var/left_dir = turn(unleash_dir, -90)
	for (var/i = 0, i < distance - 1, i++)
		right_turf = get_step(right_turf, right_dir)
		right += right_turf
		left_turf = get_step(left_turf, left_dir)
		left += left_turf

	var/turf/prev_R = T
	for (var/turf/R in right)
		if (R.density)
			break
		if(prev_R && LinkBlocked(prev_R, R))
			break

		flame_turf(R, user, burntime, burnlevel)
		prev_R = R

	var/turf/prev_L = T
	for (var/turf/L in left)
		if (L.density)
			break
		if(prev_L && LinkBlocked(prev_L, L))
			break

		flame_turf(L, user, burntime, burnlevel)
		prev_L = L

	distance++
