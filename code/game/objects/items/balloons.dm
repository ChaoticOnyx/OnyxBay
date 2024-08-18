
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
	w_class = ITEM_SIZE_SMALL
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
	set_next_think(world.time + 1 MINUTE)

/obj/item/balloon_box/think()
	if(charges >= max_charges)
		return

	charges++
	set_next_think(world.time + 1 MINUTE)


/obj/item/balloon_flat
	name = "balloon"
	desc = "Still flat-n-sad."
	icon = 'icons/obj/balloons.dmi'
	icon_state = "deflat"
	item_state = "balloon_deflat"
	force = 0.0
	throwforce = 0.0
	w_class = ITEM_SIZE_TINY
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
		balloon_choices[temp_balloon.type_desc] = list(entry, temp_balloon.balloon_type)
		qdel(temp_balloon)
	balloon_choices["Cancel"] = null

#define PICK_RANDOM_BALLOON(a) \
	var/list/sanitized_balloons = balloon_choices.Copy();\
	sanitized_balloons.Remove("Random", "Cancel");\
	a = sanitized_balloons[pick(sanitized_balloons)][1];

/obj/item/balloon_flat/attack_self(mob/living/user)
	if(!user.client)
		return

	if(!isturf(user.loc))
		return

	var/choice = "Random"
	if(user.mind?.assigned_role && (user.mind.assigned_role == "Mime"))
		var/balloon_choice = input("What should I do with this balloon?", "Select desired shape.") in balloon_choices
		if(QDELETED(src))
			return
		if(!isturf(user.loc))
			return
		if(loc != user)
			return
		if(balloon_choice == "Random")
			PICK_RANDOM_BALLOON(choice)
		else if(choice == "Cancel")
			return
		else
			choice = balloon_choices[balloon_choice][1]
	else
		var/list/boring_balloons = list()
		for(var/entry in balloon_choices)
			if(islist(balloon_choices[entry]) && balloon_choices[entry][2] == BALLOON_NORMAL)
				boring_balloons[entry] = balloon_choices[entry]
		choice = boring_balloons[pick(boring_balloons)][1]

	to_chat(user, SPAN("notice", "You inflate a balloon!"))

	var/obj/item/balloon/B = new choice(get_turf(user))
	B.color = color
	B.update_icon()
	transfer_fingerprints_to(B)
	B.add_fingerprint(user)
	qdel_self()
	return

#undef PICK_RANDOM_BALLOON

/obj/item/balloon
	name = "balloon"
	desc = "It's a... Balloon, right?"
	icon = 'icons/obj/balloons.dmi'
	icon_state = ""
	item_state = null
	layer = BASE_HUMAN_LAYER
	force = 0.00001
	throwforce = 0.0
	throw_range = 2
	w_class = ITEM_SIZE_HUGE
	var/type_desc = ""
	var/wielded = FALSE
	var/wieldable = FALSE
	var/wielded_item_state
	var/base_item_state
	var/balloon_type = BALLOON_FORBIDDEN

	drop_sound = SFX_DROP_RUBBER
	pickup_sound = SFX_PICKUP_RUBBER

/obj/item/balloon/Initialize()
	. = ..()
	base_item_state = item_state
	item_state = item_state ? item_state : "balloon_[icon_state]"
	update_icon()

/obj/item/balloon/on_update_icon()
	if(!wieldable)
		return
	var/new_item_state
	if(wielded_item_state)
		new_item_state = wielded ? wielded_item_state : initial(item_state)
	else
		new_item_state = "[base_item_state][wielded]"
	item_state_slots[slot_l_hand_str] = new_item_state
	item_state_slots[slot_r_hand_str] = new_item_state

/obj/item/balloon/update_twohanding()
	if(!wieldable)
		return ..()
	var/mob/living/M = loc
	if(istype(M) && M.can_wield_item(src) && is_held_twohanded(M))
		wielded = TRUE
		improper_held_icon = TRUE
	else
		wielded = FALSE
		improper_held_icon = FALSE
	update_icon()
	..()

/obj/item/balloon/bullet_act(obj/item/projectile/Proj)
	burst()
	return PROJECTILE_CONTINUE

/obj/item/balloon/ex_act(severity)
	burst()

/obj/item/balloon/attackby(obj/item/W, mob/user)
	if(W.can_puncture())
		..()
		visible_message(SPAN("danger", "[user] pops [src] with [W]!"))
		burst()
	return

/obj/item/balloon/proc/burst()
	if(balloon_type == BALLOON_BURST)
		return
	balloon_type = BALLOON_BURST
	name = "burst balloon"
	desc = "Ow... Not much can be done with this now."
	icon_state = "burst"
	item_state = null
	force = 0.0
	throwforce = 0.0
	throw_range = 7
	w_class = ITEM_SIZE_TINY
	layer = BELOW_TABLE_LAYER

	item_icons = list()
	update_held_icon()

	playsound(get_turf(src), 'sound/effects/snap.ogg', 100, 1)

/obj/item/balloon/verb/deflate()
	set name = "Deflate"
	set category = "Object"
	set src in oview(1)

	if(isobserver(usr) || usr.restrained() || !usr.Adjacent(src) || !isturf(loc))
		return FALSE

	verbs -= /obj/item/balloon/verb/deflate
	playsound(loc, 'sound/machines/hiss.ogg', 50, 1)
	var/obj/item/balloon_flat/BF = new /obj/item/balloon_flat(loc)
	BF.color = color
	qdel_self()
	return TRUE


/obj/item/balloon/normal
	name = "balloon"
	desc = "It's a balloon!"
	icon_state = "normal"
	type_desc = "Normal"
	balloon_type = BALLOON_NORMAL

