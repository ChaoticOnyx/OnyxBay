/datum/keybinding/human
	category = CATEGORY_HUMAN

/datum/keybinding/human/can_use(client/user)
	return ishuman(user.mob)

/datum/keybinding/human/quick_equip
	hotkey_keys = list("E")
	name = "quick_equip"
	full_name = "Quick Equip"
	description = "Quickly puts an item in the best slot available"

/datum/keybinding/human/quick_equip/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.quick_equip()
	return TRUE

/datum/keybinding/human/give
	hotkey_keys = list("None")
	name = "give_item"
	full_name = "Give Item"
	description = "Give the item you're currently holding"

/datum/keybinding/human/give/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.give()
	return TRUE

/datum/keybinding/human/block
	hotkey_keys = list("C") // PAGEUP
	name = "block"
	full_name = "Toggle Block"
	description = ""

/datum/keybinding/human/block/down(client/user)
	var/mob/living/carbon/human/C = user.mob
	C.useblock()
	return TRUE

/datum/keybinding/human/powersuit_select_module
	hotkey_keys = list("V")
	name = "powersuit_select_module"
	full_name = "Select Powersuit Module"
	description = "Opens a worn powersuit's module selection."

/datum/keybinding/human/powersuit_select_module/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	var/obj/item/rig/R = locate() in H
	if(istype(R))
		R.select_module()
	return TRUE
