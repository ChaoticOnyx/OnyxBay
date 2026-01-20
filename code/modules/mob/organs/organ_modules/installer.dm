/obj/item/implanter/installer
	name = "cybernetic installer"
	desc = "A medical applicator of cybernetics."
	icon_state = "installer_empty"
	w_class = ITEM_SIZE_NORMAL
	matter = list(MATERIAL_PLASTIC = 5, MATERIAL_STEEL = 3)
	var/obj/item/organ_module/mod
	var/mod_overlay = null
	var/can_reload = TRUE

/obj/item/implanter/installer/New()
	..()
	if(ispath(mod))
		mod = new mod(src)
		update_icon()

/obj/item/implanter/installer/attack_self(mob/user)
	if(!mod)
		return ..()
	if(user.get_inactive_hand())
		to_chat(user, SPAN_NOTICE("Your other hand must be empty."))
		return
	user.put_in_hands(mod)
	to_chat(user, SPAN_NOTICE("You remove \the [mod] from \the [src]."))
	mod = null
	update_icon()
	return

/obj/item/implanter/installer/update_icon()
	if(mod)
		if(mod.mod_overlay == null)
			icon_state = "installer_full"
		else
			icon_state = mod.mod_overlay
	else
		icon_state = "installer_empty"

/obj/item/implanter/installer/proc/can_load_module(obj/item/organ_module/module)
	if(!istype(module))
		return FALSE
	if(BP_EYES in (module.allowed_organs || list()))
		return FALSE
	if(istype(module, /obj/item/organ_module/armor))
		return FALSE
	if(istype(module, /obj/item/organ_module/passive/resuscitator))
		return FALSE
	if(istype(module, /obj/item/organ_module/muscle))
		return FALSE
	return TRUE

/obj/item/implanter/installer/attackby(obj/item/I, mob/user)
	if(!mod && can_reload && istype(I, /obj/item/organ_module))
		var/obj/item/organ_module/M = I
		if(!can_load_module(M))
			to_chat(user, SPAN_NOTICE("You cannot load \the [M] into \the [src]."))
			return
		if(!user.drop(I, src))
			return
		to_chat(user, SPAN_NOTICE("You slide \the [M] into \the [src]."))
		mod = M
		update_icon()
		return
	return ..()

