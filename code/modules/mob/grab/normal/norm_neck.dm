/datum/grab/normal/neck
	name               = "chokehold"
	upgrab             = /datum/grab/normal/kill
	downgrab           = /datum/grab/normal/aggressive
	drop_headbutt      = FALSE
	shift              = -10
	stop_move          = TRUE
	reverse_facing     = TRUE
	shield_assailant   = TRUE
	point_blank_mult   = 1
	damage_stage       = 2
	same_tile          = TRUE
	can_throw          = TRUE
	force_danger       = TRUE
	restrains          = TRUE
	grab_icon_state    = "kill"
	break_chance_table = list(3, 18, 45, 100)

/datum/grab/normal/neck/process_effect(obj/item/grab/G)
	var/mob/living/carbon/human/affecting = G.get_affecting_mob()

	if(affecting.can_unequip(affecting.l_hand))
		affecting.drop_l_hand()
	if(affecting.can_unequip(affecting.r_hand))
		affecting.drop_r_hand()

	if(affecting.lying || affecting.leaning)
		affecting.Weaken(2)
		affecting.Stun(2)

	affecting.adjustOxyLoss(1)
