/datum/grab/normal/kill
	name                = "strangle"
	downgrab            = /datum/grab/normal/neck
	shift               = 0
	stop_move           = TRUE
	reverse_facing      = TRUE
	shield_assailant    = FALSE
	point_blank_mult    = 2
	damage_stage        = 3
	same_tile           = TRUE
	force_danger        = TRUE
	restrains           = TRUE
	downgrade_on_action = TRUE
	downgrade_on_move   = TRUE
	grab_icon_state     = "kill1"
	break_chance_table  = list(5, 20, 40, 80, 100)

/datum/grab/normal/kill/process_effect(obj/item/grab/G)
	var/mob/living/carbon/human/affecting = G.affecting

	if(affecting.can_unequip(affecting.l_hand))
		affecting.drop_l_hand()
	if(affecting.can_unequip(affecting.r_hand))
		affecting.drop_r_hand()

	if(affecting.lying || affecting.leaning)
		affecting.Weaken(3)
		affecting.Stun(2)

	if((MUTATION_HULK in G.assailant.mutations) || (MUTATION_STRONG in G.assailant.mutations))
		affecting.adjustOxyLoss(3)
		affecting.Stun(2)
	else
		affecting.adjustOxyLoss(1)

	affecting.apply_effect(STUTTER, 5) //It will hamper your voice, being choked and all.
	affecting.losebreath = max(affecting.losebreath + 2, 3)
