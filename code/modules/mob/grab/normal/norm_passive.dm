/datum/grab/normal/passive
	name               = "passive hold"
	upgrab             = /datum/grab/normal/struggle
	shift              = 8
	stop_move          = FALSE
	reverse_facing     = FALSE
	shield_assailant   = FALSE
	point_blank_mult   = 1
	same_tile          = FALSE
	grab_icon_state    = "reinforce"
	break_chance_table = list(15, 60, 100)

/datum/grab/normal/passive/on_hit_disarm(obj/item/grab/G)
	if(ismob(G.affecting))
		to_chat(G.assailant, SPAN_WARNING("Your grip isn't strong enough to pin."))
	return FALSE

/datum/grab/normal/passive/on_hit_grab(obj/item/grab/G)
	if(ismob(G.affecting))
		to_chat(G.assailant, SPAN_WARNING("Your grip isn't strong enough to jointlock."))
	return FALSE

/datum/grab/normal/passive/on_hit_harm(obj/item/grab/G)
	if(ismob(G.affecting))
		to_chat(G.assailant, SPAN_WARNING("Your grip isn't strong enough to dislocate."))
	return FALSE

/datum/grab/normal/passive/resolve_openhand_attack(obj/item/grab/G)
	return FALSE
