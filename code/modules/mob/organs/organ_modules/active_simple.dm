/obj/item/organ_module/active/simple
	var/obj/item/holding = null
	var/holding_type = null

/obj/item/organ_module/active/simple/Initialize()
	. = ..()
	create_holding()

/obj/item/organ_module/active/simple/Destroy()
	if(holding)
		unregister_signal(holding, SIGNAL_ITEM_UNEQUIPPED)
		QDEL_NULL(holding)

	return ..()

/obj/item/organ_module/active/simple/proc/create_holding()
	if(!QDELETED(holding))
		QDEL_NULL(holding)
	if(!holding_type)
		return
	holding = new holding_type(src)
	holding.canremove = FALSE
	holding.force_drop = TRUE
	holding.w_class = ITEM_SIZE_NO_CONTAINER
	holding.slot_flags = 0

/obj/item/organ_module/active/simple/proc/deploy(mob/living/carbon/human/H, obj/item/organ/external/E)
	var/slot = null
	if(QDELETED(holding) && holding_type)
		create_holding()
	if(!holding)
		return
	if(E.organ_tag in list(BP_L_ARM, BP_L_HAND))
		slot = slot_l_hand
	else if(E.organ_tag in list(BP_R_ARM, BP_R_HAND))
		slot = slot_r_hand
	if(!H.equip_to_slot_if_possible(holding, slot))
		return

	H.visible_message(
		SPAN_WARNING("\A [holding] extends from [H]'s [E]."),
		SPAN_NOTICE("\The [holding] extends from your [E].")
	)
	register_signal(holding, SIGNAL_ITEM_UNEQUIPPED, nameof(.proc/on_holding_unequipped), override = TRUE)


/obj/item/organ_module/active/simple/proc/retract(mob/living/carbon/human/H, obj/item/organ/external/E)
	if(!holding || QDELETED(holding))
		return
	if(holding.loc == src)
		return

	if(ismob(holding.loc))
		var/mob/M = holding.loc
		M.drop(holding, force = TRUE)

	H.visible_message(
		SPAN_WARNING("\A [holding] retracts into [H]'s [E]."),
		SPAN_NOTICE("\The [holding] retracts into your [E].")
		)
	holding.forceMove(src)
	unregister_signal(holding, SIGNAL_ITEM_UNEQUIPPED)

/obj/item/organ_module/active/simple/_on_remove(obj/item/organ/external/E)
	var/mob/living/carbon/human/H = E?.owner
	if(ishuman(H))
		retract(H, E)
	else if(holding && !QDELETED(holding) && holding.loc != src)
		holding.forceMove(src)
	return ..()

/obj/item/organ_module/active/simple/proc/on_holding_unequipped(obj/item, mob/mob)
	retract(mob, loc)

/obj/item/organ_module/active/simple/activate(obj/item/organ/external/E, mob/living/carbon/human/H)
	if(!can_activate(E, H))
		return

	if(holding.loc == src)
		deploy(H, E)
	else
		retract(H, E)

/obj/item/organ_module/active/simple/deactivate(obj/item/organ/external/E, mob/living/carbon/human/H)
	retract(H, E)
	return ..()

/obj/item/organ_module/active/simple/organ_removed(obj/item/organ/external/E, mob/living/carbon/human/H)
	retract(H, E)
	return ..()

/obj/item/organ_module/active/simple/is_cpu_active(mob/living/carbon/human/H)
	return holding && !QDELETED(holding) && holding.loc != src
