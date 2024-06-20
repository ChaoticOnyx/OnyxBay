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

/obj/item/clothing/shoes/heels/equipped(mob/user, slot)
	. = ..()

	if(slot_flags & slot)
		return

	trip_chance = 0

#define TRIP_CHANCE_INCREASE 0.5

/obj/item/clothing/shoes/heels/handle_movement(turf/walking, running)
	if(running)
		playsound(src, SFX_HEELS, 40, 1)
	else
		playsound(src, SFX_HEELS, 20, 1)
	if(!can_trip())
		trip_chance = 0
		return

	trip_chance += TRIP_CHANCE_INCREASE

	if(!prob(trip_chance))
		return

	trip_chance = 0

	var/mob/living/wearer = loc
	if(!istype(wearer))
		return

	wearer.stun_effect_act(2, rand(10, 15), pick(BP_FEET), src)
	visible_message("<b>[wearer]</b> trips!", SPAN_WARNING("You trip!"))

#undef TRIP_CHANCE_INCREASE

/obj/item/clothing/shoes/heels/proc/can_trip()
	PRIVATE_PROC(TRUE)

	var/area/area = get_area(loc)
	if(!area?.has_gravity)
		return FALSE

	var/mob/wearing = loc
	if(!istype(wearing))
		return FALSE

	var/turf/walking = get_turf(loc)
	var/datum/species/wearing_species = all_species[wearing.get_species()]

	if(wearing?.cached_slowdown >= wearing_species.walk_speed_perc * config.movement.walk_speed && !istype(walking, /turf/simulated/floor/plating))
		return FALSE

	return TRUE
