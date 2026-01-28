/decl/hierarchy/outfit/job/assistant
	name = OUTFIT_JOB_NAME("Assistant")

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
	uniform = /obj/item/clothing/under/color/black //TODO: Draw a unique sprite and code a uniform for the merchants.
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
							 /obj/item/reagent_containers/spray/waterflower = 1,
							 /obj/item/balloon_box = 1)

/decl/hierarchy/outfit/job/clown/New()
	..()
	BACKPACK_OVERRIDE_CLOWN

/decl/hierarchy/outfit/job/mime
	name = OUTFIT_JOB_NAME("Mime")
	head = /obj/item/clothing/head/beret/classique
	uniform = /obj/item/clothing/under/rank/mime
	id_type = /obj/item/card/id/civilian/mime
	pda_type = /obj/item/device/pda/mime
	shoes = /obj/item/clothing/shoes/mime
	mask = /obj/item/clothing/mask/gas/mime
	r_pocket = /obj/item/pen/crayon/mime
	gloves = /obj/item/clothing/gloves/white
	backpack_contents = list(/obj/item/reagent_containers/vessel/bottle/bottleofnothing = 1,
							 /obj/item/clothing/accessory/suspenders = 1,
							 /obj/item/reagent_containers/food/baguette = 1,
							 /obj/item/balloon_box = 1)
