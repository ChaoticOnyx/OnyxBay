
/*
// TODO: Redo this in a proper way, with UI and stuff.

/mob/proc/prepare_changeling_chemical_sting()
	set category = "Changeling"
	set name = "Chemical Sting (5)"
	set desc = "We inject synthesized chemicals into the victim."

	if(changeling_is_incapacitated())
		return

	change_ctate(/datum/click_handler/changeling/changeling_chemical_sting)

/mob/proc/changeling_chemical_sting(mob/living/carbon/human/T)
	var/datum/changeling/changeling = mind.changeling
	var/mob/living/carbon/human/target = changeling_sting(/mob/proc/prepare_changeling_chemical_sting, T, 5)
	if(!target)
		return

	var/transfer_amount = 10
	if(changeling.recursive_enhancement == TRUE)
		transfer_amount = 20

	var/obj/item/organ/internal/biostructure/BIO = locate() in contents
	if(!BIO)
		return

	BIO.chem_cauldron.trans_to_mob(target, transfer_amount)

	feedback_add_details("changeling_powers", "CS")

/mob/proc/chem_disp_sting()
	set category = "Changeling"
	set name = "Biochemical Cauldron"
	set desc = "Our stinger glands are able to synthesize a variety of chemicals."

	var/datum/changeling/changeling = changeling_power(10)
	if(!changeling)
		return

	var/list/chemistry = list(
	/datum/reagent/hydrazine,
	/datum/reagent/lithium,
	/datum/reagent/carbon,
	/datum/reagent/ammonia,
	/datum/reagent/acetone,
	/datum/reagent/sodium,
	/datum/reagent/aluminum,
	/datum/reagent/silicon,
	/datum/reagent/phosphorus,
	/datum/reagent/sulfur,
	/datum/reagent/potassium,
	/datum/reagent/iron,
	/datum/reagent/copper,
	/datum/reagent/ethanol,
	/datum/reagent/acid,
	/datum/reagent/tungsten,
	/datum/reagent/water
	)

	if(changeling.recursive_enhancement == TRUE)
		chemistry += list(
		/datum/reagent/mercury,
		/datum/reagent/radium,
		/datum/reagent/acid/hydrochloric,
		/datum/reagent/toxin/plasma
		)

	var/datum/reagent/target_chem = input(src, "Choose reagent:") as null|anything in chemistry
	var/amount = input(src, "How much reagent do we want to synthesize?", "Amount", 1) as num|null
	if(amount <= 0)
		return
	if(changeling.chem_charges <= amount)
		to_chat(src, SPAN("changeling", "Not enough chemicals."))
		return
	if(target_chem == /datum/reagent/toxin/plasma)
		if(changeling.chem_charges <= 2 * amount)
			to_chat(src, SPAN("changeling", "Not enough chemicals."))
			return

	var/obj/item/organ/internal/biostructure/BIO = locate() in contents
	if(!BIO)
		return
	BIO.chem_cauldron.add_reagent(target_chem, amount)

	if(target_chem == /datum/reagent/toxin/plasma)
		amount *= 2
	changeling.chem_charges -= amount
	if(!(/mob/proc/changeling_chemical_sting in verbs))
		src.verbs += /mob/proc/prepare_changeling_chemical_sting
		src.verbs += /mob/proc/empty_cauldron

/mob/proc/empty_cauldron()
	set category = "Changeling"
	set name = "Empty Cauldron"
	set desc = "We empty our Cauldron."

	var/datum/changeling/changeling = changeling_power()
	if(!changeling)
		return FALSE

	if(src.status_flags & FAKEDEATH)	//Check for stasis
		to_chat(src, SPAN("changeling", "We can't sting until our stasis ends successfully."))
		return FALSE

	var/mob/living/carbon/human/C = src

	var/obj/item/organ/internal/biostructure/BIO = locate() in contents
	if(!BIO)
		return FALSE
	BIO.chem_cauldron.clear_reagents()

	C.adjustToxLoss(10)
	verbs -= /mob/proc/prepare_changeling_chemical_sting
	verbs -= /mob/proc/empty_cauldron
*/
