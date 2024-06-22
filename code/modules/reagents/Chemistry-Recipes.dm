//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
// It is filtered into multiple lists within a list.
// For example:
// chemical_reaction_list[/datum/reagent/toxin/plasma] is a list of all reactions relating to plasma
// Note that entries in the list are NOT duplicated. So if a reaction pertains to
// more than one chemical it will still only appear in only one of the sublists.
/proc/initialize_chemical_reactions()
	var/paths = typesof(/datum/chemical_reaction) - /datum/chemical_reaction
	chemical_reactions_list = list()

	for(var/path in paths)
		var/datum/chemical_reaction/D = new path()
		if(D.required_reagents && D.required_reagents.len)
			var/reagent_id = D.required_reagents[1]
			if(!chemical_reactions_list[reagent_id])
				chemical_reactions_list[reagent_id] = list()
			chemical_reactions_list[reagent_id] += D

/datum/chemical_reaction
	var/name = null
	var/result = null
	var/list/required_reagents = list()
	var/list/catalysts = list()
	var/list/inhibitors = list()
	var/result_amount = 0

	var/mix_message = "The solution begins to bubble."
	var/reaction_sound = 'sound/effects/bubbles.ogg'

	var/log_is_important = 0 // If this reaction should be considered important for logging. Important recipes message admins when mixed, non-important ones just log to file.

/datum/chemical_reaction/proc/can_happen(datum/reagents/holder)
	//check that all the required reagents are present
	if(!holder.has_all_reagents(required_reagents))
		return 0

	//check that all the required catalysts are present in the required amount
	if(!holder.has_all_reagents(catalysts))
		return 0

	//check that none of the inhibitors are present in the required amount
	if(holder.has_any_reagent(inhibitors))
		return 0

	return 1

// This proc returns a list of all reagents it wants to use; if the holder has several reactions that use the same reagent, it will split the reagent evenly between them
/datum/chemical_reaction/proc/get_used_reagents()
	. = list()
	for(var/reagent in required_reagents)
		. += reagent

/datum/chemical_reaction/proc/process(datum/reagents/holder, limit)
	var/data = send_data(holder)

	var/reaction_volume = holder.maximum_volume
	for(var/reactant in required_reagents)
		var/A = holder.get_reagent_amount(reactant) / required_reagents[reactant] / limit // How much of this reagent we are allowed to use
		if(reaction_volume > A)
			reaction_volume = A

	for(var/reactant in required_reagents)
		holder.remove_reagent(reactant, reaction_volume * required_reagents[reactant], safety = 1)

	//add the product
	var/amt_produced = result_amount * reaction_volume
	if(result)
		holder.add_reagent(result, amt_produced, data, safety = 1)

	log_it(holder.my_atom)
	on_reaction(holder, amt_produced)

//called when a reaction processes
/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return

//called after processing reactions, if they occurred
/datum/chemical_reaction/proc/post_reaction(datum/reagents/holder)
	var/atom/container = holder.my_atom
	if(container && (container.atom_flags & ATOM_FLAG_SILENTCONTAINER))
		return

	if(mix_message && !ismob(container))
		var/turf/T = get_turf(container)
		var/list/seen = viewers(4, T)
		for(var/mob/M in seen)
			M.show_message("<span class='notice'>\icon[container] [mix_message]</span>", 1)
		playsound(T, reaction_sound, 80, 1)

//obtains any special data that will be provided to the reaction products
//this is called just before reactants are removed.
/datum/chemical_reaction/proc/send_data(datum/reagents/holder, reaction_limit)
	return null

/* Common reactions */

/datum/chemical_reaction/inaprovaline
	name = "Inaprovaline"
	result = /datum/reagent/inaprovaline
	required_reagents = list(/datum/reagent/acetone = 1, /datum/reagent/carbon = 1, /datum/reagent/sugar = 1)
	result_amount = 3

/datum/chemical_reaction/dylovene
	name = "Dylovene"
	result = /datum/reagent/dylovene
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/potassium = 1, /datum/reagent/ammonia = 1)
	result_amount = 3

/datum/chemical_reaction/painkiller
	name = "Metazine"
	result = /datum/reagent/painkiller
	required_reagents = list(/datum/reagent/painkiller/tramadol = 1, /datum/reagent/ammonia = 1, /datum/reagent/phosphorus = 1)
	catalysts = list(/datum/reagent/toxin/plasma = 5)
	result_amount = 1

/datum/chemical_reaction/tramadol
	name = "Tramadol"
	result = /datum/reagent/painkiller/tramadol
	required_reagents = list(/datum/reagent/inaprovaline = 1, /datum/reagent/ethanol = 1, /datum/reagent/acetone = 1)
	result_amount = 1

/datum/chemical_reaction/paracetamol
	name = "Paracetamol"
	result = /datum/reagent/painkiller/paracetamol
	required_reagents = list(/datum/reagent/painkiller/tramadol = 1, /datum/reagent/sugar = 1, /datum/reagent/water = 1)
	result_amount = 3

/datum/chemical_reaction/oxycodone
	name = "Oxycodone"
	result = /datum/reagent/painkiller/tramadol/oxycodone
	required_reagents = list(/datum/reagent/ethanol = 1, /datum/reagent/painkiller/tramadol = 1)
	catalysts = list(/datum/reagent/toxin/plasma = 5)
	result_amount = 1

/datum/chemical_reaction/tarine
	name = "Tarine"
	result = /datum/reagent/painkiller/opium/tarine
	required_reagents = list(/datum/reagent/painkiller/opium = 3, /datum/reagent/acetone = 1, /datum/reagent/acid/hydrochloric = 1)
	result_amount = 3

/datum/chemical_reaction/sterilizine
	name = "Sterilizine"
	result = /datum/reagent/sterilizine
	required_reagents = list(/datum/reagent/ethanol = 1, /datum/reagent/dylovene = 1, /datum/reagent/acid/hydrochloric = 1)
	result_amount = 3

/datum/chemical_reaction/silicate
	name = "Silicate"
	result = /datum/reagent/silicate
	required_reagents = list(/datum/reagent/aluminum = 1, /datum/reagent/silicon = 1, /datum/reagent/acetone = 1)
	result_amount = 3

/datum/chemical_reaction/mutagen
	name = "Unstable mutagen"
	result = /datum/reagent/mutagen
	required_reagents = list(/datum/reagent/radium = 1, /datum/reagent/phosphorus = 1, /datum/reagent/acid/hydrochloric = 1)
	result_amount = 3

/datum/chemical_reaction/thermite
	name = "Thermite"
	result = /datum/reagent/thermite
	required_reagents = list(/datum/reagent/aluminum = 1, /datum/reagent/iron = 1, /datum/reagent/acetone = 1)
	result_amount = 3
	log_is_important = 1

/datum/chemical_reaction/space_drugs
	name = "Space Drugs"
	result = /datum/reagent/space_drugs
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/sugar = 1, /datum/reagent/lithium = 1)
	result_amount = 3

/datum/chemical_reaction/lube
	name = "Space Lube"
	result = /datum/reagent/lube
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/silicon = 1, /datum/reagent/acetone = 1)
	result_amount = 4
	log_is_important = 1

/datum/chemical_reaction/pacid
	name = "Polytrinic acid"
	result = /datum/reagent/acid/polyacid
	required_reagents = list(/datum/reagent/acid = 1, /datum/reagent/acid/hydrochloric = 1, /datum/reagent/potassium = 1)
	result_amount = 3
	log_is_important = 1

/datum/chemical_reaction/synaptizine
	name = "Synaptizine"
	result = /datum/reagent/synaptizine
	required_reagents = list(/datum/reagent/sugar = 1, /datum/reagent/lithium = 1, /datum/reagent/water = 1)
	result_amount = 3

/datum/chemical_reaction/hyronalin
	name = "Hyronalin"
	result = /datum/reagent/hyronalin
	required_reagents = list(/datum/reagent/radium = 1, /datum/reagent/dylovene = 1)
	result_amount = 2

/datum/chemical_reaction/arithrazine
	name = "Arithrazine"
	result = /datum/reagent/arithrazine
	required_reagents = list(/datum/reagent/hyronalin = 1, /datum/reagent/hydrazine = 1)
	result_amount = 2

/datum/chemical_reaction/impedrezene
	name = "Impedrezene"
	result = /datum/reagent/impedrezene
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/acetone = 1, /datum/reagent/sugar = 1)
	result_amount = 2

/datum/chemical_reaction/kelotane
	name = "Kelotane"
	result = /datum/reagent/kelotane
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/carbon = 1)
	result_amount = 2

/datum/chemical_reaction/peridaxon
	name = "Peridaxon"
	result = /datum/reagent/peridaxon
	required_reagents = list(/datum/reagent/bicaridine = 2, /datum/reagent/clonexadone = 2)
	catalysts = list(/datum/reagent/toxin/plasma = 5)
	result_amount = 2

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	result = /datum/reagent/nutriment/virus_food
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/drink/milk = 1)
	result_amount = 5

/datum/chemical_reaction/leporazine
	name = "Leporazine"
	result = /datum/reagent/leporazine
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/copper = 1)
	catalysts = list(/datum/reagent/toxin/plasma = 5)
	result_amount = 2

/datum/chemical_reaction/cryptobiolin
	name = "Cryptobiolin"
	result = /datum/reagent/cryptobiolin
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/acetone = 1, /datum/reagent/sugar = 1)
	result_amount = 3

/datum/chemical_reaction/tricordrazine
	name = "Tricordrazine"
	result = /datum/reagent/tricordrazine
	required_reagents = list(/datum/reagent/inaprovaline = 1, /datum/reagent/dylovene = 1)
	result_amount = 2

/datum/chemical_reaction/alkysine
	name = "Alkysine"
	result = /datum/reagent/alkysine
	required_reagents = list(/datum/reagent/acid/hydrochloric = 1, /datum/reagent/ammonia = 1, /datum/reagent/dylovene = 1)
	result_amount = 2

/datum/chemical_reaction/dexalin
	name = "Dexalin"
	result = /datum/reagent/dexalin
	required_reagents = list(/datum/reagent/acetone = 2, /datum/reagent/toxin/plasma = 0.1)
	inhibitors = list(/datum/reagent/water = 1) // Messes with cryox
	result_amount = 1

/datum/chemical_reaction/dermaline
	name = "Dermaline"
	result = /datum/reagent/dermaline
	required_reagents = list(/datum/reagent/acetone = 1, /datum/reagent/phosphorus = 1, /datum/reagent/kelotane = 1)
	result_amount = 3

/datum/chemical_reaction/dexalinp
	name = "Dexalin Plus"
	result = /datum/reagent/dexalinp
	required_reagents = list(/datum/reagent/dexalin = 1, /datum/reagent/carbon = 1, /datum/reagent/iron = 1)
	result_amount = 3

