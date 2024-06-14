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
	hotkey_keys = list("C")
	name = "block"
	full_name = "Toggle Block"
	description = ""

/datum/keybinding/human/block/down(client/user)
	var/mob/living/carbon/human/C = user.mob
	C.useblock()
	return TRUE

/datum/keybinding/human/bite
	hotkey_keys = list("B")
	name = "bite"
	full_name = "Toggle Bite"
	description = ""

/datum/keybinding/human/bite/down(client/user)
	var/mob/living/carbon/human/C = user.mob
	C.mmb_switch(MMB_BITE)
	return TRUE

/datum/keybinding/human/jump
	hotkey_keys = list("J")
	name = "jump"
	full_name = "Toggle Jump"
	description = ""

/datum/keybinding/human/jump/down(client/user)
	var/mob/living/carbon/human/C = user.mob
	C.mmb_switch(MMB_JUMP)
	return TRUE
