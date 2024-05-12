
/*
 * Backpack
 */

/obj/item/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_backpacks.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_backpacks.dmi',
		)
	icon = 'icons/obj/storage/backpacks.dmi'
	icon_state = "backpack"
	inspect_state = TRUE
	item_state = null
	w_class = ITEM_SIZE_HUGE
	slot_flags = SLOT_BACK
	max_w_class = ITEM_SIZE_LARGE
	max_storage_space = DEFAULT_BACKPACK_STORAGE
	use_sound = SFX_SEARCH_CLOTHES
	var/worn_access = TRUE // Whether it can be opened while worn on back

	drop_sound = SFX_DROP_BACKPACK
	pickup_sound = SFX_PICKUP_BACKPACK

/obj/item/storage/backpack/Initialize()
	. = ..()

	AddComponent(/datum/component/cardborg)

/obj/item/storage/backpack/attackby(obj/item/W, mob/user)
	if(use_sound)
		playsound(loc, src.use_sound, 50, 1, -5)
	return ..()

/obj/item/storage/backpack/equipped(mob/user, slot)
	if(slot == slot_back && use_sound)
		playsound(loc, use_sound, 50, 1, -5)
	if(!worn_access && worn_check())
		close_all()
	..(user, slot)

/obj/item/storage/backpack/handle_item_insertion(obj/item/W, prevent_warning = FALSE, NoUpdate = FALSE)
	if(!worn_access && worn_check())
		to_chat(usr, SPAN("warning", "You can't insert \the [W] while \the [src] is on your back."))
		return
	. = ..()

/obj/item/storage/backpack/open(mob/user)
	if(!worn_access && worn_check())
		to_chat(user, SPAN("warning", "You can't open \the [src] while it is on your back."))
		return
	. = ..()

/obj/item/storage/backpack/proc/worn_check()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.get_inventory_slot(src) == slot_back)
			return TRUE
	return FALSE

/*
 * Backpack Types
 */

/obj/item/storage/backpack/holding
	name = "bag of holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	origin_tech = list(TECH_BLUESPACE = 4)
	icon_state = "holdingpack"
	inspect_state = FALSE
	max_w_class = ITEM_SIZE_GARGANTUAN
	max_storage_space = 56

/obj/item/storage/backpack/holding/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/storage/backpack/holding))
		investigate_log("has triggered a wormhole event. Caused by [user.key]")
		to_chat(usr, "\red The Bluespace interfaces of the two devices catastrophically malfunction!")
		log_and_message_admins("detonated a bag of holding", user, src.loc)
		explosion(get_turf(src), 0, 1, 3, 3)
		var/datum/event/E = SSevents.total_events["wormholes"]
		E.fire()
		qdel(W)
		qdel_self()
		return

	..()

/obj/item/storage/backpack/santabag
	name = "\improper Santa's gift bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space for Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	item_state = "giftbag"
	inspect_state = FALSE
	w_class = ITEM_SIZE_HUGE
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = 400 // can store a ton of shit!

/obj/item/storage/backpack/santabag/fake
	desc = "Space Santa uses this to deliver toys to all the nice children in space for Christmas! It would seem to be very large, but in real life there is no place for fairy tales."
	max_storage_space = DEFAULT_BACKPACK_STORAGE

/obj/item/storage/backpack/cultpack
	name = "trophy rack"
	desc = "It's useful for both carrying extra gear and proudly declaring your insanity."
	icon_state = "cultpack"

/obj/item/storage/backpack/clown
	name = "Giggles von Honkerton"
	desc = "It's a backpack made by Honk! Co."
	icon_state = "clownpack"

/obj/item/storage/backpack/medic
	name = "medical backpack"
	desc = "It's a backpack especially designed for use in a sterile environment."
	icon_state = "medicalpack"

/obj/item/storage/backpack/security
	name = "security backpack"
	desc = "It's a very robust backpack."
	icon_state = "securitypack"

/obj/item/storage/backpack/captain
	name = "captain's backpack"
	desc = "It's a special backpack made exclusively for officers."
	icon_state = "captainpack"

/obj/item/storage/backpack/industrial
	name = "industrial backpack"
	desc = "It's a tough backpack for the daily grind of industrial life."
	icon_state = "engiepack"

/obj/item/storage/backpack/toxins
	name = "scientist backpack"
	desc = "It's a light backpack modeled for use in laboratories and other scientific institutions."
	icon_state = "toxpack"

