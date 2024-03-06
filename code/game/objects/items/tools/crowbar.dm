
/*
 * Crowbar
 */

/obj/item/crowbar
	name = "crowbar"
	desc = "A heavy crowbar of solid steel, good and solid in your hand."
	description_info = "Crowbars have countless uses: click on floor tiles to pry them loose. Use alongside a screwdriver to install or remove windows. Force open emergency shutters, or depowered airlocks. Open the panel of an unlocked APC. Pry a computer's circuit board free. And much more!"
	description_fluff = "As is the case with most standard-issue tools, crowbars are a simple and timeless design, the only difference being that advanced materials like plasteel have made them uncommonly tough."
	description_antag = "Need to bypass a bolted door? You can use a crowbar to pry the electronics out of an airlock, provided that it has no power and has been welded shut."
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	force = 10.0
	throwforce = 7.0
	throw_range = 3
	item_state = "crowbar"
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.0
	mod_reach = 1.0
	mod_handy = 1.0
	armor_penetration = 10
	origin_tech = list(TECH_ENGINEERING = 1)
	matter = list(MATERIAL_STEEL = 140)
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	tool_behaviour = TOOL_CROWBAR

	drop_sound = SFX_DROP_CROWBAR
	pickup_sound = SFX_PICKUP_CROWBAR

/obj/item/crowbar/red
	desc = "A heavy crowbar of solid steel, good and solid in your hand. The red paint gives it a truly robust look."
	icon_state = "red_crowbar"
	item_state = "crowbar_red"
	armor_penetration = 20 // Red smakks betta

/obj/item/crowbar/prybar
	name = "pry bar"
	desc = "A steel bar with a wedge. It comes in a variety of configurations - collect them all."
	icon_state = "prybar"
	item_state = "crowbar"
	force = 7.5
	throwforce = 6.0
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.75
	mod_reach = 0.75
	mod_handy = 1.0
	armor_penetration = 0 // Smol smakks bettan't
	matter = list(MATERIAL_STEEL = 80)

/obj/item/crowbar/prybar/Initialize()
	icon_state = "prybar[pick("","_red","_green","_aubergine","_blue")]"
	. = ..()

/obj/item/crowbar/emergency
	name = "emergency bar"
	desc = "A plastic bar with a wedge. Kind of awkward and widdly, yet it may save your life one day."
	icon_state = "emergbar"
	item_state = "crowbar_emerg"
	force = 6.0
	throwforce = 5.0
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.6
	mod_reach = 0.75
	mod_handy = 0.8
	armor_penetration = 0
	matter = list(MATERIAL_PLASTIC = 80)

/obj/item/crowbar/emergency/vox
	icon_state = "emergbar_vox"

/obj/item/crowbar/emergency/eng
	icon_state = "emergbar_eng"

/obj/item/crowbar/emergency/sec
	icon_state = "emergbar_sec"

// MAINTENANCE JACK - Allows removing of braces with certain delay.
/obj/item/crowbar/brace_jack
	name = "maintenance jack"
	desc = "A special crowbar that can be used to safely remove airlock braces from airlocks."
	icon_state = "maintenance_jack"
	force = 13
	mod_weight = 1.25
	armor_penetration = 30 // A poor man's lucerne
	throwforce = 12
	w_class = ITEM_SIZE_NORMAL
