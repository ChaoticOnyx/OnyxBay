/* NEUROMOD SHELL */

/obj/item/weapon/reagent_containers/neuromod_shell
	name = "neuromod"
	desc = "This is a neuromod."
	icon = 'icons/obj/psychotronics.dmi'
	icon_state = "neuromod"
	volume = 5
	w_class = ITEM_SIZE_TINY
	sharp = 0
	unacidable = 0

	var/datum/neuromod/neuromod = null // Contains neuromod path

/obj/item/weapon/reagent_containers/neuromod_shell/proc/ToList()
	return null

/obj/item/weapon/reagent_containers/neuromod_shell/New(loc, neuromod_data, ...)
	src.neuromod = neuromod

	..()

/obj/item/weapon/reagent_containers/neuromod_shell/Destroy()
	QDEL_NULL(neuromod)
	..()

/obj/item/weapon/reagent_containers/neuromod_shell/do_surgery(mob/living/carbon/M, mob/living/user)
	afterattack(M, user, 1)

/obj/item/weapon/reagent_containers/neuromod_shell/afterattack(mob/living/target, mob/living/user, proximity)
	if (!proximity)
		return

	if (!target || !user)
		return

	if (!ismob(target) || !ismob(user))
		return

	if (istext(neuromod))
		neuromod = text2path(neuromod)
	else if (!ispath(neuromod))
		neuromod = null

	if (!neuromod)
		to_chat(user, "The neuromod shell is empty.")
		return

	if (target == user)
		to_chat(user, "You're trying to inject the neuromod.")
	else
		to_chat(user, "You're trying to inject the neuromod in [target].")
		to_chat(target, "[user] trying to inject a neuromod in you.")

	if (do_after(user, 20, target, TRUE, TRUE, INCAPACITATION_DEFAULT, FALSE, FALSE))
		if (neuromod in target.neuromods)
			target.adjustToxLoss(10)
			target.adjustBrainLoss(10)
		else
			target.neuromods += neuromod
			target.adjustToxLoss(5)
			neuromod = null

/* NEUROMOD DATA DISK */

/obj/item/weapon/disk/neuromod_disk
	name = "neuromod data disk"
	desc = "A disk for storing neuromod data."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 30, MATERIAL_GLASS = 10)

	var/neuromod = null // Contains neuromd path

/obj/item/weapon/disk/neuromod_disk/lightRegeneration
	neuromod = /datum/neuromod/lightRegeneration

/* LIFEFORM DATA DISK */

/obj/item/weapon/disk/lifeform_disk
	name = "lifeform data disk"
	desc = "A disk for storing lifeform data."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 30, MATERIAL_GLASS = 10)

	var/lifeform = null // Contains lifeform path
	var/list/lifeform_data = null