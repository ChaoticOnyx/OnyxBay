/obj/item/weapon/storage/box/syndie_kit
	name = "box"
	desc = "A sleek, sturdy box."
	icon_state = "box_of_doom"

//For uplink kits that provide bulkier items
/obj/item/weapon/storage/backpack/satchel/syndie_kit
	desc = "A sleek, sturdy satchel."
	icon_state = "satchel-norm"

//In case an uplink kit provides a lot of gear
/obj/item/weapon/storage/backpack/dufflebag/syndie_kit
	name = "black dufflebag"
	desc = "A sleek, sturdy dufflebag."
	icon_state = "duffle_syndie"


/obj/item/weapon/storage/box/syndie_kit/imp_freedom
	name = "box (F)"
	startswith = list(/obj/item/weapon/implanter/freedom)

/obj/item/weapon/storage/box/syndie_kit/adrenalin
	name = "box (A)"
	startswith = list(/obj/item/weapon/implanter/adrenalin)

/obj/item/weapon/storage/box/syndie_kit/imp_uplink
	name = "box (U)"
	startswith = list(/obj/item/weapon/implanter/uplink)

/obj/item/weapon/storage/box/syndie_kit/imp_compress
	name = "box (C)"
	startswith = list(/obj/item/weapon/implanter/compressed)

/obj/item/weapon/storage/box/syndie_kit/spy_implant
	name = "box (S)"
	startswith = list(/obj/item/weapon/implanter/spy)

/obj/item/weapon/storage/box/syndie_kit/imp_explosive
	name = "box (E)"
	startswith = list(
		/obj/item/weapon/implanter/explosive,
		/obj/item/weapon/implantpad
		)

/obj/item/weapon/storage/box/syndie_kit/imp_imprinting
	name = "box (I)"
	startswith = list(
		/obj/item/weapon/implanter/imprinting,
		/obj/item/weapon/implantpad,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/mindbreaker
		)

// Space suit uplink kit
/obj/item/weapon/storage/backpack/satchel/syndie_kit/space
	//name = "\improper EVA gear pack"

	startswith = list(
		/obj/item/clothing/suit/space/syndicate,
		/obj/item/clothing/head/helmet/space/syndicate,
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/weapon/tank/emergency/oxygen/double,
		)

// Chameleon uplink kit
/obj/item/weapon/storage/backpack/chameleon/sydie_kit
	startswith = list(
		/obj/item/clothing/under/chameleon,
		/obj/item/clothing/suit/chameleon,
		/obj/item/clothing/shoes/chameleon,
		/obj/item/clothing/mask/chameleon,
		/obj/item/weapon/storage/box/syndie_kit/chameleon,
		/obj/item/weapon/gun/energy/chameleon,
		)

/obj/item/weapon/storage/box/syndie_kit/chameleon
	name = "chameleon kit"
	desc = "Comes with all the clothes you need to impersonate most people.  Acting lessons sold seperately."
	startswith = list(
		/obj/item/clothing/gloves/chameleon,
		/obj/item/clothing/glasses/chameleon,
		/obj/item/clothing/head/chameleon,
		)

// Clerical uplink kit
/obj/item/weapon/storage/backpack/satchel/syndie_kit/clerical
	name = "clerical kit"
	desc = "Comes with all you need to fake paperwork. Assumes you have passed basic writing lessons."
	startswith = list(
		/obj/item/weapon/packageWrap,
		/obj/item/weapon/hand_labeler,
		/obj/item/weapon/stamp/chameleon,
		/obj/item/weapon/pen/chameleon,
		/obj/item/device/destTagger,
		)

/obj/item/weapon/storage/box/syndie_kit/spy
	name = "spy kit"
	desc = "For when you want to conduct voyeurism from afar."
	startswith = list(
		/obj/item/device/spy_bug = 6,
		/obj/item/device/spy_monitor
	)

/obj/item/weapon/storage/box/syndie_kit/g9mm
	name = "\improper Smooth operator"
	desc = "9mm with silencer kit and ammunition."
	startswith = list(
		/obj/item/weapon/gun/projectile/pistol/holdout,
		/obj/item/weapon/silencer,
		/obj/item/ammo_magazine/mc9mm
	)

/obj/item/weapon/storage/backpack/satchel/syndie_kit/revolver
	name = "\improper Tough operator"
	desc = ".357 revolver, with ammunition."
	startswith = list(
		/obj/item/weapon/gun/projectile/revolver,
		/obj/item/ammo_magazine/a357
	)

/obj/item/weapon/storage/backpack/satchel/syndie_kit/revolver2
	name = "\improper Dandy tough operator"
	desc = ".44 magnum revolver, with ammunition."
	startswith = list(
		/obj/item/weapon/gun/projectile/revolver/webley,
		/obj/item/ammo_magazine/c44
	)

