/mob
	var/obj/structure/overmap/overmap_ship //Used for relaying movement, hotkeys etc.

/obj/structure/overmap
	name = "overmap ship"
	desc = "A space faring vessel."
	icon = 'icons/overmap/nsv13/nanotrasen/titan.dmi'
	icon_state = "titan"
	density = TRUE
	dir = NORTH
	layer = ABOVE_HUMAN_LAYER
	animate_movement = NO_STEPS // Override the inbuilt movement engine to avoid bouncing
	/// Bridge assistants/heads, munitions techs / fighter pilots, security officers, engineering personnel all have access.
	req_one_access = list(access_heads, access_sec_doors, access_engine)

	var/overmap_flags = 0

	anchored = FALSE

	var/overmap_deletion_traits = DAMAGE_DELETES_UNOCCUPIED | DAMAGE_STARTS_COUNTDOWN
	var/deletion_teleports_occupants = FALSE

	var/sprite_size = 64 //Pixels. This represents 64x64 and allows for the bullets that you fire to align properly.
	var/area_type = null //Set the type of the desired area you want a ship to link to, assuming it's not the main player ship.
	var/impact_sound_cooldown = FALSE //Avoids infinite spamming of the ship taking damage.
	var/datum/star_system/current_system //What star_system are we currently in? Used for parallax.
	var/resize = 0 //Factor by which we should shrink a ship down. 0 means don't shrink it.

	var/list/linked_areas = list() //List of all areas that we control
	var/datum/gas_mixture/cabin_air //Cabin air mix used for small ships like fighters (see overmap/fighters/fighters.dm)
	var/obj/machinery/portable_atmospherics/canister/internal_tank //Internal air tank reference. Used mostly in small ships. If you want to sabotage a fighter, load a plasma tank into its cockpit :)

	// Health, armor, and damage
	var/integrity = 0
	var/max_integrity = 300 //Max internal integrity
	var/integrity_failure = 0

	var/armour_plates = 0 //You lose max integrity when you lose armour plates.
	var/sensor_profile = 0	//A penalty (or, possibly even bonus) to from how far away one can be detected. Affected by things like sending out a active ping, which will make you glow like a christmas tree.
	var/cloak_factor = 255 // Min alpha of a ship during cloak. 0-255
	var/max_armour_plates = 0
	var/list/dent_decals = list() //Ships get visibly damaged as they get shot
	var/damage_states = FALSE //Did you sprite damage states for this ship? If yes, set this to true
	///Hullburn time, this is basically a DoT effect on ships. One day I'll have to add actual ship status effects, siiiigh.
	var/hullburn = 0
	///Hullburn strength is what determines the damage per tick, the strongest damage usually goes. Which means, a weaker weapon could be used to lengthen the duration of a strong but short one.
	var/hullburn_power = 0
	var/disruption = 0	//Causes bad effects proportional to how significant. Most significant for AI ships (or fighters) hit by disruption weapons.

	var/use_armour_quadrants = FALSE //Does the object use the armour quadrant system?
	var/max_armour = 0 //Max armour amount per quad
	var/current_armour = 0 //Per quad
	var/list/armour_quadrants = list("forward_port" = list(), "forward_starboard" = list(), "aft_port" = list(), "aft_starboard" = list()) //Our four quadrants

	var/structure_crit = FALSE //Handles when the ship's integrity has failed
	var/structure_crit_no_return = FALSE //Override for handling point of no return
	var/structure_crit_init = null //Timer ID for point of no return
	var/structure_crit_alert = 0 //Incremental warning states
	var/last_critprocess = 0 //Keeper for SS Crit timing
	var/explosion_cooldown = FALSE

	//Movement Variables
	var/offset_x = 0 // like pixel_x/y but in tiles
	var/offset_y = 0
	var/angle = 0 // degrees, clockwise
	var/keyboard_delta_angle_left = 0 // Set by use of turning key
	var/keyboard_delta_angle_right = 0 // Set by use of turning key
	var/movekey_delta_angle = 0 // A&D support
	var/desired_angle = null // set by pilot moving his mouse or by keyboard steering
	var/angular_velocity = 0 // degrees per second
	var/max_angular_acceleration = 180 // in degrees per second per second
	var/speed_limit = 3.5 //Stops ships from going too damn fast. This can be overridden by things like fighters launching from tubes, so it's not a const.
	var/last_thrust_forward = 0
	var/last_thrust_right = 0
	var/last_rotate = 0
	var/should_open_doors = FALSE //Should we open airlocks? This is off by default because it was HORRIBLE.
	var/inertial_dampeners = TRUE

	var/user_thrust_dir = 0

	//Movement speed variables
	var/forward_maxthrust = 1
	var/backward_maxthrust = 1
	var/side_maxthrust = 0.5
	var/mass = MASS_SMALL //The "mass" variable will scale the movespeed according to how large the ship is.

	var/bump_impulse = 0.6
	var/bounce_factor = 0.7 // how much of our velocity to keep on collision
	var/lateral_bounce_factor = 0.95 // mostly there to slow you down when you drive (pilot?) down a 2x2 corridor

	var/brakes = FALSE //Helps you stop the ship
	var/rcs_mode = FALSE //stops you from swivelling on mouse move
	var/move_by_mouse = FALSE //Mouse guided turning

	// Mobs
	var/mob/living/pilot //Physical mob that's piloting us. Cameras come later
	var/mob/living/gunner //The person who fires the guns.
	var/list/gauss_gunners = list() //Anyone sitting in a gauss turret who should be able to commit pew pew against syndies.
	var/list/operators = list() //Everyone who needs their client updating when we move.
	var/list/mobs_in_ship = list() //A list of mobs which is inside the ship. This is generated by our areas.dm file as they enter / exit areas
	var/list/overmaps_in_ship = list() //A list of smaller overmaps inside the ship

	// Controlling equipment

	/*
	These are probably more okay not being lists since only one person can control either of these two slots at a time.
	*/
	var/obj/machinery/computer/ship/helm/helm //Relay beeping noises when we act
	var/obj/machinery/computer/ship/tactical/tactical

	/*
		|| THIS SHOULD BE A LIST, there could be a billion dradises that can keep fighting for which one is considered the ship dradis any time someone interacts with one!!!
		|| When you change this, also change the reference cleaning on del for this var from being on the dradis to being on the ship listening for the console's QDEL signal.
		\/ I'm not feeling like refactoring that right now though. Maybe in the future. -Delta
	*/
	var/obj/machinery/computer/ship/dradis/dradis //So that pilots can check the radar easily

	// Ship weapons
	var/weapon_safety = FALSE //Like a gun safety. Entirely un-used except for fighters to stop brainlets from shooting people on the ship unintentionally :)

	var/list/weapon_overlays = list()
	var/obj/weapon_overlay/last_fired //Last weapon overlay that fired, so we can rotate guns independently

	// Railgun aim helper
	var/last_tracer_process = 0
	var/aiming = FALSE
	var/aiming_lastangle = 0
	var/lastangle = 0
	var/mob/listeningTo
	var/obj/aiming_target
	var/aiming_params
	var/atom/autofire_target = null

	// Trader delivery locations
	var/list/trader_beacons = null

	var/uid = 0 //Unique identification code
	var/static/list/free_treadmills = list()
	var/static/list/free_boarding_levels = list()
	var/starting_system = null //Where do we start in the world?

	var/obj/machinery/ftl_drive/core/ftl_drive

	//Misc variables
	var/list/scanned = list() //list of scanned overmap anomalies
	var/reserved_z = 0 //The Z level we were spawned on, and thus inhabit. This can be changed if we "swap" positions with another ship.
	var/list/occupying_levels = list() //Refs to the z-levels we own for setting parallax and that, or for admins to debug things when EVERYTHING INEVITABLY BREAKS
	var/next_maneuvre = 0 //When can we pull off a fancy trick like boost or kinetic turn?
	var/flak_battery_amount = 0
	var/broadside = FALSE //Whether the ship is allowed to have broadside cannons or not
	var/plasma_caster = FALSE //Wehther the ship is allowed to have plasma gun or not
	var/role = NORMAL_OVERMAP

	var/list/missions = list()

	var/last_radar_pulse = 0

	//Our verbs tab
	var/list/overmap_verbs = list()

	var/ai_controlled = FALSE //Set this to true to let the computer fly your ship.

	/// This THEORETICALLY helps us fixing bonked physics processing during lags. Boneheaded implementation of /TG/ delta time.
	var/last_process = 0

	/**
	 * Collision-related stuff (basically physics)
	 */
	var/obj/vector_overlay/vector_overlay
	var/pixel_collision_size_x = 0
	var/pixel_collision_size_y = 0
	var/matrix/vector/offset
	var/matrix/vector/last_offset
	var/matrix/vector/position
	var/matrix/vector/velocity

	is_poi = TRUE

	var/obj/structure/overmap/last_overmap = null

	var/list/engines = list()

	// Ship weapons
	var/list/weapon_types[MAX_POSSIBLE_FIREMODE]
	var/list/weapon_numkeys_map = list() // I hate this

	var/fire_mode = FIRE_MODE_TORPEDO //What gun do we want to fire? Defaults to railgun, with PDCs there for flak
	var/switchsound_cooldown = 0

	var/torpedoes = 0 //If this starts at above 0, then the ship can use torpedoes when AI controlled
	var/missiles = 0 //If this starts at above 0, then the ship can use missiles when AI controlled
	var/torpedo_type = /obj/item/projectile/guided_munition/torpedo

	var/autotarget = FALSE // Whether we autolock onto painted targets or not.
	var/no_gun_cam = FALSE // Var for disabling the gunner's camera
	var/atom/target_lock = null // Our "locked" target. This is what manually fired guided weapons will track towards.

	var/atom/last_target //Last thing we shot at, used to point the railgun at an enemy.
	var/list/target_painted = list() // How many targets we've "painted" for AMS/relay targeting, associated with the ship supplying the datalink (if any)
	var/list/target_last_tracked = list() // When we last tracked a target

	//Fleet organisation
	var/shots_left = 15 //Number of arbitrary shots an AI can fire with its heavy weapons before it has to resupply with a supply ship.
	var/light_shots_left = 300
	var/uses_integrity = TRUE

