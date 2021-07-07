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

/* DEBUG */
/obj/item/weapon/reagent_containers/neuromod_shell/proc/SetNeuromod(neuromod_path, mob_path)
	neuromod = text2path(neuromod_path)
	created_for = text2path(mob_path)

/obj/item/weapon/reagent_containers/neuromod_shell/proc/ToList()
	return null

/obj/item/weapon/reagent_containers/neuromod_shell/proc/UpdateDesc()
	if (!created_for || !neuromod)
		desc = initial(desc) + "<br>Empty Shell"
		return

	var/datum/lifeform/L = GLOB.lifeforms.GetByMobType(created_for)
	var/datum/neuromod/N = GLOB.neuromods.Get(neuromod)

	if (!L)
		crash_with("trying to get [created_for] but it is not exists")

	if (!N)
		crash_with("trying to get [neuromod] but it is not exists")

	desc = initial(desc) + "<br>Contains: [N.name]" + "<br>Created for [L.species]"

/obj/item/weapon/reagent_containers/neuromod_shell/Initialize()
	. = ..()

	UpdateDesc()

/obj/item/weapon/reagent_containers/neuromod_shell/Destroy()
	neuromod = null
	created_for = null

	return ..()

/obj/item/weapon/reagent_containers/neuromod_shell/do_surgery(mob/living/carbon/M, mob/living/user)
	afterattack(M, user, 1)

/obj/item/weapon/reagent_containers/neuromod_shell/afterattack(mob/living/target, mob/living/user, proximity)
	if (!proximity)
		return

	if (!target || !user)
		crash_with("target or user is null")

	if (!ismob(target) || !ismob(user))
		return

	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/victim = target

		var/obj/item/safe_thing = null
		if(victim.wear_mask)
			if (victim.wear_mask.body_parts_covered & EYES)
				safe_thing = victim.wear_mask
		if(victim.head)
			if (victim.head.body_parts_covered & EYES)
				safe_thing = victim.head
		if(victim.glasses)
			if (victim.glasses.body_parts_covered & EYES)
				safe_thing = victim.glasses

		if(safe_thing)
			to_chat(user, SPAN("warning", "\the [safe_thing] on the way!"))
			return

	if (!neuromod)
		to_chat(user, "\the [src.name] is empty.")
		return

	if (!ispath(neuromod))
		crash_with("neuromod's type must be `path`")

	if (target == user)
		visible_message(SPAN("warning", "[user] trying to inject content of \the [src.name] to self."))
	else
		visible_message(SPAN("warning", "[user] trying to inject content of \the [src.name] to [target]!"))

	if (do_after(user, 20, target, TRUE, TRUE, INCAPACITATION_DEFAULT, FALSE, FALSE))
		visible_message(SPAN("warning", "[user] did inject content of \the [src.name] to [target]"))

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
		UpdateDesc()

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
	var/researched_chance = 35

/* A Disk with 100% chance to have a researched neuromod */
/obj/item/weapon/disk/neuromod_disk/researched/Initialize()
	. = ..()

	if (neuromod)
		researched = TRUE

/* If a disk has a neuromod on spawn - it may be researched */
/obj/item/weapon/disk/neuromod_disk/Initialize()
	. = ..()

	if (neuromod)
		if (prob(researched_chance))
			researched = TRUE

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
