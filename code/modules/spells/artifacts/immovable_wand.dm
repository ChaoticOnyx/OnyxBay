
#define IW_WAND   "wand"
#define IW_RACKET "racket"
#define IW_BAT    "bat"
#define IW_BALL   "basketball"

/obj/item/immovable_wand
	name = "immovable wand"
	desc = "It looks like a regular metal rod, but appears to be insanely heavy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "immovable_wand"
	w_class = ITEM_SIZE_SMALL
	anchored = TRUE
	throw_range = 5
	force = 10.0
	throwforce = 10.0
	mod_weight = 1.5
	mod_reach = 0.5
	mod_handy = 1.5
	unacidable = TRUE

	var/current_shape = IW_WAND

	var/static/radial_wand   = image(icon = 'icons/obj/wizard.dmi', icon_state = "immovable_wand")
	var/static/radial_racket = image(icon = 'icons/obj/wizard.dmi', icon_state = "immovable_racket")
	var/static/radial_bat    = image(icon = 'icons/obj/wizard.dmi', icon_state = "immovable_bat")
	var/static/radial_ball   = image(icon = 'icons/obj/wizard.dmi', icon_state = "immovable_ball")
	var/static/list/radial_options = list(
		IW_WAND   = radial_wand,
		IW_RACKET = radial_racket,
		IW_BAT    = radial_bat,
		IW_BALL   = radial_ball
	)

/obj/item/immovable_wand/dropped(mob/user)
	..()
	set_next_think(world.time + 1 SECOND)

/obj/item/immovable_wand/attack_hand(mob/user)
	if(ishuman(user))
		if((MUTATION_HULK in user.mutations) || (MUTATION_STRONG in user.mutations))
			anchored = FALSE
			..()
		else
			to_chat(user, SPAN("warning", "\The [src] appears to be glued to the time-space itself!"))
		return

	..()

/obj/item/immovable_wand/attack_self(mob/user)
	if((MUTATION_HULK in user.mutations) || (MUTATION_STRONG in user.mutations))
		var/choice = show_radial_menu(user, user, radial_options, require_near = TRUE)
		if(choice)
			user.visible_message("<b>[user]</b> bends and reshapes \the [src] with their bare hands!")
			reshape(choice)
		return

	return ..()

/obj/item/immovable_wand/throw_impact(hit_atom, speed)
	. = ..()
	var/pwn_chance = current_shape == IW_BALL ? 100 : 50
	if(isliving(hit_atom) && prob(pwn_chance))
		var/mob/living/L = hit_atom
		playsound(L.loc, 'sound/effects/bang.ogg', 50, 1, -1)
		L.Weaken(10)

// So we can throw it
/obj/item/immovable_wand/think()
	if(isturf(loc))
		anchored = TRUE

/obj/item/immovable_wand/proc/reshape(new_shape)
	SetName("immovable [new_shape]")
	current_shape = new_shape

	switch(new_shape)
		if(IW_WAND)
			throw_range = 5
			force = 10.0
			throwforce = 10.0
			mod_weight = 1.5
			mod_reach = 0.5
			mod_handy = 1.5
			mod_shield = 1.0
			block_tier = BLOCK_TIER_MELEE
			w_class = ITEM_SIZE_SMALL
			desc = "It looks like a regular metal rod, but appears to be insanely heavy."
			icon_state = "immovable_wand"
		if(IW_RACKET)
			throw_range = 5
			force = 10.0
			throwforce = 10.0
			mod_weight = 1.5
			mod_reach = 0.8
			mod_handy = 1.5
			mod_shield = 3.0
			block_tier = BLOCK_TIER_ADVANCED
			w_class = ITEM_SIZE_LARGE
			desc = "It looks like a tennis racket made of solid metal. It appears to be insanely heavy."
			icon_state = "immovable_racket"
		if(IW_BAT)
			throw_range = 5
			force = 20.0
			throwforce = 10.0
			mod_weight = 2.0
			mod_reach = 1.0
			mod_handy = 1.5
			mod_shield = 1.5
			block_tier = BLOCK_TIER_MELEE
			w_class = ITEM_SIZE_LARGE
			desc = "It looks like a baseball bat made of some sort of metal. It appears to be insanely heavy."
			icon_state = "immovable_bat"
		if(IW_BALL)
			throw_range = 20
			force = 10.0
			throwforce = 25.0
			mod_weight = 1.5
			mod_reach = 0.5
			mod_handy = 0.5
			mod_shield = 1.0
			block_tier = BLOCK_TIER_MELEE
			w_class = ITEM_SIZE_LARGE
			desc = "It looks like a basketball made entirely of metal. It appears to be insanely heavy."
			icon_state = "immovable_ball"

	update_held_icon()
	return


#undef IW_WAND
#undef IW_RACKET
#undef IW_BAT
#undef IW_BALL
