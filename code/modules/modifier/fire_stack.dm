/// Maxamounts of fire stacks a mob can get
#define MAX_FIRE_STACKS 20
/// If a mob has a higher threshold than this, the icon shown will be increased to the big fire icon.
#define MOB_BIG_FIRE_STACK_THRESHOLD 3

/datum/modifier/fire_handler
	stacks = MODIFIER_STACK_REFRESH
	/// Current amount of current_stacks we have
	var/current_stacks
	/// Maximum of current_stacks that we could possibly get
	var/stack_limit = 20
	/// What status effect types do we remove uppon being applied. These are just deleted without any deduction from our or their current_stacks when forced.
	var/list/enemy_types
	/// What status effect types do we merge into if they exist. Ignored when forced.
	var/list/merge_types
	/// What status effect types do we override if they exist. These are simply deleted when forced.
	var/list/override_types
	/// For how much firestacks does one our stack count
	var/stack_modifier = 1

/datum/modifier/fire_handler/refresh(modifier_type, expire_at, mob/living/origin, new_stacks)
	adjust_stacks(new_stacks)

// Override this for special effects when it gets added to the mob.
/datum/modifier/fire_handler/on_applied(modifier_type, expire_at, mob/living/origin, new_stacks)
	if(!isliving(holder))
		qdel_self()
		return

	set_stacks(new_stacks)

	for(var/enemy_type in enemy_types)
		var/datum/modifier/fire_handler/enemy_effect = holder.has_modifier_of_type(enemy_type)
		if(enemy_effect)
			//if(forced)
			//	qdel(enemy_effect)
			//	continue

			var/cur_stacks = current_stacks
			adjust_stacks(-abs(enemy_effect.current_stacks * enemy_effect.stack_modifier / stack_modifier))
			enemy_effect.adjust_stacks(-abs(cur_stacks * stack_modifier / enemy_effect.stack_modifier))
			if(enemy_effect.current_stacks <= 0)
				qdel(enemy_effect)

			if(current_stacks <= 0)
				qdel_self()
				return

	//if(!forced)
	var/list/merge_effects = list()
	for(var/merge_type in merge_types)
		var/datum/modifier/fire_handler/merge_effect = holder.has_modifier_of_type(merge_type)
		if(merge_effect)
			merge_effects += merge_effects

	if(LAZYLEN(merge_effects))
		for(var/datum/modifier/fire_handler/merge_effect in merge_effects)
			merge_effect.adjust_stacks(current_stacks * stack_modifier / merge_effect.stack_modifier / LAZYLEN(merge_effects))
		qdel_self()
		return

	for(var/override_type in override_types)
		var/datum/modifier/fire_handler/override_effect = holder.has_modifier_of_type(override_type)
		if(override_effect)
			//if(forced)
			//	qdel(override_effect)
			//	continue

			adjust_stacks(override_effect.current_stacks)
			qdel(override_effect)

/**
 * Setter and adjuster procs for firestacks
 *
 * Arguments:
 * - new_stacks
 *
 */

/datum/modifier/fire_handler/proc/set_stacks(new_stacks)
	current_stacks = max(0, min(stack_limit, new_stacks))
	cache_stacks()

/datum/modifier/fire_handler/proc/adjust_stacks(new_stacks)
	current_stacks = max(0, min(stack_limit, current_stacks + new_stacks))
	cache_stacks()

/**
 * Refresher for mob's fire_stacks
 */

/datum/modifier/fire_handler/proc/cache_stacks()
	holder.fire_stacks = 0
	var/was_on_fire = holder.on_fire
	holder.on_fire = FALSE
	for(var/datum/modifier/fire_handler/possible_fire in holder.modifiers)
		holder.fire_stacks += possible_fire.current_stacks * possible_fire.stack_modifier

		if(!istype(possible_fire, /datum/modifier/fire_handler/fire_stacks))
			continue

		var/datum/modifier/fire_handler/fire_stacks/our_fire = possible_fire
		if(our_fire.on_fire)
			holder.on_fire = TRUE

	if(was_on_fire && !holder.on_fire)
		holder.ExtinguishMob()
	update_particles()

