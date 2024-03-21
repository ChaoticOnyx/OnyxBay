/datum/modifier/movespeed
	stacks = MODIFIER_STACK_EXTEND
	var/equipment_slowdown_immunity = FALSE

/datum/modifier/movespeed/on_applied()
	holder.add_movespeed_modifier(movespeed_modifier_path)
	if(equipment_slowdown_immunity)
		holder.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/equipment_slowdown)

/datum/modifier/movespeed/on_expire()
	holder.remove_movespeed_modifier(movespeed_modifier_path)
	if(equipment_slowdown_immunity)
		holder.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/equipment_slowdown)

/datum/modifier/movespeed/bloodchill
	movespeed_modifier_path = /datum/movespeed_modifier/bloodchill

/datum/movespeed_modifier/bloodchill
	slowdown = 2

/datum/modifier/movespeed/bonechill
	movespeed_modifier_path = /datum/movespeed_modifier/bonechill

/datum/movespeed_modifier/bonechill
	slowdown = 2

/datum/modifier/movespeed/sepia
	movespeed_modifier_path = /datum/movespeed_modifier/sepia

/datum/movespeed_modifier/sepia
	variable = TRUE
	slowdown = 0

/datum/modifier/movespeed/lightpink
	movespeed_modifier_path = /datum/movespeed_modifier/lightpink

/datum/movespeed_modifier/lightpink
	slowdown = -1

/datum/modifier/movespeed/tarfoot
	movespeed_modifier_path = /datum/movespeed_modifier/tarfoot

/datum/movespeed_modifier/tarfoot
	slowdown = 6

/datum/modifier/movespeed/equipment_immunity_speedmod
	equipment_slowdown_immunity=TRUE
