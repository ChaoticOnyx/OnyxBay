////////////////////////STAGE 1/////////////////////////////////
/datum/disease2/effect/stealth
	name = "Silent Death Syndrome"
	stage = 1
	badness = VIRUS_EXOTIC
	chance_max = 0
	allow_multiple = 1



/datum/disease2/effect/vulnerability
	name = "Arteriviridae"
	stage = 1
	badness = VIRUS_EXOTIC

/datum/disease2/effect/vulnerability/activate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.add_modifier(/datum/modifier/vulnerability)

/datum/disease2/effect/vulnerability/deactivate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.remove_a_modifier_of_type(/datum/modifier/vulnerability)

/datum/modifier/vulnerability
	name = "Vulnerability"
	desc = "Something devours your inner strength."

	max_health_percent = 0.5
	disable_duration_percent = 2
	incoming_brute_damage_percent = 1.5
	incoming_fire_damage_percent = 1.5
	bleeding_rate_percent = 4
	incoming_healing_percent = 0.2

/datum/modifier/vulnerability/New(new_holder, new_origin)
	. = ..()
	on_created_text = SPAN("warning", "You are now weak, something affects your well-being!")
	on_expired_text = SPAN("notice", "You feel better.")

/datum/disease2/effect/musclerace
	name = "Reverse Muscle Overstrain Effect"
	stage = 1
	badness = VIRUS_EXOTIC

/datum/disease2/effect/musclerace/activate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.nutrition = max(0, mob.nutrition - 25)
	mob.add_modifier(/datum/modifier/musclerace)
	if(prob(25))
		mob.custom_emote(pick("growls", "roars", "snarls", "squeals", "yelps", "barks", "screeches"))
		mob.jitteriness += 10
	if(prob(45) && mob.reagents.get_reagent_amount(/datum/reagent/mutagen) < 5)
		mob.custom_pain(pick("Your muscle tissue hurts unbearably!", "Your muscle tissue is burning!", "Your muscle tissue is torn!", "Your muscles are torn!", "Your muscles hurt unbearably!", "Your muscles are burning!", "Your muscles are shrinking!"), 45)
		mob.bodytemperature += 45
		mob.take_organ_damage((3 * multiplier))

/datum/disease2/effect/musclerace/deactivate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.remove_a_modifier_of_type(/datum/modifier/musclerace)

/datum/modifier/musclerace
	name = "Unintentional Muscle Burning"
	desc = "Some kind of force makes your body work to the limit of its capabilities."

	max_health_percent = 0.8
	disable_duration_percent = 0.5
	incoming_brute_damage_percent = 1.4
	incoming_fire_damage_percent = 1.4
	bleeding_rate_percent = 2
	incoming_healing_percent = 0.2
	haste = 1

/datum/modifier/musclerace/New(new_holder, new_origin)
	. = ..()
	on_created_text = SPAN("warning", "You are incredibly strong right now, this is not for long!")
	on_expired_text = SPAN("notice", "You feel better.")

// Atom Virus
/datum/disease2/effect/nuclear
	name = "Atomic Fever"
	stage = 1
	badness = VIRUS_EXOTIC
	possible_mutations = list(/datum/disease2/effect/nuclear_exacerbation,
							  /datum/disease2/effect/nuclear_escalation)
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

/datum/disease2/effect/nuclear/activate(mob/living/carbon/human/mob)
	if(..())
		return
	if(!codes_received)
		var/obj/machinery/nuclearbomb/nuke = locate(/obj/machinery/nuclearbomb/station) in world
		if(nuke && mob.mind)
			to_chat(mob, SPAN("danger", "Station Self Destruction Code is [nuke.r_code]. Write and dont forget, its very important, you have to blow up the station and get to know the Atom. Your consciousness will tell you everything you need."))
			mob.mind.store_memory("[nuke.r_code]")
			mob.mind.store_memory("<B>ATOM WILL TELL ME THE WAY</B>")
			codes_received = 1
	if(prob(30))
		to_chat(mob, SPAN("notice", "... [pick(reflections)] ..."))
		if(prob(5))
			mob.whisper_say("[pick(reflections)]")
	if(mob.reagents.get_reagent_amount(/datum/reagent/tramadol/oxycodone) < 10)
		mob.reagents.add_reagent(/datum/reagent/tramadol/oxycodone, 5)
	mob.add_modifier(/datum/modifier/nuclear)

/datum/disease2/effect/nuclear/deactivate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.remove_a_modifier_of_type(/datum/modifier/nuclear)

/datum/modifier/nuclear
	name = "Nuclear fury"
	desc = "You use all your willpower to achieve your highest goal in this life."

	disable_duration_percent = 0.8
	outgoing_melee_damage_percent = 1.35
	evasion = 0.7