/obj/item/storage/backpack/nanotrasen
	name = "\improper NanoTrasen backpack"
	desc = "It's a light backpack modeled for use in laboratories and other scientific institutions. The colors on it denote it as a NanoTrasen backpack."
	icon_state = "ntpack"

/obj/item/storage/backpack/hydroponics
	name = "herbalist's backpack"
	desc = "It's a green backpack with many pockets to store plants and tools in."
	icon_state = "hydpack"

/obj/item/storage/backpack/genetics
	name = "geneticist backpack"
	desc = "It's a backpack fitted with slots for diskettes and other workplace tools."
	icon_state = "genpack"

/obj/item/storage/backpack/virology
	name = "sterile backpack"
	desc = "It's a sterile backpack able to withstand different pathogens from entering its fabric."
	icon_state = "viropack"

/obj/item/storage/backpack/chemistry
	name = "chemistry backpack"
	desc = "It's an orange backpack which was designed to hold beakers, pill bottles and bottles."
	icon_state = "chempack"

/obj/item/storage/backpack/emt
	name = "emt backpack"
	desc = "It's a blue backpack with white cross on it which was designed for initial medical emergency works."
	icon_state = "emtpack"

/*
 * Duffle Types
 */

/obj/item/storage/backpack/dufflebag
	name = "dufflebag"
	desc = "A large dufflebag for holding extra things."
	icon_state = "duffle"
	w_class = ITEM_SIZE_HUGE
	max_storage_space = DEFAULT_BACKPACK_STORAGE + 14
	worn_access = FALSE

/obj/item/storage/backpack/dufflebag/syndie
	name = "black dufflebag"
	desc = "A large dufflebag for holding extra tactical supplies."
	icon_state = "duffle_syndie"

/obj/item/storage/backpack/dufflebag/syndie/med
	name = "medical dufflebag"
	desc = "A large dufflebag for holding extra tactical medical supplies."
	icon_state = "duffle_syndiemed"

/obj/item/storage/backpack/dufflebag/syndie/ammo
	name = "ammunition dufflebag"
	desc = "A large dufflebag for holding extra weapons ammunition and supplies."
	icon_state = "duffle_syndieammo"

/obj/item/storage/backpack/dufflebag/captain
	name = "captain's dufflebag"
	desc = "A large dufflebag for holding extra captainly goods."
	icon_state = "duffle_captain"

/obj/item/storage/backpack/dufflebag/med
	name = "medical dufflebag"
	desc = "A large dufflebag for holding extra medical supplies."
	icon_state = "duffle_med"

/obj/item/storage/backpack/dufflebag/emt
	name = "emt dufflebag"
	desc = "A large dufflebag for holding extra medical emergency supplies."
	icon_state = "duffle_emt"

/obj/item/storage/backpack/dufflebag/sec
	name = "security dufflebag"
	desc = "A large dufflebag for holding extra security supplies and ammunition."
	icon_state = "duffle_sec"

/obj/item/storage/backpack/dufflebag/eng
	name = "industrial dufflebag"
	desc = "A large dufflebag for holding extra tools and supplies."
	icon_state = "duffle_eng"

/*
 * Satchel Types
 */

/obj/item/storage/backpack/satchel
	name = "satchel"
	desc = "A trendy looking satchel."
	icon_state = "satchel-norm"
	max_w_class = ITEM_SIZE_NORMAL // It's not nearly as spaceous as backpacks, how TF can you fit a rifle inside?
	item_state_slots = null

/obj/item/storage/backpack/satchel/grey
	name = "grey satchel"

/obj/item/storage/backpack/satchel/grey/withwallet
	startswith = list(/obj/item/storage/wallet/random)

/obj/item/storage/backpack/satchel/leather //brown, master type
	name = "brown leather satchel"
	desc = "A very fancy satchel made of some kind of leather."
	icon_state = "satchel"
	color = "#3d2711"

/obj/item/storage/backpack/satchel/leather/Initialize()
	. = ..()
	update_icon()

/obj/item/storage/backpack/satchel/leather/on_update_icon()
	ClearOverlays()
	AddOverlays(OVERLAY(icon, (being_inspected ? "satchel_overlay-open" : "satchel_overlay"), alpha, RESET_COLOR))

/obj/item/storage/backpack/satchel/leather/khaki
	name = "khaki leather satchel"
	color = "#baa481"

/obj/item/storage/backpack/satchel/leather/black
	name = "black leather satchel"
	color = "#3F3F3F"

