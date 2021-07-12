//Look Sir, free crabs!
/mob/living/simple_animal/crab
	name = "crab"
	desc = "A hard-shelled crustacean. Seems quite content to lounge around all the time."
	icon_state = "crab"
	item_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	mob_size = MOB_SMALL
	speak_emote = list("clicks", "clacks")
	emote_hear = list("clicks", "clacks")
	emote_see = list("clacks", "clacks")
	pass_flags = PASS_FLAG_TABLE
	speak_chance = 1
	turns_per_move = 3
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "stomps"
	friendly = "pinches"
	attacktext = "nipped"
	attack_sound = 'sound/weapons/bite.ogg'
	density = 0
	universal_speak = FALSE
	universal_understand = TRUE
	holder_type = /obj/item/weapon/holder/crab
	possession_candidate = TRUE
	can_escape = TRUE //snip snip
	controllable = TRUE
	shy_animal = TRUE

	can_pull_size = ITEM_SIZE_TINY
	can_pull_mobs = MOB_PULL_SAME

	renamable = TRUE


/mob/living/simple_animal/crab/Crossed(AM as mob|obj)
	if(!client && ishuman(AM) && !stat)
		var/mob/M = AM
		to_chat(M, SPAN("warning", "\icon[src] [pick("Click", "Clack")]!"))
		if(prob(50))
			UnarmedAttack(M)
		set_panic_target(M)
	..()

//COFFEE! SQUEEEEEEEEE!
/mob/living/simple_animal/crab/Coffee
	name = "Coffee"
	real_name = "Coffee"
	desc = "It's Coffee, the other pet!"
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "stomps"
	possession_candidate = FALSE
	controllable = FALSE
	renamable = FALSE
