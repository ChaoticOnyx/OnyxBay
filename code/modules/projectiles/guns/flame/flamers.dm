//for cargo delivery, official NT flamer
/obj/item/weapon/gun/flamer/NT
	name = "\improper NT flamerthrower"
	desc = "NT flamerthrower. Used to burn spaces vines. The special layout of the elements allows you to not disturb the atmosphere in confined spaces."

/obj/item/weapon/gun/flamer/NT/Initialize()
	. = ..()
	fuel_tank = new /obj/item/weapon/welder_tank/huge(src)
	pressure_tank = new /obj/item/weapon/tank/oxygen(src)
	igniter = new /obj/item/device/assembly/igniter(src)
	gauge = new /obj/item/device/analyzer(src)
	attached_electronics = list(igniter, gauge)
	update_icon()
	return

//for syndicate event flamer
/obj/item/weapon/gun/flamer/NT/syndicate
	name = "\improper syndicate flamethrower"
	desc = "Syndicate style flamer. Used to burn NT personal."


//non-branded full flamer, can be used for shitspawn

/obj/item/weapon/gun/flamer/full/Initialize()
	. = ..()
	fuel_tank = new /obj/item/weapon/welder_tank/large(src)
	pressure_tank = new /obj/item/weapon/tank/oxygen(src)
	igniter = new /obj/item/device/assembly/igniter(src)
	gauge = new /obj/item/device/analyzer(src)
	attached_electronics = list(igniter, gauge)
	update_icon()
	return
