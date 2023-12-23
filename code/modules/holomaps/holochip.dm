/obj/item/clothing/accessory/holochip
	name = "Holomap chip"
	desc = "A small holomap module, attached to helmets."

	icon = 'icons/holomap/holochips.dmi'
	icon_state = "holochip"
	slot = ACCESSORY_SLOT_HELM_H
	var/datum/action/item_action/toggle_holomap/toggle_holomap

	var/marker_id = null
	var/marker_filter = null

/obj/item/clothing/accessory/holochip/Initialize(obj/item/I)
	. = ..()
	var/datum/component/holomarker/toggleable/transmitting/hmap_comp = AddComponent(/datum/component/holomarker/toggleable/transmitting, marker_id, marker_filter)
	hmap_comp.update_holomarker_image(src)
	toggle_holomap = new /datum/action/item_action/toggle_holomap(src)
	toggle_holomap.target = src

/obj/item/clothing/accessory/holochip/Destroy()
	QDEL_NULL(toggle_holomap)
	if(has_suit)
		unregister_signal(has_suit, SIGNAL_ITEM_UNEQUIPPED)
	return ..()

/obj/item/clothing/accessory/holochip/on_attached(obj/item/clothing/S, mob/user)
	. = ..()
	var/datum/component/holomarker/toggleable/transmitting/H = get_component(/datum/component/holomarker/toggleable/transmitting)
	H.on_attached(S)
	register_signal(S, SIGNAL_ITEM_UNEQUIPPED, nameof(.proc/deactivate))

/obj/item/clothing/accessory/holochip/on_removed(mob/user)
	var/datum/component/holomarker/toggleable/transmitting/H = get_component(/datum/component/holomarker/toggleable/transmitting)
	H.on_removed()
	H.deactivate()
	if(has_suit)
		unregister_signal(has_suit, SIGNAL_ITEM_UNEQUIPPED)
	return ..()

/obj/item/clothing/accessory/holochip/attack_self(mob/user)
	var/datum/component/holomarker/toggleable/transmitting/H = get_component(/datum/component/holomarker/toggleable/transmitting)
	H.toggle(user)

/obj/item/clothing/accessory/holochip/proc/deactivate()
	var/datum/component/holomarker/toggleable/transmitting/H = get_component(/datum/component/holomarker/toggleable/transmitting)
	H.deactivate()

/datum/action/item_action/toggle_holomap
	name = "Toggle holomap"
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_ALIVE

/datum/action/item_action/toggle_holomap/CheckRemoval(mob/living/user)
	var/obj/item/clothing/accessory/A = target
	if(!istype(A))
		return TRUE

	if(..() && isnull(A.has_suit))
		return TRUE

	if(!isnull(A.has_suit) && !(A.has_suit in user))
		return TRUE

/obj/item/clothing/accessory/holochip/attack_self(mob/user)
	var/datum/component/holomarker/toggleable/transmitting/H = get_component(/datum/component/holomarker/toggleable/transmitting)
	H.tgui_interact(user)

/obj/item/clothing/accessory/holochip/equipped(mob/user)
	. = ..()
	toggle_holomap.Grant(user)

/obj/item/clothing/accessory/holochip/ui_action_click()
	toggle_verb()

/obj/item/clothing/accessory/holochip/verb/toggle_verb()
	set name = "Toggle holomap"
	set category = "Object"
	set src in usr

	if(!istype(usr, /mob/living))
		return

	if(usr.restrained() || usr.stunned || usr.is_ic_dead())
		return

	var/datum/component/holomarker/toggleable/transmitting/holochip_comp = get_component(/datum/component/holomarker/toggleable/transmitting)
	holochip_comp.toggle(usr)

/obj/item/clothing/accessory/holochip/vox
	marker_filter = HOLOMAP_FILTER_VOX

/obj/item/clothing/accessory/holochip/nuke
	icon_state = "holochip_syndi"
	marker_filter = HOLOMAP_FILTER_NUKEOPS

/obj/item/clothing/accessory/holochip/elitesyndicate
	icon_state = "holochip_syndi"
	marker_filter = HOLOMAP_FILTER_ELITESYNDICATE

/obj/item/clothing/accessory/holochip/ert
	icon_state = "holochip_nt"
	marker_filter = HOLOMAP_FILTER_ERT

/obj/item/clothing/accessory/holochip/deathsquad
	icon_state = "holochip_nt"
	marker_filter = HOLOMAP_FILTER_DEATHSQUAD
