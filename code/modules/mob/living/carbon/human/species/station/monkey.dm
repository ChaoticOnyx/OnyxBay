/datum/species/monkey
	name = "Monkey"
	name_plural = "Monkeys"
	blurb = "Ook."

	icobase = 'icons/mob/human_races/monkeys/r_monkey.dmi'
	deform = 'icons/mob/human_races/monkeys/r_monkey.dmi'
	damage_overlays = 'icons/mob/human_races/masks/dam_monkey.dmi'
	damage_mask = 'icons/mob/human_races/masks/dam_mask_monkey.dmi'
	language = null
	default_language = "Chimpanzee"
	greater_form = SPECIES_HUMAN
	mob_size = MOB_SMALL
	show_ssd = null
	health_hud_intensity = 1.75

	gibbed_anim = "gibbed-m"
	dusted_anim = "dust-m"
	death_message = "lets out a faint chimper as it collapses and stops moving..."
	tail = "chimptail"
	y_shift = -8

	body_builds = list(
		new /datum/body_build/monkey
	)

	unarmed_types = list(/datum/unarmed_attack/bite, /datum/unarmed_attack/claws)
	inherent_verbs = list(/mob/living/proc/ventcrawl)
	hud_type = /datum/hud_data/monkey
	meat_type = /obj/item/reagent_containers/food/meat/monkey

	rarity_value = 0.1
	total_health = 75
	brute_mod = 1.5
	burn_mod = 1.5

	spawn_flags = SPECIES_IS_RESTRICTED | SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN | SPECIES_NO_LACE

	bump_flag = MONKEY
	swap_flags = MONKEY|METROID|SIMPLE_ANIMAL
	push_flags = MONKEY|METROID|SIMPLE_ANIMAL|ALIEN
	species_flags = SPECIES_FLAG_NO_ANTAG_TARGET

	pass_flags = PASS_FLAG_TABLE
	holder_type = /obj/item/holder
	has_limbs = list(
		BP_CHEST =  list("path" = /obj/item/organ/external/chest),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/no_eyes),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right)
		)

	var/list/no_touchie = list(
		/obj/item/mirror,
		/obj/item/paper,
		/obj/item/device/taperecorder,
		/obj/item/modular_computer,
		/obj/item/storage/secure/safe,
		/obj/item/stool,
	)

/datum/species/monkey/handle_npc(mob/living/carbon/human/H)
	if(H.stat != CONSCIOUS)
		return

	if(prob(25) && isturf(H.loc) && !H.pulledby) //won't move if being pulled
		H.SelfMove(pick(GLOB.cardinal))

	if(prob(25))
		H.hand = !(H.hand)

	var/obj/held = H.get_active_hand()
	if(prob(5) && held)
		var/turf/T = get_random_turf_in_range(H, 7, 2)
		if(T && !is_type_in_list(T, no_touchie))
			if(istype(held, /obj/item/gun) && prob(80))
				var/obj/item/gun/G = held
				G.Fire(T, H)
			if(istype(held, /obj/item/reagent_containers) && prob(80))
				var/obj/item/reagent_containers/C = held
				C.attack(H, H)
			if(istype(held, /obj/item/) && prob(50))
				var/obj/item/O = held
				O.attack_self(H)
			else
				H.throw_item(T)
		else
			H.drop_item()
	if(prob(5) && !held && !H.restrained() && istype(H.loc, /turf/))
		var/list/touchables = list()
		for(var/obj/item/O in range(1,get_turf(H)))
			if(O.simulated && O.Adjacent(H) && !is_type_in_list(O, no_touchie) && isturf(O.loc))
				touchables += O
		if(touchables.len)
			var/obj/touchy = pick(touchables)
			touchy.attack_hand(H)

	if(H.buckled && prob(10))
		H.resist()

	if(prob(1))
		H.emote(pick("scratch","jump","roll","tail"))

	if(H.get_shock() && H.shock_stage < 40 && prob(3))
		H.custom_emote("chimpers pitifully")

	if(H.shock_stage > 10 && prob(3))
		H.emote(pick("cry","whimper"))

	if(H.shock_stage >= 40 && prob(3))
		H.emote("scream")

	if(!H.restrained() && H.lying && H.shock_stage >= 60 && prob(3))
		H.custom_emote("thrashes in agony")

/datum/species/monkey/get_random_name()
	return "[lowertext(name)] ([rand(100,999)])"

/datum/species/monkey/handle_post_spawn(mob/living/carbon/human/H)
	..()
	H.item_state = lowertext(name)

/datum/species/monkey/is_eligible_for_antag_spawn(antag_id)
	if(antag_id == MODE_CHANGELING) // For memes sake
		return TRUE
	return FALSE


/datum/species/monkey/tajaran
	name = "Farwa"
	name_plural = "Farwa"
	health_hud_intensity = 2

	icobase = 'icons/mob/human_races/monkeys/r_farwa.dmi'
	deform = 'icons/mob/human_races/monkeys/r_farwa.dmi'

	greater_form = SPECIES_TAJARA
	default_language = "Farwa"
	flesh_color = "#afa59e"
	base_color = "#333333"
	tail = "farwatail"

/datum/species/monkey/skrell
	name = "Neaera"
	name_plural = "Neaera"
	health_hud_intensity = 1.75

	icobase = 'icons/mob/human_races/monkeys/r_neaera.dmi'
	deform = 'icons/mob/human_races/monkeys/r_neaera.dmi'

	greater_form = SPECIES_SKRELL
	default_language = "Neaera"
	flesh_color = "#8cd7a3"
	blood_color = "#1d2cbf"
	reagent_tag = IS_SKRELL
	tail = null

/datum/species/monkey/unathi
	name = "Stok"
	name_plural = "Stok"
	health_hud_intensity = 1.5

	icobase = 'icons/mob/human_races/monkeys/r_stok.dmi'
	deform = 'icons/mob/human_races/monkeys/r_stok.dmi'

	tail = "stoktail"
	greater_form = SPECIES_UNATHI
	default_language = "Stok"
	flesh_color = "#34af10"
	base_color = "#066000"
	reagent_tag = IS_UNATHI
