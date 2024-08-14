/mob/living/carbon/human/proc/create_stack()
	internal_organs_by_name[BP_STACK] = new /obj/item/organ/internal/stack(src,1)
	to_chat(src, "<span class='notice'>You feel a faint sense of vertigo as your neural lace boots.</span>")

/obj/item/organ/internal/stack
	name = "neural lace"
	parent_organ = BP_HEAD
	icon = 'icons/mob/human_races/organs/cyber.dmi'
	icon_state = "cortical-stack"
	override_species_icon = TRUE
	organ_tag = BP_STACK
	status = ORGAN_ROBOTIC
	vital = 1
	origin_tech = list(TECH_BIO = 4, TECH_MATERIAL = 4, TECH_MAGNET = 2, TECH_DATA = 3)
	relative_size = 10

	var/ownerckey
	var/invasive
	var/default_language
	var/list/languages = list()
	var/datum/mind/backup

/obj/item/organ/internal/stack/emp_act()
	return

/obj/item/organ/internal/stack/getToxLoss()
	return 0

/obj/item/organ/internal/stack/vox
	name = "cortical stack"
	icon = 'icons/mob/human_races/organs/vox.dmi'
	icon_state = "cortical-stack"
	invasive = 1

/obj/item/organ/internal/stack/proc/do_backup()
	if(owner && !owner.is_ooc_dead() && !is_broken() && owner.mind)
		languages = owner.languages.Copy()
		backup = owner.mind
		default_language = owner.default_language
		if(owner.ckey)
			ownerckey = owner.ckey

/obj/item/organ/internal/stack/New()
	..()
	do_backup()
	robotize()

/obj/item/organ/internal/stack/proc/backup_inviable()
	if(!istype(backup))
		return TRUE

	if(backup == owner.mind)
		return TRUE

	if(backup.current)
		var/datum/element/in_spessmans_haven/restriction = backup.current.LoadComponent(/datum/element/in_spessmans_haven)
		if(!istype(restriction))
			return TRUE

	return FALSE

/obj/item/organ/internal/stack/replaced()
	if(!..()) return 0

	if(owner && !backup_inviable() && owner.has_brain())
		var/current_owner = owner
		var/mob/dead_owner = find_dead_player(ownerckey, 1)
		if(istype(dead_owner))
			var/response = input(dead_owner, "Your neural backup has been placed into a new body. Do you wish to return to life?", "Resleeving") as anything in list("Yes", "No")
			if(src && response == "Yes" && owner == current_owner)
				overwrite()
	sleep(-1)
	do_backup()

	return 1

/obj/item/organ/internal/stack/removed(mob/living/user, drop_organ = TRUE, detach = TRUE)
	do_backup()
	..()

/obj/item/organ/internal/stack/vox/removed(mob/living/user, drop_organ = TRUE, detach = TRUE)
	var/obj/item/organ/external/head = owner.get_organ(parent_organ)
	owner.visible_message("<span class='danger'>\The [src] rips gaping holes in \the [owner]'s [head.name] as it is torn loose!</span>")
	head.take_external_damage(rand(15,20))
	for(var/obj/item/organ/internal/O in head.contents)
		O.take_internal_damage(rand(30,70))
	..()

/obj/item/organ/internal/stack/proc/overwrite()
	if(owner.mind && owner.ckey) //Someone is already in this body!
		owner.visible_message("<span class='danger'>\The [owner] spasms violently!</span>")
		if(prob(66))
			to_chat(owner, "<span class='danger'>You fight off the invading tendrils of another mind, holding onto your own body!</span>")
			return
		owner.ghostize() // Remove the previous owner to avoid their client getting reset.
	//owner.dna.real_name = backup.name
	//owner.real_name = owner.dna.real_name
	//owner.SetName(owner.real_name)
	//The above three lines were commented out for
	backup.active = 1
	backup.transfer_to(owner)
	if(default_language) owner.default_language = default_language
	owner.languages = languages.Copy()
	to_chat(owner, "<span class='notice'>Consciousness slowly creeps over you as your new body awakens.</span>")