/datum/modifier/nuclear/New(new_holder, new_origin)
	. = ..()
	on_created_text = SPAN("warning", "I need to do everything possible to merge with the Atom!")
	on_expired_text = SPAN("notice", "You feel rather weak.")

////////////////////////STAGE 2/////////////////////////////////

/datum/disease2/effect/hisstarvation
	name = "Hisstarvation Effect"
	stage = 2
	badness = VIRUS_EXOTIC

/datum/disease2/effect/hisstarvation/activate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.nutrition = max(0, mob.nutrition - 1000)
	mob.custom_emote(message = "hisses")
	if(prob(25))
		to_chat(mob, SPAN("danger", "[pick("You want to eat more than anything in this life!", "You feel your stomach begin to devour itself!", "You are ready to kill for food!", "You urgently need to find food!")]"))

//Atom Virus
/datum/disease2/effect/nuclear_exacerbation
	name = "Atomic Rage"
	stage = 2
	badness = VIRUS_EXOTIC
	possible_mutations = list(/datum/disease2/effect/nuclear,
							  /datum/disease2/effect/nuclear_escalation)

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

/datum/disease2/effect/nuclear_exacerbation/activate(mob/living/carbon/human/mob)
	if(..())
		return
	if(prob(25))
		to_chat(mob, SPAN("danger", "[pick(reflections)]"))
	if(mob.reagents.get_reagent_amount(/datum/reagent/hyperzine) < 10)
		mob.reagents.add_reagent(/datum/reagent/hyperzine, 4)
	if(mob.reagents.get_reagent_amount(/datum/reagent/bicaridine) < 25)
		mob.reagents.add_reagent(/datum/reagent/bicaridine, 3)

////////////////////////STAGE 3/////////////////////////////////

/datum/disease2/effect/brainrot
	name = "Cryptococcus Cosmosis"
	stage = 3
	badness = VIRUS_EXOTIC
	possible_mutations = list(/datum/disease2/effect/mind)

/datum/disease2/effect/brainrot/activate(mob/living/carbon/human/mob)
	if(..())
		return
	if(mob.reagents.get_reagent_amount(/datum/reagent/alkysine) > 5)
		to_chat(mob, SPAN("notice", "You feel better."))
	else
		if(mob.getBrainLoss() < 90)
			mob.emote("drool")
			mob.adjustBrainLoss(9)
			if(prob(2))
				to_chat(mob, SPAN("warning", "Your try to remember something important... But can't."))
		if(prob(5))
			mob.confused += 5



/datum/disease2/effect/emp
	name = "Electromagnetic Mismatch Syndrome"
	stage = 3
	badness = VIRUS_EXOTIC
	possible_mutations = list(/datum/disease2/effect/radian)

/datum/disease2/effect/emp/activate(mob/living/carbon/human/mob)
	if(..())
		return
	if(prob(35))
		to_chat(mob, SPAN("danger", "Your inner energy breaks out!"))
		empulse(mob.loc, 3, 2)
	if(prob(50))
		to_chat(mob, SPAN("warning", "You are overwhelmed with electricity from the inside!"))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, mob)
		s.start()


//Atom Virus
/datum/disease2/effect/nuclear_escalation
	name = "Atomic End"
	stage = 3
	badness = VIRUS_EXOTIC
	possible_mutations = list(/datum/disease2/effect/nuclear_exacerbation,
							  /datum/disease2/effect/nuclear)

/datum/disease2/effect/nuclear_escalation/activate(mob/living/carbon/human/mob)
	if(..())
		return
	if(prob(10))
		to_chat(mob, SPAN("danger", "The atom was mistaken in you, you received a great gift and could not live up to expectations, good luck."))
		var/obj/item/organ/internal/brain/B = mob.internal_organs_by_name[BP_BRAIN]
		if(B && B.damage < B.min_broken_damage)
			B.take_internal_damage(150)
		mob.apply_effect(30*multiplier, IRRADIATE, blocked = 0)

////////////////////////STAGE 4/////////////////////////////////

/datum/disease2/effect/gibbingtons
	name = "Gibbingtons Syndrome"
	stage = 4
	badness = VIRUS_EXOTIC

/datum/disease2/effect/gibbingtons/activate(mob/living/carbon/human/mob)
	if(..())
		return
	// Probabilities have been tweaked to kill in ~2-3 minutes, giving 5-10 messages.
	// Probably needs more balancing, but it's better than LOL U GIBBED NOW, especially now that viruses can potentially have no signs up until Gibbingtons.
	mob.adjustBruteLoss(10*multiplier)
	var/obj/item/organ/external/O = pick(mob.organs)
	if(prob(25))
		to_chat(mob, GIBBINGTONS_EFFECT_WARNING(O.name))
	if(prob(10))
		spawn(50)
			if(O)
				O.droplimb(0,DROPLIMB_BLUNT)
