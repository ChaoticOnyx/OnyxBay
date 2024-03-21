/mob/living/simple_animal/hostile/ghoul
	name = "Ghoul"
	desc = "Unnatural and abhorrent abomination"
	icon_state = "ghoul"
	icon_living = "ghoul"
	speak_chance = FALSE
	response_help = "passes through"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	maxHealth = 500
	health = 500

	harm_intent_damage = 30
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "gripped"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	min_gas = null
	max_gas = null
	minbodytemp = 0

	faction = "wizard"
	bodyparts = /decl/simple_animal_bodyparts/ghoul

/decl/simple_animal_bodyparts/ghoul
	hit_zones = list("body", "left appendage", "right appendage", "shadowy tendrils", "head", "right stump", "left stump", "infernal eye")
