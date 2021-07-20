
/mob/living/carbon/human/proc/has_any_exposed_bodyparts()
	var/p_head  = FALSE
	var/p_face  = FALSE
	var/p_eyes  = FALSE
	var/p_chest = FALSE
	var/p_groin = FALSE
	var/p_arms  = FALSE
	var/p_hands = FALSE
	var/p_legs  = FALSE
	var/p_feet  = FALSE

	for(var/obj/item/clothing/C in list(head, wear_mask, wear_suit, w_uniform, gloves, shoes))
		if(!C)
			continue
		if((C.body_parts_covered & HEAD) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_head = TRUE
		if((C.body_parts_covered & FACE) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_face = TRUE
		if((C.body_parts_covered & EYES) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_eyes = TRUE
		if((C.body_parts_covered & UPPER_TORSO) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_chest = TRUE
		if((C.body_parts_covered & LOWER_TORSO) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_groin = TRUE
		if((C.body_parts_covered & ARMS) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_arms = TRUE
		if((C.body_parts_covered & HANDS) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_hands = TRUE
		if((C.body_parts_covered & LEGS) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_legs = TRUE
		if((C.body_parts_covered & FEET) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			p_feet = TRUE

	return !(p_head && p_face && p_eyes && p_chest && p_groin && p_arms && p_hands && p_legs && p_feet)


/mob/proc/transform_into_little_changeling()
	set category = "Changeling"
	set name = "Transform into little changeling"
	set desc = "If we find ourselves inside a severed limb we will grow little limbs and jaws."

	var/obj/item/organ/internal/biostructure/BIO = loc
	var/limb_to_del = BIO.loc

	if(istype(BIO.loc, /obj/item/organ/external/leg))
		var/mob/living/simple_animal/hostile/little_changeling/leg_chan/leg_ling = new (get_turf(BIO.loc))
		changeling_transfer_mind(leg_ling)

	else if(istype(BIO.loc, /obj/item/organ/external/arm))
		var/mob/living/simple_animal/hostile/little_changeling/arm_chan/arm_ling = new (get_turf(BIO.loc))
		changeling_transfer_mind(arm_ling)

	else if(istype(BIO.loc, /obj/item/organ/external/head))
		var/mob/living/simple_animal/hostile/little_changeling/head_chan/head_ling = new (get_turf(BIO.loc))
		changeling_transfer_mind(head_ling)

	else
		headcrab_runaway() // Because byond doesn't want to update verbs sometimes this engine is a fucking mess
		return

	BIO.loc.visible_message(SPAN("warning", "[BIO.loc] suddenly grows little legs!"), \
							SPAN("changeling", "<font size='2'><b>We have just transformed into mobile but vulnerable form! We have to find a new host quickly!</b></font>"))
	qdel(limb_to_del)


/mob/living/simple_animal/hostile/little_changeling
	name = "biomass"
	desc = "A terrible biomass"
	icon_state = "biomass_2p"
	icon_living = "biomass_2p"
	icon_dead = "gibbed_gib"
	icon_gib = "gibbed_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "touch the"
	response_disarm = "pushes aside the"
	response_harm = "hits the"
	speed = 0
	maxHealth = 50
	health = 50
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/human
	pass_flags = PASS_FLAG_TABLE
	harm_intent_damage = 20
	melee_damage_lower = 7.5
	melee_damage_upper = 12.5
	attacktext = "bitten"
	attack_sound = 'sound/weapons/bite.ogg'
	var/cloaked = FALSE
	universal_understand = 1
	min_gas = null
	max_gas = null
	see_in_dark = 8
	meat_amount = 1
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	mob_size = MOB_SMALL
	can_pull_size = ITEM_SIZE_NORMAL
	can_pull_mobs = MOB_PULL_SAME

	minbodytemp = 0
	maxbodytemp = 350
	break_stuff_probability = 15
	faction = "biomass"


/mob/living/simple_animal/hostile/little_changeling/New()
	verbs += /mob/living/proc/ventcrawl
	verbs += /mob/living/proc/hide
	pixel_z = 6
	..()


/mob/living/simple_animal/hostile/little_changeling/death(gibbed, deathmessage = "has been ripped open!", show_dead_message)
	var/obj/item/organ/internal/biostructure/BIO = locate() in contents
	if(BIO)
		BIO.removed()
		BIO.forceMove(get_turf(src))
		return
	..()


/mob/living/simple_animal/hostile/little_changeling/Destroy()
	var/obj/item/organ/internal/biostructure/BIO = locate() in contents
	if(BIO)
		BIO.removed()
		BIO.forceMove(get_turf(src))
		return
	..()


/mob/living/simple_animal/hostile/little_changeling/verb/prepare_paralyse_sting()
	set category = "Changeling"
	set name = "Paralyzis sting"
	set desc = "We sting our prey and inject paralyzing toxin into them, making them harmless to us for relatively long period of time."

	change_ctate(/datum/click_handler/changeling/little_paralyse)


/mob/living/simple_animal/hostile/little_changeling/proc/paralyse_sting(mob/living/carbon/human/target as mob in oview(1))
	if(stat == DEAD)
		to_chat(src, SPAN("changeling", "We cannot use this ability. We are dead."))
		return

	if(last_special > world.time)
		to_chat(src, SPAN("changeling", "We must wait a little while before we can use this ability again!"))
		return

	if(!target)
		return FALSE

	if(!istype(target))
		to_chat(src, SPAN("changeling", "[target] is not human. How should we sting that thing?!"))
		return

	if(target.isSynthetic())
		to_chat(src, SPAN("changeling", "[target] is not an biological organism, we can't paralyse them."))
		return

	if(!sting_can_reach(target, 1))
		to_chat(src, SPAN("changeling", "We are too far away."))
		return

	if(!target.has_any_exposed_bodyparts())
		to_chat(src, SPAN("changeling", "[target]'s armor has protected them from our stinger."))
		return

	to_chat(target, SPAN("danger", "Your muscles begin to painfully tighten."))
	target.Weaken(20)
	target.Stun(20)
	visible_message(SPAN("danger", "[src] has grown out a huge abominable stinger and pierced \the [target] with it!"))
	feedback_add_details("changeling_powers", "PB")

	last_special = world.time + 15 SECONDS
	return


/mob/living/simple_animal/hostile/little_changeling/verb/prepare_infest()
	set category = "Changeling"
	set name = "Infest"
	set desc = "We latch onto potential host and merge with their body, taking control over it."

	change_ctate(/datum/click_handler/changeling/infest)


/mob/living/simple_animal/hostile/little_changeling/proc/infest(mob/living/carbon/human/target as mob in oview(1))
	var/datum/changeling/changeling = src.mind.changeling
	if(!changeling)
		return

	if(stat == DEAD)
		to_chat(src, SPAN("changeling", "We cannot use this ability. We are dead."))
		return

	if(cloaked)
		to_chat(src, SPAN("changeling", "We can't infest while mimicking enviroment."))
		return

	if(!sting_can_reach(target, 1))
		to_chat(src, SPAN("changeling", "We are too far away."))
		return

	if(!istype(target))
		to_chat(src, SPAN("changeling", "[target] is not compatible with our biology."))
		return

	if(target.species.species_flags & SPECIES_FLAG_NO_SCAN)
		to_chat(src, SPAN("changeling", "[target] is not compatible with our biology."))
		return

	if(MUTATION_HUSK in target.mutations)
		to_chat(src, SPAN("changeling", "This creature's DNA is ruined beyond useability!"))
		return

	if(changeling.isabsorbing)
		to_chat(src, SPAN("changeling", "We are already infesting!"))
		return

	if(target.stat != DEAD && !target.is_asystole() && !target.incapacitated(INCAPACITATION_ALL))
		to_chat(src, SPAN("changeling", "We need our victim to be paralysed, dead or somehow else incapable of defending themself for us to latch on!"))
		return

	if(!target.has_any_exposed_bodyparts())
		to_chat(src, SPAN("changeling", "We can't merge with [target] because they are coated with something impenetrable for us!"))
		return

	forceMove(target.loc)
	visible_message(SPAN("danger", "[src] has latched onto \the [target]."), \
					SPAN("changeling", "We have latched onto \the [target]."))

	changeling.isabsorbing = TRUE
	for(var/stage = 1 to 3)
		switch(stage)
			if(2)
				src.visible_message(SPAN("danger", "[src] merged their tegument with [target]"), \
									SPAN("changeling", "We bind our tegument to our prey."))
				target.getBruteLoss(10)
			if(3)
				src.visible_message(SPAN("danger", "[src] grown their appendages into [target]"), \
									SPAN("changeling", "We grow inwards."))
				target.getBruteLoss(15)

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(src, target, 150))
			to_chat(src, SPAN("changeling", "Our infestation of [target] has been interrupted!"))
			changeling.isabsorbing = FALSE
			target.getBruteLoss(39)
			return

	visible_message(SPAN("danger", "[src] dissolved in [target] and merged with them completely!"), \
					SPAN("notice", "We merged with our prey."))

	to_chat(target, SPAN("danger", "<h3>Your neural network has been overtaken by \the [src]!</h3>"))
	to_chat(target, SPAN("deadsay", "You have died."))
	changeling.isabsorbing = FALSE

	if(istype(src, /mob/living/simple_animal/hostile/little_changeling/arm_chan))
		if(!target.has_limb(BP_L_ARM))
			target.restore_limb(BP_L_ARM)
			target.restore_limb(BP_L_HAND)
		else if(!target.has_limb(BP_R_ARM))
			target.restore_limb(BP_R_ARM)
			target.restore_limb(BP_R_HAND)

	else if(istype(src, /mob/living/simple_animal/hostile/little_changeling/leg_chan))
		if(!target.has_limb(BP_L_LEG))
			target.restore_limb(BP_L_LEG)
			target.restore_limb(BP_L_FOOT)
		else if(!target.has_limb(BP_R_LEG))
			target.restore_limb(BP_R_LEG)
			target.restore_limb(BP_R_FOOT)

	else if(istype(src, /mob/living/simple_animal/hostile/little_changeling/head_chan))
		if(!target.has_limb(BP_HEAD))
			target.restore_limb(BP_HEAD)
			target.internal_organs_by_name[BP_BRAIN] = new /obj/item/organ/internal/brain(target)
			target.internal_organs_by_name[BP_EYES] = new /obj/item/organ/internal/eyes(target)

	target.sync_organ_dna()
	target.regenerate_icons()

	var/datum/absorbed_dna/newDNA = new(target.real_name, target.dna, target.species.name, target.languages, target.modifiers, target.flavor_texts)
	absorbDNA(newDNA)

	target.ghostize()
	if(changeling_transfer_mind(target))
		qdel(src) // So we wait for transfer to end before risking to fuck things up

	return


/mob/living/simple_animal/hostile/little_changeling/FindTarget()
	. = ..()
	if(.)
		custom_emote(1, "nashes at [.]")


/mob/living/simple_animal/hostile/little_changeling/AttackingTarget()
	if(!harm_intent_damage)
		return
	. = ..()
	var/mob/living/L = .
	if(health <= (maxHealth - 5))
		health += 5

	if(ishuman(L) && prob(3))
		L.Weaken(3)
		L.visible_message(SPAN("danger", "\the [src] knocks down \the [L]!"))


///// Subtypes /////
/mob/living/simple_animal/hostile/little_changeling/arm_chan
	maxHealth = 50
	health = 50
	name = "disfigured arm"
	icon_state = "gib_arm"
	icon_living = "gib_arm"

/mob/living/simple_animal/hostile/little_changeling/head_chan
	maxHealth = 70
	health = 70
	melee_damage_lower = 17.5
	melee_damage_upper = 22.5
	name = "disfigured head"
	icon_state = "gib_head"
	icon_living = "gib_head"
	meat_amount = 2

/mob/living/simple_animal/hostile/little_changeling/chest_chan
	maxHealth = 150
	health = 150
	melee_damage_lower = 15.0
	melee_damage_upper = 20.0
	name = "disfigured chest"
	icon_state = "gib_torso"
	icon_living = "gib_torso"
	meat_amount = 3
	mob_size = MOB_MEDIUM
	can_pull_size = ITEM_SIZE_LARGE

/mob/living/simple_animal/hostile/little_changeling/leg_chan
	maxHealth = 60
	health = 60
	name = "disfigured leg"
	icon_state = "gib_leg"
	icon_living = "gib_leg"


///// Headcrabs /////
/mob/living/simple_animal/hostile/little_changeling/headcrab
	maxHealth = 40
	health = 40
	melee_damage_lower = 5.0
	melee_damage_upper = 7.5
	speed = 0
	name = "headcrab"
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"


/mob/living/simple_animal/hostile/little_changeling/headcrab/update_icon()
	if(cloaked)
		alpha = 25
		set_light(0)
		move_to_delay = initial(move_to_delay)
	else
		alpha = 255
		set_light(0.25, 0.1, 3)
		move_to_delay = 2


/mob/living/simple_animal/hostile/little_changeling/headcrab/death(gibbed, deathmessage = "went limp and collapsed!", show_dead_message)
	cloaked = 0
	var/obj/item/organ/internal/biostructure/BIO = locate() in contents
	if(BIO)
		BIO.die()
	..()
	qdel(src) // The headcrab is supposed to be the biostructure itself (but with tiny legs), not a separate entity


/mob/living/simple_animal/hostile/little_changeling/headcrab/verb/Vanish()
	set category = "Changeling"
	set name = "Freeze and vanish"
	set desc = "We smooth and contract our chromatophores, almost vanishing in the air."

	if(stat == DEAD)
		to_chat(src, SPAN("changeling", "We can't use this ability. We are dead."))
		return

	if(mind.changeling.isabsorbing)
		to_chat(src, SPAN("changeling", "We can't mimic environment while infesting."))
		return

	if(cloaked)
		cloaked = FALSE
		to_chat(src, SPAN("changeling", "We stop mimicking the environment, regaining our mobility."))
		update_icon()
		speed = 0
	else
		cloaked = TRUE
		to_chat(src, SPAN("changeling", "We are now mimicking our environment, but we can't move quickly in that state."))
		update_icon()
		speed = 4
		apply_effect(2, STUN, 0)


/mob/proc/headcrab_runaway() // Well fuck I can't decide whether it should belong here or somewhere in /changeling/powers
	set category = "Changeling"
	set name = "Runaway form"
	set desc = "We take our weakest form."

	if(is_regenerating())
		return

	var/mob/living/simple_animal/hostile/little_changeling/headcrab/HC = new (get_turf(src))
	var/obj/item/organ/internal/biostructure/BIO = loc

	BIO.parent_organ = BP_CHEST // So we don't end up inside nonexistent limbs
	changeling_transfer_mind(HC)

	HC.visible_message(SPAN("danger", "[BIO] suddenly grows tiny eyes and reforms it's appendages into legs!"), \
					   SPAN("changeling", "<font size='2'><b>We are in our weakest form! WE HAVE TO SURVIVE!</b></font>"))
