/mob/living/simple_animal/hostile/bluespace_thing
	name = "Bluespace Thing"
	desc = "Uh, what is this? It doesn't look like it's from our world."
	icon_state = "bluespace_thing"
	icon_living = "bluespace_thing"
	icon_dead = "bluespace_thing"
	icon_gib = "bluespace_thing"

	invisibility = INVISIBILITY_MAXIMUM
	armor_projectile = 30
	resistance = 30
	maxHealth = 120
	health = 120
	harm_intent_damage = 0
	melee_damage_lower = 40
	melee_damage_upper = 20
	speed = 4
	universal_speak = FALSE
	universal_understand = FALSE
	speak_chance = 0
	break_stuff_probability = 0
	ranged = FALSE

	// Bluespace things aren't affected by atmos.
	min_gas = null
	max_gas = null
	minbodytemp = 0
	attacktext = "bitten"
	attack_sound = 'sound/weapons/bite.ogg'
	bodyparts = null
	faction = "bluespace"

	vision_range = 2
	aggro_vision_range = 3
	idle_vision_range = 2
	wander = FALSE
