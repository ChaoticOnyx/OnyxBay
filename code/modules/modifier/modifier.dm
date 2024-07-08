
// This is a datum that tells the mob that something is affecting them.
// The advantage of using this datum verses just setting a variable on the mob directly, is that there is no risk of two different procs overwriting
// each other, or other weirdness.  An excellent example is adjusting max health.

/datum/modifier
	var/name = null                     // Mostly used to organize, might show up on the UI in the Future(tm)
	var/desc = null                     // Ditto.
	var/icon_state = null               // See above.
	var/mob/living/holder = null        // The mob that this datum is affecting.
	var/weakref/origin = null           // A weak reference to whatever caused the modifier to appear.  THIS NEEDS TO BE A MOB/LIVING.  It's a weakref to not interfere with qdel().
	var/expire_at = null                // world.time when holder's Life() will remove the datum.  If null, it lasts forever or until it gets deleted by something else.
	var/on_created_text = null          // Text to show to holder upon being created.
	var/on_expired_text = null          // Text to show to holder when it expires.
	var/hidden = FALSE                  // If true, it will not show up on the HUD in the Future(tm)
	var/stacks = MODIFIER_STACK_FORBID  // If true, attempts to add a second instance of this type will refresh expire_at instead.
	var/flags = 0                       // Flags for the modifier, see mobs.dm defines for more details.

	var/light_color = null              // If set, the mob possessing the modifier will glow in this color.  Not implemented yet.
	var/light_range = null              // How far the light for the above var goes. Not implemented yet.
	var/light_intensity = null          // Ditto. Not implemented yet.
	var/mob_overlay_state = null        // Icon_state for an overlay to apply to a (human) mob while this exists.  This is actually implemented.
	var/client_color = null             // If set, the client will have the world be shown in this color, from their perspective.

	// Now for all the different effects.
	// Percentage modifiers are expressed as a multipler. (e.g. +25% damage should be written as 1.25)
	var/max_health_flat                 // Adjusts max health by a flat (e.g. +20) amount.  Note this is added to base health.
	var/max_health_percent              // Adjusts max health by a percentage (e.g. -30%).
	var/disable_duration_percent        // Adjusts duration of 'disables' (stun, weaken, paralyze, confusion, sleep, halloss, etc)  Setting to 0 will grant immunity.
	var/siemens_coefficient=1
	var/incoming_damage_percent         // Adjusts all incoming damage.
	var/incoming_brute_damage_percent   // Only affects bruteloss.
	var/incoming_fire_damage_percent    // Only affects fireloss.
	var/incoming_tox_damage_percent     // Only affects toxloss.
	var/incoming_oxy_damage_percent     // Only affects oxyloss.
	var/incoming_clone_damage_percent   // Only affects cloneloss.
	var/incoming_hal_damage_percent     // Only affects halloss.
	var/incoming_healing_percent        // Adjusts amount of healing received.
	var/outgoing_melee_damage_percent   // Adjusts melee damage inflicted by holder by a percentage.  Affects attacks by melee weapons and hand-to-hand.
	/// Path to the movespeed modifier added to mob
	var/movespeed_modifier_path
	var/evasion                         // Positive numbers reduce the odds of being hit. Negative numbers increase the odds.
	var/bleeding_rate_percent           // Adjusts amount of blood lost when bleeding.
	var/accuracy                        // Positive numbers makes hitting things with guns easier, negatives make it harder.
	var/accuracy_dispersion             // Positive numbers make gun firing cover a wider tile range, and therefore more inaccurate.  Negatives help negate dispersion penalties.
	var/metabolism_percent              // Adjusts the mob's metabolic rate, which affects reagent processing.  Won't affect mobs without reagent processing.
	var/attack_speed_percent            // Makes the holder's 'attack speed' (click delay) shorter or longer.
	var/pain_immunity                   // Makes the holder not care about pain while this is on. Only really useful to human mobs.
	var/stammering
	var/burrieng
	var/lisping
	var/use_tool_delay
	var/medical_treatment_time
	var/crp_fracture_chance
	var/surgery_step_time
	var/disarm_drop_percent
	var/pull_slowdown_percent
	var/electrocute_damage_percent
	var/electrocute_block_chance
	var/poise_pool_flat
	/// A particle effect, for effects like embers on fire and water droplets.
	var/atom/movable/particle_emitter/particle_effect