/obj/item/weapon/storage/box/syndie_kit/toxin
	name = "toxin kit"
	desc = "An apple will not be enough to keep the doctor away after this."
	startswith = list(
		/obj/item/weapon/reagent_containers/glass/beaker/vial/random/toxin,
		/obj/item/weapon/reagent_containers/syringe
	)

/obj/item/weapon/storage/box/syndie_kit/syringegun
	startswith = list(
		/obj/item/weapon/gun/launcher/syringe/disguised,
		/obj/item/weapon/syringe_cartridge = 4,
		/obj/item/weapon/reagent_containers/syringe = 4
	)

/obj/item/weapon/storage/box/syndie_kit/cigarette
	name = "\improper Tricky smokes"
	desc = "Comes with the following brands of cigarettes, in this order: 2xFlash, 2xSmoke, 1xMindBreaker, 1xTricordrazine. Avoid mixing them up."

/obj/item/weapon/storage/box/syndie_kit/cigarette/New()
	..()
	new /obj/item/weapon/storage/fancy/cigarettes/syndi_cigs/flash(src)
	new /obj/item/weapon/storage/fancy/cigarettes/syndi_cigs/flash(src)
	new /obj/item/weapon/storage/fancy/cigarettes/syndi_cigs/smoke(src)
	new /obj/item/weapon/storage/fancy/cigarettes/syndi_cigs/smoke(src)
	new /obj/item/weapon/storage/fancy/cigarettes/syndi_cigs/mind_breaker(src)
	new /obj/item/weapon/storage/fancy/cigarettes/syndi_cigs/tricordrazine(src)

	new /obj/item/weapon/flame/lighter/zippo(src)

/proc/fill_cigarre_package(obj/item/weapon/storage/fancy/cigarettes/C, list/reagents)
	for(var/reagent in reagents)
		C.reagents.add_reagent(reagent, reagents[reagent] * C.max_storage_space)

//Rig Electrowarfare and Voice Synthesiser kit
/obj/item/weapon/storage/backpack/satchel/syndie_kit/ewar_voice
	//name = "\improper Electrowarfare and Voice Synthesiser pack"
	//desc = "Kit for confounding organic and synthetic entities alike."
	startswith = list(
		/obj/item/rig_module/electrowarfare_suite,
		/obj/item/rig_module/voice,
		)

/obj/item/weapon/storage/secure/briefcase/heavysniper
	startswith = list(
		/obj/item/weapon/gun/projectile/heavysniper,
		/obj/item/weapon/storage/box/sniperammo
	)

/obj/item/weapon/storage/secure/briefcase/heavysniper/Initialize()
	. = ..()
	make_exact_fit()

/obj/item/weapon/storage/secure/briefcase/money

	startswith = list(/obj/item/weapon/spacecash/bundle/c500 = 10)

/obj/item/weapon/storage/backpack/satchel/syndie_kit/cleaning_kit
	name = "cleaning kit"
	desc = "Used to clean your dirty deeds up."
	startswith = list(
		/obj/item/weapon/reagent_containers/spray/cleaner,
		/obj/item/weapon/reagent_containers/spray/sterilizine,
		/obj/item/weapon/soap/syndie,
		/obj/item/weapon/storage/bag/trash,
		/obj/item/weapon/grenade/chem_grenade/cleaner = 3,
		/obj/item/weapon/reagent_containers/glass/bucket/full,
		/obj/item/weapon/mop,
		/obj/item/weapon/storage/box/bodybags
		)

/obj/item/weapon/storage/backpack/satchel/syndie_kit/armor
	name = "armor satchel"
	desc = "A satchel for when you don't want to try a diplomatic approach."
	startswith = list(
		/obj/item/clothing/suit/armor/pcarrier/syndi,
		/obj/item/clothing/head/helmet/syndi
	)

/obj/item/weapon/storage/firstaid/surgery/syndie
	name = "surgery kit"
	desc = "Contains tools for surgery. Has precise foam fitting for safe transport and automatically sterilizes the content between uses."
	icon_state = "surgerykit"
	item_state = "firstaid-surgery"
	startswith = list(
		/obj/item/weapon/bonesetter/bone_mender,
		/obj/item/weapon/cautery,
		/obj/item/weapon/circular_saw/plasmasaw,
		/obj/item/weapon/hemostat/pico,
		/obj/item/weapon/retractor,
		/obj/item/weapon/scalpel/laser3,
		/obj/item/weapon/surgicaldrill,
		/obj/item/weapon/bonegel,
		/obj/item/weapon/FixOVein/clot,
		/obj/item/weapon/organfixer/advanced,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/nanopaste,
		)
