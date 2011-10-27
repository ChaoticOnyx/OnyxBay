/obj/virus
	// a virus instance that is placed on the map, moves, and infects
	invisibility = 100

	icon = 'laptop.dmi'
	icon_state = "laptop_0"

	var/datum/microorganism/D

	New()
		..()
		step_rand(src)
		step_rand(src)
		anchored = 1
		spawn(300) del(src)

mob/var/datum/microorganism/disease/microorganism = null

/mob/living/carbon/proc/get_infection_chance()
	var/score = 0
	var/mob/living/carbon/M = src
	if(istype(M, /mob/living/carbon/human))
		if(M:gloves)
			score += 5
		if(istype(M:wear_suit, /obj/item/clothing/suit/space)) score += 10
		if(istype(M:wear_suit, /obj/item/clothing/suit/bio_suit)) score += 10
		if(istype(M:head, /obj/item/clothing/head/helmet/space)) score += 5
		if(istype(M:head, /obj/item/clothing/head/bio_hood)) score += 5
	if(M.wear_mask)
		score += 5
		if(istype(M:wear_mask, /obj/item/clothing/mask/surgical) && !M.internal)
			score += 10
		if(M.internal)
			score += 10

	if(score >= 30)
		return 0
	else if(score == 25 && prob(99))
		return 0
	else if(score == 20 && prob(95))
		return 0
	else if(score == 15 && prob(75))
		return 0
	else if(score == 10 && prob(55))
		return 0
	else if(score == 5 && prob(35))
		return 0

	return 1


/proc/infect_microorganism(var/mob/living/carbon/M,var/datum/microorganism/disease/disease,var/forced = 0)
	if(M.microorganism)
		return
	if(!disease)
		return
	//immunity
	for(var/iii = 1, iii <= M.immunemicroorganism.len, iii++)
		if(disease.issame(M.immunemicroorganism[iii]))
			return

	// if one of the antibodies in the mob's body matches one of the disease's antigens, don't infect
	if(M.antibodies & disease.antigen != 0) return

	for(var/datum/microorganism/resistance/res in M.resistances)
		if(res.resistsdisease(disease))
			return
	if(prob(disease.infectionchance) || forced)
		if(M.microorganism)
			return
		else
			// certain clothes can prevent an infection
			if(!forced && !M.get_infection_chance())
				return

			M.microorganism = disease.getcopy()
			M.microorganism.minormutate()

			for(var/datum/microorganism/resistance/res in M.resistances)
				if(res.resistsdisease(M.microorganism))
					M.microorganism = null



/datum/microorganism/resistance
	var/list/datum/microorganism/effect/resistances = list()

	proc/resistsdisease(var/datum/microorganism/disease/microorganism)
		var/list/res2 = list()
		for(var/datum/microorganism/effect/e in resistances)
			res2 += e.type
		for(var/datum/microorganism/effectholder/holder in microorganism)
			if(!(holder.effect.type in res2))
				return 0
			else
				res2 -= holder.effect.type
		if(res2.len > 0)
			return 0
		else
			return 1

	New(var/datum/microorganism/disease/microorganism)
		for(var/datum/microorganism/effectholder/h in microorganism.effects)
			resistances += h.effect.type


/proc/infect_mob_random_lesser(var/mob/living/carbon/M)
	if(!M.microorganism)
		M.microorganism = new /datum/microorganism/disease
		M.microorganism.makerandom()
		M.microorganism.infectionchance = 1

/proc/infect_mob_random_greater(var/mob/living/carbon/M)
	if(!M.microorganism)
		M.microorganism = new /datum/microorganism/disease
		M.microorganism.makerandom(1)

/proc/infect_mob_zombie(var/mob/living/carbon/M)
	if(!M.microorganism)
		M.microorganism = new /datum/microorganism/disease
		M.microorganism.makezombie()

/datum/microorganism/var/antigen = 0 // 16 bits describing the antigens, when one bit is set, a cure with that bit can dock here

// reserving some numbers for later special antigens
var/global/const
	ANTIGEN_A  = 1
	ANTIGEN_B  = 2
	ANTIGEN_RH = 4
	ANTIGEN_Q  = 8
	ANTIGEN_U  = 16
	ANTIGEN_V  = 32
	ANTIGEN_X  = 64
	ANTIGEN_Y  = 128
	ANTIGEN_Z  = 256
	ANTIGEN_M  = 512
	ANTIGEN_N  = 1024
	ANTIGEN_P  = 2048
	ANTIGEN_O  = 4096

