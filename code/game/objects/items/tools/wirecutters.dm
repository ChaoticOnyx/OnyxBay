
/*
 * Wirecutters
 */
/obj/item/wirecutters
	name = "wirecutters"
	desc = "A special pair of pliers with cutting edges. Various brackets and manipulators built into the handle allow it to repair severed wiring."
	description_info = "This tool will cut wiring anywhere you see it - make sure to wear insulated gloves! When used on more complicated machines or airlocks, it can not only cut cables, but repair them, as well."
	description_fluff = "With modern alloys, today's wirecutters can snap through cables of astonishing thickness."
	description_antag = "These cutters can be used to cripple the power anywhere on the ship. All it takes is some creativity, and being in the right place at the right time."
	icon = 'icons/obj/tools.dmi'
	icon_state = "cutters"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	sharp = 1
	force = 5.5
	throw_range = 9
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.45
	mod_reach = 0.3
	mod_handy = 0.75
	origin_tech = list(TECH_MATERIAL = 1, TECH_ENGINEERING = 1)
	matter = list(MATERIAL_STEEL = 80)
	center_of_mass = "x=18;y=16"
	attack_verb = list("pinched", "nipped")
	sharp = 1
	edge = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	tool_behaviour = TOOL_WIRECUTTER
	var/randicon = TRUE

	drop_sound = SFX_DROP_WIRECUTTER
	pickup_sound = SFX_PICKUP_WIRECUTTER

/obj/item/wirecutters/Initialize()
	if(randicon && prob(50))
		icon_state = "cutters-y"
		item_state = "cutters_yellow"
	. = ..()

/obj/item/wirecutters/attack(mob/living/carbon/C as mob, mob/user as mob)
	if(user.a_intent == I_HELP && (C.handcuffed) && (istype(C.handcuffed, /obj/item/handcuffs/cable)))
		usr.visible_message("\The [usr] cuts \the [C]'s restraints with \the [src]!",\
		"You cut \the [C]'s restraints with \the [src]!",\
		"You hear cable being cut.")
		C.handcuffed = null
		if(C.buckled && C.buckled.buckle_require_restraints)
			C.buckled.unbuckle_mob()
		C.update_inv_handcuffed()
		return
	else
		..()

/obj/item/wirecutters/old
	name = "old wirecutters"
	desc = "A very special pair of pliers with cutting edges. No excessive brackets and manipulators are needed to allow it to repair severed wiring."
	icon_state = "legacycutters"
	item_state = "cutters"
	force = 6.5
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.5
	mod_reach = 0.3
	mod_handy = 0.8
	matter = list(MATERIAL_PLASTEEL = 80)
	center_of_mass = "x=20;y=16"
	randicon = FALSE
