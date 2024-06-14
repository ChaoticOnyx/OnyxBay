//Thank you once again to qwerty for writing the directional calc for this.
/obj/structure/overmap/proc/check_quadrant(matrix/vector/point_of_collision)
	if(!point_of_collision)
		return
	var/matrix/vector/diff = point_of_collision - position
	diff.a /= 32 //Scale it down so that the math isn't off.
	diff.e /= 32
	var/shield_angle_hit = SIMPLIFY_DEGREES(diff.angle() - angle)
	switch(shield_angle_hit)
		if(0 to 89) //0 - 90 deg is the first right quarter of the circle, it's like dividing up a pizza!
			return ARMOUR_FORWARD_PORT
		if(90 to 179)
			return ARMOUR_AFT_PORT
		if(180 to 269)
			return ARMOUR_AFT_STARBOARD
		if(270 to 360) //Then this represents the last quadrant of the circle, the northwest one
			return ARMOUR_FORWARD_STARBOARD

/obj/structure/overmap/proc/projectile_quadrant_impact(obj/item/projectile/P)
	var/shield_angle_hit = SIMPLIFY_DEGREES(Get_Angle(P, src) - angle)
	switch(shield_angle_hit)
		if(0 to 89)
			return ARMOUR_FORWARD_PORT
		if(90 to 179)
			return ARMOUR_AFT_PORT
		if(180 to 269)
			return ARMOUR_AFT_STARBOARD
		if(270 to 360)
			return ARMOUR_FORWARD_STARBOARD

#define ARMOUR_DING pick('sound/effects/ship/freespace2/ding1.wav', 'sound/effects/ship/freespace2/ding2.wav', 'sound/effects/ship/freespace2/ding3.wav', 'sound/effects/ship/freespace2/ding4.wav', 'sound/effects/ship/freespace2/ding5.wav')

/obj/structure/overmap/proc/take_quadrant_hit(damage, quadrant)
	if(!quadrant)
		return

	if(!armour_quadrants[quadrant])
		return

	var/list/quad = armour_quadrants[quadrant]
	var/delta = damage-quad["current_armour"]
	quad["current_armour"] = max(quad["current_armour"] - damage, 0)
	if(delta <= 0)
		if(!impact_sound_cooldown)
			if(damage >= 15)
				shake_everyone(5)
			impact_sound_cooldown = TRUE
	else
		take_damage(delta)
	update_quadrants()

/obj/structure/overmap/proc/test()
	var/list/L = armour_quadrants[ARMOUR_FORWARD_PORT]
	L["current_armour"] = 0
	update_quadrants()

/obj/structure/overmap/proc/update_quadrants()
	for(var/X in armour_quadrants)
		var/list/L = armour_quadrants[X]
		if(!islist(L))
			continue
		CutOverlays(L["name"])
		if(L["current_armour"] <= L["max_armour"]/10)
			AddOverlays(L["name"])

#undef ARMOUR_DING

//Repair Procs

/obj/structure/overmap/proc/full_repair()
	integrity = max_integrity
	if(structure_crit)
		stop_relay(channel = SOUND_CHANNEL_AMBIENT)
		structure_crit = FALSE
		structure_crit_no_return = FALSE
	if(use_armour_quadrants)
		armour_quadrants["forward_port"]["current_armour"] = armour_quadrants["forward_port"]["max_armour"]
		armour_quadrants["forward_starboard"]["current_armour"] = armour_quadrants["forward_starboard"]["max_armour"]
		armour_quadrants["aft_port"]["current_armour"] = armour_quadrants["aft_port"]["max_armour"]
		armour_quadrants["aft_starboard"]["current_armour"] = armour_quadrants["aft_starboard"]["max_armour"]

/obj/structure/overmap/proc/repair_structure(input, failure = 0)
	var/percentile = input / 100

	integrity += max_integrity * percentile
	if(integrity > max_integrity)
		integrity = max_integrity
	if(structure_crit)
		if(integrity >= max_integrity * 0.2)
			stop_relay(channel = SOUND_CHANNEL_AMBIENT)
			structure_crit = FALSE

/obj/structure/overmap/proc/repair_quadrant(input, failure = 0, bias = 50, quadrant)
	var/percentile = input / 100
	if(use_armour_quadrants)
		if(prob(failure))
			if(prob(bias))
				var/misrepair_amount = max_integrity * percentile
				if(integrity - misrepair_amount < 10)
					integrity = 10
					handle_crit(misrepair_amount)
				else
					integrity -= max_integrity * percentile
				return
			else
				var/misrepair_quadrant = pick("forward_port", "forward_starboard", "aft_port", "aft_starboard")
				armour_quadrants[misrepair_quadrant]["current_armour"] -= armour_quadrants[misrepair_quadrant]["max_armour"] * percentile
				if(armour_quadrants[misrepair_quadrant]["current_armour"] < 0)
					armour_quadrants[misrepair_quadrant]["current_armour"] = 0

		armour_quadrants[quadrant]["current_armour"] += armour_quadrants[quadrant]["max_armour"] * percentile
		if(armour_quadrants[quadrant]["current_armour"] > armour_quadrants[quadrant]["max_armour"])
			armour_quadrants[quadrant]["current_armour"] = armour_quadrants[quadrant]["max_armour"]

/obj/structure/overmap/proc/repair_all_quadrants(input, failure = 0, bias = 50)
	var/percentile = input / 100
	if(use_armour_quadrants)
		var/list/quadrant_list = list("forward_port", "forward_starboard", "aft_port", "aft_starboard")
		if(prob(failure))
			if(prob(bias))
				var/misrepair_amount = max_integrity * percentile
				if(integrity - misrepair_amount < 10)
					integrity = 10
					handle_crit(misrepair_amount)
				else
					integrity -= max_integrity * percentile
				return
			else
				var/misrepair = pick_n_take(quadrant_list)
				armour_quadrants[misrepair]["current_armour"] -= armour_quadrants[misrepair]["max_armour"] * percentile
				if(armour_quadrants[misrepair]["current_armour"] < 0)
					armour_quadrants[misrepair]["current_armour"] = 0

		for(var/quad in quadrant_list)
			armour_quadrants[quad]["current_armour"] += armour_quadrants[quad]["max_armour"] * percentile
			if(armour_quadrants[quad]["current_armour"] > armour_quadrants[quad]["max_armour"])
				armour_quadrants[quad]["current_armour"] = armour_quadrants[quad]["max_armour"]

/obj/structure/overmap/proc/shake_everyone(severity)
	for(var/mob/M in mobs_in_ship)
		if(M.client)
			shake_camera(M, 5, 1)
