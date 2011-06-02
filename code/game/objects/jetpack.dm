/obj/item/weapon/tank/jetpack
	name = "Jetpack (Oxygen)"
	icon_state = "jetpack0"
	var/on = 0.0
	w_class = 4.0
	item_state = "jetpack"
	var/datum/effects/system/ion_trail_follow/ion_trail

/obj/item/weapon/tank/jetpack/syndie
	icon_state = "jetpack0_s"
	item_state = "jetpack_s"


/obj/item/weapon/tank/jetpack/New()
	..()
	src.ion_trail = new /datum/effects/system/ion_trail_follow()
	src.ion_trail.set_up(src)
	src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*src.air_contents.volume/(R_IDEAL_GAS_EQUATION*T20C)
	return


/obj/item/weapon/tank/jetpack/MouseDrop(obj/over_object as obj)
	if ((istype(usr, /mob/living/carbon/human) || (ticker && ticker.mode.name == "monkey")))
		var/mob/M = usr
		if (!( istype(over_object, /obj/screen) ))
			return ..()
		if ((!( M.restrained() ) && !( M.stat ) && M.back == src))
			if (over_object.name == "r_hand")
				if (!( M.r_hand ))
					M.u_equip(src)
					M.r_hand = src
			else
				if (over_object.name == "l_hand")
					if (!( M.l_hand ))
						M.u_equip(src)
						M.l_hand = src
			M.update_clothing()
			src.add_fingerprint(usr)
			return
	return


/obj/item/weapon/tank/jetpack/proc/allow_thrust(num, mob/user as mob)
	if (!( src.on ))
		return 0
	if ((num < 0.01 || src.air_contents.total_moles() < num))
		src.ion_trail.stop()
		return 0

	var/datum/gas_mixture/G = src.air_contents.remove(num)

	if (G.oxygen >= 0.01)
		return 1
	if (G.toxins > 0.001)
		if (user)
			var/d = G.toxins / 2
			d = min(abs(user.health + 100), d, 25)
			user.fireloss += d
			user.updatehealth()
		return (G.oxygen >= 0.0075 ? 0.5 : 0)
	else
		if (G.oxygen >= 0.0075)
			return 0.5
		else
			return 0
	//G = null
	del(G)
	return


// Maybe it's best to have this hardcoded for whatever we'd add to the map, in order to avoid exploits
// (such as mining base => admin station)
// Note that this assumes the ship's top is at z=1 and bottom at z=4
/obj/item/weapon/tank/jetpack/proc/move_z(cardinal, mob/user as mob)
	if (user.z > 4)
		user << "\red There is nothing of interest in that direction."
		return
	if(allow_thrust(0.01, user))
		switch(cardinal)
			if (UP) // Going up!
				if(user.z != 1) // If we aren't at the very top of the ship
					var/turf/T = locate(user.x, user.y, user.z - 1)
					// You can only jetpack up if there's space above, and you're sitting on either hull (on the exterior), or space
					if(T && istype(T, /turf/space) && (istype(user.loc, /turf/space) || istype(user.loc, /turf/space/hull)))
						user.Move(T)
					else
						user << "\red You bump into the ship's plating."
				else
					user << "\red The ship's gravity well keeps you in orbit!" // Assuming the ship starts on z level 1, you don't want to go past it

			if (DOWN) // Going down!
				if (user.z != 4 && user.z != 5) // If we aren't at the very bottom of the ship, or out in space
					var/turf/T = locate(user.x, user.y, user.z + 1)
					// You can only jetpack down if you're sitting on space and there's space down below, or hull
					if(T && (istype(T, /turf/space) || istype(T, /turf/space/hull)) && istype(user.loc, /turf/space))
						user.Move(T)
					else
						user << "\red You bump into the ship's plating."
				else
					user << "\red The ship's gravity well keeps you in orbit!"


/obj/item/weapon/tank/jetpack/verb/toggle()
	src.on = !( src.on )
	src.icon_state = text("jetpack[]", src.on)
	if(src.on)
		src.ion_trail.start()
	else
		src.ion_trail.stop()
	return


/obj/item/weapon/tank/jetpack/syndie/toggle()
	src.on = !( src.on )
	src.icon_state = text("jetpack[]_s", src.on)
	if(src.on)
		src.ion_trail.start()
	else
		src.ion_trail.stop()
	return