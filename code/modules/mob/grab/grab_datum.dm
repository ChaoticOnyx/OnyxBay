/datum/grab
	var/name                    = "generic grab"
	/// Whether or not the grabbed person can move out of the grab
	var/stop_move               = 0
	/// Whether the person being grabbed is facing forwards or backwards.
	var/reverse_facing          = 0
	/// Whether the person you're grabbing will shield you from bullets.
	var/shield_assailant        = 0
	/// How much the grab increases point blank damage.
	var/point_blank_mult        = 1
	/// Affects how much damage is being dealt using certain actions.
	var/damage_stage            = 1
	/// If the grabbed person and the grabbing person are on the same tile.
	var/same_tile               = 0
	/// If the grabber can throw the person grabbed.
	var/can_throw               = 0
	/// If the grab needs to be downgraded when the grabber does stuff.
	var/downgrade_on_action     = 0
	/// If the grab needs to be downgraded when the grabber moves.
	var/downgrade_on_move       = 0
	/// If the grab is strong enough to be able to force someone to do something harmful to them.
	var/force_danger            = 0
	/// If the grab acts like cuffs and prevents action from the victim.
	var/restrains               = 0
	/// Multiplier for the object size (w_class or mob_size) of the grabbed atom, applied as slowdown.
	var/grab_slowdown           = 0.15
	/// Whether or not this grab causes atoms to adjust their pixel offsets according to grabber dir.
	var/shift                   = 0
	/// Whether or not this grab causes atoms to adjust their plane/layer according to grabber dir.
	var/adjust_plane            = TRUE
	/// Whether this grabstate allows to absorb (for changelings and vampires).
	var/can_absorb              = FALSE
	/// Whether this grabstate forces affected mob to stand.
	var/force_stand             = FALSE

	var/success_up              = "You get a better grip on $rep_affecting$."
	var/success_down            = "You adjust your grip on $rep_affecting$."
	var/fail_up                 = "You can't get a better grip on $rep_affecting$!"
	var/fail_down               = "You can't seem to relax your grip on $rep_affecting$!"

	/// The grab that this will upgrade to if it upgrades, null means no upgrade
	var/datum/grab/upgrab
	/// The grab that this will downgrade to if it downgrades, null means break grab on downgrade
	var/datum/grab/downgrab

	var/grab_icon               = 'icons/hud/actions.dmi'
	var/grab_icon_state         = "reinforce"
	var/upgrade_cooldown        = 40
	var/action_cooldown         = 40
	var/can_downgrade_on_resist = 1
	var/list/break_chance_table = list(100)
	var/breakability            = 2

	/// The names of different intents for use in attack logs
	var/help_action             = "help intent"
	var/disarm_action           = "disarm intent"
	var/grab_action             = "grab intent"
	var/harm_action             = "harm intent"

/datum/grab/proc/refresh_updown()
	if(ispath(upgrab))
		upgrab = GLOB.all_grabstates[upgrab]

	if(ispath(downgrab))
		downgrab = GLOB.all_grabstates[downgrab]

/// This is for the strings defined as datum variables. It takes them and swaps out keywords for relevent ones from the grab object involved.
/datum/grab/proc/string_process(obj/item/grab/G, to_write, obj/item/used_item)
	SHOULD_NOT_OVERRIDE(TRUE)

	to_write = replacetext(to_write, "$rep_affecting$", G.affecting)
	to_write = replacetext(to_write, "$rep_assailant$", G.assailant)
	if(used_item)
		to_write = replacetext(to_write, "$rep_item$", used_item)
	return to_write

/datum/grab/proc/upgrade(obj/item/grab/G)
	if(can_upgrade(G) && upgrade_effect(G))
		to_chat(G.assailant, SPAN_WARNING("[string_process(G, success_up)]"))
		admin_attack_log(G.assailant, G.affecting, "tightens their grip on their victim to [upgrab]", "was grabbed more tightly to [upgrab]", "tightens grip to [upgrab] on")
		return upgrab

	to_chat(G.assailant, SPAN_WARNING("[string_process(G, fail_up)]"))

