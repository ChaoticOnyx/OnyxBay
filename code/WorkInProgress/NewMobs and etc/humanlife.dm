/mob/living/carbon/human/handle_regular_hud_updates()

	if (stat == 2 || mutations & 4)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = 2
	else if (zombie)
		sight |= SEE_MOBS
		see_in_dark = 4
		see_invisible = 2
	else if (istype(glasses, /obj/item/clothing/glasses/meson))
		sight |= SEE_TURFS
		see_in_dark = 3
		see_invisible = 0
	else if (istype(glasses, /obj/item/clothing/glasses/thermal))
		sight |= SEE_MOBS
		see_in_dark = 4
		see_invisible = 2
	else if (stat != 2)
		sight &= ~SEE_TURFS
		sight &= ~SEE_MOBS
		sight &= ~SEE_OBJS
		if (mutantrace == "lizard")
			see_in_dark = 3
			see_invisible = 1
		else
			see_in_dark = 2
			see_invisible = 0

	if (sleep) sleep.icon_state = text("sleep[]", sleeping)
	if (rest) rest.icon_state = text("rest[]", resting)

	if (healths)
		if (stat != 2)
			switch(health)
				if(100 to INFINITY)
					healths.icon_state = "health0"
				if(80 to 100)
					healths.icon_state = "health1"
				if(60 to 80)
					healths.icon_state = "health2"
				if(40 to 60)
					healths.icon_state = "health3"
				if(20 to 40)
					healths.icon_state = "health4"
				if(0 to 20)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

	if(pullin)	pullin.icon_state = "pull[pulling ? 1 : 0]"


	if (toxin)	toxin.icon_state = "tox[toxins_alert ? 1 : 0]"
	if (oxygen) oxygen.icon_state = "oxy[oxygen_alert ? 1 : 0]"
	if (fire) fire.icon_state = "fire[fire_alert ? 1 : 0]"
	//NOTE: the alerts dont reset when youre out of danger. dont blame me,
	//blame the person who coded them. Temporary fix added.

	switch(bodytemperature) //310.055 optimal body temp

		if(370 to INFINITY)
			bodytemp.icon_state = "temp4"
		if(350 to 370)
			bodytemp.icon_state = "temp3"
		if(335 to 350)
			bodytemp.icon_state = "temp2"
		if(320 to 335)
			bodytemp.icon_state = "temp1"
		if(300 to 320)
			bodytemp.icon_state = "temp0"
		if(295 to 300)
			bodytemp.icon_state = "temp-1"
		if(280 to 295)
			bodytemp.icon_state = "temp-2"
		if(260 to 280)
			bodytemp.icon_state = "temp-3"
		else
			bodytemp.icon_state = "temp-4"

	client.screen -= hud_used.blurry
	client.screen -= hud_used.druggy
	client.screen -= hud_used.vimpaired

	if ((blind && stat != 2))
		if ((blinded))
			blind.layer = 18
		else
			blind.layer = 0

			if (disabilities & 1 && !istype(glasses, /obj/item/clothing/glasses/regular) )
				client.screen += hud_used.vimpaired

			if (eye_blurry)
				client.screen += hud_used.blurry

			if (druggy)
				client.screen += hud_used.druggy

	if (stat != 2)
		if (machine)
			if (!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(!client.adminobs)
				reset_view(null)

	return 1
/mob/living/carbon/human/proc/drip(var/amt as num)
	if(!amt)
		return
	var/turf/T = src.loc
	var/nums
	var/amm = 0.1 * amt
	vessel.remove_reagent("blood",amm)
	for(var/obj/decal/cleanable/blood/drip/D in T)
		nums++
		if(nums >= 3)
			return
	var/obj/decal/cleanable/blood/drip/this = new(T)
	var/hax = pick("1","2","3","4","5")
	this.icon_state = hax
	this.blood_DNA = src.dna.unique_enzymes
	this.blood_type = src.b_type
	this.virus = src.virus
	this.blood_owner = src
	if(src.virus2)
		this.virus2 = src.virus2.getcopy()
/mob/living/carbon/human/handle_regular_status_updates()
	for(var/datum/organ/external/E in GetOrgans())
		E.process()
		if(E.broken)
			if(E.name == "l hand" || E.name == "l arm")
				if(hands && hands.dir == SOUTH && equipped())
					drop_item()
					emote("scream")
			else if(E.name == "r hand" || E.name == "r arm")
				if(hands && hands.dir == NORTH && equipped())
					drop_item()
					emote("scream")
		if(E.open && (!resting) && (!sleeping))
			emote("scream")
			E.take_damage(20,0)
			emote("collapse")
			paralysis = 10


	UpdateDamage()
	updatehealth()
	if(oxyloss > 50) paralysis = max(paralysis, 3)

	if(sleeping)
		paralysis = max(paralysis, 3)
		if (prob(10) && health) spawn(0) emote("snore")
		sleeping--

	if(resting)
		weakened = max(weakened, 5)

	if(health < -100 || brain_op_stage == 4.0)
		if(!zombie|| (toxloss +fireloss) > 100)
			death()
	else if(health < 0)
		if(health <= 20 && prob(1)) spawn(0) emote("gasp")

		//if(!rejuv) oxyloss++
		if(!reagents.has_reagent("inaprovaline")) oxyloss++

		if(stat != 2)	stat = 1
		paralysis = max(paralysis, 5)

	if (stat != 2) //Alive.

		if (paralysis || stunned || weakened || changeling_fakedeath) //Stunned etc.
			if (stunned > 0)
				stunned--
				stat = 0
			if (weakened > 0)
				weakened--
				lying = 1
				stat = 0
			if (paralysis > 0)
				paralysis--
				blinded = 1
				lying = 1
				stat = 1
			var/h = hand
			hand = 0
			drop_item()
			hand = 1
			drop_item()
			hand = h

		else	//Not stunned.
			lying = 0
			stat = 0

	else //Dead.
		lying = 1
		blinded = 1
		stat = 2

	if (stuttering) stuttering--
	if (intoxicated) intoxicated--
	var/datum/organ/external/head/head = organs["head"]
	if(head && src.real_name != "Unknown")
		if(head.brute_dam >= 150 || head.burn_dam >= 150)
			src.real_name = "Unknown"
			src << "\red Your face has become disfigured."
	for(var/datum/organ/external/temp in organs2)
		if(!temp.bleeding)
			continue
		else
			if(prob(35))
				bloodloss += rand(1,10)
		if(temp.wounds)
			for(var/datum/organ/external/wound/W in temp.wounds)
				if(!temp.bleeding)
					continue
				else
					if(prob(25))
						bloodloss++
	if(stat < 2)
		var/amt = vessel.get_reagent_amount("blood")
		var/lol = round(amt)
		if(bloodloss)
			drip(bloodloss)
		if(!lol)
			bloodloss = 0
		else if(lol > 448)
			if(pale)
				pale = 0
				updatepale()
		else if(lol <= 448 && lol > 336)
			if(!pale)
				updatepale()
				pale = 1
				var/word = pick("dizzy","woosey","faint")
				src << "\red You feel [word]"
			if(prob(1))
				var/word = pick("dizzy","woosey","faint")
				src << "\red You feel [word]"
		else if(lol <= 336 && lol > 244)
			if(!pale)
				updatepale()
				pale = 1
			eye_blurry += 6
			if(prob(15))
				paralysis += rand(1,3)
		else if(lol <= 244 && lol > 122)
			if(toxloss <= 100)
				toxloss = 100
		else if(lol <= 122)
			death()
			src.unlock_medal("Were all sold out on blood", 0, "You bled to death..", "easy")
	if (eye_blind)
		eye_blind--
		blinded = 1

	if (ear_deaf > 0) ear_deaf--
	if (ear_damage < 25)
		ear_damage -= 0.05
		ear_damage = max(ear_damage, 0)

	density = !( lying )

	if ((sdisabilities & 1 || istype(glasses, /obj/item/clothing/glasses/blindfold)))
		blinded = 1
	if ((sdisabilities & 4 || istype(ears, /obj/item/clothing/ears/earmuffs)))
		ear_deaf = 1

	if (eye_blurry > 0)
		eye_blurry--
		eye_blurry = max(0, eye_blurry)

	if (druggy > 0)
		druggy--
		druggy = max(0, druggy)

	return 1

/mob/living/carbon/human/proc/morph()
	set name = "Morph"
	if(!(src.mutations & mMorph))
		src.verbs -= /mob/living/carbon/human/proc/morph
		return

	var/new_facial = input("Please select facial hair color.", "Character Generation") as color
	if(new_facial)
		r_facial = hex2num(copytext(new_facial, 2, 4))
		g_facial = hex2num(copytext(new_facial, 4, 6))
		b_facial = hex2num(copytext(new_facial, 6, 8))



	var/new_eyes = input("Please select eye color.", "Character Generation") as color
	if(new_eyes)
		r_eyes = hex2num(copytext(new_eyes, 2, 4))
		g_eyes = hex2num(copytext(new_eyes, 4, 6))
		b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_tone = input("Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation")  as text

	if (new_tone)
		s_tone = max(min(round(text2num(new_tone)), 220), 1)
		s_tone =  -s_tone + 35

	var/new_style = input("Please select hair style", "Character Generation")  as null|anything in list( "Cut Hair", "Short Hair", "Long Hair", "Mohawk", "Balding", "Fag", "Bedhead", "Dreadlocks", "Ponytail", "Bald" )

	if (new_style)
		h_style = new_style

	new_style = input("Please select facial style", "Character Generation")  as null|anything in list("Watson", "Chaplin", "Selleck", "Full Beard", "Long Beard", "Neckbeard", "Van Dyke", "Elvis", "Abe", "Chinstrap", "Hipster", "Goatee", "Hogan", "Shaved")

	if (new_style)
		f_style = new_style

	var/new_gender = input("Please select gender") as null|anything in list("Male","Female")
	if (new_gender)
		if(new_gender == "Male")
			gender = MALE
		else
			gender = FEMALE
	update_body()
	update_face()

	for(var/mob/M in view())
		M.show_message("[src.name] just morphed!")

/mob/living/carbon/human/proc/remotesay()
	set name = "Project mind"
	if(!(src.mutations & mRemotetalk))
		src.verbs -= /mob/living/carbon/human/proc/remotesay
		return

	var/mob/target = input ("Who do you want to project your mind to ?") as mob in world

	var/say = input ("What do you wish to say")

	target.show_message("\blue You hear a voice: [say]")


/mob/living/carbon/human/proc/remoteobserve()
	set name = "Remote View"

	if(!(src.mutations & mRemote))
		src.verbs -= /mob/living/carbon/human/proc/remoteobserve
		return

	var/list/mob/creatures = list()

	for(var/mob/living/carbon/human/h in world)
		creatures += h
	client.perspective = EYE_PERSPECTIVE

	var/eye_name = null

	eye_name = input("Who do you wish to see ?", "Observe", null, null) as null|anything in creatures

	if (!eye_name)
		return

	var/mob/eye = creatures[eye_name]
	if (eye)
		client.eye = eye
	else
		client.eye = client.mob

/mob/living/carbon/human/proc/updatepale()
	if(!pale)
		stand_icon.Blend(rgb(100,100,100))
		lying_icon.Blend(rgb(100,100,100))
		pale = 1
	else
		update_body()
		pale = 0
/mob/living/carbon/human/handle_disabilities()
	if(zombie == 1)
		return

	if(mutations & mSmallsize)
		if(!(flags & TABLEPASS))
			flags |= TABLEPASS
	else
		if(flags & TABLEPASS)
			flags &= ~TABLEPASS

	if(mutations & mMorph)
		if(!(/mob/living/carbon/human/proc/morph in src.verbs))
			src.verbs += /mob/living/carbon/human/proc/morph

	if(mutations & mRemote)
		if(!(/mob/living/carbon/human/proc/remoteobserve in src.verbs))
			src.verbs += /mob/living/carbon/human/proc/remoteobserve

	if(mutations & mRemotetalk)
		if(!(/mob/living/carbon/human/proc/remotesay in src.verbs))
			src.verbs += /mob/living/carbon/human/proc/remotesay

	if(hallucination > 0)

		if(hallucinations.len == 0 && hallucination >= 20 && health > 0)
			if(prob(5))
				fake_attack(src)
		//for(var/atom/a in hallucinations)
		//	a.hallucinate(src)
		hallucination -= 1
		if(health < 0)
			for(var/obj/a in hallucinations)
				del a
	else
		halloss = 0
		for(var/obj/a in hallucinations)
			del a

	if (mutations & mHallucination)
		hallucination = 100
		halloss = 0

	if (mutations & mRegen)
		src.bruteloss -= 1
		src.fireloss -= 1
		src.oxyloss -= 1

		for(var/datum/organ/external/o in GetOrgans())
			if(o.broken)
				o.heal_damage(1,1,1)


	if (disabilities & 2)
		if ((prob(1) && paralysis < 1 && r_epil < 1))
			src << "\red You have a seizure!"
			for(var/mob/O in viewers(src, null))
				if(O == src)
					continue
				O.show_message(text("\red <B>[src] starts having a seizure!"), 1)
			paralysis = max(10, paralysis)
			make_jittery(1000)
	if (disabilities & 4)
		if ((prob(5) && paralysis <= 1 && r_ch_cou < 1))
			drop_item()
			spawn( 0 )
				emote("cough")
				return
	if (disabilities & 8)
		if ((prob(10) && paralysis <= 1 && r_Tourette < 1))
			stunned = max(10, stunned)
			spawn( 0 )
				switch(rand(1, 3))
					if(1)
						emote("twitch")
					if(2 to 3)
						say("[prob(50) ? ";" : ""][pick("DWARFS","MAGMA","ARMOK")]!")
				var/old_x = pixel_x
				var/old_y = pixel_y
				pixel_x += rand(-2,2)
				pixel_y += rand(-1,1)
				sleep(2)
				pixel_x = old_x
				pixel_y = old_y
				return
	if (disabilities & 16)
		if (prob(10))
			stuttering = max(10, stuttering)
//	if (brainloss >= 60 && stat != 2)

/mob/living/carbon/human/handle_chemicals_in_body()
	if(reagents) reagents.metabolize(src)
	if(vessel) vessel.metabolize(src)

	for(var/obj/item/I in src)
		if(I.contaminated) toxloss += vsc.plc.CONTAMINATION_LOSS

	if(nutrition > 400 && !(mutations & 32))
		if(prob(5 + round((nutrition - 200) / 2)))
			src << "\red You suddenly feel blubbery!"
			mutations |= 32
			update_body()
	if (nutrition < 100 && mutations & 32)
		if(prob(round((50 - nutrition) / 100)))
			src << "\blue You feel fit again!"
			mutations &= ~32
			update_body()
	if (nutrition > 0)
		nutrition--

	if (drowsyness)
		drowsyness--
		eye_blurry = max(2, eye_blurry)
		if (prob(5))
			sleeping = 1
			paralysis = 5

	confused = max(0, confused - 1)
	// decrement dizziness counter, clamped to 0
	if(resting)
		dizziness = max(0, dizziness - 5)
		jitteriness = max(0, jitteriness - 5)
	else
		dizziness = max(0, dizziness - 1)
		jitteriness = max(0, jitteriness - 1)

	updatehealth()

	return //TODO: DEFERRED

/mob/living/carbon/human/handle_mutations_and_radiation()
	if(zombifying)
		zombietime -= 1
		if(zombietime <= 0)
			zombify()

		if(prob(5))
			src << pick("\red You feel very slow","\red You feel hungry", "\red You start drooling")


	if(zombie)
		stunned = 0
		paralysis = 0
		handcuffed = 0
		oxyloss = 0
		if(l_hand)
		//	u_equip(l_hand)
			if (client)
				client.screen -= l_hand
			if (l_hand)
				l_hand.loc = loc
				l_hand.dropped(src)
				l_hand.layer = initial(r_hand.layer)
				l_hand = null
		if(r_hand)
		//	u_equip(r_hand)
			if (client)
				client.screen -= r_hand
			if (r_hand)
				r_hand.loc = loc
				r_hand.dropped(src)
				r_hand.layer = initial(r_hand.layer)
				r_hand = null
		machine = null

	..()

/mob/living/carbon/human/breathe()
	if(mutations & mNobreath)	return
	if(reagents.has_reagent("lexorin")) return
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) return

	var/datum/gas_mixture/environment = loc.return_air(1)
	var/datum/gas_mixture/breath
	// HACK NEED CHANGING LATER
	if(health < 0 && !zombie)
		losebreath++

	//var/halfmask = 0

	//if(wear_mask && internal)
	//	if(wear_mask.flags & 4)
	//		halfmask = 1

	if(losebreath > 10) //Suffocating so do not take a breath
		losebreath--
		if (prob(75)) //High chance of gasping for air
			spawn emote("gasp")
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)
	/*else if(halfmask)
		var/datum/gas_mixture/breath2

		breath = get_breath_from_internal(BREATH_VOLUME/2)

		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			breath2 = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME/2)
		else if(istype(loc, /turf/))
			var/breath_moles = 0
			/*if(environment.return_pressure() > ONE_ATMOSPHERE)
				// Loads of air around (pressure effects will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
				breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
				else*/
				// Not enough air around, take a percentage of what's there to model this properly
			breath_moles = environment.total_moles()*((BREATH_VOLUME/2)/CELL_VOLUME)

			breath2 = loc.remove_air(breath_moles)

		breath.merge(breath2)*/
	else
		//First, check for air from internal atmosphere (using an air tank and mask generally)
		breath = get_breath_from_internal(BREATH_VOLUME)

		//No breath from internal atmosphere so suffocate if wearing them, otherwise try and breathe external atmosphere
		if(!breath && !internal)
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				breath = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME)
			else if(istype(loc, /turf/))
				var/breath_moles = 0
				/*if(environment.return_pressure() > ONE_ATMOSPHERE)
					// Loads of air around (pressure effects will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
					breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
				else*/
					// Not enough air around, take a percentage of what's there to model this properly
				breath_moles = environment.total_moles()*BREATH_PERCENTAGE

				breath = loc.remove_air(breath_moles)

		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

	handle_breath(breath)

	if(breath)
		loc.assume_air(breath)

