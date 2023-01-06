/mob/living/simple_animal/hostile/bluespace_thing
	name = "Bluespace Thing"
	desc = "Uh, what is this? It doesn't look like it's from our world."
	icon = 'icons/mob/polar/bluespace_thing.dmi'
	armor_projectile = 30
	resistance = 30
	maxHealth = 125
	health = 125
	harm_intent_damage = 0
	melee_damage_lower = 15
	melee_damage_upper = 25
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
	aggro_vision_range = 2
	idle_vision_range = 2
	wander = TRUE

/mob/living/simple_animal/hostile/bluespace_thing/boss
	name = "Bluespace Thing"
	desc = "Uh, what is this? It doesn't look like it's from our world."
	icon = 'icons/mob/polar/bluespace_thing_96x96.dmi'
	maxHealth = 450
	health = 450
	melee_damage_lower = 30
	melee_damage_upper = 40

/mob/living/simple_animal/hostile/bluespace_thing/Initialize()
	. = ..()
	var/rand_icon = rand(0,2)
	icon_state = "bluespace_thing-[rand_icon]"
	icon_living = "bluespace_thing-[rand_icon]"
	icon_dead = "bluespace_thing-[rand_icon]"
	icon_gib = "bluespace_thing-[rand_icon]"

/mob/living/simple_animal/hostile/bluespace_thing/boss/Initialize()
	..()
	for(var/i=0, i<rand(3,10), i++)
		new /mob/living/simple_animal/hostile/bluespace_thing(src.loc)

/mob/living/simple_animal/hostile/bluespace_thing/death(gibbed, deathmessage, show_dead_message)
	. = ..()
	qdel(src)
