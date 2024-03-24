/datum/grab/normal/kill
	state_name = NORM_KILL

	downgrab_name = NORM_NECK

	shift = 8

	stop_move = 1
	reverse_moving = TRUE
	can_absorb = 1
	shield_assailant = 0
	point_blank_mult = 1
	same_tile = 1
	force_danger = 1
	restrains = 1

	downgrade_on_action = 1
	downgrade_on_move = 1

	icon_state = "kill1"

	break_chance_table = list(5, 20, 40, 80, 100)

/datum/grab/normal/kill/process_effect(obj/item/grab/G)
	var/mob/living/carbon/human/affecting = G.affecting

	if(affecting.can_unequip(affecting.l_hand))
		affecting.drop_l_hand()
	if(affecting.can_unequip(affecting.r_hand))
		affecting.drop_r_hand()

	if(affecting.lying)
		affecting.Weaken(3)
		affecting.Stun(2)

	if((MUTATION_HULK in G.assailant.mutations) || (MUTATION_STRONG in G.assailant.mutations))
		affecting.adjustOxyLoss(3)
		affecting.Stun(2)
	else
		affecting.adjustOxyLoss(1)

	affecting.apply_effect(STUTTER, 5) //It will hamper your voice, being choked and all.
	affecting.losebreath = max(affecting.losebreath + 2, 3)
