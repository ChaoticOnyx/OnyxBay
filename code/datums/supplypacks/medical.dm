/decl/hierarchy/supply_pack/medical
	name = "Medical"
	containertype = /obj/structure/closet/crate/medical

/decl/hierarchy/supply_pack/medical/medical
	name = "Medical crate"
	contains = list(/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/adv,
					/obj/item/storage/firstaid/antirad,
					/obj/item/reagent_containers/vessel/bottle/chemical/antitoxin,
					/obj/item/reagent_containers/vessel/bottle/chemical/inaprovaline,
					/obj/item/reagent_containers/vessel/bottle/chemical/stoxin,
					/obj/item/storage/box/syringes,
					/obj/item/storage/box/autoinjectors)
	cost = 10
	containername = "\improper Medical crate"

/decl/hierarchy/supply_pack/medical/somaticgel
	name = "Somatic gel crate"
	contains = list(/obj/item/stack/medical/advanced/bruise_pack = 5)
	cost = 10
	containername = "\improper Somatic gel crate"

/decl/hierarchy/supply_pack/medical/burngel
	name = "Burn gel crate"
	contains = list(/obj/item/stack/medical/advanced/ointment = 5)
	cost = 10
	containername = "\improper Burn gel crate"

/decl/hierarchy/supply_pack/medical/somaticgeltank
	name = "Somatic gel tank"
	contains = list(/obj/structure/geltank/somatic)
	cost = 10
	containername = "\improper Somatic gel crate"
	containertype = /obj/structure/largecrate

/decl/hierarchy/supply_pack/medical/burngeltank
	name = "Burn gel tank"
	contains = list(/obj/structure/geltank/burn)
	cost = 10
	containername = "\improper Burn gel crate"
	containertype = /obj/structure/largecrate

/decl/hierarchy/supply_pack/medical/pills
	num_contained = 5
	contains = list(/obj/item/storage/pill_bottle/dylovene,
					/obj/item/storage/pill_bottle/bicaridine,
					/obj/item/storage/pill_bottle/dexalin_plus,
					/obj/item/storage/pill_bottle/dexalin,
					/obj/item/storage/pill_bottle/dermaline,
					/obj/item/storage/pill_bottle/inaprovaline,
					/obj/item/storage/pill_bottle/kelotane,
					/obj/item/storage/pill_bottle/spaceacillin,
					/obj/item/storage/pill_bottle/tramadol,
					/obj/item/storage/pill_bottle/oxycodone,
					/obj/item/storage/pill_bottle/antidexafen,
					/obj/item/storage/pill_bottle/paracetamol,
					/obj/item/storage/pill_bottle/hyronalin,
					/obj/item/storage/pill_bottle/glucose,
					/obj/item/storage/pill_bottle/tricordrazine,
					/obj/item/storage/pill_bottle/ryetalyn,
					/obj/item/storage/pill_bottle/albumin)
	name = "Surplus medical drugs"
	cost = 30
	containername = "\improper Medical drugs crate"
	supply_method = /decl/supply_method/randomized

/decl/hierarchy/supply_pack/medical/syringe_gun
	name = "Syringe guns"
	contains = list(/obj/item/gun/launcher/syringe = 2,
					/obj/item/storage/box/syringegun = 2,
					/obj/item/storage/box/syringes = 2,
					/obj/item/reagent_containers/vessel/bottle/chemical/stoxin = 2)
	cost = 50
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Syringe guns crate"
	access = access_medical

/decl/hierarchy/supply_pack/medical/syringe_cartridge
	name = "Syringe cartridges"
	contains = list(/obj/item/storage/box/syringegun = 2)
	cost = 25
	containername = "\improper Syringe cartridges crate"

/decl/hierarchy/supply_pack/medical/bloodpack
	name = "IV bags crate"
	contains = list(/obj/item/storage/box/bloodpacks = 3)
	cost = 10
	containername = "\improper IV bags crate"

/decl/hierarchy/supply_pack/medical/blood
	name = "IV bags (nanoblood) crate"
	contains = list(/obj/item/reagent_containers/ivbag/nanoblood = 4)
	cost = 15
	containername = "\improper Nanoblood crate"

/decl/hierarchy/supply_pack/medical/saline
	name = "IV bags (saline) crate"
	contains = list(/obj/item/reagent_containers/ivbag/saline = 10)
	cost = 10
	containername = "\improper Saline crate"

/decl/hierarchy/supply_pack/medical/bodybag
	name = "Body bag crate"
	contains = list(/obj/item/storage/box/bodybags = 10)
	cost = 10
	containername = "\improper Body bag crate"

/decl/hierarchy/supply_pack/medical/cryobag
	name = "Stasis bag crate"
	contains = list(/obj/item/bodybag/cryobag = 5)
	cost = 50
	containername = "\improper Stasis bag crate"

/decl/hierarchy/supply_pack/medical/medicalextragear
	name = "Medical surplus equipment"
	contains = list(/obj/item/storage/belt/medical = 3,
					/obj/item/clothing/glasses/hud/one_eyed/oneye/medical = 3)
	cost = 15
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Medical surplus equipment"
	access = access_medical

