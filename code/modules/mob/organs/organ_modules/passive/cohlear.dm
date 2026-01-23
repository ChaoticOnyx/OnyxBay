/obj/item/organ_module/cochlear
	name = "cochlear implant"
	desc = "A synthetic replacement for the structures within the ear, allowing the user to hear without requiring external tools."
	allowed_organs =  list(BP_HEAD)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	icon_state = "cranial_aug"
	loadout_cost = 0
	available_in_charsetup = TRUE
	augment_cost = 1
	allowed_jobs = list(/datum/job/hos, /datum/job/warden, /datum/job/detective, /datum/job/officer, /datum/job/chief_engineer, /datum/job/engineer)
	origin_tech = list(TECH_BIO = 4, TECH_COMBAT = 4, TECH_ENGINEERING = 4)
	matter = list(
		MATERIAL_SILVER = 800,
		MATERIAL_PLASTIC = 500
	)

/obj/item/organ_module/cochlear/emp_act(severity)
	. = ..()

	var/obj/item/organ/O = loc
	var/mob/living/carbon/human/H = O?.owner
	if(!istype(H))
		return

	var/chance = 10 * (4 - severity)
	if(!prob(chance))
		return

	H.visible_message(
		SPAN_WARNING("[H] reels as \his cochlear implant overloads!"),
		SPAN_DANGER("Your cochlear implant overloads with a painful shock!")
	)
	var/deaf_time = 10 * (4 - severity)
	H.setEarDamage(null, max(H.ear_deaf, deaf_time))