/obj/item/storage/backpack/satchel/leather/navy
	name = "navy leather satchel"
	color = "#1c2133"

/obj/item/storage/backpack/satchel/leather/olive
	name = "olive leather satchel"
	color = "#544f3d"

/obj/item/storage/backpack/satchel/leather/reddish
	name = "auburn leather satchel"
	color = "#512828"

/obj/item/storage/backpack/satchel/pocketbook //black, master type
	name = "black pocketbook"
	desc = "A neat little folding clasp pocketbook with a shoulder sling."
	icon_state = "pocketbook"
	max_storage_space = DEFAULT_LARGEBOX_STORAGE
	color = "#3F3F3F"
	item_state_slots = list(
		slot_l_hand_str = "satchel-flat",
		slot_r_hand_str = "satchel-flat",
		)

/obj/item/storage/backpack/satchel/pocketbook/Initialize()
	. = ..()
	update_icon()

/obj/item/storage/backpack/satchel/pocketbook/on_update_icon()
	ClearOverlays()
	AddOverlays(OVERLAY(icon, (being_inspected ? "pocketbook_overlay-open" : "pocketbook_overlay"), alpha, RESET_COLOR))

/obj/item/storage/backpack/satchel/pocketbook/brown
	name = "brown pocketbook"
	color = "#3d2711"

/obj/item/storage/backpack/satchel/pocketbook/reddish
	name = "auburn pocketbook"
	color = "#512828"

/obj/item/storage/backpack/satchel/eng
	name = "industrial satchel"
	desc = "A tough satchel with extra pockets."
	icon_state = "satchel-eng"

/obj/item/storage/backpack/satchel/med
	name = "medical satchel"
	desc = "A sterile satchel used in medical departments."
	icon_state = "satchel-med"

/obj/item/storage/backpack/satchel/vir
	name = "virologist satchel"
	desc = "A sterile satchel with virologist colours."
	icon_state = "satchel-vir"

/obj/item/storage/backpack/satchel/chem
	name = "chemist satchel"
	desc = "A sterile satchel with chemist colours."
	icon_state = "satchel-chem"

/obj/item/storage/backpack/satchel/gen
	name = "geneticist satchel"
	desc = "A sterile satchel with geneticist colours."
	icon_state = "satchel-gen"

/obj/item/storage/backpack/satchel/emt
	name = "emt satchel"
	desc = "A sterile satchel with EMT colours."
	icon_state = "satchel-emt"

/obj/item/storage/backpack/satchel/tox
	name = "scientist satchel"
	desc = "Useful for holding research materials."
	icon_state = "satchel-tox"

/obj/item/storage/backpack/satchel/nt
	name = "\improper NanoTrasen satchel"
	desc = "Useful for holding research materials. The colors on it denote it as a NanoTrasen bag."
	icon_state = "satchel-nt"
	item_state_slots = list(
		slot_l_hand_str = "satchel-gen", // Looks surprisingly close
		slot_r_hand_str = "satchel-gen",
		)

/obj/item/storage/backpack/satchel/sec
	name = "security satchel"
	desc = "A robust satchel for security related needs."
	icon_state = "satchel-sec"

/obj/item/storage/backpack/satchel/hyd
	name = "hydroponics satchel"
	desc = "A green satchel for plant related work."
	icon_state = "satchel_hyd"

/obj/item/storage/backpack/satchel/cap
	name = "captain's satchel"
	desc = "An exclusive satchel for officers."
	icon_state = "satchel-cap"

//ERT backpacks.
/obj/item/storage/backpack/ert
	name = "emergency response team backpack"
	desc = "A spacious backpack with lots of pockets, used by members of the Emergency Response Team."
	icon_state = "ert_commander"
	inspect_state = FALSE
	item_state_slots = list(
		slot_l_hand_str = "securitypack",
		slot_r_hand_str = "securitypack",
		)

//Commander
/obj/item/storage/backpack/ert/commander
	name = "emergency response team commander backpack"
	desc = "A spacious backpack with lots of pockets, worn by the commander of an Emergency Response Team."

//Security
/obj/item/storage/backpack/ert/security
	name = "emergency response team security backpack"
	desc = "A spacious backpack with lots of pockets, worn by security members of an Emergency Response Team."
	icon_state = "ert_security"

//Engineering
/obj/item/storage/backpack/ert/engineer
	name = "emergency response team engineer backpack"
	desc = "A spacious backpack with lots of pockets, worn by engineering members of an Emergency Response Team."
	icon_state = "ert_engineering"

