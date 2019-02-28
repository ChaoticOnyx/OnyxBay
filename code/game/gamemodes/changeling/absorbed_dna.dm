/datum/absorbed_dna
	var/name
	var/datum/dna/dna
	var/speciesName
	var/list/languages
//	var/flavor_text
	var/traits = list()

/datum/absorbed_dna/New(var/newName, var/newDNA, var/newSpecies, var/newLanguages, var/newTraits)
	..()
	name = newName
	dna = newDNA
	speciesName = newSpecies
	languages = newLanguages
//	flavor_text = newFlavor
	traits = newTraits
