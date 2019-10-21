/* NEUROMOD SHELL */

/obj/item/weapon/reagent_containers/neuromod_shell
	name = "\improper neuromod shell"
	desc = "This is a neuromod."
	icon = 'icons/obj/psychotronics.dmi'
	icon_state = "neuromod"
	volume = 5
	w_class = ITEM_SIZE_TINY
	sharp = 0
	unacidable = 0

	var/datum/neuromod/neuromod = null 	// Contains neuromod path
	var/mob/living/created_for = null	// Contains path of mob which this neuromod is for

/obj/item/weapon/reagent_containers/neuromod_shell/proc/ToList()
	return null

/obj/item/weapon/reagent_containers/neuromod_shell/proc/UpdateDesc()
	if (!created_for || !neuromod)
		return

	var/datum/lifeform/L = GLOB.lifeforms.GetByMobType(created_for)

	if (!L)
		crash_with("trying to get [created_for] but it is not exists")

	desc = initial(desc) + "<b>Created for [L.genus]"

/obj/item/weapon/reagent_containers/neuromod_shell/Initialize()
	. = ..()

	UpdateDesc()

/obj/item/weapon/reagent_containers/neuromod_shell/Destroy()
	neuromod = null
	created_for = null
	..()

/obj/item/weapon/reagent_containers/neuromod_shell/do_surgery(mob/living/carbon/M, mob/living/user)
	afterattack(M, user, 1)

/obj/item/weapon/reagent_containers/neuromod_shell/afterattack(mob/living/target, mob/living/user, proximity)
	if (!proximity)
		return

	if (!target || !user)
		crash_with("target or user is null")

	if (!ismob(target) || !ismob(user))
		return

	if (!neuromod)
		to_chat(user, "\the [src.name] is empty.")
		return

	if (!ispath(neuromod))
		crash_with("neuromod's type must be `path`")

	if (target == user)
		to_chat(user, SPAN_WARN("You're trying to inject content of \the [src.name] to self."))
	else
		visible_message(SPAN_WARN("[user] trying to inject content of \the [src.name] to [target]!"))

	if (do_after(user, 20, target, TRUE, TRUE, INCAPACITATION_DEFAULT, FALSE, FALSE))
		visible_message(SPAN_WARN("[user] did inject content of \the [src.name] to [target]"))

		if (!istype(target, created_for))
			target.adjustToxLoss(70)
			target.adjustBrainLoss(70)
			neuromod = null

			return

		if (neuromod in target.neuromods)
			target.adjustToxLoss(50)
			target.adjustBrainLoss(50)
		else
			target.neuromods += neuromod
			target.adjustToxLoss(25)

		neuromod = null

/* NEUROMOD DATA DISK */

/obj/item/weapon/disk/neuromod_disk
	name = "\improper neuromod data disk"
	desc = "A disk for storing neuromod data."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 30, MATERIAL_GLASS = 10)

	var/neuromod = null 	// Contains neuromd path
	var/researched = FALSE

/obj/item/weapon/disk/neuromod_disk/Initialize()
	. = ..()

	if (neuromod)
		if (prob(20))
			researched = TRUE

/obj/item/weapon/disk/neuromod_disk/lightRegeneration
	neuromod = /datum/neuromod/light_regeneration

/* LIFEFORM DATA DISK */

/obj/item/weapon/disk/lifeform_disk
	name = "\improper lifeform data disk"
	desc = "A disk for storing lifeform data."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 30, MATERIAL_GLASS = 10)

	var/lifeform = null 			// Contains lifeform path
	var/list/lifeform_data = null	// Contains lifeform data from psychoscope (scan count, etc)