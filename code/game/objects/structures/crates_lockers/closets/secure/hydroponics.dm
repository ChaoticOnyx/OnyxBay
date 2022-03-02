/obj/structure/closet/secure_closet/hydroponics
	name = "botanist's locker"
	req_access = list(access_hydroponics)
	icon_state = "hydrosecure1"
	icon_closed = "hydrosecure"
	icon_locked = "hydrosecure1"
	icon_opened = "hydrosecureopen"
	icon_off = "hydrosecureoff"

/obj/structure/closet/secure_closet/hydroponics/WillContain()
	return list(
		new /datum/atom_creator/weighted(list(/obj/item/clothing/suit/apron, /obj/item/clothing/suit/apron/overalls)),
		/obj/item/storage/plants,
		/obj/item/clothing/under/rank/hydroponics,
		/obj/item/device/analyzer/plant_analyzer,
		/obj/item/device/radio/headset/headset_service,
		/obj/item/clothing/mask/bandana/botany,
		/obj/item/clothing/head/bandana/green,
		/obj/item/material/minihoe,
		/obj/item/material/hatchet,
		/obj/item/shovel/spade,
		/obj/item/wirecutters/clippers,
		/obj/item/reagent_containers/spray/plantbgone,
	)
