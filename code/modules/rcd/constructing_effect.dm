/obj/effect/constructing_effect
	icon = 'icons/effects/effects_rcd.dmi'
	icon_state = ""
	layer = ABOVE_HUMAN_LAYER
	plane = DEFAULT_PLANE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	var/status = 0
	var/delay = 0

/obj/effect/constructing_effect/Initialize(mapload, rcd_delay, rcd_status, rcd_upgrades)
	. = ..()
	status = rcd_status
	delay = rcd_delay
	if(status == RCD_DECONSTRUCT)
		addtimer(CALLBACK(src, nameof(/atom.proc/update_icon)), 1.1 SECONDS)
		delay -= 11
		icon_state = "rcd_end_reverse"
	else
		update_icon()

	if(rcd_upgrades & RCD_UPGRADE_ANTI_INTERRUPT)
		color = list(
			1.0, 0.5, 0.5, 0.0,
			0.1, 0.0, 0.0, 0.0,
			0.1, 0.0, 0.0, 0.0,
			0.0, 0.0, 0.0, 1.0,
			0.0, 0.0, 0.0, 0.0,
		)

		mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/constructing_effect/proc/update_name(updates)
	if(status == RCD_DECONSTRUCT)
		name = "deconstruction effect"
	else
		name = "construction effect"

/obj/effect/constructing_effect/on_update_icon()
	. = ..()
	icon_state = "rcd"
	if(delay < 10)
		icon_state += "_shortest"
		return ..()
	if (delay < 20)
		icon_state += "_shorter"
		return ..()
	if (delay < 37)
		icon_state += "_short"
		return ..()
	if(status == RCD_DECONSTRUCT)
		icon_state += "_reverse"

/obj/effect/constructing_effect/proc/end_animation()
	if(status == RCD_DECONSTRUCT)
		qdel_self()
	else
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		icon_state = "rcd_end"
		set_next_think(world.time + 1.5 SECONDS)

/obj/effect/constructing_effect/think()
	qdel_self()

/obj/effect/constructing_effect/proc/attacked(mob/user)
	playsound(loc, 'sound/weapons/egloves.ogg', vol = 80, vary = TRUE)
	qdel_self()

/obj/effect/constructing_effect/attackby(obj/item/weapon, mob/user, params)
	attacked(user)

/obj/effect/constructing_effect/attack_hand(mob/living/user, list/modifiers)
	attacked(user)
