/obj/vector_overlay
	name = "Vector overlay for overmap ships"
	desc = "Report this to a coder"
	icon = 'icons/overmap/thrust_vector.dmi'
	icon_state = "thrust_low"
	mouse_opacity = FALSE
	alpha = 0
	layer = ABOVE_STRUCTURE_LAYER

/// Helper proc to get the actual center of the ship, if the ship's hitbox is placed in the bottom left corner like they usually are.
/obj/structure/overmap/proc/get_center()
	RETURN_TYPE(/turf)
	return (bound_height > 32 && bound_height > 32) ? get_turf(locate((src.x + (pixel_collision_size_x / 32)/ 2), src.y + ((pixel_collision_size_y / 32) / 2), z)) : get_turf(src)

/obj/structure/overmap/proc/get_pixel_bounds()
	for(var/turf/T in obounds(src, pixel_x + pixel_collision_size_x/4, pixel_y + pixel_collision_size_y/4, pixel_x  + -pixel_collision_size_x/4, pixel_y + -pixel_collision_size_x/4) )//Forms a zone of 4 quadrants around the desired overmap using some math fuckery.
		T.SpinAnimation()

/obj/structure/overmap/proc/show_bounds()
	for(var/turf/T in locs)
		T.SpinAnimation()

/obj/effect/overmap_hitbox_marker
	name = "Hitbox display"
	icon = 'icons/overmap/default.dmi'
	icon_state = "hitbox_marker"

/obj/effect/overmap_hitbox_marker/Initialize(mapload, pixel_x, pixel_y, pixel_z, pixel_w)
	. = ..()
	src.pixel_x = pixel_x
	src.pixel_y = pixel_y
	src.pixel_z = pixel_z
	src.pixel_w = pixel_w

/obj/structure/overmap/proc/can_move()
	return TRUE

#define RELEASE_PRESSURE ONE_ATMOSPHERE

/obj/structure/overmap/proc/slowthink()
	if(structure_crit)
		if(world.time > last_critprocess + 1 SECONDS)
			last_critprocess = world.time

	disruption = max(0, disruption - 1)
	if(hullburn > 0)
		hullburn = max(0, hullburn - 1)
		if(hullburn == 0)
			hullburn_power = 0

	if(cabin_air)
		process_cabin_air()

	set_next_think_ctx("slowthink", world.time + 1 SECOND)

