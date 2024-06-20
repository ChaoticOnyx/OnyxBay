///Hoods for winter coats and chaplain hoodie etc

/obj/item/clothing/suit/storage/hooded
	initial_closed = TRUE
	var/obj/item/clothing/head/winterhood/hood
	var/hoodtype = null //so the chaplain hoodie or other hoodies can override this
	var/hood_on = FALSE

/obj/item/clothing/suit/storage/hooded/Initialize()
	. = ..()
	if(!base_icon_state)
		base_icon_state = icon_state
	MakeHood()

/obj/item/clothing/suit/storage/hooded/Destroy()
	QDEL_NULL(hood)
	return ..()

/obj/item/clothing/suit/storage/hooded/proc/MakeHood()
	if(hood || !hoodtype)
		return

	hood = new hoodtype(src)

/obj/item/clothing/suit/storage/hooded/ui_action_click()
	ToggleHood()

/obj/item/clothing/suit/storage/hooded/equipped(mob/user, slot)
	if(slot != slot_wear_suit)
		RemoveHood()
	..()

/obj/item/clothing/suit/storage/hooded/proc/RemoveHood()
	if(!hood)
		return

	hood_on = FALSE
	update_icon()

	if(ishuman(hood.loc))
		var/mob/living/carbon/H = hood.loc
		H.drop(hood, force = TRUE)
		H.update_inv_wear_suit()

	hood.forceMove(src)

/obj/item/clothing/suit/storage/hooded/dropped()
	. = ..()
	RemoveHood()

/obj/item/clothing/suit/storage/hooded/proc/ToggleHood()
	if(hood_on)
		RemoveHood()
		return

	if(!ishuman(loc))
		return

	var/mob/living/carbon/human/H = src.loc
	if(H.wear_suit != src)
		to_chat(H, SPAN("warning", "You must be wearing \the [src] to put up the hood!"))
		return

	if(H.head)
		to_chat(H, SPAN("warning", "You're already wearing something on your head!"))
		return

	H.equip_to_slot_if_possible(hood, slot_head, 0, 0, 1)
	hood_on = TRUE
	update_icon()
	H.update_inv_wear_suit()

/obj/item/clothing/suit/storage/hooded/on_update_icon()
	icon_state = base_icon_state
	if(hood_on)
		icon_state += "_t"


/obj/item/clothing/suit/storage/hooded/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon_state = "coatwinter"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10)
	action_button_name = "Toggle Winter Hood"
	hoodtype = /obj/item/clothing/head/winterhood
	allowed = list (/obj/item/pen, /obj/item/paper, /obj/item/device/flashlight,/obj/item/storage/fancy/cigarettes, /obj/item/storage/box/matches, /obj/item/reagent_containers/vessel/flask)
	siemens_coefficient = 0.6

/obj/item/clothing/head/winterhood
	name = "winter hood"
	desc = "A hood attached to a heavy winter jacket."
	icon_state = "generic_hood"
	body_parts_covered = HEAD
	cold_protection = HEAD
	flags_inv = HIDEEARS | BLOCKHAIR
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/storage/hooded/wintercoat/captain
	name = "captain's winter coat"
	icon_state = "coatcaptain"
	armor = list(melee = 20, bullet = 15, laser = 20, energy = 10, bomb = 15, bio = 0)

/obj/item/clothing/suit/storage/hooded/wintercoat/security
	name = "security winter coat"
	icon_state = "coatsecurity"
	armor = list(melee = 25, bullet = 20, laser = 20, energy = 15, bomb = 20, bio = 0)

/obj/item/clothing/suit/storage/hooded/wintercoat/medical
	name = "medical winter coat"
	icon_state = "coatmedical"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 50)

/obj/item/clothing/suit/storage/hooded/wintercoat/science
	name = "science winter coat"
	icon_state = "coatscience"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 10, bio = 0)

/obj/item/clothing/suit/storage/hooded/wintercoat/engineering
	name = "engineering winter coat"
	icon_state = "coatengineer"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0)

/obj/item/clothing/suit/storage/hooded/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	icon_state = "coatatmos"

/obj/item/clothing/suit/storage/hooded/wintercoat/hydro
	name = "hydroponics winter coat"
	icon_state = "coathydro"

