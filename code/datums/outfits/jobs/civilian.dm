/decl/hierarchy/outfit/job/assistant
	name = OUTFIT_JOB_NAME("Assistant")

/decl/hierarchy/outfit/job/service
	l_ear = /obj/item/device/radio/headset/headset_service
	hierarchy_type = /decl/hierarchy/outfit/job/service

/decl/hierarchy/outfit/job/service/bartender
	name = OUTFIT_JOB_NAME("Bartender")
	uniform = /obj/item/clothing/under/rank/bartender
	id_type = /obj/item/card/id/civilian/bartender
	pda_type = /obj/item/device/pda/bar
	suit = /obj/item/clothing/suit/armor/vest

/decl/hierarchy/outfit/job/service/chef
	name = OUTFIT_JOB_NAME("Chef")
	uniform = /obj/item/clothing/under/rank/chef
	suit = /obj/item/clothing/suit/chef
	head = /obj/item/clothing/head/chefhat
	id_type = /obj/item/card/id/civilian/chef
	pda_type = /obj/item/device/pda/chef

/decl/hierarchy/outfit/job/service/gardener
	name = OUTFIT_JOB_NAME("Gardener")
	uniform = /obj/item/clothing/under/rank/hydroponics
	suit = /obj/item/clothing/suit/apron
	gloves = /obj/item/clothing/gloves/thick/botany
	r_pocket = /obj/item/device/analyzer/plant_analyzer
	id_type = /obj/item/card/id/civilian/botanist
	pda_type = /obj/item/device/pda/botanist

/decl/hierarchy/outfit/job/service/gardener/New()
	..()
	BACKPACK_OVERRIDE_HYDRO

/decl/hierarchy/outfit/job/service/janitor
	name = OUTFIT_JOB_NAME("Janitor")
	uniform = /obj/item/clothing/under/rank/janitor
	id_type = /obj/item/card/id/civilian/janitor
	pda_type = /obj/item/device/pda/janitor

/decl/hierarchy/outfit/job/service/barmonkey
	name = OUTFIT_JOB_NAME("Bar Monkey")
	uniform = null
	shoes = null
	pda_type = null
	id_type = /obj/item/card/id/civilian/barmonkey
	flags = OUTFIT_NO_SURVIVAL

/decl/hierarchy/outfit/job/service/barmonkey/equip_id(mob/living/carbon/human/H, rank, assignment, equip_adjustments)
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

/decl/hierarchy/outfit/job/service/barmonkey/post_equip(mob/living/carbon/human/H)
	..()
	var/obj/item/clothing/C
	if(prob(50))
		C = new /obj/item/clothing/under/monkey/punpun(src)
		H.equip_to_appropriate_slot(C)
	else
		C = new /obj/item/clothing/under/monkey/pants(src)
		C.attach_accessory(null, new /obj/item/clothing/accessory/toggleable/hawaii/random(src))
		H.equip_to_appropriate_slot(C)

/decl/hierarchy/outfit/job/librarian
	name = OUTFIT_JOB_NAME("Librarian")
	uniform = /obj/item/clothing/under/suit_jacket/red
	id_type = /obj/item/card/id/civilian/librarian
	pda_type = /obj/item/device/pda/librarian

/decl/hierarchy/outfit/job/internal_affairs_agent
	name = OUTFIT_JOB_NAME("Internal affairs agent")
	l_ear = /obj/item/device/radio/headset/ia
	uniform = /obj/item/clothing/under/rank/internalaffairs
	suit = /obj/item/clothing/suit/storage/toggle/suit/black
	shoes = /obj/item/clothing/shoes/brown
	glasses = /obj/item/clothing/glasses/sunglasses/big
	l_hand = /obj/item/storage/briefcase/iaa
	id_type = /obj/item/card/id/civilian/internal_affairs_agent
	pda_type = /obj/item/device/pda/iaa

/decl/hierarchy/outfit/job/lawyer
	name = OUTFIT_JOB_NAME("Lawyer")
	uniform = /obj/item/clothing/under/lawyer/bluesuit
	suit = /obj/item/clothing/suit/storage/toggle/suit/blue
	shoes = /obj/item/clothing/shoes/brown
	l_hand = /obj/item/storage/briefcase
	id_type = /obj/item/card/id/civilian/lawyer
	pda_type = /obj/item/device/pda/lawyer

/decl/hierarchy/outfit/job/chaplain
	name = OUTFIT_JOB_NAME("Chaplain")
	uniform = /obj/item/clothing/under/rank/chaplain
	l_hand = /obj/item/storage/bible
	id_type = /obj/item/card/id/civilian/chaplain
	pda_type = /obj/item/device/pda/chaplain

/decl/hierarchy/outfit/job/merchant
	name = OUTFIT_JOB_NAME("Merchant")
	uniform = /obj/item/clothing/under/color/black
	l_ear = /obj/item/device/radio/headset
	shoes = /obj/item/clothing/shoes/black
	pda_type = /obj/item/device/pda
	id_type = /obj/item/card/id/merchant
	backpack_contents = list(/obj/item/device/price_scanner = 1)

/decl/hierarchy/outfit/job/clown
	name = OUTFIT_JOB_NAME("Clown")
	uniform = /obj/item/clothing/under/rank/clown
	id_type = /obj/item/card/id/civilian/clown
	pda_type = /obj/item/device/pda/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	r_pocket = /obj/item/pen/crayon/rainbow
	l_pocket = /obj/item/bikehorn
	backpack_contents = list(/obj/item/reagent_containers/food/pie = 1,
							 /obj/item/bananapeel = 1,
							 /obj/item/reagent_containers/spray/waterflower = 1)

/decl/hierarchy/outfit/job/clown/New()
	..()
	BACKPACK_OVERRIDE_CLOWN

/decl/hierarchy/outfit/job/mime
	name = OUTFIT_JOB_NAME("Mime")
	head = /obj/item/clothing/head/beret/classique
	uniform = /obj/item/clothing/under/mime
	id_type = /obj/item/card/id/civilian/mime
	pda_type = /obj/item/device/pda/mime
	shoes = /obj/item/clothing/shoes/mime
	mask = /obj/item/clothing/mask/gas/mime
	r_pocket = /obj/item/pen/crayon/mime
	gloves = /obj/item/clothing/gloves/white
	backpack_contents = list(/obj/item/reagent_containers/vessel/bottle/bottleofnothing = 1,
							 /obj/item/clothing/accessory/suspenders = 1,
							 /obj/item/reagent_containers/food/baguette = 1)
