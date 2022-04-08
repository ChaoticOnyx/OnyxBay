/datum/ictus

/datum/ictus/New()
	start()
	if(prob(65))
		command_announcement.Announce("Suspicious biological activity was noticed at the station. The medical crew should immediately prepare for the fight against the pathogen. Infected crew members must not leave the station under any circumstances.")
	..()

/datum/ictus/proc/start()
	return

/datum/event/virus_minor/start()
	var/next_outbreak = pick(/datum/ictus/retrovirus, /datum/ictus/cold9,
							 /datum/ictus/flu, /datum/ictus/vulnerability,
							 /datum/ictus/xeno, /datum/ictus/hisstarvation,
							 /datum/ictus/musclerace, /datum/ictus/space_migraine)
	new next_outbreak

/datum/event/virus_major/start()
	var/next_outbreak = pick(/datum/ictus/gbs, /datum/ictus/fake_gbs, /datum/ictus/nuclear, /datum/ictus/fluspanish, /datum/ictus/emp)
	new next_outbreak

/datum/admins/proc/ictus()
	set category = "Admin"
	set name = "Spawn Epidemic"
	if(!check_rights(R_ADMIN))
		return

	var/ictus = input("Select virus:", "Infection") as null|anything in subtypesof(/datum/ictus)
	if(!ictus)
		return
	new	ictus

	message_admins("[key_name_admin(src)] released [ictus].", 1)

/datum/disease2/disease/space_migraine
	infectionchance = 80
	spreadtype = "Airborne"
	stage = 2
	max_stage = 3

/datum/disease2/disease/space_migraine/New()
	. = ..()
	antigen = list(pick(ALL_ANTIGENS))
	var/datum/disease2/effect/headache/E1 = new()
	E1.stage = 1
	E1.chance = 90
	effects += E1
	var/datum/disease2/effect/disorientation/E2 = new()
	E2.stage = 2
	E2.chance = 75
	effects += E2
	var/datum/disease2/effect/confusion/E3 = new()
	E3.stage = 3
	E3.chance = 35
	effects += E3

/datum/ictus/space_migraine/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return

	var/datum/disease2/disease/space_migraine/D = new
	var/mob/living/carbon/human/candidate = pick_n_take(candidates)

	if(candidate.species.name in D.affected_species)
		infect_virus2(candidate, D, 1)

/datum/disease2/disease/retrovirus
	infectionchance = 90
	speed = 10
	spreadtype = "Airborne"
	max_stage = 4
	affected_species = list(SPECIES_HUMAN)

/datum/disease2/disease/retrovirus/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	var/datum/disease2/effect/sneeze/E1 = new()
	E1.stage = 1
	E1.chance = 75
	effects += E1
	var/datum/disease2/effect/cough/E2 = new()
	E2.stage = 2
	E2.chance = 65
	effects += E2
	var/datum/disease2/effect/dnaspread/E3 = new()
	E3.stage = 3
	E3.chance = 35
	effects += E3
	var/datum/disease2/effect/mutation/E4 = new()
	E4.stage = 4
	E4.chance = 75
	effects += E4

/datum/ictus/retrovirus/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return

	var/datum/disease2/disease/retrovirus/D = new
	var/mob/living/carbon/human/candidate = pick_n_take(candidates)

	for(var/datum/disease2/effect/dnaspread/E in D.effects)
		E.data["name"] = candidate.real_name
		E.data["UI"] = candidate.dna.UI.Copy()
		E.data["SE"] = candidate.dna.SE.Copy()

	if(candidate.species.name in D.affected_species)
		infect_virus2(candidate,D,1)



// ####################################################################
// ################################GBS#################################
// ####################################################################

/datum/disease2/disease/gbs
	infectionchance = 45
	speed = 4
	spreadtype = "Contact"
	max_stage = 4
	affected_species = list(SPECIES_HUMAN, SPECIES_TAJARA, SPECIES_SKRELL, SPECIES_DIONA, SPECIES_UNATHI)

/datum/disease2/disease/gbs/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	var/datum/disease2/effect/cough/E1 = new()
	E1.stage = 1
	E1.chance = 35
	effects += E1
	var/datum/disease2/effect/sneeze/E2 = new()
	E2.stage = 2
	E2.chance = 50
	effects += E2
	var/datum/disease2/effect/hungry/E3 = new()
	E3.stage = 3
	E3.chance = 35
	effects += E3
	var/datum/disease2/effect/gbs/E4 = new()
	E4.stage = 4
	E4.chance = 50
	effects += E4

/datum/ictus/gbs/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return

	var/datum/disease2/disease/gbs/D = new
	var/mob/living/carbon/human/candidate = pick_n_take(candidates)

	if(candidate.species.name in D.affected_species)
		infect_virus2(candidate,D,1)


// ####################################################################
// ################################FAKE GBS############################
// ####################################################################

/datum/disease2/disease/fake_gbs
	infectionchance = 45
	speed = 4
	spreadtype = "Contact"
	max_stage = 4
	affected_species = list(SPECIES_HUMAN, SPECIES_TAJARA, SPECIES_SKRELL, SPECIES_DIONA, SPECIES_UNATHI)

