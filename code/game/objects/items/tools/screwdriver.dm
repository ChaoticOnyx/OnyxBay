
/*
 * Screwdriver
 */
/obj/item/screwdriver
	name = "screwdriver"
	desc = "Your archetypal flathead screwdriver, with a nice, heavy polymer handle."
	description_info = "This tool is used to expose or safely hide away cabling. It can open and shut the maintenance panels on vending machines, airlocks, and much more. You can also use it, in combination with a crowbar, to install or remove windows."
	description_fluff = "Screws have not changed significantly in centuries, and neither have the drivers used to install and remove them."
	description_antag = "In the world of breaking and entering, tools like multitools and wirecutters are the bread; the screwdriver is the butter. In a pinch, try targetting someone's eyes and stabbing them with it - it'll really hurt!"
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT | SLOT_EARS
	sharp = 1
	force = 7.5
	w_class = ITEM_SIZE_TINY
	mod_weight = 0.35
	mod_reach = 0.3
	mod_handy = 1.0
	armor_penetration = 40
	throwforce = 5.0
	throw_range = 5
	matter = list(MATERIAL_STEEL = 75)
	attack_verb = list("stabbed")
	lock_picking_level = 5
	hitsound = 'sound/weapons/bladeslice.ogg'
	tool_behaviour = TOOL_SCREWDRIVER
	var/randicon = TRUE

	can_get_wet = FALSE
	can_be_wrung_out = FALSE

	drop_sound = SFX_DROP_SCREWDRIVER
	pickup_sound = SFX_PICKUP_SCREWDRIVER

/obj/item/screwdriver/Initialize()
	if(randicon)
		switch(pick("red", "blue", "purple", "brown", "green", "cyan", "yellow"))
			if("red")
				icon_state = "screwdriver2"
				item_state = "screwdriver"
			if("blue")
				icon_state = "screwdriver"
				item_state = "screwdriver_blue"
			if("purple")
				icon_state = "screwdriver3"
				item_state = "screwdriver_purple"
			if("brown")
				icon_state = "screwdriver4"
				item_state = "screwdriver_brown"
			if("green")
				icon_state = "screwdriver5"
				item_state = "screwdriver_green"
			if("cyan")
				icon_state = "screwdriver6"
				item_state = "screwdriver_cyan"
			if("yellow")
				icon_state = "screwdriver7"
				item_state = "screwdriver_yellow"

	if(prob(75))
		pixel_y = rand(0, 16)
	. = ..()
	update_icon()

/obj/item/screwdriver/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M) || user.a_intent == "help")
		return ..()
	if(is_pacifist(user))
		to_chat(user, SPAN("warning", "You can't you're pacifist!"))
		return
	if(user.zone_sel.selecting != BP_EYES)
		return ..()
	if(istype(user.l_hand,/obj/item/grab) || istype(user.r_hand,/obj/item/grab))
		return ..()
	if((MUTATION_CLUMSY in user.mutations) && prob(50))
		M = user
	return eyestab(M,user)

/obj/item/screwdriver/pickup(mob/user)
	..()
	update_icon()

/obj/item/screwdriver/dropped(mob/user)
	..()
	update_icon()

/obj/item/screwdriver/attack_hand()
	..()
	update_icon()

/obj/item/screwdriver/on_enter_storage(obj/item/storage/S)
	..()
	update_icon()

/obj/item/screwdriver/on_update_icon()
	SetTransform(rotation = istype(loc, /obj/item/storage) ? -90 : 0)

/obj/item/screwdriver/old
	name = "old screwdriver"
	desc = "Old-school flathead screwdriver made of plasteel, with a sturdy and heavy duraplastic handle."
	icon_state = "legacyscrewdriver"
	item_state = "screwdriver"
	force = 8.5
	mod_weight = 0.4
	mod_reach = 0.3
	mod_handy = 1.1
	armor_penetration = 50
	throwforce = 6.0
	matter = list(MATERIAL_PLASTEEL = 75)
	attack_verb = list("stabbed", "screwed", "unscrewed")
	randicon = FALSE
