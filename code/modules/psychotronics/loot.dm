/* Any ready to use items that can be placed on maps */

/obj/item/clothing/glasses/hud/psychoscope/with_battery/Initialize()
	. = ..()

	bcell = new /obj/item/weapon/cell/standard/(src.contents)

/* Random ready to use neuromod shells for humans */
/obj/item/weapon/reagent_containers/neuromod_shell/human_random/Initialize()
	neuromod = pick(subtypesof(/datum/neuromod) - list(/datum/neuromod/language))
	created_for = /mob/living/carbon/human

	. = ..()

/* Fully random ready to use neuromod shells */
/obj/item/weapon/reagent_containers/neuromod_shell/random/Initialize()
	neuromod = pick(subtypesof(/datum/neuromod) - list(/datum/neuromod/language))
	created_for = pick(list(/mob/living/carbon/human,
							/mob/living/carbon/human/tajaran,
							/mob/living/carbon/human/skrell,
							/mob/living/carbon/human/unathi))

	. = ..()

/* Fully random neuromod disk */
/obj/item/weapon/disk/neuromod_disk/random/Initialize()
	. = ..()

	neuromod = pick(subtypesof(/datum/neuromod/))
	researched = prob(35)

/* Message from CC */
/obj/item/weapon/paper/psychoscope
	name = "paper - 'Psychoscope'"

/obj/item/weapon/paper/psychoscope/Initialize()
	. = ..()

	src.info = "<center>\[logo]<BR><b><large>NanoTrasen's Research Directorate</large></b><BR><h2>Psychoscope</h2>Greetings, Research Director. We provide [station_name()] with our new prototype of \the psychoscope. Since this moment you are responsible for the prototype and you must not let lose or damage it, or you will get reproval. We will await any discorveries, if you got one - send on a transport shuttles.<h2>Remarks</h2>We permit any safe experiments on crew members that will be helpful in your researchings, for any invasive experiments you should get a permit from the subject and do it under medical surveillance, otherwise it will be regarded as a contravene of job's contract."

/* Briefcase with a psychoscope and message from CC */
/obj/item/weapon/storage/secure/briefcase/psychoscope/Initialize()
	. = ..()

	src.contents += new /obj/item/clothing/glasses/hud/psychoscope/with_battery
	src.contents += new /obj/item/weapon/paper/psychoscope