/obj/structure/overmap/Initialize(mapload)
	. = ..()
	GLOB.overmap_objects += src
	var/icon/I = icon(icon,icon_state, SOUTH) //SOUTH because all overmaps only ever face right, no other dirs.
	pixel_collision_size_x = I.Width()
	pixel_collision_size_y = I.Height()
	offset = new /matrix/vector()
	last_offset = new /matrix/vector()
	position = new /matrix/vector(x*32,y*32)
	velocity = new /matrix/vector(0, 0)

	integrity = max_integrity

	add_think_ctx("slowthink", CALLBACK(src, nameof(.proc/slowthink)), 0)
	set_next_think(world.time + 10 SECONDS)

	return INITIALIZE_HINT_LATELOAD

/obj/structure/overmap/LateInitialize()
	. = ..()
	if(role > NORMAL_OVERMAP)
		SSstar_system.add_ship(src)

	vector_overlay = new()
	vector_overlay.appearance_flags |= KEEP_APART
	vector_overlay.appearance_flags |= RESET_TRANSFORM
	vector_overlay.icon = icon
	vis_contents += vector_overlay
	update_icon()
	find_area()
	if(mass > MASS_TINY && !use_armour_quadrants && role != MAIN_MINING_SHIP)
		use_armour_quadrants = TRUE
		var/armour_efficiency = (role > NORMAL_OVERMAP) ? integrity / 2 : integrity / 4
		armour_quadrants = list("forward_port" = list("name" = "Forward Port", "max_armour" = armour_efficiency, "current_armour" = armour_efficiency),\
							"forward_starboard" = list("name" = "Forward Starboard", "max_armour" = armour_efficiency, "current_armour" = armour_efficiency),\
							"aft_port" = list("name" = "Aft Port", "max_armour" = armour_efficiency, "current_armour" = armour_efficiency),\
							"aft_starboard" = list("name" = "Aft Starboard", "max_armour" = armour_efficiency, "current_armour" = armour_efficiency))
	switch(mass) //Scale speed with mass (tonnage)
		if(MASS_TINY)
			forward_maxthrust = 2
			backward_maxthrust = 2
			side_maxthrust = 2
			max_angular_acceleration = 100
			cabin_air = new
			cabin_air.temperature = 20 CELSIUS
			cabin_air.volume = 200
			cabin_air.adjust_multi(
				"oxygen", O2STANDARD * cabin_air.volume / (R_IDEAL_GAS_EQUATION * cabin_air.temperature),
				"nitrogen", N2STANDARD * cabin_air.volume / (R_IDEAL_GAS_EQUATION * cabin_air.temperature)
			)
			bounce_factor = 1
			lateral_bounce_factor = 1
			move_by_mouse = TRUE
			inertial_dampeners = FALSE

		if(MASS_SMALL)
			forward_maxthrust = 0.75
			backward_maxthrust = 0.75
			side_maxthrust = 0.75
			max_angular_acceleration = 12
			bounce_factor = 0.75
			lateral_bounce_factor = 0.75

		if(MASS_MEDIUM)
			forward_maxthrust = 0.75
			backward_maxthrust = 0.5
			side_maxthrust = 0.45
			max_angular_acceleration = 10
			bounce_factor = 0.55
			lateral_bounce_factor = 0.55

		if(MASS_MEDIUM_LARGE)
			forward_maxthrust = 0.65
			backward_maxthrust = 0.45
			side_maxthrust = 0.35
			max_angular_acceleration = 8
			bounce_factor = 0.40
			lateral_bounce_factor = 0.40

		if(MASS_LARGE)
			forward_maxthrust = 0.5
			backward_maxthrust = 0.35
			side_maxthrust = 0.25
			max_angular_acceleration = 6
			bounce_factor = 0.20
			lateral_bounce_factor = 0.20

		if(MASS_TITAN)
			forward_maxthrust = 0.35
			backward_maxthrust = 0.10
			side_maxthrust = 0.10
			max_angular_acceleration = 2.75
			bounce_factor = 0.10
			lateral_bounce_factor = 0.10

	switch(role)
		if(MAIN_OVERMAP)
			name = station_name()
			SSstar_system.main_overmap = src
	var/datum/star_system/sys = SSstar_system.find_system(src)
	if(sys)
		current_system = sys

	for(var/firemode = 1; firemode <= MAX_POSSIBLE_FIREMODE; firemode++)
		var/datum/ship_weapon/SW = weapon_types[firemode]
		if(istype(SW) && (SW.allowed_roles & OVERMAP_USER_ROLE_GUNNER))
			weapon_numkeys_map += firemode
	apply_weapons()