/datum/modifier/New(new_holder, new_origin)
	holder = new_holder
	if(new_origin)
		origin = weakref(new_origin)
	else // We assume the holder caused the modifier if not told otherwise.
		origin = weakref(holder)

	update_particles()
	..()

/datum/modifier/Destroy(force)
	if(particle_effect)
		QDEL_NULL(particle_effect)
	return ..()

// Checks if the modifier should be allowed to be applied to the mob before attaching it.
// Override for special criteria, e.g. forbidding robots from receiving it.
/datum/modifier/proc/can_apply(mob/living/L)
	return TRUE

// Checks to see if this datum should continue existing.
/datum/modifier/proc/check_if_valid()
	if(expire_at && expire_at < world.time) // Is our time up?
		src.expire()

/datum/modifier/proc/expire(silent = FALSE)
	if(on_expired_text && !silent)
		to_chat(holder, on_expired_text)

	if(pain_immunity && ishuman(holder))
		var/mob/living/carbon/human/human_user = holder
		human_user.no_pain = TRUE

	on_expire()
	holder.modifiers.Remove(src)
	if(mob_overlay_state) // We do this after removing ourselves from the list so that the overlay won't remain.
		holder.update_modifier_visuals()
	if(client_color)
		holder.update_client_color()
	qdel(src)

// Override this for special effects when it gets added to the mob.
/datum/modifier/proc/on_applied(list/arguments)
	return

// Override this for special effects when it gets removed.
/datum/modifier/proc/on_expire()
	return

// Called every Life() tick.  Override for special behaviour.
/datum/modifier/proc/tick()
	return

/datum/modifier/proc/examine()
	return

/// Override for specific particle behavior.
/datum/modifier/proc/update_particles()
	SHOULD_CALL_PARENT(FALSE)
	return

/// Override for specific behavior when a new modifier is applied with stacks = MODIFIER_STACK_REFRESH
/datum/modifier/proc/refresh(arguments)
	SHOULD_CALL_PARENT(FALSE)
	return

/mob/living
	var/list/modifiers = list() // A list of modifier datums, which can adjust certain mob numbers.

/mob/living/Destroy()
	remove_all_modifiers(TRUE)
	return ..()

// Called by Life().
/mob/living/proc/handle_modifiers()
	if(!modifiers.len) // No work to do.
		return
	// Get rid of anything we shouldn't have.
	for(var/datum/modifier/M in modifiers)
		M.check_if_valid()
	// Remaining modifiers will now receive a tick().  This is in a second loop for safety in order to not tick() an expired modifier.
	for(var/datum/modifier/M in modifiers)
		M.tick()

// Call this to add a modifier to a mob. First argument is the modifier type you want, second is how long it should last, in ticks.
// Third argument is the 'source' of the modifier, if it's from someone else.  If null, it will default to the mob being applied to.
// The SECONDS/MINUTES macro is very helpful for this.  E.g. M.add_modifier(/datum/modifier/example, 5 MINUTES)
/mob/living/proc/add_modifier(modifier_type, expire_at = null, mob/living/origin = null, ...)
	var/list/arguments = args.Copy()
	// First, check if the mob already has this modifier.
	for(var/datum/modifier/M in modifiers)
		if(ispath(modifier_type, M))
			switch(M.stacks)
				if(MODIFIER_STACK_FORBID)
					return // Stop here.
				if(MODIFIER_STACK_ALLOWED)
					break // No point checking anymore.
				if(MODIFIER_STACK_EXTEND)
					// Not allow to add a second instance, but we can try to prolong the first instance.
					if(expire_at && world.time + expire_at > M.expire_at)
						M.expire_at = world.time + expire_at
					return
				if(MODIFIER_STACK_REFRESH)
					M.refresh(arglist(arguments))
					return

	// If we're at this point, the mob doesn't already have it, or it does but stacking is allowed.
	var/datum/modifier/mod = new modifier_type(src, origin)
	if(!mod.can_apply(src))
		qdel(mod)
		return
	if(expire_at)
		mod.expire_at = world.time + expire_at
	if(mod.on_created_text)
		to_chat(src, mod.on_created_text)
	modifiers.Add(mod)
	if(mod.pain_immunity && ishuman(src))
		var/mob/living/carbon/human/human_user = src
		human_user.no_pain = TRUE

	mod.on_applied(arglist(arguments))
	if(mod.mob_overlay_state)
		update_modifier_visuals()
	if(mod.client_color)
		update_client_color()

	return mod

