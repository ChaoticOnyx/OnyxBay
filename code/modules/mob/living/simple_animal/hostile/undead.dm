/mob/living/simple_animal/hostile/skull
	name = "Skull"
	desc = "A collection of skulls."

	icon_state = "skull"
	icon_living = "skull"

	health = 80
	maxHealth = 80

	density = FALSE

	attacktext = "headbutted"
	can_escape = TRUE

	bodyparts = /decl/simple_animal_bodyparts/skull

	faction = "wizard"

/mob/living/simple_animal/hostile/skull/AttackingTarget()
	if(!Adjacent(target_mob))
		return

	var/hit_zone = ran_zone()
	target_mob.stun_effect_act(rand(2,5), rand(10, 90), hit_zone, src)
	var/turf/location = get_turf(loc)
	ASSERT(location)
	explosion(location, -1, -1, 0, 1)
	qdel_self()

/decl/simple_animal_bodyparts/skull
	hit_zones = list("body", "carapace", "righ skull", "left skull", "central skull")

/mob/living/simple_animal/hostile/wight
	name = "Wight"
	desc = "A reanimated corpse."

	icon_state = "wight"
	icon_living = "wight"

	health = 100
	maxHealth = 100

	attacktext = "attacked"
	melee_damage_lower = 15
	melee_damage_upper = 15
	can_escape = TRUE

	bodyparts = /decl/simple_animal_bodyparts/humanoid

	faction = "wizard"
