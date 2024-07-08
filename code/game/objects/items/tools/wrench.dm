
/*
 * Wrench
 */
/obj/item/wrench
	name = "wrench"
	desc = "A good, durable combination wrench, with self-adjusting, universal open- and ring-end mechanisms to match a wide variety of nuts and bolts."
	description_info = "This versatile tool is used for dismantling machine frames, anchoring or unanchoring heavy objects like vending machines and emitters, and much more. In general, if you want something to move or stop moving entirely, you ought to use a wrench on it."
	description_fluff = "The classic open-end wrench (or spanner, if you prefer) hasn't changed significantly in shape in over 500 years, though these days they employ a bit of automated trickery to match various bolt sizes and configurations."
	description_antag = "Not only is this handy tool good for making off with machines, but it even makes a weapon in a pinch!"
	icon = 'icons/obj/tools.dmi'
	icon_state = "wrench"
	item_state = "wrench"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	force = 8.5
	throwforce = 7.0
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.8
	mod_reach = 0.75
	mod_handy = 1.0
	origin_tech = list(TECH_MATERIAL = 1, TECH_ENGINEERING = 1)
	matter = list(MATERIAL_STEEL = 150)
	center_of_mass = "x=17;y=16"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")
	tool_behaviour = TOOL_WRENCH
	var/randicon = TRUE
	can_get_wet = FALSE
	can_be_wrung_out = FALSE
	drop_sound = SFX_DROP_WRENCH
	pickup_sound = SFX_PICKUP_WRENCH

/obj/item/wrench/Initialize()
	if(randicon)
		icon_state = "wrench[pick("","_red","_black")]"
	. = ..()

/obj/item/wrench/plain
	icon_state = "wrench"
	randicon = FALSE

/obj/item/wrench/red
	icon_state = "wrench_red"
	randicon = FALSE

/obj/item/wrench/black
	icon_state = "wrench_black"
	randicon = FALSE

/obj/item/wrench/old
	name = "old wrench"
	desc = "It wrenches. It unwrenches. But more importantly, it's old as hell."
	icon_state = "legacywrench"
	center_of_mass = "x=16;y=16"
	matter = list(MATERIAL_PLASTEEL = 150)
	force = 9.5
	throwforce = 7.5
	mod_weight = 0.85
	mod_reach = 0.75
	mod_handy = 1.1
	randicon = FALSE
