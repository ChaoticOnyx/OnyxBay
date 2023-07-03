/datum/modifier/movespeed
	stacks = MODIFIER_STACK_EXTEND
	var/equipment_slowdown_immunity = FALSE
	var/movespeed_modifier = 0 // the higher the number, the stronger slowdown

/datum/modifier/movespeed/bloodchill
	movespeed_modifier = 2

/datum/modifier/movespeed/bonechill
	movespeed_modifier = 2

/datum/modifier/movespeed/sepia
	movespeed_modifier = 0

/datum/modifier/movespeed/lightpink
	movespeed_modifier = -1

/datum/modifier/movespeed/tarfoot
	movespeed_modifier = 6

/datum/modifier/movespeed/equipment_immunity_speedmod
	equipment_slowdown_immunity=TRUE