/obj/item/balloon/normal/narrow
	desc = "It's a narrow balloon!"
	icon_state = "narrow"
	type_desc = "Normal (Narrow)"

/obj/item/balloon/normal/wide
	desc = "It's a wide balloon!"
	icon_state = "wide"
	type_desc = "Normal (Wide)"

/obj/item/balloon/normal/star
	desc = "It's a star-shaped balloon!"
	icon_state = "star"
	type_desc = "Normal (Star)"

/obj/item/balloon/normal/heart
	desc = "It's a heart-shaped balloon. How lovely!"
	icon_state = "heart"
	type_desc = "Normal (Heart)"

/obj/item/balloon/normal/ring
	desc = "It's a ring-shaped balloon. Or is it donut-shaped?"
	icon_state = "ring"
	type_desc = "Normal (Ring)"

/obj/item/balloon/normal/Square
	desc = "It's a square balloon. How's that even possible?"
	icon_state = "square"
	type_desc = "Normal (Square)"
	balloon_type = BALLOON_ADVANCED

/obj/item/balloon/animal
	name = "animal balloon"
	desc = "It's an... Inflatable animal?"
	balloon_type = BALLOON_FORBIDDEN

/obj/item/balloon/animal/crab
	desc = "It's an inflatable crab!"
	icon_state = "crab"
	type_desc = "Animal (Crab)"
	balloon_type = BALLOON_ADVANCED

/obj/item/balloon/animal/corgi
	desc = "It's an inflatable corgi! HoP's favourite!"
	icon_state = "corgi"
	type_desc = "Animal (Corgi)"
	balloon_type = BALLOON_ADVANCED

/obj/item/balloon/animal/cat
	desc = "It's an inflatable cat! CMO's favourite!"
	icon_state = "cat"
	type_desc = "Animal (Cat)"
	balloon_type = BALLOON_ADVANCED

/obj/item/balloon/animal/mouse
	desc = "It's an inflatable mouse! Hope it doesn't bite your foot."
	icon_state = "mouse"
	type_desc = "Animal (Mouse)"
	balloon_type = BALLOON_ADVANCED

/obj/item/balloon/animal/carp
	desc = "It's an inflatable carp! Hope it doesn't knock you down."
	icon_state = "carp"
	type_desc = "Animal (Carp)"
	balloon_type = BALLOON_ADVANCED

/obj/item/balloon/animal/pig
	desc = "It's an inflatable pig! Does it even oink?.."
	icon_state = "pig"
	type_desc = "Animal (Pig)"
	balloon_type = BALLOON_ADVANCED

/obj/item/balloon/item
	name = "inflatable item"
	desc = "It's an... Item-shaped balloon?"
	layer = ABOVE_STRUCTURE_LAYER
	w_class = ITEM_SIZE_NORMAL
	balloon_type = BALLOON_FORBIDDEN
	throw_range = 5

/obj/item/balloon/item/stunbaton
	name = "stunbaton"
	desc = "It's an inflatable stunbaton! Not that great for incapacitating people with."
	icon_state = "stunbaton"
	item_state = "baton"
	type_desc = "Item (Stunbaton)"
	balloon_type = BALLOON_FAKE_ITEM

/obj/item/balloon/item/sword
	name = "claymore"
	desc = "It's an inflatable sword! What are you standing around staring at this for? Get to pranking!"
	icon_state = "claymore"
	item_state = "claymore"
	type_desc = "Item (Claymore)"
	balloon_type = BALLOON_FAKE_ITEM

/obj/item/balloon/item/fireaxe
	name = "fireaxe"
	desc = "It's an inflatable axe! Truly, the balloon of a madman."
	icon_state = "fireaxe"
	item_state = "fireaxe"
	type_desc = "Item (Fireaxe)"
	balloon_type = BALLOON_FAKE_ITEM
	wieldable = TRUE

/obj/item/balloon/item/extinguisher
	name = "fire extinguisher"
	desc = "It's an inflatable fire extinguisher!"
	icon_state = "extinguisher"
	item_state = "fire_extinguisher"
	type_desc = "Item (Extinguisher)"
	balloon_type = BALLOON_FAKE_ITEM

/obj/item/balloon/item/gun
	balloon_type = BALLOON_FORBIDDEN
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_guns.dmi',
		)

/obj/item/balloon/item/gun/revolver
	name = "revolver"
	desc = "The Lumoco Arms HE Colt is a choice balloon for when you absolutely, positively need to prank another guy."
	icon_state = "revolver"
	item_state = "revolver"
	type_desc = "Item (Revolver)"
	balloon_type = BALLOON_FAKE_ITEM

/obj/item/balloon/item/gun/shotgun
	name = "shotgun"
	desc = "The Lumoco Arms HE Colt is a choice balloon for when you absolutely, positively need to prank another guy."
	icon_state = "shotgun"
	item_state = "shotgun"
	wielded_item_state = "shotgun-wielded"
	type_desc = "Item (Shotgun)"
	balloon_type = BALLOON_FAKE_ITEM
	wieldable = TRUE


/obj/item/balloon/burst
	name = "burst balloon"
	desc = "Ow... Not much can be done with this now."
	icon_state = "burst"
	force = 0.0
	throwforce = 0.0
	throw_range = 7
	w_class = ITEM_SIZE_TINY
	layer = BELOW_TABLE_LAYER
	balloon_type = BALLOON_BURST

#undef BALLOON_FORBIDDEN
#undef BALLOON_NORMAL
#undef BALLOON_ADVANCED
#undef BALLOON_FAKE_ITEM
#undef BALLOON_BURST
#undef BALLOON_COLORS
