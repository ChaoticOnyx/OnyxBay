/obj/item/organ/internal/heart/gland/viral
	abductor_hint = "contamination incubator. The abductee becomes a carrier of a random advanced disease."
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1
	icon_state = "viral"
	mind_control_uses = 1
	mind_control_duration = 1800
	var/list/virus_whitelist_species = list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_SKRELL, SPECIES_TAJARA)

/obj/item/organ/internal/heart/gland/viral/activate()
	to_chat(owner, SPAN_WARNING("You feel sick."))
	var/datum/disease2/disease/D = new /datum/disease2/disease()
	D.makerandom(rand(1,4))
	D.infectionchance = rand(40,80)
	D.affected_species = list(owner.species.name)
	for(var/i in 1 to rand(1,2))
		D.affected_species |= pick(virus_whitelist_species)
	if(owner.species.primitive_form)
		D.affected_species |= owner.species.primitive_form
	if(owner.species.greater_form)
		D.affected_species |= owner.species.greater_form
	infect_virus2(owner,D,1)
