/datum/grab/normal/aggressive
	name               = "aggressive grab"
	upgrab             = /datum/grab/normal/neck
	downgrab           = /datum/grab/normal/passive
	shift              = 12
	stop_move          = TRUE
	reverse_facing     = FALSE
	shield_assailant   = FALSE
	point_blank_mult   = 1.5
	damage_stage       = 1
	same_tile          = FALSE
	can_throw          = TRUE
	force_danger       = TRUE
	breakability       = 3
	grab_icon_state    = "reinforce1"
	break_chance_table = list(5, 20, 40, 80, 100)

/datum/grab/normal/aggressive/process_effect(obj/item/grab/G)
	if(!G.affecting)
		return
	var/mob/living/carbon/human/affecting = G.affecting

	if(G.target_zone in list(BP_L_HAND, BP_R_HAND))
		if(affecting.can_unequip(affecting.l_hand))
			affecting.drop_l_hand()
		if(affecting.can_unequip(affecting.r_hand))
			affecting.drop_r_hand()

	// Keeps those who are on the ground down
	if(affecting.lying)
		affecting.Weaken(2)
		affecting.Stun(2)

	if(affecting.leaning)
		affecting.Stun(2)

/datum/grab/normal/aggressive/can_upgrade(obj/item/grab/G)
	. = ..()
	if(!.)
		return

	if(!ishuman(G.affecting))
		to_chat(G.assailant, SPAN_WARNING("You can only upgrade an aggressive grab when grappling a human!"))
		return FALSE

	if(!(G.target_zone in list(BP_CHEST, BP_HEAD)))
		to_chat(G.assailant, SPAN_WARNING("You need to be grabbing their torso or head for this!"))
		return FALSE

	var/mob/living/carbon/human/affecting_mob = G.get_affecting_mob()
	if(istype(affecting_mob))
		var/obj/item/clothing/C = affecting_mob.head
		if((C?.item_flags & ITEM_FLAG_STOPPRESSUREDAMAGE) && C?.armor["melee"] > 20)
			to_chat(G.assailant, SPAN_WARNING("\The [C] is in the way!"))
			return FALSE
