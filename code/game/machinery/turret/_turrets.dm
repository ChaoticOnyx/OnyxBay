GLOBAL_LIST_EMPTY(all_turrets)

#define TURRET_WAIT 2
// Base type for rewritten turrets, designed to hopefully be cleaner and more fun to use and fight against.
// Use the subtypes for 'real' turrets.

/obj/machinery/turret
	name = "abstract turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	anchored = TRUE
	density = TRUE
	idle_power_usage = 50 WATTS
	active_power_usage = 300 WATTS
	interact_offline = TRUE
	power_channel = STATIC_EQUIP

	var/transform_animate_time = 0.2 SECONDS
	// Visuals.
	var/image/turret_stand = null
	var/image/turret_ray = null
	var/image/turret_underlay = null
	var/ray_color = "#ffffffff" // Color of the ray, changed by the FSM when switching states.
	var/ray_alpha = 255

	var/image/transverse_left // Images for displaying the range of the turret's transverse
	var/image/transverse_right

	/// Animation played when this turret goes up
	var/popup_anim = "popup"
	/// Animation played when this turret goes down
	var/popdown_anim = "popdown"

	// Sounds
	var/turn_on_sound = SFX_TURRET_DEPLOY // Played when turret goes from off to on.
	var/turn_off_sound = SFX_TURRET_RETRACT // The above, in reverse.

	// Shooting
	var/obj/item/gun/installed_gun = /obj/item/gun/energy/laser/practice // Instance of the gun inside the turret.
	var/gun_looting_prob = 25 // If the turret dies and then is disassembled, this is the odds of getting the gun.
	/// Number of stored ammo. Easier to store it then iterate through mags.
	var/stored_ammo = 0

	// Power
	var/enabled = TRUE // If false, turret turns off.
	/// World.time of last enabled, to prevent spam
	var/last_enabled
	var/toggle_cooldown = 2 SECONDS
	/// Determines how fast energy weapons will be recharged
	var/cell_charge_modifier = 1

	// Angles
	// Remember that in BYOND, NORTH equals 0 absolute degrees, and not 90.
	var/traverse = 360 // Determines how wide the turret can turn to shoot things, in degrees. The 'front' of the turret is determined by it's dir variable.
	var/leftmost_traverse = null // How far left or right the turret can turn. Set automatically using the above variable and the inital dir value.
	var/rightmost_traverse = null
	var/current_bearing = 0 // Current absolute angle the turret has, used to calculate if it needs to turn to try to shoot the target.
	var/target_bearing = 0 // The desired bearing. If the current bearing is too far from this, the turret will turn towards it until within tolerence.
	var/bearing_tolerence = 3 // Degrees that the turret must be within to be able to shoot at the target.
	var/turning_rate = 90 // Degrees per second.
	var/default_bearing = null // If no target is found, the turret will return to this bearing automatically.

	// Detection.
	var/datum/proximity_trigger/angle/proximity
	var/vision_range = 7	// How many tiles away the turret can see. Values higher than 7 will let the turret shoot offscreen, which might be unsporting.
							// Higher values may also have a performance cost.

	// Logic
	var/datum/state_machine/turret/state_machine = null
	var/weakref/target = null
	var/list/potential_targets = list()
	var/datum/hostility/hostility
	/// Determines whether this turret is raised or not
	var/raised = FALSE
	/// Whether this turret is moving its cover at the moment. No state transitions until it finishes moving.
	var/currently_raising = FALSE
	/// Boolean to prevent FSM spamming state switching.
	var/reloading = FALSE
	/// Firewall that prevents AI and synth from interacting with it directly.
	var/ailock = TRUE
	/// Whether this turret is locked or not, used for removing guns and disassembly.
	var/locked = TRUE

	// Integrity
	var/integrity = 80
	var/max_integrity = 80
	var/auto_repair = TRUE

	/// Weakref to an '/obj/machinery/turret_control_panel'
	var/weakref/master_controller = null

	/// Signaller
	var/obj/item/device/assembly/signaler/signaler = /obj/item/device/assembly/signaler
	/// The spark system for generating sparks
	var/datum/effect/effect/system/spark_spread/spark_system

	/// Will show a nice ray that displays this turret's targeting states.
	var/debug_mode = FALSE

	var/reloading_state = /datum/state/turret/reloading
	var/idle_state = /datum/state/turret/idle
	var/turning_state = /datum/state/turret/turning
	var/shooting_state = /datum/state/turret/engaging

