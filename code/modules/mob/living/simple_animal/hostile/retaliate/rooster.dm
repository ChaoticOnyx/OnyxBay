
/mob/living/simple_animal/hostile/retaliate/rooster
	name = "rooster"
	desc = "What a big, majestic cock!"
	icon_state = "cock"
	icon_living = "cock"
	icon_dead = "cock_dead"
	speak = list("COCK-A-DOODLE-DOO!", "Cluck!", "BWAAAAARK BWAK BWAK BWAK!", "CLUCK!", "KIKERIKU!", "COCORICO!", "BWOINK!" = 0.1, "WAKE-THE-FUCK-UP!" = 0.001, "GRIEFER!" = 0.0000001)
	speak_emote = list("screams")
	emote_hear = list("clucks")
	emote_see = list("shakes its head", "stamps a foot", "glares around")
	speak_chance = 2
	turns_per_move = 3
	see_in_dark = 6
	meat_type = /obj/item/reagent_containers/food/meat/chicken
	meat_amount = 4
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	faction = "farm"
	attacktext = "shredded"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	maxHealth = 50
	health = 50
	melee_damage_lower = 5
	melee_damage_upper = 10
	bodyparts = /decl/simple_animal_bodyparts/bird

	var/isragemode = FALSE


/mob/living/simple_animal/hostile/retaliate/rooster/AttackingTarget()
	. = ..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(15))
			L.Weaken(3)
			L.visible_message(SPAN_DANGER("The [src] knocks down \the [L]!"))
