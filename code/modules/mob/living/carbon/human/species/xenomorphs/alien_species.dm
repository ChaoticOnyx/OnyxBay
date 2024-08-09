/datum/species/xenos
	name = SPECIES_XENO
	name_plural = "Xenomorphs"

	has_eyes_icon = FALSE

	default_language = "Xenomorph"
	language = "Hivemind"
	genders = list(NEUTER)
	assisted_langs = list()
	unarmed_types = list(/datum/unarmed_attack/claws/strong/xeno, /datum/unarmed_attack/bite/strong/xeno)
	generic_attack_mod = 4.0
	hud_type = /datum/hud_data/alien
	meat_type = /obj/item/reagent_containers/food/meat/xeno
	rarity_value = 3

	has_fine_manipulation = 0
	siemens_coefficient = 0
	gluttonous = 2

	brute_mod = 0.75  // Hardened carapace.
	burn_mod  = 1.5   // Weak to fire.

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	species_flags =  SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_PAIN | SPECIES_FLAG_NO_SLIP | SPECIES_FLAG_NO_POISON | SPECIES_FLAG_NO_MINOR_CUT | SPECIES_FLAG_NO_EMBED | SPECIES_FLAG_NO_ANTAG_TARGET
	spawn_flags = SPECIES_IS_RESTRICTED | SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN | SPECIES_NO_LACE

	reagent_tag = IS_XENOS

	blood_color = "#05EE05"
	flesh_color = "#282846"
	gibbed_anim = "gibbed-a"
	dusted_anim = "dust-a"
	death_message = "lets out a waning guttural screech, green blood bubbling from its maw."
	death_sound = 'sound/voice/hiss6.ogg'

	speech_sounds = list('sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg')
	speech_chance = 100

	virus_immune = 1

	breath_type = null
	poison_type = null

	vision_flags = SEE_SELF|SEE_MOBS
	darksight_range = 8
	darksight_tint = DARKTINT_GOOD

	has_organ = list(
		O_BRAIN =    /obj/item/organ/internal/cerebrum/brain/xeno,
		O_PLASMA =   /obj/item/organ/internal/xenos/plasmavessel,
		O_HIVE =     /obj/item/organ/internal/xenos/hivenode,
		O_NUTRIENT = /obj/item/organ/internal/diona/nutrients,
		O_GANGLION = /obj/item/organ/internal/xenos/ganglion
		)

	body_builds = list(
		new /datum/body_build/xenomorph
	)

	bump_flag = ALIEN
	swap_flags = ~HEAVY
	push_flags = (~HEAVY) ^ ROBOT

	var/alien_number = 0
	var/caste_name = "creature" // Used to update alien name.
	var/weeds_heal_rate = 10     // Health regen on weeds.
	var/weeds_plasma_rate = 5   // Plasma regen on weeds.

	has_limbs = list(
		BP_CHEST =  list("path" = /obj/item/organ/external/chest/xeno),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin/xeno),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/xeno),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm/xeno),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right/xeno),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg/xeno),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right/xeno),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand/xeno),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right/xeno),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot/xeno),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right/xeno)
		)

	xenomorph_type = null // No larvae spawn from xenomorphs themselves

/datum/species/xenos/can_understand(mob/other)
	if(istype(other,/mob/living/carbon/alien/larva))
		return TRUE
	return FALSE

/datum/species/xenos/hug(mob/living/carbon/human/H,mob/living/target)
	H.visible_message("<span class='notice'>[H] caresses [target] with its scythe-like arm.</span>", \
					"<span class='notice'>I caress [target] with my scythe-like arm.</span>")

/datum/species/xenos/handle_post_spawn(mob/living/carbon/human/H)
	alien_number++ //Keep track of how many aliens we've had so far.
	H.real_name = get_random_name()
	H.SetName(H.real_name)
	H.add_modifier(/datum/modifier/trait/vent_breaker)
	..()
	if(H.mind && !GLOB.xenomorphs.is_antagonist(H.mind))
		GLOB.xenomorphs.add_antagonist(H.mind, 1)

/datum/species/xenos/get_random_name()
	return "alien [caste_name] ([rand(100,999)])"

