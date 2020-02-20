/datum/absorbed_dna
	var/name
	var/datum/dna/dna
	var/speciesName
	var/list/languages
//	var/flavor_text
	var/list/modifiers

/datum/absorbed_dna/New(newName, newDNA, newSpecies, newLanguages, newModifiers)
	..()
	name = newName
	dna = newDNA
	speciesName = newSpecies
	languages = newLanguages
//	flavor_text = newFlavor
	modifiers = newModifiers