/// Method to apply weapon types to a ship. Override to your liking, this just handles generic rules and behaviours
/obj/structure/overmap/proc/apply_weapons()
	if(mass <= MASS_TINY)
		weapon_types[FIRE_MODE_ANTI_AIR] = new /datum/ship_weapon/light_cannon(src)
	else
		weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)
	if(mass >= MASS_SMALL || length(occupying_levels))
		weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src)
	if(mass > MASS_MEDIUM || length(occupying_levels))
		weapon_types[FIRE_MODE_MAC] = new /datum/ship_weapon/mac(src)

/obj/structure/overmap/Destroy()
	if((overmap_deletion_traits & NEVER_DELETE_OCCUPIED) && has_occupants())
		message_admins("[src] has occupants and will not be deleted")
		return QDEL_HINT_LETMELIVE

	if(current_system)
		current_system.system_contents.Remove(src)

	GLOB.overmap_objects -= src

	if(role == MAIN_OVERMAP)
		GLOB.cinematic.station_explosion_cinematic(0,null)
		SSticker.mode.check_finished(TRUE)

	SEND_SIGNAL(src, SIGNAL_OVERMAP_SHIP_KILLED)
	if(cabin_air)
		QDEL_NULL(cabin_air)

	if(deletion_teleports_occupants)
		var/turf/T = get_turf(src)
		for(var/mob/living/M in mobs_in_ship)
			if(M)
				M.forceMove(T)
				M.apply_damage(200)

	if(reserved_z)
		free_treadmills += reserved_z
		reserved_z = null

	return ..()