/obj/machinery/turret/Initialize(mapload, _signaler)
	. = ..()

	hostility = new hostility()

	if(!_signaler && mapload)
		signaler = new signaler()
	else if(_signaler)
		signaler = _signaler
		signaler.forceMove(src)

	if(ispath(installed_gun))
		installed_gun = new installed_gun(src)
		setup_gun()

	add_think_ctx("process_reloading", CALLBACK(src, nameof(.proc/process_reloading)), 0)
	add_think_ctx("process_idle", CALLBACK(src, nameof(.proc/process_idle)), 0)
	add_think_ctx("process_turning", CALLBACK(src, nameof(.proc/process_turning)), 0)
	add_think_ctx("process_shooting", CALLBACK(src, nameof(.proc/process_shooting)), 0)
	add_think_ctx("emagged_targetting", CALLBACK(src, nameof(.proc/emagged_targeting)), 0)

	state_machine = add_state_machine(src, /datum/state_machine/turret)

	target_bearing = dir2angle(dir)
	set_bearing(target_bearing)
	calculate_traverse()

	proximity = new(src,
		/obj/machinery/turret/proc/on_proximity,
		/obj/machinery/turret/proc/on_changed_turf_visibility,
		vision_range,
		PROXIMITY_EXCLUDE_HOLDER_TURF,
		src,
		leftmost_traverse,
		rightmost_traverse
	)
	proximity.register_turfs()

	//Sets up a spark system
	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	update_icon()

	GLOB.all_turrets.Add(src)

/obj/machinery/turret/Destroy()
	remove_state_machine(src, /datum/state_machine/turret)

	QDEL_NULL(state_machine)
	QDEL_NULL(proximity)
	QDEL_NULL(installed_gun)
	QDEL_NULL(hostility)
	QDEL_NULL(turret_underlay)
	QDEL_NULL(signaler)
	QDEL_NULL(turret_stand)
	QDEL_NULL(turret_ray)
	QDEL_NULL(transverse_left)
	QDEL_NULL(transverse_right)
	QDEL_NULL(spark_system)

	target = null
	potential_targets.Cut()

	master_controller = null

	GLOB.all_turrets.Remove(src)

	return ..()

// Handles charging the powercell of an installed energy weapon.
/obj/machinery/turret/Process()
	if(istype(installed_gun, /obj/item/gun/energy))
		var/obj/item/gun/energy/energy_gun = installed_gun
		if(energy_gun.power_supply)
			var/obj/item/cell/power_cell = energy_gun.power_supply
			if(!power_cell.fully_charged())
				power_cell.give(active_power_usage * CELLRATE * cell_charge_modifier)
				update_use_power(POWER_USE_ACTIVE)
				return
			else
				update_use_power(POWER_USE_IDLE)

	if(auto_repair && (integrity < max_integrity))
		use_power_oneoff(20000)
		integrity = min(integrity + 1, max_integrity) // 1HP for 20kJ

/obj/machinery/turret/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/gun) && !installed_gun)
		if(istype(I, /obj/item/gun/projectile))
			var/obj/item/gun/projectile/proj_gun = I
			if(proj_gun.load_method != 4) // Not a magazine
				show_splash_text(user, "Unsupported weapon!")
				return

		else if(!istype(I, /obj/item/gun/energy))
			show_splash_text(user, "Unsupported weapon!")
			return

		if(!user.drop(I, src))
			return

		to_chat(user, SPAN_NOTICE("You install \the [I] into \the [src]!"))
		installed_gun = I
		setup_gun()
		return

	if(istype(installed_gun, /obj/item/gun/projectile) && (istype(I, /obj/item/ammo_magazine)))
		var/obj/item/gun/projectile/proj_gun = installed_gun
		var/obj/item/ammo_magazine/magazine = I
		if(ispath(proj_gun.allowed_magazines) && istype(magazine, proj_gun.allowed_magazines))
			store_ammo(I, user)
			return

		else if(islist(proj_gun.allowed_magazines) && is_type_in_list(magazine, proj_gun.allowed_magazines))
			store_ammo(I, user)
			return

	if(istype(I, /obj/item/card/id) || istype(I, /obj/item/device/pda))
		if(allowed(user))
			if(emagged)
				show_splash_text(user, "Control panel is unresponsive")
			else
				locked = !locked
				show_splash_text(user, "Turret [locked ? "locked" : "unlocked"]")
		return

	if(isCrowbar(I) && !locked && installed_gun)
		if(do_after(user, 50, src))
			if(QDELETED(src) || !installed_gun || locked)
				return

			show_splash_text(user, "Weapon removed!")
			user.pick_or_drop(installed_gun)
			installed_gun = null

		return

	if(isWelder(I))
		var/obj/item/weldingtool/WT = I
		if(!WT.use_tool(src, user, delay = 4 SECONDS, amount = 5))
			return

		if(QDELETED(src) || !user)
			return

		show_splash_text(user, "External armor removed!")

		new /obj/machinery/turret_frame(get_turf(src), istype(signaler) ? signaler : null, 7) //7 == BUILDSTAGE_EARMOR_WELD

		qdel_self()

	return ..()

