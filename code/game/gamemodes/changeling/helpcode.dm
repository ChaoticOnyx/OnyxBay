
////////////////No Brain Gen//////////////////////////////////////////////
/obj/item/organ/internal/biostructure/proc/check_damage()
	if(owner)
		if (owner.has_damaged_organ())
			owner.mind.changeling.damaged = TRUE
		else
			owner.mind.changeling.damaged = FALSE
	else
		if(brainchan)
			brainchan.mind.changeling.damaged = FALSE

// Using in: /mob/living/carbon/human/proc/changeling_rapidregen()
/datum/rapidregen
	var/heals = 10
	var/mob/living/carbon/human/H = null
	var/datum/changeling/C = null

/datum/rapidregen/New(mob/_M)
	H = _M
	C = _M.mind.changeling
	START_PROCESSING(SSprocessing, src)

/datum/rapidregen/Destroy()
	H = null
	C = null
	return ..()

/datum/rapidregen/Process()
	if(QDELETED(H))
		qdel(src)
		return
	if(heals)
		H.adjustBruteLoss(-5)
		H.adjustToxLoss(-5)
		H.adjustOxyLoss(-5)
		H.adjustFireLoss(-5)
		--heals
	else
		C?.rapidregen_active = FALSE
		qdel(src)

/datum/reagent/toxin/cyanide/change_toxin //Fast and Lethal
	name = "Changeling reagent"
	description = "A highly toxic chemical extracted from strange alien-looking biostructure."
	taste_mult = 0.6
	reagent_state = LIQUID
	color = "#cf3600"
	strength = 30
	metabolism = REM * 0.5
	target_organ = BP_HEART

/datum/reagent/toxin/cyanide/change_toxin/biotoxin //Fast and Lethal
	name = "Strange biotoxin"
	description = "Destroys any biological tissue in seconds."
	taste_mult = 0.6
	reagent_state = LIQUID
	color = "#cf3600"
	strength = 80
	metabolism = REM * 0.5
	target_organ = BP_BRAIN

/datum/reagent/toxin/cyanide/change_toxin/biotoxin/affect_blood(mob/living/carbon/M, alien, removed)
	..()
	var/datum/changeling/changeling = M.mind.changeling
	if(changeling)
		M.mind.changeling.true_dead = 1
		M.mind.changeling.geneticpoints = 0
		M.mind.changeling.chem_storage = 0
		M.mind.changeling.chem_recharge_rate = 0

/datum/reagent/rezadone/change_reviver
	name = "Strange bioliquid"
	description = "Smells like acetone."
	taste_description = "sourness"
	reagent_state = LIQUID
	color = "#cb68fc"
	overdose = 4
	scannable = 1
	metabolism = 0.05
	ingest_met = 0.02
	flags = IGNORE_MOB_SIZE


/datum/reagent/rezadone/change_reviver/affect_blood(mob/living/carbon/M, alien, removed)
	..()
	if(prob(1))
		var/datum/antagonist/changeling/a = new
		a.add_antagonist(M.mind, ignore_role = 1, do_not_equip = 1)


/datum/reagent/rezadone/change_reviver/overdose(mob/living/carbon/M, alien)
	..()
	M.revive()

/datum/chemical_reaction/change_reviver
	name = "Strange bioliquid"
	result = /datum/reagent/rezadone/change_reviver
	required_reagents = list(/datum/reagent/toxin/cyanide/change_toxin = 5, /datum/reagent/dylovene = 5, /datum/reagent/cryoxadone = 5)
	result_amount = 5


/datum/chemical_reaction/Biotoxin
	name = "Strange biotoxin"
	result = /datum/reagent/toxin/cyanide/change_toxin/biotoxin
	required_reagents = list(/datum/reagent/toxin/cyanide/change_toxin = 5, /datum/reagent/toxin/plasma = 5, /datum/reagent/mutagen = 5)
	result_amount = 3


