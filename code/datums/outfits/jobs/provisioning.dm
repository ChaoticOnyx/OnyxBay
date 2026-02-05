
/decl/hierarchy/outfit/job/hop
	name = OUTFIT_JOB_NAME("Head of Provisioning")
	head = /obj/item/clothing/head/soft/hop
	uniform = /obj/item/clothing/under/rank/hop
	l_ear = /obj/item/device/radio/headset/heads/hop
	shoes = /obj/item/clothing/shoes/brown
	glasses = /obj/item/clothing/glasses/sunglasses
	id_type = /obj/item/card/id/provisioning/head
	pda_type = /obj/item/device/pda/heads/hop
	backpack_contents = list(/obj/item/clipboard = 1)

/decl/hierarchy/outfit/job/cargo
	l_ear = /obj/item/device/radio/headset/headset_cargo
	hierarchy_type = /decl/hierarchy/outfit/job/cargo

/decl/hierarchy/outfit/job/cargo/cargo_tech
	name = OUTFIT_JOB_NAME("Cargo technician")
	uniform = /obj/item/clothing/under/rank/cargotech
	id_type = /obj/item/card/id/provisioning/cargo
	pda_type = /obj/item/device/pda/cargo

/decl/hierarchy/outfit/job/cargo/cargo_tech/docker
	name = OUTFIT_JOB_NAME("Cargo docker")
	uniform = /obj/item/clothing/under/rank/cargotech/shorts

/decl/hierarchy/outfit/job/cargo/mining
	name = OUTFIT_JOB_NAME("Shaft miner")
	shoes = /obj/item/clothing/shoes/workboots
	uniform = /obj/item/clothing/under/rank/miner
	id_type = /obj/item/card/id/provisioning/cargo/mining
	pda_type = /obj/item/device/pda/shaftminer
	pda_slot = slot_l_store
	backpack_contents = list(/obj/item/crowbar = 1)
	belt = /obj/item/storage/ore
	flags = OUTFIT_HAS_BACKPACK|OUTFIT_EXTENDED_SURVIVAL

/decl/hierarchy/outfit/job/cargo/mining/New()
	..()
	BACKPACK_OVERRIDE_ENGINEERING

/decl/hierarchy/outfit/job/cargo/mining/void
	name = OUTFIT_JOB_NAME("Shaft miner - Voidsuit")
	head = /obj/item/clothing/head/helmet/space/void/mining
	mask = /obj/item/clothing/mask/breath
	suit = /obj/item/clothing/suit/space/void/mining


/decl/hierarchy/outfit/job/provisioning
	l_ear = /obj/item/device/radio/headset/headset_service
	hierarchy_type = /decl/hierarchy/outfit/job/provisioning

/decl/hierarchy/outfit/job/provisioning/bartender
	name = OUTFIT_JOB_NAME("Bartender")
	uniform = /obj/item/clothing/under/rank/bartender
	id_type = /obj/item/card/id/provisioning/bartender
	pda_type = /obj/item/device/pda/bar
	suit = /obj/item/clothing/suit/armor/vest

/decl/hierarchy/outfit/job/provisioning/chef
	name = OUTFIT_JOB_NAME("Chef")
	uniform = /obj/item/clothing/under/rank/chef
	suit = /obj/item/clothing/suit/chef
	head = /obj/item/clothing/head/chefhat
	id_type = /obj/item/card/id/provisioning/chef
	pda_type = /obj/item/device/pda/chef

/decl/hierarchy/outfit/job/provisioning/gardener
	name = OUTFIT_JOB_NAME("Gardener")
	uniform = /obj/item/clothing/under/rank/hydroponics
	suit = /obj/item/clothing/suit/apron
	gloves = /obj/item/clothing/gloves/thick/botany
	r_pocket = /obj/item/device/analyzer/plant_analyzer
	id_type = /obj/item/card/id/provisioning/botanist
	pda_type = /obj/item/device/pda/botanist

/decl/hierarchy/outfit/job/provisioning/gardener/New()
	..()
	BACKPACK_OVERRIDE_HYDRO

/decl/hierarchy/outfit/job/provisioning/janitor
	name = OUTFIT_JOB_NAME("Janitor")
	uniform = /obj/item/clothing/under/rank/janitor
	id_type = /obj/item/card/id/provisioning/janitor
	pda_type = /obj/item/device/pda/janitor

/decl/hierarchy/outfit/job/provisioning/barmonkey
	name = OUTFIT_JOB_NAME("Bar Monkey")
	uniform = null
	shoes = null
	pda_type = null
	id_type = /obj/item/card/id/civilian/barmonkey
	flags = OUTFIT_NO_SURVIVAL

/decl/hierarchy/outfit/job/provisioning/barmonkey/equip_id(mob/living/carbon/human/H, rank, assignment, equip_adjustments)
	var/obj/item/card/id/W = new id_type(H)
	if(id_desc)
		W.desc = id_desc
	if(rank)
		W.rank = rank
	if(assignment)
		W.assignment = assignment
	H.set_id_info(W)
	H.put_in_l_hand(W)
	return W

/decl/hierarchy/outfit/job/provisioning/barmonkey/post_equip(mob/living/carbon/human/H)
	..()
	var/obj/item/clothing/C
	if(prob(50))
		C = new /obj/item/clothing/under/monkey/punpun(src)
		H.equip_to_appropriate_slot(C)
	else
		C = new /obj/item/clothing/under/monkey/pants(src)
		C.attach_accessory(null, new /obj/item/clothing/accessory/toggleable/hawaii/random(src))
		H.equip_to_appropriate_slot(C)