/obj/machinery/turret/proc/store_ammo(obj/item/ammo_magazine/magazine, mob/user)
	if(!user.drop(magazine, src))
		return

	stored_ammo++

/// Called after the gun gets instantiated or slotted in.
/obj/machinery/turret/proc/setup_gun()
	pass()

// State machine processing steps, called by looping timer
/obj/machinery/turret/proc/process_turning()
	if(!istype(state_machine?.current_state, turning_state))
		return

	if(!enabled || inoperable())
		state_machine.evaluate()
		return

	var/distance_from_target_bearing = get_distance_from_target_bearing()

	var/turn_rate = calculate_turn_rate_per_process()

	var/distance_this_step = clamp(distance_from_target_bearing, -turn_rate, turn_rate)

	if(!angle_within_traverse(current_bearing + distance_this_step))
		distance_this_step = 0

	set_bearing(current_bearing + distance_this_step)
	set_next_think_ctx("process_turning", world.time + TURRET_WAIT)
	state_machine.evaluate()

/obj/machinery/turret/proc/process_shooting()
	if(!istype(state_machine?.current_state, shooting_state))
		return

	if(operable())
		if(installed_gun && is_valid_target(target?.resolve()))
			var/atom/resolved_target = target.resolve()
			if(istype(resolved_target))
				fire_weapon(resolved_target)
		else
			target = null

	set_next_think_ctx("process_shooting", world.time + TURRET_WAIT)
	state_machine.evaluate()

/obj/machinery/turret/proc/fire_weapon(atom/resolved_target)
	installed_gun?.Fire(resolved_target, src)

/obj/machinery/turret/proc/process_reloading()
	if(!istype(state_machine?.current_state, reloading_state))
		return

	if(istype(installed_gun, /obj/item/gun/projectile))
		var/obj/item/gun/projectile/proj_gun = installed_gun

		if(proj_gun.is_jammed)
			proj_gun.is_jammed = FALSE
			playsound(loc, 'sound/weapons/flipblade.ogg', 50, 1)

		else if(proj_gun.load_method & 4) // #define MAGAZINE 4
			for(var/obj/item/ammo_magazine/mag in contents)
				if(ispath(proj_gun.allowed_magazines) && !istype(mag, proj_gun.allowed_magazines))
					continue

				if(islist(proj_gun.allowed_magazines) && !is_type_in_list(mag, proj_gun.allowed_magazines))
					continue

				proj_gun.unload_ammo(src, TRUE, get_turf(src))
				proj_gun.load_ammo(mag, src)

				stored_ammo--

				break

	state_machine.evaluate()
	reloading = FALSE

/obj/machinery/turret/proc/process_idle()
	if(!istype(state_machine?.current_state, idle_state))
		return

	if(!isnull(default_bearing) && (target_bearing != default_bearing) && angle_within_traverse(default_bearing))
		target_bearing = default_bearing

		set_next_think_ctx("process_idle", world.time + TURRET_WAIT)
		state_machine.evaluate()