/obj/structure/overmap/proc/find_area()
	pass()

/obj/structure/overmap/proc/InterceptClickOn(atom/target, atom/location, control, params)
	var/mob/user = usr
	if(user.incapacitated() || !isliving(user) || weapon_safety)
		return FALSE

	if(istype(target, /obj/machinery/button))
		return target.attack_hand(user)

	var/list/params_list = params2list(params)
	if(target == src || istype(target, /atom/movable/screen) || (target in user.GetAllContents()) || params_list["alt"] || params_list["shift"])
		return FALSE

	var/dist = modulus(bounds_dist(src, target))
	if(istype(target, /obj/effect/overmap_anomaly/visitable) && dist <= 32)
		land(target)
		stop_piloting(user)
		return TRUE

	fire(target)
	return TRUE

/obj/structure/overmap/onMouseMove(object,location,control,params)
	if(!pilot || !pilot.client || pilot.incapacitated() || !move_by_mouse || control !="mapwindow.map" ||!can_move())
		return

	desired_angle = getMouseAngle(params, pilot)
	update_icon()

/obj/structure/overmap/proc/getMouseAngle(params, mob/M)
	var/list/params_list = params2list(params)
	var/list/sl_list = splittext(params_list["screen-loc"],",")
	if(!sl_list.len)
		return

	var/list/sl_x_list = splittext(sl_list[1], ":")
	var/list/sl_y_list = splittext(sl_list[2], ":")
	var/view_list = isnum(M.client.view) ? list("[M.client.view*2+1]","[M.client.view*2+1]") : splittext(M.client.view, "x")
	var/dx = text2num(sl_x_list[1]) + (text2num(sl_x_list[2]) / world.icon_size) - 1 - text2num(view_list[1]) / 2
	var/dy = text2num(sl_y_list[1]) + (text2num(sl_y_list[2]) / world.icon_size) - 1 - text2num(view_list[2]) / 2
	if(sqrt(dx*dx+dy*dy) > 1)
		return 90 - ATAN2(dx, dy)
	else
		return null

/obj/structure/overmap/proc/enable_dampeners(mob/user)
	inertial_dampeners = TRUE
	return TRUE

/obj/structure/overmap/proc/disable_dampeners(mob/user)
	inertial_dampeners = FALSE
	return TRUE

/obj/structure/overmap/proc/toggle_dampeners(mob/user)
	if(inertial_dampeners)
		return disable_dampeners(user)
	else
		return enable_dampeners(user)

/obj/structure/overmap/relaymove(mob/user, direction)
	if(user != pilot || pilot.incapacitated())
		return
	user_thrust_dir = direction
	// Since they can't strafe with IAS on, they can also turn with A and D
	if(inertial_dampeners)
		if(direction & WEST)
			movekey_delta_angle = -15
			user_thrust_dir = direction - WEST
		else if(direction & EAST)
			movekey_delta_angle = 15
			user_thrust_dir = direction - EAST

	//relay('sound/effects/ship/rcs.ogg')

/// This is overly expensive, most of these checks are already ran in physics. TODO: optimize
/obj/structure/overmap/on_update_icon()
	apply_damage_states()

/obj/structure/overmap/proc/apply_damage_states()
	if(!damage_states)
		return

	var/progress = integrity //How damaged is this shield? We examine the position of index "I" in the for loop to check which directional we want to check
	var/goal = max_integrity //How much is the max hp of the shield? This is constant through all of them
	progress = Clamp(progress, 0, goal)
	progress = round(((progress / goal) * 100), 25)//Round it down to 20%. We now apply visual damage
	icon_state = "[initial(icon_state)]-[progress]"

/obj/structure/overmap/proc/relay(S, message = null, loop = FALSE, channel = null) //Sends a sound + text message to the crew of a ship
	for(var/mob/M in GLOB.living_mob_list_)
		if(!M.is_deaf())
			if(channel) //Doing this forbids overlapping of sounds
				DIRECT_OUTPUT(M, sound(S, repeat = loop, wait = 0, volume = 100, channel = channel))
			else
				DIRECT_OUTPUT(M, sound(S, repeat = loop, wait = 0, volume = 100))
		if(message)
			to_chat(M, message)
	for(var/obj/structure/overmap/O as() in overmaps_in_ship) //Of course they get relayed the same message if they're in the same ship too
		if(length(O.mobs_in_ship))
			O.relay(args)

/obj/structure/overmap/proc/stop_relay(channel) //Stops all playing sounds for crewmen on N channel.
	for(var/obj/structure/overmap/O as() in overmaps_in_ship) //Of course they get relayed the same message if they're in the same ship too
		if(length(O.mobs_in_ship))
			O.stop_relay(args)

