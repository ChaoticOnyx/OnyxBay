/obj/item/weapon/storage/syndie_kit
	name = "Box"
	desc = "A sleek, sturdy box"
	icon_state = "box_of_doom"
	item_state = "syringe_kit"


/obj/item/weapon/storage/syndie_kit/imp_freedom
	name = "Freedom Implant (with injector)"

/obj/item/weapon/storage/syndie_kit/imp_freedom/New()
	var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
	O.imp = new /obj/item/weapon/implant/freedom(O)
	O.update()
	..()
	return


/obj/item/weapon/storage/syndie_kit/imp_compress
	name = "Compressed Matter Implant (with injector)"

/obj/item/weapon/storage/syndie_kit/imp_compress/New()
	var/obj/item/weapon/implanter/compress/O = new /obj/item/weapon/implanter/compress(src)
	O.imp = new /obj/item/weapon/implant/compressed(O)
	..()
	return


/obj/item/weapon/storage/syndie_kit/imp_control
	name = "Mind Control Implant (with injectors)"

/obj/item/weapon/storage/syndie_kit/imp_control/New()
	var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
	O.name = "master"
	O.imp = new /obj/item/weapon/implant/master(O)
	var/obj/item/weapon/implanter/S = new /obj/item/weapon/implanter(src)
	S.name = "slave"
	S.imp = new /obj/item/weapon/implant/slave(S)
	S.imp:m = O.imp
	O.imp:s = S.imp
	..()
	return


/obj/item/weapon/storage/syndie_kit/imp_alien
	name = "Alien Embryo (with injector) - Not fully tested on humans!"

/obj/item/weapon/storage/syndie_kit/imp_alien/New()
	var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
	O.imp = new /obj/item/weapon/implant/alien(O)
	O.update()
	..()
	return


/obj/item/weapon/storage/syndie_kit/imp_vfac
	name = "Viral Factory Implant (with injector)"

/obj/item/weapon/storage/syndie_kit/imp_vfac/New()
	var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
	O.imp = new /obj/item/weapon/implant/vfac(O)
	O.update()
	..()
	return


/obj/item/weapon/storage/syndie_kit/imp_explosive
	name = "Explosive Implant (with injector)"

/obj/item/weapon/storage/syndie_kit/imp_explosive/New()
	var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
	O.imp = new /obj/item/weapon/implant/explosive(O)
	O.name = "(BIO-HAZARD) BIO-detpack"
	O.update()
	..()
	return