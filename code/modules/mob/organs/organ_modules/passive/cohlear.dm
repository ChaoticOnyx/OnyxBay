/obj/item/organ_module/cochlear
	name = "cochlear implant"
	desc = "A synthetic replacement for the structures within the ear, allowing the user to hear without requiring external tools."
	allowed_organs =  list(BP_HEAD)
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	icon_state = "cranial_aug"
	loadout_cost = 0

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
