//for cargo delivery, official NT flamer
/obj/item/gun/flamer/NT
	name = "\improper NT flamerthrower"
	desc = "NT flamerthrower. Used to burn spaces vines. The special layout of the elements allows you to not disturb the atmosphere in confined spaces."

/obj/item/gun/flamer/NT/Initialize()
	. = ..()
	fuel_tank = new /obj/item/welder_tank/huge(src)
	pressure_tank = new /obj/item/tank/oxygen(src)
	igniter = new /obj/item/device/assembly/igniter(src)
	gauge = new /obj/item/device/analyzer(src)
	attached_electronics = list(igniter, gauge)
	update_icon()
	return

//for syndicate event flamer
/obj/item/gun/flamer/NT/syndicate
	name = "\improper syndicate flamethrower"
	desc = "Syndicate style flamer. Used to burn NT personal."


//non-branded full flamer, can be used for shitspawn

/obj/item/gun/flamer/full/Initialize()
	. = ..()
	fuel_tank = new /obj/item/welder_tank/large(src)
	pressure_tank = new /obj/item/tank/oxygen(src)
	igniter = new /obj/item/device/assembly/igniter(src)
	gauge = new /obj/item/device/analyzer(src)
	attached_electronics = list(igniter, gauge)
	update_icon()
	return
