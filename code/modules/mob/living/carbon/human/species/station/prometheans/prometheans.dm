///The rate at which metroids regenerate their promethean normally
#define PROMETHEAN_REGEN_RATE 1.5
///The rate at which metroids regenerate their promethean when they completely run out of it and start taking damage, usually after having cannibalized all their limbs already
#define PROMETHEAN_REGEN_RATE_EMPTY 2.5
///The blood volume at which metroids begin to start losing nutrition -- so that IV drips can work for blood deficient metroids
#define BLOOD_VOLUME_LOSE_NUTRITION 550
#define BLOOD_LOSE_PER_LIMB 0.05 //we'll lose 5% per limb
/datum/component/promethean
	var/datum/action/innate/regenerate_limbs/regenerate_limbs
	var/obj/item/organ/internal/promethean/metroid_jelly_vessel/metroid_jelly_vessel

/datum/species/promethean
	name =             SPECIES_PROMETHEAN
	name_plural =      "Prometheans"
	blurb =            "What has Science done?"
	show_ssd =         "totally quiescent"
	death_message =    "rapidly loses cohesion, splattering across the ground..."
	knockout_message = "collapses inwards, forming a disordered puddle of goo."
	remains_type = /obj/effect/decal/cleanable/ash
	icobase = 'icons/mob/human_races/prometheans/r_promethean.dmi'

	blood_color = "#05ff9b"
	flesh_color = "#05fffb"
	fixed_skin_tone = -145
	hunger_factor =    DEFAULT_HUNGER_FACTOR //todo
	reagent_tag =      IS_METROID
	bump_flag =        METROID
	swap_flags =       MONKEY|METROID|SIMPLE_ANIMAL
	push_flags =       MONKEY|METROID|SIMPLE_ANIMAL
	species_flags =    SPECIES_FLAG_NO_SCAN | SPECIES_FLAG_NO_SLIP | SPECIES_FLAG_NO_MINOR_CUT | SPECIES_FLAG_NO_BLOOD | SPECIES_NO_LACE
	appearance_flags = HAS_SKIN_COLOR | HAS_SKIN_TONE_NORMAL
	spawn_flags =      SPECIES_IS_RESTRICTED

	has_eyes_icon = FALSE
	breath_type = null
	poison_type = null

	gluttonous =          GLUT_TINY | GLUT_SMALLER | GLUT_ITEM_ANYTHING | GLUT_PROJECTILE_VOMIT
	virus_immune =        1
	blood_volume =        600
	min_age =             1
	max_age =             5
	brute_mod =           0.5
	burn_mod =            2
	oxy_mod =             0
	toxins_mod = 		  -1
	total_health =        120
	siemens_coefficient = -1
	rarity_value =        5
	limbs_are_nonsolid =  TRUE

	unarmed_types = list(/datum/unarmed_attack/metroid_glomp)
	has_organ =     list(
		BP_BRAIN = /obj/item/organ/internal/cerebrum/brain/metroid,
		BP_METROID = /obj/item/organ/internal/promethean/metroid_jelly_vessel // Literaly hate baymed
	) // Metroid core.
	has_limbs = list(
		BP_CHEST =  list("path" = /obj/item/organ/external/chest/unbreakable),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin/unbreakable),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/unbreakable),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm/unbreakable),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right/unbreakable),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg/unbreakable),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right/unbreakable),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand/unbreakable),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right/unbreakable),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot/unbreakable),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right/unbreakable)
		)
	heat_discomfort_strings = list("You feel too warm.")
	cold_discomfort_strings = list("You feel too cool.")

	var/datum/action/innate/regenerate_limbs/regenerate_limbs
	var/datum/modifier/trait/blooddeficiency/blooddeficiency
	inherent_traits = list(
		TRAIT_TOXINLOVER,
		TRAIT_BLOOD_DEFICIENCY
	)
	var/heal_rate = 5 // Temp. Regen per tick.

/datum/species/promethean/handle_post_spawn(mob/living/carbon/human/H)
	..()
	for(var/modifier in H.modifiers)
		if(istype(modifier, /datum/modifier/trait/blooddeficiency))
			blooddeficiency = modifier
	var/datum/component/promethean/promethean_comp = H.AddComponent(/datum/component/promethean)
	promethean_comp.regenerate_limbs = new
	promethean_comp.regenerate_limbs.Grant(H)
	spawn(1)
		H.update_action_buttons()
	promethean_comp.metroid_jelly_vessel = H.internal_organs_by_name[BP_METROID]
	H.dna.mcolor = rand_hex_color()
	H.UpdateAppearance(mutcolor_update=TRUE)

/datum/species/promethean/on_species_loss(mob/living/carbon/human/H)
	var/datum/component/promethean/promethean_comp = H.get_component(/datum/component/promethean)
	promethean_comp.regenerate_limbs.Remove(H)
	qdel(promethean_comp)
	..()


/datum/species/promethean/hug(mob/living/carbon/human/H,mob/living/target)
	var/datum/gender/G = gender_datums[target.gender]
	H.visible_message("<span class='notice'>\The [H] glomps [target] to make [G.him] feel better!</span>", \
					"<span class='notice'>You glomps [target] to make [G.him] feel better!</span>")
	H.apply_stored_shock_to(target)

/datum/species/promethean/handle_death(mob/living/carbon/human/H)
	spawn(1)
		if(H)
			H.gib()

/datum/species/promethean/handle_fall_special(mob/living/carbon/human/H, turf/landing)
	H.visible_message("\The [src] fall down from \the [landing], their body softened the falling!", "You fall down to \the [landing], your body softened the falling.")
	return TRUE

