/datum/grab/normal/struggle
	name                    = "struggle grab"
	upgrab                  = /datum/grab/normal/aggressive
	downgrab                = /datum/grab/normal/passive
	shift                   = 8
	stop_move               = TRUE
	reverse_facing          = FALSE
	point_blank_mult        = 1
	same_tile               = FALSE
	breakability            = 3
	grab_slowdown           = 0.35
	upgrade_cooldown        = 20
	can_downgrade_on_resist = FALSE
	grab_icon_state         = "reinforce"
	break_chance_table      = list(5, 20, 30, 80, 100)

/datum/grab/normal/struggle/process_effect(obj/item/grab/G)
	var/mob/living/carbon/human/affecting = G.affecting
	var/mob/living/carbon/human/assailant = G.assailant

	if(affecting.incapacitated() || affecting.a_intent == I_HELP)
		var/datum/gender/assailant_gender = gender_datums[assailant.gender]
		affecting.visible_message(SPAN_DANGER("\The [affecting] isn't prepared to fight back as [assailant] tightens [assailant_gender.his] grip!"))
		G.done_struggle = TRUE
		G.upgrade(TRUE)

/datum/grab/normal/struggle/enter_as_up(obj/item/grab/G)
	var/mob/living/carbon/human/affecting = G.affecting
	var/mob/living/carbon/human/assailant = G.assailant

	if(affecting.incapacitated() || affecting.a_intent == I_HELP)
		var/datum/gender/assailant_gender = gender_datums[assailant.gender]
		affecting.visible_message(SPAN_DANGER("\The [affecting] isn't prepared to fight back as [assailant] tightens [assailant_gender.his] grip!"))
		G.done_struggle = TRUE
		G.upgrade(TRUE)
	else
		affecting.visible_message(SPAN_WARNING("[affecting] struggles against [assailant]!"))
		G.done_struggle = FALSE
		G.set_next_think_ctx("handle_resist", 1 SECOND)
		resolve_struggle(G)

/datum/grab/normal/struggle/proc/resolve_struggle(obj/item/grab/G)
	set waitfor = FALSE
	if(do_after(G.assailant, upgrade_cooldown, G, can_move = 1))
		G.done_struggle = TRUE
		G.upgrade(TRUE)
	else
		G.downgrade()

/datum/grab/normal/struggle/can_upgrade(obj/item/grab/G)
	. = ..() && G.done_struggle

/datum/grab/normal/struggle/on_hit_disarm(obj/item/grab/G)
	to_chat(G.assailant, SPAN_WARNING("Your grip isn't strong enough to pin."))
	return FALSE

/datum/grab/normal/struggle/on_hit_grab(obj/item/grab/G)
	to_chat(G.assailant, SPAN_WARNING("Your grip isn't strong enough to jointlock."))
	return FALSE

/datum/grab/normal/struggle/on_hit_harm(obj/item/grab/G)
	to_chat(G.assailant, SPAN_WARNING("Your grip isn't strong enough to dislocate."))
	return FALSE

/datum/grab/normal/struggle/resolve_openhand_attack(obj/item/grab/G)
	return FALSE