/decl/hierarchy/supply_pack/medical/cmogear
	name = "Chief medical officer equipment"
	contains = list(/obj/item/storage/belt/medical,
					/obj/item/device/radio/headset/heads/cmo,
					/obj/item/clothing/under/rank/chief_medical_officer,
					/obj/item/reagent_containers/hypospray/vial,
					/obj/item/clothing/accessory/stethoscope,
					/obj/item/clothing/glasses/hud/one_eyed/oneye/medical,
					/obj/item/clothing/suit/storage/toggle/labcoat/cmo,
					/obj/item/clothing/suit/storage/toggle/labcoat/cmoalt,
					/obj/item/clothing/mask/surgical,
					/obj/item/clothing/shoes/white,
					/obj/item/cartridge/cmo,
					/obj/item/clothing/gloves/latex,
					/obj/item/device/healthanalyzer,
					/obj/item/device/flashlight/pen,
					/obj/item/reagent_containers/syringe)
	cost = 60
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Chief medical officer equipment"
	access = access_cmo

/decl/hierarchy/supply_pack/medical/doctorgear
	name = "Medical Doctor equipment"
	contains = list(/obj/item/storage/belt/medical,
					/obj/item/device/radio/headset/headset_med,
					/obj/item/clothing/under/rank/medical,
					/obj/item/clothing/accessory/stethoscope,
					/obj/item/clothing/glasses/hud/one_eyed/oneye/medical,
					/obj/item/clothing/suit/storage/toggle/labcoat,
					/obj/item/clothing/mask/surgical,
					/obj/item/storage/firstaid/adv,
					/obj/item/clothing/shoes/white,
					/obj/item/cartridge/medical,
					/obj/item/clothing/gloves/latex,
					/obj/item/device/healthanalyzer,
					/obj/item/device/flashlight/pen,
					/obj/item/reagent_containers/syringe)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Medical Doctor equipment"
	access = access_medical_equip

/decl/hierarchy/supply_pack/medical/chemistgear
	name = "Chemist equipment"
	contains = list(/obj/item/storage/box/beakers,
					/obj/item/device/radio/headset/headset_med,
					/obj/item/storage/box/autoinjectors,
					/obj/item/clothing/under/rank/chemist,
					/obj/item/clothing/glasses/hud/standard/science,
					/obj/item/clothing/suit/storage/toggle/labcoat/chemist,
					/obj/item/clothing/mask/surgical,
					/obj/item/clothing/shoes/white,
					/obj/item/cartridge/chemistry,
					/obj/item/clothing/gloves/latex,
					/obj/item/reagent_containers/dropper,
					/obj/item/device/healthanalyzer,
					/obj/item/storage/box/pillbottles,
					/obj/item/reagent_containers/syringe)
	cost = 15
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Chemist equipment"
	access = access_chemistry

/decl/hierarchy/supply_pack/medical/paramedicgear
	name = "Paramedic equipment"
	contains = list(/obj/item/storage/belt/medical/emt,
					/obj/item/device/radio/headset/headset_med,
					/obj/item/clothing/under/rank/medical/scrubs/black,
					/obj/item/clothing/accessory/armband/medgreen,
					/obj/item/clothing/glasses/hud/one_eyed/oneye/medical,
					/obj/item/clothing/suit/storage/toggle/labcoat,
					/obj/item/clothing/under/rank/medical/paramedic,
					/obj/item/clothing/suit/storage/toggle/fr_jacket,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/under/rank/medical/paramedic,
					/obj/item/clothing/accessory/stethoscope,
					/obj/item/storage/firstaid/adv,
					/obj/item/clothing/shoes/jackboots,
					/obj/item/clothing/gloves/latex,
					/obj/item/device/healthanalyzer,
					/obj/item/cartridge/medical,
					/obj/item/device/flashlight/pen,
					/obj/item/reagent_containers/syringe,
					/obj/item/clothing/accessory/storage/white_vest)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Paramedic equipment"
	access = access_medical_equip

/decl/hierarchy/supply_pack/medical/psychiatristgear
	name = "Psychiatrist equipment"
	contains = list(/obj/item/clothing/under/rank/psych,
					/obj/item/device/radio/headset/headset_med,
					/obj/item/clothing/under/rank/psych/turtleneck,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/suit/storage/toggle/labcoat,
					/obj/item/clothing/shoes/white,
					/obj/item/clipboard,
					/obj/item/folder/white,
					/obj/item/pen,
					/obj/item/cartridge/medical)
	cost = 15
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Psychiatrist equipment"
	access = access_psychiatrist

