/datum/reagent/blood
	name = "Blood"

	reagent_state = LIQUID
	color = "#c80000"

	taste_description = "iron"
	taste_mult = 1.5

	metabolism = 50
	ingest_met = 1.0
	digest_met = 5.0
	hydration_value = 0.51 // Scientific

	glass_name = "tomato juice"
	glass_desc = "Are you sure this is tomato juice?"

	data = new /list(
		"donor" = null,
		"species" = SPECIES_HUMAN,
		"blood_DNA" = null,
		"blood_type" = null,
		"blood_colour" = COLOR_BLOOD_HUMAN,
		"trace_chem" = null,
		"dose_chem" = null,
		"virus2" = list(),
		"antibodies" = list(),
		"has_oxy" = 1
	)

/datum/reagent/blood/initialize_data(newdata)
	..()
	if(data && data["blood_colour"])
		color = data["blood_colour"]
	return

/datum/reagent/blood/proc/sync_to(mob/living/carbon/C)
	data["donor"] = weakref(C)
	if (!data["virus2"])
		data["virus2"] = list()
	data["virus2"] |= virus_copylist(C.virus2)
	data["antibodies"] = C.antibodies
	data["blood_DNA"] = C.dna.unique_enzymes
	data["blood_type"] = C.dna.b_type
	data["species"] = C.species.name
	data["has_oxy"] = C.species.blood_oxy
	var/list/temp_chem = list()
	for(var/datum/reagent/R in C.reagents.reagent_list)
		temp_chem[R.type] = R.volume
	data["trace_chem"] = list2params(temp_chem)
	data["dose_chem"] = list2params(C.chem_traces)
	data["blood_colour"] = C.species.get_blood_colour(C)
	color = data["blood_colour"]

/datum/reagent/blood/mix_data(newdata, newamount)
	if(!islist(newdata))
		return
	if(!data["virus2"])
		data["virus2"] = list()
	data["virus2"] |= newdata["virus2"]
	if(!data["antibodies"])
		data["antibodies"] = list()
	data["antibodies"] |= newdata["antibodies"]

/datum/reagent/antibodies/mix_data(newdata, newamount)
	if(!islist(newdata))
		return
	if(!data["antibodies"])
		data["antibodies"] = list()
	data["antibodies"] |= newdata["antibodies"]

/datum/reagent/blood/get_data() // Just in case you have a reagent that handles data differently.
	var/t = data.Copy()
	if(t["virus2"])
		var/list/v = t["virus2"]
		t["virus2"] = v.Copy()
	if(t["antibodies"])
		var/list/a = t["antibodies"]
		t["antibodies"] = a.Copy()
	return t

/datum/reagent/antibodies/get_data() // Just in case you have a reagent that handles data differently.
	var/t = data.Copy()
	if(t["antibodies"])
		var/list/v = t["antibodies"]
		t["antibodies"] = v.Copy()
	return t

/datum/reagent/blood/touch_turf(turf/simulated/T)
	if(!istype(T) || volume < 3)
		return

	var/weakref/W = data["donor"]
	if(!W)
		blood_splatter(T, src, 1)
		return

	W = W.resolve()
	if(istype(W, /mob/living/carbon/human))
		blood_splatter(T, src, 1)
	else if(istype(W, /mob/living/carbon/larva))
		var/obj/effect/decal/cleanable/blood/B = blood_splatter(T, src, 1)
		if(B)
			B.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"

/datum/reagent/blood/affect_ingest(mob/living/carbon/M, alien, removed)
	// Only transferring viruses while in stomach, digested blood is considered "neutralized"
	if(data && data["virus2"])
		var/list/vlist = data["virus2"]
		if(vlist.len)
			for(var/ID in vlist)
				var/datum/disease2/disease/V = vlist[ID]
				if(V && V.spreadtype == "Contact")
					infect_virus2(M, V.getcopy())

/datum/reagent/blood/affect_digest(mob/living/carbon/M, alien, removed)
	// Nutritious red water
	M.add_hydration(removed * hydration_value)
	M.add_nutrition(removed * 0.5)

/datum/reagent/blood/affect_touch(mob/living/carbon/M, alien, removed)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.isSynthetic())
			return
	if(data && data["virus2"])
		var/list/vlist = data["virus2"]
		if(vlist.len)
			for(var/ID in vlist)
				var/datum/disease2/disease/V = vlist[ID]
				if(V.spreadtype == "Contact")
					infect_virus2(M, V.getcopy())
	if(data && data["antibodies"])
		M.antibodies |= data["antibodies"]

/datum/reagent/blood/affect_blood(mob/living/carbon/M, alien, removed)
	M.inject_blood(src, volume)
	remove_self(volume)

// pure concentrated antibodies
/datum/reagent/antibodies
	name = "Antibodies"

	taste_description = "slime"

	reagent_state = LIQUID
	color = "#0050f0"

	data = list("antibodies"=list())

/datum/reagent/antibodies/affect_blood(mob/living/carbon/M, alien, removed)
	if(src.data)
		M.antibodies |= src.data["antibodies"]
	..()
