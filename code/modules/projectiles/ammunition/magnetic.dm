/obj/item/magnetic_ammo
	name = "flechette magazine"
	desc = "A magazine containing steel flechettes."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "5.56"
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 1800)
	origin_tech = list(TECH_COMBAT = 1)
	var/remaining = 9

/obj/item/magnetic_ammo/ex_act(severity)
	. = ..()
	. += "There [(remaining == 1)? "is" : "are"] [remaining] flechette\s left!"
