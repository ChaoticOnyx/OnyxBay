#define WARDROBE_BLIND_MESSAGE(fool) "\The [src] flashes a light at \the [fool] as it states a message."

/obj/structure/undies_wardrobe
	name = "underwear wardrobe"
	desc = "Holds item of clothing you shouldn't be showing off in the hallways."
	icon = 'icons/obj/closet.dmi'
	icon_state = "cabinet_closed"
	density = 1

	var/static/list/amount_of_underwear_by_id_card

/obj/structure/undies_wardrobe/attackby(obj/item/underwear/underwear, mob/user)
	if(istype(underwear))
		if(!user.drop(underwear))
			return
		qdel(underwear)
		user.visible_message("<span class='notice'>\The [user] inserts \their [underwear.name] into \the [src].</span>", "<span class='notice'>You insert your [underwear.name] into \the [src].</span>")

		var/id = user.get_id_card()
		var/message
		if(id)
			message = "ID card detected. Your underwear quota for this shift as been increased, if applicable."
		else
			message = "No ID card detected. Thank you for your contribution."

		audible_message(message, WARDROBE_BLIND_MESSAGE(user))

		var/number_of_underwear = LAZYACCESS(amount_of_underwear_by_id_card, id) - 1
		if(number_of_underwear)
			LAZYSET(amount_of_underwear_by_id_card, id, number_of_underwear)
			register_signal(id, SIGNAL_QDELETING, nameof(.proc/remove_id_card))
		else
			remove_id_card(id)

	else
		..()

/obj/structure/undies_wardrobe/proc/remove_id_card(id_card)
	LAZYREMOVE(amount_of_underwear_by_id_card, id_card)
	unregister_signal(id_card, SIGNAL_QDELETING)

/obj/structure/undies_wardrobe/proc/human_who_can_use_underwear(mob/living/carbon/human/H)
	if(!istype(H) || !H.species || !(H.species.species_appearance_flags & HAS_UNDERWEAR))
		return FALSE
	return TRUE

/obj/structure/undies_wardrobe/attack_hand(mob/user)
	if(!human_who_can_use_underwear(user))
		to_chat(user, SPAN_WARNING("Sadly there's nothing in here for you to wear."))
		return

	tgui_interact(user)

/obj/structure/undies_wardrobe/tgui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "UnderWardrobe", name)
		ui.open()

/obj/structure/undies_wardrobe/tgui_data(mob/user)
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id = H?.get_id_card()

	var/list/data = list(
		"user" = id? id.name : null,
		"mayClaim" = id ? length(GLOB.underwear.categories) - LAZYACCESS(amount_of_underwear_by_id_card, id) : 0,
	)

	return data

/obj/structure/undies_wardrobe/tgui_static_data(mob/user)
	var/list/data = list(
		"underwearCategories" = list()
	)

	for(var/datum/category_group/underwear/UWC in GLOB.underwear.categories)
		var/list/cat_data = list("name" = UWC.name)

		for(var/datum/category_item/underwear/UWI in UWC.items)
			if(!UWI.underwear_type)
				continue

			var/list/item_data = list(
				"name" = UWI.name
			)
			for(var/tweak in UWI.tweaks)
				item_data["tweaks"] += list(tweak)

			cat_data["catItems"] += list(item_data)

		data["underwearCategories"] += list(cat_data)

	return data

/obj/structure/undies_wardrobe/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("equip")
			var/datum/category_group/underwear/UWC = GLOB.underwear.categories_by_name[params["underwearCat"]]
			if(!istype(UWC))
				return

			var/datum/category_item/underwear/UWI = UWC.items_by_name[params["underwearItem"]]
			if(!istype(UWI))
				return

			var/mob/living/carbon/human/H = usr
			if(!istype(H))
				return

			var/id = H.get_id_card()
			if(!id)
				audible_message("No ID card detected. Unable to acquire your underwear quota for this shift.", WARDROBE_BLIND_MESSAGE(H))
				return

			var/list/metadata_list = list()
			for(var/tweak in UWI.tweaks)
				var/datum/gear_tweak/gt = tweak
				var/metadata = gt.get_metadata(H, "Adjust underwear")
				if(!metadata)
					return
				metadata_list["[gt]"] = metadata

			var/current_quota = LAZYACCESS(amount_of_underwear_by_id_card, id)
			if(current_quota >= length(GLOB.underwear.categories))
				audible_message("You have already used up your underwear quota for this shift. Please return previously acquired items to increase it.", WARDROBE_BLIND_MESSAGE(H))
				return

			LAZYSET(amount_of_underwear_by_id_card, id, ++current_quota)
			var/obj/UW = UWI.create_underwear(metadata_list)
			H.pick_or_drop(UW, loc)
			return TRUE

/obj/structure/undies_wardrobe/proc/exlude_none(list/L)
	. = L.Copy()
	for(var/e in .)
		var/datum/category_item/underwear/UWI = e
		if(!UWI.underwear_type)
			. -= UWI

#undef WARDROBE_BLIND_MESSAGE