/datum/chemical_reaction/bicaridine
	name = "Bicaridine"
	result = /datum/reagent/bicaridine
	required_reagents = list(/datum/reagent/inaprovaline = 1, /datum/reagent/carbon = 1)
	inhibitors = list(/datum/reagent/sugar = 1) // Messes up with inaprovaline
	result_amount = 2

/datum/chemical_reaction/hyperzine
	name = "Hyperzine"
	result = /datum/reagent/hyperzine
	required_reagents = list(/datum/reagent/sugar = 1, /datum/reagent/phosphorus = 1, /datum/reagent/sulfur = 1)
	result_amount = 3

/datum/chemical_reaction/ryetalyn
	name = "Ryetalyn"
	result = /datum/reagent/ryetalyn
	required_reagents = list(/datum/reagent/arithrazine = 1, /datum/reagent/carbon = 1)
	result_amount = 2

/datum/chemical_reaction/cryoxadone
	name = "Cryoxadone"
	result = /datum/reagent/cryoxadone
	required_reagents = list(/datum/reagent/dexalin = 1, /datum/reagent/water = 1, /datum/reagent/acetone = 1)
	result_amount = 3

/datum/chemical_reaction/clonexadone
	name = "Clonexadone"
	result = /datum/reagent/clonexadone
	required_reagents = list(/datum/reagent/cryoxadone = 1, /datum/reagent/sodium = 1, /datum/reagent/toxin/plasma = 0.1)
	result_amount = 2

/datum/chemical_reaction/spaceacillin
	name = "Spaceacillin"
	result = /datum/reagent/spaceacillin
	required_reagents = list(/datum/reagent/cryptobiolin = 1, /datum/reagent/inaprovaline = 1)
	result_amount = 2

/datum/chemical_reaction/imidazoline
	name = "Imidazoline"
	result = /datum/reagent/imidazoline
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/hydrazine = 1, /datum/reagent/dylovene = 1)
	result_amount = 2

/datum/chemical_reaction/ethylredoxrazine
	name = "Ethylredoxrazine"
	result = /datum/reagent/ethylredoxrazine
	required_reagents = list(/datum/reagent/acetone = 1, /datum/reagent/dylovene = 1, /datum/reagent/carbon = 1)
	result_amount = 3

/datum/chemical_reaction/soporific
	name = "Soporific"
	result = /datum/reagent/soporific
	required_reagents = list(/datum/reagent/chloralhydrate = 1, /datum/reagent/sugar = 4)
	inhibitors = list(/datum/reagent/phosphorus) // Messes with the smoke
	result_amount = 5

/datum/chemical_reaction/chloralhydrate
	name = "Chloral Hydrate"
	result = /datum/reagent/chloralhydrate
	required_reagents = list(/datum/reagent/ethanol = 1, /datum/reagent/acid/hydrochloric = 3, /datum/reagent/water = 1)
	result_amount = 1
	log_is_important = 1

/datum/chemical_reaction/potassium_chloride
	name = "Potassium Chloride"
	result = /datum/reagent/toxin/potassium_chloride
	required_reagents = list(/datum/reagent/sodiumchloride = 1, /datum/reagent/potassium = 1)
	result_amount = 2
	log_is_important = 1

/datum/chemical_reaction/potassium_chlorophoride
	name = "Potassium Chlorophoride"
	result = /datum/reagent/toxin/potassium_chlorophoride
	required_reagents = list(/datum/reagent/toxin/potassium_chloride = 1, /datum/reagent/toxin/plasma = 1, /datum/reagent/chloralhydrate = 1)
	result_amount = 4
	log_is_important = 1

/datum/chemical_reaction/zombiepowder
	name = "Zombie Powder"
	result = /datum/reagent/toxin/zombiepowder
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 5, /datum/reagent/soporific = 5, /datum/reagent/copper = 5)
	result_amount = 2

/datum/chemical_reaction/mindbreaker
	name = "Mindbreaker Toxin"
	result = /datum/reagent/mindbreaker
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/hydrazine = 1, /datum/reagent/dylovene = 1)
	result_amount = 3

/datum/chemical_reaction/lipozine
	name = "Lipozine"
	result = /datum/reagent/lipozine
	required_reagents = list(/datum/reagent/sodiumchloride = 1, /datum/reagent/ethanol = 1, /datum/reagent/radium = 1)
	result_amount = 3

/datum/chemical_reaction/surfactant
	name = "Azosurfactant"
	result = /datum/reagent/surfactant
	required_reagents = list(/datum/reagent/hydrazine = 2, /datum/reagent/carbon = 2, /datum/reagent/acid = 1)
	result_amount = 5

/datum/chemical_reaction/diethylamine
	name = "Diethylamine"
	result = /datum/reagent/diethylamine
	required_reagents = list (/datum/reagent/ammonia = 1, /datum/reagent/ethanol = 1)
	result_amount = 2

/datum/chemical_reaction/space_cleaner
	name = "Space cleaner"
	result = /datum/reagent/space_cleaner
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/water = 1)
	result_amount = 2

/datum/chemical_reaction/reconstituted_space_cleaner
	name = "Reconstituted space cleaner"
	result = /datum/reagent/space_cleaner
	required_reagents = list(/datum/reagent/space_cleaner/dry = 1, /datum/reagent/water = 10)
	result_amount = 10

/datum/chemical_reaction/plantbgone
	name = "Plant-B-Gone"
	result = /datum/reagent/toxin/plantbgone
	required_reagents = list(/datum/reagent/toxin = 1, /datum/reagent/water = 4)
	result_amount = 5

/datum/chemical_reaction/foaming_agent
	name = "Foaming Agent"
	result = /datum/reagent/foaming_agent
	required_reagents = list(/datum/reagent/lithium = 1, /datum/reagent/hydrazine = 1)
	result_amount = 1

/datum/chemical_reaction/glycerol
	name = "Glycerol"
	result = /datum/reagent/glycerol
	required_reagents = list(/datum/reagent/nutriment/cornoil = 3, /datum/reagent/acid = 1)
	result_amount = 1

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	result = /datum/reagent/sodiumchloride
	required_reagents = list(/datum/reagent/sodium = 1, /datum/reagent/acid/hydrochloric = 1)
	result_amount = 2

/datum/chemical_reaction/condensedcapsaicin
	name = "Condensed Capsaicin"
	result = /datum/reagent/capsaicin/condensed
	required_reagents = list(/datum/reagent/capsaicin = 2)
	catalysts = list(/datum/reagent/toxin/plasma = 5)
	result_amount = 1

/datum/chemical_reaction/coolant
	name = "Coolant"
	result = /datum/reagent/coolant
	required_reagents = list(/datum/reagent/tungsten = 1, /datum/reagent/acetone = 1, /datum/reagent/water = 1)
	result_amount = 3

/datum/chemical_reaction/rezadone
	name = "Rezadone"
	result = /datum/reagent/rezadone
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 1, /datum/reagent/cryptobiolin = 1, /datum/reagent/copper = 1)
	result_amount = 3

/datum/chemical_reaction/lexorin
	name = "Lexorin"
	result = /datum/reagent/lexorin
	required_reagents = list(/datum/reagent/toxin/plasma = 1, /datum/reagent/hydrazine = 1, /datum/reagent/ammonia = 1)
	result_amount = 3

/datum/chemical_reaction/methylphenidate
	name = "Methylphenidate"
	result = /datum/reagent/methylphenidate
	required_reagents = list(/datum/reagent/mindbreaker = 1, /datum/reagent/lithium = 1)
	result_amount = 3

/datum/chemical_reaction/citalopram
	name = "Citalopram"
	result = /datum/reagent/citalopram
	required_reagents = list(/datum/reagent/mindbreaker = 1, /datum/reagent/carbon = 1)
	result_amount = 3


/datum/chemical_reaction/paroxetine
	name = "Paroxetine"
	result = /datum/reagent/paroxetine
	required_reagents = list(/datum/reagent/mindbreaker = 1, /datum/reagent/acetone = 1, /datum/reagent/inaprovaline = 1)
	result_amount = 3

/datum/chemical_reaction/hair_remover
	name = "Hair Remover"
	result = /datum/reagent/toxin/hair_remover
	required_reagents = list(/datum/reagent/radium = 1, /datum/reagent/potassium = 1, /datum/reagent/acid/hydrochloric = 1)
	result_amount = 3

/datum/chemical_reaction/hair_grower
	name = "Hair Grower"
	result = /datum/reagent/toxin/hair_grower
	required_reagents = list(/datum/reagent/arithrazine = 1, /datum/reagent/potassium = 1, /datum/reagent/acid/polyacid = 1)
	result_amount = 1

/datum/chemical_reaction/noexcutite
	name = "Noexcutite"
	result = /datum/reagent/noexcutite
	required_reagents = list(/datum/reagent/painkiller/tramadol/oxycodone = 1, /datum/reagent/dylovene = 1)
	result_amount = 2

/* Solidification */

/datum/chemical_reaction/plasmasolidification
	name = "Solid Plasma"
	result = null
	required_reagents = list(/datum/reagent/iron = 5, /datum/reagent/frostoil = 5, /datum/reagent/toxin/plasma = REAGENTS_PER_MATERIAL_SHEET)
	result_amount = 1

/datum/chemical_reaction/plasmasolidification/on_reaction(datum/reagents/holder, created_volume)
	new /obj/item/stack/material/plasma(get_turf(holder.my_atom), created_volume)

/datum/chemical_reaction/plastication
	name = "Plastic"
	result = null
	required_reagents = list(/datum/reagent/acid/polyacid = 1, /datum/reagent/toxin/plasticide = REAGENTS_PER_MATERIAL_SHEET)
	result_amount = 1

/datum/chemical_reaction/plastication/on_reaction(datum/reagents/holder, created_volume)
	new /obj/item/stack/material/plastic(get_turf(holder.my_atom), created_volume)

/datum/chemical_reaction/solidification_glass
	name = "Glass"
	result = null
	required_reagents = list(/datum/reagent/silicate = 1, /datum/reagent/toxin/plasticide = REAGENTS_PER_MATERIAL_SHEET)
	result_amount = 1

/datum/chemical_reaction/solidification_glass/on_reaction(datum/reagents/holder, created_volume)
	new /obj/item/stack/material/glass(get_turf(holder.my_atom), created_volume)

/* Explosion reactions */

/datum/chemical_reaction/explosion
	name = "Explosion"
	mix_message = null
	result_amount = 2
	log_is_important = 1

/datum/chemical_reaction/explosion/on_reaction(datum/reagents/holder, created_volume)
	var/datum/effect/effect/system/reagents_explosion/e = new()
	e.set_up(created_volume, holder.my_atom, 0, 0)
	e.start()
	holder.clear_reagents()

/datum/chemical_reaction/explosion/potassium
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/potassium = 1)

/datum/chemical_reaction/explosion/hair_solution
	required_reagents = list(/datum/reagent/toxin/hair_grower = 1, /datum/reagent/toxin/hair_remover = 1)
	result_amount = 1

