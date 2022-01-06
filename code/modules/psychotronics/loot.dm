/* Any ready to use items that can be placed on maps */

/obj/item/clothing/glasses/psychoscope/with_battery/Initialize()
	. = ..()

	bcell = new /obj/item/cell/standard/(src.contents)

/* Random ready to use neuromod shells for humans */
/obj/item/reagent_containers/neuromod_shell/human_random/Initialize()
	neuromod = pick(subtypesof(/datum/neuromod) - list(/datum/neuromod/language))
	created_for = /mob/living/carbon/human

	. = ..()

/* Fully random ready to use neuromod shells */
/obj/item/reagent_containers/neuromod_shell/random/Initialize()
	neuromod = pick(subtypesof(/datum/neuromod) - list(/datum/neuromod/language))
	created_for = pick(list(/mob/living/carbon/human,
							/mob/living/carbon/human/tajaran,
							/mob/living/carbon/human/skrell,
							/mob/living/carbon/human/unathi))

	. = ..()

/* Fully random neuromod disk */
/obj/item/disk/neuromod_disk/random/Initialize()
	. = ..()

	neuromod = pick(subtypesof(/datum/neuromod/))
	researched = prob(35)

/* Briefcase with a psychoscope and message from CC */
/obj/item/storage/secure/briefcase/psychoscope/Initialize()
	. = ..()

	src.contents += new /obj/item/clothing/glasses/psychoscope/with_battery
	src.contents += new /obj/item/paper/psychoscope