// Removes a specific instance of modifier
/mob/living/proc/remove_specific_modifier(datum/modifier/M, silent = FALSE)
	M.expire(silent)

// Removes one modifier of a type
/mob/living/proc/remove_a_modifier_of_type(modifier_type, silent = FALSE)
	for(var/datum/modifier/M in modifiers)
		if(ispath(M.type, modifier_type))
			M.expire(silent)
			break

// Removes all modifiers of a type
/mob/living/proc/remove_modifiers_of_type(modifier_type, silent = FALSE)
	for(var/datum/modifier/M in modifiers)
		if(ispath(M.type, modifier_type))
			M.expire(silent)

// Removes all modifiers, useful if the mob's being deleted
/mob/living/proc/remove_all_modifiers(silent = FALSE)
	for(var/datum/modifier/M in modifiers)
		M.expire(silent)

// Checks if the mob has a modifier type.
/mob/living/proc/has_modifier_of_type(modifier_type)
	for(var/datum/modifier/M in modifiers)
		if(istype(M, modifier_type))
			return TRUE
	return FALSE

// This displays the actual 'numbers' that a modifier is doing.  Should only be shown in OOC contexts.
// When adding new effects, be sure to update this as well.
/datum/modifier/proc/describe_modifier_effects()
	// SEMantic COLoring 🤓
	#define SEMCOL(good_cond, txt) do { var/is_good = good_cond; effects += {"<font color="[is_good ? "green" : "red"]">[txt]</font>"}; } while (FALSE)

	var/list/effects = list()

	if(!isnull(max_health_flat))
		SEMCOL(max_health_flat > 0, "You [is_good ? "gain" : "lose"] [abs(max_health_flat)] maximum health.")
	if(!isnull(max_health_percent))
		SEMCOL(max_health_percent > 1.0, "You [is_good ? "gain" : "lose"] [multipler_to_percentage(max_health_percent, TRUE)] maximum health.")
	if(!isnull(disable_duration_percent))
		SEMCOL(disable_duration_percent <= 1.0, "Disabling effects on you last [multipler_to_percentage(disable_duration_percent, TRUE)] [is_good ? "shorter" : "longer"]")
	if(!isnull(incoming_damage_percent))
		SEMCOL(incoming_damage_percent <= 1.0, "You take [multipler_to_percentage(incoming_damage_percent, TRUE)] [is_good ? "less" : "more"] damage.")
	if(!isnull(incoming_brute_damage_percent))
		SEMCOL(incoming_brute_damage_percent <= 1.0, "You take [multipler_to_percentage(incoming_brute_damage_percent, TRUE)] [is_good ? "less" : "more"] brute damage.")
	if(!isnull(incoming_fire_damage_percent))
		SEMCOL(incoming_fire_damage_percent <= 1.0, "You take [multipler_to_percentage(incoming_fire_damage_percent, TRUE)] [is_good ? "less" : "more"] fire damage.")
	if(!isnull(incoming_tox_damage_percent))
		SEMCOL(incoming_tox_damage_percent <= 1.0, "You take [multipler_to_percentage(incoming_tox_damage_percent, TRUE)] [is_good ? "less" : "more"] toxin damage.")
	if(!isnull(incoming_oxy_damage_percent))
		SEMCOL(incoming_oxy_damage_percent <= 1.0, "You take [multipler_to_percentage(incoming_oxy_damage_percent, TRUE)] [is_good ? "less" : "more"] oxy damage.")
	if(!isnull(incoming_clone_damage_percent))
		SEMCOL(incoming_clone_damage_percent <= 1.0, "You take [multipler_to_percentage(incoming_clone_damage_percent, TRUE)] [is_good ? "less" : "more"] clone damage.")
	if(!isnull(incoming_hal_damage_percent))
		SEMCOL(incoming_hal_damage_percent <= 1.0, "You take [multipler_to_percentage(incoming_hal_damage_percent, TRUE)] [is_good ? "less" : "more"] agony damage.")
	if(!isnull(incoming_healing_percent))
		SEMCOL(incoming_healing_percent > 1.0, "Healing applied to you is [multipler_to_percentage(incoming_healing_percent, TRUE)] [is_good ? "stronger" : "weaker"].")
	if(!isnull(outgoing_melee_damage_percent))
		SEMCOL(outgoing_melee_damage_percent > 1.0, "Damage you do with melee weapons and unarmed combat is [multipler_to_percentage(outgoing_melee_damage_percent, TRUE)] [is_good ? "higher" : "lower"].")
	if(!isnull(evasion))
		SEMCOL(evasion > 0, "You are [abs(evasion)]% [is_good ? "harder" : "easier"] to hit with weapons.")
	if(!isnull(bleeding_rate_percent))
		SEMCOL(bleeding_rate_percent <= 1.0, "You bleed [multipler_to_percentage(bleeding_rate_percent, TRUE)] [is_good ? "slower" : "faster"].")
	if(!isnull(accuracy))
		SEMCOL(accuracy > 0, "It is [abs(accuracy)]% [is_good ? "easier" : "harder"] for you to hit someone with a ranged weapon.")
	if(!isnull(accuracy_dispersion))
		SEMCOL(accuracy_dispersion <= 0, "Projectiles you fire are [is_good ? "less" : "more"] likely to stray from your intended target.")
	if(!isnull(metabolism_percent))
		SEMCOL(metabolism_percent <= 1.0, "Your metabolism is [is_good ? "slower" : "faster"], causing reagents in your body to process, and hunger to occur [multipler_to_percentage(metabolism_percent, TRUE)] [is_good ? "slower" : "faster"].")
	if(!isnull(attack_speed_percent))
		SEMCOL(disable_duration_percent <= 1.0, "The delay between attacking is [multipler_to_percentage(attack_speed_percent, TRUE)] [is_good ? "longer" : "shorter"].")
	if(!isnull(use_tool_delay))
		SEMCOL(use_tool_delay <= 1.0, "Your tooling speed is [is_good ? "increased" : "reduced"] by [multipler_to_percentage(use_tool_delay, TRUE)].")
	if(!isnull(medical_treatment_time))
		SEMCOL(medical_treatment_time <= 1.0, "Your speed of medical treatment and syringe's handling is [is_good ? "increased" : "reduced"] by [multipler_to_percentage(medical_treatment_time, TRUE)].")
	if(!isnull(crp_fracture_chance))
		SEMCOL(crp_fracture_chance <= 1.0, "Your chance of breaking ribs at CPR is [is_good ? "reduced" : "increased"] by [multipler_to_percentage(crp_fracture_chance, TRUE)].")
	if(!isnull(surgery_step_time))
		SEMCOL(surgery_step_time <= 1.0, "Your speed of surgical operations is [is_good ? "increased" : "reduced"] by [multipler_to_percentage(surgery_step_time, TRUE)].")
	if(!isnull(disarm_drop_percent))
		SEMCOL(disarm_drop_percent <= 1.0, "Your chance of dropping a held item is [is_good ? "reduced" : "increased"] by [multipler_to_percentage(disarm_drop_percent, TRUE)].")
	if(!isnull(pull_slowdown_percent))
		SEMCOL(pull_slowdown_percent <= 1.0, "Your pulling speed is [is_good ? "increased" : "reduced"] by [multipler_to_percentage(pull_slowdown_percent, TRUE)].")
	if(!isnull(electrocute_damage_percent))
		SEMCOL(electrocute_damage_percent <= 1.0, "The electrocution damage on you is [is_good ? "reduced" : "increased"] by [multipler_to_percentage(electrocute_damage_percent, TRUE)].")
	if(!isnull(electrocute_block_chance))
		SEMCOL(electrocute_block_chance > 0.0, "The electrocution damage can be blocked with [electrocute_block_chance * 100]% chance.")
	if(!isnull(poise_pool_flat))
		SEMCOL(poise_pool_flat > 0, "You [is_good ? "gain" : "lose"] [abs(poise_pool_flat)] to poison pool.")

	#undef SEMCOL

	return jointext(effects, "<br>")

// Helper to format multiplers (e.g. 1.4) to percentages (like '40%')
/proc/multipler_to_percentage(multi, abs = FALSE)
	if(abs)
		return "[abs( ((multi - 1) * 100) )]%"
	return "[((multi - 1) * 100)]%"
