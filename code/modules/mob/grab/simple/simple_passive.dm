/datum/grab/simple
	name = "simple grab"
	shift = 8
	stop_move = 0
	reverse_facing = 0
	shield_assailant = 0
	point_blank_mult = 1
	same_tile = 0
	break_chance_table = list(15, 60, 100)

/datum/grab/simple/upgrade(obj/item/grab/G)
	return

/datum/grab/simple/on_hit_disarm(obj/item/grab/G, atom/A, proximity)
	return FALSE

/datum/grab/simple/on_hit_grab(obj/item/grab/G, atom/A, proximity)
	return FALSE

/datum/grab/simple/on_hit_harm(obj/item/grab/G, atom/A, proximity)
	return FALSE

/datum/grab/simple/resolve_openhand_attack(obj/item/grab/G)
	return FALSE
