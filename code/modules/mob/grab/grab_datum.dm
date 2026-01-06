/datum/grab

	var/type_name
	var/state_name
	var/fancy_desc

	var/datum/grab/upgrab						// The grab that this will upgrade to if it upgrades, null means no upgrade
	var/datum/grab/downgrab						// The grab that this will downgrade to if it downgrades, null means break grab on downgrade

	var/stop_move = 0							// Whether or not the grabbed person can move out of the grab
	var/force_stand = 0							// Whether or not the grabbed person is forced to be standing
	var/reverse_moving = FALSE					// Whether the persons involved will move backwards
	var/can_absorb = 0							// Whether this grab state is strong enough to, as a changeling, absorb the person you're grabbing.
	var/shield_assailant = 0					// Whether the person you're grabbing will shield you from bullets.,,
	var/point_blank_mult = 1					// How much the grab increases point blank damage.
	var/same_tile = 0							// If the grabbed person and the grabbing person are on the same tile.
	var/ladder_carry = 0						// If the grabber can carry the grabbed person up or down ladders.
	var/can_throw = 0							// If the grabber can throw the person grabbed.
	var/downgrade_on_action = 0					// If the grab needs to be downgraded when the grabber does stuff.
	var/downgrade_on_move = 0					// If the grab needs to be downgraded when the grabber moves.
	var/force_danger = 0						// If the grab is strong enough to be able to force someone to do something harmful to them.
	var/restrains = 0							// If the grab acts like cuffs and prevents action from the victim.

	var/grab_slowdown = 7

	var/shift = 0

	var/success_up = "You upgrade the grab."
	var/success_down = "You downgrade the grab."

	var/fail_up = "You fail to upgrade the grab."
	var/fail_down = "You fail to downgrade the grab."

	var/upgrab_name
	var/downgrab_name

	var/icon
	var/icon_state

	var/upgrade_cooldown = 40
	var/action_cooldown = 40

	var/can_downgrade_on_resist = 1
	var/list/break_chance_table = list(100)
	var/breakability = 2

	// The names of different intents for use in attack logs
	var/help_action = "help intent"
	var/disarm_action = "disarm intent"
	var/grab_action = "grab intent"
	var/harm_action = "harm intent"

/*
	These procs shouldn't be overriden in the children unless you know what you're doing with them; they handle important core functions.
	Even if you do override them, you should likely be using ..() if you want the behaviour to function properly. That is, of course,
	unless you're writing your own custom handling of things.
*/

/datum/grab/proc/refresh_updown()
	if(upgrab_name)
		upgrab = all_grabstates[upgrab_name]

	if(downgrab_name)
		downgrab = all_grabstates[downgrab_name]

// This is for the strings defined as datum variables. It takes them and swaps out keywords for relevent ones from the grab
// object involved.
/datum/grab/proc/string_process(obj/item/grab/G, to_write, obj/item/used_item)
	to_write = replacetext(to_write, "rep_affecting", G.affecting)
	to_write = replacetext(to_write, "rep_assailant", G.assailant)
	if(used_item)
		to_write = replacetext(to_write, "rep_item", used_item)
	return to_write

/datum/grab/proc/upgrade(obj/item/grab/G)
	if(!upgrab)
		return

	if (can_upgrade(G))
		upgrade_effect(G)
		admin_attack_log(G.assailant, G.affecting, "tightens their grip on their victim to [upgrab.state_name]", "was grabbed more tightly to [upgrab.state_name]", "tightens grip to [upgrab.state_name] on")
		return upgrab
	else
		to_chat(G.assailant, "<span class='warning'>[string_process(G, fail_up)]</span>")
		return

/datum/grab/proc/downgrade(obj/item/grab/G)
	return downgrab

/datum/grab/proc/process(obj/item/grab/G)
	if(!G.is_eligible()) // In case if the grab wants to process, but there's no longer a mob grabbed by this exact grab
		G.delete_self()
		return
	var/diff_zone = G.target_change()
	if(diff_zone && G.special_target_functional)
		special_target_change(G, diff_zone)
	else
		special_target_effect(G)

	process_effect(G)

