/mob/living/simple_animal/hostile/tomato
	name = "tomato"
	desc = "It's a horrifyingly enormous beef tomato, and it's packing extra beef!"
	icon_state = "tomato"
	icon_living = "tomato"
	icon_dead = "tomato_dead"
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 42
	health = 42
	speed = 4
	meat_type = /obj/item/reagent_containers/food/tomatomeat
	response_help  = "prods"
	response_disarm = "pushes aside"
	response_harm   = "smacks"
	harm_intent_damage = 5
	melee_damage_upper = 15
	melee_damage_lower = 10
	attacktext = "mauled"
	bodyparts = /decl/simple_animal_bodyparts/tomato
	possession_candidate = 1
	controllable = TRUE
	universal_speak = 0
	universal_understand = 1

	faction = "floral"

/mob/living/simple_animal/hostile/tomato/Initialize()
	. = ..()

	if(name == initial(name))
		name = "[name] ([sequential_id(/mob/living/simple_animal/hostile/tomato)])"
	real_name = name

/decl/simple_animal_bodyparts/tomato
	hit_zones = list("flesh", "leaf", "mouth")