// Calculates the turret's leftmost and rightmost angles from the turret's direction and traverse.
/obj/machinery/turret/proc/calculate_traverse()
	if(traverse >= 360)
		leftmost_traverse = 0
		rightmost_traverse = 0
	else
		var/half_arc = traverse / 2
		leftmost_traverse = SIMPLIFY_DEGREES(dir2angle(dir) - half_arc)
		rightmost_traverse = SIMPLIFY_DEGREES(dir2angle(dir) + half_arc)

	if(istype(proximity))
		proximity.l_angle_ = leftmost_traverse
		proximity.r_angle_ = rightmost_traverse

		proximity.register_turfs()

	CutOverlays(list(transverse_right, transverse_left))
	transverse_left = null
	transverse_right = null
	update_icon()

// Returns TRUE if the input is within the two angles that determine the traverse.
/obj/machinery/turret/proc/angle_within_traverse(angle)
	if(traverse >= 360)
		return TRUE

	return angle_between_two_angles(leftmost_traverse, angle, rightmost_traverse)

/obj/machinery/turret/set_dir(ndir)
	..()
	calculate_traverse()

// Instantly turns the turret to a specific absolute angle.
/obj/machinery/turret/proc/set_bearing(new_angle)
	current_bearing = SIMPLIFY_DEGREES(new_angle)
	SetTransform(rotation = current_bearing)

// Gives a new target bearing, if the turret's capable of turning to it.
/obj/machinery/turret/proc/set_target_bearing(new_angle)
	new_angle = SIMPLIFY_DEGREES(new_angle)
	if(angle_within_traverse(new_angle))
		target_bearing = new_angle

// Turret turning calculations
#define TURN_CLOCKWISE 1
#define TURN_COUNTERCLOCKWISE -1
// Returns the signed distance from the target bearing
/obj/machinery/turret/proc/get_distance_from_target_bearing()
	var/raw_distance = target_bearing - current_bearing
	if(traverse < 360)
		if(SIMPLIFY_DEGREES(target_bearing - current_bearing) <= SIMPLIFY_DEGREES(rightmost_traverse - current_bearing))
			return SIMPLIFY_DEGREES(raw_distance * TURN_CLOCKWISE)
		else if(SIMPLIFY_DEGREES(current_bearing - target_bearing) <= SIMPLIFY_DEGREES(current_bearing - leftmost_traverse))
			return SIMPLIFY_DEGREES(raw_distance * TURN_COUNTERCLOCKWISE)
		return 0

	// The turret can traverse the entire circle, so it must decide which direction is a shorter distance.
	return closer_angle_difference(current_bearing, target_bearing)

/obj/machinery/turret/proc/within_bearing()
	var/distance_from_target_bearing = closer_angle_difference(current_bearing, target_bearing)
	return abs(distance_from_target_bearing) <= bearing_tolerence

#undef TURN_CLOCKWISE
#undef TURN_COUNTERCLOCKWISE

/obj/machinery/turret/proc/calculate_turn_rate_per_process()
	return turning_rate / (1 SECOND / TURRET_WAIT)

// Turret proximity handling
/obj/machinery/turret/proc/on_proximity(atom/movable/AM)
	if(inoperable()) // Should be handled by the state machine, but just in case.
		return

	if(target?.resolve() == AM)
		track_target()
	else
		add_target(AM)

/// Called when a door opens etc., immediately check the newly visible turfs for targets.
/obj/machinery/turret/proc/on_changed_turf_visibility(list/prior_turfs, list/current_turfs)
	if(!length(prior_turfs))
		return // Don't perform this check on spawn

	if(inoperable() || QDELETED(src))
		return

	var/list/turfs_to_check = current_turfs - prior_turfs
	for(var/turf/T as anything in turfs_to_check)
		for(var/atom/movable/AM in T)
			on_proximity(AM)

// Turret targeting
/obj/machinery/turret/proc/can_be_hostile_to(atom/potential_target)
	return hostility?.can_target(src, potential_target)

/obj/machinery/turret/proc/set_target(atom/new_target)
	if(is_valid_target(new_target))
		target = weakref(new_target)
		set_target_bearing(Get_Angle(src, target.resolve()))

/obj/machinery/turret/proc/is_valid_target(atom/A)
	if(!istype(A))
		return FALSE

	if(!angle_within_traverse(Get_Angle(src, A)))
		return FALSE

	if(!can_be_hostile_to(A))
		return FALSE

	if(!(get_turf(A) in proximity.seen_turfs_))
		return FALSE

	return TRUE