/datum/disease2/disease/fake_gbs/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	var/datum/disease2/effect/cough/E1 = new()
	E1.stage = 1
	E1.chance = 35
	effects += E1
	var/datum/disease2/effect/sneeze/E2 = new()
	E2.stage = 2
	E2.chance = 50
	effects += E2
	var/datum/disease2/effect/hungry/E3 = new()
	E3.stage = 3
	E3.chance = 35
	effects += E3
	var/datum/disease2/effect/fake_gbs/E4 = new()
	E4.stage = 4
	E4.chance = 50
	effects += E4

/datum/ictus/fake_gbs/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return

	var/datum/disease2/disease/fake_gbs/D = new
	var/mob/living/carbon/human/candidate = pick_n_take(candidates)

	if(candidate.species.name in D.affected_species)
		infect_virus2(candidate,D,1)

// ####################################################################
// ################################COLD NINE###########################
// ####################################################################

/datum/disease2/disease/cold9
	infectionchance = 75
	speed = 2
	spreadtype = "Contact"
	max_stage = 3
	affected_species = list(SPECIES_HUMAN, SPECIES_TAJARA)

/datum/disease2/disease/cold9/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	var/datum/disease2/effect/sneeze/E1 = new()
	E1.stage = 1
	E1.chance = 75
	effects += E1
	var/datum/disease2/effect/gunck/E2 = new()
	E2.stage = 2
	E2.chance = 25
	effects += E2
	var/datum/disease2/effect/cold9/E3 = new()
	E3.stage = 3
	E3.chance = 50
	effects += E3

/datum/ictus/cold9/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return

	var/datum/disease2/disease/cold9/D = new
	var/mob/living/carbon/human/candidate = pick_n_take(candidates)

	if(candidate.species.name in D.affected_species)
		infect_virus2(candidate,D,1)

// ####################################################################
// #############################NUCLEAR FEVER##########################
// ####################################################################

/datum/disease2/disease/nuclear
	infectionchance = 0
	speed = 1
	spreadtype = "Contact"
	max_stage = 3
	affected_species = list(SPECIES_HUMAN)

/datum/disease2/disease/nuclear/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	var/datum/disease2/effect/nuclear/E1 = new()
	E1.stage = 1
	E1.chance = 50
	effects += E1
	var/datum/disease2/effect/nuclear_exacerbation/E2 = new()
	E2.stage = 2
	E2.chance = 50
	effects += E2
	var/datum/disease2/effect/nuclear_escalation/E3 = new()
	E3.stage = 3
	E3.chance = 50
	effects += E3

/datum/ictus/nuclear/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return

	var/datum/disease2/disease/nuclear/D = new
	var/mob/living/carbon/human/candidate = pick_n_take(candidates)

	if(candidate.species.name in D.affected_species)
		infect_virus2(candidate,D,1)

// ####################################################################
// ################################FLU#################################
// ####################################################################

/datum/disease2/disease/flu
	infectionchance = 60
	speed = 2
	spreadtype = "Airborne"
	max_stage = 4
	affected_species = list(SPECIES_HUMAN)

/datum/disease2/disease/flu/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	var/datum/disease2/effect/sneeze/E1 = new()
	E1.stage = 1
	E1.chance = 50
	effects += E1
	var/datum/disease2/effect/cough/E2 = new()
	E2.stage = 2
	E2.chance = 65
	effects += E2
	var/datum/disease2/effect/stomach/E3 = new()
	E3.stage = 3
	E3.chance = 35
	effects += E3
	var/datum/disease2/effect/flu/E4 = new()
	E4.stage = 4
	E4.chance = 75
	effects += E4

/datum/ictus/flu/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return

	var/datum/disease2/disease/flu/D = new

	var/victims = min(rand(1,3), candidates.len)
	while(victims)
		infect_virus2(pick_n_take(candidates),D,1)
		victims--

// ####################################################################
// #############################SPANISH FLU############################
// ####################################################################

/datum/disease2/disease/fluspanish
	infectionchance = 70
	speed = 1
	spreadtype = "Airborne"
	max_stage = 4
	affected_species = list(SPECIES_HUMAN)

/datum/disease2/disease/fluspanish/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	var/datum/disease2/effect/sneeze/E1 = new()
	E1.stage = 1
	E1.chance = 50
	effects += E1
	var/datum/disease2/effect/cough/E2 = new()
	E2.stage = 2
	E2.chance = 65
	effects += E2
	var/datum/disease2/effect/stomach/E3 = new()
	E3.stage = 3
	E3.chance = 30
	effects += E3
	var/datum/disease2/effect/fluspanish/E4 = new()
	E4.stage = 4
	E4.chance = 50
	effects += E4

/datum/ictus/fluspanish/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return

	var/datum/disease2/disease/nuclear/D = new
	var/mob/living/carbon/human/candidate = pick_n_take(candidates)

	if(candidate.species.name in D.affected_species)
		infect_virus2(candidate,D,1)

// ####################################################################
// ############################ARTERIVIRUS#############################
// ####################################################################

