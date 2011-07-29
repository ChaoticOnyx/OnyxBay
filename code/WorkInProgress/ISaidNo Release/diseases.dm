// These are diseases I coded - since Nannek did the overarching disease system I don't paticularly want to include it
// Variables are:
// max_stages = What the highest stage of the disease is, this is used in the procs
// spread = How it spreads = the vectors are taken care of in mob life code and gameticker
// cure = what cures the disease = this is taken care of mainly in disease.dm but in a few other places too
// reagentcure = Any reagents in this list variable will cure the disease if present in the victim's system
// recureprob = What % chance per tick that reagents in the victim's system will cure the disease
// associated_reagent = used for disease dispensing in the pathology department
// affected_species = somewhat obvious, includes "Human", "Monkey" and "Alien"

// the stage_act proc is calculated every tick in the mob's life proc
// it is generally set up to have various things happen with a % chance depending on what stage the disease is at

/datum/ailment/disease/berserker
	name = "Berserker"
	max_stages = 2
	spread = "Contact"
	cure = "Sedative Reagents"
	reagentcure = list("stoxin","cryptobiolin","lexorin","impedrezene")
	recureprob = 10
	associated_reagent = "pubbie tears"
	affected_species = list("Human")

/datum/ailment/disease/berserker/stage_act()
	..()
	if (affected_mob.reagents.has_reagent("THC"))
		affected_mob <<"\blue You mellow out."
		affected_mob.resistances += src.type
		affected_mob.ailments -= src
	switch(stage)
		if(1)
			if (prob(5)) affected_mob.emote(pick("twitch", "grumble"))
			if (prob(5))
				var/speak = pick("Grr...", "Fuck...", "Fucking...", "Fuck this fucking.. fuck..")
				affected_mob.say(speak)
		if(2)
			if (prob(5)) affected_mob.emote(pick("twitch", "scream"))
			if (prob(5))
				var/speak = pick("AAARRGGHHH!!!!", "GRR!!!", "FUCK!! FUUUUUUCK!!!", "FUCKING SHITCOCK!!", "WROOAAAGHHH!!")
				affected_mob.say(speak)
			if (prob(15))
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(text("\red <B>[] twitches violently!</B>", affected_mob), 1)
				var/h = affected_mob.hand
				affected_mob.hand = 0
				affected_mob.drop_item()
				affected_mob.hand = 1
				affected_mob.drop_item()
				affected_mob.hand = h
			if (prob(33))
				if (!affected_mob.canmove)
					for(var/mob/O in viewers(affected_mob, null))
						O.show_message(text("\red <B>[] spasms and twitches!</B>", affected_mob), 1)
					return
				for (var/mob/living/carbon/M in range(1,affected_mob))
					for(var/mob/O in viewers(affected_mob, null))
						O.show_message(text("\red <B>[] thrashes around violently!</B>", affected_mob), 1)
					if (M == affected_mob) continue
					var/damage = rand(1, 5)
					if (prob(80))
						playsound(affected_mob.loc, "punch", 25, 1, -1)
						for(var/mob/O in viewers(affected_mob, null))
							O.show_message(text("\red <B>[] hits [] with their thrashing!</B>", affected_mob, M), 1)
						M.bruteloss += damage
						M.updatehealth()
					else
						playsound(affected_mob.loc, 'punchmiss.ogg', 25, 1, -1)
						for(var/mob/O in viewers(affected_mob, null))
							O.show_message(text("\red <B>[] fails to hit [] with their thrashing!</B>", affected_mob, M), 1)
						return

/datum/ailment/disease/food_poisoning
	name = "Food Poisoning"
	max_stages = 3
	spread = "Non-Contagious"
	cure = "Rest"
	associated_reagent = "salmonella"
	affected_species = list("Human")