/datum/modifier/fire_handler/fire_stacks
	enemy_types = list(/datum/modifier/fire_handler/wet_stacks)
	stack_modifier = 1

	/// If we're on fire
	var/on_fire = FALSE
	/// Reference to the mob light emitter itself
	var/obj/effect/dummy/lighting_obj/moblight
	/// Type of mob light emitter we use when on fire
	//var/moblight_type = /obj/effect/dummy/lighting_obj/moblight/fire

/datum/modifier/fire_handler/fire_stacks/tick()
	if(stacks <= 0)
		qdel_self()
		return TRUE

	if(!on_fire)
		return TRUE

	adjust_stacks(-0.05 * SSmobs.wait)

	if(stacks <= 0)
		qdel_self()
		return TRUE

	var/turf/location = get_turf(holder)
	if(!istype(location))
		return

	holder.handle_fire()

	location.hotspot_expose(max(2.25 * round(FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE * (current_stacks / FIRE_MAX_FIRESUIT_STACKS) ** 2), 700), 50, 1)
	var/datum/gas_mixture/air = location.return_air()
	if(!air.get_by_flag(XGM_GAS_OXIDIZER) < 1)
		qdel_self()
		return TRUE

/datum/modifier/fire_handler/fire_stacks/update_particles()
	if(on_fire)
		//if(!particle_effect)
		//	particle_effect = new(holder, /particles/embers)
		if(stacks > MOB_BIG_FIRE_STACK_THRESHOLD)
			particle_effect.particles.spawning = 5
		else
			particle_effect.particles.spawning = 1
	else if(particle_effect)
		QDEL_NULL(particle_effect)

/**
 * Handles mob ignition, should be the only way to set on_fire to TRUE
 *
 * Arguments:
 * - silent: When set to TRUE, no message is displayed
 *
 */

/datum/modifier/fire_handler/fire_stacks/proc/ignite(silent = FALSE)
	on_fire = TRUE
	if(!silent)
		holder.visible_message(SPAN_WARNING("[holder] catches fire!"), SPAN_DANGER("You're set on fire!"))

	//if(moblight_type)
	//	if(moblight)
	//		qdel(moblight)
//
	//	moblight = new moblight_type(holder)

	cache_stacks()
	//SEND_SIGNAL(holder, COMSIG_LIVING_IGNITED, holder)
	return TRUE

/**
 * Handles mob extinguishing, should be the only way to set on_fire to FALSE
 */

/datum/modifier/fire_handler/fire_stacks/proc/extinguish()
	//QDEL_NULL(moblight)
	on_fire = FALSE
	//SEND_SIGNAL(holder, COMSIG_LIVING_EXTINGUISHED, holder)
	cache_stacks()
	//for(var/obj/item/equipped in (holder.get_equipped_items(TRUE)))
		//equipped.extinguish()

/datum/modifier/fire_handler/fire_stacks/on_expire()
	if(on_fire)
		extinguish()
	set_stacks(0)

//datum/modifier/fire_handler/fire_stacks/on_apply()
	//. = ..()
	//register_signal(holder, COMSIG_ATOM_EXTINGUISH, PROC_REF(extinguish))

/datum/modifier/fire_handler/wet_stacks
	enemy_types = list(/datum/modifier/fire_handler/fire_stacks)
	stack_modifier = -1

/datum/modifier/fire_handler/wet_stacks/tick(seconds_between_ticks)
	adjust_stacks(-0.5 * seconds_between_ticks)
	if(stacks <= 0)
		qdel_self()

/datum/modifier/fire_handler/wet_stacks/update_particles()
	if(particle_effect)
		return

	particle_effect = new(holder, /particles/droplets)
