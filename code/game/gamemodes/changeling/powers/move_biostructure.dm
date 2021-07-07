
/mob/proc/changeling_move_biostructure()
	set category = "Changeling"
	set name = "Move Biostructure"
	set desc = "We relocate our precious organ."

	var/mob/living/carbon/T = src
	if(T)
		T.move_biostructure()

// Moves biostructure inside a mob's body
/mob/living/carbon/proc/move_biostructure()
	var/obj/item/organ/internal/biostructure/BIO = internal_organs_by_name[BP_CHANG]
	if(!BIO)
		return

	if(is_regenerating())
		to_chat(src, SPAN("notice", "We can't do it right now."))
		return

	if(!BIO.moving)
		var/list/available_limbs = organs.Copy()
		for(var/obj/item/organ/external/E in available_limbs)
			if(E.organ_tag == BP_R_HAND || E.organ_tag == BP_L_HAND || E.organ_tag == BP_R_FOOT || E.organ_tag == BP_L_FOOT || E.is_stump() || BP_IS_ROBOTIC(E))
				available_limbs -= E
		var/obj/item/organ/external/new_parent = input(src, "Where do we want to move our [BIO.name]?") as null|anything in available_limbs

		if(new_parent)
			to_chat(src, SPAN("changeling", "We start to move our [BIO.name] to \the [new_parent]."))
			BIO.moving = TRUE
			var/move_time
			if(mind.changeling.recursive_enhancement)
				move_time = rand(20, 50)
			else
				move_time = rand(80, 150)
			if(do_after(src, move_time, can_move = 1, needhand = 0, incapacitation_flags = 0))
				BIO.moving = FALSE
				if(mind)
					if(istype(src,/mob/living/carbon/human))
						var/mob/living/carbon/human/H = src
						var/obj/item/organ/external/E = H.get_organ(BIO.parent_organ)
						if(!E)
							to_chat(src, SPAN("changeling", "We are missing that limb."))
							return
						if(istype(E))
							E.internal_organs -= BIO
						BIO.parent_organ = new_parent.organ_tag
						E = H.get_organ(BIO.parent_organ)
						if(!E)
							CRASH("[src] spawned in [src] without a parent organ: [BIO.parent_organ].")
						E.internal_organs |= BIO
						to_chat(src, SPAN("changeling", "Our [BIO.name] is now in \the [new_parent]."))
						log_debug("([src])The changeling biostructure moved in [new_parent].")
