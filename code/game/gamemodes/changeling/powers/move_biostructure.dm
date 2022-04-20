
// Moves biostructure inside a mob's body
/datum/changeling_power/passive/move_biostructure
	name = "Relocate Biostructure"
	desc = "We relocate our true body."
	var/moving_bio = FALSE
	var/moving_delay_min = 80
	var/moving_delay_max = 150

/datum/changeling_power/passive/move_biostructure/activate()
	my_mob.verbs += /datum/changeling/proc/move_biostructure

/datum/changeling_power/passive/move_biostructure/deactivate()
	my_mob.verbs -= /datum/changeling/proc/move_biostructure

/datum/changeling_power/passive/move_biostructure/update_recursive_enhancement()
	if(..())
		moving_delay_min = 20
		moving_delay_max = 50
	else
		moving_delay_min = 80
		moving_delay_max = 150

/datum/changeling/proc/move_biostructure()
	set category = "Changeling"
	set name = "Relocate Biostructure"
	set desc = "We relocate our true body."

	if(!usr?.mind?.changeling)
		return
	src = usr.mind.changeling

	if(usr != my_mob)
		return

	var/datum/changeling_power/passive/move_biostructure/source_power = get_changeling_power_by_name("Relocate Biostructure")
	if(!source_power)
		my_mob.verbs -= /datum/changeling/proc/move_biostructure
		return

	if(!ishuman(my_mob))
		return

	var/mob/living/carbon/human/H = my_mob
	var/obj/item/organ/internal/biostructure/BIO = H.internal_organs_by_name[BP_CHANG]
	if(!BIO)  // Should never happen, but still.
		log_debug("Changeling Shenanigans: [my_mob] ([my_mob.key]) had no biostructure during move_biostructure() call. Please, inform developers.")
		return

	if(is_regenerating() || source_power.moving_bio)
		to_chat(H, SPAN("changeling", "We can't do it right now."))
		return

	var/list/available_limbs = H.organs.Copy()
	for(var/obj/item/organ/external/E in available_limbs)
		if(E.organ_tag == BP_R_HAND || E.organ_tag == BP_L_HAND || E.organ_tag == BP_R_FOOT || E.organ_tag == BP_L_FOOT || E.is_stump() || BP_IS_ROBOTIC(E))
			available_limbs -= E

	var/obj/item/organ/external/new_parent = input(H, "Where do we want to move our biostructure?") as null|anything in available_limbs
	if(!new_parent)
		return

	to_chat(H, SPAN("changeling", "We begin moving our biostructure to \the [new_parent]..."))
	source_power.moving_bio = TRUE

	var/moving_delay = rand(source_power.moving_delay_min, source_power.moving_delay_max)

	if(!do_after(H, moving_delay, can_move = 1, needhand = 0, incapacitation_flags = 0))
		source_power.moving_bio = FALSE
		to_chat(H, SPAN("changeling", "Our movement has been interrupted!"))
		return

	source_power.moving_bio = FALSE

	if(QDELETED(new_parent) || new_parent.loc != H) // Target limb was lost
		to_chat(H, SPAN("changeling", "We are missing that limb."))
		return

	var/obj/item/organ/external/BIO_parent = null
	BIO_parent = H.get_organ(BIO.parent_organ)
	if(!BIO_parent)
		to_chat(H, SPAN("changeling", "We are missing that limb."))
		return

	BIO_parent.internal_organs.Remove(BIO)

	BIO.parent_organ = new_parent.organ_tag
	BIO_parent = H.get_organ(BIO.parent_organ)
	if(!BIO_parent)
		CRASH("[BIO] spawned in [H] without a parent organ: [BIO.parent_organ].")
	BIO_parent.internal_organs |= BIO
	to_chat(H, SPAN("changeling", "Our biostructure is now in \the [new_parent]."))
