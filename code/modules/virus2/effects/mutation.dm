////////////////////////STAGE 1/////////////////////////////////

/datum/disease2/effect/unified_appearance
	name = "Unified Appearance Syndrome"
	stage = 1
	badness = VIRUS_MUTATION
	oneshot = 1
	possible_mutations = list(/datum/disease2/effect/dnaspread,
							  /datum/disease2/effect/beard)
/datum/disease2/effect/unified_appearance/generate(c_data)
	if(c_data)
		data = c_data
		return
	data["facial"] = pick(GLOB.facial_hair_styles_list)
	data["head"] = pick(GLOB.hair_styles_list)

/datum/disease2/effect/unified_appearance/activate(var/mob/living/carbon/human/mob)
	mob.change_facial_hair(data["facial"])
	mob.change_hair(data["head"])
	to_chat(mob, SPAN_WARNING("You feel like you look different."))



/datum/disease2/effect/curer
	name = "Cure-All Syndrome"
	stage = 1
	oneshot = 1
	badness = VIRUS_MUTATION
	possible_mutations = list(/datum/disease2/effect/immortal)

/datum/disease2/effect/curer/activate(mob/living/carbon/human/mob)
	to_chat(mob, SPAN_NOTICE("You feel cured."))
	for(var/ID in mob.virus2)
		var/datum/disease2/disease/D = mob.virus2[ID]
		D.cure(mob)
	

////////////////////////STAGE 2/////////////////////////////////

////////////////////////STAGE 3/////////////////////////////////

/datum/disease2/effect/dnaspread
	name = "Space Retrovirus Syndrome"
	stage = 3
	badness = VIRUS_MUTATION
	possible_mutations = list(/datum/disease2/effect/monkey,
							  /datum/disease2/effect/unified_appearance,
							  /datum/disease2/effect/beard)
	var/list/original_dna = list()
	var/transformed = 0
	var/host = 0

/datum/disease2/effect/dnaspread/generate(c_data)
	if(c_data)
		data = c_data

/datum/disease2/effect/dnaspread/activate(var/mob/living/carbon/human/mob)
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

/datum/disease2/effect/dnaspread/deactivate(var/mob/living/carbon/human/mob)
	if ((!original_dna["name"]) && (!original_dna["UI"]) && (!original_dna["SE"]))
		var/list/newUI=original_dna["UI"]
		var/list/newSE=original_dna["SE"]
		mob.UpdateAppearance(newUI.Copy())
		mob.dna.SE = newSE.Copy()
		mob.dna.UpdateSE()
		mob.real_name = original_dna["name"]

		to_chat(mob, "<span class='notice'>You feel more like yourself.</span>")

////////////////////////STAGE 4/////////////////////////////////

/datum/disease2/effect/monkey
	name = "Two Percent Syndrome"
	stage = 4
	badness = VIRUS_MUTATION

/datum/disease2/effect/monkey/activate(var/mob/living/carbon/human/mob)
	mob.monkeyize()



/datum/disease2/effect/fluspanish
	name = "Spanish Flu Virion"
	stage = 4
	delay = 25 SECONDS
	badness = VIRUS_MUTATION
	possible_mutations = list(/datum/disease2/effect/cold9,
							  /datum/disease2/effect/flu)

/datum/disease2/effect/fluspanish/activate(var/mob/living/carbon/human/mob)
	if(mob.reagents.get_reagent_amount(/datum/reagent/leporazine) < 5)
		mob.bodytemperature += 25
		if(prob(15))
			mob.bodytemperature += 35
			to_chat(mob, "<span class='warning'>Your insides burn out.</span>")
			mob.take_organ_damage((4*multiplier))
		if(prob(10))
			mob.bodytemperature += 40
			to_chat(mob, "<span class='warning'>You're burning in your own skin!</span>")