/datum/grab/proc/downgrade(obj/item/grab/G)
	SHOULD_NOT_OVERRIDE(TRUE)

	// If we have no downgrab at all, assume we just drop the grab.
	if(!downgrab)
		let_go(G)
		return

	if(can_downgrade(G) && downgrade_effect(G))
		to_chat(G.assailant, SPAN_NOTICE("[string_process(G, success_down)]"))
		return downgrab

	to_chat(G.assailant, SPAN_WARNING("[string_process(G, fail_down)]"))

/datum/grab/proc/let_go(obj/item/grab/G)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(G.assailant && G.affecting)
		to_chat(G.assailant, SPAN_NOTICE("You release \the [G.affecting]."))
	let_go_effect(G)
	G.force_drop()

/datum/grab/proc/on_target_change(obj/item/grab/G, old_zone, new_zone)
	SHOULD_NOT_OVERRIDE(TRUE)

	G.special_target_functional = check_special_target(G)
	if(G.special_target_functional)
		special_target_change(G, old_zone, new_zone)
		special_target_effect(G)

/datum/grab/proc/process(obj/item/grab/G)
	SHOULD_NOT_OVERRIDE(TRUE)

	special_target_effect(G)
	process_effect(G)

/datum/grab/proc/throw_held(obj/item/grab/G)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(G.assailant == G.affecting)
		return

	if(can_throw)
		. = G.affecting
		var/mob/thrower = G.loc
		qdel(G)
		// check if we're grabbing with our inactive hand
		for(var/obj/item/grab/grab in thrower.get_inactive_hand())
			qdel(grab)

