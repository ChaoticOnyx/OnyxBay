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

/datum/disease2/effect/dnaspread
	name = "Space Retrovirus Syndrome"
	stage = 3
	badness = VIRUS_EXOTIC
	var/list/original_dna = list()
	var/transformed = 0
	var/host = 0

	generate(c_data)
		if(c_data)
			data = c_data

	activate(var/mob/living/carbon/human/mob,var/multiplier)
		if(!src.transformed && !src.host)
			if ((!data["name"]) || (!data["UI"]) || (!data["SE"]))
				data["name"] = mob.real_name
				data["UI"] = mob.dna.UI.Copy()
				data["SE"] = mob.dna.SE.Copy()
				host = 1
				return

			src.original_dna["name"] = mob.real_name
			src.original_dna["UI"] = mob.dna.UI.Copy()
			src.original_dna["SE"] = mob.dna.SE.Copy()

			to_chat(mob, "<span class='danger'>You don't feel like yourself..</span>")
			var/list/newUI=data["UI"]
			var/list/newSE=data["SE"]
			mob.UpdateAppearance(newUI.Copy())
			mob.dna.SE = newSE.Copy()
			mob.dna.UpdateSE()
			mob.real_name = data["name"]
			mob.flavor_text = ""
			domutcheck(mob)
			src.transformed = 1

	deactivate(var/mob/living/carbon/human/mob,var/multiplier)
		if ((!original_dna["name"]) && (!original_dna["UI"]) && (!original_dna["SE"]))
			var/list/newUI=original_dna["UI"]
			var/list/newSE=original_dna["SE"]
			mob.UpdateAppearance(newUI.Copy())
			mob.dna.SE = newSE.Copy()
			mob.dna.UpdateSE()
			mob.real_name = original_dna["name"]

			to_chat(mob, "<span class='notice'>You feel more like yourself.</span>")

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

/datum/disease2/effect/gbs
	name = "Gravitokinetic Bipotential SADS+"
	stage = 4
	badness = VIRUS_ENGINEERED

	activate(var/mob/living/carbon/human/mob)
		to_chat(mob, "<span class='danger'>Your body feels as if it's trying to rip itself open...</span>")
		mob.weakened += 5
		if(prob(50))
			if(mob.reagents.get_reagent_amount(/datum/reagent/chloralhydrate) < 2)
				mob.gib()

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

/datum/disease2/effect/fake_gbs
	name = "Gravitokinetic Bipotential SADS+"
	stage = 4
	badness = VIRUS_ENGINEERED

	activate(var/mob/living/carbon/human/mob)
		to_chat(mob, "<span class='danger'>Your body feels as if it's trying to rip itself open...</span>")
		mob.weakened += 5

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

/datum/disease2/effect/cold9
	name = "The Cold"
	stage = 3
	badness = VIRUS_ENGINEERED

	activate(var/mob/living/carbon/human/mob)
		if(mob.reagents.get_reagent_amount(/datum/reagent/leporazine) < 2)
			mob.bodytemperature -= rand(35,75)
			if(prob(35))
				mob.bodytemperature -= rand(45,55)
				to_chat(mob, "<span class='danger'>Your throat feels sore.</span>")
			if(prob(30))
				mob.bodytemperature -= rand(65,80)
				to_chat(mob, "<span class='danger'>You feel stiff.</span>")
			if(prob(5))
				mob.bodytemperature -= rand(85,200)
				to_chat(mob, "<span class='danger'>You stop feeling your limbs.</span>")

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

/datum/disease2/effect/nuclear
	name = "Atomic Fever"
	stage = 1
	badness = VIRUS_EXOTIC
	var/codes_received

	var/list/reflections = list(
		"only atomic light will set me free",
		"atom gave birth to me - he will end me",
		"blast this station, blow up society",
		"they hide our beginning in the vault",
		"insert a disk, enter the code and forget it",
		"praise the atom and end the day",
		"may all who create these be quartered and burned",
		"may destruction fall upon the heads of those who are guilty of a monstrous crime",
		"may they burn in the cleansing flame and disappear with all their work",
		"and even their names and their memory will be erased",
		"hellfire erupted, it was all over",
		"fate does not punish them for their sins, and therefore they consider themselves sinless",
		"and he turned to Atom with a request",
		"sparkling light, my spark is too heavy for me. for all the people I know, the paths are much simpler, brighter",
		"i invite you to the refuge of human Sparks",
		"just a couple of minutes and I will be gone",
		"i need to act faster",
		"i need to do it faster",
		"an all-consuming spirit will take me with him",
		"get the floppy disk and do it",
		"nt gave this station a final solution",
		"i'm in control of myself now",
		"blow up and reunite with him",
		"atom arrival is inevitable",
		"atom can finish any story",
		"glory to the atom, do not forget to shout it at the end",
		"i will die with these people - i will become one with these people",
		)

	activate(var/mob/living/carbon/human/mob)
		if(!codes_received)
			var/obj/machinery/nuclearbomb/nuke = locate(/obj/machinery/nuclearbomb/station) in world
			if(nuke && mob.mind)
				to_chat(mob, "<span class='danger'>Station Self Destruction Code is [nuke.r_code]. Write and dont forget, its very important, you have to blow up the station and get to know the Atom. Your consciousness will tell you everything you need.</span>")
				mob.mind.store_memory("[nuke.r_code]")
				mob.mind.store_memory("<B>ATOM WILL TELL ME THE WAY</B>")
				codes_received = 1
		if(prob(30))
			to_chat(mob, "<span class='notice'>... [pick(reflections)] ...</span>")
			if(prob(5))
				mob.whisper_say("[pick(reflections)]")
		if(mob.reagents.get_reagent_amount(/datum/reagent/tramadol/oxycodone) < 10)
			mob.reagents.add_reagent(/datum/reagent/tramadol/oxycodone, 5)
		mob.add_modifier(/datum/modifier/nuclear)

	deactivate(var/mob/living/carbon/human/mob)
		mob.remove_a_modifier_of_type(/datum/modifier/nuclear)

