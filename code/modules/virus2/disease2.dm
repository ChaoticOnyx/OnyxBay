LEGACY_RECORD_STRUCTURE(virus_records, virus_record)

/datum/disease2/disease
	var/infectionchance = 70
	var/speed = 1
	var/spreadtype = "Contact" // Can also be "Airborne"
	var/stage = 1
	var/dead = 0
	var/clicks = 0
	var/uniqueID = 0
	var/list/datum/disease2/effect/effects = list()
	var/antigen = list() // 16 bits describing the antigens, when one bit is set, a cure with that bit can dock here
	var/max_stage = 4
	var/list/affected_species = list(SPECIES_HUMAN,SPECIES_UNATHI,SPECIES_SKRELL,SPECIES_TAJARA)

/datum/disease2/disease/New(random_severity = 0)
	uniqueID = rand(0,10000)
	if(random_severity)
		makerandom(random_severity)

/datum/disease2/disease/proc/update_disease()

	var/list/datum/disease2/effect/effects_sorted = list() //Sort effects by stage
	for(var/i in 1 to max_stage)
		for(var/datum/disease2/effect/D in effects)
			if(D.stage == i)
				effects_sorted.Add(D)
	effects = effects_sorted

	for(var/datum/disease2/effect/E in effects) 
		E.parent_disease = src
		E.change_parent()

/datum/disease2/disease/proc/makerandom(severity=2)
	var/list/excludetypes = list()
	for(var/i=1 ; i <= max_stage ; i++ )
		var/datum/disease2/effect/E = get_random_virus2_effect(i, severity, excludetypes)
		E.stage = i
		if(!E.allow_multiple)
			excludetypes += E.type
		effects += E
	uniqueID = rand(0,10000)
	switch(severity)
		if(1,2)
			infectionchance = rand(10,20)
		else
			infectionchance = rand(60,90)

	antigen = list(pick(ALL_ANTIGENS))
	antigen |= pick(ALL_ANTIGENS)
	spreadtype = prob(70) ? "Airborne" : "Contact"

	if(all_species.len)
		affected_species = get_infectable_species()
	update_disease()

/proc/get_infectable_species()
	var/list/meat = list()
	var/list/res = list()
	for (var/specie in all_species)
		var/datum/species/S = all_species[specie]
		if((S.spawn_flags & SPECIES_CAN_JOIN) && !S.get_virus_immune() && !S.greater_form)
			meat += S
	if(meat.len)
		var/num = rand(1,meat.len)
		for(var/i=0,i<num,i++)
			var/datum/species/picked = pick_n_take(meat)
			res |= picked.name
			if(picked.primitive_form)
				res |= picked.primitive_form
	return res

/datum/disease2/disease/proc/process(mob/living/carbon/human/H)
	if(dead)
		cure(H)
		return

	if(H.stat == DEAD)
		return

	if(stage <= 1 && clicks == 0) 	// with a certain chance, the mob may become immune to the disease before it starts properly
		if(prob(H.virus_immunity() * 0.05))
			cure(H, 1)
			return

	// Some species are flat out immune to organic viruses.
	if(H.species.get_virus_immune(H))
		cure(H)
		return

	if(H.radiation > 50)
		if(prob(4))
			majormutate()

	if(prob(H.virus_immunity()) && prob(stage)) // Increasing chance of curing as the virus progresses
		cure(H, 1)
	//Waiting out the disease the old way
	if(stage == max_stage && clicks > max(stage*100, 300))
		if(prob(H.virus_immunity() * 0.05 + 100-infectionchance))
			cure(H, 1)

	var/top_badness = 1
	for(var/datum/disease2/effect/e in effects)
		if(e.stage == stage)
			top_badness = max(top_badness, e.badness)

	//Space antibiotics might stop disease completely
	if(H.chem_effects[CE_ANTIVIRAL] > top_badness)
		if(stage == 1 && prob(20))
			cure(H)
		return

	clicks += speed
	//Virus food speeds up disease progress
	if(H.reagents.has_reagent(/datum/reagent/nutriment/virus_food))
		H.reagents.remove_reagent(/datum/reagent/nutriment/virus_food, REM)
		clicks += 10

	//Moving to the next stage
	if(clicks > max(stage*100, 300))
		if(stage < max_stage && prob(10))
			stage++
			clicks = 0

	//Do nasty effects
	for(var/datum/disease2/effect/e in effects)
		e.fire(H,stage)

	//fever
	if(!H.chem_effects[CE_ANTIVIRAL])
		H.bodytemperature = max(H.bodytemperature, min(310+5*min(stage,max_stage), H.bodytemperature+5*min(stage,max_stage)))

/datum/disease2/disease/proc/cure(mob/living/carbon/H, antigen)
	if(!H)
		return
	for(var/datum/disease2/effect/e in effects)
		e.deactivate(H)
	H.virus2.Remove("[uniqueID]")
	if(antigen)
		H.antibodies |= antigen

	BITSET(H.hud_updateflag, STATUS_HUD)

/datum/disease2/disease/proc/minormutate()
	var/datum/disease2/effect/E = pick(effects)
	E.minormutate()