/datum/chemical_reaction/explosion/nitroglycerin
	name = "Nitroglycerin"
	// will be deleted in on_reaction, anyways
	// result = /datum/reagent/Nitroglycerin
	required_reagents = list(/datum/reagent/glycerol = 1, /datum/reagent/acid/polyacid = 1, /datum/reagent/acid = 1)

/* Non-explosion reactions for grenades */

/datum/chemical_reaction/flash_powder
	name = "Flash powder"
	result = null
	required_reagents = list(/datum/reagent/aluminum = 1, /datum/reagent/potassium = 1, /datum/reagent/sulfur = 1 )
	result_amount = null

/datum/chemical_reaction/flash_powder/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(2, 1, location)
	s.start()
	for(var/mob/living/carbon/M in viewers(world.view, location))
		var/eye_safety = M.eyecheck()
		switch(get_dist(M, location))
			if(0 to 3)
				if(eye_safety >= FLASH_PROTECTION_MODERATE)
					continue

				M.flash_eyes()
				M.Weaken(15)
				M.Stun(10)

			if(4 to 5)
				if(eye_safety >= FLASH_PROTECTION_MODERATE)
					continue

				M.flash_eyes()
				M.Stun(5)

/datum/chemical_reaction/emp_pulse
	name = "EMP Pulse"
	result = null
	required_reagents = list(/datum/reagent/uranium = 1, /datum/reagent/iron = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense
	result_amount = 2
	log_is_important = 1

/datum/chemical_reaction/emp_pulse/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	// 100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
	// 200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
	empulse(location, round(created_volume / 24), round(created_volume / 14), 1)
	holder.clear_reagents()

/datum/chemical_reaction/napalm
	name = "Napalm"
	result = null
	required_reagents = list(/datum/reagent/aluminum = 1, /datum/reagent/toxin/plasma = 1, /datum/reagent/acid = 1 )
	result_amount = 1
	log_is_important = 1

/datum/chemical_reaction/napalm/on_reaction(datum/reagents/holder, created_volume)
	var/turf/location = get_turf(holder.my_atom.loc)
	for(var/turf/simulated/floor/target_tile in range(0,location))
		target_tile.assume_gas("plasma", created_volume, 400 CELSIUS)
		spawn (0) target_tile.hotspot_expose(700, 400)
	holder.del_reagent("napalm")

/datum/chemical_reaction/chemsmoke
	name = "Chemsmoke"
	result = null
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/sugar = 1, /datum/reagent/phosphorus = 1)
	result_amount = 0.4

/datum/chemical_reaction/chemsmoke/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/smoke_spread/chem/S = new /datum/effect/effect/system/smoke_spread/chem
	S.attach(location)
	S.set_up(holder, created_volume, 0, location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	spawn(0)
		S.start()
	holder.clear_reagents()

/datum/chemical_reaction/foam
	name = "Foam"
	result = null
	required_reagents = list(/datum/reagent/surfactant = 1, /datum/reagent/water = 1)
	result_amount = 2
	mix_message = "The solution violently bubbles!"

/datum/chemical_reaction/foam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='warning'>The solution spews out foam!</span>")

	var/datum/effect/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 0)
	s.start()
	holder.clear_reagents()

/datum/chemical_reaction/metalfoam
	name = "Metal Foam"
	result = null
	required_reagents = list(/datum/reagent/aluminum = 3, /datum/reagent/foaming_agent = 1, /datum/reagent/acid/polyacid = 1)
	result_amount = 5

/datum/chemical_reaction/metalfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='warning'>The solution spews out a metalic foam!</span>")

	var/datum/effect/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 1)
	s.start()

/datum/chemical_reaction/ironfoam
	name = "Iron Foam"
	result = null
	required_reagents = list(/datum/reagent/iron = 3, /datum/reagent/foaming_agent = 1, /datum/reagent/acid/polyacid = 1)
	result_amount = 5

/datum/chemical_reaction/ironfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='warning'>The solution spews out a metalic foam!</span>")

	var/datum/effect/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 2)
	s.start()

/* Paint */

/datum/chemical_reaction/red_paint
	name = "Red paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/crayon_dust/red = 1)
	result_amount = 5

/datum/chemical_reaction/red_paint/send_data()
	return "#fe191a"

/datum/chemical_reaction/orange_paint
	name = "Orange paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/crayon_dust/orange = 1)
	result_amount = 5

/datum/chemical_reaction/orange_paint/send_data()
	return "#ffbe4f"

/datum/chemical_reaction/yellow_paint
	name = "Yellow paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/crayon_dust/yellow = 1)
	result_amount = 5

/datum/chemical_reaction/yellow_paint/send_data()
	return "#fdfe7d"

/datum/chemical_reaction/green_paint
	name = "Green paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/crayon_dust/green = 1)
	result_amount = 5

/datum/chemical_reaction/green_paint/send_data()
	return "#18a31a"

/datum/chemical_reaction/blue_paint
	name = "Blue paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/crayon_dust/blue = 1)
	result_amount = 5

/datum/chemical_reaction/blue_paint/send_data()
	return "#247cff"

/datum/chemical_reaction/purple_paint
	name = "Purple paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/crayon_dust/purple = 1)
	result_amount = 5

/datum/chemical_reaction/purple_paint/send_data()
	return "#cc0099"

/datum/chemical_reaction/grey_paint //mime
	name = "Grey paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/crayon_dust/grey = 1)
	result_amount = 5

/datum/chemical_reaction/grey_paint/send_data()
	return "#808080"

/datum/chemical_reaction/brown_paint
	name = "Brown paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/crayon_dust/brown = 1)
	result_amount = 5

/datum/chemical_reaction/brown_paint/send_data()
	return "#846f35"

/datum/chemical_reaction/blood_paint
	name = "Blood paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/blood = 2)
	result_amount = 5

/datum/chemical_reaction/blood_paint/send_data(datum/reagents/T)
	var/t = T.get_data("blood")
	if(t && t["blood_colour"])
		return t["blood_colour"]
	return "#fe191a" // Probably red

/datum/chemical_reaction/milk_paint
	name = "Milk paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/drink/milk = 5)
	result_amount = 5

/datum/chemical_reaction/milk_paint/send_data()
	return "#f0f8ff"

/datum/chemical_reaction/orange_juice_paint
	name = "Orange juice paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/drink/juice/orange = 5)
	result_amount = 5

/datum/chemical_reaction/orange_juice_paint/send_data()
	return "#e78108"

/datum/chemical_reaction/tomato_juice_paint
	name = "Tomato juice paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/drink/juice/tomato = 5)
	result_amount = 5

/datum/chemical_reaction/tomato_juice_paint/send_data()
	return "#731008"

/datum/chemical_reaction/lime_juice_paint
	name = "Lime juice paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/drink/juice/lime = 5)
	result_amount = 5

/datum/chemical_reaction/lime_juice_paint/send_data()
	return "#365e30"

/datum/chemical_reaction/carrot_juice_paint
	name = "Carrot juice paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/drink/juice/carrot = 5)
	result_amount = 5

/datum/chemical_reaction/carrot_juice_paint/send_data()
	return "#973800"

/datum/chemical_reaction/berry_juice_paint
	name = "Berry juice paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/drink/juice/berry = 5)
	result_amount = 5

/datum/chemical_reaction/berry_juice_paint/send_data()
	return "#990066"

/datum/chemical_reaction/grape_juice_paint
	name = "Grape juice paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/drink/juice/grape = 5)
	result_amount = 5

/datum/chemical_reaction/grape_juice_paint/send_data()
	return "#863333"

/datum/chemical_reaction/poisonberry_juice_paint
	name = "Poison berry juice paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/toxin/poisonberryjuice = 5)
	result_amount = 5

/datum/chemical_reaction/poisonberry_juice_paint/send_data()
	return "#863353"

/datum/chemical_reaction/watermelon_juice_paint
	name = "Watermelon juice paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/drink/juice/watermelon = 5)
	result_amount = 5

/datum/chemical_reaction/watermelon_juice_paint/send_data()
	return "#b83333"

/datum/chemical_reaction/lemon_juice_paint
	name = "Lemon juice paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/drink/juice/lemon = 5)
	result_amount = 5

/datum/chemical_reaction/lemon_juice_paint/send_data()
	return "#afaf00"

/datum/chemical_reaction/banana_juice_paint
	name = "Banana juice paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/drink/juice/banana = 5)
	result_amount = 5

/datum/chemical_reaction/banana_juice_paint/send_data()
	return "#c3af00"

/datum/chemical_reaction/potato_juice_paint
	name = "Potato juice paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/drink/juice/potato = 5)
	result_amount = 5

/datum/chemical_reaction/potato_juice_paint/send_data()
	return "#302000"

/datum/chemical_reaction/carbon_paint
	name = "Carbon paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/carbon = 1)
	result_amount = 5

/datum/chemical_reaction/carbon_paint/send_data()
	return "#333333"

/datum/chemical_reaction/aluminum_paint
	name = "Aluminum paint"
	result = /datum/reagent/paint
	required_reagents = list(/datum/reagent/toxin/plasticide = 1, /datum/reagent/water = 3, /datum/reagent/aluminum = 1)
	result_amount = 5

/datum/chemical_reaction/aluminum_paint/send_data()
	return "#f0f8ff"

/* Metroid cores */

/datum/chemical_reaction/metroid
	var/required = null

/datum/chemical_reaction/metroid/can_happen(datum/reagents/holder)
	if(holder.my_atom && istype(holder.my_atom, required))
		var/obj/item/metroid_extract/T = holder.my_atom
		if(T.Uses > 0)
			return ..()
	return 0

/datum/chemical_reaction/metroid/on_reaction(datum/reagents/holder)
	var/obj/item/metroid_extract/T = holder.my_atom
	T.Uses--
	if(T.Uses <= 0)
		T.visible_message("\icon[T]<span class='notice'>\The [T]'s power is consumed in the reaction.</span>")
		T.SetName("used metroid extract")
		T.desc = "This extract has been used up."

//Green
/datum/chemical_reaction/metroid/create
	name = "Metroid Spawn"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/green

/datum/chemical_reaction/metroid/create/on_reaction(datum/reagents/holder)
	holder.my_atom.visible_message("<span class='warning'>Infused with plasma, the core begins to quiver and grow, and soon a new baby metroid emerges from it!</span>")
	var/mob/living/carbon/metroid/S = new /mob/living/carbon/metroid
	S.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/monkey
	name = "Metroid Monkey"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/green

/datum/chemical_reaction/metroid/monkey/on_reaction(datum/reagents/holder)
	for(var/i = 1, i <= 3, i++)
		var /obj/item/reagent_containers/food/monkeycube/M = new /obj/item/reagent_containers/food/monkeycube
		M.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/heal
	name = "Metroid heal"
	result = /datum/reagent/tricordrazine
	required_reagents = list(/datum/reagent/water = 1)
	result_amount = 15
	required = /obj/item/metroid_extract/green

//Grey
/datum/chemical_reaction/metroid/mutate
	name = "Mutation Toxin"
	result = /datum/reagent/metroidtoxin
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/grey

