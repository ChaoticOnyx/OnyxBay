/datum/grab/normal/neck
	state_name = NORM_NECK

	upgrab_name = NORM_KILL
	downgrab_name = NORM_AGGRESSIVE

	drop_headbutt = 0

	shift = 8

	stop_move = 1
	reverse_moving = TRUE
	can_absorb = 1
	shield_assailant = 1
	point_blank_mult = 1
	same_tile = 1
	can_throw = 1
	force_danger = 1
	restrains = 1
	ladder_carry = 1
	breakability = 5

	icon_state = "kill"

	break_chance_table = list(3, 18, 45, 100)

/datum/grab/normal/neck/process_effect(obj/item/grab/G)
	var/mob/living/carbon/human/affecting = G.affecting

	if(affecting.can_unequip(affecting.l_hand))
		affecting.drop_l_hand()
	if(affecting.can_unequip(affecting.r_hand))
		affecting.drop_r_hand()

	if(affecting.lying)
		affecting.Weaken(2)
		affecting.Stun(2)

	affecting.adjustOxyLoss(1)