/obj/item/implanter/installer/attack(mob/living/M, mob/living/user)
	if(!istype(M) || !mod)
		return

	var/obj/item/organ/affected = null
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/target_zone = user.zone_sel?.selecting
		if(!target_zone)
			to_chat(user, SPAN_NOTICE("You must target a body part first."))
			return
		if(target_zone in BP_INTERNAL_ORGANS)
			affected = H.internal_organs_by_name[target_zone]
		else
			affected = H.get_organ(target_zone)

		if(!affected)
			to_chat(user, SPAN_WARNING("[M] is missing that body part."))
			return

		if(!(affected.organ_tag in mod.allowed_organs))
			to_chat(user, SPAN_WARNING("You can't install [mod.name] in the [affected.name]."))
			return
		if(mod.has_duplicate_in(affected))
			to_chat(user, SPAN_NOTICE("You cannot install another [mod.name] into the [affected]."))
			return

		if(initial(mod.module_type) == OM_TYPE_PROCESSOR && affected.organ_tag != BP_HEAD)
			to_chat(user, SPAN_NOTICE("You cannot install the [mod] into the [affected]."))
			return
		if(initial(mod.module_type) == OM_TYPE_ACTUATOR && (affected.organ_tag == BP_HEAD || BP_IS_ROBOTIC(affected)))
			to_chat(user, SPAN_NOTICE("You cannot install the [mod] into the [affected]."))
			return

		if(istype(affected, /obj/item/organ/external))
			var/obj/item/organ/external/external = affected
			if(BP_IS_ROBOTIC(external))
				if(external.hatch_state != HATCH_OPENED)
					to_chat(user, SPAN_NOTICE("You must open the maintenance panel first."))
					return
			else
				var/open_state = external.open()
				if(external.encased)
					if(open_state < SURGERY_RETRACTED)
						to_chat(user, SPAN_NOTICE("You must open the incision first."))
						return
					if(open_state < SURGERY_ENCASED)
						to_chat(user, SPAN_NOTICE("You must cut through the bones first."))
						return
				else if(open_state < SURGERY_RETRACTED)
					to_chat(user, SPAN_NOTICE("You must open the incision first."))
					return

		if(!locate(/obj/machinery/optable, get_turf(M)))
			to_chat(user, SPAN_NOTICE("[M] must be on an operating table."))
			return

		if((mod.w_class + affected.occupied_space) > affected.max_module_size)
			to_chat(user, SPAN_NOTICE("You cannot install the [mod] into the [affected]."))
			return
		var/total_cpu_power = 0
		var/loaded_cpu_power = 0
		var/obj/item/organ/external/head/head = H.organs_by_name[BP_HEAD]
		if(head)
			for(var/obj/item/organ_module/module in head.organ_modules)
				if(initial(module.module_type) == OM_TYPE_PROCESSOR)
					total_cpu_power += (isnull(initial(module.cpu_power)) ? 0 : initial(module.cpu_power))
		for(var/obj/item/organ/external/O in H.organs)
			for(var/obj/item/organ_module/module in O.organ_modules)
				var/module_type = initial(module.module_type)
				if(module_type == OM_TYPE_ACTUATOR || module_type == OM_TYPE_PROCESSOR)
					continue
				loaded_cpu_power += (isnull(initial(module.cpu_load)) ? 0 : initial(module.cpu_load))
		for(var/obj/item/organ/internal/I in H.internal_organs)
			for(var/obj/item/organ_module/module in I.organ_modules)
				var/module_type = initial(module.module_type)
				if(module_type == OM_TYPE_ACTUATOR || module_type == OM_TYPE_PROCESSOR)
					continue
				loaded_cpu_power += (isnull(initial(module.cpu_load)) ? 0 : initial(module.cpu_load))

		var/new_cpu_power = 0
		if(initial(mod.module_type) == OM_TYPE_PROCESSOR && affected.organ_tag == BP_HEAD)
			new_cpu_power = (isnull(initial(mod.cpu_power)) ? 0 : initial(mod.cpu_power))
		var/new_cpu_load = 0
		if(initial(mod.module_type) != OM_TYPE_ACTUATOR && initial(mod.module_type) != OM_TYPE_PROCESSOR)
			new_cpu_load = (isnull(initial(mod.cpu_load)) ? 0 : initial(mod.cpu_load))
		if((loaded_cpu_power + new_cpu_load) > (total_cpu_power + new_cpu_power))
			to_chat(user, SPAN_NOTICE("You cannot install the [mod] into the [affected]."))
			return

	M.visible_message(SPAN_WARNING("[user] is attemping to install something into [M]."))

	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	user.do_attack_animation(M)

	var/implant_duration = SURGERY_DURATION_DELTA * CUT_DURATION * 2
	if(do_mob(user, M, implant_duration) && !QDELETED(src) && !QDELETED(mod))
		mod.install(affected)
		M.visible_message(
		SPAN_WARNING("[user] has installed something into [M]'s' [affected]."),
		SPAN_NOTICE("You installed \the [mod] into [M]'s [affected].")
		)

		admin_attack_log(user, M,
		"Installed using \the [src.name] ([mod.name])",
		"Installed with \the [src.name] ([mod.name])",
		"used an installer, [src.name] ([mod.name]), on"
		)

		mod = null
		update_icon()

/obj/item/implanter/installer/disposable
	name = "cybernetic installer (disposable)"
	desc = "A single use medical applicator of cybernetics."
	can_reload = FALSE

/obj/item/implanter/installer/disposable/New()
	..()
	if(ispath(mod))
		mod = new mod(src)
		update_icon()