/obj/item/organ/internal/biostructure
	name = "strange biostructure"
	desc = "Strange abhorrent biostructure of unknown origins. Is that an alien organ, a xenoparasite or some sort of space cancer? Is that normal to bear things like that inside you?"
	organ_tag = BP_CHANG
	parent_organ = BP_CHEST
	vital = 1
	icon_state = "Strange_biostructure"
	force = 1.0
	w_class = ITEM_SIZE_SMALL
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = list(TECH_BIO = 10, TECH_ILLEGAL = 5)
	attack_verb = list("attacked", "slapped", "whacked")
	relative_size = 10
	foreign = TRUE
	var/mob/living/carbon/brain/brainchan = null 	//notice me, biostructure-kun~ (✿˵•́ ‸ •̀˵)
	var/const/damage_threshold_count = 10
	var/last_regen_time = 0
	var/damage_threshold_value
	var/healing_threshold = 1
	var/moving = 0

/obj/item/organ/internal/biostructure/New(mob/living/holder)
	..()
	max_damage = 600
	min_bruised_damage = max_damage*0.25
	min_broken_damage = max_damage*0.75


	damage_threshold_value = round(max_damage / damage_threshold_count)

	brainchan = new(src)
	brainchan.container = src

	spawn(5)
		if(brainchan && brainchan.client)
			brainchan.client.screen.len = null //clear the hud
	var/datum/reagent/toxin/cyanide/change_toxin/R = new
	reagents.reagent_list += R
	R.volume = 5

/obj/item/organ/internal/biostructure/Destroy()
	QDEL_NULL(brainchan)
	. = ..()

/obj/item/organ/internal/biostructure/proc/mind_into_biostructure(mob/living/M)
	if(status & ORGAN_DEAD)
		return
	if(M && M.mind && brainchan)
		M.mind.transfer_to(brainchan)
		to_chat(brainchan, "<span class='notice'>You feel slightly disoriented.</span>")

/obj/item/organ/internal/biostructure/removed(mob/living/user)
	if(vital)
		if(owner)
			mind_into_biostructure(owner)
		else if (istype(src.loc,/mob/living))
			mind_into_biostructure(src.loc)

		spawn()
			if(istype(src.loc,/obj/item/organ/external))
				brainchan.verbs += /mob/proc/transform_into_little_changeling
			else
				brainchan.verbs += /mob/proc/aggressive
	..()

/obj/item/organ/internal/biostructure/replaced(mob/living/target)
	if(!..())
		return 0

	if(target.key)
		target.ghostize()

	if(brainchan)
		if(brainchan.mind)
			brainchan.mind.transfer_to(target)
		else
			target.key = brainchan.key

	return 1

/obj/item/organ/internal/biostructure/Process()
	..()
	if(damage > max_damage / 2 && healing_threshold)
		if(owner)
			alert(owner, "We have taken massive core damage! We need regeneration.", "Core Damaged")
		else
			alert(brainchan, "We have taken massive core damage! We need host and regeneration.", "Core Damaged")
		healing_threshold = 0
	else if (damage <= max_damage/2 && !healing_threshold)
		healing_threshold = 1
	if(owner)
		check_damage()
		if(damage <= max_damage / 2 && healing_threshold && world.time < last_regen_time + 40)
			owner.mind.changeling.chem_charges = max(owner.mind.changeling.chem_charges - 0.5, 0)
			damage--
			last_regen_time = world.time

/obj/item/organ/internal/biostructure/die()
	if(brainchan)
		if(brainchan.mind)
			brainchan.mind.changeling.true_dead = 1
		brainchan.death()
	else
		var/mob/host = src.loc
		if (istype(host))
			host.mind.changeling.true_dead = 1
			host.death()
	src.dead_icon = "Strange_biostructure_dead"
	QDEL_NULL(brainchan)

	..()

/obj/item/organ/internal/biostructure/after_organ_creation()
	. = ..()
	change_host(owner)

