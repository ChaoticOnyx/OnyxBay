/datum/storyteller_character/thirteen
	name = "Thirteen"
	desc = "She'll give you plenty of time to get prepared but will also grow vicious and unfair as time goes on."
	aggression_ratio = 0.50
	rarity_ratio = 0.20
	quantity_ratio = 0.35
	event_chance_multiplier = 10
	difficulty_soft_cap = 0
	difficulty_hard_cap = 6.0
	var/difficulty_increment = 6.0 // Difficulty hard cap rises by this value every 3 minutes.

/datum/storyteller_character/thirteen/New()
	..()
	set_next_think(world.time + 10 MINUTES)

/datum/storyteller_character/thirteen/think()
	difficulty_hard_cap += difficulty_increment
	if(difficulty_hard_cap > 100)
		simultaneous_event_fire = TRUE
	if(difficulty_hard_cap - difficulty_soft_cap > 75)
		difficulty_soft_cap += difficulty_increment
	set_next_think(world.time + 3 MINUTES)
