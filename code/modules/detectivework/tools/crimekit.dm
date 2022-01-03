//crime scene kit
/obj/item/storage/briefcase/crimekit
	name = "crime scene kit"
	desc = "A stainless steel-plated carrycase for all your forensic needs. Feels heavy."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "case"
	item_state = "case"
	startswith = list(
		/obj/item/storage/box/swabs,
		/obj/item/storage/box/fingerprints,
		/obj/item/reagent_containers/spray/luminol,
		/obj/item/device/uv_light,
		/obj/item/forensics/sample_kit,
		/obj/item/forensics/sample_kit/powder,
		)
