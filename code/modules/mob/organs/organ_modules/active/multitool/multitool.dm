/obj/item/organ_module/active/multitool
	name = "multitool embed module"
	desc = "An augment designed to hold multiple tools for swift deployment."
	action_button_name = "Deploy tool"
	icon_state = "multitool"
	allowed_organs = list(BP_L_ARM, BP_R_ARM)
	matter = list(MATERIAL_STEEL = 100)
	origin_tech = list(TECH_BIO = 3, TECH_POWER = 3)
	augment_cost = 3
	cpu_load = 1
	w_class = 3
	available_in_charsetup = TRUE
	allowed_roles = list(/datum/job/chief_engineer, /datum/job/engineer)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_MECHANICAL
	var/list/items = list(
		/obj/item/screwdriver,
		/obj/item/wrench,
		/obj/item/weldingtool,
		/obj/item/crowbar,
		/obj/item/wirecutters,
		/obj/item/device/analyzer
	)
	loadout_cost = 0

/obj/item/organ_module/active/multitool/Initialize()
	. = ..()
	for(var/path in items)
		var/obj/item/I = new path(src)
		I.canremove = FALSE
		I.w_class = ITEM_SIZE_NO_CONTAINER
		I.slot_flags = 0
		items += I
		register_signal(I, SIGNAL_QDELETING, nameof(.proc/on_holding_qdel))

/obj/item/organ_module/active/multitool/Destroy()
	for(var/atom/A in items)
		unregister_signal(A, SIGNAL_QDELETING)
		qdel(A)
	items.Cut()
	return ..()

/obj/item/organ_module/active/multitool/activate(obj/item/organ/external/E, mob/living/carbon/human/H)
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
		if(!item || !(src.loc in H.external_organs) || H.incapacitated())
			return

		if(H.equip_to_slot_if_possible(item, target_hand))
			H.visible_message(
				SPAN_WARNING("[H] extend \his [item] from [E]."),
				SPAN_NOTICE("You extend your [item] from [E].")
			)

/obj/item/organ_module/active/multitool/proc/on_holding_qdel(obj/item)
    if(!item)
        log_runtime("Organ module [type] lost a held item (null); skipping replacement.")
        return
    log_runtime("Organ module [type] lost held item [item.type]; recreating replacement.")
    var/obj/item/I = new item.type (src)
    I.canremove = FALSE
    items += I
    register_signal(I, SIGNAL_QDELETING, nameof(.proc/on_holding_qdel))


/obj/item/organ_module/active/multitool/proc/on_holding_unequipped(obj/item, mob/mob)
	mob.drop(item, src, TRUE)

/obj/item/organ_module/active/multitool/is_cpu_active(mob/living/carbon/human/H)
	if(!istype(H))
		return FALSE
	if(H.l_hand && (H.l_hand in items))
		return TRUE
	if(H.r_hand && (H.r_hand in items))
		return TRUE
	return FALSE

/obj/item/organ_module/active/multitool/emp_act(severity)
	. = ..()

	var/obj/item/organ/external/E = loc
	var/mob/living/carbon/human/H = E?.owner
	if(!istype(E) || !istype(H))
		return

	var/obj/item/weldingtool/WT = null
	for(var/obj/item/weldingtool/W in items)
		WT = W
		break
	if(!WT || WT.get_fuel() <= 0)
		return

	var/chance = 10 * (4 - severity)
	if(!prob(chance))
		return

	H.visible_message(
		SPAN_WARNING("[H]'s embedded welder pops and flares!"),
		SPAN_DANGER("Your embedded welder pops and flares in your hand!")
	)
	WT.burn_fuel(min(5, WT.get_fuel()))
	H.apply_damage(rand(8, 16), BURN, E.organ_tag)
