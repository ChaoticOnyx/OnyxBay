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
	data["color_facial"] = hex2rgb(rand_hex_color())
	data["head"] = pick(GLOB.hair_styles_list)
	data["color_head"] = hex2rgb(rand_hex_color())

/datum/disease2/effect/unified_appearance/activate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.change_facial_hair(data["facial"])
	mob.change_facial_hair_color(data["color_facial"][1], data["color_facial"][2], data["color_facial"][3])
	mob.change_hair(data["head"])
	mob.change_hair_color(data["color_head"][1], data["color_head"][2], data["color_head"][3])
	to_chat(mob, SPAN("warning", "You feel like you look different."))



/datum/disease2/effect/curer
	name = "Cure-All Syndrome"
	stage = 1
	oneshot = 1
	badness = VIRUS_MUTATION
	possible_mutations = list(/datum/disease2/effect/immortal)

/datum/disease2/effect/curer/activate(mob/living/carbon/human/mob)
	if(..())
		return
	to_chat(mob, SPAN("notice", "You feel cured."))
	for(var/ID in mob.virus2)
		var/datum/disease2/disease/D = mob.virus2[ID]
		D.cure()


////////////////////////STAGE 2/////////////////////////////////

/datum/disease2/effect/adaptation_kill
	name = "Psyсhokinetic Connection"
	stage = 2
	badness = VIRUS_MUTATION
	possible_mutations = list(/datum/disease2/effect/adaptation_kill,
							  /datum/disease2/effect/adaptation_damage,
							  /datum/disease2/effect/loyalty)

/datum/disease2/effect/adaptation_kill/generate(c_data)
	if(c_data)
		data = c_data
	else
		data = pick(GLOB.human_mob_list)
	var/mob/living/carbon/human/H = data
	name = "[H.real_name] [initial(name)]"

/datum/disease2/effect/adaptation_kill/change_parent()
	parent_disease.antigen = list()

/datum/disease2/effect/adaptation_kill/activate(mob/living/carbon/human/mob)
	if(..())
		return
	var/mob/living/carbon/human/H = data
	if(locate(H) in GLOB.dead_mob_list_)
		parent_disease.cure()

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

/datum/disease2/effect/dnaspread/activate(mob/living/carbon/human/mob)
	if(..())
		return
	if(!transformed && !host)
		if(!data["name"] || !data["UI"] || !data["SE"])
			data["name"] = mob.real_name
			data["UI"] = mob.dna.UI.Copy()
			host = 1
			return

		original_dna["name"] = mob.real_name
		original_dna["UI"] = mob.dna.UI.Copy()

		to_chat(mob, SPAN("danger", "You don't feel like yourself."))
		var/list/newUI = data["UI"]
		mob.UpdateAppearance(newUI.Copy())
		mob.real_name = data["name"]
		mob.flavor_text = ""
		transformed = 1

/datum/disease2/effect/dnaspread/deactivate(mob/living/carbon/human/mob)
	if(..())
		return
	if(!original_dna["name"] || !original_dna["UI"] || !original_dna["SE"])
		return
	var/list/newUI = original_dna["UI"]
	mob.UpdateAppearance(newUI.Copy())
	mob.real_name = original_dna["name"]

	to_chat(mob, SPAN("notice", "You feel more like yourself."))

////////////////////////STAGE 4/////////////////////////////////

/datum/disease2/effect/monkey
	name = "Two Percent Syndrome"
	stage = 4
	badness = VIRUS_MUTATION
	oneshot = 1

/datum/disease2/effect/monkey/activate(mob/living/carbon/human/mob)
	if(..())
		return
	mob.monkeyize()


/datum/disease2/effect/fluspanish
	name = "Spanish Flu Virion"
	stage = 4
	delay = 25 SECONDS
	badness = VIRUS_MUTATION
	possible_mutations = list(/datum/disease2/effect/cold9,
							  /datum/disease2/effect/flu)

/datum/disease2/effect/fluspanish/activate(mob/living/carbon/human/mob)
	if(..())
		return
	if(mob.reagents.get_reagent_amount(/datum/reagent/leporazine) < 5)
		mob.bodytemperature += 25
		if(prob(15))
			mob.bodytemperature += 35
			to_chat(mob, SPAN("warning", "Your insides burn out."))
			mob.take_organ_damage(4 * multiplier)
		if(prob(10))
			mob.bodytemperature += 40
			to_chat(mob, SPAN("warning", "You're burning in your own skin!"))
