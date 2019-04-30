/datum/absorbed_dna
	var/name
	var/datum/dna/dna
	var/speciesName
	var/list/languages
//	var/flavor_text
	var/list/modifiers

/datum/absorbed_dna/New(var/newName, var/newDNA, var/newSpecies, var/newLanguages, var/newModifiers)
	..()
	name = newName
	dna = newDNA
	speciesName = newSpecies
	languages = newLanguages
//	flavor_text = newFlavor
	modifiers = newModifiers