/obj/item/organ/internal/biostructure/proc/change_host(atom/destination)
	var/atom/source = src.loc
	//deleteing biostructure from external organ so when that organ is deleted biostructure wont be deleted
	if(istype(source, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = source
		var/obj/item/organ/external/E = H.get_organ(parent_organ)
		if(E)
			E.internal_organs -= src
		H.internal_organs_by_name.Remove(BP_CHANG)
		H.internal_organs_by_name -= BP_CHANG
		H.internal_organs_by_name -= null
		H.internal_organs -= src
	else if(istype(source, /obj/item/organ/external))
		var/obj/item/organ/external/E = source
		if(E)
			E.internal_organs -= src

	forceMove(destination)

	//connecting organ
	if(istype(destination, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = destination
		owner = H
		H.internal_organs_by_name[BP_CHANG] = src
		var/obj/item/organ/external/E = H.get_organ(parent_organ)
		if(E)	//wont happen but just in case
			E.internal_organs |= src
			if(E.status & ORGAN_CUT_AWAY)
				E.status &= ~ORGAN_CUT_AWAY
		var/obj/item/organ/internal/brain/brain = H.internal_organs_by_name[BP_BRAIN]
		if(brain)
			brain.vital = 0
	else
		owner = null

/mob/living/proc/insert_biostructure()
	var/obj/item/organ/internal/biostructure/BIO = locate() in src.contents
	if(!BIO)
		BIO = new /obj/item/organ/internal/biostructure(src)
	src.faction = "biomass"
	log_debug("The changeling biostructure appeares in [src.name].")

/mob/living/carbon/insert_biostructure()

	var/obj/item/organ/internal/brain/brain = src.internal_organs_by_name[BP_BRAIN]
	var/obj/item/organ/internal/biostructure/BIO = src.internal_organs_by_name[BP_CHANG]

	if(brain)
		brain.vital = 0
	if(!BIO)
		BIO = new /obj/item/organ/internal/biostructure(src)
		src.internal_organs_by_name[BP_CHANG] = BIO
	else
		src.internal_organs |= BIO
	..()


/mob/living/carbon/proc/move_biostructure()
	var/obj/item/organ/internal/biostructure/BIO = src.internal_organs_by_name[BP_CHANG]
	if(!BIO)
		return
	if(is_regenerating())
		to_chat(src, SPAN_NOTICE("We can't do it right now."))
		return
	if(!BIO.moving)
		var/list/available_limbs = src.organs.Copy()
		for (var/obj/item/organ/external/E in available_limbs)
			if (E.organ_tag == BP_R_HAND || E.organ_tag == BP_L_HAND || E.organ_tag == BP_R_FOOT || E.organ_tag == BP_L_FOOT || E.is_stump())
				available_limbs -= E
		var/obj/item/organ/external/new_parent = input(src, "Where do you want to move [BIO]?") as null|anything in available_limbs

		if(new_parent)
			to_chat(src, "<span class='notice'>We started to move our [BIO] to \the [new_parent].</span>")
			BIO.moving = 1
			var/move_time
			if(src.mind.changeling.recursive_enhancement)
				move_time = rand(20,50)
			else
				move_time = rand(80,150)
			if(do_after(src, move_time, can_move = 1, needhand = 0, incapacitation_flags = 0))
				BIO.moving = 0
				if(src.mind)
					if(istype(src,/mob/living/carbon/human))
						var/mob/living/carbon/human/H = src
						var/obj/item/organ/external/E = H.get_organ(BIO.parent_organ)
						if(!E)
							to_chat(src, "<span class='notice'>You are missing that limb.</span>")
							return
						if(istype(E))
							E.internal_organs -= BIO
						BIO.parent_organ = new_parent.organ_tag
						E = H.get_organ(BIO.parent_organ)
						if(!E)
							CRASH("[src] spawned in [src] without a parent organ: [BIO.parent_organ].")
						E.internal_organs |= BIO
						to_chat(src, "<span class='notice'>Our [BIO] is now in our \the [new_parent].</span>")
						log_debug("([src])The changeling biostructure moved in [new_parent].")


//////////////////changelling mob///////////////////////////////////////////////////////////

/mob/proc/transform_into_little_changeling()
	set category = "Changeling"
	set name = "Transform into little changeling"
	set desc = "If we find ourselves inside a severed limb we will grow little limbs and jaws."

	var/obj/item/organ/internal/biostructure/BIO = src.loc
	var/limb_to_del = BIO.loc
	if (istype(BIO.loc,/obj/item/organ/external/leg))
		var/mob/living/simple_animal/hostile/little_changeling/leg_chan/leg_ling = new (get_turf(BIO.loc))
		changeling_transfer_mind(leg_ling)
	else if (istype(BIO.loc,/obj/item/organ/external/arm))
		var/mob/living/simple_animal/hostile/little_changeling/arm_chan/arm_ling = new (get_turf(BIO.loc))
		changeling_transfer_mind(arm_ling)
	else if (istype(BIO.loc,/obj/item/organ/external/head))
		var/mob/living/simple_animal/hostile/little_changeling/head_chan/head_ling = new (get_turf(BIO.loc))
		changeling_transfer_mind(head_ling)
	else
		return

	BIO.loc.visible_message("<span class='warning'>[BIO.loc] suddenly grows little legs!</span>",
		"<span class='alert'><font size='2'><b>We have just transformed into mobile but vulnerable form! We have to find a new host quickly!</b></font></span>")
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
	var/cloaked = 0
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
	var/obj/item/organ/internal/biostructure/BIO = locate() in src.contents
	if (BIO)
		BIO.removed()
		BIO.forceMove(get_turf(src))
		return
	..()

/mob/living/simple_animal/hostile/little_changeling/Destroy()
	var/obj/item/organ/internal/biostructure/BIO = locate() in src.contents
	if (BIO)
		BIO.removed()
		BIO.forceMove(get_turf(src))
		return
	..()

/mob/living/simple_animal/hostile/little_changeling/verb/prepare_paralyse_sting()
	set category = "Changeling"
	set name = "Paralyzis sting"
	set desc = "We sting our prey and inject paralyzing toxin into them, making them harmless to us for relatively long period of time."

	change_ctate(/datum/click_handler/changeling/little_paralyse)
	return

/mob/living/simple_animal/hostile/little_changeling/proc/paralyse_sting(mob/living/carbon/human/target as mob in oview(1))
	if(src.stat == DEAD)
		to_chat(src, "<span class='warning'>We cannot use this ability. We are dead.</span>")
		return

	if(last_special > world.time)
		to_chat(src, "<span class='warning'>We must wait a little while before we can use this ability again!</span>")
		return

	if(!target)
		return FALSE

	if(!istype(target))
		to_chat(src, "<span class='warning'>[target] is not human. How should we sting that thing?!</span>")
		return

	if(target.isSynthetic())
		to_chat(src, "<span class='warning'>[target] is not an biological organism, we can't paralyse them.</span>")
		return

	if(!sting_can_reach(target, 1))
		to_chat(src, "<span class='warning'>We are too far away.</span>")
		return

	// Part not exposed for sting flags
	var/head = FALSE
	var/face = FALSE
	var/eyes = FALSE
	var/chest = FALSE
	var/groin = FALSE
	var/arms = FALSE
	var/hands = FALSE
	var/legs = FALSE
	var/feet = FALSE

	// TODO[V] Refactor this one
	for(var/obj/item/clothing/C in list(target.head, target.wear_mask, target.wear_suit, target.w_uniform, target.gloves, target.shoes))
		if(C && (C.body_parts_covered & HEAD) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			head = TRUE
		if(C && (C.body_parts_covered & FACE) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			face = TRUE
		if(C && (C.body_parts_covered & EYES) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			eyes = TRUE
		if(C && (C.body_parts_covered & UPPER_TORSO) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			chest = TRUE
		if(C && (C.body_parts_covered & LOWER_TORSO) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			groin = TRUE
		if(C && (C.body_parts_covered & ARMS) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			arms = TRUE
		if(C && (C.body_parts_covered & HANDS) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			hands = TRUE
		if(C && (C.body_parts_covered & LEGS) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			legs = TRUE
		if(C && (C.body_parts_covered & FEET) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			feet = TRUE

	if(head && face && eyes && chest && groin && arms && hands && legs && feet)
		to_chat(src, "<span class='warning'>[target]'s armor has protected them from our stinger.</span>")
		return

	to_chat(target,"<span class='danger'>Your muscles begin to painfully tighten.</span>")
	target.Weaken(20)
	target.Stun(20)
	src.visible_message("<span class='warning'>[src] has grown out a huge abominable stinger and pierced \the [target] with it!</span>")
	feedback_add_details("changeling_powers","PB")

	last_special = world.time + 15 SECONDS
	return

/mob/living/simple_animal/hostile/little_changeling/verb/prepare_infest()
	set category = "Changeling"
	set name = "Infest"
	set desc = "We latch onto potential host and merge with their body, taking control over it."

	change_ctate(/datum/click_handler/changeling/infest)
	return

/mob/living/simple_animal/hostile/little_changeling/proc/infest(mob/living/carbon/human/target as mob in oview(1))
	var/datum/changeling/changeling = src.mind.changeling
	if(!changeling)
		return

	if(src.stat == DEAD)
		to_chat(src, "<span class='warning'>We cannot use this ability. We are dead.</span>")
		return

	if(src.cloaked == 1)
		to_chat(src, "<span class='warning'>We can't infest while mimicking enviroment.</span>")
		return

	if(!sting_can_reach(target, 1))
		to_chat(src, "<span class='warning'>We are too far away.</span>")
		return

	if(!istype(target))
		to_chat(src, "<span class='warning'>[target] is not compatible with our biology.</span>")
		return

	if(target.species.species_flags & SPECIES_FLAG_NO_SCAN)
		to_chat(src, "<span class='warning'>[target] is not compatible with our biology.</span>")
		return

	if(MUTATION_HUSK in target.mutations)
		to_chat(src, "<span class='warning'>This creature's DNA is ruined beyond useability!</span>")
		return

	if(changeling.isabsorbing)
		to_chat(src, "<span class='warning'>We are already infesting!</span>")
		return

	if(target.stat != DEAD && !target.is_asystole() && !target.incapacitated() && !target.sleeping && !target.weakened && !target.stunned && !target.paralysis && !target.restrained())
		to_chat(src, "<span class='warning'>We need our victim to be paralysed, dead or somehow else incapable of defending themself for us to latch on!</span>")
		return

	// Part not exposed for merge flags
	var/head = FALSE
	var/face = FALSE
	var/eyes = FALSE
	var/chest = FALSE
	var/groin = FALSE
	var/arms = FALSE
	var/hands = FALSE
	var/legs = FALSE
	var/feet = FALSE

	// TODO[V] Refactor this one later
	for(var/obj/item/clothing/C in list(target.head, target.wear_mask, target.wear_suit, target.w_uniform, target.gloves, target.shoes))
		if(C && (C.body_parts_covered & HEAD) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			head = TRUE
		if(C && (C.body_parts_covered & FACE) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			face = TRUE
		if(C && (C.body_parts_covered & EYES) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			eyes = TRUE
		if(C && (C.body_parts_covered & UPPER_TORSO) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			chest = TRUE
		if(C && (C.body_parts_covered & LOWER_TORSO) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			groin = TRUE
		if(C && (C.body_parts_covered & ARMS) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			arms = TRUE
		if(C && (C.body_parts_covered & HANDS) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			hands = TRUE
		if(C && (C.body_parts_covered & LEGS) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			legs = TRUE
		if(C && (C.body_parts_covered & FEET) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			feet = TRUE

	if(head && face && eyes && chest && groin && arms && hands && legs && feet)
		to_chat(src, "<span class='warning'>We can't merge with [target] because they are coated with something impenetrable for us!</span>")
		return

	src.forceMove(target.loc)
	src.visible_message("<span class='danger'>[src] has latched onto \the [target].</span>", \
						"<span class='warning'>We have latched onto \the [target].</span>")

	changeling.isabsorbing = 1
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(2)
				src.visible_message("<span class='warning'>[src] merged their tegument with [target]</span>", \
						"<span class='notice'>We bind our tegument to our prey.</span>")
				target.getBruteLoss(10)
			if(3)
				src.visible_message("<span class='warning'>[src] grown their appendages into [target]</span>", \
						"<span class='notice'>We grow inwards.</span>")
				target.getBruteLoss(15)

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(src, target, 150))
			to_chat(src, "<span class='warning'>Our infestation of [target] has been interrupted!</span>")
			changeling.isabsorbing = 0
			target.getBruteLoss(39)
			return

	src.visible_message("<span class='danger'>[src] dissolved in [target] and merged with them completely!</span>", \
						"<span class='notice'>We merged with our prey.</span>")

	to_chat(target, "<span class='danger'><h3>Your neural network has been overtaken by \the [src]!</h3></span>")
	to_chat(target,"<span class='deadsay'>You have died.</span>")
	changeling.isabsorbing = 0

	if(istype(src,/mob/living/simple_animal/hostile/little_changeling/arm_chan))
		if(!target.has_limb(BP_L_ARM))
			target.restore_limb(BP_L_ARM)
			target.restore_limb(BP_L_HAND)
		else if (!target.has_limb(BP_R_ARM))
			target.restore_limb(BP_R_ARM)
			target.restore_limb(BP_R_HAND)
	else if(istype(src,/mob/living/simple_animal/hostile/little_changeling/leg_chan))
		if(!target.has_limb(BP_L_LEG))
			target.restore_limb(BP_L_LEG)
			target.restore_limb(BP_L_FOOT)
		else if (!target.has_limb(BP_R_LEG))
			target.restore_limb(BP_R_LEG)
			target.restore_limb(BP_R_FOOT)
	else if(istype(src,/mob/living/simple_animal/hostile/little_changeling/head_chan))
		if(!target.has_limb(BP_HEAD))
			target.restore_limb(BP_HEAD)
			target.internal_organs_by_name[BP_BRAIN] = new /obj/item/organ/internal/brain(target)
			target.internal_organs_by_name[BP_EYES] = new /obj/item/organ/internal/eyes(target)

	target.sync_organ_dna()
	target.regenerate_icons()

	var/datum/absorbed_dna/newDNA = new(target.real_name, target.dna, target.species.name, target.languages, target.modifiers, target.flavor_texts)
	absorbDNA(newDNA)

	target.ghostize()
	changeling_transfer_mind(target)

	qdel(src)

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
	if(src.health <= (src.maxHealth - 5))
		src.health += 5

	if(ishuman(L) && prob(3))
		L.Weaken(3)
		L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")

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

/mob/living/simple_animal/hostile/little_changeling/headcrab/verb/Vanish()
	set category = "Changeling"
	set name = "Freeze and vanish"
	set desc = "We smooth and contract our chromatophores, almost vanishing in the air."

	if(src.stat == DEAD)
		to_chat(src, "<span class='warning'>We can't use this ability. We are dead.</span>")
		return

	if(src.mind.changeling.isabsorbing == 1)
		to_chat(src, "<span class='warning'>We can't mimic environment while infesting.</span>")
		return

	if(cloaked == 1)
		cloaked = 0
		update_icon()
		speed = 0
	else
		cloaked = 1
		to_chat(src, "<span class='alert'>We are now mimicking our environment, but we can't move quickly in that state.</span>")
		update_icon()
		speed = 4
		apply_effect(2, STUN, 0)

/mob/living/simple_animal/hostile/little_changeling/headcrab/update_icon()
	if(cloaked == 1)
		alpha = 25
		set_light(0)
		move_to_delay = initial(move_to_delay)
	else
		alpha = 255
		set_light(4)
		move_to_delay = 2
	return

/mob/living/simple_animal/hostile/little_changeling/headcrab/death(gibbed, deathmessage = "went limp and collapsed!", show_dead_message)
	cloaked = 0
	var/obj/item/organ/internal/biostructure/BIO = locate() in src.contents
	if(BIO)
		BIO.die()
	..()
