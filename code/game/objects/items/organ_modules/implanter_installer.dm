/obj/item/implanter/installer
	name = "cybernetic installer"
	desc = "A medical applicator of cybernetics."
	icon_state = "installer_empty"
	w_class = ITEM_SIZE_NORMAL
	matter = list(MATERIAL_PLASTIC = 5, MATERIAL_STEEL = 3)
	var/obj/item/organ_module/mod
	var/mod_overlay = null

/obj/item/implanter/installer/New()
	..()
	if(ispath(mod))
		mod = new mod(src)
		update_icon()

/obj/item/implanter/installer/attack_self(mob/user)
	if(!mod)
		return ..()
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

/obj/item/implanter/installer/attack(mob/living/M, mob/living/user)
	if(!istype(M) || !mod)
		return

	var/obj/item/organ/external/affected = null
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		affected = H.get_organ(user.zone_sel.selecting)

		if(!affected)
			to_chat(user, SPAN_WARNING("[M] is missing that body part."))
			return

		if(!(affected.organ_tag in mod.allowed_organs))
			to_chat(user, SPAN_NOTICE("You cannot install the [mod] into the [affected]."))
			return

		if(affected.module != null)
			to_chat(user, SPAN_WARNING("[mod] cannot be installed into this [affected], as it's already occupied."))
			return

	M.visible_message(SPAN_WARNING("[user] is attemping to install something into [M]."))

	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	user.do_attack_animation(M)

	if(do_mob(user, M, 5 SECONDS) && !QDELETED(src) && !QDELETED(mod))

		if(mod.install(affected))
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

/obj/item/implanter/installer/disposable/New()
	..()
	if(ispath(mod))
		mod = new mod(src)
		update_icon()
