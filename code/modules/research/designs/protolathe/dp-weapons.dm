/datum/design/item/weapon
	category_items = list("Weapons")

/datum/design/item/weapon/AssembleDesignDesc()
	if(!desc)
		if(build_path)
			var/obj/item/I = build_path
			desc = initial(I.desc)
		..()

/datum/design/item/weapon/chemsprayer
	desc = "An advanced chem spraying device."
	id = "chemsprayer"

	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 1000)
	build_path = /obj/item/reagent_containers/spray/chemsprayer
	sort_string = "TAAAA"

/datum/design/item/weapon/rapidsyringe
	id = "rapidsyringe"

	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 1000)
	build_path = /obj/item/gun/launcher/syringe/rapid
	sort_string = "TAAAB"

/datum/design/item/weapon/temp_gun
	desc = "A gun that shoots high-powered glass-encased energy temperature bullets."
	id = "temp_gun"

	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 500, MATERIAL_SILVER = 3000)
	build_path = /obj/item/gun/energy/temperature
	sort_string = "TAAAC"

/datum/design/item/weapon/large_grenade
	id = "large_Grenade"

	materials = list(MATERIAL_STEEL = 3000)
	build_path = /obj/item/grenade/chem_grenade/large
	sort_string = "TABAA"

/datum/design/item/weapon/anti_photon
	id = "anti_photon"

	materials = list(MATERIAL_STEEL = 3000, MATERIAL_GLASS = 1000, MATERIAL_DIAMOND = 1000)
	build_path = /obj/item/grenade/anti_photon
	sort_string = "TABAB"

/datum/design/item/weapon/flora_gun
	id = "flora_gun"

	materials = list(MATERIAL_STEEL = 2000, MATERIAL_GLASS = 500, MATERIAL_URANIUM = 500)
	build_path = /obj/item/gun/energy/floragun
	sort_string = "TACAA"
	category_items = list("Misc")

/datum/design/item/weapon/advancedflash
	id = "advancedflash"

	materials = list(MATERIAL_STEEL = 2000, MATERIAL_GLASS = 2000, MATERIAL_SILVER = 500)
	build_path = /obj/item/device/flash/advanced
	sort_string = "TADAA"

/datum/design/item/weapon/stunrevolver
	id = "stunrevolver"

	materials = list(MATERIAL_STEEL = 4000)
	build_path = /obj/item/gun/energy/stunrevolver
	sort_string = "TADAB"

/datum/design/item/weapon/stunrifle
	id = "stun_rifle"

	materials = list(MATERIAL_STEEL = 4000, MATERIAL_GLASS = 1000, MATERIAL_SILVER = 500)
	build_path = /obj/item/gun/energy/stunrevolver/rifle
	sort_string = "TADAC"

/datum/design/item/weapon/nuclear_gun
	id = "nuclear_gun"

	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 1000, MATERIAL_URANIUM = 500)
	build_path = /obj/item/gun/energy/gun/nuclear
	sort_string = "TAEAA"

/datum/design/item/weapon/lasercannon
	desc = "The lasing medium of this prototype is enclosed in a tube lined with uranium-235 and subjected to high neutron flux in a nuclear reactor core."
	id = "lasercannon"

	materials = list(MATERIAL_STEEL = 10000, MATERIAL_GLASS = 1000, MATERIAL_DIAMOND = 2000)
	build_path = /obj/item/gun/energy/lasercannon
	sort_string = "TAEAB"

/datum/design/item/weapon/xraypistol
	id = "xraypistol"

	materials = list(MATERIAL_STEEL = 4000, MATERIAL_GLASS = 500, MATERIAL_URANIUM = 500)
	build_path = /obj/item/gun/energy/xray/pistol
	sort_string = "TAFAA"

/datum/design/item/weapon/xrayrifle
	id = "xrayrifle"

	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 1000, MATERIAL_URANIUM = 1000)
	build_path = /obj/item/gun/energy/xray
	sort_string = "TAFAB"

/datum/design/item/weapon/grenadelauncher
	id = "grenadelauncher"

	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 1000)
	build_path = /obj/item/gun/launcher/grenade
	sort_string = "TAGAA"

/datum/design/item/weapon/pneumatic
	id = "pneumatic"

	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 2000, MATERIAL_SILVER = 500)
	build_path = /obj/item/gun/launcher/pneumatic
	sort_string = "TAGAB"