/obj/machinery/turret/proc/find_target()
	if(is_valid_target(target?.resolve()))
		set_target_bearing(Get_Angle(src, target.resolve()))
		return target

	else if(length(potential_targets))
		while(length(potential_targets))
			var/weakref/W = potential_targets[1]
			potential_targets -= W
			if(is_valid_target(W.resolve()))
				target = W
				track_target()
				return W

	target = null
	return null

/obj/machinery/turret/proc/add_target(atom/A)
	if(is_valid_target(A))
		if(!target)
			target = weakref(A)
			track_target()
		else
			potential_targets |= weakref(A)

		return TRUE
	return FALSE

/obj/machinery/turret/proc/track_target()
	set_target_bearing(Get_Angle(src, target.resolve()))
	state_machine.evaluate()

/obj/machinery/turret/proc/should_reload()
	if(reloading) // Reload sequence already in progress, aborting.
		return FALSE

	if(stored_ammo <= 0)
		return FALSE

	if(istype(installed_gun, /obj/item/gun/projectile))
		var/obj/item/gun/projectile/proj_gun = installed_gun
		if(proj_gun.is_jammed)
			return TRUE

		var/ammo_remaining = proj_gun.getAmmo() // Counts ammo in the chamber as well.
		if(ammo_remaining != 0)
			return FALSE

		else if(ammo_remaining == 0)
			return TRUE

		if(!is_valid_target(target?.resolve()) && length(proj_gun.ammo_magazine.stored_ammo) != proj_gun.ammo_magazine.max_ammo)
			return TRUE

	return FALSE

/obj/machinery/turret/emag_act(remaining_charges, mob/user, emag_source)
	if(!emagged)
		emagged = TRUE
		to_chat(user, SPAN_WARNING("You short out \the [src]'s threat assessment circuits."))
		visible_message("\The [src] hums oddly...")
		enabled = FALSE
		set_next_think_ctx("emagged_targeting", world.time + 6 SECONDS)
		state_machine.evaluate()

/obj/machinery/turret/proc/emagged_targeting()
	enabled = TRUE
	state_machine.evaluate()

/obj/machinery/turret/power_change()
	..()
	state_machine?.evaluate()

/obj/machinery/turret/proc/toggle_enabled(override = null)
	if(isnull(override))
		enabled = !enabled
	else
		enabled = override

	state_machine.evaluate()

/obj/machinery/turret/proc/change_firemode(firemode_index)
	if(!installed_gun || !LAZYLEN(installed_gun.firemodes))
		return FALSE

	if(firemode_index > LAZYLEN(installed_gun.firemodes) || firemode_index == installed_gun.sel_mode)
		return FALSE

	installed_gun.switch_firemodes(firemode_index)
	return TRUE

/obj/machinery/turret/on_update_icon()
	if(!turret_ray && debug_mode)
		turret_ray = image(icon, "turret_ray")
		turret_ray.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		turret_ray.appearance_flags = KEEP_APART | RESET_COLOR | TILE_BOUND | PIXEL_SCALE
		turret_ray.mouse_opacity = FALSE

		var/matrix/M = matrix(turret_ray.transform)
		// Offset away from the parent, so that when the parent rotates, this rotates with it correctly.
		M.Translate(0, (1 * WORLD_ICON_SIZE * 0.50) + 4)
		M.Scale(1, 4)
		turret_ray.transform = M
		AddOverlays(turret_ray)

	if(!transverse_left && leftmost_traverse)
		transverse_left = image(icon, "transverse_indicator_left")
		transverse_left.layer = src.layer - 0.01
		transverse_left.appearance_flags = KEEP_APART | RESET_TRANSFORM | TILE_BOUND | PIXEL_SCALE

		// Rotate according to transverse
		var/matrix/M = matrix(transverse_left.transform)
		M.Turn(leftmost_traverse)
		transverse_left.transform = M
		AddOverlays(transverse_left)

	if(!turret_underlay)
		turret_underlay = image(icon, "openTurretCover")
		turret_underlay.layer = src.layer - 0.02
		turret_underlay.appearance_flags = KEEP_APART | RESET_TRANSFORM | TILE_BOUND | PIXEL_SCALE

		AddOverlays(turret_underlay)

	if(!transverse_right && rightmost_traverse)
		transverse_right = image(icon, "transverse_indicator_right")
		transverse_right.layer = src.layer - 0.01
		transverse_right.appearance_flags = KEEP_APART | RESET_TRANSFORM | TILE_BOUND | PIXEL_SCALE

		// Rotate according to transverse
		var/matrix/M = matrix(transverse_right.transform)
		M.Turn(rightmost_traverse)
		transverse_right.transform = M
		AddOverlays(transverse_right)

	if(raised)
		icon_state = "grey_target_prism"
	else
		icon_state = "turretCover"

	// Changes the ray color based on state.
	if(debug_mode)
		CutOverlays(turret_ray)
		turret_ray?.color = ray_color
		AddOverlays(turret_ray)

	return ..()