/obj/structure/overmap/proc/relay_to_nearby(S, message, ignore_self=FALSE, sound_range=20, faction_check=FALSE) //Sends a sound + text message to nearby ships
	for(var/obj/structure/overmap/ship as() in GLOB.overmap_objects) //Might be called in hyperspace or by fighters, so shouldn't use a system check.
		if(ignore_self)
			if(ship == src)
				continue

		if(ship?.current_system != current_system)	//If we aren't in the same system this shouldn't be happening.
			continue

		if(get_dist(src, ship) <= sound_range) //Sound doesnt really travel in space, but space combat with no kaboom is LAME

			ship.relay(S,message)

/obj/structure/overmap/proc/boost(direction)
	pass()

/// Intended to be used with a timer, sets all agility controlling variables, saves us making 6 varset timers
/obj/structure/overmap/proc/reset_boost(forward_maxthrust, backward_maxthrust, side_maxthrust, max_angular_acceleration, speed_limit)
	src.forward_maxthrust = forward_maxthrust
	src.backward_maxthrust = backward_maxthrust
	src.side_maxthrust = side_maxthrust
	src.max_angular_acceleration = max_angular_acceleration
	src.speed_limit = speed_limit

/// Check how aggressively the pilots are turning
/obj/structure/overmap/proc/check_throwaround(theAngle, direction)
	var/delta = abs(angular_velocity) //Where we started.
	if(delta < 20) //This is the canterbury, prepare for FLIP AND BURN.
		return

	if(!length(mobs_in_ship))
		return

	if(!length(linked_areas))
		for(var/mob/living/carbon/human/M in mobs_in_ship)
			M.damage_poise(10)
			switch(M.poise)
				if(0 to 30)
					continue

				if(50 to 70)
					to_chat(M, SPAN_WARNING("You feel lightheaded."))
				if(71 to 89)
					to_chat(M, SPAN_WARNING("Colour starts to drain from your vision. You feel like you're starting to black out...."))
				if(90 to 100)
					to_chat(M, SPAN_DANGER("You black out!"))
					M.Sleeping(5 SECONDS)
		return

	if(!direction)
		return

	for(var/mob/living/M in mobs_in_ship)
		if(M.buckled)
			continue

		if(M.mob_negates_gravity())
			continue

		var/atom/throw_target
		switch(direction)
			if(NORTH)
				throw_target = locate(M.x - 10, M.y, M.z)
			if(SOUTH)
				throw_target = locate(M.x + 10, M.y, M.z)
			if(EAST)
				throw_target = locate(M.x, M.y + 10, M.z)
			if(WEST)
				throw_target = locate(M.x, M.y - 10, M.z)
		if(!throw_target)
			continue

		if(ishuman(M))
			var/mob/living/carbon/human/L = M
			if(MUTATION_SEASICK in L.mutations)
				to_chat(L, SPAN_WARNING("Your head swims as the ship violently turns!"))
				if(prob(40))
					L.vomit()
				else
					L.emote("vomit")
		M.throw_at(throw_target, 4, 3)
		M.Stun(2 SECONDS)

/obj/structure/overmap/proc/can_change_safeties()
	return TRUE

/obj/structure/overmap/proc/can_brake()
	return TRUE

/obj/structure/overmap/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, bypasses_shields = FALSE)
	var/blocked = FALSE
	var/damage_sound = null
	//if(!bypasses_shields && shields && shields.absorb_hit(damage_amount))
	//	blocked = TRUE
		//damage_sound = pick('sound/effects/ship/damage/shield_hit.ogg', 'sound/effects/ship/damage/shield_hit2.ogg')
		//if(!impact_sound_cooldown)
			//add_overlay(new /obj/effect/temp_visual/overmap_shield_hit(get_turf(src), src))
	if(!impact_sound_cooldown && damage_sound)
		relay(damage_sound)
		if(damage_amount >= 15) //Flak begone
			shake_everyone(5)
		impact_sound_cooldown = TRUE
		//addtimer(VARSET_CALLBACK(src, impact_sound_cooldown, FALSE), 1 SECONDS)
	if(blocked)
		return FALSE

	if(!uses_integrity)
		update_icon()
		return

	var/old_integ = integrity
	integrity = max(old_integ - damage_amount, 0)
	if((overmap_deletion_traits & DAMAGE_STARTS_COUNTDOWN) && !(overmap_deletion_traits & DAMAGE_DELETES_UNOCCUPIED) && !has_occupants())
		if(integrity <= damage_amount || structure_crit)
			integrity = 10
			handle_crit(damage_amount)
			return FALSE

	update_icon()

/obj/structure/overmap/proc/has_occupants()
	if(length(mobs_in_ship))
		for(var/mob/M in mobs_in_ship) // Hopefully we don't have to do this super often but I didn't want one list of people who have to hear noises and announcements and another list of people who matter for this
			if(istype(M, /mob/living) && !istype(M, /mob/living/simple_animal))
				return TRUE
	if(length(overmaps_in_ship))
		if(overmap_deletion_traits & FIGHTERS_ARE_OCCUPANTS)
			return TRUE
		for(var/obj/structure/overmap/OM as() in overmaps_in_ship)
			if(length(OM.mobs_in_ship))
				return TRUE
	return FALSE