/datum/species/xenos/handle_environment_special(mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(!T)
		return

	var/datum/gas_mixture/environment = T.return_air()
	if(environment?.gas["plasma"] > 0 || locate(/obj/effect/alien/weeds) in T)
		if(!regenerate(H))
			var/obj/item/organ/internal/xenos/plasmavessel/P = H.internal_organs_by_name[BP_PLASMA]
			P.stored_plasma += weeds_plasma_rate
			P.stored_plasma = min(max(P.stored_plasma, 0), P.max_plasma)
			H.set_nutrition(min(H.nutrition + 5, STOMACH_FULLNESS_HIGH))
	..()

/datum/species/xenos/proc/regenerate(mob/living/carbon/human/H)
	if(H.is_ooc_dead())
		return TRUE // So we neither regenerate nor gain plasma once dead
	var/heal_rate = weeds_heal_rate
	var/mend_prob = 20
	if(!(H.resting || H.lying))
		heal_rate = weeds_heal_rate / 3
		mend_prob = 2

	//first heal damages
	if(H.getBruteLoss() || H.getFireLoss() || H.getOxyLoss() || H.getToxLoss())
		H.adjustBruteLoss(-heal_rate)
		H.adjustFireLoss(-heal_rate)
		H.adjustOxyLoss(-heal_rate)
		H.adjustToxLoss(-heal_rate)
		if(prob(5))
			to_chat(H, "<span class='alium'>I feel a soothing sensation come over me...</span>")
		H.UpdateDamageIcon()
		return TRUE

	//next internal organs
	for(var/obj/item/organ/I in H.internal_organs)
		if(I.damage > 0)
			I.damage = max(I.damage - heal_rate, 0)
			if(mend_prob / 2)
				to_chat(H, "<span class='alium'>I feel a soothing sensation within my [I.parent_organ]...</span>")
			if(!I.damage && (I.status & ORGAN_DEAD))
				to_chat(H, "<span class='alium'>I feel invigorated as my [I] appears to be functioning again!</span>")
				I.status &= ~ORGAN_DEAD
			return TRUE

	//next regrow lost limbs, approx 5 ticks each
	if(prob(mend_prob))
		for(var/limb_type in has_limbs)
			var/obj/item/organ/external/E = H.organs_by_name[limb_type]
			if(E && E.organ_tag != BP_HEAD && !E.vital && !E.is_usable())
				E.removed()
				qdel(E)
				E = null
			if(!E)
				var/list/organ_data = has_limbs[limb_type]
				var/limb_path = organ_data["path"]
				var/obj/item/organ/external/O = new limb_path(H)
				organ_data["descriptor"] = O.name
				H.visible_message(SPAN("warning", "A fresh carapace growth through [H]'s [O.amputation_point], forming a new [O.name]!"))
				O.set_dna(H.dna)
				H.update_body()
				return TRUE
			else
				for(var/datum/wound/W in E.wounds)
					if(W.wound_damage() == 0)
						E.wounds -= W
						return TRUE
	return FALSE

/datum/species/xenos/can_overcome_gravity(mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(!T || istype(T, /turf/space))
		return FALSE
	return TRUE // Claws and stuff

/datum/species/xenos/get_blood_name()
	return "xenoblood"

/datum/species/xenos/handle_vision(mob/living/carbon/human/H)
	. = ..()
	process_xeno_hud(H)
	return TRUE

/datum/species/monkey/is_eligible_for_antag_spawn(antag_id)
	return FALSE

/datum/species/xenos/get_species_runechat_color(mob/living/carbon/human/H)
	return blood_color


// Caste species
/datum/species/xenos/drone
	name = SPECIES_XENO_DRONE
	caste_name = "drone"
	weeds_plasma_rate = 15
	movespeed_modifier = /datum/movespeed_modifier/xenos
	total_health = 100
	tail = "xenos_drone_tail"
	rarity_value = 5
	strength = STR_MEDIUM
	brute_mod = 0.85
	burn_mod  = 1.6
	generic_attack_mod = 3.5

	icobase = 'icons/mob/human_races/xenos/r_xenos_drone.dmi'

	has_organ = list(
		BP_BRAIN =		/obj/item/organ/internal/cerebrum/brain/xeno,
		BP_PLASMA =		/obj/item/organ/internal/xenos/plasmavessel/queen,
		BP_ACID =		/obj/item/organ/internal/xenos/acidgland,
		BP_HIVE =		/obj/item/organ/internal/xenos/hivenode,
		BP_RESIN =		/obj/item/organ/internal/xenos/resinspinner,
		BP_NUTRIENT =	/obj/item/organ/internal/diona/nutrients,
		BP_GANGLION =    /obj/item/organ/internal/xenos/ganglion
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/proc/toggle_darksight,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/plant,
		/mob/living/carbon/human/proc/transfer_plasma,
		/mob/living/carbon/human/proc/evolve,
		/mob/living/carbon/human/proc/resin,
		/mob/living/carbon/human/proc/corrosive_acid
		)

/datum/species/xenos/drone/vile
	name = SPECIES_XENO_DRONE_VILE
	caste_name = "vile drone"
	weeds_plasma_rate = 20
	icobase = 'icons/mob/human_races/xenos/r_xenos_drone_vile.dmi'

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/proc/toggle_darksight,
		/mob/living/carbon/human/proc/toggle_powers,
		/mob/living/carbon/human/proc/toggle_acidspit,
		/mob/living/carbon/human/proc/spit,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/plant,
		/mob/living/carbon/human/proc/transfer_plasma,
		/mob/living/carbon/human/proc/evolve,
		/mob/living/carbon/human/proc/resin,
		/mob/living/carbon/human/proc/corrosive_acid
		)

/datum/species/xenos/hunter
	name = SPECIES_XENO_HUNTER
	weeds_plasma_rate = 5
	caste_name = "hunter"
	movespeed_modifier = /datum/movespeed_modifier/xenos_hunter
	total_health = 125
	tail = "xenos_hunter_tail"
	strength = STR_HIGH
	brute_mod = 0.75
	burn_mod  = 1.5
	generic_attack_mod = 4.5

	icobase = 'icons/mob/human_races/xenos/r_xenos_hunter.dmi'

	has_organ = list(
		BP_BRAIN =    /obj/item/organ/internal/cerebrum/brain/xeno,
		BP_PLASMA =   /obj/item/organ/internal/xenos/plasmavessel/hunter,
		BP_HIVE =     /obj/item/organ/internal/xenos/hivenode,
		BP_NUTRIENT = /obj/item/organ/internal/diona/nutrients,
		BP_GANGLION =  /obj/item/organ/internal/xenos/ganglion
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/proc/toggle_darksight,
		/mob/living/carbon/human/proc/toggle_powers,
		/mob/living/carbon/human/proc/toggle_tackle,
		/mob/living/carbon/human/proc/toggle_leap,
		/mob/living/carbon/human/proc/tackle,
		/mob/living/carbon/human/proc/leap,
		/mob/living/carbon/human/proc/gut,
		/mob/living/carbon/human/proc/psychic_whisper,
		/mob/living/carbon/human/proc/regurgitate
		)

/datum/species/xenos/hunter/feral
	name = SPECIES_XENO_HUNTER_FERAL
	caste_name = "feral hunter"
	unarmed_types = list(/datum/unarmed_attack/claws/strong/xeno/feral, /datum/unarmed_attack/bite/strong/xeno)
	icobase = 'icons/mob/human_races/xenos/r_xenos_hunter_feral.dmi'
	tail = "xenos_hunter_feral_tail"
	movespeed_modifier = /datum/movespeed_modifier/xenos_feral

/datum/species/xenos/sentinel
	name = SPECIES_XENO_SENTINEL
	weeds_plasma_rate = 10
	caste_name = "sentinel"
	movespeed_modifier = /datum/movespeed_modifier/xenos
	total_health = 150
	weeds_heal_rate = 15
	tail = "xenos_sentinel_tail"
	strength = STR_VHIGH
	brute_mod = 0.65
	burn_mod  = 1.4

	push_flags = ~HEAVY

	icobase = 'icons/mob/human_races/xenos/r_xenos_sentinel.dmi'

	has_organ = list(
		BP_BRAIN =    /obj/item/organ/internal/cerebrum/brain/xeno,
		BP_PLASMA =   /obj/item/organ/internal/xenos/plasmavessel/sentinel,
		BP_ACID =     /obj/item/organ/internal/xenos/acidgland,
		BP_HIVE =     /obj/item/organ/internal/xenos/hivenode,
		BP_NUTRIENT = /obj/item/organ/internal/diona/nutrients,
		BP_GANGLION = /obj/item/organ/internal/xenos/ganglion
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/proc/toggle_darksight,
		/mob/living/carbon/human/proc/toggle_powers,
		/mob/living/carbon/human/proc/toggle_tackle,
		/mob/living/carbon/human/proc/toggle_neurotoxin,
		/mob/living/carbon/human/proc/toggle_acidspit,
		/mob/living/carbon/human/proc/tackle,
		/mob/living/carbon/human/proc/spit,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/transfer_plasma,
		/mob/living/carbon/human/proc/corrosive_acid
		)

/datum/species/xenos/sentinel/primal
	name = SPECIES_XENO_SENTINEL_PRIMAL
	caste_name = "primal sentinel"
	weeds_heal_rate = 20
	burn_mod  = 1.3
	icobase = 'icons/mob/human_races/xenos/r_xenos_sentinel_primal.dmi'
	tail = "xenos_sentinel_primal_tail"

/datum/species/xenos/queen

	name = SPECIES_XENO_QUEEN
	total_health = 200
	weeds_heal_rate = 20
	weeds_plasma_rate = 20
	caste_name = "queen"
	movespeed_modifier = /datum/movespeed_modifier/xenos_queen
	tail = "xenos_queen_tail"
	rarity_value = 10
	strength = STR_VHIGH
	brute_mod = 0.5
	burn_mod  = 1.2
	icon_scale = 1.3
	generic_attack_mod = 4.5

	bump_flag = HEAVY
	swap_flags = ALLMOBS
	push_flags = ALLMOBS

	icobase = 'icons/mob/human_races/xenos/r_xenos_queen.dmi'

	unarmed_types = list(/datum/unarmed_attack/claws/strong/xeno/queen, /datum/unarmed_attack/bite/strong/xeno)

	has_organ = list(
		BP_BRAIN =    /obj/item/organ/internal/cerebrum/brain/xeno,
		BP_EGG =      /obj/item/organ/internal/xenos/eggsac,
		BP_PLASMA =   /obj/item/organ/internal/xenos/plasmavessel/queen,
		BP_ACID =     /obj/item/organ/internal/xenos/acidgland,
		BP_HIVE =     /obj/item/organ/internal/xenos/hivenode,
		BP_RESIN =    /obj/item/organ/internal/xenos/resinspinner,
		BP_NUTRIENT = /obj/item/organ/internal/diona/nutrients,
		BP_GANGLION =  /obj/item/organ/internal/xenos/ganglion
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/proc/toggle_darksight,
		/mob/living/carbon/human/proc/toggle_powers,
		/mob/living/carbon/human/proc/toggle_tackle,
		/mob/living/carbon/human/proc/toggle_neurotoxin,
		/mob/living/carbon/human/proc/toggle_acidspit,
		/mob/living/carbon/human/proc/tackle,
		/mob/living/carbon/human/proc/spit,
		/mob/living/carbon/human/proc/gut,
		/mob/living/carbon/human/proc/psychic_whisper,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/lay_egg,
		/mob/living/carbon/human/proc/plant,
		/mob/living/carbon/human/proc/transfer_plasma,
		/mob/living/carbon/human/proc/corrosive_acid,
		/mob/living/carbon/human/proc/resin
		)

/datum/species/xenos/queen/handle_login_special(mob/living/carbon/human/H)
	..()
	// Make sure only one official queen exists at any point.
	if(!alien_queen_exists(1, H))
		H.real_name = "alien queen ([alien_number])"
		H.name = H.real_name
	else
		H.real_name = "alien princess ([alien_number])"
		H.name = H.real_name

/datum/hud_data/alien

	icon = 'icons/hud/mob/screen_alien.dmi'
	has_a_intent =  1
	has_m_intent =  1
	has_warnings =  0
	has_health =    1
	has_pain =		0
	has_hands =     1
	has_drop =      1
	has_throw =     1
	has_resist =    1
	has_pressure =  0
	has_nutrition = 0
	has_bodytemp =  0
	has_internals = 0

	gear = list()
