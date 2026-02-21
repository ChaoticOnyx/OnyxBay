/datum/reagent
	var/name = "Reagent"
	var/description = "A non-descript chemical."
	var/taste_description = "old rotten bandaids"
	var/taste_mult = 1 //how this taste compares to others. Higher values means it is more noticable
	var/datum/reagents/holder = null
	var/reagent_state = SOLID
	var/list/data = null
	var/volume = 0

	var/datum/radiation/radiation

	var/metabolism = REM // This would be 0.2 normally

	var/ingest_met = REM * 0.25           // Ingested metabolism speed multiplier, not to be confused with absorbability.
	var/touch_met  = METABOLISM_FALLBACK  // Touch met-
	var/digest_met = METABOLISM_FALLBACK  // Digest met-

	var/excretion = 1.0 // Rate at which metabolism products (chem_traces) reduce, relative to metabolism

	var/ingest_absorbability = 0.5 // Ratio of the volume that affects the blood from the stomach. The rest is discarded. Has no effect if there's no ingest_met.
	var/digest_absorbability = 0.5 // Ratio of the volume that affects the blood from the intestines. The rest is discarded. Has no effect if there's no digest_met.

	var/forced_metabolism = FALSE // Should we force metabolism (i.e. acid affecting a broken stomach).
	var/hydration_value = 0 // How well the reagent replenishes hydration per ml
	var/overdose = INFINITY
	var/scannable = 0 // Shows up on health analyzers.
	var/color = "#000000"
	var/color_weight = 1
	var/flags = 0

	var/glass_icon = DRINK_ICON_DEFAULT
	var/glass_name = "something"
	var/glass_desc = "It's a glass of... what, exactly?"
	var/glass_icon_state = null
	var/glass_required = null // Required glass for current cocktail
	var/list/glass_special = null // null equivalent to list()
	var/list/decompile_results = null

/datum/reagent/New(datum/reagents/holder)
	if(!istype(holder))
		CRASH("Invalid reagents holder: [log_info_line(holder)]")
	src.holder = holder
	..()

/datum/reagent/proc/remove_self(amount) // Shortcut
	if(holder) holder.remove_reagent(type, amount)

// This doesn't apply to skin contact - this is for, e.g. extinguishers and sprays. The difference is that reagent is not directly on the mob's skin - it might just be on their clothing.
/datum/reagent/proc/touch_mob(mob/M, amount)
	return

/datum/reagent/proc/touch_obj(obj/O, amount) // Acid melting, cleaner cleaning, etc
	return

/datum/reagent/proc/touch_turf(turf/T, amount) // Cleaner cleaning, lube lubbing, etc, all go here
	return

/datum/reagent/proc/on_mob_life(mob/living/carbon/M, alien, location) // Currently, on_mob_life is called on carbons. Any interaction with non-carbon mobs (lube) will need to be done in touch_mob.
	if(!istype(M))
		return

	if(!(flags & AFFECTS_DEAD) && M.is_ic_dead() && (world.time - M.timeofdeath > 150))
		return

	if(!(type in M.chem_doses))
		add_user_effects(M)

	if(overdose && (location != CHEM_TOUCH))
		var/overdose_threshold = overdose * (flags & IGNORE_MOB_SIZE? 1 : MOB_MEDIUM/M.mob_size)
		var/overdose_volume = volume - overdose_threshold
		if(overdose_volume > 0)
			overdose(M, alien, overdose_volume)

	//determine the metabolism rate
	var/removed = metabolism
	switch(location)
		if(CHEM_INGEST)
			if(ingest_met != METABOLISM_FALLBACK)
				removed = ingest_met
		if(CHEM_DIGEST)
			if(digest_met != METABOLISM_FALLBACK)
				removed = digest_met
		if(CHEM_TOUCH)
			if(touch_met != METABOLISM_FALLBACK)
				removed = touch_met

	// Adjusted metabolism (modifiers, species, etc.)
	removed = M.get_adjusted_metabolism(removed)

	// No metabolism, aborting.
	if(!removed)
		return

	// Adjust effective amounts - removed, dose, and max_dose - for mob size
	var/effective = removed
	if(!(flags & IGNORE_MOB_SIZE) && location != CHEM_TOUCH)
		effective *= (MOB_MEDIUM/M.mob_size)
	effective = min(effective, volume)

	if(location != CHEM_TOUCH)
		M.chem_doses[type] += effective
		M.chem_traces[type] += effective

	var/affecting_dose = min(volume, M.chem_doses[type])
	switch(location)
		if(CHEM_BLOOD)
			affect_blood(M, alien, effective, affecting_dose)
		if(CHEM_INGEST)
			affect_ingest(M, alien, effective, affecting_dose)
		if(CHEM_DIGEST)
			affect_digest(M, alien, effective, affecting_dose)
		if(CHEM_TOUCH)
			affect_touch(M, alien, effective, affecting_dose)

	if(volume)
		remove_self(removed)
	return