/datum/design/item/weapon/railgun
	id = "railgun"

	materials = list(MATERIAL_STEEL = 6000, MATERIAL_GOLD = 2000, MATERIAL_SILVER = 2000)
	build_path = /obj/item/gun/magnetic/railgun
	sort_string = "TAHAA"

/datum/design/item/weapon/flechette
	id = "flechette"

	materials = list(MATERIAL_STEEL = 8000, MATERIAL_GOLD = 4000, MATERIAL_SILVER = 4000, MATERIAL_DIAMOND = 2000)
	build_path = /obj/item/gun/magnetic/railgun/flechette
	sort_string = "TAHAB"

/datum/design/item/weapon/plasmapistol
	id = "ppistol"

	materials = list(MATERIAL_STEEL = 5000, MATERIAL_GLASS = 1000, MATERIAL_PLASMA = 3000)
	build_path = /obj/item/gun/energy/toxgun
	sort_string = "TAJAA"

/datum/design/item/weapon/decloner
	id = "decloner"

	materials = list(MATERIAL_GOLD = 5000, MATERIAL_URANIUM = 15000, MATERIAL_DIAMOND = 2000)
	build_path = /obj/item/gun/energy/decloner
	sort_string = "TAJAB"

/datum/design/item/weapon/smg
	id = "smg"

	materials = list(MATERIAL_STEEL = 8000, MATERIAL_SILVER = 2000, MATERIAL_DIAMOND = 1000)
	build_path = /obj/item/gun/projectile/automatic/machine_pistol
	sort_string = "TAPAA"

/datum/design/item/weapon/wt550
	id = "wt550"

	materials = list(MATERIAL_STEEL = 8000, MATERIAL_SILVER = 3000, MATERIAL_DIAMOND = 1500)
	build_path = /obj/item/gun/projectile/automatic/wt550
	sort_string = "TAPAB"

/datum/design/item/weapon/bullpup
	id = "bullpup"

	materials = list(MATERIAL_STEEL = 10000, MATERIAL_SILVER = 5000, MATERIAL_DIAMOND = 3000)
	build_path = /obj/item/gun/projectile/automatic/z8
	sort_string = "TAPAC"

/datum/design/item/weapon/ammunition/ammo_9mm
	id = "ammo_9mm"

	materials = list(MATERIAL_STEEL = 3750, MATERIAL_SILVER = 100)
	build_path = /obj/item/ammo_magazine/box/c9mm
	sort_string = "TBAAA"

/datum/design/item/weapon/ammunition/stunshell
	desc = "A stunning shell for a shotgun."
	id = "stunshell"

	materials = list(MATERIAL_STEEL = 4000)
	build_path = /obj/item/ammo_casing/shotgun/stunshell
	sort_string = "TBAAB"

/datum/design/item/weapon/ammunition/ammo_emp_38
	id = "ammo_emp_38"
	desc = "A .38 round with an integrated EMP charge."
	materials = list(MATERIAL_STEEL = 2500, MATERIAL_URANIUM = 750)

	build_path = /obj/item/ammo_magazine/box/emp
	sort_string = "TBAAC"

/datum/design/item/weapon/ammunition/ammo_emp_45
	id = "ammo_emp_45"
	desc = "A .45 round with an integrated EMP charge."
	materials = list(MATERIAL_STEEL = 2500, MATERIAL_URANIUM = 750)

	build_path = /obj/item/ammo_magazine/box/emp/c45
	sort_string = "TBAAD"

/datum/design/item/weapon/ammunition/ammo_emp_10
	id = "ammo_emp_10"
	desc = "A .10mm round with an integrated EMP charge."
	materials = list(MATERIAL_STEEL = 2500, MATERIAL_URANIUM = 750)

	build_path = /obj/item/ammo_magazine/box/emp/a10mm
	sort_string = "TBAAE"

/datum/design/item/weapon/ammunition/ammo_emp_slug
	id = "ammo_emp_slug"
	desc = "A shotgun slug with an integrated EMP charge."
	materials = list(MATERIAL_STEEL = 3000, MATERIAL_URANIUM = 1000)

	build_path = /obj/item/ammo_casing/shotgun/emp
	sort_string = "TBAAF"
