/obj/item/storage/garment
	name = "garment bag"
	desc = "A bag for storing multiple clothig items in a better and convenient way!"

	icon = 'icons/obj/storage/misc.dmi'
	icon_state = "garment"

	can_hold = list(
		/obj/item/clothing
	)

	max_w_class = ITEM_SIZE_LARGE
	max_storage_space = 120
	storage_slots = 20

	use_to_pickup = TRUE
	allow_quick_empty = TRUE
	allow_quick_gather = TRUE

	inspect_state = TRUE

/obj/item/storage/garment/hos
	name = "head of security's garment bag"
	desc = "A bag for storing multiple clothig items in a better and convenient way! This one belongs to the head of security."

	startswith = list(
		/obj/item/clothing/mask/gas/clear,
		/obj/item/clothing/glasses/hud/aviators/security,
		/obj/item/clothing/head/HoS,
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/HoS/dermal,
		/obj/item/clothing/head/beret/sec/corporate/hos,
		/obj/item/clothing/accessory/holster/waist,
		/obj/item/clothing/accessory/storage/black_vest,
		/obj/item/clothing/under/rank/head_of_security/jensen,
		/obj/item/clothing/suit/armor/vest/hos_heavy,
		/obj/item/clothing/suit/armor/hos,
		/obj/item/clothing/suit/armor/hos/jensen,
		/obj/item/clothing/shoes/swat

	)

/obj/item/storage/garment/warden
	name = "warden's garment bag"
	desc = "A bag for storing multiple clothig items in a better and convenient way! This one belongs to the warden."

	startswith = list(
		/obj/item/clothing/glasses/hud/aviators/security,
		/obj/item/clothing/head/warden,
		/obj/item/clothing/head/warden/drill,
		/obj/item/clothing/head/beret/sec/corporate/warden,
		/obj/item/clothing/accessory/holster/waist,
		/obj/item/clothing/accessory/storage/black_vest,
		/obj/item/clothing/suit/armor/vest/warden_heavy,
		/obj/item/clothing/suit/armor/vest/warden,
		/obj/item/clothing/under/rank/warden
	)

/obj/item/storage/garment/head_of_personnel
	name = "head of personnel's garment bag"
	desc = "A bag for storing multiple clothig items in a better and convenient way! This one belongs to the head of personnel."

	startswith = list(
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/caphat/hop,
		/obj/item/clothing/accessory/holster/waist,
		/obj/item/clothing/under/dress/dress_hr,
		/obj/item/clothing/under/dress/dress_hop,
		/obj/item/clothing/under/rank/head_of_personnel,
		/obj/item/clothing/under/rank/head_of_personnel/whimsy,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/clothing/shoes/black,
		/obj/item/clothing/shoes/white
	)

/obj/item/storage/garment/captain
	name = "captain's garment bag"
	desc = "A bag for storing multiple clothig items in a better and convenient way! This one belongs to the captain."

	startswith = list(
		/obj/item/clothing/head/caphat/cap,
		/obj/item/clothing/head/caphat/formal,
		/obj/item/clothing/head/helmet/captain,
		/obj/item/clothing/gloves/captain,
		/obj/item/clothing/accessory/holster/thigh,
		/obj/item/clothing/under/rank/captain,
		/obj/item/clothing/under/captainformal,
		/obj/item/clothing/under/dress/dress_cap,
		/obj/item/clothing/suit/captunic,
		/obj/item/clothing/suit/captunic/formal,
		/obj/item/clothing/suit/captunic/capjacket,
		/obj/item/clothing/suit/armor/vest/capcarapace,
		/obj/item/clothing/shoes/brown
	)

/obj/item/storage/garment/chief_engineer
	name = "chief engineer's garment bag"
	desc = "A bag for storing multiple clothig items in a better and convenient way! This one belongs to the chief engineer."

	startswith = list(
		/obj/item/clothing/glasses/welding/superior,
		/obj/item/clothing/head/hardhat/white,
		/obj/item/clothing/gloves/insulated,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/under/rank/chief_engineer,
		/obj/item/clothing/shoes/brown
	)

/obj/item/storage/garment/quartermaster
	name = "quartermaster's garment bag"
	desc = "A bag for storing multiple clothig items in a better and convenient way! This one belongs to the quartermaster."

	startswith = list(
		/obj/item/clothing/glasses/hud/standard/meson,
		/obj/item/clothing/head/soft,
		/obj/item/clothing/gloves/thick,
		/obj/item/clothing/under/rank/cargo,
		/obj/item/clothing/shoes/brown
	)

/obj/item/storage/garment/chief_medical_officer
	name = "chief medical officer's garment bag"
	desc = "A bag for storing multiple clothig items in a better and convenient way! This one belongs to the chief medical officer."

	startswith = list(
		/obj/item/clothing/mask/gas/clear,
		/obj/item/clothing/glasses/hud/standard/medical,
		/obj/item/clothing/accessory/stethoscope,
		/obj/item/clothing/under/rank/chief_medical_officer,
		/obj/item/clothing/suit/storage/toggle/labcoat/cmo,
		/obj/item/clothing/suit/storage/toggle/labcoat/cmoalt,
		/obj/item/clothing/accessory/storage/white_vest,
		/obj/item/clothing/gloves/latex,
		/obj/item/clothing/shoes/brown,
		/obj/item/clothing/shoes/white
	)

/obj/item/storage/garment/research_director
	name = "reseach director's garment bag"
	desc = "A bag for storing multiple clothig items in a better and convenient way! This one belongs to the research director."

	startswith = list(
		/obj/item/clothing/glasses/welding/superior,
		/obj/item/clothing/glasses/hud/standard/science,
		/obj/item/clothing/gloves/latex,
		/obj/item/clothing/under/rank/research_director,
		/obj/item/clothing/under/rank/research_director/rdalt,
		/obj/item/clothing/under/rank/research_director/dress_rd,
		/obj/item/clothing/suit/storage/toggle/labcoat/rd,
		/obj/item/clothing/shoes/leather
	)
