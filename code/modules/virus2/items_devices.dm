///////////////ANTIBODY SCANNER///////////////

/obj/item/device/antibody_scanner
	name = "antibody scanner"
	desc = "Scans living beings for antibodies in their blood."
	icon_state = "antibody"
	w_class = ITEM_SIZE_SMALL
	item_state = "electronic"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT

/obj/item/device/antibody_scanner/attack(mob/M as mob, mob/user as mob)
	if(!istype(M,/mob/living/carbon/))
		report("Scan aborted: Incompatible target.", user)
		return

	var/mob/living/carbon/C = M
	if (istype(C,/mob/living/carbon/human/))
		var/mob/living/carbon/human/H = C
		if(!H.should_have_organ(BP_HEART))
			report("Scan aborted: The target does not have blood.", user)
			return

	if(!C.antibodies.len)
		report("Scan Complete: No antibodies detected.", user)
		return

	if (MUTATION_CLUMSY in user.mutations && prob(50))
		// I was tempted to be really evil and rot13 the output.
		report("Antibodies detected: [reverse_text(antigens2string(C.antibodies))]", user)
	else
		report("Antibodies detected: [antigens2string(C.antibodies)]", user)

/obj/item/device/antibody_scanner/proc/report(text, mob/user as mob)
	to_chat(user, "<span class='notice'>\icon[src] \The [src] beeps, \"[text]\"</span>")

///////////////VIRUS DISH///////////////

/obj/item/virusdish
	name = "virus dish"
	icon = 'icons/obj/virology.dmi'
	icon_state = "virus_sample"
	w_class = ITEM_SIZE_SMALL
	var/datum/disease2/disease/virus2 = null
	var/growth = 0
	var/basic_info = null
	var/info = 0
	var/analysed = 0

/obj/item/virusdish/random
	name = "virus sample"

/obj/item/virusdish/random/New()
	..()
	src.virus2 = new /datum/disease2/disease
	src.virus2.makerandom()
	growth = rand(5, 50)

/obj/item/virusdish/attackby(obj/item/W as obj,mob/living/carbon/user as mob)
	if(istype(W,/obj/item/hand_labeler) || istype(W,/obj/item/reagent_containers/syringe))
		return
	..()
	if(prob(50))
		to_chat(user, "<span class='danger'>\The [src] shatters!</span>")
		if(virus2.infectionchance > 0)
			for(var/mob/living/carbon/target in view(1, get_turf(src)))
				if(airborne_can_reach(get_turf(src), get_turf(target)))
					infect_virus2(target, src.virus2)
		qdel(src)

/obj/item/virusdish/_examine_text(mob/user)
	. = ..()
	if(basic_info)
		. += "\n[basic_info] : <a href='?src=\ref[src];info=1'>More Information</a>"

/obj/item/virusdish/OnTopic(user, href_list)
	if(href_list["info"])
		show_browser(user, info, "window=info_\ref[src]")
		return TOPIC_HANDLED

/obj/item/ruinedvirusdish
	name = "ruined virus sample"
	icon = 'icons/obj/virology.dmi'
	icon_state = "virus_dish_r"
	desc = "The bacteria in the dish are completely dead."
	w_class = ITEM_SIZE_SMALL

/obj/item/ruinedvirusdish/attackby(obj/item/W as obj,mob/living/carbon/user as mob)
	if(istype(W,/obj/item/hand_labeler) || istype(W,/obj/item/reagent_containers/syringe))
		return ..()

	if(prob(50))
		to_chat(user, "\The [src] shatters!")
		qdel(src)

///////////////GNA DISK///////////////

/obj/item/diseasedisk
	name = "blank GNA disk"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk0"
	w_class = ITEM_SIZE_TINY
	var/datum/disease2/effect/effect = null
	var/list/species = null
	var/stage = 1
	var/analysed = 1

/obj/item/diseasedisk/premade/New()
	name = "blank GNA disk (stage: [stage])"
	effect = new /datum/disease2/effect/invisible
	effect.stage = stage
