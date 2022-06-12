/obj/item/gun/magnetic
	name = "improvised coilgun"
	desc = "A coilgun hastily thrown together out of a basic frame and advanced power storage components. Is it safe for it to be duct-taped together like that?"
	icon_state = "coilgun"
	item_state = "coilgun"
	icon = 'icons/obj/railgun.dmi'
	one_hand_penalty = 1
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 4, TECH_ILLEGAL = 2, TECH_MAGNET = 4)
	w_class = ITEM_SIZE_LARGE
	combustion = 1
	mod_weight = 1.0
	mod_reach = 0.8
	mod_handy = 1.0

	var/obj/item/cell/cell                              // Currently installed powercell.
	var/obj/item/stock_parts/capacitor/capacitor        // Installed capacitor. Higher rating == faster charge between shots.
	var/removable_components = TRUE                            // Whether or not the gun can be dismantled.

	var/obj/item/loaded                                        // Currently loaded object, for retrieval/unloading.
	var/load_type = /obj/item/stack/rods                       // Type of stack to load with.
	var/projectile_type = /obj/item/projectile/bullet/magnetic // Actual fire type, since this isn't throw_at rod launcher.

	var/heat_level = 0										   // When a magnetic weapon has too much heat, it malfunctions.
	var/able_to_overheat = TRUE							       // Changes whether it should or should not overheat.

	var/power_cost = 950                                       // Cost per fire, should consume almost an entire basic cell.
	var/power_per_tick                                         // Capacitor charge per process(). Updated based on capacitor rating.

/obj/item/gun/magnetic/Initialize()
	START_PROCESSING(SSobj, src)
	if(capacitor)
		power_per_tick = (power_cost*0.15) * capacitor.rating
	update_icon()
	. = ..()

/obj/item/gun/magnetic/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(cell)
	QDEL_NULL(loaded)
	QDEL_NULL(capacitor)
	. = ..()

/obj/item/gun/magnetic/Process()
	if(capacitor)
		if(cell)
			if(capacitor.charge < capacitor.max_charge && cell.checked_use(power_per_tick))
				capacitor.charge(power_per_tick)
		else
			capacitor.use(capacitor.charge * 0.05)
	update_icon()
	if(able_to_overheat && heat_level > 0)
		heat_level--

/obj/item/gun/magnetic/update_icon()
	var/list/overlays_to_add = list()
	if(removable_components)
		if(cell)
			overlays_to_add += image(icon, "[icon_state]_cell")
		if(capacitor)
			overlays_to_add += image(icon, "[icon_state]_capacitor")
	if(!cell || !capacitor)
		overlays_to_add += image(icon, "[icon_state]_red")
	else if(capacitor.charge < power_cost)
		overlays_to_add += image(icon, "[icon_state]_amber")
	else
		overlays_to_add += image(icon, "[icon_state]_green")
	if(loaded)
		overlays_to_add += image(icon, "[icon_state]_loaded")

	overlays = overlays_to_add
	..()

/obj/item/gun/magnetic/proc/show_ammo()
	if(loaded)
		return "<span class='notice'>It has \a [loaded] loaded.</span>"

/obj/item/gun/magnetic/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) <= 2)
		var/ret = show_ammo()
		if (ret)
			. += "\n[ret]"

		if(cell)
			. += "\n<span class='notice'>The installed [cell.name] has a charge level of [round((cell.charge/cell.maxcharge)*100)]%.</span>"
		if(capacitor)
			. += "\n<span class='notice'>The installed [capacitor.name] has a charge level of [round((capacitor.charge/capacitor.max_charge)*100)]%.</span>"

		if(!cell || !capacitor)
			. += "\n<span class='notice'>The capacitor charge indicator is blinking <font color ='[COLOR_RED]'>red</font>. Maybe you should check the cell or capacitor.</span>"
		else
			if(capacitor.charge < power_cost)
				. += "\n<span class='notice'>The capacitor charge indicator is <font color ='[COLOR_ORANGE]'>amber</font>.</span>"
			else
				. += "\n<span class='notice'>The capacitor charge indicator is <font color ='[COLOR_GREEN]'>green</font>.</span>"

		if(able_to_overheat && heat_level > 15)
			if(heat_level < 25)
				. += "\n<span class='warning'>\The [src]'s wiring glows faintly.</span>"
			else
				. += "\n<span class='danger'>\The [src]'s wiring is glowing brightly!</span>"

		return