/obj/structure/overmap/proc/handle_crit(damage_amount)
	if(!structure_crit)
		structure_crit = TRUE
		structure_crit_init = world.time
		structure_crit_alert = 0 //RESET
	if(explosion_cooldown)
		return
	explosion_cooldown = TRUE
	//addtimer(VARSET_CALLBACK(src, explosion_cooldown, FALSE), 5 SECONDS)
	//var/area/target = null
	//if(role == MAIN_OVERMAP)
	//	var/name = pick(GLOB.teleportlocs) //Time to kill everyone
	//	target = GLOB.teleportlocs[name]
	//else if(length(linked_areas))
	//	target = pick(linked_areas)

	//if(target)
	//	var/turf/T = pick(get_area_turfs(target))
		//new /obj/effect/temp_visual/explosion_telegraph(T, damage_amount)

/obj/structure/overmap/proc/start_piloting(mob/living/carbon/user, position)
	if(!position || user.overmap_ship == src || LAZYFIND(operators, user))
		return FALSE

	if(position & OVERMAP_USER_ROLE_PILOT)
		if(pilot)
			to_chat(pilot, SPAN_WARNING("[user] has kicked you off the ship controls!"))
			stop_piloting(pilot)
		pilot = user
		LAZYOR(user.mousemove_intercept_objects, src)
	if(position & OVERMAP_USER_ROLE_GUNNER)
		if(gunner)
			to_chat(gunner, SPAN_WARNING("[user] has kicked you off the ship controls!"))
			stop_piloting(gunner)
		gunner = user
	register_signal(user, SIGNAL_MOB_MOUSEDOWN, nameof(.proc/InterceptClickOn))
	observe_ship(user)
	if(mass < MASS_MEDIUM)
		return TRUE

	return TRUE

// Handles actually "observing" the ship.
/obj/structure/overmap/proc/observe_ship(mob/living/carbon/user)
	if(user.overmap_ship == src || LAZYFIND(operators, user))
		return FALSE

	register_signal(user, SIGNAL_MOVED, nameof(.proc/stop_piloting))
	LAZYADD(operators,user)
	user.overmap_ship = src
	user.click_intercept = src
	var/mob/observer/eye/cameranet/ship/eyeobj = new(get_center())
	eyeobj.origin = src
	eyeobj.possess(user, FALSE)
	eyeobj.register_signal(src, SIGNAL_MOVED, nameof(/mob/observer/eye/cameranet/ship.proc/update))

/obj/structure/overmap/proc/stop_piloting(mob/living/M)
	LAZYREMOVE(operators,M)
	M.remove_verb(overmap_verbs)
	M.overmap_ship = null
	if(M.click_intercept == src)
		M.click_intercept = null
	if(pilot && M == pilot)
		LAZYREMOVE(M.mousemove_intercept_objects, src)
		pilot = null
		keyboard_delta_angle_left = 0
		keyboard_delta_angle_right = 0

	var/mob/observer/eye/cameranet/ship/eyeobj = M?.eyeobj
	M.eyeobj = null
	qdel(eyeobj)
	unregister_signal(M, SIGNAL_MOVED)

	M.reset_view(M)
	M.cancel_camera()

/obj/structure/overmap/touch_map_edge()
	return FALSE // Just NO.

/mob/observer/eye/cameranet/ship
	var/obj/structure/overmap/origin
	var/obj/structure/overmap/ship_target = null
	animate_movement = 0
	uses_static = FALSE

/mob/observer/eye/cameranet/ship/EyeMove(direct)
	origin?.relaymove(owner, direct)
	return TRUE

/mob/observer/eye/cameranet/ship/proc/update()
	//SIGNAL_HANDLER Fuck this shit.
	if(!owner.client)
		return

	var/obj/structure/overmap/ship = origin
	owner.client.pixel_x = ship.pixel_x
	owner.client.pixel_y = ship.pixel_y
	setLoc(ship.get_center())
	return TRUE

/obj/structure/overmap/proc/update_gunner_cam(atom/target)
	if(!gunner)
		return

/**
 *
 * Weapons and stuff.
 *
 */

/obj/structure/overmap/proc/add_weapon_overlay(type)
	var/path = text2path(type)
	var/obj/weapon_overlay/OL = new path
	OL.icon = icon
	OL.appearance_flags |= KEEP_APART
	OL.appearance_flags |= RESET_TRANSFORM
	vis_contents += OL
	weapon_overlays += OL
	return OL

/obj/structure/overmap/proc/fire(atom/target)
	if(weapon_safety)
		if(gunner)
			to_chat(gunner, "<span class='warning'>Weapon safety interlocks are active! Use the ship verbs tab to disable them!</span>")
		return

	last_target = target

	fire_weapon(target)

/obj/structure/overmap/proc/fire_weapon(atom/target, mode = fire_mode, lateral = (mass > MASS_TINY), mob/user_override = gunner, ai_aim = FALSE) //"Lateral" means that your ship doesnt have to face the target
	var/datum/ship_weapon/SW = weapon_types[mode]
	if(weapon_safety)
		return FALSE

	if(SW?.fire(target, ai_aim = ai_aim))
		return TRUE
	else
		if(user_override && SW) //Tell them we failed
			if(world.time < SW.next_firetime) //Silence, SPAM.
				return FALSE

			to_chat(user_override, SW.failure_alert)