//Medical
/obj/item/storage/backpack/ert/medical
	name = "emergency response team medical backpack"
	desc = "A spacious backpack with lots of pockets, worn by medical members of an Emergency Response Team."
	icon_state = "ert_medical"

/*
 * Messenger Bags
 */

/obj/item/storage/backpack/messenger
	name = "messenger bag"
	desc = "A sturdy backpack worn over one shoulder."
	icon_state = "courierbag"

/obj/item/storage/backpack/messenger/chem
	name = "chemistry messenger bag"
	desc = "A sterile backpack worn over one shoulder. This one is in Chemsitry colors."
	icon_state = "courierbagchem"

/obj/item/storage/backpack/messenger/med
	name = "medical messenger bag"
	desc = "A sterile backpack worn over one shoulder used in medical departments."
	icon_state = "courierbagmed"

/obj/item/storage/backpack/messenger/viro
	name = "virology messenger bag"
	desc = "A sterile backpack worn over one shoulder. This one is in Virology colors."
	icon_state = "courierbagviro"

/obj/item/storage/backpack/messenger/emt
	name = "emt messenger bag"
	desc = "A blue backpack with white cross on it worn over one shoulder. This one is in EMT colors."
	icon_state = "courierbagemt"

/obj/item/storage/backpack/messenger/tox
	name = "research messenger bag"
	desc = "A backpack worn over one shoulder. Useful for holding science materials."
	icon_state = "courierbagtox"

/obj/item/storage/backpack/messenger/nt
	name = "\improper NanoTrasen messenger bag"
	desc = "A backpack worn over one shoulder. Useful for holding science materials. The colors on it denote it as a NanoTrasen bag."
	icon_state = "courierbagnt"

/obj/item/storage/backpack/messenger/com
	name = "captain's messenger bag"
	desc = "A special backpack worn over one shoulder. This one is made specifically for officers."
	icon_state = "courierbagcom"

/obj/item/storage/backpack/messenger/engi
	name = "engineering messenger bag"
	desc = "A strong backpack worn over one shoulder. This one is designed for Industrial work."
	icon_state = "courierbagengi"

/obj/item/storage/backpack/messenger/hyd
	name = "hydroponics messenger bag"
	desc = "A backpack worn over one shoulder. This one is designed for plant-related work."
	icon_state = "courierbaghyd"

/obj/item/storage/backpack/messenger/sec
	name = "security messenger bag"
	desc = "A tactical backpack worn over one shoulder. This one is in Security colors."
	icon_state = "courierbagsec"

//Smuggler's satchel
/obj/item/storage/backpack/satchel/flat
	name = "\improper Smuggler's satchel"
	desc = "A very slim satchel that can easily fit into tight spaces."
	icon_state = "satchel-flat"
	item_state = "satchel-norm"
	level = 1
	w_class = ITEM_SIZE_NORMAL //Can fit in backpacks itself.
	storage_slots = 5
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = 15
	cant_hold = list(/obj/item/storage/backpack/satchel/flat) //muh recursive backpacks
	startswith = list(
		/obj/item/stack/tile/floor,
		/obj/item/crowbar
		)
	item_state_slots = list(
		slot_l_hand_str = "satchel-flat",
		slot_r_hand_str = "satchel-flat",
		)

/obj/item/storage/backpack/satchel/flat/hide(i)
	set_invisibility(i ? 101 : 0)
	anchored = i ? TRUE : FALSE
	alpha = i ? 128 : initial(alpha)

/obj/item/storage/backpack/carppack
	name = "Space carp backpack"
	desc = "It's a backpack made of real space carp."
	icon_state = "carppack"
	inspect_state = FALSE
	item_state_slots = list(
		slot_l_hand_str = "backpack",
		slot_r_hand_str = "backpack",
		)

/obj/item/storage/backpack/messenger/shoulder_bag
	name = "shoulder bag"
	desc = "A complex backpack with multiple compartments."
	icon_state = "shoulder_bag"
	item_state_slots = list(
		slot_l_hand_str = "satchel",
		slot_r_hand_str = "satchel",
		)

/obj/item/storage/backpack/shipack
	name = "Spaceship backpack"
	desc = "Some say that humanity conquered space inside such things. Today it has obviously broken but looks neat, and you can store your stuff inside."
	icon_state = "shipack"
	inspect_state = FALSE
	item_state_slots = list(
		slot_l_hand_str = "shipack",
		slot_r_hand_str = "shipack",
		)
