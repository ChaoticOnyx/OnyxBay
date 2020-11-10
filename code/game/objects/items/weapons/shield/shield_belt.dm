/obj/item/weapon/shield/shield_belt
	name = "shield belt"
	desc = "Protects user from bullets and lasers, but don't allow you to shoot"
	icon = 'icons/obj/clothing/belts.dmi' //to be changed
	icon_state = "utilitybelt"
	item_state = "utility"
	icon_state="utility"
	item_flags = ITEM_FLAG_IS_BELT
	slot_flags = SLOT_BELT
	attack_verb = "Bashed"
/obj/item/weapon/shield/shield_belt/syndicate_shield_belt
	icon_state = "utilitybelt"
	item_state = "utility"
	name = "syndicate shield belt"
	desc = "Protects user from bullets and lasers, but doesn't allow you to shoot, looks suspicious"
	origin_tech = list(TECH_MATERIAL = 6, TECH_MAGNET = 6, TECH_ILLEGAL = 4)
	var/active = 0
/obj/item/weapon/shield/shield_belt/experimental_shield_belt
	icon_state = "utilitybelt"
	item_state = "utility"
	name = "experimental shield belt"
	desc = "Protects user from bullets and lasers, but doesn't allow you to shoot"
	origin_tech = list(TECH_MATERIAL = 6, TECH_MAGNET = 6)
	var/active = 0
/obj/item/weapon/shield/shield_belt/get_mob_overlay(mob/user_mob, slot)
	var/image/ret = ..()
	if(slot == slot_belt_str && contents.len)
		for(var/obj/item/I in contents)
			ret.overlays += image("icon" = 'icons/mob/onmob/belt.dmi', "icon_state" = "[I.item_state ? I.item_state : I.icon_state]")
	return ret