/datum/map_template/ruin/exoplanet/monolith
	name = "Monolith Ring"
	id = "planetsite_monoliths"
	description = "Bunch of monoliths surrounding an artifact."
	suffixes = list("monoliths/monoliths.dmm")
	cost = 1
	template_flags = TEMPLATE_FLAG_NO_RUINS

/obj/structure/monolith
	name = "monolith"
	desc = "An obviously artifical structure of unknown origin. The symbols 'DWNbTX' are engraved on the base."
	icon = 'icons/obj/monolith.dmi'
	icon_state = "jaggy1"

	layer = ABOVE_HUMAN_LAYER
	density = 1
	anchored = 1
	var/active = 0

/obj/structure/monolith/Initialize()
	. = ..()
	icon_state = "jaggy[rand(1,4)]"
	var/material/A = get_material_by_name(MATERIAL_ALIUMIUM)
	if(A)
		color = A.icon_colour

/obj/structure/monolith/update_icon()
	overlays.Cut()
	if(active)
		var/image/I = image(icon,"[icon_state]decor")
		I.appearance_flags = RESET_COLOR
		I.color = get_random_colour(0, 150, 255)
		I.layer = ABOVE_LIGHTING_LAYER
		I.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		overlays += I
		set_light(0.4, 0.1, 2, 2, I.color)

/obj/structure/monolith/attack_hand(mob/user)
	visible_message("[user] touches \the [src].")
	to_chat(user, "<span class='notice'>\The [src] is still.</span>")
	return ..()

/turf/simulated/floor/misc/fixed/alium/ruin
	name = "ancient alien plating"
	desc = "This obviously wasn't made for your feet. Looks pretty old."
	initial_gas = null

/turf/simulated/floor/misc/fixed/alium/ruin/Initialize()
	. = ..()
	if(prob(10))
		ChangeTurf(get_base_turf_by_area(src))