/obj/item/gun/magnetic/attackby(obj/item/thing, mob/user)

	if(removable_components)
		if(istype(thing, /obj/item/cell))
			if(cell)
				to_chat(user, "<span class='warning'>\The [src] already has \a [cell] installed.</span>")
				return
			cell = thing
			user.drop_from_inventory(cell)
			cell.forceMove(src)
			playsound(loc, 'sound/machines/click.ogg', 10, 1)
			user.visible_message("<span class='notice'>\The [user] slots \the [cell] into \the [src].</span>")
			update_icon()
			return

		if(isScrewdriver(thing))
			if(!capacitor)
				to_chat(user, "<span class='warning'>\The [src] has no capacitor installed.</span>")
				return
			capacitor.forceMove(get_turf(src))
			user.put_in_hands(capacitor)
			user.visible_message("<span class='notice'>\The [user] unscrews \the [capacitor] from \the [src].</span>")
			playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
			capacitor = null
			update_icon()
			return

		if(istype(thing, /obj/item/stock_parts/capacitor))
			if(capacitor)
				to_chat(user, "<span class='warning'>\The [src] already has \a [capacitor] installed.</span>")
				return
			capacitor = thing
			user.drop_from_inventory(capacitor)
			capacitor.forceMove(src)
			playsound(loc, 'sound/machines/click.ogg', 10, 1)
			power_per_tick = (power_cost*0.15) * capacitor.rating
			user.visible_message("<span class='notice'>\The [user] slots \the [capacitor] into \the [src].</span>")
			update_icon()
			return

	if(istype(thing, load_type))

		if(loaded)
			to_chat(user, "<span class='warning'>\The [src] already has \a [loaded] loaded.</span>")
			return

		// This is not strictly necessary for the magnetic gun but something using
		// specific ammo types may exist down the track.
		var/obj/item/stack/ammo = thing
		if(!istype(ammo))
			loaded = thing
			user.drop_from_inventory(thing)
			thing.forceMove(src)
		else
			loaded = new load_type(src, 1)
			ammo.use(1)

		user.visible_message("<span class='notice'>\The [user] loads \the [src] with \the [loaded].</span>")
		playsound(loc, 'sound/weapons/flipblade.ogg', 50, 1)
		update_icon()
		return
	. = ..()

/obj/item/gun/magnetic/attack_hand(mob/user)
	if(user.get_inactive_hand() == src)
		var/obj/item/removing

		if(loaded)
			removing = loaded
			loaded = null
		else if(cell && removable_components)
			removing = cell
			cell = null

		if(removing)
			removing.forceMove(get_turf(src))
			user.put_in_hands(removing)
			user.visible_message("<span class='notice'>\The [user] removes \the [removing] from \the [src].</span>")
			playsound(loc, 'sound/machines/click.ogg', 10, 1)
			update_icon()
			return
	. = ..()

/obj/item/gun/magnetic/proc/check_ammo()
	return loaded

/obj/item/gun/magnetic/proc/use_ammo()
	qdel(loaded)
	loaded = null

/obj/item/gun/magnetic/proc/increase_heat_level()
	if(prob(30))
		heat_level += rand(5, 9)
	else
		heat_level += rand(3, 5)

/obj/item/gun/magnetic/proc/emit_sparks()
	var/datum/effect/effect/system/spark_spread/spark = new /datum/effect/effect/system/spark_spread()
	spark.set_up(3, 1, src)
	spark.start()

/obj/item/gun/magnetic/consume_next_projectile(mob/user)

	if(!check_ammo() || !capacitor || capacitor.charge < power_cost)
		return

	if(able_to_overheat)
		increase_heat_level()
		if(heat_level > 10 && prob(5 + heat_level))
			if(heat_level < 15 || prob(90 - heat_level))
				to_chat(user, "<span class='warning'>\The [src] misfires!</span>")
				capacitor.use(power_cost)
				emit_sparks()
				update_icon()
				return
			else
				if(heat_level < 30 || prob(100 - heat_level))
					if(electrocute_mob(user, cell, src))
						emit_sparks()
						to_chat(user, "<span class='danger'>You accidentally ground bare wiring of [src]!</span>")
						return
				else
					spawn(3) // So that it will still fire - considered modifying Fire() to return a value but burst fire makes that annoying.
						visible_message("<span class='danger'>\The [src] explodes with the force of the shot!</span>")
						explosion(get_turf(src), -1, 0, 2)
						qdel(src)

		if(heat_level > 15)
			emit_sparks()

	use_ammo()
	capacitor.use(power_cost)
	update_icon()

	return new projectile_type(src)
