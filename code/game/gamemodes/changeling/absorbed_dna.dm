/datum/absorbed_dna
	var/name
	var/datum/dna/dna
	var/speciesName
	var/list/languages
	var/flavor_texts
	var/list/modifiers

/datum/absorbed_dna/New(newName, newDNA, newSpecies, newLanguages, newModifiers, newFlavorTexts)
	..()
	name = newName
	dna = newDNA
	speciesName = newSpecies
	languages = newLanguages
	flavor_texts = newFlavorTexts
	modifiers = newModifiers