/obj/item/clothing/suit/storage/hooded/wintercoat/cargo
	name = "cargo winter coat"
	icon_state = "coatcargo"

/obj/item/clothing/suit/storage/hooded/wintercoat/miner
	name = "mining winter coat"
	icon_state = "coatminer"
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0)

/obj/item/clothing/suit/storage/hooded/wintercoat/centcom
	name = "centcom winter coat"
	icon_state = "coatcentcom"
	armor = list(melee = 20, bullet = 15, laser = 20, energy = 10, bomb = 15, bio = 0)

/obj/item/clothing/suit/storage/hooded/wintercoat/hop
	name = "hop winter coat"
	icon_state = "coathop"

/obj/item/clothing/suit/storage/hooded/wintercoat/qm
	name = "qm winter coat"
	icon_state = "coatqm"

/obj/item/clothing/suit/storage/hooded/wintercoat/janitor
	name = "janitor winter coat"
	icon_state = "coatjanitor"

/obj/item/clothing/suit/storage/hooded/wintercoat/ce
	name = "ce winter coat"
	icon_state = "coatce"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 10, bomb = 0, bio = 0)

/obj/item/clothing/suit/storage/hooded/wintercoat/cmo
	name = "cmo winter coat"
	icon_state = "coatcmo"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10)

/obj/item/clothing/suit/storage/hooded/wintercoat/chemistry
	name = "chemistry winter coat"
	icon_state = "coatchemistry"

/obj/item/clothing/suit/storage/hooded/wintercoat/viro
	name = "viro winter coat"
	icon_state = "coatviro"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10)

/obj/item/clothing/suit/storage/hooded/wintercoat/paramed
	name = "paramed winter coat"
	icon_state = "coatparamed"

/obj/item/clothing/suit/storage/hooded/wintercoat/rd
	name = "rd winter coat"
	icon_state = "coatrd"
	armor = list(melee = 0, bullet = 0, laser = 10, energy = 0, bomb = 10, bio = 0)

/obj/item/clothing/suit/storage/hooded/wintercoat/robotics
	name = "robotics winter coat"
	icon_state = "coatrobotics"


/obj/item/clothing/suit/storage/hooded/hoodie
	name = "hoodie"
	desc = "A warm sweatshirt."
	icon_state = "hoodie"
	min_cold_protection_temperature = -20 CELSIUS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	action_button_name = "Toggle Hood"
	hoodtype = /obj/item/clothing/head/hoodiehood

/obj/item/clothing/head/hoodiehood
	name = "hoodie hood"
	desc = "A hood attached to a warm sweatshirt."
	icon_state = "generic_hood"
	body_parts_covered = HEAD
	min_cold_protection_temperature = -20 CELSIUS
	cold_protection = HEAD
	flags_inv = HIDEEARS | BLOCKHAIR


/obj/item/clothing/suit/storage/hooded/toggle
	initial_closed = FALSE
	coverage = 0.8

	var/zipped = FALSE

/obj/item/clothing/suit/storage/hooded/toggle/on_update_icon()
	icon_state = base_icon_state
	if(hood_on)
		icon_state += "_t"
	if(!zipped)
		icon_state += "_open"

/obj/item/clothing/suit/storage/hooded/toggle/verb/toggle()
	set name = "Toggle Zipper"
	set category = "Object"
	set src in usr

	if(!CanPhysicallyInteract(usr))
		return FALSE

	zipped = !zipped

	if(zipped)
		to_chat(usr, "You zip up \the [src].")
		flags_inv |= HIDEJUMPSUITACCESSORIES
		coverage = 1.0
	else
		to_chat(usr, "You unzip \the [src].")
		flags_inv &= HIDEJUMPSUITACCESSORIES
		coverage = 0.8

	update_icon()
	update_clothing_icon()

/obj/item/clothing/suit/storage/hooded/toggle/hoodie
	name = "zip-up hoodie"
	desc = "A warm sweatshirt with a zipper."
	icon_state = "ziphoodie_open"
	base_icon_state = "ziphoodie"
	min_cold_protection_temperature = -20 CELSIUS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	action_button_name = "Toggle Hood"
	hoodtype = /obj/item/clothing/head/hoodiehood
