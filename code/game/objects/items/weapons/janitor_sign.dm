/obj/item/weapon/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	force = 5.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.75
	mod_reach = 1.0
	mod_handy = 0.75
	attack_verb = list("warned", "cautioned", "smashed")
	matter = list(MATERIAL_STEEL = 300, MATERIAL_GLASS = 50)

/obj/item/weapon/caution/cone
	desc = "This cone is trying to warn you of something!"
	name = "warning cone"
	icon_state = "cone"
	slot_flags = SLOT_HEAD
	mod_weight = 0.8
	mod_reach = 0.8
	mod_handy = 0.5