var/global/list/ANTIGENS = list("[ANTIGEN_A]" = "A", "[ANTIGEN_B]" = "B", "[ANTIGEN_RH]" = "RH", "[ANTIGEN_Q]" = "Q",
								      "[ANTIGEN_U]" = "U", "[ANTIGEN_V]" = "V", "[ANTIGEN_Z]" = "Z", "[ANTIGEN_M]" = "M",
								      "[ANTIGEN_N]" = "N", "[ANTIGEN_P]" = "P", "[ANTIGEN_O]" = "O")

/datum/microorganism/disease
	var/infectionchance = 10
	var/speed = 1
	var/spreadtype = "Blood" // Can also be "Airborne"
	var/stage = 1
	var/stageprob = 10
	var/dead = 0
	var/clicks = 0

	var/uniqueID = 0
	var/list/datum/microorganism/effectholder/effects = list()
	proc/makerandom(var/greater=0)
		var/datum/microorganism/effectholder/holder = new /datum/microorganism/effectholder
		holder.stage = 1
		if(greater)
			holder.getrandomeffect_greater()
		else
			holder.getrandomeffect_lesser()
		effects += holder
		holder = new /datum/microorganism/effectholder
		holder.stage = 2
		if(greater)
			holder.getrandomeffect_greater()
		else
			holder.getrandomeffect_lesser()
		effects += holder
		holder = new /datum/microorganism/effectholder
		holder.stage = 3
		if(greater)
			holder.getrandomeffect_greater()
		else
			holder.getrandomeffect_lesser()
		effects += holder
		holder = new /datum/microorganism/effectholder
		holder.stage = 4
		if(greater)
			holder.getrandomeffect_greater()
		else
			holder.getrandomeffect_lesser()
		effects += holder
		uniqueID = rand(0,10000)
		infectionchance = rand(1,10)
		// pick 2 antigens
		antigen |= text2num(pick(ANTIGENS))
		antigen |= text2num(pick(ANTIGENS))
		spreadtype = "Airborne"

	proc/makezombie()
		var/datum/microorganism/effectholder/holder = new /datum/microorganism/effectholder
		holder.stage = 1
		holder.chance = 10
		holder.effect = new/datum/microorganism/effect/greater/gunck()
		effects += holder

		holder = new /datum/microorganism/effectholder
		holder.stage = 2
		holder.chance = 10
		holder.effect = new/datum/microorganism/effect/lesser/hungry()
		effects += holder

		holder = new /datum/microorganism/effectholder
		holder.stage = 3
		holder.chance = 10
		holder.effect = new/datum/microorganism/effect/lesser/groan()
		effects += holder

		holder = new /datum/microorganism/effectholder
		holder.stage = 4
		holder.chance = 10
		holder.effect = new/datum/microorganism/effect/zombie()
		effects += holder

		uniqueID = 1220 // all zombie diseases have the same ID
		infectionchance = 0
		spreadtype = "Airborne"

	proc/makealien()
		var/datum/microorganism/effectholder/holder = new /datum/microorganism/effectholder
		holder.stage = 1
		holder.chance = 10
		holder.effect = new/datum/microorganism/effect/lesser/gunck()
		effects += holder

		holder = new /datum/microorganism/effectholder
		holder.stage = 2
		holder.chance = 10
		holder.effect = new/datum/microorganism/effect/lesser/cough()
		effects += holder

		holder = new /datum/microorganism/effectholder
		holder.stage = 3
		holder.chance = 10
		holder.effect = new/datum/microorganism/effect/greater/toxins()
		effects += holder

		holder = new /datum/microorganism/effectholder
		holder.stage = 4
		holder.chance = 10
		holder.effect = new/datum/microorganism/effect/alien()
		effects += holder

		uniqueID = 896 // all alien diseases have the same ID
		infectionchance = 0
		spreadtype = "Airborne"

	proc/minormutate()
		var/datum/microorganism/effectholder/holder = pick(effects)
		holder.minormutate()
		infectionchance = min(10,infectionchance + rand(0,1))

	proc/issame(var/datum/microorganism/disease/disease)
		var/list/types = list()
		var/list/types2 = list()
		for(var/datum/microorganism/effectholder/d in effects)
			types += d.effect.type
		var/equal = 1

		for(var/datum/microorganism/effectholder/d in disease.effects)
			types2 += d.effect.type

		for(var/type in types)
			if(!(type in types2))
				equal = 0
		return equal

	proc/activate(var/mob/living/carbon/mob)
		if(dead)
			cure(mob)
			mob.microorganism = null
			return
		if(mob.stat == 2)
			return
		// with a certain chance, the mob may become immune to the disease before it starts properly
		if(stage <= 1 && clicks == 0)
			if(prob(20))
				mob.antibodies |= antigen // 20% immunity is a good chance IMO, because it allows finding an immune person easily
			else
		if(mob.radiation > 50)
			if(prob(1))
				majormutate()
		if(mob.reagents.has_reagent("spaceacillin"))
			mob.reagents.remove_reagent("spaceacillin",0.3)
			return
		if(mob.reagents.has_reagent("virusfood"))
			mob.reagents.remove_reagent("virusfood",0.1)
			clicks += 10
		if(clicks > stage*100 && prob(10))
			if(stage == 4)
				var/datum/microorganism/resistance/res = new /datum/microorganism/resistance(src)
				mob.immunemicroorganism += src.getcopy()
				mob.resistances2 += res
				mob.antibodies |= src.antigen
				mob.microorganism = null
				del src
			stage++
			clicks = 0
		for(var/datum/microorganism/effectholder/e in effects)
			e.runeffect(mob,stage)
		clicks+=speed

	proc/cure(var/mob/living/carbon/mob)
		var/datum/microorganism/effectholder/E
		if(stage>1)
			E = effects[1]
			E.effect.deactivate(mob)
		if(stage>2)
			E = effects[2]
			E.effect.deactivate(mob)
		if(stage>3)
			E = effects[3]
			E.effect.deactivate(mob)
		if(stage>4)
			E = effects[4]
			E.effect.deactivate(mob)

	proc/cure_added(var/datum/microorganism/resistance/res)
		if(res.resistsdisease(src))
			dead = 1

	proc/majormutate()
		var/datum/microorganism/effectholder/holder = pick(effects)
		holder.majormutate()


	proc/getcopy()
