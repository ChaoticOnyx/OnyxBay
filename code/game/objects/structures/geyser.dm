/obj/structure/geyser
	name = "geyser"
	icon = 'icons/obj/geyser.dmi'
	icon_state = "geyser"
	anchored = TRUE

	/// Set to null to get it greyscaled from "[icon_state]_soup". Not very usable with the whole random thing, but more types can be added if you change the spawn prob
	var/erupting_state = null
	/// Whether we are active and generating chems
	var/activated = FALSE
	var/reagent_id = /datum/reagent/fuel
	/// How much reagents we add every think() (5 seconds wait)
	var/potency = 2
	var/max_volume = 500
	var/start_volume = 50

/obj/structure/geyser/proc/start_chemming()
	activated = TRUE
	reagents.add_reagent(reagent_id, start_volume)
	set_next_think(world.time + 5 SECONDS)
	if(erupting_state)
		icon_state = erupting_state
	else
		var/mutable_appearance/I = mutable_appearance(icon, "[icon_state]_soup")
		//I.color = mix_color_from_reagents(reagents.reagent_list)
		AddOverlays(I)

/obj/structure/geyser/think()
 	//this is also evaluated in add_reagent, but from my understanding proc calls are expensive
	if(activated && reagents.total_volume <= reagents.maximum_volume)
		reagents.add_reagent(reagent_id, potency)
		set_next_think(world.time + 5 SECONDS)

/obj/structure/geyser/attack_hand(mob/user)
	if(activated)
		show_splash_text(user, "Already active!", SPAN_WARNING("\The [src] is already active!"))
		return

	show_splash_text(user, "Plunged!", SPAN_NOTICE("You start vigorously plunging \the [src]!"))
	if(!do_after(user, 5 SECONDS, target = src) && !activated)
		return

	if(QDELETED(src))
		return

	start_chemming()

	return ..()

/obj/structure/geyser/random
	erupting_state = null
	var/list/options = list(/datum/reagent/toxin/plasma = 10, /datum/reagent/water = 10, /datum/reagent/toxin/chlorine = 6)

/obj/structure/geyser/random/Initialize()
	. = ..()
	reagent_id = util_pick_weight(options)
