////////////////////////STAGE 1/////////////////////////////////

/datum/disease2/effect/honk
	name = "Honking Syndrome"
	stage = 1

/datum/disease2/effect/honk/activate(mob/living/carbon/human/mob)
	playsound(mob.loc, 'sound/items/bikehorn.ogg', 50, 1)
	to_chat(mob, SPAN_WARNING("You suddenly honk."))



/datum/disease2/effect/invisible
	name = "Waiting Syndrome"
	stage = 1



/datum/disease2/effect/sneeze
	name = "Coldingtons Effect"
	stage = 1
	delay = 15 SECONDS

/datum/disease2/effect/sneeze/activate(var/mob/living/carbon/human/mob)
	if (prob(30))
		to_chat(mob, SNEEZE_EFFECT_WARNING)
	sleep(5)
	mob.emote("sneeze")
	for(var/mob/living/carbon/human/M in get_step(mob,mob.dir))
		mob.spread_disease_to(M)
	if (prob(50) && !mob.wear_mask)
		var/obj/effect/decal/cleanable/mucus/M = new(get_turf(mob))
		M.virus2 = virus_copylist(mob.virus2)



/datum/disease2/effect/gunck
	name = "Flemmingtons"
	stage = 1
	delay = 25 SECONDS

/datum/disease2/effect/gunck/activate(var/mob/living/carbon/human/mob)
	to_chat(mob, GUNCK_EFFECT_WARNING)



/datum/disease2/effect/drool
	name = "Saliva Effect"
	stage = 1
	chance_max = 25
	delay = 25 SECONDS

/datum/disease2/effect/drool/activate(var/mob/living/carbon/human/mob)
	mob.emote("drool")



/datum/disease2/effect/twitch
	name = "Twitcher"
	stage = 1
	chance_max = 25
	delay = 25 SECONDS

/datum/disease2/effect/twitch/activate(var/mob/living/carbon/human/mob)
	mob.emote("twitch")



/datum/disease2/effect/headache
	name = "Headache"
	stage = 1
	delay = 25 SECONDS

/datum/disease2/effect/headache/activate(var/mob/living/carbon/human/mob)
	mob.custom_pain("Your head hurts a bit.", 20)



/datum/disease2/effect/itch
	name = "Itches"
	stage = 1
	delay = 25 SECONDS

/datum/disease2/effect/itch/activate(var/mob/living/carbon/human/mob)
	var/obj/O = pick(mob.organs)
	to_chat(mob, ITCH_EFFECT_WARNING(O.name))



/datum/disease2/effect/stomach
	name = "Upset stomach"
	stage = 1
	delay = 25 SECONDS

/datum/disease2/effect/stomach/activate(var/mob/living/carbon/human/mob)
	to_chat(mob, STOMACH_EFFECT_WARNING)



/datum/disease2/effect/nothing
	name = "Nil Syndrome"
	stage = 1
	badness = VIRUS_MILD
	chance_max = 0



/datum/disease2/effect/voice_change
	name = "Voice Changer Syndrome"
	stage = 1
	badness = VIRUS_MILD
	oneshot = 1
	var/special_voice_old

/datum/disease2/effect/voice_change/generate(c_data)
	if(c_data)
		data = c_data

/datum/disease2/effect/voice_change/activate(mob/living/carbon/human/mob)
	if(!data["name"])
		data["name"] = mob.real_name
	to_chat(mob, (SPAN_WARNING("Your throat hurts.")))
	special_voice_old = mob.GetSpecialVoice()
	mob.SetSpecialVoice(data["name"])
	
/datum/disease2/effect/voice_change/deactivate(mob/living/carbon/human/mob)
	if(special_voice_old)
		mob.SetSpecialVoice(special_voice_old)
	else
		mob.UnsetSpecialVoice()

////////////////////////STAGE 2/////////////////////////////////

/datum/disease2/effect/disorientation
	name = "Disorientation"
	stage = 2
	delay = 15 SECONDS

/datum/disease2/effect/disorientation/activate(mob/living/carbon/human/mob)
	to_chat(mob, DISORIENTATION_EFFECT_WARNING)
	if(mob.client)
		var/client/C = mob.client
		if(prob(50))
			C.dir = turn(C.dir, 90)
		else
			C.dir = turn(C.dir, -90)



/datum/disease2/effect/fridge
	name = "Refridgerator Syndrome"
	stage = 2
	chance_max = 25
	delay = 25 SECONDS
