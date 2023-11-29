
#define BALLOON_FORBIDDEN 0
#define BALLOON_NORMAL 1
#define BALLOON_ADVANCED 2
#define BALLOON_FAKE_ITEM 3
#define BALLOON_BURST 4
#define BALLOON_COLORS list("#FF0000", "#FF6A00", "#FFD800", "#B6FF00", "#00FF21", "#00FFFF", "#0094FF", "#FF00DC", "#FF006E", "#FF93B4", "#FFFFFF", "#727272")

/obj/item/balloon_box
	name = "Box`o`Balloons"
	desc = "Endless source of inflatable fun!"
	icon = 'icons/obj/balloons.dmi'
	icon_state = "box"
	var/charges = 10
	var/max_charges = 10

/obj/item/balloon_box/attack_self(mob/living/user)
	add_fingerprint(user)
	if(!charges)
		to_chat(user, SPAN("notice", "You do your best to find something in \the [src], but you ultimately fail..."))
		return

	charges--
	var/obj/item/balloon_flat/new_balloon = new
	user.pick_or_drop(new_balloon)
	to_chat(user, SPAN("notice", "You take a new [new_balloon] outta \the [src]!"))
	set_next_think(world.time + 30 SECONDS)

/obj/item/balloon_box/think()
	if(charges >= max_charges)
		return

	charges++
	set_next_think(world.time + 30 SECONDS)


/obj/item/balloon_flat
	name = "balloon"
	desc = "Still flat-n-sad."
	icon = 'icons/obj/balloons.dmi'
	icon_state = "balloon_deflat"
	force = 0.0
	throw_force = 0.0
	var/static/balloon_choices_generated = FALSE
	var/static/list/balloon_choices

/obj/item/balloon_flat/Initialize()
	. = ..()
	color = pick(BALLOON_COLORS)
	if(!balloon_choices_generated)
		balloon_choices_generated = TRUE
		generate_balloon_choices()

/obj/item/balloon_flat/proc/generate_balloon_choices()
	balloon_choices = list()
	balloon_choices["Random"] = null
	for(var/entry in subtypesof(/obj/item/balloon))
		var/obj/item/balloon/temp_balloon = new entry
		if(temp_balloon.balloon_type == BALLOON_FORBIDDEN || temp_balloon.balloon_type == BALLOON_BURST)
			continue
		balloon_choices[temp_balloon.name] = list(entry, balloon_type)
		qdel(temp_balloon)
	balloon_choices["Cancel"] = null

/obj/item/balloon_flat/attack_self(mob/living/user)
	if(!user.client)
		return

	var/choice = "Random"
	if(user.mind?.assigned_role && (user.mind.assigned_role in job_specific))
		var/balloon_choice = input("What should I do with this balloon?", "Select desired shape.") in balloon_choices)
		if(balloon_choice = "Random")
			var/list/sanitized_balloons = balloon_choices.copy()
			sanitized_balloons.Remove("Random", "Cancel")
			choice = pick(sanitized_balloons)[1]
		else if(choice == "Cancel")
			return
		else
			choice = balloon_choice
	else
		var/list/boring_balloons = balloon_choices.copy()
		for(var/entry in balloon_choices)
			if(islist(balloon_choices[entry]) && balloon_choices[entry][2] != BALLOON_NORMAL)
				boring_balloons[entry] = balloon_choices[entry]
		choice = pick(boring_balloons)[1]

	if(direction == "Cancel")
		fastening = 0
		return

/obj/item/balloon
	name = "balloon"
	desc = "It's a balloon!"
	icon = 'icons/obj/balloons.dmi'
	icon_state = "balloon_deflat"
	force = 0.0
	throw_force = 0.0
	var/wielded_icon_state = ""
	var/balloon_type = BALLOON_FORBIDDEN

/obj/item/balloon/Initialize()
	. = ..()
	update_icon()

/obj/item/balloon/on_update_icon()
	var/new_item_state = "[base_icon][wielded]"
	item_state_slots[slot_l_hand_str] = new_item_state
	item_state_slots[slot_r_hand_str] = new_item_state

/obj/item/balloon/update_twohanding()
	if(!wielded_icon_state)
		return
	update_icon()
	..()

#undef BALLOON_NORMAL
#undef BALLOON_FAKE_ITEM
#undef BALLOON_BURST
#undef BALLOON_COLORS