/// Use this proc to add user audiovisual effects, e.g. - flash overlay while under combat painkillers.
/datum/reagent/proc/add_user_effects(mob/living/carbon/M)
	SHOULD_CALL_PARENT(FALSE)

/// Use this proc to remove user audiovisual effects.
/datum/reagent/proc/remove_user_effects(mob/living/carbon/M)
	SHOULD_CALL_PARENT(FALSE)

/datum/reagent/proc/affect_blood(mob/living/carbon/M, alien, removed, affecting_dose)
	return

/datum/reagent/proc/affect_ingest(mob/living/carbon/M, alien, removed, affecting_dose)
	if(ingest_absorbability > 0)
		affect_blood(M, alien, removed * ingest_absorbability, affecting_dose)
	if(hydration_value > 0)
		M.add_hydration(removed * hydration_value)
	else if(hydration_value < 0)
		M.remove_hydration(removed * hydration_value)
	return

/datum/reagent/proc/affect_touch(mob/living/carbon/M, alien, removed, affecting_dose)
	return

/datum/reagent/proc/affect_digest(mob/living/carbon/M, alien, removed, affecting_dose)
	if(digest_absorbability > 0)
		affect_blood(M, alien, removed * digest_absorbability, affecting_dose)
	if(hydration_value > 0)
		M.add_hydration(removed * hydration_value)
	else if(hydration_value < 0)
		M.remove_hydration(removed * hydration_value)
	return

/datum/reagent/proc/overdose(mob/living/carbon/M, alien, overdose_volume) // Overdose effect. Doesn't happen instantly.
	M.add_chemical_effect(CE_TOXIN, 5)
	M.adjustToxLoss(0.5)
	return

/datum/reagent/proc/initialize_data(newdata) // Called when the reagent is created.
	if(!isnull(newdata))
		data = newdata
	return

/datum/reagent/proc/mix_data(newdata, newamount) // You have a reagent with data, and new reagent with its own data get added, how do you deal with that?
	return

/datum/reagent/proc/get_data() // Just in case you have a reagent that handles data differently.
	if(data && istype(data, /list))
		return data.Copy()
	else if(data)
		return data
	return null

/datum/reagent/proc/decompile_into(datum/reagents/target)
	if(!target)
		return FALSE

	if(!islist(decompile_results))
		return FALSE

	var/datum/reagents/R = new /datum/reagents(100 LITERS, GLOB.temp_reagents_holder)
	for(var/newpath in decompile_results)
		R.add_reagent(newpath, decompile_results[newpath] * volume)

	holder.del_reagent(type)
	R.trans_to_holder(target, R.total_volume)
	qdel(R)
	return TRUE

/datum/reagent/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	holder = null
	. = ..()

/* DEPRECATED - TODO: REMOVE EVERYWHERE */

/datum/reagent/proc/reaction_turf(turf/target)
	touch_turf(target)

/datum/reagent/proc/reaction_obj(obj/target)
	touch_obj(target)

/datum/reagent/proc/reaction_mob(mob/target)
	touch_mob(target)