/datum/grab/proc/hit_with_grab(obj/item/grab/G, atom/A, P = TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(QDELETED(G) || !istype(G))
		return FALSE

	if(!G.check_action_cooldown() || G.is_currently_resolving_hit)
		to_chat(G.assailant, SPAN_WARNING("You must wait before you can do that."))
		return FALSE

	G.is_currently_resolving_hit = TRUE
	switch(G.assailant.a_intent)
		if(I_HELP)
			if(on_hit_help(G, A, P))
				. = help_action || TRUE
		if(I_DISARM)
			if(on_hit_disarm(G, A, P))
				. = disarm_action || TRUE
		if(I_GRAB)
			if(on_hit_grab(G, A, P))
				. = grab_action || TRUE
		if(I_HURT)
			if(on_hit_harm(G, A, P))
				. = harm_action || TRUE

	if(!QDELETED(G))
		G.is_currently_resolving_hit = FALSE
		if(.)
			G.action_used()
			if(G.assailant)
				G.assailant.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
				if(istext(.) && G.affecting)
					admin_attack_log(G.assailant, G.affecting, "[.]s their victim", "was [.]ed", "used [.] on")
			if(downgrade_on_action)
				G.downgrade()

/// This is called whenever the assailant moves.
/datum/grab/proc/assailant_moved(obj/item/grab/G)
	SHOULD_NOT_OVERRIDE(TRUE)

	G.adjust_position()
	moved_effect(G)
	if(downgrade_on_move)
		G.downgrade()

/datum/grab/proc/make_log(obj/item/grab/G, action)
	if(!G.affecting && !G.assailant)
		return
	admin_attack_log(G.assailant, G.affecting, "[action]s their victim", "was [action]ed", "used [action] on")

/*
	Override these procs to set how the grab state will work. Some of them are best
	overriden in the parent of the grab set (for example, the behaviour for on_hit_intent()
	procs is determined in /datum/grab/normal and then inherited by each intent).
*/

/// What happens when you upgrade from one grab state to the next.
/datum/grab/proc/upgrade_effect(obj/item/grab/G)
	admin_attack_log(G.assailant, G.affecting, "upgraded grab on their victim to [upgrab]", "was grabbed more tightly to [upgrab]", "upgraded grab to [upgrab] on")
	return TRUE

/// Conditions to see if upgrading is possible
/// Only works on mobs.
/datum/grab/proc/can_upgrade(obj/item/grab/G)
	return !!upgrab && !!G.get_affecting_mob()

/// What happens when you downgrade from one grab state to the next.
/datum/grab/proc/downgrade_effect(obj/item/grab/G)
	return TRUE

/// Conditions to see if downgrading is possible
/datum/grab/proc/can_downgrade(obj/item/grab/G)
	return !!downgrab

/// What happens when you let go of someone by either dropping the grab
/// or by downgrading from the lowest grab state.
/datum/grab/proc/let_go_effect(obj/item/grab/G)

/// What happens each tic when process is called.
/datum/grab/proc/process_effect(obj/item/grab/G)

/// Handles special targeting like eyes and mouth being covered.
/datum/grab/proc/special_target_effect(obj/item/grab/G)

/// Handles when they change targeted areas and something is supposed to happen.
/datum/grab/proc/special_target_change(obj/item/grab/G, diff_zone)

/// Checks if the special target works on the grabbed humanoid.
/datum/grab/proc/check_special_target(obj/item/grab/G)

/// What happens when you a target with the grab on help intent.
/datum/grab/proc/on_hit_help(obj/item/grab/G, atom/A, proximity)
	return TRUE

/// What happens when you a target with the grab on disarm intent.
/datum/grab/proc/on_hit_disarm(obj/item/grab/G, atom/A, proximity)
	return TRUE

/// What happens when you a target with the grab on grab intent.
/datum/grab/proc/on_hit_grab(obj/item/grab/G, atom/A, proximity)
	return TRUE

/// What happens when you a target with the grab on harm intent.
/datum/grab/proc/on_hit_harm(obj/item/grab/G, atom/A, proximity)
	return TRUE

/// What happens when you hit a target with an open hand and you want it
/// to do some special snowflake action based on some other factor such as intent.
/datum/grab/proc/resolve_openhand_attack(obj/item/grab/G)
	return 0

/// Used when you want an effect to happen when the grab enters this state as an upgrade
/datum/grab/proc/enter_as_up(obj/item/grab/G)
	pass()

/datum/grab/proc/item_attack(obj/item/grab/G, obj/item)
	pass()

/datum/grab/proc/resolve_item_attack(obj/item/grab/G, mob/living/carbon/human/user, obj/item/I, target_zone)
	return FALSE

/datum/grab/proc/handle_resist(obj/item/grab/G)
	var/mob/living/carbon/human/affecting = G.get_affecting_mob()
	var/mob/living/carbon/human/assailant = G.assailant
	if(!affecting)
		return

	if(affecting.incapacitated(INCAPACITATION_KNOCKOUT | INCAPACITATION_STUNNED))
		to_chat(G.affecting, SPAN_WARNING("You can't resist in your current state!"))

	var/p_mult = 1.5
	for(var/obj/item/grab/AF in affecting.grabbed_by)
		p_mult -= 0.5

	if(affecting.incapacitated(INCAPACITATION_ALL))
		p_mult -= 0.1
	if(affecting.confused)
		p_mult -= 0.1
	if(!affecting.lying)
		p_mult += 0.1

	var/p_lost = (5.5 + affecting.poise / 10 - assailant.poise / 20) * p_mult
	assailant.damage_poise(p_lost)
	affecting.damage_poise(2.0)

	var/p_diff = 25.0 // If difference is less than 5.0 then the break chance is capped (12.5%/8.33% for normal and agressive grabs respectively).

	if((affecting.poise - assailant.poise) > 5.0)
		p_diff = (affecting.poise - assailant.poise) * 5
	else if(assailant.poise - affecting.poise > 20.0) // HUGE difference, tiny chance to escape
		p_diff = 10.0

	p_diff /= breakability // 2 for a normal grab, 3 for agressive and kill grabs

	//var/break_strength = breakability + size_difference(affecting, assailant) + skill_mod

	if(p_diff > assailant.poise || prob(p_diff))
		if(can_downgrade_on_resist && !prob(p_diff))
			affecting.visible_message(SPAN("warning", "[affecting] has loosened [assailant]'s grip!"))
			assailant.setClickCooldown(10)
			G.downgrade()
			return
		else
			affecting.visible_message(SPAN("warning", "[affecting] has broken free of [assailant]'s grip!"))
			assailant.setClickCooldown(15)
			let_go(G)

/datum/grab/proc/size_difference(mob/A, mob/B)
	return mob_size_difference(A.mob_size, B.mob_size)

/datum/grab/proc/moved_effect(obj/item/grab/G)
	return
