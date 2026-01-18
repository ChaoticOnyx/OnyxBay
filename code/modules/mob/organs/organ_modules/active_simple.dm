/obj/item/organ_module/active/simple
	var/obj/item/holding = null
	var/holding_type = null

/obj/item/organ_module/active/simple/Initialize()
	. = ..()
	if(holding_type)
		holding = new holding_type(src)
		holding.canremove = FALSE

/obj/item/organ_module/active/simple/Destroy()
	if(holding)
		unregister_signal(holding, SIGNAL_ITEM_UNEQUIPPED)
		QDEL_NULL(holding)

	return ..()

/obj/item/organ_module/active/simple/proc/deploy(mob/living/carbon/human/H, obj/item/organ/external/E)
	var/slot = null
	if(E.organ_tag in list(BP_L_ARM, BP_L_HAND))
		slot = slot_l_hand
	else if(E.organ_tag in list(BP_R_ARM, BP_R_HAND))
		slot = slot_r_hand
	if(!H.equip_to_slot_if_possible(holding, slot))
		return

	H.visible_message(
		SPAN_WARNING("[H] extend \his [holding.name] from [E]."),
		SPAN_NOTICE("You extend your [holding.name] from [E].")
	)
	register_signal(holding, SIGNAL_ITEM_UNEQUIPPED, nameof(.proc/on_holding_unequipped))

/obj/item/organ_module/active/simple/proc/retract(mob/living/carbon/human/H, obj/item/organ/external/E)
	if(holding.loc == src)
		return

	if(ismob(holding.loc))
		var/mob/M = holding.loc
		M.drop(holding, force = TRUE)
		M.visible_message(
			SPAN_WARNING("[M] retracts \his [holding.name] into [E]."),
			SPAN_NOTICE("You retract your [holding.name] into [E].")
		)
	holding.forceMove(src)
	unregister_signal(H, SIGNAL_ITEM_UNEQUIPPED)

/obj/item/organ_module/active/simple/proc/on_holding_unequipped(obj/item, mob/mob)
	retract(mob, loc)

/obj/item/organ_module/active/simple/activate(mob/living/carbon/human/H, obj/item/organ/external/E)
	if(!can_activate(H, E))
		return

	if(holding.loc == src)
		deploy(H, E)
	else
		retract(H, E)

/obj/item/organ_module/active/simple/deactivate(mob/living/carbon/human/H, obj/item/organ/external/E)
	retract(H, E)
	return ..()

/obj/item/organ_module/active/simple/organ_removed(obj/item/organ/external/E, mob/living/carbon/human/H)
	retract(H, E)
	return ..()
