/obj/item/organ/internal/stomach
	name = "stomach"
	desc = "Gross. This is hard to stomach."
	icon_state = "stomach"
	dead_icon = "stomach"
	organ_tag = BP_STOMACH
	parent_organ = BP_GROIN
	var/datum/reagents/metabolism/ingested
	var/next_cramp = 0

/obj/item/organ/internal/stomach/Destroy()
	QDEL_NULL(ingested)
	. = ..()

/obj/item/organ/internal/stomach/New()
	..()
	ingested = new /datum/reagents/metabolism(240, owner, CHEM_INGEST)
	if(!ingested.my_atom) ingested.my_atom = src

/obj/item/organ/internal/stomach/removed()
	. = ..()
	ingested.my_atom = src
	ingested.parent = null

/obj/item/organ/internal/stomach/replaced()
	. = ..()
	ingested.my_atom = owner
	ingested.parent = owner

// This call needs to be split out to make sure that all the ingested things are metabolised
// before the process call is made on any of the other organs
/obj/item/organ/internal/stomach/proc/metabolize()
	if(is_usable())
		ingested.metabolize()

#define STOMACH_VOLUME 65

/obj/item/organ/internal/stomach/Process()
	..()

	if(owner)
		var/functioning = is_usable()
		if(damage >= min_bruised_damage && prob((damage / max_damage) * 100))
			functioning = FALSE

		if(germ_level > INFECTION_LEVEL_ONE && prob(1))
			functioning = FALSE

		if(germ_level > INFECTION_LEVEL_TWO && prob(5))
			functioning = FALSE

		if(germ_level > INFECTION_LEVEL_THREE && prob(10))
			functioning = FALSE

		if(functioning)
			for(var/mob/living/M in contents)
				if(M.stat == DEAD)
					qdel(M)
					continue

				M.adjustBruteLoss(3)
				M.adjustFireLoss(3)
				M.adjustToxLoss(3)

		else if(world.time >= next_cramp)
			next_cramp = world.time + rand(200,800)
			owner.custom_pain("Your stomach cramps agonizingly!",1)

		var/alcohol_volume = ingested.get_reagent_amount(/datum/reagent/ethanol)

		var/alcohol_threshold_met = alcohol_volume > STOMACH_VOLUME / 2
		if(alcohol_threshold_met && (owner.disabilities & EPILEPSY) && prob(20))
			owner.seizure()

		// Alcohol counts as double volume for the purposes of vomit probability
		var/effective_volume = ingested.total_volume + alcohol_volume

		// Just over the limit, the probability will be low. It rises a lot such that at double ingested it's 64% chance.
		var/vomit_probability = (effective_volume / STOMACH_VOLUME) ** 6
		if(prob(vomit_probability))
			owner.vomit()

#undef STOMACH_VOLUME