//
/datum/ailment/disease/food_poisoning/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(5))
				affected_mob << "\red Your stomach feels weird."
			if(prob(5))
				affected_mob << "\red You feel queasy."
		if(2)
			if(affected_mob.sleeping && prob(40))
				affected_mob << "\blue You feel better."
				affected_mob.ailments -= src
				return
			if(prob(1) && prob(10))
				affected_mob << "\blue You feel better."
				affected_mob.ailments -= src
				return
			if(prob(10))
				affected_mob.emote("groan")
			if(prob(5))
				affected_mob << "\red Your stomach aches."
			if(prob(5))
				affected_mob << "\red You feel nauseous."
		if(3)
			if(affected_mob.sleeping && prob(25))
				affected_mob << "\blue You feel better."
				affected_mob.ailments -= src
				return
			if(prob(1) && prob(10))
				affected_mob << "\blue You feel better."
				affected_mob.ailments -= src
			if(prob(10))
				affected_mob.emote("moan")
			if(prob(10))
				affected_mob.emote("groan")
			if(prob(1))
				affected_mob << "\red Your stomach hurts."
			if(prob(1))
				affected_mob << "\red You feel sick."
			if(prob(5))
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(text("\red [] farts, leaking diarrhea down their legs!", affected_mob), 1)
				playsound(affected_mob.loc, 'poo2.ogg', 50, 1)
				new /obj/decal/cleanable/poo(affected_mob.loc)
			if(prob(5))
				if (affected_mob.nutrition > 10)
					for(var/mob/O in viewers(affected_mob, null))
						O.show_message(text("\red [] vomits on the floor profusely!", affected_mob), 1)
					playsound(affected_mob.loc, 'splat.ogg', 50, 1)
					new /obj/decal/cleanable/vomit(affected_mob.loc)
					affected_mob.nutrition -= rand(3,5)
				else
					affected_mob << "\red Your stomach lurches painfully!"
					for(var/mob/O in viewers(affected_mob, null))
						O.show_message(text("\red [] gags and retches!", affected_mob), 1)
					affected_mob.stunned += rand(2,4)
					affected_mob.weakened += rand(2,4)

/datum/ailment/disease/necrotic_degeneration
	name = "Necrotic Degeneration"
	max_stages = 6
	spread = "Contact"
	cure = "Healing Reagents"
	reagentcure = list("tricordazine","cryoxadone","alkysine","arithrazine","bicaridine")
	recureprob = 8
	associated_reagent = "necrovirus"
	affected_species = list("Human")

/datum/ailment/disease/necrotic_degeneration/stage_act()
	..()
	if (affected_mob.fireloss >= 80) affected_mob.ailments -= src
	switch(stage)
		if(2)
			if (prob(5))
				affected_mob.emote(pick("shiver", "pale"))
		if(3)
			if (prob(8))
				affected_mob << "\red You notice a foul smell."
			if (prob(10))
				affected_mob << "\red You lose track of your thoughts."
				affected_mob.brainloss += 10
			if (prob(4))
				affected_mob << "\red You pass out momentarily."
				affected_mob.paralysis += 2
			if (prob(5))
				affected_mob.emote(pick("shiver","pale","drool"))
		if(4)
			affected_mob.stuttering = 10
			if (prob(10))
				affected_mob.emote(pick("drool","moan"))
			if (prob(20))
				affected_mob.say(pick("Hungry...", "Must... kill...", "Brains..."))
		if(5)
			if (affected_mob:mutantrace && istype(affected_mob:mutantrace, /datum/mutantrace/zombie)) stage++
			affected_mob.stuttering = 10
			affected_mob <<"\red Your skin rots off."
			affected_mob.toxloss += 1
			affected_mob.updatehealth()
			if(prob(33))
				affected_mob <<"\red Your heart seems to have stopped..."
				affected_mob:mutantrace = new /datum/mutantrace/zombie(affected_mob)
				regress = 0
				curable = 0
				cure = "Subject Beyond Help"
				stage++
		if(6)
			affected_mob.stuttering = 10
			affected_mob.brainloss = 90
			if (prob(10))
				affected_mob.emote(pick("moan"))

/datum/ailment/disease/panacaea
	name = "Panacaea"
	max_stages = 2
	spread = "Airborne"
	cure = "Self-Curing"
	curable = 0
	regress = 0
	associated_reagent = "viral curative"
	affected_species = list("Human", "Monkey", "Alien")