/// This proc handles processing atmos stuff.
/obj/structure/overmap/proc/process_cabin_air()
	if(cabin_air.total_moles > 0)
		var/delta = cabin_air.temperature - 20 CELSIUS
		cabin_air.temperature = cabin_air.temperature - max(-10, min(10, round(delta / 4, 0.1)))

	if(internal_tank)
		var/datum/gas_mixture/tank_air = internal_tank.return_air()
		var/cabin_pressure = cabin_air.return_pressure()
		var/pressure_delta = min(RELEASE_PRESSURE - cabin_pressure, (tank_air.return_pressure() - cabin_pressure) / 2)
		var/transfer_moles = 0
		if(pressure_delta > 0)
			if(tank_air.temperature > 0)
				transfer_moles = pressure_delta*cabin_air.volume/(cabin_air.temperature * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
				cabin_air.merge(removed)
		else if(pressure_delta < 0)
			var/turf/T = get_center()
			if(!T)
				return

			var/datum/gas_mixture/t_air = T.return_air()
			pressure_delta = cabin_pressure - RELEASE_PRESSURE
			if(t_air)
				pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
			if(pressure_delta > 0)
				transfer_moles = pressure_delta * cabin_air.return_pressure() / (cabin_air.temperature * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
				T.assume_air(removed)

#undef RELEASE_PRESSURE

/obj/structure/overmap/think()
	set waitfor = FALSE
	var/time = min(world.time - last_process, 10)
	time /= 10
	last_process = world.time

	last_offset.copy(offset)
	var/last_angle = angle
	if(!move_by_mouse && !ai_controlled)
		desired_angle = angle + keyboard_delta_angle_left + keyboard_delta_angle_right + movekey_delta_angle
		movekey_delta_angle = 0
	var/desired_angular_velocity = 0
	if(isnum(desired_angle))
		while(angle > desired_angle + 180)
			angle -= 360
			last_angle -= 360
		while(angle < desired_angle - 180)
			angle += 360
			last_angle += 360
		if(abs(desired_angle - angle) < (max_angular_acceleration * time))
			desired_angular_velocity = (desired_angle - angle) / time
		else if(desired_angle > angle)
			desired_angular_velocity = 2 * sqrt((desired_angle - angle) * max_angular_acceleration * 0.25)
		else
			desired_angular_velocity = -2 * sqrt((angle - desired_angle) * max_angular_acceleration * 0.25)

	var/angular_velocity_adjustment = Clamp(desired_angular_velocity - angular_velocity, -max_angular_acceleration*time, max_angular_acceleration*time)
	if(angular_velocity_adjustment)
		last_rotate = angular_velocity_adjustment / time
		angular_velocity += angular_velocity_adjustment
	else
		last_rotate = 0
	angle += angular_velocity * time

	var/velocity_mag = velocity.ln()
	if(velocity_mag > 0 && (z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
		var/drag = 0
		var/has_gravity = has_gravity(get_center())
		for(var/turf/T in locs)
			if(isspaceturf(T))
				continue

			drag += 0.001
			var/floating = TRUE
			if(has_gravity && velocity_mag >= 4)
				floating = TRUE
			var/datum/gas_mixture/env = T.return_air()
			var/pressure = env.return_pressure()
			drag += velocity_mag * pressure * 0.001
			if(pressure >= 10)
				if((!floating && has_gravity))
					drag += 0.5
					if(velocity_mag <= 2 && istype(T, /turf/simulated/floor) && prob(30))
						var/turf/simulated/floor/TF = T
						TF.make_plating()
						take_damage(3, BRUTE, "melee", FALSE)

		if(velocity_mag > 20)
			drag = max(drag, (velocity_mag - 20) / time)
		if(drag)
			var/drag_factor = 1 - Clamp(drag * time / velocity_mag, 0, 1)
			velocity.a *= drag_factor
			velocity.e *= drag_factor
			if(angular_velocity != 0)
				var/drag_factor_spin = 1 - Clamp(drag * 30 * time / abs(angular_velocity), 0, 1)
				angular_velocity *= drag_factor_spin

	CutOverlays("rcs_left")
	CutOverlays("rcs_right")
	CutOverlays("thrust")

	var/thrust_x
	var/thrust_y
	var/fx = cos(90 - angle)
	var/fy = sin(90 - angle)
	var/sx = fy
	var/sy = -fx
	last_thrust_forward = 0
	last_thrust_right = 0
	if(brakes)
		var/forward_thrust = -((fx * velocity.a) + (fy * velocity.e)) / time
		var/right_thrust = -((sx * velocity.a) + (sy * velocity.e)) / time
		forward_thrust = Clamp(forward_thrust, -backward_maxthrust, forward_maxthrust)
		right_thrust = Clamp(right_thrust, -side_maxthrust, side_maxthrust)
		thrust_x += forward_thrust * fx + right_thrust * sx;
		thrust_y += forward_thrust * fy + right_thrust * sy;
		last_thrust_forward = forward_thrust
		last_thrust_right = right_thrust
	else
		if(can_move() && user_thrust_dir)
			var/total_dv = get_delta_v()
			if(user_thrust_dir & NORTH)
				thrust_x += fx * total_dv
				thrust_y += fy * total_dv
				last_thrust_forward = total_dv
			if(user_thrust_dir & SOUTH)
				thrust_x -= fx * total_dv
				thrust_y -= fy * total_dv
				last_thrust_forward = -total_dv
			if(user_thrust_dir & EAST)
				thrust_x += sx * total_dv
				thrust_y += sy * total_dv
				last_thrust_right = total_dv
			if(user_thrust_dir & WEST)
				thrust_x -= sx * total_dv
				thrust_y -= sy * total_dv
				last_thrust_right = -total_dv

	velocity.a = clamp(velocity.a, -speed_limit, speed_limit)
	velocity.e = clamp(velocity.e, -speed_limit, speed_limit)

	velocity.a += thrust_x * time
	velocity.e += thrust_y * time
	if(inertial_dampeners)
		var/side_movement = (sx*velocity.a) + (sy*velocity.e)
		var/friction_impulse = ((mass / 10) + side_maxthrust) * time
		var/clamped_side_movement = Clamp(side_movement, -friction_impulse, friction_impulse)
		velocity.a -= clamped_side_movement * sx
		velocity.e -= clamped_side_movement * sy

	offset._set(offset.a + velocity.a * time, offset.e +  velocity.e * time, TRUE)

	position._set(x * 32 + offset.a * 32, y * 32 + offset.e * 32)

	while((offset.a != 0 && velocity.a != 0) || (offset.e != 0 && velocity.e != 0))
		var/failed_x = FALSE
		var/failed_y = FALSE
		if(offset.a > 0 && velocity.a > 0)
			dir = EAST
			if(!Move(get_step(src, EAST)))
				offset.a = 0
				failed_x = TRUE
				velocity.a *= -bounce_factor
				velocity.e *= lateral_bounce_factor
			else
				offset.a--
				last_offset.a--
		else if(offset.a < 0 && velocity.a < 0)
			dir = WEST
			if(!Move(get_step(src, WEST)))
				offset.a = 0
				failed_x = TRUE
				velocity.a *= -bounce_factor
				velocity.e *= lateral_bounce_factor
			else
				offset.a++
				last_offset.a++
		else
			failed_x = TRUE
		if(offset.e > 0 && velocity.e > 0)
			dir = NORTH
			if(!Move(get_step(src, NORTH)))
				offset.e = 0
				failed_y = TRUE
				velocity.e *= -bounce_factor
				velocity.a *= lateral_bounce_factor
			else
				offset.e--
				last_offset.e--
		else if(offset.e < 0 && velocity.e < 0)
			dir = SOUTH
			if(!Move(get_step(src, SOUTH)))
				offset.e = 0
				failed_y = TRUE
				velocity.e *= -bounce_factor
				velocity.a *= lateral_bounce_factor
			else
				offset.e++
				last_offset.e++
		else
			failed_y = TRUE
		if(failed_x && failed_y)
			break

	if(velocity.a == 0)
		if(offset.a > 0.5)
			if(Move(get_step(src, EAST)))
				offset.a--
				last_offset.a--
			else
				offset.a = 0
		if(offset.a < -0.5)
			if(Move(get_step(src, WEST)))
				offset.a++
				last_offset.a++
			else
				offset.a = 0
	if(velocity.e == 0)
		if(offset.e > 0.5)
			if(Move(get_step(src, NORTH)))
				offset.e--
				last_offset.e--
			else
				offset.e = 0
		if(offset.e < -0.5)
			if(Move(get_step(src, SOUTH)))
				offset.e++
				last_offset.e++
			else
				offset.e = 0
	dir = NORTH
	var/matrix/mat_from = new()
	mat_from.Turn(last_angle)
	var/matrix/mat_to = new()
	mat_to.Turn(angle)
	var/matrix/targetAngle = new()
	targetAngle.Turn(desired_angle)
	if(resize > 0)
		for(var/i = 0, i < resize, i++)
			mat_from.Scale(0.5,0.5)
			mat_to.Scale(0.5,0.5)
			targetAngle.Scale(0.5,0.5)
	if(pilot?.client && desired_angle && !move_by_mouse && vector_overlay)
		vector_overlay.transform = targetAngle
		vector_overlay.alpha = 255
	else
		vector_overlay?.alpha = 0
		targetAngle = null
	transform = mat_from

	pixel_x = last_offset.a*32
	pixel_y = last_offset.e*32

	animate(src, transform=mat_to, pixel_x = offset.a*32, pixel_y = offset.e*32, time = time*10, flags=ANIMATION_END_NOW)

	for(var/mob/living/M as() in operators)
		var/client/C = M.client
		if(!C)
			continue

		C.pixel_x = last_offset.a*32
		C.pixel_y = last_offset.e*32
		animate(C, pixel_x = offset.a*32, pixel_y = offset.e*32, time = time*10, flags=ANIMATION_END_NOW)
	user_thrust_dir = 0
	update_icon()

	if(angle != desired_angle)//No RCS needed if we're already facing where we want to go
		if(prob(80) && desired_angle)
			relay('sound/effects/ship/rcs.ogg', null, FALSE, SOUND_CHANNEL_HUM)

	var/list/left_thrusts = list()
	left_thrusts.len = 8
	var/list/right_thrusts = list()
	right_thrusts.len = 8
	var/back_thrust = 0
	if(last_thrust_right != 0)
		var/tdir = last_thrust_right > 0 ? WEST : EAST
		left_thrusts[tdir] = abs(last_thrust_right) / side_maxthrust
		right_thrusts[tdir] = abs(last_thrust_right) / side_maxthrust
	if(last_thrust_forward > 0)
		back_thrust = last_thrust_forward / forward_maxthrust
	if(last_thrust_forward < 0)
		left_thrusts[NORTH] = -last_thrust_forward / backward_maxthrust
		right_thrusts[NORTH] = -last_thrust_forward / backward_maxthrust
	if(last_rotate != 0)
		var/frac = abs(last_rotate) / max_angular_acceleration
		for(var/cdir in GLOB.cardinal)
			if(last_rotate > 0)
				right_thrusts[cdir] += frac
			else
				left_thrusts[cdir] += frac
	for(var/cdir in GLOB.cardinal)
		var/left_thrust = left_thrusts[cdir]
		var/right_thrust = right_thrusts[cdir]
		if(left_thrust)
			AddOverlays("rcs_left")
		if(right_thrust)
			AddOverlays("rcs_right")

	if(back_thrust)
		AddOverlays("thrust")

	set_next_think(world.time + 1.5)

/obj/structure/overmap/proc/get_delta_v()
	var/dv = 0
	for(var/obj/machinery/atmospherics/unary/engine/engine in engines)
		var/datum/extension/ship_engine/extension = get_extension(engine, /datum/extension/ship_engine)
		dv += extension.burn()

	return dv / 1000

/obj/structure/overmap/proc/collide(obj/structure/overmap/other, collision_velocity)
	var/src_vel_mag = src.velocity.ln()
	var/other_vel_mag = other.velocity.ln()
	var/col_angle = ATAN2((other.position.a + other.pixel_collision_size_x / 2) - (src.position.a + src.pixel_collision_size_x / 2), (other.position.e + other.pixel_collision_size_y / 2) - (src.position.e + pixel_collision_size_y / 2))

	if(((cos(src.velocity.angle() - col_angle) * src_vel_mag) - (cos(other.velocity.angle() - col_angle) * other_vel_mag)) < 0)
		return

	var/new_src_vel_x = ((																			\
		(src_vel_mag * cos(src.velocity.angle() - col_angle) * (src.mass - other.mass)) +			\
		(2 * other.mass * other_vel_mag * cos(other.velocity.angle() - col_angle))					\
	) / (src.mass + other.mass)) * cos(col_angle) + (src_vel_mag * sin(src.velocity.angle() - col_angle) * cos(col_angle + 90))

	var/new_src_vel_y = ((																			\
		(src_vel_mag * cos(src.velocity.angle() - col_angle) * (src.mass - other.mass)) +			\
		(2 * other.mass * other_vel_mag * cos(other.velocity.angle() - col_angle))					\
	) / (src.mass + other.mass)) * sin(col_angle) + (src_vel_mag * sin(src.velocity.angle() - col_angle) * sin(col_angle + 90))

	var/new_other_vel_x = ((																		\
		(other_vel_mag * cos(other.velocity.angle() - col_angle) * (other.mass - src.mass)) +		\
		(2 * src.mass * src_vel_mag * cos(src.velocity.angle() - col_angle))						\
	) / (other.mass + src.mass)) * cos(col_angle) + (other_vel_mag * sin(other.velocity.angle() - col_angle) * cos(col_angle + 90))

	var/new_other_vel_y = ((																		\
		(other_vel_mag * cos(other.velocity.angle() - col_angle) * (other.mass - src.mass)) +		\
		(2 * src.mass * src_vel_mag * cos(src.velocity.angle() - col_angle))						\
	) / (other.mass + src.mass)) * sin(col_angle) + (other_vel_mag * sin(other.velocity.angle() - col_angle) * sin(col_angle + 90))

	src.velocity._set(new_src_vel_x, new_src_vel_y)
	other.velocity._set(new_other_vel_x, new_other_vel_y)

	var/bonk = src_vel_mag
	var/bonk2 = other_vel_mag
	//Prevent ultra spam.
	if(!impact_sound_cooldown && (bonk > 2 || bonk2 > 2))
		bonk *= 5
		bonk2 *= 5
		take_quadrant_hit(bonk, projectile_quadrant_impact(other))
		other.take_quadrant_hit(bonk2, projectile_quadrant_impact(src))

		log_game("[key_name(pilot)] has impacted an overmap ship into [other] with velocity [bonk]")

/obj/structure/overmap/Bumped(atom/movable/A)
	if(brakes || isovermap(A))
		return FALSE

	if(A.dir & NORTH)
		velocity.e += bump_impulse
	if(A.dir & SOUTH)
		velocity.e -= bump_impulse
	if(A.dir & EAST)
		velocity.a += bump_impulse
	if(A.dir & WEST)
		velocity.a -= bump_impulse
	return ..()

/obj/structure/overmap/Bump(atom/movable/A)
	var/bump_velocity = 0
	if(dir & (NORTH|SOUTH))
		bump_velocity = abs(velocity.e) + (abs(velocity.a) / 10)
	else
		bump_velocity = abs(velocity.a) + (abs(velocity.e) / 10)
	if(layer < A.layer)
		return ..()

	if(istype(A, /obj/structure/overmap))
		collide(A, bump_velocity)
		return FALSE

	if(bump_velocity >= 3 && !impact_sound_cooldown && isobj(A))
		var/strength = bump_velocity
		strength = strength * strength
		strength = min(strength, 5)
		message_admins("[key_name_admin(pilot)] has impacted an overmap ship into [A] with velocity [bump_velocity]")
		log_game("[key_name(pilot)] has impacted an overmap ship into [A] with velocity [bump_velocity]")
		visible_message("<span class='danger'>The force of the impact causes a shockwave</span>")
	var/atom/movable/AM = A
	if(istype(AM) && !AM.anchored && bump_velocity > 1)
		step(AM, dir)
	if(isliving(A) && bump_velocity > 2)
		var/mob/living/M = A
		M.apply_damage(bump_velocity * 2)
		playsound(M.loc, "swing_hit", 1000, 1, -1)
		M.Weaken(1)
		M.visible_message("<span class='warning'>The force of the impact knocks [M] down!</span>","<span class='userdanger'>The force of the impact knocks you down!</span>")
	return ..()
