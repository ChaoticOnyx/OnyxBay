/obj/item/implanter/installer
	name = "cybernetic installer"
	desc = "A medical applicator of cybernetics."
	icon_state = "installer_empty"
	w_class = ITEM_SIZE_NORMAL
	matter = list(MATERIAL_PLASTIC = 5, MATERIAL_STEEL = 3)
	var/obj/item/organ_module/mod
	var/mod_overlay = null
	var/can_reload = TRUE

/obj/item/implanter/installer/proc/get_target_organ(mob/living/carbon/human/H, target_zone)
	if(!target_zone)
		to_chat(H, SPAN_NOTICE("You must target a body part first."))
		return null
	if(target_zone in BP_INTERNAL_ORGANS)
		return H.internal_organs_by_name[target_zone]
	return H.get_organ(target_zone)

/obj/item/implanter/installer/proc/is_clothing_blocking(mob/living/carbon/human/H, obj/item/organ/affected, target_zone)
	var/clothing_zone = target_zone
	if(istype(affected, /obj/item/organ/internal))
		var/obj/item/organ/internal/internal = affected
		if(internal.parent_organ)
			clothing_zone = internal.parent_organ
	var/list/clothes = get_target_clothes(H, clothing_zone)
	for(var/obj/item/clothing/C in clothes)
		if(C.body_parts_covered & body_part_flags[clothing_zone])
			to_chat(H, SPAN_DANGER("Clothing on [H]'s [organ_name_by_zone(H, clothing_zone)] blocks surgery!"))
			return TRUE
	return FALSE

/obj/item/implanter/installer/Initialize()
	. = ..()
	if(ispath(mod))
		mod = new mod(src)
		update_icon()

/obj/item/implanter/installer/attack_self(mob/user)
	if(!mod)
		return ..()
	if(istype(src, /obj/item/implanter/installer/disposable) && !can_reload)
		to_chat(user, SPAN_NOTICE("This installer is spent."))
		return
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
	if(!mod && istype(I, /obj/item/organ_module))
		if(can_reload && can_load_module(I))
			var/obj/item/organ_module/M = I
			if(!user.drop(I, src))
				return
			to_chat(user, SPAN_NOTICE("You slide \the [M] into \the [src]."))
			mod = M
			update_icon()
			return
		else
			to_chat(user, SPAN_NOTICE("You cannot load \the [I] into \the [src]."))
			return
	return ..()

/obj/item/implanter/installer/attack(mob/living/M, mob/living/user)
	if(!istype(M) || !mod)
		return

	var/obj/item/organ/affected = null
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/target_zone = user.zone_sel?.selecting
		affected = get_target_organ(H, target_zone)

		if(!affected)
			to_chat(user, SPAN_WARNING("[M] is missing that body part."))
			return
		if(is_clothing_blocking(H, affected, target_zone))
			return
		if(!mod.can_install_in(affected, user))
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
		if(istype(src, /obj/item/implanter/installer/disposable))
			can_reload = FALSE
		update_icon()

/obj/item/implanter/installer/disposable
	name = "cybernetic installer (disposable)"
	desc = "A single use medical applicator of cybernetics."
	can_reload = TRUE

/obj/item/implanter/installer/disposable/attackby(obj/item/I, mob/user)
	if(!can_reload)
		to_chat(user, SPAN_NOTICE("This installer is spent."))
		return
	return ..()

/obj/item/implanter/installer/disposable/attack(mob/living/M, mob/living/user)
	. = ..()
	if(. && !can_reload && mod == null)
		SetName("[initial(name)] (used)")