//
/datum/ailment/disease/panacaea/stage_act()
	..()
	switch(stage)
		if(1)
			if (prob(8))
				affected_mob <<"\blue You feel refreshed."
				affected_mob.bruteloss -= 2
				affected_mob.fireloss -= 2
				affected_mob.toxloss -= 2
			if (prob(8))
				var/procmessage = pick("You feel very healthy.","All your aches and pains fade.","You feel really good!")
				affected_mob <<"\blue [procmessage]"
		if(2)
			if (prob(8))
				var/procmessage = pick("You feel very healthy.","All your aches and pains fade.","You feel really good!")
				affected_mob <<"\blue [procmessage]"
			if (prob(8))
				affected_mob <<"\blue You feel refreshed."
				affected_mob.bruteloss -= 2
				affected_mob.fireloss -= 2
				affected_mob.toxloss -= 2
			if(prob(10))
				for (var/datum/ailment/disease/V in affected_mob.ailments)
					if (istype(V, /datum/ailment/disease/panacaea)) continue
					affected_mob.resistances += V.type
					affected_mob.ailments -= V

/datum/ailment/disease/space_aids
	name = "Space AIDS"
	max_stages = 3
	spread = "Airborne"
	cure = "Incurable"
	curable = 0
	regress = 0
	associated_reagent = "HIV"
	affected_species = list("Human")


/datum/ailment/disease/space_aids/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(5)) affected_mob.emote(pick("cough", "sneeze"))
			if (prob(8))
				var/procmessage = pick("You feel utterly horrible.","You feel deathly ill.","You feel like your body is shutting down...")
				affected_mob <<"\red [procmessage]"
		if(2)
			if(prob(10))
				for(var/datum/ailment/A in affected_mob.ailments)
					affected_mob.toxloss += 1
					affected_mob.updatehealth()
			if(prob(8)) affected_mob.emote("sneeze")
			if (prob(8))
				var/procmessage = pick("You feel like you're dying...","Your innards ache horribly.")
				affected_mob <<"\red [procmessage]"
		if(3)
			if(prob(10))
				for(var/datum/ailment/A in affected_mob.ailments)
					affected_mob.toxloss += 1
					affected_mob.updatehealth()
			if(prob(5)) affected_mob.emote(pick("cough", "sneeze"))
			if (prob(8))
				var/procmessage = pick("It feels like you could drop dead any second...","Pain and nausea wrack your entire body.")
				affected_mob <<"\red [procmessage]"
			if(prob(5))
				switch(rand(1,17))
					if (1) affected_mob.contract_disease(new /datum/ailment/disease/gastric_ejections)
					if (2) affected_mob.contract_disease(new /datum/ailment/disease/gay)
					if (3) affected_mob.contract_disease(new /datum/ailment/disease/cold)
					if (4) affected_mob.contract_disease(new /datum/ailment/disease/flu)
					if (5) affected_mob.contract_disease(new /datum/ailment/disease/fake_gbs)
					if (6) affected_mob.contract_disease(new /datum/ailment/disease/berserker)
					if (7) affected_mob.contract_disease(new /datum/ailment/disease/cosby)
					if (8) affected_mob.contract_disease(new /datum/ailment/disease/teleportitis)
					if (9) affected_mob.contract_disease(new /datum/ailment/disease/gbs)
					if (10) affected_mob.contract_disease(new /datum/ailment/disease/clowning_around)
					if (11) affected_mob.contract_disease(new /datum/ailment/disease/necrotic_degeneration)
					if (12) affected_mob.contract_disease(new /datum/ailment/disease/dnaspread)
					if (13) affected_mob.contract_disease(new /datum/ailment/disease/space_madness)
					if (14) affected_mob.contract_disease(new /datum/ailment/disease/food_poisoning)
					if (15) affected_mob.contract_disease(new /datum/ailment/disease/downs)
					if (16) affected_mob.contract_disease(new /datum/ailment/disease/owns)
		else
			return

/datum/ailment/disease/vamplague
	name = "Grave Fever"
	max_stages = 3
	spread = "Airborne"
	cure = "Antibiotics"
	recureprob = 10
	regress = 0
	associated_reagent = "grave dust"
	affected_species = list("Human")

/datum/ailment/disease/vamplague/stage_act()
	..()
	var/toxdamage = stage * 2
	var/stuntime = stage * 3
	if(prob(9)) affected_mob.emote(pick("cough","groan", "gasp"))
	if(prob(12))
		if (prob(33)) affected_mob << "\red You feel sickly and weak."
		affected_mob.toxloss += toxdamage
	if(prob(6))
		affected_mob << "\red Your joints ache horribly!"
		affected_mob.weakened += stuntime
		affected_mob.stunned += stuntime