/datum/grab/normal/struggle
	state_name = NORM_STRUGGLE
	fancy_desc = "holding"

	upgrab_name = NORM_AGGRESSIVE
	downgrab_name = NORM_PASSIVE

	shift = 8

	stop_move = 1
	can_absorb = 0
	point_blank_mult = 1
	same_tile = 0
	breakability = 1.2

	grab_slowdown = 10
	upgrade_cooldown = GRAB_NORM_AGGRESSIVE_GRACE

	icon_state = "reinforce"

	break_chance_table = list(5, 20, 30, 80, 100)


/datum/grab/normal/struggle/process_effect(obj/item/grab/G)
	return

/datum/grab/normal/struggle/enter_as_up(obj/item/grab/G)
	var/mob/living/carbon/human/affecting = G.affecting
	var/mob/living/carbon/human/assailant = G.assailant

	if(!affecting || !assailant)
		return

	affecting.visible_message("<span class='warning'>[affecting] struggles against [assailant] as [assailant] tightens \his grip!</span>")
	G.done_struggle = FALSE
	G.grace_until = world.time + upgrade_cooldown
	resolve_struggle(G)

/datum/grab/normal/struggle/proc/resolve_struggle(obj/item/grab/G)
	set waitfor = FALSE
	if(!G?.assailant || !G.affecting)
		return
	var/success = do_after(G.assailant, upgrade_cooldown, G, can_move = 1, luck_check_type = LUCK_CHECK_COMBAT)

	if(!G || QDELETED(G) || G.current_grab?.state_name != NORM_STRUGGLE)
		return

	if(success)
		G.done_struggle = TRUE
		G.upgrade(TRUE)
	else
		G.downgrade()
	G.grace_until = 0

/datum/grab/normal/struggle/can_upgrade(obj/item/grab/G)
	return G.done_struggle

/datum/grab/normal/struggle/on_hit_disarm(obj/item/grab/normal/G)
	to_chat(G.assailant, "<span class='warning'>Your grip isn't strong enough to pin.</span>")
	return 0

/datum/grab/normal/struggle/on_hit_grab(obj/item/grab/normal/G)
	to_chat(G.assailant, "<span class='warning'>Your grip isn't strong enough to jointlock.</span>")
	return 0

/datum/grab/normal/struggle/on_hit_harm(obj/item/grab/normal/G)
	to_chat(G.assailant, "<span class='warning'>Your grip isn't strong enough to dislocate.</span>")
	return 0

/datum/grab/normal/struggle/resolve_openhand_attack(obj/item/grab/G)
	return 0