/datum/grab/proc/throw_held(obj/item/grab/G)
	if(!G.affecting)
		return
	var/mob/living/carbon/human/affecting = G.affecting

	if(can_throw)
		animate(affecting, pixel_x = 0, pixel_y = 0, 4, 1)
		qdel(G)
		return affecting
	return null

/datum/grab/proc/hit_with_grab(obj/item/grab/G)
	if(!G.assailant)
		return

	if(downgrade_on_action)
		G.downgrade()

	if(G.check_action_cooldown() && !G.attacking)
		var/intent = G.assailant.a_intent
		switch(intent)

			if(I_HELP)
				if(on_hit_help(G))
					G.action_used()
					make_log(G, help_action)

			if(I_DISARM)
				if(on_hit_disarm(G))
					G.action_used()
					make_log(G, disarm_action)

			if(I_GRAB)
				if(on_hit_grab(G))
					G.action_used()
					make_log(G, grab_action)

			if(I_HURT)
				if(on_hit_harm(G))
					G.action_used()
					make_log(G, harm_action)

	else
		to_chat(G.assailant, "<span class='warning'>You must wait before you can do that.</span>")

/datum/grab/proc/make_log(obj/item/grab/G, action)
	if(!G.affecting && !G.assailant)
		return
	admin_attack_log(G.assailant, G.affecting, "[action]s their victim", "was [action]ed", "used [action] on")


/datum/grab/proc/adjust_position(obj/item/grab/G)
	if(!G.affecting && !G.assailant)
		return
	var/mob/living/carbon/human/affecting = G.affecting
	var/mob/living/carbon/human/assailant = G.assailant
	var/adir = get_dir(assailant, affecting)

	if(same_tile)
		affecting.forceMove(assailant.loc)
		adir = assailant.dir
		affecting.set_dir(assailant.dir)

	switch(adir)
		if(NORTH)
			animate(affecting, pixel_x = 0, pixel_y =-shift, 5, 1, LINEAR_EASING)
			G.draw_affecting_under()
		if(SOUTH)
			animate(affecting, pixel_x = 0, pixel_y = shift, 5, 1, LINEAR_EASING)
			G.draw_affecting_over()
		if(WEST)
			animate(affecting, pixel_x = shift, pixel_y = 0, 5, 1, LINEAR_EASING)
			G.draw_affecting_under()
		if(EAST)
			animate(affecting, pixel_x =-shift, pixel_y = 0, 5, 1, LINEAR_EASING)
			G.draw_affecting_under()

	affecting.reset_plane_and_layer()

/datum/grab/proc/reset_position(obj/item/grab/G)
	if(!G.affecting)
		return
	var/mob/living/carbon/human/affecting = G.affecting

	if(!affecting.buckled)
		animate(affecting, pixel_x = 0, pixel_y = 0, 4, 1, LINEAR_EASING)
	affecting.reset_plane_and_layer()

/*
	Override these procs to set how the grab state will work. Some of them are best
	overriden in the parent of the grab set (for example, the behaviour for on_hit_intent(obj/item/grab/G)
	procs is determined in /datum/grab/normal and then inherited by each intent).
*/

// What happens when you upgrade from one grab state to the next.
/datum/grab/proc/upgrade_effect(obj/item/grab/G)

// Conditions to see if upgrading is possible
/datum/grab/proc/can_upgrade(obj/item/grab/G)
	return 1

// Conditions to see if downgrading is possible
/datum/grab/proc/can_downgrade(obj/item/grab/G)
	return 1

// What happens each tic when process is called.
/datum/grab/proc/process_effect(obj/item/grab/G)

// Handles special targeting like eyes and mouth being covered.
/datum/grab/proc/special_target_effect(obj/item/grab/G)