//Metal
/datum/chemical_reaction/metroid/metal
	name = "Metroid Metal"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/metal

/datum/chemical_reaction/metroid/metal/on_reaction(datum/reagents/holder)
	var/obj/item/stack/material/steel/M = new /obj/item/stack/material/steel
	M.amount = 15
	M.forceMove(get_turf(holder.my_atom))
	var/obj/item/stack/material/plasteel/P = new /obj/item/stack/material/plasteel
	P.amount = 5
	P.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/glass
	name = "Metroid Glass"
	result = null
	required_reagents = list(/datum/reagent/water = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/metal

/datum/chemical_reaction/metroid/glass/on_reaction(datum/reagents/holder)
	var/obj/item/stack/material/glass/M = new /obj/item/stack/material/glass
	M.amount = 15
	M.forceMove(get_turf(holder.my_atom))
	var/obj/item/stack/material/glass/reinforced/P = new /obj/item/stack/material/glass/reinforced
	P.amount = 5
	P.forceMove(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/marble
	name = "Metroid marble"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/metal

/datum/chemical_reaction/metroid/marble/on_reaction(datum/reagents/holder)
	var/obj/item/stack/material/marble/M = new /obj/item/stack/material/marble
	M.amount = 30
	M.forceMove(get_turf(holder.my_atom))
	..()

//Gold
/datum/chemical_reaction/metroid/f_crit
	name = "Metroid Friendly Crit"
	result = null
	required_reagents = list(/datum/reagent/water = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/gold
	var/list/possible_mobs = list(
							/mob/living/simple_animal/cat,
							/mob/living/simple_animal/cat/kitten,
							/mob/living/simple_animal/corgi,
							/mob/living/simple_animal/corgi/puppy,
							/mob/living/simple_animal/cow,
							/mob/living/simple_animal/chick,
							/mob/living/simple_animal/chicken
							)

/datum/chemical_reaction/metroid/f_crit/on_reaction(datum/reagents/holder)
	var/type = pick(possible_mobs)
	new type(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/n_crit
	name = "Metroid Neutral Crit"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/gold
	var/list/possible_mobs = list(
							/mob/living/simple_animal/hostile/asteroid/goliath,
							/mob/living/simple_animal/hostile/asteroid/sand_lurker,
							/mob/living/simple_animal/hostile/asteroid/shooter,
							/mob/living/simple_animal/hostile/asteroid/hoverhead
							)

/datum/chemical_reaction/metroid/n_crit/on_reaction(datum/reagents/holder)
	..()
	for(var/i = 1, i <= 3, i++)
		var/mob/living/simple_animal/hostile/asteroid/type = pick(possible_mobs)
		new type(get_turf(holder.my_atom))
		type.faction = "neutral"

/datum/chemical_reaction/metroid/d_crit
	name = "Metroid Dangerous Crit"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/gold
	var/list/possible_mobs = list(
							/mob/living/simple_animal/hostile/faithless,
							/mob/living/simple_animal/hostile/creature,
							/mob/living/simple_animal/hostile/bear,
							/mob/living/simple_animal/hostile/maneater,
							/mob/living/simple_animal/hostile/mimic,
							/mob/living/simple_animal/hostile/carp/pike,
							/mob/living/simple_animal/hostile/tree,
							/mob/living/simple_animal/hostile/vagrant,
							/mob/living/simple_animal/hostile/voxslug
							)

/datum/chemical_reaction/metroid/d_crit/on_reaction(datum/reagents/holder)
	for(var/i = 1, i <= 5, i++)
		var/type = pick(possible_mobs)
		new type(get_turf(holder.my_atom))
	..()

//Silver
/datum/chemical_reaction/metroid/bork
	name = "Metroid Bork"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/silver

/datum/chemical_reaction/metroid/bork/on_reaction(datum/reagents/holder)
	var/list/borks = typesof(/obj/item/reagent_containers/food) - /obj/item/reagent_containers/food
	playsound(holder.my_atom, 'sound/effects/phasein.ogg', 100, 1)
	for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
		if(M.eyecheck() < FLASH_PROTECTION_MODERATE)
			M.flash_eyes()

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.forceMove(get_turf(holder.my_atom))
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH, SOUTH, EAST, WEST))
	..()

//Blue
/datum/chemical_reaction/metroid/frost
	name = "Metroid Frost Oil"
	result = /datum/reagent/frostoil
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 10
	required = /obj/item/metroid_extract/blue

/datum/chemical_reaction/metroid/foam
	name = "Metroid Foam"
	result = /datum/reagent/surfactant
	required_reagents = list(/datum/reagent/water = 1)
	result_amount = 10
	required = /obj/item/metroid_extract/blue

/datum/chemical_reaction/metroid/stabilizer
	name = "Metroid Stabilizer"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	required = /obj/item/metroid_extract/blue

/datum/chemical_reaction/metroid/stabilizer/on_reaction(datum/reagents/holder)
	new /obj/item/metroid_stabilizer(get_turf(holder.my_atom))
	..()

//Dark Blue
/datum/chemical_reaction/metroid/freeze
	name = "Metroid Freeze"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/darkblue
	mix_message = "The metroid extract begins to vibrate violently!"

/datum/chemical_reaction/metroid/freeze/on_reaction(datum/reagents/holder)
	set waitfor = 0
	..()
	sleep(50)
	playsound(holder.my_atom, 'sound/effects/phasein.ogg', 100, 1)
	for(var/mob/living/M in range (get_turf(holder.my_atom), 7))
		M.bodytemperature -= 140
		to_chat(M, "<span class='warning'>You feel a chill!</span>")

/datum/chemical_reaction/metroid/chill_potion
	name = "Metroid Сhill Potion"
	result = null
	required_reagents = list(/datum/reagent/water = 1)
	required = /obj/item/metroid_extract/darkblue

/datum/chemical_reaction/metroid/chill_potion/on_reaction(datum/reagents/holder)
	new /obj/item/chill_potion(get_turf(holder.my_atom))
	..()

//Orange
/datum/chemical_reaction/metroid/casp
	name = "Metroid Capsaicin Oil"
	result = /datum/reagent/capsaicin
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 10
	required = /obj/item/metroid_extract/orange

/datum/chemical_reaction/metroid/fire
	name = "Metroid fire"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/orange
	mix_message = "The metroid extract begins to vibrate violently!"

/datum/chemical_reaction/metroid/fire/on_reaction(datum/reagents/holder)
	set waitfor = 0
	..()
	sleep(50)
	if(!(holder.my_atom && holder.my_atom.loc))
		return

	var/turf/location = get_turf(holder.my_atom)
	location.assume_gas("plasma", 250, 1400)
	location.hotspot_expose(700, 400)

//Yellow
/datum/chemical_reaction/metroid/overload
	name = "Metroid EMP"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/yellow

/datum/chemical_reaction/metroid/overload/on_reaction(datum/reagents/holder, created_volume)
	..()
	empulse(get_turf(holder.my_atom), 3, 7)

/datum/chemical_reaction/metroid/cell
	name = "Metroid Powercell"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/yellow

/datum/chemical_reaction/metroid/cell/on_reaction(datum/reagents/holder, created_volume)
	..()
	new /obj/item/cell/metroid(get_turf(holder.my_atom))

/datum/chemical_reaction/metroid/glow
	name = "Metroid Glow"
	result = null
	required_reagents = list(/datum/reagent/water = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/yellow
	mix_message = "The contents of the metroid core harden and begin to emit a warm, bright light."

/datum/chemical_reaction/metroid/glow/on_reaction(datum/reagents/holder, created_volume)
	..()
	new /obj/item/device/flashlight/metroid(get_turf(holder.my_atom))

//Purple
/datum/chemical_reaction/metroid/psteroid
	name = "Metroid Steroid"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/purple

/datum/chemical_reaction/metroid/psteroid/on_reaction(datum/reagents/holder, created_volume)
	..()
	var/obj/item/metroidsteroid/P = new /obj/item/metroidsteroid
	P.forceMove(get_turf(holder.my_atom))

/datum/chemical_reaction/metroid/jam
	name = "Metroid Jam"
	result = /datum/reagent/metroidjelly
	required_reagents = list(/datum/reagent/blood = 5)
	result_amount = 10
	required = /obj/item/metroid_extract/purple

//Dark Purple
/datum/chemical_reaction/metroid/plasma
	name = "Metroid Plasma"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/darkpurple

/datum/chemical_reaction/metroid/plasma/on_reaction(datum/reagents/holder)
	..()
	var/obj/item/stack/material/plasma/P = new /obj/item/stack/material/plasma
	P.amount = 3
	P.forceMove(get_turf(holder.my_atom))

//Red
/datum/chemical_reaction/metroid/mutation
	name = "Metroid Mutation"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required = /obj/item/metroid_extract/red

/datum/chemical_reaction/metroid/mutation/on_reaction(datum/reagents/holder)
	new /obj/item/metroid_mutation(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/bloodlust
	name = "Bloodlust"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/red

/datum/chemical_reaction/metroid/bloodlust/on_reaction(datum/reagents/holder)
	..()
	for(var/mob/living/carbon/metroid/metroid in viewers(get_turf(holder.my_atom), null))
		metroid.rabid = 1
		metroid.visible_message("<span class='warning'>The [metroid] is driven into a frenzy!</span>")

//Pink
/datum/chemical_reaction/metroid/docility
	name = "Metroid Docility"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/pink

/datum/chemical_reaction/metroid/docility/on_reaction(datum/reagents/holder)
	..()
	new /obj/item/metroidpotion(get_turf(holder.my_atom))

//Black
/datum/chemical_reaction/metroid/mutate2
	name = "Advanced Mutation Toxin"
	result = /datum/reagent/ametroidtoxin
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/black

//Oil
/datum/chemical_reaction/metroid/explosion
	name = "Metroid Explosion"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/oil
	mix_message = "The metroid extract begins to vibrate violently!"

/datum/chemical_reaction/metroid/explosion/on_reaction(datum/reagents/holder)
	set waitfor = 0
	..()
	sleep(50)
	explosion(get_turf(holder.my_atom), 1, 3, 6)

//Light Pink
/datum/chemical_reaction/metroid/potion2
	name = "Metroid Potion 2"
	result = null
	result_amount = 1
	required = /obj/item/metroid_extract/lightpink
	required_reagents = list(/datum/reagent/toxin/plasma = 1)

/datum/chemical_reaction/metroid/potion2/on_reaction(datum/reagents/holder)
	..()
	new /obj/item/metroidpotion2(get_turf(holder.my_atom))

//Adamantine
/datum/chemical_reaction/metroid/golem
	name = "Metroid Golem"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/adamantine

/datum/chemical_reaction/metroid/golem/on_reaction(datum/reagents/holder)
	..()
	new /obj/item/golem_shell(get_turf(holder.my_atom))

/datum/chemical_reaction/metroid/adamantine
	name = "Adamantine"
	result = null
	required_reagents = list(/datum/reagent/blood = 5)
	result_amount = 1
	required = /obj/item/metroid_extract/adamantine

/datum/chemical_reaction/metroid/adamantine/on_reaction(datum/reagents/holder)
	..()
	new /obj/item/stack/material/adamantine(get_turf(holder.my_atom))

//Sepia
/datum/chemical_reaction/metroid/film
	name = "Metroid Film"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	result_amount = 2
	required = /obj/item/metroid_extract/sepia

/datum/chemical_reaction/metroid/film/on_reaction(datum/reagents/holder)
	for(var/i in 1 to result_amount)
		new /obj/item/device/camera_film(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/camera
	name = "Metroid Camera"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	result_amount = 1
	required = /obj/item/metroid_extract/sepia

/datum/chemical_reaction/metroid/camera/on_reaction(datum/reagents/holder)
	new /obj/item/device/camera(get_turf(holder.my_atom))
	..()

//Bluespace
/datum/chemical_reaction/metroid/teleport
	name = "Metroid Teleport"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required = /obj/item/metroid_extract/bluespace
	reaction_sound = 'sound/effects/teleport.ogg'

/datum/chemical_reaction/metroid/teleport/on_reaction(datum/reagents/holder)
	new /obj/item/stack/telecrystal/bluespace_crystal(get_turf(holder.my_atom))
	..()

//pyrite
/datum/chemical_reaction/metroid/paint
	name = "Metroid Paint"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required = /obj/item/metroid_extract/pyrite

/datum/chemical_reaction/metroid/paint/on_reaction(datum/reagents/holder)
	new /obj/item/reagent_containers/vessel/paint/random(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/crayon
	name = "Metroid Crayon"
	result = null
	required_reagents = list(/datum/reagent/blood = 1)
	required = /obj/item/metroid_extract/pyrite

/datum/chemical_reaction/metroid/crayon/on_reaction(datum/reagents/holder)
	new /obj/item/pen/crayon/random(get_turf(holder.my_atom))
	..()

//cerulean
/datum/chemical_reaction/metroid/extract_enhance
	name = "Extract Enhancer"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required = /obj/item/metroid_extract/cerulean

/datum/chemical_reaction/metroid/extract_enhance/on_reaction(datum/reagents/holder)
	new /obj/item/metroidsteroid2(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/soap_key
	name = "Soap Key"
	result = null
	required_reagents = list(/datum/reagent/frostoil = 2, /datum/reagent/space_cleaner = 5)
	var/strength = 3

/datum/chemical_reaction/soap_key/can_happen(datum/reagents/holder)
	if(holder.my_atom && istype(holder.my_atom, /obj/item/soap))
		return ..()
	return 0

/datum/chemical_reaction/soap_key/on_reaction(datum/reagents/holder)
	var/obj/item/soap/S = holder.my_atom
	if(S.key_data)
		var/obj/item/key/soap/key = new(get_turf(holder.my_atom), S.key_data)
		key.uses = strength
	..()

//rainbow
/datum/chemical_reaction/metroid/random_metroid
	name = "Random Metroid"
	result = null
	required_reagents = list(/datum/reagent/toxin/plasma = 5)
	required = /obj/item/metroid_extract/rainbow

/datum/chemical_reaction/metroid/random_metroid/on_reaction(datum/reagents/holder)
	var/colour = pick(list(
		"green",
		"purple",
		"metal",
		"orange",
		"blue",
		"dark blue",
		"dark purple",
		"yellow",
		"silver",
		"pink",
		"red",
		"gold",
		"grey",
		"sepia",
		"bluespace",
		"cerulean",
		"pyrite",
		"light pink",
		"oil",
		"adamantine",
		"black"))
	new /mob/living/carbon/metroid(get_turf(holder.my_atom), colour)
	..()

/datum/chemical_reaction/metroid/mind_tansfer
	name = "Mind Transfer"
	result = null
	required_reagents = list(/datum/reagent/blood = 5)
	required = /obj/item/metroid_extract/rainbow

/datum/chemical_reaction/metroid/mind_tansfer/on_reaction(datum/reagents/holder)
	new /obj/item/metroid_transference/(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/metroid/metroidbomb
	name = "Metroid Bomb"
	result = null
	required_reagents = list(/datum/reagent/metroidjelly = 5)
	required = /obj/item/metroid_extract/rainbow

/datum/chemical_reaction/metroid/metroidbomb/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	var/obj/item/grenade/clusterbang/metroid/S = new (T)
	S.visible_message(SPAN_DANGER("Infused with slime jelly, the core begins to expand uncontrollably!"))
	S.icon_state = "metroidbang_active"
	S.active = TRUE
	S.set_next_think_ctx("think_detonate", world.time + rand(1.5 SECONDS, 6 SECONDS))
	var/lastkey = holder.my_atom.fingerprintslast
	message_admins("[key_name_admin(lastkey)] primed an explosive Brorble Brorble for detonation.")
	log_game("[key_name(lastkey)] primed an explosive Brorble Brorble for detonation.")
	..()

/* Food */

/datum/chemical_reaction/tofu
	name = "Tofu"
	result = null
	required_reagents = list(/datum/reagent/drink/milk/soymilk = 10)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 1

/datum/chemical_reaction/tofu/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/tofu(location)

/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	result = null
	required_reagents = list(/datum/reagent/drink/milk/soymilk = 2, /datum/reagent/nutriment/coco = 2, /datum/reagent/sugar = 2)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/chocolatebar(location)

/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	result = null
	required_reagents = list(/datum/reagent/drink/milk = 2, /datum/reagent/nutriment/coco = 2, /datum/reagent/sugar = 2)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar2/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/chocolatebar(location)

/datum/chemical_reaction/hot_coco
	name = "Hot Coco"
	result = /datum/reagent/drink/hot_coco
	required_reagents = list(/datum/reagent/water = 5, /datum/reagent/nutriment/coco = 1)
	result_amount = 5

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	result = /datum/reagent/nutriment/soysauce
	required_reagents = list(/datum/reagent/drink/milk/soymilk = 4, /datum/reagent/acid = 1)
	result_amount = 5

/datum/chemical_reaction/ketchup
	name = "Ketchup"
	result = /datum/reagent/nutriment/ketchup
	required_reagents = list(/datum/reagent/drink/juice/tomato = 2, /datum/reagent/water = 1, /datum/reagent/sugar = 1)
	result_amount = 4

/datum/chemical_reaction/barbecue
	name = "Barbecue Sauce"
	result = /datum/reagent/nutriment/barbecue
	required_reagents = list(/datum/reagent/nutriment/ketchup = 2, /datum/reagent/blackpepper = 1, /datum/reagent/sodiumchloride = 1)
	result_amount = 4

/datum/chemical_reaction/garlicsauce
	name = "Garlic Sauce"
	result = /datum/reagent/nutriment/garlicsauce
	required_reagents = list(/datum/reagent/drink/juice/garlic = 1, /datum/reagent/nutriment/cornoil = 1)
	result_amount = 2

/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	result = null
	required_reagents = list(/datum/reagent/drink/milk = 40)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 1

/datum/chemical_reaction/cheesewheel/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/sliceable/cheesewheel(location)

/datum/chemical_reaction/faggot
	name = "Faggot"
	result = null
	required_reagents = list(/datum/reagent/nutriment/protein = 3, /datum/reagent/nutriment/flour = 5)
	result_amount = 3

/datum/chemical_reaction/faggot/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/rawmeatball(location)

/datum/chemical_reaction/dough
	name = "Dough"
	result = null
	required_reagents = list(/datum/reagent/nutriment/protein/egg = 3, /datum/reagent/nutriment/flour = 10, /datum/reagent/water = 5)
	result_amount = 1

/datum/chemical_reaction/dough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/dough(location)

/datum/chemical_reaction/syntiflesh
	name = "Syntiflesh"
	result = null
	required_reagents = list(/datum/reagent/blood = 5, /datum/reagent/clonexadone = 1)
	result_amount = 1

/datum/chemical_reaction/syntiflesh/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/meat/syntiflesh(location)

/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	result = /datum/reagent/drink/hot_ramen
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/drink/dry_ramen = 3)
	result_amount = 3

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	result = /datum/reagent/drink/hell_ramen
	required_reagents = list(/datum/reagent/capsaicin = 1, /datum/reagent/drink/hot_ramen = 6)
	result_amount = 6

/datum/chemical_reaction/chicken_soup
	name = "Hot Ramen"
	result = /datum/reagent/drink/chicken_soup
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/drink/chicken_powder = 3)
	result_amount = 3

/datum/chemical_reaction/mint
	result = null
	required_reagents = list("sugar" = 5, "frostoil" = 5)
	result_amount = 1

/datum/chemical_reaction/mint/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/mint(location)

/datum/chemical_reaction/candy_corn
	result = null
	required_reagents = list("sugar" = 5, "cornoil" = 5)
	result_amount = 1

/datum/chemical_reaction/candy_corn/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/candy_corn(location)

/* Alcohol */

/datum/chemical_reaction/goldschlager
	name = "Goldschlager"
	result = /datum/reagent/ethanol/goldschlager
	required_reagents = list(/datum/reagent/ethanol/vodka = 10, /datum/reagent/gold = 1)
	result_amount = 10

/datum/chemical_reaction/patron
	name = "Patron"
	result = /datum/reagent/ethanol/patron
	required_reagents = list(/datum/reagent/ethanol/tequilla = 10, /datum/reagent/silver = 1)
	result_amount = 10

/datum/chemical_reaction/bilk
	name = "Bilk"
	result = /datum/reagent/ethanol/bilk
	required_reagents = list(/datum/reagent/drink/milk = 1, /datum/reagent/ethanol/beer = 1)
	result_amount = 2

/datum/chemical_reaction/icetea
	name = "Iced Tea"
	result = /datum/reagent/drink/tea/icetea
	required_reagents = list(/datum/reagent/drink/ice = 1, /datum/reagent/drink/tea = 2)
	result_amount = 3

/datum/chemical_reaction/icecoffee
	name = "Iced Coffee"
	result = /datum/reagent/caffeine/coffee/icecoffee
	required_reagents = list(/datum/reagent/drink/ice = 1, /datum/reagent/caffeine/coffee = 2)
	result_amount = 3

/datum/chemical_reaction/nuka_cola
	name = "Nuka Cola"
	result = /datum/reagent/drink/nuka_cola
	required_reagents = list(/datum/reagent/uranium = 1, /datum/reagent/drink/space_cola = 5)
	result_amount = 5

/datum/chemical_reaction/moonshine
	name = "Moonshine"
	result = /datum/reagent/ethanol/moonshine
	required_reagents = list(/datum/reagent/nutriment = 10)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 10

/datum/chemical_reaction/grenadine
	name = "Grenadine Syrup"
	result = /datum/reagent/drink/grenadine
	required_reagents = list(/datum/reagent/drink/juice/berry = 10)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 10

/datum/chemical_reaction/wine
	name = "Wine"
	result = /datum/reagent/ethanol/wine
	required_reagents = list(/datum/reagent/drink/juice/grape = 10)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 10

/datum/chemical_reaction/pwine
	name = "Poison Wine"
	result = /datum/reagent/ethanol/pwine
	required_reagents = list(/datum/reagent/toxin/poisonberryjuice = 10)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 10

/datum/chemical_reaction/melonliquor
	name = "Melon Liquor"
	result = /datum/reagent/ethanol/melonliquor
	required_reagents = list(/datum/reagent/drink/juice/watermelon = 10)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 10

/datum/chemical_reaction/bluecuracao
	name = "Blue Curacao"
	result = /datum/reagent/ethanol/bluecuracao
	required_reagents = list(/datum/reagent/drink/juice/orange = 10)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 10

/datum/chemical_reaction/spacebeer
	name = "Space Beer"
	result = /datum/reagent/ethanol/beer
	required_reagents = list(/datum/reagent/nutriment/cornoil = 10)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 10

/datum/chemical_reaction/vodka
	name = "Vodka"
	result = /datum/reagent/ethanol/vodka
	required_reagents = list(/datum/reagent/drink/juice/potato = 10)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 10

/datum/chemical_reaction/sake
	name = "Sake"
	result = /datum/reagent/ethanol/sake
	required_reagents = list(/datum/reagent/nutriment/rice = 10)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 10

/datum/chemical_reaction/kahlua
	name = "Kahlua"
	result = /datum/reagent/ethanol/kahlua
	required_reagents = list(/datum/reagent/caffeine/coffee = 5, /datum/reagent/sugar = 5)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 5

/datum/chemical_reaction/gin_tonic
	name = "Gin and Tonic"
	result = /datum/reagent/ethanol/gintonic
	required_reagents = list(/datum/reagent/ethanol/gin = 2, /datum/reagent/drink/tonic = 1)
	result_amount = 3

/datum/chemical_reaction/cuba_libre
	name = "Cuba Libre"
	result = /datum/reagent/ethanol/cuba_libre
	required_reagents = list(/datum/reagent/ethanol/rum = 2, /datum/reagent/drink/space_cola = 1)
	result_amount = 3

/datum/chemical_reaction/martini
	name = "Classic Martini"
	result = /datum/reagent/ethanol/martini
	required_reagents = list(/datum/reagent/ethanol/gin = 2, /datum/reagent/ethanol/vermouth = 1)
	result_amount = 3

/datum/chemical_reaction/vodkamartini
	name = "Vodka Martini"
	result = /datum/reagent/ethanol/vodkamartini
	required_reagents = list(/datum/reagent/ethanol/vodka = 2, /datum/reagent/ethanol/vermouth = 1)
	result_amount = 3

/datum/chemical_reaction/white_russian
	name = "White Russian"
	result = /datum/reagent/ethanol/white_russian
	required_reagents = list(/datum/reagent/ethanol/black_russian = 2, /datum/reagent/drink/milk/cream = 1)
	result_amount = 3

/datum/chemical_reaction/whiskey_cola
	name = "Whiskey Cola"
	result = /datum/reagent/ethanol/whiskey_cola
	required_reagents = list(/datum/reagent/ethanol/whiskey = 2, /datum/reagent/drink/space_cola = 1)
	result_amount = 3

/datum/chemical_reaction/screwdriver
	name = "Screwdriver"
	result = /datum/reagent/ethanol/screwdrivercocktail
	required_reagents = list(/datum/reagent/ethanol/vodka = 2, /datum/reagent/drink/juice/orange = 1)
	result_amount = 3

/datum/chemical_reaction/battuta
	name = "Ibn Battuta"
	result = /datum/reagent/ethanol/battuta
	required_reagents = list(/datum/reagent/ethanol/herbal = 2, /datum/reagent/drink/juice/orange = 1)
	catalysts = list(/datum/reagent/nutriment/mint)
	result_amount = 3

/datum/chemical_reaction/magellan
	name = "Magellan"
	result = /datum/reagent/ethanol/magellan
	required_reagents = list(/datum/reagent/ethanol/wine = 1,  /datum/reagent/ethanol/whiskey/specialwhiskey = 1)
	catalysts = list(/datum/reagent/sugar)
	result_amount = 2

/datum/chemical_reaction/zhenghe
	name = "Zheng He"
	result = /datum/reagent/ethanol/zhenghe
	required_reagents = list(/datum/reagent/drink/tea = 2, /datum/reagent/ethanol/vermouth = 1)
	result_amount = 3

/datum/chemical_reaction/armstrong
	name = "Armstrong"
	result = /datum/reagent/ethanol/armstrong
	required_reagents = list(/datum/reagent/ethanol/beer = 2, /datum/reagent/ethanol/vodka = 1, /datum/reagent/drink/juice/lime = 1)
	result_amount = 4

/datum/chemical_reaction/bloody_mary
	name = "Bloody Mary"
	result = /datum/reagent/ethanol/bloody_mary
	required_reagents = list(/datum/reagent/ethanol/vodka = 2, /datum/reagent/drink/juice/tomato = 3, /datum/reagent/drink/juice/lime = 1)
	result_amount = 6

/datum/chemical_reaction/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	result = /datum/reagent/ethanol/gargle_blaster
	required_reagents = list(/datum/reagent/ethanol/vodka = 2, /datum/reagent/ethanol/gin = 1, /datum/reagent/ethanol/whiskey = 1, /datum/reagent/ethanol/cognac = 1, /datum/reagent/drink/juice/lime = 1)
	result_amount = 6

/datum/chemical_reaction/brave_bull
	name = "Brave Bull"
	result = /datum/reagent/ethanol/coffee/brave_bull
	required_reagents = list(/datum/reagent/ethanol/tequilla = 2, /datum/reagent/ethanol/kahlua = 1)
	result_amount = 3

/datum/chemical_reaction/tequilla_sunrise
	name = "Tequilla Sunrise"
	result = /datum/reagent/ethanol/tequilla_sunrise
	required_reagents = list(/datum/reagent/ethanol/tequilla = 2, /datum/reagent/drink/juice/orange = 1)
	result_amount = 3

/datum/chemical_reaction/plasma_special
	name = "Toxins Special"
	result = /datum/reagent/ethanol/toxins_special
	required_reagents = list(/datum/reagent/ethanol/rum = 2, /datum/reagent/ethanol/vermouth = 2, /datum/reagent/toxin/plasma = 2)
	result_amount = 6

/datum/chemical_reaction/beepsky_smash
	name = "Beepksy Smash"
	result = /datum/reagent/ethanol/beepsky_smash
	required_reagents = list(/datum/reagent/drink/juice/lime = 1, /datum/reagent/ethanol/whiskey = 1, /datum/reagent/iron = 1)
	result_amount = 2

/datum/chemical_reaction/doctor_delight
	name = "The Doctor's Delight"
	result = /datum/reagent/drink/doctor_delight
	required_reagents = list(/datum/reagent/drink/juice/lime = 1, /datum/reagent/drink/juice/tomato = 1, /datum/reagent/drink/juice/orange = 1, /datum/reagent/drink/milk/cream = 2, /datum/reagent/tricordrazine = 1)
	result_amount = 6

/datum/chemical_reaction/irish_cream
	name = "Irish Cream"
	result = /datum/reagent/ethanol/irish_cream
	required_reagents = list(/datum/reagent/ethanol/whiskey = 2, /datum/reagent/drink/milk/cream = 1)
	result_amount = 3

/datum/chemical_reaction/manly_dorf
	name = "The Manly Dorf"
	result = /datum/reagent/ethanol/manly_dorf
	required_reagents = list (/datum/reagent/ethanol/beer = 1, /datum/reagent/ethanol/ale = 2)
	result_amount = 3

/datum/chemical_reaction/hooch
	name = "Hooch"
	result = /datum/reagent/ethanol/hooch
	required_reagents = list (/datum/reagent/sugar = 1, /datum/reagent/ethanol = 2, /datum/reagent/fuel = 1)
	result_amount = 3

/datum/chemical_reaction/irish_coffee
	name = "Irish Coffee"
	result = /datum/reagent/ethanol/coffee/irishcoffee
	required_reagents = list(/datum/reagent/ethanol/irish_cream = 1, /datum/reagent/caffeine/coffee = 1)
	result_amount = 2

/datum/chemical_reaction/b52
	name = "B-52"
	result = /datum/reagent/ethanol/coffee/b52
	required_reagents = list(/datum/reagent/ethanol/irish_cream = 1, /datum/reagent/ethanol/kahlua = 1, /datum/reagent/ethanol/cognac = 1)
	result_amount = 3

/datum/chemical_reaction/atomicbomb
	name = "Atomic Bomb"
	result = /datum/reagent/ethanol/atomicbomb
	required_reagents = list(/datum/reagent/ethanol/coffee/b52 = 10, /datum/reagent/uranium = 1)
	result_amount = 10

/datum/chemical_reaction/margarita
	name = "Margarita"
	result = /datum/reagent/ethanol/margarita
	required_reagents = list(/datum/reagent/ethanol/tequilla = 2, /datum/reagent/drink/juice/lime = 1)
	result_amount = 3

/datum/chemical_reaction/longislandicedtea
	name = "Long Island Iced Tea"
	result = /datum/reagent/ethanol/longislandicedtea
	required_reagents = list(/datum/reagent/ethanol/vodka = 1, /datum/reagent/ethanol/gin = 1, /datum/reagent/ethanol/tequilla = 1, /datum/reagent/ethanol/cuba_libre = 3)
	result_amount = 6

/datum/chemical_reaction/threemileisland
	name = "Three Mile Island Iced Tea"
	result = /datum/reagent/ethanol/threemileisland
	required_reagents = list(/datum/reagent/ethanol/longislandicedtea = 10, /datum/reagent/uranium = 1)
	result_amount = 10

/datum/chemical_reaction/whiskeysoda
	name = "Whiskey Soda"
	result = /datum/reagent/ethanol/whiskeysoda
	required_reagents = list(/datum/reagent/ethanol/whiskey = 2, /datum/reagent/drink/sodawater = 1)
	result_amount = 3

/datum/chemical_reaction/black_russian
	name = "Black Russian"
	result = /datum/reagent/ethanol/black_russian
	required_reagents = list(/datum/reagent/ethanol/vodka = 2, /datum/reagent/ethanol/kahlua = 1)
	result_amount = 3

/datum/chemical_reaction/manhattan
	name = "Manhattan"
	result = /datum/reagent/ethanol/manhattan
	required_reagents = list(/datum/reagent/ethanol/whiskey = 2, /datum/reagent/ethanol/vermouth = 1)
	result_amount = 3

/datum/chemical_reaction/manhattan_proj
	name = "Manhattan Project"
	result = /datum/reagent/ethanol/manhattan_proj
	required_reagents = list(/datum/reagent/ethanol/manhattan = 10, /datum/reagent/uranium = 1)
	result_amount = 10

/datum/chemical_reaction/vodka_tonic
	name = "Vodka and Tonic"
	result = /datum/reagent/ethanol/vodkatonic
	required_reagents = list(/datum/reagent/ethanol/vodka = 2, /datum/reagent/drink/tonic = 1)
	result_amount = 3

/datum/chemical_reaction/gin_fizz
	name = "Gin Fizz"
	result = /datum/reagent/ethanol/ginfizz
	required_reagents = list(/datum/reagent/ethanol/gin = 1, /datum/reagent/drink/sodawater = 1, /datum/reagent/drink/juice/lime = 1)
	result_amount = 3

/datum/chemical_reaction/bahama_mama
	name = "Bahama mama"
	result = /datum/reagent/ethanol/bahama_mama
	required_reagents = list(/datum/reagent/ethanol/rum = 2, /datum/reagent/drink/juice/orange = 2, /datum/reagent/drink/juice/lime = 1, /datum/reagent/drink/ice = 1)
	result_amount = 6

/datum/chemical_reaction/singulo
	name = "Singulo"
	result = /datum/reagent/ethanol/singulo
	required_reagents = list(/datum/reagent/ethanol/vodka = 5, /datum/reagent/radium = 1, /datum/reagent/ethanol/wine = 5)
	result_amount = 10

/datum/chemical_reaction/alliescocktail
	name = "Allies Cocktail"
	result = /datum/reagent/ethanol/alliescocktail
	required_reagents = list(/datum/reagent/ethanol/vodkamartini = 1, /datum/reagent/ethanol/martini = 1)
	result_amount = 2

/datum/chemical_reaction/demonsblood
	name = "Demons Blood"
	result = /datum/reagent/ethanol/demonsblood
	required_reagents = list(/datum/reagent/ethanol/rum = 3, /datum/reagent/drink/spacemountainwind = 1, /datum/reagent/blood = 1, /datum/reagent/drink/dr_gibb = 1)
	result_amount = 6

/datum/chemical_reaction/booger
	name = "Booger"
	result = /datum/reagent/ethanol/booger
	required_reagents = list(/datum/reagent/drink/milk/cream = 2, /datum/reagent/drink/juice/banana = 1, /datum/reagent/ethanol/rum = 1, /datum/reagent/drink/juice/watermelon = 1)
	result_amount = 5

/datum/chemical_reaction/antifreeze
	name = "Anti-freeze"
	result = /datum/reagent/ethanol/antifreeze
	required_reagents = list(/datum/reagent/ethanol/vodka = 1, /datum/reagent/drink/milk/cream = 1, /datum/reagent/drink/ice = 1)
	result_amount = 3

/datum/chemical_reaction/barefoot
	name = "Barefoot"
	result = /datum/reagent/ethanol/barefoot
	required_reagents = list(/datum/reagent/drink/juice/berry = 1, /datum/reagent/drink/milk/cream = 1, /datum/reagent/ethanol/vermouth = 1)
	result_amount = 3

/datum/chemical_reaction/grapesoda
	name = "Grape Soda"
	result = /datum/reagent/drink/grapesoda
	required_reagents = list(/datum/reagent/drink/juice/grape = 2, /datum/reagent/drink/space_cola = 1)
	result_amount = 3

/datum/chemical_reaction/sbiten
	name = "Sbiten"
	result = /datum/reagent/ethanol/sbiten
	required_reagents = list(/datum/reagent/ethanol/mead = 10, /datum/reagent/capsaicin = 1)
	result_amount = 10

/datum/chemical_reaction/red_mead
	name = "Red Mead"
	result = /datum/reagent/ethanol/red_mead
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/ethanol/mead = 1)
	result_amount = 2

/datum/chemical_reaction/mead
	name = "Mead"
	result = /datum/reagent/ethanol/mead
	required_reagents = list(/datum/reagent/nutriment/honey = 1, /datum/reagent/water = 1)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 2

/datum/chemical_reaction/iced_beer
	name = "Iced Beer"
	result = /datum/reagent/ethanol/iced_beer
	required_reagents = list(/datum/reagent/ethanol/beer = 10, /datum/reagent/frostoil = 1)
	result_amount = 10

/datum/chemical_reaction/iced_beer2
	name = "Iced Beer"
	result = /datum/reagent/ethanol/iced_beer
	required_reagents = list(/datum/reagent/ethanol/beer = 5, /datum/reagent/drink/ice = 1)
	result_amount = 6

/datum/chemical_reaction/grog
	name = "Grog"
	result = /datum/reagent/ethanol/grog
	required_reagents = list(/datum/reagent/ethanol/rum = 1, /datum/reagent/water = 1)
	result_amount = 2

/datum/chemical_reaction/soy_latte
	name = "Soy Latte"
	result = /datum/reagent/caffeine/coffee/soy_latte
	required_reagents = list(/datum/reagent/caffeine/coffee = 1, /datum/reagent/drink/milk/soymilk = 1)
	result_amount = 2

/datum/chemical_reaction/cafe_latte
	name = "Cafe Latte"
	result = /datum/reagent/caffeine/coffee/cafe_latte
	required_reagents = list(/datum/reagent/caffeine/coffee = 1, /datum/reagent/drink/milk = 1)
	result_amount = 2

/datum/chemical_reaction/cappuccino
	name = "Cappuccino"
	result = /datum/reagent/caffeine/coffee/cappuccino
	required_reagents = list(/datum/reagent/caffeine/coffee = 2, /datum/reagent/drink/milk/cream = 1)
	result_amount = 3

/datum/chemical_reaction/acidspit
	name = "Acid Spit"
	result = /datum/reagent/ethanol/acid_spit
	required_reagents = list(/datum/reagent/acid = 1, /datum/reagent/ethanol/wine = 5)
	result_amount = 6

/datum/chemical_reaction/amasec
	name = "Amasec"
	result = /datum/reagent/ethanol/amasec
	required_reagents = list(/datum/reagent/iron = 1, /datum/reagent/ethanol/wine = 5, /datum/reagent/ethanol/vodka = 5)
	result_amount = 10

/datum/chemical_reaction/changelingsting
	name = "Changeling Sting"
	result = /datum/reagent/ethanol/changelingsting
	required_reagents = list(/datum/reagent/ethanol/screwdrivercocktail = 1, /datum/reagent/drink/juice/lime = 1, /datum/reagent/drink/juice/lemon = 1)
	result_amount = 3

/datum/chemical_reaction/aloe
	name = "Aloe"
	result = /datum/reagent/ethanol/aloe
	required_reagents = list(/datum/reagent/drink/milk/cream = 1, /datum/reagent/ethanol/whiskey = 1, /datum/reagent/drink/juice/watermelon = 1)
	result_amount = 3

/datum/chemical_reaction/andalusia
	name = "Andalusia"
	result = /datum/reagent/ethanol/andalusia
	required_reagents = list(/datum/reagent/ethanol/rum = 1, /datum/reagent/ethanol/whiskey = 1, /datum/reagent/drink/juice/lemon = 1)
	result_amount = 3

/datum/chemical_reaction/neurotoxin
	name = "Neurotoxin"
	result = /datum/reagent/ethanol/neurotoxin
	required_reagents = list(/datum/reagent/ethanol/gargle_blaster = 1, /datum/reagent/soporific = 1)
	result_amount = 2

/datum/chemical_reaction/snowwhite
	name = "Snow White"
	result = /datum/reagent/ethanol/snowwhite
	required_reagents = list(/datum/reagent/ethanol/beer = 1, /datum/reagent/drink/lemon_lime = 1)
	result_amount = 2

/datum/chemical_reaction/irishcarbomb
	name = "Irish Car Bomb"
	result = /datum/reagent/ethanol/irishcarbomb
	required_reagents = list(/datum/reagent/ethanol/ale = 1, /datum/reagent/ethanol/irish_cream = 1)
	result_amount = 2

/datum/chemical_reaction/syndicatebomb
	name = "Syndicate Bomb"
	result = /datum/reagent/ethanol/syndicatebomb
	required_reagents = list(/datum/reagent/ethanol/beer = 1, /datum/reagent/ethanol/whiskey_cola = 1)
	result_amount = 2

/datum/chemical_reaction/erikasurprise
	name = "Erika Surprise"
	result = /datum/reagent/ethanol/erikasurprise
	required_reagents = list(/datum/reagent/ethanol/ale = 2, /datum/reagent/drink/juice/lime = 1, /datum/reagent/ethanol/whiskey = 1, /datum/reagent/drink/juice/banana = 1, /datum/reagent/drink/ice = 1)
	result_amount = 6

/datum/chemical_reaction/devilskiss
	name = "Devils Kiss"
	result = /datum/reagent/ethanol/devilskiss
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/ethanol/kahlua = 1, /datum/reagent/ethanol/rum = 1)
	result_amount = 3

/datum/chemical_reaction/hippiesdelight
	name = "Hippies Delight"
	result = /datum/reagent/ethanol/hippies_delight
	required_reagents = list(/datum/reagent/psilocybin = 1, /datum/reagent/ethanol/gargle_blaster = 1)
	result_amount = 2

/datum/chemical_reaction/bananahonk
	name = "Banana Honk"
	result = /datum/reagent/ethanol/bananahonk
	required_reagents = list(/datum/reagent/drink/juice/banana = 1, /datum/reagent/drink/milk/cream = 1, /datum/reagent/sugar = 1)
	result_amount = 3

/datum/chemical_reaction/silencer
	name = "Silencer"
	result = /datum/reagent/ethanol/silencer
	required_reagents = list(/datum/reagent/drink/nothing = 1, /datum/reagent/drink/milk/cream = 1, /datum/reagent/sugar = 1)
	result_amount = 3

/datum/chemical_reaction/driestmartini
	name = "Driest Martini"
	result = /datum/reagent/ethanol/driestmartini
	required_reagents = list(/datum/reagent/drink/nothing = 1, /datum/reagent/ethanol/gin = 1)
	result_amount = 2

/datum/chemical_reaction/lemonade
	name = "Lemonade"
	result = /datum/reagent/drink/lemonade
	required_reagents = list(/datum/reagent/drink/juice/lemon = 1, /datum/reagent/sugar = 1, /datum/reagent/water = 1)
	result_amount = 3

/datum/chemical_reaction/kiraspecial
	name = "Kira Special"
	result = /datum/reagent/drink/kiraspecial
	required_reagents = list(/datum/reagent/drink/juice/orange = 1, /datum/reagent/drink/juice/lime = 1, /datum/reagent/drink/sodawater = 1)
	result_amount = 3

/datum/chemical_reaction/brownstar
	name = "Brown Star"
	result = /datum/reagent/drink/brownstar
	required_reagents = list(/datum/reagent/drink/juice/orange = 2, /datum/reagent/drink/space_cola = 1)
	result_amount = 3

/datum/chemical_reaction/milkshake
	name = "Milkshake"
	result = /datum/reagent/drink/milkshake
	required_reagents = list(/datum/reagent/drink/milk/cream = 1, /datum/reagent/drink/ice = 2, /datum/reagent/drink/milk = 2)
	result_amount = 5

/datum/chemical_reaction/rewriter
	name = "Rewriter"
	result = /datum/reagent/drink/rewriter
	required_reagents = list(/datum/reagent/drink/spacemountainwind = 1, /datum/reagent/caffeine/coffee = 1)
	result_amount = 2

/datum/chemical_reaction/suidream
	name = "Sui Dream"
	result = /datum/reagent/ethanol/suidream
	required_reagents = list(/datum/reagent/drink/space_up = 1, /datum/reagent/ethanol/bluecuracao = 1, /datum/reagent/ethanol/melonliquor = 1)
	result_amount = 3

/datum/chemical_reaction/rum
	name = "Rum"
	result = /datum/reagent/ethanol/rum
	required_reagents = list(/datum/reagent/sugar = 1, /datum/reagent/water = 1)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 2

/datum/chemical_reaction/ships_surgeon
	name = "Ship's Surgeon"
	result = /datum/reagent/ethanol/ships_surgeon
	required_reagents = list(/datum/reagent/ethanol/rum = 1, /datum/reagent/drink/dr_gibb = 2, /datum/reagent/drink/ice = 1)
	result_amount = 4

/datum/chemical_reaction/luminol
	name = "Luminol"
	result = /datum/reagent/luminol
	required_reagents = list(/datum/reagent/hydrazine = 2, /datum/reagent/carbon = 2, /datum/reagent/ammonia = 2)
	result_amount = 6

/datum/chemical_reaction/plasmygen
	name = "Plasmygen"
	result = /datum/reagent/toxin/plasma/oxygen
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/toxin/plasma = 1)
	result_amount = 2

/datum/chemical_reaction/deuterium
	name = "Deuterium"
	result = null
	required_reagents = list(/datum/reagent/water = 10)
	catalysts = list(/datum/reagent/toxin/plasma/oxygen = 5)
	result_amount = 1

/datum/chemical_reaction/deuterium/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	if(istype(T)) new /obj/item/stack/material/deuterium(T, created_volume)
	return

/datum/chemical_reaction/antidexafen
	name = "Antidexafen"
	result = /datum/reagent/antidexafen
	required_reagents = list(/datum/reagent/painkiller/paracetamol = 1, /datum/reagent/carbon = 1)
	result_amount = 2

/datum/chemical_reaction/nanoblood
	name = "Nanoblood"
	result = /datum/reagent/nanoblood
	required_reagents = list(/datum/reagent/dexalinp = 1, /datum/reagent/iron = 1, /datum/reagent/blood = 1)
	result_amount = 3

/datum/chemical_reaction/glintwine
	name = "Glintwine"
	result = /datum/reagent/ethanol/glintwine
	required_reagents = list(/datum/reagent/ethanol/wine = 3, /datum/reagent/sugar = 2, /datum/reagent/drink/juice/orange = 2)
	result_amount = 5

/datum/chemical_reaction/corpserevive
	name = "Corpse Reviver"
	result = /datum/reagent/ethanol/corpserevive
	required_reagents = list(/datum/reagent/ethanol/gin = 3, /datum/reagent/ethanol/wine = 3, /datum/reagent/drink/juice/orange = 2, /datum/reagent/drink/juice/lemon = 2)
	result_amount = 9

/datum/chemical_reaction/bdaiquiri
	name = "Banana daiquiri"
	result = /datum/reagent/ethanol/bdaiquiri
	required_reagents = list(/datum/reagent/ethanol/rum = 2, /datum/reagent/drink/juice/banana = 3, /datum/reagent/drink/juice/lime = 1, /datum/reagent/drink/ice = 2)
	result_amount = 8

/datum/chemical_reaction/afternoon
	name = "Death in the afternoon"
	result = /datum/reagent/ethanol/afternoon
	required_reagents = list(/datum/reagent/ethanol/wine/premium = 4, /datum/reagent/ethanol/absinthe = 2)
	result_amount = 6

/datum/chemical_reaction/chacha
	name = "Сhacha"
	result = /datum/reagent/ethanol/chacha
	required_reagents = list(/datum/reagent/ethanol/vodka = 3, /datum/reagent/drink/juice/grape = 2)
	result_amount = 5

/datum/chemical_reaction/sexonthebeach
	name = "Sex on the Beach"
	result = /datum/reagent/ethanol/sexonthebeach
	required_reagents = list(/datum/reagent/ethanol/vodka = 2, /datum/reagent/drink/juice/lemon = 2, /datum/reagent/ethanol/melonliquor = 1)
	result_amount = 5

/datum/chemical_reaction/daddysindahouse
	name = "Daddy's in da House"
	result = /datum/reagent/ethanol/daddysindahouse
	required_reagents = list(/datum/reagent/ethanol/wine = 2, /datum/reagent/ethanol/absinthe = 1, /datum/reagent/ethanol/herbal = 1, /datum/reagent/drink/lemon_lime = 2)
	result_amount = 6

/datum/chemical_reaction/metroidscore
	name = "Metroid's Core"
	result = /datum/reagent/ethanol/metroidscore
	required_reagents = list(/datum/reagent/ethanol/absinthe = 1, /datum/reagent/drink/grenadine = 1, /datum/reagent/drink/lemon_lime = 2)
	result_amount = 4

/datum/chemical_reaction/commodore64
	name = "Commodore 64"
	result = /datum/reagent/ethanol/commodore64
	required_reagents = list(/datum/reagent/ethanol/whiskey = 2, /datum/reagent/drink/juice/lemon = 1, /datum/reagent/drink/juice/orange = 1, /datum/reagent/drink/grenadine = 1)
	result_amount = 5

/datum/chemical_reaction/georgerrmartini
	name = "George R.R. Martini"
	result = /datum/reagent/ethanol/georgerrmartini
	required_reagents = list(/datum/reagent/blood = 2, /datum/reagent/sodiumchloride = 1, /datum/reagent/ethanol/absinthe = 2)
	result_amount = 5

/datum/chemical_reaction/siegbrau
	name = "Siegbrau"
	result = /datum/reagent/ethanol/siegbrau
	required_reagents = list(/datum/reagent/tricordrazine = 2, /datum/reagent/ethanol/manly_dorf = 2, /datum/reagent/ethanol/beer/dark = 1)
	result_amount = 5

/datum/chemical_reaction/mojito
	name = "Mojito"
	result = /datum/reagent/ethanol/mojito
	required_reagents = list(/datum/reagent/ethanol/rum = 1, /datum/reagent/drink/juice/lime = 1, /datum/reagent/drink/sodawater = 2, /datum/reagent/sugar = 1)
	result_amount = 5

/datum/chemical_reaction/bacardi
	name = "Bacardi"
	result = /datum/reagent/ethanol/bacardi
	required_reagents = list(/datum/reagent/ethanol/rum = 2, /datum/reagent/drink/juice/lime = 1, /datum/reagent/drink/grenadine  = 1)
	result_amount = 5

/datum/chemical_reaction/espressomartini
	name = "Espresso Martini"
	result = /datum/reagent/ethanol/coffee/espressomartini
	required_reagents = list(/datum/reagent/ethanol/black_russian = 3, /datum/reagent/caffeine/coffee = 1, /datum/reagent/sugar = 1)
	result_amount = 5

/datum/chemical_reaction/shroombeer
	name = "shroom berr"
	result = /datum/reagent/ethanol/shroombeer
	required_reagents = list(/datum/reagent/psilocybin = 1, /datum/reagent/ethanol/beer/dark = 2, /datum/reagent/fuel = 1, /datum/reagent/blackpepper = 1)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 5

/datum/chemical_reaction/fullbiotickick
	name = "Full Biotic Kick"
	result = /datum/reagent/ethanol/fullbiotickick
	required_reagents = list(/datum/reagent/ethanol/whiskey = 2, /datum/reagent/ethanol/rum = 1, /datum/reagent/ethanol/bluecuracao = 1, /datum/reagent/drink/dr_gibb = 1)
	result_amount = 5

/datum/chemical_reaction/vesper
	name = "Vesper"
	result = /datum/reagent/ethanol/vesper
	required_reagents = list(/datum/reagent/ethanol/gin = 3, /datum/reagent/ethanol/vodka = 1, /datum/reagent/ethanol/wine/white = 1)
	result_amount = 5

/datum/chemical_reaction/witcher
	name = "Witcher"
	result = /datum/reagent/ethanol/witcher
	required_reagents = list(/datum/reagent/ethanol/vodka = 1,/datum/reagent/ethanol/wine/white = 2,/datum/reagent/ethanol/cider/apple = 3)
	result_amount = 6

/datum/chemical_reaction/witcherwolf
	name = "School of the Wolf"
	result = /datum/reagent/ethanol/witcher/wolf
	required_reagents = list(/datum/reagent/ethanol/witcher = 3,/datum/reagent/ethanol/vermouth = 1,/datum/reagent/ethanol/herbal = 1)
	result_amount = 5

/datum/chemical_reaction/witchercat
	name = "School of the Cat"
	result = /datum/reagent/ethanol/witcher/cat
	required_reagents = list(/datum/reagent/ethanol/witcher = 3,/datum/reagent/drink/grenadine = 1,/datum/reagent/ethanol/cider/apple = 1)
	result_amount = 5

/datum/chemical_reaction/witcherbear
	name = "School of the Bear"
	result = /datum/reagent/ethanol/witcher/bear
	required_reagents = list(/datum/reagent/ethanol/witcher = 3,/datum/reagent/ethanol/black_russian = 2)
	result_amount = 5

/datum/chemical_reaction/witchergriffin
	name = "School of the Griffin"
	result = /datum/reagent/ethanol/witcher/griffin
	required_reagents = list(/datum/reagent/ethanol/witcher = 3,/datum/reagent/ethanol/bluecuracao = 1,/datum/reagent/ethanol/wine/sparkling = 1)
	result_amount = 5

/datum/chemical_reaction/immunobooster
	name = "Immunobooster"
	result = /datum/reagent/immunobooster
	required_reagents = list(/datum/reagent/cryptobiolin = 3, /datum/reagent/dylovene = 1)
	result_amount = 2

/datum/chemical_reaction/vecuronium_bromide
	name = "Vecuronium Bromide"
	result = /datum/reagent/vecuronium_bromide
	required_reagents = list(/datum/reagent/ethanol = 1, /datum/reagent/mercury = 2, /datum/reagent/luminol = 2)
	result_amount = 1

/datum/chemical_reaction/kvass
	name = "Kvass"
	result = /datum/reagent/ethanol/kvass
	required_reagents = list(/datum/reagent/ethanol/beer = 1, /datum/reagent/sugar = 1)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 2

/datum/chemical_reaction/quas
	name = "Quas"
	result = /datum/reagent/ethanol/quas
	required_reagents = list(/datum/reagent/ethanol/kvass = 3, /datum/reagent/frostoil = 1, /datum/reagent/drink/ice = 1)
	result_amount = 3
