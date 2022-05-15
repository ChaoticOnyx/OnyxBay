/obj/item/storage/box/syndie_kit
	name = "box"
	desc = "A sleek, sturdy box."
	icon_state = "box_of_doom"

//For uplink kits that provide bulkier items
/obj/item/storage/backpack/satchel/syndie_kit
	desc = "A sleek, sturdy satchel."
	icon_state = "satchel-norm"

//In case an uplink kit provides a lot of gear
/obj/item/storage/backpack/dufflebag/syndie_kit
	name = "black dufflebag"
	desc = "A sleek, sturdy dufflebag."
	icon_state = "duffle_syndie"


/obj/item/storage/box/syndie_kit/imp_freedom
	name = "box (F)"
	startswith = list(/obj/item/implanter/freedom)

/obj/item/storage/box/syndie_kit/adrenalin
	name = "box (A)"
	startswith = list(/obj/item/implanter/adrenalin)

/obj/item/storage/box/syndie_kit/imp_uplink
	name = "box (U)"
	startswith = list(/obj/item/implanter/uplink)

/obj/item/storage/box/syndie_kit/imp_compress
	name = "box (C)"
	startswith = list(/obj/item/implanter/compressed)

/obj/item/storage/box/syndie_kit/spy_implant
	name = "box (S)"
	startswith = list(/obj/item/implanter/spy)

/obj/item/storage/box/syndie_kit/imp_explosive
	name = "box (E)"
	startswith = list(
		/obj/item/implanter/explosive,
		/obj/item/implantpad
		)

/obj/item/storage/box/syndie_kit/imp_imprinting
	name = "box (I)"
	startswith = list(
		/obj/item/implanter/imprinting,
		/obj/item/implantpad,
		/obj/item/reagent_containers/hypospray/autoinjector/mindbreaker
		)

// Space suit uplink kit
/obj/item/storage/backpack/satchel/syndie_kit/space
	//name = "\improper EVA gear pack"

	startswith = list(
		/obj/item/clothing/suit/space/syndicate,
		/obj/item/clothing/head/helmet/space/syndicate,
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/tank/emergency/oxygen/double,
		)

// Chameleon uplink kit
/obj/item/storage/backpack/chameleon/sydie_kit
	startswith = list(
		/obj/item/clothing/under/chameleon,
		/obj/item/clothing/suit/chameleon,
		/obj/item/clothing/shoes/chameleon,
		/obj/item/clothing/mask/chameleon,
		/obj/item/storage/box/syndie_kit/chameleon,
		/obj/item/gun/energy/chameleon,
		)

/obj/item/storage/box/syndie_kit/chameleon
	name = "chameleon kit"
	desc = "Comes with all the clothes you need to impersonate most people.  Acting lessons sold seperately."
	startswith = list(
		/obj/item/clothing/gloves/chameleon,
		/obj/item/clothing/glasses/chameleon,
		/obj/item/clothing/head/chameleon,
		)

// Clerical uplink kit
/obj/item/storage/backpack/satchel/syndie_kit/clerical
	name = "clerical kit"
	desc = "Comes with all you need to fake paperwork. Assumes you have passed basic writing lessons."
	startswith = list(
		/obj/item/packageWrap,
		/obj/item/hand_labeler,
		/obj/item/stamp/chameleon,
		/obj/item/pen/chameleon,
		/obj/item/device/destTagger,
		)

/obj/item/storage/box/syndie_kit/spy
	name = "spy kit"
	desc = "For when you want to conduct voyeurism from afar."
	startswith = list(
		/obj/item/device/spy_bug = 6,
		/obj/item/device/spy_monitor
	)

/obj/item/storage/box/syndie_kit/g9mm
	name = "\improper Smooth operator"
	desc = "9mm with silencer kit and ammunition."
	startswith = list(
		/obj/item/gun/projectile/pistol/holdout,
		/obj/item/silencer,
		/obj/item/ammo_magazine/mc9mm
	)

/obj/item/storage/backpack/satchel/syndie_kit/revolver
	name = "\improper Tough operator"
	desc = ".357 revolver, with ammunition."
	startswith = list(
		/obj/item/gun/projectile/revolver,
		/obj/item/ammo_magazine/a357
	)

