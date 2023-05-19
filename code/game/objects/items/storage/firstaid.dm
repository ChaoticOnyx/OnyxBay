/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Surgery Kits
 */

/*
 * First Aid Kits
 */
/obj/item/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon_state = "firstaid"
	throw_range = 8
	force = 7.0
	mod_weight = 1.25
	mod_reach = 0.7
	mod_handy = 0.7
	max_w_class = ITEM_SIZE_SMALL
	max_storage_space = DEFAULT_BOX_STORAGE
	attack_verb = list("doctored", "medicined", "unhealed", "fist-aided")

/obj/item/storage/firstaid/regular
	icon_state = "firstaid"

	startswith = list(
		/obj/item/device/healthanalyzer,
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/stack/medical/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/storage/pill_bottle/antidexafen,
		/obj/item/storage/pill_bottle/paracetamol
		)

/obj/item/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "It's an emergency medical kit for when the toxins lab <i>-spontaneously-</i> burns down."
	icon_state = "firstaid-fire"
	item_state = "firstaid-ointment"

	startswith = list(
		/obj/item/device/healthanalyzer,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/storage/pill_bottle/kelotane,
		/obj/item/storage/pill_bottle/paracetamol
		)

/obj/item/storage/firstaid/fire/Initialize()
	icon_state = pick("firstaid-fire", "firstaid-fire2")
	. = ..()

/obj/item/storage/firstaid/toxin
	name = "toxin first-aid kit"
	desc = "Used to treat when you have a high amount of toxins in your body."
	icon_state = "firstaid-tox"
	item_state = "firstaid-toxin"

	startswith = list(
		/obj/item/device/healthanalyzer,
		/obj/item/storage/pill_bottle/dylovene,
		/obj/item/reagent_containers/syringe/antitoxin/packaged = 3,
		/obj/item/reagent_containers/vessel/plastic/waterbottle
		)

/obj/item/storage/firstaid/toxin/Initialize()
	icon_state = pick("firstaid-tox", "firstaid-tox2", "firstaid-tox3", "firstaid-tox4")
	. = ..()

/obj/item/storage/firstaid/o2
	name = "oxygen deprivation first-aid kit"
	desc = "A box full of oxygen goodies."
	icon_state = "firstaid-o2"
	item_state = "firstaid-o2"

	startswith = list(
		/obj/item/device/healthanalyzer,
		/obj/item/storage/pill_bottle/dexalin,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/reagent_containers/syringe/inaprovaline/packaged,
		/obj/item/tank/emergency/oxygen,
		/obj/item/clothing/mask/breath
		)

/obj/item/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Contains advanced medical treatments."
	icon_state = "firstaid-adv"
	item_state = "firstaid-advanced"

	startswith = list(
		/obj/item/device/healthanalyzer,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical/advanced/bruise_pack = 2,
		/obj/item/stack/medical/advanced/ointment = 2,
		/obj/item/stack/medical/splint
		)

/obj/item/storage/firstaid/combat
	name = "combat medical kit"
	desc = "Contains advanced medical treatments."
	icon_state = "firstaid-bezerk"
	item_state = "firstaid-advanced"
	storage_slots = 9 // Tacticoolness makes it more spaceous

	startswith = list(
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/storage/pill_bottle/bicaridine,
		/obj/item/storage/pill_bottle/dermaline,
		/obj/item/storage/pill_bottle/dexalin_plus,
		/obj/item/storage/pill_bottle/dylovene,
		/obj/item/storage/pill_bottle/tramadol,
		/obj/item/storage/pill_bottle/spaceacillin,
		/obj/item/stack/medical/splint
		)

/obj/item/storage/firstaid/surgery
	name = "surgery kit"
	desc = "Contains tools for surgery. Has precise foam fitting for safe transport and automatically sterilizes the content between uses."
	icon_state = "surgerykit"
	item_state = "firstaid-surgery"

	storage_slots = 14
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = null

	can_hold = list(
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/hemostat,
		/obj/item/retractor,
		/obj/item/scalpel,
		/obj/item/surgicaldrill,
		/obj/item/bonegel,
		/obj/item/FixOVein,
		/obj/item/organfixer,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/nanopaste
		)

	startswith = list(
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/hemostat,
		/obj/item/retractor,
		/obj/item/scalpel,
		/obj/item/surgicaldrill,
		/obj/item/bonegel,
		/obj/item/FixOVein,
		/obj/item/organfixer/standard,
		/obj/item/stack/medical/advanced/bruise_pack,
		)