/datum/disease2/disease/proc/mediummutate()
	var/list/datum/disease2/effect/mutable_effects = list()
	for(var/datum/disease2/effect/T in effects)
		if(T.possible_mutations && T.possible_mutations.len)
			mutable_effects += T
	if(!mutable_effects.len)
		return 0

	uniqueID = rand(0,10000)
	var/datum/disease2/effect/mutating_effect = pick(mutable_effects)
	var/list/exclude = list()
	for(var/datum/disease2/effect/D in effects)
		if(D != mutating_effect)
			exclude += D.type
	var/datum/disease2/effect/new_effect = get_mutated_effect(mutating_effect)
	if(!new_effect)
		return 0
	mutating_effect.deactivate()
	effects -= mutating_effect
	effects += new_effect
	update_disease()
	qdel(mutating_effect)
	return 1

/datum/disease2/disease/proc/majormutate(badness = VIRUS_ENGINEERED)
	uniqueID = rand(0,10000)
	var/datum/disease2/effect/E = pick(effects)
	var/list/exclude = list()
	for(var/datum/disease2/effect/D in effects)
		if(D != E)
			exclude += D.type

	var/effect_stage = E.stage
	E.deactivate()
	effects -= E
	qdel(E)

	effects += get_random_virus2_effect(effect_stage, badness, exclude)

	if (prob(5))
		antigen = list(pick(ALL_ANTIGENS))
		antigen |= pick(ALL_ANTIGENS)

	if (prob(5) && all_species.len)
		affected_species = get_infectable_species()
	update_disease()

/datum/disease2/disease/proc/stageshift()
	uniqueID = rand(0,10000)
	var/list/exclude = list()
	for(var/datum/disease2/effect/D in effects)
		if(!D.stage == 1 || !D.stage == max_stage)
			exclude += D.type
		D.stage += 1
		if(D.stage > max_stage)
			effects -= D
	effects += get_random_virus2_effect(1, VIRUS_MILD, exclude)
	update_disease()

/datum/disease2/disease/proc/getcopy()
	var/datum/disease2/disease/disease = new /datum/disease2/disease
	disease.infectionchance = infectionchance
	disease.spreadtype = spreadtype
	disease.speed = speed
	disease.antigen   = antigen
	disease.uniqueID = uniqueID
	disease.affected_species = affected_species.Copy()
	for(var/datum/disease2/effect/effect in effects)
		var/datum/disease2/effect/neweffect = new effect.type
		neweffect.generate(effect.data)
		neweffect.chance = effect.chance
		neweffect.multiplier = effect.multiplier
		neweffect.stage = effect.stage
		disease.effects += neweffect
	disease.update_disease()
	return disease

/datum/disease2/disease/proc/issame(datum/disease2/disease/disease)
	. = 1

	var/list/types = list()
	for(var/datum/disease2/effect/d in effects)
		types += d.type
	for(var/datum/disease2/effect/d in disease.effects)
		if(!(d.type in types))
			return 0

	if (antigen != disease.antigen)
		return 0

/proc/virus_copylist(list/datum/disease2/disease/viruses)
	var/list/res = list()
	for (var/ID in viruses)
		var/datum/disease2/disease/V = viruses[ID]
		res["[V.uniqueID]"] = V.getcopy()
	return res


var/global/list/virusDB = list()

/datum/disease2/disease/proc/name()
	.= "strain #[add_zero("[uniqueID]", 4)]"
	if ("[uniqueID]" in virusDB)
		var/datum/computer_file/data/virus_record/V = virusDB["[uniqueID]"]
		.= V.fields["name"]

/datum/disease2/disease/proc/get_basic_info()
	var/t = ""
	for(var/datum/disease2/effect/E in effects)
		t += ", [E.name]"
	return "[name()] ([copytext(t,3)])"

/datum/disease2/disease/proc/get_info()
	var/r = {"
	<small>Analysis determined the existence of a GNAv2-based viral lifeform.</small><br>
	<u>Designation:</u> [name()]<br>
	<u>Antigen:</u> [antigens2string(antigen)]<br>
	<u>Transmitted By:</u> [spreadtype]<br>
	<u>Rate of Progression:</u> [speed * 100]%<br>
	<u>Species Affected:</u> [jointext(affected_species, ", ")]<br>
"}

	r += "<u>Symptoms:</u><br>"
	for(var/datum/disease2/effect/E in effects)
		r += "([E.stage]) [E.name]    "
		r += "<small><u>Strength:</u> [E.multiplier >= 3 ? "Severe" : E.multiplier > 1 ? "Above Average" : "Average"]    "
		r += "<u>Verosity:</u> [E.chance * 15]</small><br>"

	return r

/datum/disease2/disease/proc/addToDB()
	if ("[uniqueID]" in virusDB)
		return 0
	var/datum/computer_file/data/virus_record/v = new()
	v.fields["id"] = uniqueID
	v.fields["name"] = name()
	v.fields["description"] = get_info()
	v.fields["antigen"] = antigens2string(antigen)
	v.fields["spread type"] = spreadtype
	virusDB["[uniqueID]"] = v
	return 1


proc/virology_letterhead(report_name)
	return {"
		<center><h1><b>[report_name]</b></h1></center>
		<center><small><i>[station_name()] Virology Lab</i></small></center>
		<hr>
"}

/datum/disease2/disease/proc/can_add_symptom(type)
	for(var/datum/disease2/effect/H in effects)
		if(H.type == type && !H.allow_multiple)
			return 0

	return 1
