/obj/item/organ_module/active/multitool
	name = "multitool embed module"
	desc = "An augment designed to hold multiple tools for swift deployment."
	verb_name = "Deploy tool"
	icon_state = "multitool"
	allowed_organs = list(BP_R_ARM, BP_L_ARM)
	matter = list(MATERIAL_STEEL = 100)
	var/list/items = list(
		/obj/item/screwdriver,
		/obj/item/wrench,
		/obj/item/weldingtool,
		/obj/item/crowbar,
		/obj/item/wirecutters,
		/obj/item/device/analyzer
	)

/obj/item/organ_module/active/multitool/Initialize()
	. = ..()
	for(var/path in items)
		var/obj/item/I = new path(src)
		I.canremove = FALSE
		items += I
		register_signal(I, SIGNAL_QDELETING, nameof(.proc/on_holding_qdel))

/obj/item/organ_module/active/multitool/activate(mob/living/carbon/human/H, obj/item/organ/external/E)
	var/target_hand = E.organ_tag == BP_L_ARM ? slot_l_hand : slot_r_hand
	var/obj/I = H.get_active_hand()
	if(I)
		if(I in items)
			H.drop(I, src, TRUE)
			H.visible_message(
				SPAN_WARNING("[H] retract \his [I] into [E]."),
				SPAN_NOTICE("You retract your [I] into [E].")
			)
		else
			show_splash_text(H, "Drop first!", SPAN_WARNING("You must drop [I] before tool can be extend."))
	else
		var/obj/item = tgui_input_list(H, "Select item for deploy", "Multitool Implant", src.contents)
		if(!item || !(src.loc in H.organs) || H.incapacitated())
			return

		if(H.equip_to_slot_if_possible(item, target_hand))
			H.visible_message(
				SPAN_WARNING("[H] extend \his [item] from [E]."),
				SPAN_NOTICE("You extend your [item] from [E].")
			)

/obj/item/organ_module/active/multitool/proc/on_holding_qdel(obj/item)
	util_crash_with("Somehow an organ_module's item got qdeleted. This is NOT normal.")
	var/obj/item/I = new item.type (src)
	I.canremove = FALSE
	items += I
	register_signal(I, SIGNAL_QDELETING, nameof(.proc/on_holding_qdel))

/obj/item/organ_module/active/multitoolle/proc/on_holding_unequipped(obj/item, mob/mob)
	mob.drop(item, src, TRUE)
