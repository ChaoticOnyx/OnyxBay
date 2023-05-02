
/// 9mm
/obj/item/ammo_magazine/box/c9mm
	name = "ammunition box (9mm)"
	icon_state = "9mm"
	origin_tech = list(TECH_COMBAT = 2)
	matter = list(MATERIAL_STEEL = 1800)
	caliber = "9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 30

/obj/item/ammo_magazine/box/c9mm/empty
	initial_ammo = 0

/obj/item/ammo_magazine/box/c9mm/nt
	desc = "A NT-manufactured magazine for some kind of gun."
	ammo_type = /obj/item/ammo_casing/c9mm/nt

/obj/item/ammo_magazine/box/emp
	name = "ammunition box (.38, haywire)"
	icon_state = "empbox"
	origin_tech = list(TECH_COMBAT = 2)
	max_ammo = 10
	ammo_type = /obj/item/ammo_casing/c38/emp
	caliber = ".38"

/obj/item/ammo_magazine/box/emp/c45
	name = "ammunition box (.45, haywire)"
	ammo_type = /obj/item/ammo_casing/c45/emp
	caliber = ".45"

/obj/item/ammo_magazine/box/emp/a10mm
	name = "ammunition box (10mm, haywire)"
	ammo_type = /obj/item/ammo_casing/a10mm/emp
	caliber = "10mm"

/// .45
/obj/item/ammo_magazine/box/c45
	name = "ammunition box (.45)"
	icon_state = "9mm"
	origin_tech = list(TECH_COMBAT = 2)
	caliber = ".45"
	matter = list(MATERIAL_STEEL = 2250)
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 30

/obj/item/ammo_magazine/box/c45/empty
	initial_ammo = 0

/// 5.56mm
/obj/item/ammo_magazine/box/a556
	name = "magazine box (5.56mm)"
	icon_state = "a556"
	origin_tech = list(TECH_COMBAT = 2)
	mag_type = MAGAZINE
	caliber = "a556"
	matter = list(MATERIAL_STEEL = 5400)
	ammo_type = /obj/item/ammo_casing/a556
	max_ammo = 60
	multiple_sprites = TRUE

/obj/item/ammo_magazine/box/a556/empty
	initial_ammo = 0
