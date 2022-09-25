#define JAWS_CROWBAR "crowbar"
#define JAWS_CUTTERS "wirecutters"

/obj/item/combotool/jaws_of_life
	name = "jaws of life"
	desc = ""
	description_info = ""
	description_fluff = ""
	description_antag = ""
	icon = 'icons/obj/tools.dmi'
	icon_state = "jaws"
	item_state = "jaws"
	w_class = ITEM_SIZE_LARGE // This thing is kinda big and can't fit in small storages. - Max
	item_flags = ITEM_FLAG_IS_BELT
	matter = list(MATERIAL_STEEL = 100, MATERIAL_GLASS = 50)
	origin_tech = list(TECH_ENGINEERING = 4, TECH_MAGNET = 3)
	var/obj/item/wirecutters/wirecutters = null
	var/obj/item/crowbar/crowbar = null

/obj/item/combotool/jaws_of_life/update_icon()
	icon_state = initial(icon_state)
	if(tool_c == JAWS_CROWBAR)
		icon_state = "[initial(icon_state)]-on"

/obj/item/combotool/jaws_of_life/Initialize()
	. = ..()
	wirecutters = new(src)
	crowbar = new(src)
	tool_c = JAWS_CUTTERS
	tool_u = wirecutters

/obj/item/combotool/jaws_of_life/attack_self(mob/user)
	playsound(loc, 'sound/items/jaws_pry.ogg', 50, 1)
	..()

/obj/item/combotool/jaws_of_life/switchtools()
	tool_c = tool_c == JAWS_CUTTERS ? JAWS_CROWBAR : JAWS_CUTTERS
	tool_u = tool_u == wirecutters ? crowbar : wirecutters
	update_icon()
	return

/obj/item/combotool/jaws_of_life/sindi
	desc = "It looks kinda SUS."
	icon_state = "jaws_sindi"
	item_state = "jaws_sindi"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_MAGNET = 3, TECH_ILLEGAL = 2)

#undef JAWS_CROWBAR
#undef JAWS_CUTTERS