/datum/disease2/effect/fridge/activate(var/mob/living/carbon/human/mob)
	mob.emote("shiver")



/datum/disease2/effect/hungry
	name = "Appetiser Effect"
	stage = 2
/datum/disease2/effect/hungry/activate(var/mob/living/carbon/human/mob)
	mob.nutrition = max(0, mob.nutrition - 200)



/datum/disease2/effect/cough
	name = "Anima Syndrome"
	stage = 2
	delay = 25 SECONDS

/datum/disease2/effect/cough/activate(var/mob/living/carbon/human/mob)
	mob.emote("cough")
	if (mob.wear_mask)
		return
	for(var/mob/living/carbon/human/M in oview(2,mob))
		mob.spread_disease_to(M)



/datum/disease2/effect/sleepy
	name = "Resting Syndrome"
	stage = 2
	chance_max = 15
	delay = 35 SECONDS

/datum/disease2/effect/sleepy/activate(var/mob/living/carbon/human/mob)
	mob.emote("collapse")



/datum/disease2/effect/aids
	name = "Space AIDS"
	stage = 2
	delay = 10 SECONDS

/datum/disease2/effect/aids/activate(mob/living/carbon/human/mob)
	mob.immunity -= 2*multiplier

/datum/disease2/effect/aids/change_parent()
	parent_disease.spreadtype = "Contact"
	parent_disease.infectionchance = 110

/datum/disease2/effect/drowsness
	name = "Automated Sleeping Syndrome"
	stage = 2

/datum/disease2/effect/drowsness/activate(var/mob/living/carbon/human/mob)
	if(mob.drowsyness < 35)
		mob.drowsyness += 10



/datum/disease2/effect/flu
	name = "Flu Virion"
	stage = 2
	delay = 25 SECONDS

/datum/disease2/effect/flu/activate(var/mob/living/carbon/human/mob)
	mob.bodytemperature += 5
	if(prob(3))
		to_chat(mob, SPAN_WARNING("Your stomach feels heavy."))
		mob.take_organ_damage((2*multiplier))
	if(prob(10))
		mob.bodytemperature += 10
		to_chat(mob, "<span class='warning'>Your muscles ache.</span>")



/datum/disease2/effect/aggressive
	name = "Uncontrolable Agression"
	stage = 2
	chance_max = 20
	possible_mutations = list(/datum/disease2/effect/pacifism,
							  /datum/disease2/effect/click)

/datum/disease2/effect/aggressive/activate(var/mob/living/carbon/human/mob)
	mob.a_intent = I_HURT
	mob.hud_used.action_intent.icon_state = "intent_harm"


datum/disease2/effect/pacifism
	name = "Pacifist Syndrome"
	stage = 2
	chance_max = 20
	possible_mutations = list(/datum/disease2/effect/aggressive)

datum/disease2/effect/pacifism/activate(var/mob/living/carbon/human/mob)
	mob.a_intent = I_HELP
	mob.hud_used.action_intent.icon_state = "intent_help"

////////////////////////STAGE 3/////////////////////////////////

/datum/disease2/effect/confusion
	name = "Topographical Cretinism"
	stage = 3
	delay = 15 SECONDS

/datum/disease2/effect/confusion/activate(var/mob/living/carbon/human/mob)
	to_chat(mob, CONFUSION_EFFECT_WARNING)
	mob.confused += 10



/datum/disease2/effect/deaf
	name = "Hard of Hearing Syndrome"
	stage = 3

/datum/disease2/effect/deaf/activate(var/mob/living/carbon/human/mob)
	mob.ear_deaf = 5



/datum/disease2/effect/telepathic
	name = "Telepathy Syndrome"
	stage = 3

/datum/disease2/effect/telepathic/activate(var/mob/living/carbon/human/mob)
	mob.dna.SetSEState(GLOB.REMOTETALKBLOCK,1)
	domutcheck(mob, null, MUTCHK_FORCED)



/datum/disease2/effect/shakey
	name = "World Shaking Syndrome"
	stage = 3
	multiplier_max = 3

/datum/disease2/effect/shakey/activate(var/mob/living/carbon/human/mob)
	shake_camera(mob,5*multiplier)

////////////////////////STAGE 4/////////////////////////////////

/datum/disease2/effect/hallucinations
	name = "Disorder of Consciousness"
	stage = 4
	multiplier_max = 10

/datum/disease2/effect/hallucinations/activate(mob/living/carbon/human/mob)
	mob.adjust_hallucination(multiplier, 4*multiplier)