/obj/item/storage/backpack/satchel/syndie_kit/revolver2
	name = "\improper Dandy tough operator"
	desc = ".44 magnum revolver, with ammunition."
	startswith = list(
		/obj/item/gun/projectile/revolver/webley,
		/obj/item/ammo_magazine/c44
	)

/obj/item/storage/box/syndie_kit/toxin
	name = "toxin kit"
	desc = "An apple will not be enough to keep the doctor away after this."
	startswith = list(
		/obj/item/reagent_containers/vessel/beaker/vial/random/toxin,
		/obj/item/reagent_containers/syringe
	)

/obj/item/storage/box/syndie_kit/syringegun
	startswith = list(
		/obj/item/gun/launcher/syringe/disguised,
		/obj/item/syringe_cartridge = 4,
		/obj/item/reagent_containers/syringe = 4
	)

/obj/item/storage/box/syndie_kit/cigarette
	name = "\improper Tricky smokes"
	desc = "Comes with the following brands of cigarettes, in this order: 2xFlash, 2xSmoke, 1xMindBreaker, 1xTricordrazine. Avoid mixing them up."

/obj/item/storage/box/syndie_kit/cigarette/New()
	..()
	new /obj/item/storage/fancy/cigarettes/syndi_cigs/flash(src)
	new /obj/item/storage/fancy/cigarettes/syndi_cigs/flash(src)
	new /obj/item/storage/fancy/cigarettes/syndi_cigs/smoke(src)
	new /obj/item/storage/fancy/cigarettes/syndi_cigs/smoke(src)
	new /obj/item/storage/fancy/cigarettes/syndi_cigs/mind_breaker(src)
	new /obj/item/storage/fancy/cigarettes/syndi_cigs/tricordrazine(src)

	new /obj/item/flame/lighter/zippo(src)

/proc/fill_cigarre_package(obj/item/storage/fancy/cigarettes/C, list/reagents)
	for(var/reagent in reagents)
		C.reagents.add_reagent(reagent, reagents[reagent] * C.max_storage_space)

//Rig Electrowarfare and Voice Synthesiser kit
/obj/item/storage/backpack/satchel/syndie_kit/ewar_voice
	//name = "\improper Electrowarfare and Voice Synthesiser pack"
	//desc = "Kit for confounding organic and synthetic entities alike."
	startswith = list(
		/obj/item/rig_module/electrowarfare_suite,
		/obj/item/rig_module/voice,
		)

/obj/item/storage/secure/briefcase/heavysniper
	startswith = list(
		/obj/item/gun/projectile/heavysniper,
		/obj/item/storage/box/sniperammo
	)

/obj/item/storage/secure/briefcase/heavysniper/Initialize()
	. = ..()
	make_exact_fit()

/obj/item/storage/secure/briefcase/money

	startswith = list(/obj/item/spacecash/bundle/c500 = 10)

/obj/item/storage/backpack/satchel/syndie_kit/cleaning_kit
	name = "cleaning kit"
	desc = "Used to clean your dirty deeds up."
	startswith = list(
		/obj/item/reagent_containers/spray/cleaner,
		/obj/item/reagent_containers/spray/sterilizine,
		/obj/item/soap/syndie,
		/obj/item/storage/bag/trash,
		/obj/item/grenade/chem_grenade/cleaner = 3,
		/obj/item/reagent_containers/vessel/bucket/full,
		/obj/item/mop,
		/obj/item/storage/box/bodybags
		)

/obj/item/storage/backpack/satchel/syndie_kit/armor
	name = "armor satchel"
	desc = "A satchel for when you don't want to try a diplomatic approach."
	startswith = list(
		/obj/item/clothing/suit/armor/pcarrier/syndi,
		/obj/item/clothing/head/helmet/syndi
	)

/obj/item/storage/firstaid/surgery/syndie
	name = "surgery kit"
	desc = "Contains tools for surgery. Has precise foam fitting for safe transport and automatically sterilizes the content between uses."
	icon_state = "surgerykit"
	item_state = "firstaid-surgery"
	startswith = list(
		/obj/item/bonesetter/bone_mender,
		/obj/item/cautery,
		/obj/item/circular_saw/plasmasaw,
		/obj/item/hemostat/pico,
		/obj/item/retractor,
		/obj/item/scalpel/laser3,
		/obj/item/surgicaldrill,
		/obj/item/bonegel,
		/obj/item/FixOVein/clot,
		/obj/item/organfixer/advanced,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/nanopaste,
		)
