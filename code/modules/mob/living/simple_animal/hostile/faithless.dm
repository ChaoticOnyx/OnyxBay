/mob/living/simple_animal/hostile/faithless
	name = "Faithless"
	desc = "The Wish Granter's faith in humanity, incarnate"
	icon_state = "faithless"
	icon_living = "faithless"
	icon_dead = "faithless_dead"
	speak_chance = 0
	turns_per_move = 5
	response_help = "passes through"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = -1
	maxHealth = 80
	health = 80

	harm_intent_damage = 25
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "gripped"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	min_gas = null
	max_gas = null
	minbodytemp = 0
	speed = 12

	faction = "faithless"
	supernatural = 1

/mob/living/simple_animal/hostile/faithless/Allow_Spacemove(var/check_drift = 0)
	return 1

/mob/living/simple_animal/hostile/faithless/FindTarget()
	. = ..()
	if(.)
		audible_emote("wails at [.]")

/mob/living/simple_animal/hostile/faithless/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(12))
			L.Weaken(3)
			L.visible_message("<span class='danger'>\The [src] knocks down \the [L]!</span>")

/mob/living/simple_animal/hostile/faithless/cult
	faction = "cult"

/mob/living/simple_animal/hostile/faithless/cult/cultify()
	return