/datum/modifier/nuclear
	name = "Nuclear fury"
	desc = "You use all your willpower to achieve your highest goal in this life."

	on_created_text = "<span class='warning'>I need to do everything possible to merge with the Atom!</span>"
	on_expired_text = "<span class='notice'>You feel rather weak.</span>"

	disable_duration_percent = 0.8
	outgoing_melee_damage_percent = 1.35
	evasion = 0.7

/datum/disease2/effect/nuclear_exacerbation
	name = "Atomic Rage"
	stage = 2
	badness = VIRUS_EXOTIC

	var/list/reflections = list(
		"I need to shout directly at their skulls!",
		"You're late for the meeting with Atom, hurry up!",
		"Accelerate, Atom is not waiting!",
		"Just a little bit left, pull up!",
		"The long-awaited meeting is already very close, do not miss!",
		"I will turn you into dust, no, Atom will turn you into dust!",
		"The mistake in the universe took Atom captive and put him in a small box, but you will manage to change all this!",
		"Hurry up! A flash will not overshadow your eyes!",
		"Cleansing flames will cleanse your souls!",
		"Try, try and try again! Better death in battle than death in inaction!",
		"The Atom speaks your tongue, the atom sees with your eyes, wake up!",
		"Everything around is not real, but the Atom is real!",
		"Kill all who stand in your way to merge with God!",
		"You will succeed, I know that!",
		"Blast these people, blow their souls, connect them with the Atom!",
		"It is you who succeed, it is you!",
		"Everything in this world is just dust for the Atom!",
		)

	activate(var/mob/living/carbon/human/mob)
		if(prob(25))
			to_chat(mob, "<span class='danger'>[pick(reflections)]</span>")
		if(mob.reagents.get_reagent_amount(/datum/reagent/hyperzine) < 10)
			mob.reagents.add_reagent(/datum/reagent/hyperzine, 4)
		if(mob.reagents.get_reagent_amount(/datum/reagent/bicaridine) < 25)
			mob.reagents.add_reagent(/datum/reagent/bicaridine, 3)

/datum/disease2/effect/nuclear_escalation
	name = "Atomic End"
	stage = 3
	badness = VIRUS_EXOTIC

	activate(var/mob/living/carbon/human/mob, var/multiplier)
		if(prob(10))
			to_chat(mob, "<span class='danger'>The atom was mistaken in you, you received a great gift and could not live up to expectations, good luck.</span>")
			var/obj/item/organ/internal/brain/B = mob.internal_organs_by_name[BP_BRAIN]
			if(B && B.damage < B.min_broken_damage)
				B.take_internal_damage(150)
			mob.apply_effect(30*multiplier, IRRADIATE, blocked = 0)

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

/datum/disease2/effect/flu
	name = "Flu Virion"
	stage = 2
	delay = 25 SECONDS
	badness = VIRUS_MILD

	activate(var/mob/living/carbon/human/mob)
		mob.bodytemperature += 5
		if(prob(3))
			to_chat(mob, "<span class='warning'>Your stomach feels heavy.</span>")
			mob.take_organ_damage((2*multiplier))
		if(prob(10))
			mob.bodytemperature += 10
			to_chat(mob, "<span class='warning'>Your muscles ache.</span>")

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

