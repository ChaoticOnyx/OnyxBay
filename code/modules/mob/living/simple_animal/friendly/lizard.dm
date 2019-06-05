/mob/living/simple_animal/lizard
	name = "lizard"
	desc = "A cute tiny lizard."
	icon = 'icons/mob/animal.dmi'
	icon_state = "lizard"
	icon_living = "lizard"
	icon_dead = "lizard_dead"
	speak_emote = list("hisses")
	pass_flags = PASS_FLAG_TABLE
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	attacktext = "bitten"
	melee_damage_lower = 1
	melee_damage_upper = 2
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	density = 0
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	universal_speak = 0
	universal_understand = 1
	holder_type = /obj/item/weapon/holder/lizard
	mob_size = MOB_MINISCULE
	possession_candidate = 1
	can_escape = 1
	shy_animal = 1

	can_pull_size = ITEM_SIZE_TINY
	can_pull_mobs = MOB_PULL_SAME

/mob/living/simple_animal/lizard/Crossed(AM as mob|obj)
	if(ishuman(AM))
		if(!stat)
			var/mob/M = AM
			set_panic_target(M)
	..()
