/datum/storyteller_character/chaotic
	name = "Chaotic"
	desc = "So chaotic that he doesn't even know his next step. Unpredictable"
	aggression_ratio = 0.50
	rarity_ratio = 1.0
	quantity_ratio = 0.50

/datum/storyteller_character/chaotic/New()
	..()

	set_next_think(world.time)

/datum/storyteller_character/chaotic/think()
	roll_ratio()

	set_next_think(world.time + (rand(1, 5) MINUTES))

/datum/storyteller_character/chaotic/proc/roll_ratio()
	if(prob(50))
		aggression_ratio -= rand()
	else
		aggression_ratio += rand()

	if(prob(50))
		quantity_ratio -= rand()
	else
		quantity_ratio += rand()

	if(prob(50))
		rarity_ratio -= rand()
	else
		rarity_ratio += rand()

	aggression_ratio = Clamp(aggression_ratio, 3.0, 0.0)
	quantity_ratio = Clamp(quantity_ratio, 3.0, 0.0)
	rarity_ratio = Clamp(rarity_ratio, 3.0, 0.0)
