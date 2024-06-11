/datum/grab/bite
	state_name = NORM_STRUGGLE

	shift = 8

	grab_slowdown = 7

	breakability = 2
	stop_move = FALSE
	can_absorb = FALSE
	shield_assailant = FALSE
	point_blank_mult = FALSE
	same_tile = FALSE
	icon_state = "kill"
	icon = 'icons/hud/actions.dmi'

/obj/item/grab/bite
	type_name = GRAB_BITE
	start_grab_name = NORM_STRUGGLE
	slot_flags = SLOT_MASK

/obj/item/grab/bite/init()
	. = ..()

	if(!affecting)
		return

	assailant.equip_to_slot_or_del(src, slot_wear_mask)
	if(QDELETED(src))
		return

	assailant.do_attack_animation(affecting)
	affecting.grabbed_by += src
