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
	icon_state = "bite"
	icon = 'icons/hud/actions.dmi'

/obj/item/grab/bite
	type_name = GRAB_BITE
	start_grab_name = NORM_STRUGGLE
	slot_flags = SLOT_MASK
	icon = 'icons/hud/actions.dmi'
	icon_state = "bite"

/obj/item/grab/bite/Click(location, control, params)
	var/list/PM = params2list(params)
	if(text2num(PM["icon-y"]) >= 19)
		THROTTLE(cooldown, 3 SECONDS)
		if(!cooldown)
			show_splash_text(assailant, "Too soon!", SPAN_WARNING("It is too soon to bite!"))
			return

		assailant?.finalize_bite(affecting, target_zone, FALSE)
	else if(text2num(PM["icon-y"]) <= 14)
		var/datum/gender/T = gender_datums[assailant.get_gender()]
		visible_message(SPAN("danger", "[assailant] releases [T.his] grip on [affecting]!"),\
			SPAN("danger", "You release your grip!.")
		)
		qdel_self()

/obj/item/grab/bite/update_icons()
	icon = 'icons/hud/actions.dmi'
	icon_state = "bite"

/obj/item/grab/bite/init()
	. = ..()

	if(!affecting)
		return

	assailant.equip_to_slot_or_del(src, slot_wear_mask)
	if(QDELETED(src))
		return

	assailant.do_attack_animation(affecting)
	affecting.grabbed_by += src