/obj/structure/overmap/proc/get_max_firemode()
	if(mass < MASS_MEDIUM) //Small craft dont get a railgun
		return FIRE_MODE_TORPEDO
	return FIRE_MODE_MAC

/obj/structure/overmap/proc/select_weapon(number)
	if(number > 0 && number <= length(weapon_numkeys_map))
		swap_to(weapon_numkeys_map[number])
		return TRUE

/obj/structure/overmap/proc/swap_to(what = FIRE_MODE_ANTI_AIR)
	if(!weapon_types[what])
		return FALSE

	var/datum/ship_weapon/SW = weapon_types[what]
	if(!(SW.allowed_roles & OVERMAP_USER_ROLE_GUNNER))
		return FALSE

	fire_mode = what
	if(world.time > switchsound_cooldown)
		relay(SW.overmap_select_sound)
		switchsound_cooldown = world.time + 5 SECONDS
	if(gunner)
		to_chat(gunner, SW.select_alert)
	return TRUE

/obj/structure/overmap/proc/fire_torpedo(atom/target, ai_aim = FALSE, burst = 1)
	if(ai_controlled || !linked_areas.len && role != MAIN_OVERMAP) //AI ships and fighters don't have interiors
		if(torpedoes <= 0)
			return FALSE
		if(isovermap(target))
			ai_aim = FALSE // This is a homing projectile
		var/launches = min(torpedoes, burst)

		fire_projectile(torpedo_type, target, speed=3, lateral = TRUE, ai_aim = ai_aim)
		var/datum/ship_weapon/SW = weapon_types[FIRE_MODE_TORPEDO]
		relay_to_nearby(pick(SW.overmap_firing_sounds))

		if(launches > 1)
			fire_torpedo_burst(target, ai_aim, launches - 1)
		torpedoes -= launches
		return TRUE

/obj/structure/overmap/proc/fire_torpedo_burst(atom/target, ai_aim = FALSE, burst = 1)
	set waitfor = FALSE
	for(var/cycle = 1; cycle <= burst; cycle++)
		sleep(3)
		if(QDELETED(src))	//We might get shot.
			return
		if(QDELETED(target))
			target = null
		fire_projectile(torpedo_type, target, speed=3, lateral = TRUE, ai_aim = ai_aim)
		var/datum/ship_weapon/SW = weapon_types[FIRE_MODE_TORPEDO]
		relay_to_nearby(pick(SW.overmap_firing_sounds))

/obj/structure/overmap/proc/fire_missile(atom/target, ai_aim = FALSE)
	if(ai_controlled || !linked_areas.len && role != MAIN_OVERMAP) //AI ships and fighters don't have interiors
		if(missiles <= 0)
			return FALSE

		missiles --
		var/obj/structure/overmap/OM = target
		if(istype(OM))
			ai_aim = FALSE // This is a homing projectile
		fire_projectile(/obj/item/projectile/guided_munition/missile, target, lateral = FALSE, ai_aim = ai_aim)
		var/datum/ship_weapon/SW = weapon_types[FIRE_MODE_MISSILE]
		relay_to_nearby(pick(SW.overmap_firing_sounds))
		return TRUE

/obj/structure/overmap/proc/get_flak_range(atom/target)
	if(!target)
		target = src
	var/dist = (get_dist(src, target) / 1.5)
	var/minimum_safe_distance = pixel_collision_size_y / 32
	return (dist >= minimum_safe_distance) ? dist : minimum_safe_distance //Stops you flak-ing yourself

/obj/structure/overmap/proc/select_target(obj/structure/overmap/target)
	if(QDELETED(target) || !istype(target) || !locate(target) in target_painted)
		target_lock = null
		update_gunner_cam()
		dump_lock(target)
		return

	if(target_lock == target)
		target_lock = null
		update_gunner_cam()
		return

	target_lock = target

/obj/structure/overmap/proc/dump_lock(obj/structure/overmap/target) // Our locked target got destroyed/moved, dump the lock
	SIGNAL_HANDLER
	SEND_SIGNAL(src, SIGNAL_OM_LOCK_LOST, target)
	target_painted -= target
	target_last_tracked -= target
	unregister_signal(target, SIGNAL_QDELETING)
	if(target_lock == target)
		update_gunner_cam()
		target_lock = null

/obj/structure/overmap/proc/dump_locks() // clears all target locks.
	SIGNAL_HANDLER
	update_gunner_cam()
	for(var/obj/structure/overmap/OM in target_painted)
		dump_lock(OM)

/**
 *
 * Damage behavior
 *
 */
/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	P.spec_overmap_hit(src)
	var/relayed_type = P.type
	relay_damage(relayed_type)
	if(!use_armour_quadrants)
		return ..()
	else
		playsound(src, P.hitsound, 50, 1)
		if(!QDELETED(src)) //Bullet on_hit effect might have already destroyed this object
			take_quadrant_hit(P.damage, projectile_quadrant_impact(P))

/// Special proc special behavior on bullet_act()
/obj/item/projectile/proc/spec_overmap_hit(obj/structure/overmap/target)
	return