/// Plays opening animation
/obj/machinery/turret/proc/popup()
	playsound(src, turn_on_sound, 80, TRUE)
	var/atom/flick_holder = new /atom/movable/porta_turret_cover(loc)
	flick_holder.layer = layer + 0.1
	var/icon/flick_icon = icon(icon, popup_anim)
	flick_holder.SetTransform(rotation = current_bearing)
	flick(flick_icon, flick_holder)
	raised = TRUE
	update_icon()
	sleep(10)
	qdel(flick_holder)
	currently_raising = FALSE

/// Plays closing animation
/obj/machinery/turret/proc/popdown()
	playsound(src, turn_off_sound, 80, TRUE)
	var/atom/flick_holder = new /atom/movable/porta_turret_cover(loc)
	flick_holder.layer = layer + 0.1
	var/icon/flick_icon = icon(icon, popdown_anim)
	flick_holder.SetTransform(rotation = current_bearing)
	flick(flick_icon, flick_holder)
	sleep(10)
	qdel(flick_holder)
	raised = FALSE
	update_icon()
	currently_raising = FALSE

/// Pops turret down or up according to the var 'state'.
/obj/machinery/turret/proc/change_raised(state)
	if(currently_raising)
		return FALSE

	currently_raising = TRUE

	if(state)
		INVOKE_ASYNC(src, nameof(.proc/popup))
	else
		INVOKE_ASYNC(src, nameof(.proc/popdown))

/obj/machinery/turret/proc/take_damage(force)
	if(stat & BROKEN)
		return

	if(!raised)
		force = force / 8
		if(force < 5)
			return

	state_machine.evaluate()

	integrity -= force

	if(force > 5 && prob(45))
		spark_system.start()

	if(integrity <= 0)
		die()

/obj/machinery/turret/bullet_act(obj/item/projectile/Proj)
	var/damage = Proj.get_structure_damage()

	if(!damage)
		return

	..()

	take_damage(damage)

/obj/machinery/turret/emp_act(severity)
	if(enabled)
		//if the turret is on, the EMP no matter how severe disables the turret for a while
		if(prob(5))
			emagged = TRUE

		toggle_enabled(FALSE)
		spawn(rand(60, 600))
			if(!enabled)
				toggle_enabled(TRUE)

	..()

/obj/machinery/turret/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel_self()

		if(EXPLODE_HEAVY)
			if(prob(25))
				qdel_self()
			else
				take_damage(max_integrity * 8) //should instakill most turrets

		if(EXPLODE_LIGHT)
			take_damage(max_integrity * 8 / 3)

/obj/machinery/turret/proc/die()	//called when the turret dies, ie, health <= 0
	integrity = 0
	set_broken(TRUE)
	spark_system.start()	//creates some sparks because they look cool
	atom_flags |= ATOM_FLAG_CLIMBABLE // they're now climbable

/obj/machinery/turret/malf_upgrade(mob/living/silicon/ai/user)
	ailock = FALSE
	malf_upgraded = TRUE
	to_chat(user, "\The [src] has been upgraded. It's damage and rate of fire has been increased. Auto-regeneration system has been enabled. Power usage has increased.")
	max_integrity = round(initial(max_integrity) * 1.5)
	auto_repair = TRUE
	change_power_consumption(round(initial(active_power_usage) * 5), POWER_USE_ACTIVE)
	return TRUE

/atom/movable/porta_turret_cover
	icon = 'icons/obj/turrets.dmi'