/mob/living/carbon/human/handle_breath(datum/gas_mixture/breath)
	if(nodamage)
		return
	if(zombie)
		oxyloss = 0
		var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME
		var/Toxins_pp = (breath.toxins/breath.total_moles())*breath_pressure
		if(Toxins_pp > 0.5)
			toxloss += 5
		var/O2_pp = (breath.oxygen/breath.total_moles())*breath_pressure
		if(O2_pp > 16)
			bruteloss -= 8
			bruteloss = max(100,bruteloss)
			oxyloss = 0
	return ..()

/*
snippets

	if (mach)
		if (machine)
			mach.icon_state = "mach1"
		else
			mach.icon_state = null

	if (!m_flag)
		moved_recently = 0
	m_flag = null



		if ((istype(loc, /turf/space) && !( locate(/obj/movable, loc) )))
			var/layers = 20
			// ******* Check
			if (((istype(head, /obj/item/clothing/head) && head.flags & 4) || (istype(wear_mask, /obj/item/clothing/mask) && (!( wear_mask.flags & 4 ) && wear_mask.flags & 8))))
				layers -= 5
			if (istype(w_uniform, /obj/item/clothing/under))
				layers -= 5
			if ((istype(wear_suit, /obj/item/clothing/suit) && wear_suit.flags & 8))
				layers -= 10
			if (layers > oxcheck)
				oxcheck = layers


				if(bodytemperature < 282.591 && (!firemut))
					if(bodytemperature < 250)
						fireloss += 4
						updatehealth()
						if(paralysis <= 2)	paralysis += 2
					else if(prob(1) && !paralysis)
						if(paralysis <= 5)	paralysis += 5
						emote("collapse")
						src << "\red You collapse from the cold!"
				if(bodytemperature > 327.444  && (!firemut))
					if(bodytemperature > 345.444)
						if(!eye_blurry)	src << "\red The heat blurs your vision!"
						eye_blurry = max(4, eye_blurry)
						if(prob(3))	fireloss += rand(1,2)
					else if(prob(3) && !paralysis)
						paralysis += 2
						emote("collapse")
						src << "\red You collapse from heat exaustion!"
				plcheck = t_plasma
				oxcheck = t_oxygen
				G.turf_add(T, G.total_moles())
*/