//		world << "getting copy"
		var/datum/microorganism/disease/disease = new /datum/microorganism/disease
		disease.infectionchance = infectionchance
		disease.spreadtype = spreadtype
		disease.stageprob = stageprob
		disease.antigen   = antigen
		for(var/datum/microorganism/effectholder/holder in effects)
	//		world << "adding effects"
			var/datum/microorganism/effectholder/newholder = new /datum/microorganism/effectholder
			newholder.effect = new holder.effect.type
			newholder.chance = holder.chance
			newholder.cure = holder.cure
			newholder.multiplier = holder.multiplier
			newholder.happensonce = holder.happensonce
			newholder.stage = holder.stage
			disease.effects += newholder
	//		world << "[newholder.effect.name]"
	//	world << "[disease]"
		return disease

/datum/microorganism/effect
	var/chance_maxm = 100
	var/name = "Blanking effect"
	var/stage = 4
	var/maxm = 1
	proc/activate(var/mob/living/carbon/mob,var/multiplier)
	proc/deactivate(var/mob/living/carbon/mob)

/datum/microorganism/effect/zombie
	name = "Tombstone Syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		if(istype(mob,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			if(!H.zombie)
				H.zombify()
				del H.microorganism

/datum/microorganism/effect/alien
	name = "Unidentified Foreign Body"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "\red You feel something tearing its way out of your stomach..."
		mob.toxloss += 10
		mob.updatehealth()
		if(prob(40))
			if(mob.client)
				mob.client.mob = new/mob/living/carbon/alien/larva(mob.loc)
			else
				new/mob/living/carbon/alien/larva(mob.loc)
			var/datum/microorganism/disease/D = mob:microorganism
			mob:gib()
			del D

/datum/microorganism/effect/greater/gibbingtons
	name = "Gibbingtons Syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.gib()

/datum/microorganism/effect/greater/radian
	name = "Radian's syndrome"
	stage = 4
	maxm = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.radiation += (2*multiplier)

/datum/microorganism/effect/greater/toxins
	name = "Hyperacid Syndrome"
	stage = 3
	maxm = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.toxloss += (2*multiplier)

/datum/microorganism/effect/greater/scream
	name = "Random screaming syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*scream")

/datum/microorganism/effect/greater/drowsness
	name = "Automated sleeping syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.drowsyness += 10

/datum/microorganism/effect/greater/shakey
	name = "World Shaking syndrome"
	stage = 3
	maxm = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		shake_camera(mob,5*multiplier)

/datum/microorganism/effect/greater/deaf
	name = "Hard of hearing syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.ear_deaf += 20

/datum/microorganism/effect/invisible
	name = "Waiting Syndrome"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		return

/datum/microorganism/effect/greater/telepathic
	name = "Telepathy Syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.mutations |= 512

/datum/microorganism/effect/greater/noface
	name = "Identity Loss syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.face_dmg++
	deactivate(var/mob/living/carbon/mob)
		mob.face_dmg--

/datum/microorganism/effect/greater/monkey
	name = "Monkism syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		if(istype(mob,/mob/living/carbon/human))
			var/mob/living/carbon/human/h = mob
			h.monkeyize()

/datum/microorganism/effect/greater/sneeze
	name = "Coldingtons Effect"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*sneeze")

/datum/microorganism/effect/greater/gunck
	name = "Flemmingtons"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "\red Mucous runs down the back of your throat."

