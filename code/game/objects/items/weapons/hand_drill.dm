#define DRILL_SCREW "screw"
#define DRILL_WRENCH "wrench"

/obj/item/combotool/hand_drill
	name = "hand drill"
	desc = ""
	description_info = ""
	description_fluff = ""
	description_antag = ""
	hitsound = 'sound/items/drill_hit.ogg'
	icon = 'icons/obj/tools.dmi'
	icon_state = "drill"
	sharp = TRUE
	item_flags = ITEM_FLAG_IS_BELT
	matter = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50)
	origin_tech = list(TECH_ENGINEERING = 4, TECH_MAGNET = 3)
	var/obj/item/screwdriver/screwdriver = null
	var/obj/item/wrench/wrench = null

/obj/item/combotool/hand_drill/update_icon()
	icon_state = initial(icon_state)
	if(tool_c == DRILL_WRENCH)
		icon_state = "[initial(icon_state)]-on"

/obj/item/combotool/hand_drill/Initialize()
	. = ..()
	screwdriver = new(src)
	wrench = new(src)
	tool_c = DRILL_SCREW
	tool_u = screwdriver

/obj/item/combotool/hand_drill/attack_self(mob/user)
	playsound(loc, 'sound/items/drill_switch.ogg', 50, 1)
	..()

/obj/item/combotool/hand_drill/switchtools()
	tool_c = tool_c == DRILL_SCREW ? DRILL_WRENCH : DRILL_SCREW
	tool_u = tool_u == screwdriver ? wrench : screwdriver
	sharp = sharp ? FALSE : TRUE
	update_icon()
	return

/obj/item/combotool/hand_drill/sindi
	desc = "wzhzhzh"
	icon_state = "drill_sindi"

#undef DRILL_SCREW
#undef DRILL_WRENCH