/obj/structure/overmap/proc/relay_damage(proj_type)
	if(!length(occupying_levels))
		return

	var/theZ = pick(occupying_levels)
	var/startside = pick(GLOB.cardinal)
	var/turf/pickedstart = spaceDebrisStartLoc(startside, theZ)
	var/turf/pickedgoal = locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), theZ)
	var/obj/item/projectile/proj = new proj_type(pickedstart)
	proj.starting = pickedstart
	proj.firer = null
	proj.def_zone = "chest"
	proj.original = pickedgoal
	spawn(0)
		proj.fire(Get_Angle(pickedstart, pickedgoal))

/**
 * Landing behavior
 */

/obj/structure/overmap/proc/land(obj/effect/overmap_anomaly/visitable/planetoid/overmap)
	set background = TRUE

	if(ftl_drive?.jumping)
		return

	// Preventing people from watching at an empty space
	if(pilot)
		stop_piloting(pilot)
	if(gunner)
		stop_piloting(gunner)

	var/datum/star_system/SS = SSstar_system.ships[src]["current_system"]
	SS.remove_ship(src, overmap, remove_fully = FALSE)
	SSstar_system.ships[src]["landed"] = TRUE

	GLOB.using_map.apply_mask()
	var/list/spawned = block(
		locate(1, 1, 1),
		locate(world.maxx, world.maxy, 1)
	)

	SSannounce.play_announce(/datum/announce/comm_program, "", "Helm announcement", "Command Room", 'sound/misc/notice2.ogg', FALSE, TRUE, GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION))
	var/datum/looping_sound/sound = new /datum/looping_sound/ship/engine(list(), FALSE, TRUE, channel = SOUND_CHANNEL_REACTOR_ALERT)

	var/list/predicates = area_repository.get_areas_by_z_level(GLOB.is_station_but_not_space_or_shuttle_area)
	var/list/areas_to_play = list()
	for(var/name in predicates)
		areas_to_play |= predicates[name]

	sound.output_atoms |= areas_to_play
	sound.start()

	var/list/areas_to_mask = list()

	for(var/type in GLOB.areas_by_type)
		var/area/A = GLOB.areas_by_type[type]
		if(!is_space_or_mapgen_area(A))
			continue

		areas_to_mask |= A
		var/icon/clouds = new('icons/effects/weather_effects.dmi', "clouds_fast")
		clouds.Blend(COLOR_BLUE_LIGHT, ICON_MULTIPLY)
		A.icon = clouds

	for(var/zlevel = 1 to GLOB.using_map.map_levels.len)
		if(!(zlevel in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
			continue

		var/datum/space_level/L = GLOB.using_map.map_levels[zlevel]
		L.assume_atmosphere(overmap.atmosphere)

/**
 * '/proc/generate()' is extremely cursed
 * And fucks CPU usage up, whether it is called async or not, in background or not.
 * Therefore we are doing a little trick here. Processing this shit with the lowest possible priority.
 */
	var/datum/map_generator/planet_generator/mapgen = new overmap.mapgen()
	mapgen.load_random_ruins(1)
	SSmapgen.generate(mapgen, spawned)

	while(SSmapgen.current_mapgen)
		sleep(1)

	relay('sound/effects/ship/radio_100m.wav', null, FALSE, SOUND_CHANNEL_SHIP_ALERT)
	if(!isnull(mapgen?.weather_controller_type))
		mapgen.weather_controller_type = new mapgen.weather_controller_type(z)
	for(var/area/A in areas_to_mask)
		A.icon = initial(A.icon)

	relay('sound/effects/ship/radio_landing_touch_01.wav', null, FALSE, SOUND_CHANNEL_SHIP_ALERT)
	sound.stop()

/obj/structure/overmap/proc/takeoff()
	SSstar_system.ships[src]["landed"] = FALSE
	SSannounce.play_announce(/datum/announce/comm_program, "", "Helm announcement", "Command Room", 'sound/misc/notice2.ogg', FALSE, TRUE, GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION))
	var/datum/looping_sound/sound = new /datum/looping_sound/ship/engine(list(), FALSE, TRUE, channel = SOUND_CHANNEL_REACTOR_ALERT)
	var/list/predicates = area_repository.get_areas_by_z_level(GLOB.is_station_but_not_space_or_shuttle_area)
	var/list/areas_to_play = list()
	for(var/name in predicates)
		areas_to_play += predicates[name]

	sound.output_atoms |= areas_to_play
	sound.start()

	sleep (5 SECONDS)

	var/list/areas_to_mask = list()

	for(var/type in GLOB.areas_by_type)
		var/area/A = GLOB.areas_by_type[type]
		if(!is_space_or_mapgen_area(A))
			continue

		areas_to_mask |= A
		var/icon/clouds = new('icons/effects/weather_effects.dmi', "clouds_fast")
		clouds.Blend(COLOR_BLUE_LIGHT, ICON_MULTIPLY)
		A.icon = clouds

	for(var/zlevel = 1 to GLOB.using_map.map_levels.len)
		if(!(zlevel in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
			continue

		var/datum/space_level/L = GLOB.using_map.map_levels[zlevel]
		L.make_space_atmosphere()

	sleep(4 SECONDS)

	GLOB.using_map.apply_mask()

	sleep(2 SECONDS)

	for(var/area/A in areas_to_mask)
		A.icon = initial(A.icon)

	sound.stop()
	var/datum/star_system/SS = SSstar_system.ships[src]["current_system"]
	SSstar_system.ships[src]["landed"] = FALSE
	SS.add_ship(src)