// Handles when they change targeted areas and something is supposed to happen.
/datum/grab/proc/special_target_change(obj/item/grab/G, diff_zone)

// Checks if the special target works on the grabbed humanoid.
/datum/grab/proc/check_special_target(obj/item/grab/G)

// What happens when you hit the grabbed person with the grab on help intent.
/datum/grab/proc/on_hit_help(obj/item/grab/G)
	return 1

// What happens when you hit the grabbed person with the grab on disarm intent.
/datum/grab/proc/on_hit_disarm(obj/item/grab/G)
	return 1

// What happens when you hit the grabbed person with the grab on grab intent.
/datum/grab/proc/on_hit_grab(obj/item/grab/G)
	return 1

// What happens when you hit the grabbed person with the grab on harm intent.
/datum/grab/proc/on_hit_harm(obj/item/grab/G)
	return 1

// What happens when you hit the grabbed person with an open hand and you want it
// to do some special snowflake action based on some other factor such as
// intent.
/datum/grab/proc/resolve_openhand_attack(obj/item/grab/G)
	return 0

// Used when you want an effect to happen when the grab enters this state as an upgrade
/datum/grab/proc/enter_as_up(obj/item/grab/G)

/datum/grab/proc/item_attack(obj/item/grab/G, obj/item)

/datum/grab/proc/resolve_item_attack(obj/item/grab/G, mob/living/carbon/human/user, obj/item/I, target_zone)
	return 0

/datum/grab/proc/handle_resist(obj/item/grab/G)
	if(!G.affecting && !G.assailant)
		return
	var/mob/living/carbon/human/affecting = G.affecting
	var/mob/living/carbon/human/assailant = G.assailant

	if(affecting.incapacitated(INCAPACITATION_KNOCKOUT | INCAPACITATION_STUNNED))
		to_chat(affecting, SPAN("warning", "You can't resist in your current state!"))

	//var/break_strength = breakability + size_difference(affecting, assailant)

	var/p_mult = 1.5
	for(var/obj/item/grab/AF in affecting.grabbed_by)
		p_mult -= 0.5

	if(affecting.incapacitated(INCAPACITATION_ALL))
		p_mult -= 0.1
	if(affecting.confused)
		p_mult -= 0.1
	if(affecting.lying)
		p_mult -= 0.1

	//if(break_strength < 1)
	//	to_chat(G.assailant, "<span class='warning'>You try to break free but feel that unless something changes, you'll never escape!</span>")
	//	return

	var/p_lost = round((5.0 + affecting.poise/10 - assailant.poise/15) * p_mult, 0.1)
	assailant.damage_poise(p_lost)
	affecting.damage_poise(2.0)

	//assailant.visible_message("Debug: [assailant] lost [p_lost] poise | now: [assailant.poise]/[assailant.poise_pool]") //Debug message

	var/p_diff = 25.0 // If difference is less than 5.0 then the break chance is capped (12.5%/8.33% for normal and agressive grabs respectively).
	if((affecting.poise - assailant.poise) > 5.0)
		p_diff = (affecting.poise - assailant.poise) * 5
	else if(assailant.poise - affecting.poise > 20.0) // HUGE difference, tiny chance to escape
		p_diff = 10.0

	p_diff /= breakability // 2 for a normal grab, 3 for agressive and kill grabs

	//assailant.visible_message("Debug: p_diff = [p_diff] | breakability = [breakability]") //Debug message

	if(p_diff > assailant.poise && prob(p_diff))
		if(can_downgrade_on_resist && !prob(p_diff))
			affecting.visible_message(SPAN("warning", "[affecting] has loosened [assailant]'s grip!"))
			assailant.setClickCooldown(10)
			G.downgrade()
			return
		else
			affecting.visible_message(SPAN("warning", "[affecting] has broken free of [assailant]'s grip!"))
			assailant.setClickCooldown(15)
			G.delete_self()

/datum/grab/proc/size_difference(mob/A, mob/B)
	return mob_size_difference(A.mob_size, B.mob_size)
