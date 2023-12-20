////////////////Sand lurker////////////////

/mob/living/simple_animal/hostile/asteroid/sand_lurker
	name = "cosmopterid"
	desc = "Huge segmented creature with sharp fearsome claws. It's almost perfectly disguises itself in sand. Isn't it an arthropod-like incarnation of paranoia itself?"
	icon = 'icons/mob/asteroid/sand_lurker.dmi'
	icon_state = "Sand_lurker"
	icon_living = "Sand_lurker"
	icon_aggro = "Sand_lurker"
	icon_dead = "Sand_lurker_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = 2
	move_to_delay = 20
	friendly = "buzzes near"
	vision_range = 2
	aggro_vision_range = 6
	idle_vision_range = 2
	speed = 3
	maxHealth = 50
	health = 50
	harm_intent_damage = 15
	melee_damage_lower = 20
	melee_damage_upper = 20
	attacktext = "slashes"
	throw_message = "does nothing against the hard shell of"
	environment_smash = 0
	pass_flags = PASS_FLAG_TABLE
	attacktext = "bites into"
	a_intent = "harm"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	bodyparts = /decl/simple_animal_bodyparts/sand_lurker
	meat_type = /obj/item/reagent_containers/food/meat/xeno

/mob/living/simple_animal/hostile/asteroid/sand_lurker/Life()
	. = ..()
	if(.)
		stop_automated_movement = 1

/decl/simple_animal_bodyparts/sand_lurker
	hit_zones = list("cephalothorax", "pedipalp", "tail segment", "mouthparts")