/datum/species/promethean/handle_environment_special(mob/living/carbon/human/H)
	var/obj/item/organ/internal/promethean/metroid_jelly_vessel/jelly_vessel = H.internal_organs_by_name[BP_METROID]
	var/jelly_amount = jelly_vessel.stored_jelly
	var/jelly_volume = round((jelly_amount/blood_volume)*100)
	if(H.stat == DEAD) //can't farm metroid prometheany from a dead metroid/prometheany person indefinitely
		return

	if(!jelly_amount)
		jelly_vessel.add_jelly(PROMETHEAN_REGEN_RATE_EMPTY * 0.1)
		H.adjustBruteLoss(2.5 * 0.1)
		to_chat(H, SPAN_DANGER("You feel empty!"))

	if(jelly_volume < BLOOD_VOLUME_SAFE)
		if(H.nutrition >= STOMACH_FULLNESS_LOW)
			jelly_vessel.add_jelly(PROMETHEAN_REGEN_RATE * 0.1)
			if(jelly_volume <= BLOOD_VOLUME_LOSE_NUTRITION) // don't lose nutrition if we are above a certain threshold, otherwise metroids on IV drips will still lose nutrition
				H.add_nutrition(-1.25 * 0.1)

	// we call lose_blood() here rather than quirk/process() to make sure that the blood loss happens in sync with life()
	if(HAS_TRAIT(H, TRAIT_BLOOD_DEFICIENCY))
		if(jelly_volume>=BLOOD_VOLUME_BAD)
			jelly_vessel.remove_jelly(PROMETHEAN_REGEN_RATE * 0.1)

	if(jelly_volume < BLOOD_VOLUME_OKAY)
		if(prob(1))
			to_chat(H, SPAN_DANGER("You feel drained!"))

	if(jelly_volume < BLOOD_VOLUME_BAD)
		Cannibalize_Body(H)

/datum/species/promethean/proc/Cannibalize_Body(mob/living/carbon/human/H)
	var/obj/item/organ/internal/promethean/metroid_jelly_vessel/jelly_vessel = H.internal_organs_by_name[BP_METROID]
	var/list/missing_limbs
	for(var/limb_type in has_limbs)
		var/obj/item/organ/external/E = H.organs_by_name[limb_type]
		if(!E)
			missing_limbs+=limb_type
	var/list/limbs_to_consume = list(BP_R_ARM, BP_L_ARM, BP_R_LEG, BP_L_LEG) - missing_limbs
	var/obj/item/organ/external/consumed_limb
	if(!length(limbs_to_consume))
		H.losebreath++
		return
	if(H.has_organ(BP_L_LEG)||H.has_organ(BP_R_LEG)) //Legs go before arms
		limbs_to_consume -= list(BP_R_ARM, BP_L_ARM)
	consumed_limb = H.get_organ(pick(limbs_to_consume))
	consumed_limb.droplimb()
	to_chat(H, SPAN_DANGER("Your [consumed_limb] is drawn back into your body, unable to maintain its shape!"))
	qdel(consumed_limb)
	jelly_vessel.add_jelly(20)

/datum/action/innate/regenerate_limbs
	name = "Regenerate Limbs"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "metroidheal"
	button_icon = 'icons/hud/actions.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/regenerate_limbs/Trigger()
	IsAvailable()
	..()

/datum/action/innate/regenerate_limbs/IsAvailable(feedback = FALSE)
	if(!ispromethean(owner))
		src.Remove(owner)
		return FALSE
	return TRUE

/datum/action/innate/regenerate_limbs/Activate()
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = list()
	var/obj/item/organ/internal/promethean/metroid_jelly_vessel/jelly_vessel = H.internal_organs_by_name[BP_METROID]
	var/jelly_amount = jelly_vessel.stored_jelly
	var/jelly_volume = round((jelly_amount/H.species.blood_volume)*100)
	for(var/limb_type in H.species.has_limbs)
		var/obj/item/organ/external/E = H.organs_by_name[limb_type]
		if(!E)
			limbs_to_heal.Add(limb_type)
		else
			if(istype(E, /obj/item/organ/external/stump))
				limbs_to_heal.Add(limb_type)

	if(!length(limbs_to_heal))
		to_chat(H, SPAN_NOTICE("You feel intact enough as it is."))
		return
	to_chat(H, SPAN_NOTICE("You focus intently on your missing [length(limbs_to_heal) >= 2 ? "limbs" : "limb"]..."))
	if(jelly_volume >= 5*length(limbs_to_heal)+BLOOD_VOLUME_OKAY)
		for(var/healed_limb in limbs_to_heal)
			H.rejuvenate(TRUE)
		jelly_vessel.remove_jelly(H.species.blood_volume*BLOOD_LOSE_PER_LIMB*length(limbs_to_heal)) //FIXME fuck baymed with their BLOOD
		to_chat(H, SPAN_NOTICE("...and after a moment you finish reforming!"))
		return
	else if(jelly_volume > BLOOD_VOLUME_BAD)//We can partially heal some limbs
		while(jelly_volume >= BLOOD_VOLUME_BAD+20)
			var/healed_limb = pick(limbs_to_heal)
			H.restore_limb(healed_limb)
			limbs_to_heal -= healed_limb
			jelly_vessel.remove_jelly(H.species.blood_volume*BLOOD_LOSE_PER_LIMB) //FIXME fuck baymed with their BLOOD
		to_chat(H, SPAN_WARNING("...but there is not enough of you to fix everything! You must attain more mass to heal completely!"))
		return
	to_chat(H, SPAN_WARNING("...but there is not enough of you to go around! You must attain more mass to heal!"))


/datum/species/promethean/is_eligible_for_antag_spawn(antag_id)
	if(antag_id == MODE_TRAITOR) // The only role that looks somewhat suitable
		return TRUE
	return FALSE
