/obj/item/clothing/shoes/heels
	name = "Heels"
	desc = "Cheap, yet elegant, pair of female shoes. These are definitely made for walking tho."

	icon_state = "high_shoes_preview"
	base_icon_state = "high_shoes"
	color = COLOR_DARK_GRAY

	/// Accumulated trip chance, rolls every move*.
	var/trip_chance = 0

/obj/item/clothing/shoes/heels/on_update_icon()
	ClearOverlays()

	icon_state = base_icon_state

	AddOverlays(overlay_image(icon, "[base_icon_state]_overlay", flags = RESET_COLOR))

/obj/item/clothing/shoes/heels/Initialize()
	. = ..()

	update_icon()

#define TRIP_CHANCE_INCREASE 0.5

/obj/item/clothing/shoes/heels/handle_movement(turf/walking, running)
	if(!running && !istype(walking, /turf/simulated/floor/plating))
		return

	trip_chance += TRIP_CHANCE_INCREASE

	if(!prob(trip_chance))
		return

	trip_chance = 0

	var/mob/wearer = loc

	wearer.Stun(1)
	wearer.Weaken(2)

	visible_message("<b>[wearer]</b> trips!", SPAN_WARNING("You trip!"))

#undef TRIP_CHANCE_INCREASE