/datum/disease2/effect/fluspanish
	name = "Spanish Flu Virion"
	stage = 4
	delay = 25 SECONDS
	badness = VIRUS_EXOTIC

	activate(var/mob/living/carbon/human/mob, var/multiplier)
		if(mob.reagents.get_reagent_amount(/datum/reagent/leporazine) < 5)
			mob.bodytemperature += 25
			if(prob(15))
				mob.bodytemperature += 35
				to_chat(mob, "<span class='warning'>Your insides burn out.</span>")
				mob.take_organ_damage((4*multiplier))
			if(prob(10))
				mob.bodytemperature += 40
				to_chat(mob, "<span class='warning'>You're burning in your own skin!</span>")

// ####################################################################
// ###############################BRAINROT#############################
// ####################################################################

/datum/disease2/effect/brainrot
	name = "Cryptococcus Cosmosis"
	stage = 3
	badness = VIRUS_EXOTIC

	activate(var/mob/living/carbon/human/mob, var/multiplier)
		if(mob.reagents.get_reagent_amount(/datum/reagent/alkysine) > 5)
			to_chat(mob, "<span class='notice'>You feel better.</span>")
		else
			if(mob.getBrainLoss() < 90)
				mob.emote("drool")
				mob.adjustBrainLoss(9)
				if(prob(2))
					to_chat(mob, "<span class='warning'>Your try to remember something important...but can't.</span>")
			if(prob(5))
				mob.confused += 5

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

/datum/disease2/effect/vulnerability
	name = "Arteriviridae"
	stage = 1
	badness = VIRUS_EXOTIC

	activate(var/mob/living/carbon/human/mob)
		mob.add_modifier(/datum/modifier/vulnerability)

	deactivate(var/mob/living/carbon/human/mob)
		mob.remove_a_modifier_of_type(/datum/modifier/vulnerability)

/datum/modifier/vulnerability
	name = "Vulnerability"
	desc = "Something devours your inner strength."

	on_created_text = "<span class='warning'>You are now weak, something affects your well-being!</span>"
	on_expired_text = "<span class='notice'>You feel better.</span>"

	max_health_percent = 0.5
	disable_duration_percent = 2
	incoming_brute_damage_percent = 1.5
	incoming_fire_damage_percent = 1.5
	bleeding_rate_percent = 4
	incoming_healing_percent = 0.2

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

/datum/disease2/effect/emp
	name = "Electromagnetic Mismatch Syndrome"
	stage = 3
	badness = VIRUS_EXOTIC

	activate(var/mob/living/carbon/human/mob)
		if(prob(35))
			to_chat(mob, "<span class='danger'>Your inner energy breaks out!</span>")
			empulse(mob.loc, 3, 2)
		if(prob(50))
			to_chat(mob, "<span class='warning'>You are overwhelmed with electricity from the inside!</span>")
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, mob)
			s.start()

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

/datum/disease2/effect/hisstarvation
	name = "Hisstarvation Effect"
	stage = 2
	badness = VIRUS_EXOTIC

	activate(var/mob/living/carbon/human/mob,var/multiplier)
		mob.nutrition = max(0, mob.nutrition - 1000)
		mob.custom_emote("hisses")
		if(prob(25))
			to_chat(mob, "<span class='danger'>[pick("You want to eat more than anything in this life!", "You feel your stomach begin to devour itself!", "You are ready to kill for food!", "You urgently need to find food!")]</span>")

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

/datum/disease2/effect/musclerace
	name = "Reverse Muscle Overstrain Effect"
	stage = 1
	badness = VIRUS_EXOTIC

	activate(var/mob/living/carbon/human/mob,var/multiplier)
		mob.nutrition = max(0, mob.nutrition - 25)
		mob.add_modifier(/datum/modifier/musclerace)
		if(prob(25))
			mob.custom_emote(pick("growls", "roars", "snarls", "squeals", "yelps", "barks", "screeches"))
			mob.jitteriness += 10
		if(prob(45) && mob.reagents.get_reagent_amount(/datum/reagent/mutagen) < 5)
			mob.custom_pain(pick("Your muscle tissue hurts unbearably!", "Your muscle tissue is burning!", "Your muscle tissue is torn!", "Your muscles are torn!", "Your muscles hurt unbearably!", "Your muscles are burning!", "Your muscles are shrinking!"), 45)
			mob.bodytemperature += 45
			mob.take_organ_damage((3*multiplier))

	deactivate(var/mob/living/carbon/human/mob)
		mob.remove_a_modifier_of_type(/datum/modifier/musclerace)

/datum/modifier/musclerace
	name = "Unintentional Muscle Burning"
	desc = "Some kind of force makes your body work to the limit of its capabilities."

	on_created_text = "<span class='warning'>You are incredibly strong right now, this is not for long!</span>"
	on_expired_text = "<span class='notice'>You feel better.</span>"

	max_health_percent = 0.8
	disable_duration_percent = 0.5
	incoming_brute_damage_percent = 1.4
	incoming_fire_damage_percent = 1.4
	bleeding_rate_percent = 2
	incoming_healing_percent = 0.2
	haste = 1
