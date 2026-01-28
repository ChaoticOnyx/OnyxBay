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
	required_reagents = list(/datum/reagent/water = 3, /datum/reagent/silicon = 1, /datum/reagent/acetone = 1)
	result_amount = 3
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
	result_amount = 2

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
	required_reagents = list(/datum/reagent/salt = 1, /datum/reagent/potassium = 1)
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
	required_reagents = list(/datum/reagent/salt = 1, /datum/reagent/ethanol = 1, /datum/reagent/radium = 1)
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
	required_reagents = list(/datum/reagent/space_cleaner/dry = 1, /datum/reagent/water = 50)
	result_amount = 50

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
	required_reagents = list(/datum/reagent/nutriment/oil = 4, /datum/reagent/acid = 1)
	result_amount = 1

/datum/chemical_reaction/cornglycerol
	name = "Corn Glycerol"
	result = /datum/reagent/glycerol
	required_reagents = list(/datum/reagent/nutriment/oil/corn = 3, /datum/reagent/acid = 1)
	result_amount = 1

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	result = /datum/reagent/salt
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

/datum/chemical_reaction/teleglobin
	name = "Teleglobin"
	result = /datum/reagent/teleglobin
	required_reagents = list(/datum/reagent/nanoblood = 3, /datum/reagent/toxin/plasma = 2, /datum/reagent/chloralhydrate = 1)
	result_amount = 2

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

/datum/chemical_reaction/emezoline
	name = "Emezoline"
	result = /datum/reagent/emezoline
	required_reagents = list(/datum/reagent/lithium = 1, /datum/reagent/potassium = 1, /datum/reagent/dylovene = 1)
	result_amount = 1
