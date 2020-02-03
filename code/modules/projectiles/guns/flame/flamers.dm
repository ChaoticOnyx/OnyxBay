//for cargo delivery, official NT flamer
/obj/item/weapon/gun/flamer/NT
	name = "\improper NT flamethrower"
	desc = "NT style flamer"
	icon_state = "NT_flamer"

/obj/item/weapon/gun/flamer/NT/Initialize()
	. = ..()
	fuel_tank = new /obj/item/weapon/welder_tank/huge(src)
	preassure_tank = new /obj/item/weapon/tank/oxygen(src)
	igniter = new /obj/item/device/assembly/igniter(src)
	gauge = new /obj/item/device/analyzer(src)
	update_icon()
	return

//for syndicate event flamer
/obj/item/weapon/gun/flamer/NT/syndicate
	name = "\improper syndicate flamethrower"
	desc = "Syndicate style flamer"
	icon_state = "syndi_flamer"


//non-branded full flamer, can be used for shitspawn

/obj/item/weapon/gun/flamer/unbranded/Initialize()
	. = ..()
	fuel_tank = new /obj/item/weapon/welder_tank/large(src)
	preassure_tank = new /obj/item/weapon/tank/oxygen(src)
	igniter = new /obj/item/device/assembly/igniter(src)
	gauge = new /obj/item/device/analyzer(src)
	update_icon()
	return