/datum/disease2/disease/vulnerability
	infectionchance = 75
	speed = 2
	spreadtype = "Contact"
	max_stage = 3
	affected_species = list(SPECIES_HUMAN, SPECIES_SKRELL)

/datum/disease2/disease/vulnerability/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	var/datum/disease2/effect/vulnerability/E1 = new()
	E1.stage = 1
	E1.chance = 75
	effects += E1
	var/datum/disease2/effect/headache/E2 = new()
	E2.stage = 2
	E2.chance = 25
	effects += E2
	var/datum/disease2/effect/bones/E3 = new()
	E3.stage = 3
	E3.chance = 50
	effects += E3

/datum/ictus/vulnerability/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return

	var/datum/disease2/disease/vulnerability/D = new
	var/mob/living/carbon/human/candidate = pick_n_take(candidates)

	if(candidate.species.name in D.affected_species)
		infect_virus2(candidate,D,1)

// ####################################################################
// ################################EMP#################################
// ####################################################################

/datum/disease2/disease/emp
	infectionchance = 25
	speed = 1
	spreadtype = "Contact"
	max_stage = 4
	affected_species = list(SPECIES_HUMAN)

/datum/disease2/disease/emp/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	var/datum/disease2/effect/headache/E1 = new()
	E1.stage = 1
	E1.chance = 50
	effects += E1
	var/datum/disease2/effect/shakey/E2 = new()
	E2.stage = 2
	E2.chance = 50
	effects += E2
	var/datum/disease2/effect/emp/E3 = new()
	E3.stage = 3
	E3.chance = 50
	effects += E3
	var/datum/disease2/effect/blind/E4 = new()
	E4.stage = 4
	E4.chance = 50
	effects += E4

/datum/ictus/emp/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return

	var/datum/disease2/disease/emp/D = new
	var/mob/living/carbon/human/candidate = pick_n_take(candidates)

	if(candidate.species.name in D.affected_species)
		infect_virus2(candidate,D,1)

// ####################################################################
// ###############################XENO#################################
// ####################################################################

/datum/disease2/disease/xeno
	infectionchance = 65
	speed = 1
	spreadtype = "Airborne"
	max_stage = 4
	affected_species = list(SPECIES_TAJARA, SPECIES_SKRELL, SPECIES_DIONA, SPECIES_UNATHI)

/datum/disease2/disease/xeno/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	var/datum/disease2/effect/cough/E1 = new()
	E1.stage = 1
	E1.chance = 50
	effects += E1
	var/datum/disease2/effect/confusion/E2 = new()
	E2.stage = 2
	E2.chance = 50
	effects += E2
	var/datum/disease2/effect/mind/E3 = new()
	E3.stage = 3
	E3.chance = 25
	effects += E3
	var/datum/disease2/effect/deaf/E4 = new()
	E4.stage = 4
	E4.chance = 100
	effects += E4

/datum/ictus/xeno/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return

	var/datum/disease2/disease/xeno/D = new
	var/mob/living/carbon/human/candidate = pick_n_take(candidates)

	if(candidate.species.name in D.affected_species)
		infect_virus2(candidate,D,1)

// ####################################################################
// #############################HISSVIRUS##############################
// ####################################################################

/datum/disease2/disease/hisstarvation
	infectionchance = 50
	speed = 1
	spreadtype = "Airborne"
	max_stage = 3
	affected_species = list(SPECIES_UNATHI)

/datum/disease2/disease/hisstarvation/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	var/datum/disease2/effect/cough/E1 = new()
	E1.stage = 1
	E1.chance = 50
	effects += E1
	var/datum/disease2/effect/hisstarvation/E2 = new()
	E2.stage = 2
	E2.chance = 35
	effects += E2
	var/datum/disease2/effect/invisible/E3 = new()
	E3.stage = 3
	E3.chance = 50
	effects += E3

/datum/ictus/hisstarvation/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return

	var/datum/disease2/disease/hisstarvation/D = new
	var/mob/living/carbon/human/candidate = pick_n_take(candidates)

	if(candidate.species.name in D.affected_species)
		infect_virus2(candidate,D,1)

// ####################################################################
// ###########################PLUSH RACER##############################
// ####################################################################

/datum/disease2/disease/musclerace
	infectionchance = 35
	speed = 1
	spreadtype = "Airborne"
	max_stage = 3
	affected_species = list(SPECIES_TAJARA)

/datum/disease2/disease/musclerace/New()
	..()
	antigen = list(pick(ALL_ANTIGENS))
	var/datum/disease2/effect/twitch/E1 = new()
	E1.stage = 1
	E1.chance = 50
	effects += E1
	var/datum/disease2/effect/musclerace/E2 = new()
	E2.stage = 2
	E2.chance = 35
	effects += E2
	var/datum/disease2/effect/invisible/E3 = new()
	E3.stage = 3
	E3.chance = 50
	effects += E3

/datum/ictus/musclerace/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return

	var/datum/disease2/disease/musclerace/D = new
	var/mob/living/carbon/human/candidate = pick_n_take(candidates)

	if(candidate.species.name in D.affected_species)
		infect_virus2(candidate,D,1)
