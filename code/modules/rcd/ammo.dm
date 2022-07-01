/obj/item/rcd_ammo
	name = "compressed matter cartridge"
	desc = "A highly-compressed matter cartridge usable in rapid construction (and deconstruction) devices, such as railguns."

	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"

	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 2)
	matter = list(MATERIAL_STEEL = 15000, MATERIAL_GLASS = 7500)

	var/remaining = 10

/obj/item/rcd_ammo/_examine_text(mob/user)
	. = ..()

	if(get_dist(src, user) <= 1)
		. += "\n" + SPAN("notice", "It has [remaining] unit\s of matter left.")

/obj/item/rcd_ammo/large
	name = "high-capacity matter cartridge"
	desc = "Do not ingest."
	matter = list(MATERIAL_STEEL = 45000, MATERIAL_GLASS = 22500)
	remaining = 30
	origin_tech = list(TECH_MATERIAL = 4)