/decl/hierarchy/supply_pack/medical/medicalscrubs
	name = "Medical scrubs"
	contains = list(/obj/item/clothing/shoes/white = 4,
					/obj/item/clothing/under/rank/medical/scrubs/blue,
					/obj/item/clothing/under/rank/medical/scrubs/green,
					/obj/item/clothing/under/rank/medical/scrubs/purple,
					/obj/item/clothing/under/rank/medical/scrubs/black,
					/obj/item/clothing/head/surgery/black,
					/obj/item/clothing/head/surgery/purple,
					/obj/item/clothing/head/surgery/blue,
					/obj/item/clothing/head/surgery/green,
					/obj/item/storage/box/masks,
					/obj/item/storage/box/compact_shoe_covers,
					/obj/item/storage/box/gloves)
	cost = 15
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Medical scrubs crate"
	access = access_medical_equip

/decl/hierarchy/supply_pack/medical/autopsy
	name = "Autopsy equipment"
	contains = list(/obj/item/folder/white,
					/obj/item/device/camera,
					/obj/item/device/camera_film = 2,
					/obj/item/autopsy_scanner,
					/obj/item/scalpel,
					/obj/item/storage/box/masks,
					/obj/item/storage/box/gloves,
					/obj/item/pen)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Autopsy equipment crate"
	access = access_morgue

/decl/hierarchy/supply_pack/medical/medicaluniforms
	name = "Medical uniforms"
	contains = list(/obj/item/clothing/shoes/white = 3,
					/obj/item/clothing/under/rank/chief_medical_officer,
					/obj/item/clothing/under/rank/geneticist,
					/obj/item/clothing/under/rank/virologist,
					/obj/item/clothing/under/rank/nursesuit,
					/obj/item/clothing/under/rank/nurse,
					/obj/item/clothing/under/rank/medical = 3,
					/obj/item/clothing/under/rank/medical/paramedic = 3,
					/obj/item/clothing/suit/storage/toggle/labcoat = 3,
					/obj/item/clothing/suit/storage/toggle/labcoat/cmo,
					/obj/item/clothing/suit/storage/toggle/labcoat/cmoalt,
					/obj/item/clothing/suit/storage/toggle/labcoat/genetics,
					/obj/item/clothing/suit/storage/toggle/labcoat/virologist,
					/obj/item/clothing/suit/storage/toggle/labcoat/chemist,
					/obj/item/storage/box/masks,
					/obj/item/storage/box/compact_shoe_covers,
					/obj/item/storage/box/gloves)
	cost = 15
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Medical uniform crate"
	access = access_medical_equip

/decl/hierarchy/supply_pack/medical/medicalbiosuits
	name = "Medical biohazard gear"
	contains = list(/obj/item/clothing/head/bio_hood = 3,
					/obj/item/clothing/suit/bio_suit = 3,
					/obj/item/clothing/head/bio_hood/virology = 2,
					/obj/item/clothing/suit/bio_suit/cmo = 2,
					/obj/item/clothing/mask/gas = 5,
					/obj/item/tank/oxygen = 5,
					/obj/item/storage/box/masks,
					/obj/item/storage/box/gloves)
	cost = 50
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Medical biohazard equipment"
	access = access_medical_equip

/decl/hierarchy/supply_pack/medical/portablefreezers
	name = "Portable freezers crate"
	contains = list(/obj/item/storage/box/freezer = 7)
	cost = 25
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Portable freezers"
	access = access_medical_equip

/decl/hierarchy/supply_pack/medical/surgery
	name = "Surgery crate"
	contains = list(/obj/item/storage/firstaid/surgery)
	cost = 25
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Surgery crate"
	access = access_medical

/decl/hierarchy/supply_pack/medical/sterile
	name = "Sterile equipment crate"
	contains = list(/obj/item/clothing/under/rank/medical/scrubs/green = 2,
					/obj/item/clothing/head/surgery/green = 2,
					/obj/item/storage/box/masks,
					/obj/item/storage/box/gloves,
					/obj/item/storage/belt/medical = 3)
	cost = 15
	containertype = /obj/structure/closet/crate
	containername = "\improper Sterile equipment crate"

/decl/hierarchy/supply_pack/medical/voidsuit
	name = "Medical voidsuit"
	contains = list(/obj/item/clothing/suit/space/void/medical/alt,
					/obj/item/clothing/head/helmet/space/void/medical/alt,
					/obj/item/clothing/shoes/magboots)
	cost = 120
	containername = "\improper Medical voidsuit crate"
	containertype = /obj/structure/closet/crate/secure/large
	access = access_medical_equip

/decl/hierarchy/supply_pack/medical/rig
	name = "Medical RIG"
	contains = list(/obj/item/rig/medical/equipped)
	cost = 360
	containername = "\improper Medical RIG crate"
	containertype = /obj/structure/closet/crate/secure
	access = access_medical_equip

/decl/hierarchy/supply_pack/medical/vatgrownbodymale
	name = "Blank vat-grown male body"
	cost = 300
	containername = "\improper Vat-grown body crate"
	containertype = /obj/structure/largecrate/animal/vatgrownbody/male

/decl/hierarchy/supply_pack/medical/vatgrownbodyfemale
	name = "Blank vat-grown female body"
	cost = 300
	containername = "\improper Vat-grown body crate"
	containertype = /obj/structure/largecrate/animal/vatgrownbody/female