/datum/microorganism/effect/greater/killertoxins
	name = "Toxification syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.toxloss += 15

/datum/microorganism/effect/greater/hallucinations
	name = "Hallucinational Syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.hallucination += 25

/datum/microorganism/effect/greater/sleepy
	name = "Resting syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*collapse")

/datum/microorganism/effect/greater/mind
	name = "Lazy mind syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.brainloss = 50

/datum/microorganism/effect/greater/suicide
	name = "Suicidal syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.suiciding = 1
		//instead of killing them instantly, just put them at -175 health and let 'em gasp for a while
		viewers(mob) << "\red <b>[mob.name] is holding \his breath. It looks like \he's trying to commit suicide.</b>"
		mob.oxyloss = max(175 - mob.toxloss - mob.fireloss - mob.bruteloss, mob.oxyloss)
		mob.updatehealth()
		spawn(200) //in case they get revived by cryo chamber or something stupid like that, let them suicide again in 20 seconds
			mob.suiciding = 0

// lesser syndromes, partly just copypastes
/datum/microorganism/effect/lesser/mind
	name = "Lazy mind syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.brainloss = 20

/datum/microorganism/effect/lesser/drowsy
	name = "Bedroom Syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.drowsyness = 5

/datum/microorganism/effect/lesser/deaf
	name = "Hard of hearing syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.ear_deaf = 5

/datum/microorganism/effect/lesser/gunck
	name = "Flemmingtons"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "\red Mucous runs down the back of your throat."

/datum/microorganism/effect/lesser/radian
	name = "Radian's syndrome"
	stage = 4
	maxm = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.radiation += 1

/datum/microorganism/effect/lesser/sneeze
	name = "Coldingtons Effect"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*sneeze")

/datum/microorganism/effect/lesser/cough
	name = "Anima Syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*cough")

/datum/microorganism/effect/lesser/hallucinations
	name = "Hallucinational Syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.hallucination += 5

/datum/microorganism/effect/lesser/arm
	name = "Disarming Syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		var/datum/organ/external/org = mob.organs["r_arm"]
		org.take_damage(3,0,0,0)
		mob << "\red You feel a sting in your right arm."

/datum/microorganism/effect/lesser/hungry
	name = "Appetiser Effect"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.nutrition = max(0, mob.nutrition - 200)

/datum/microorganism/effect/lesser/groan
	name = "Groaning Syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*groan")

/datum/microorganism/effect/lesser/scream
	name = "Loudness Syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*scream")

/datum/microorganism/effect/lesser/drool
	name = "Saliva Effect"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*drool")

/datum/microorganism/effect/lesser/fridge
	name = "Refridgerator Syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*shiver")

/datum/microorganism/effect/lesser/twitch
	name = "Twitcher"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*twitch")

/*Removed on request by Spaceman, due to it being detrimental to RP. -CN
/datum/microorganism/effect/lesser/deathgasp
	name = "Zombie Syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*deathgasp")*/

/datum/microorganism/effect/lesser/giggle
	name = "Uncontrolled Laughter Effect"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*giggle")


/datum/microorganism/effect/lesser
	chance_maxm = 10

/datum/microorganism/effectholder
	var/name = "Holder"
	var/datum/microorganism/effect/effect
	var/chance = 0 //Chance in percentage each tick
	var/cure = "" //Type of cure it requires
	var/happensonce = 0
	var/multiplier = 1 //The chance the effects are WORSE
	var/stage = 0

	proc/runeffect(var/mob/living/carbon/human/mob,var/stage)
		if(happensonce > -1 && effect.stage <= stage && prob(chance))
			effect.activate(mob)
			if(happensonce == 1)
				happensonce = -1

	proc/getrandomeffect_greater()
		var/list/datum/microorganism/effect/list = list()
		for(var/e in (typesof(/datum/microorganism/effect/greater) - /datum/microorganism/effect/greater))
		//	world << "Making [e]"
			var/datum/microorganism/effect/f = new e
			if(f.stage == src.stage)
				list += f
		effect = pick(list)
		chance = rand(1,6)

	proc/getrandomeffect_lesser()
		var/list/datum/microorganism/effect/list = list()
		for(var/e in (typesof(/datum/microorganism/effect/lesser) - /datum/microorganism/effect/lesser))
			var/datum/microorganism/effect/f = new e
			if(f.stage == src.stage)
				list += f
		effect = pick(list)
		chance = rand(1,6)

	proc/minormutate()
		switch(pick(1,2,3,4,5))
			if(1)
				chance = rand(0,effect.chance_maxm)
			if(2)
				multiplier = rand(1,effect.maxm)
	proc/majormutate()
		getrandomeffect_greater()

/proc/dprob(var/p)
	return(prob(sqrt(p)) && prob(sqrt(p)))