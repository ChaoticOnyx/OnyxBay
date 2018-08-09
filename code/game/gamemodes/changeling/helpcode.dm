/mob/living/proc/set_m_intent(var/intent)
	if (intent != "walk" && intent != "run")
		return 0
	m_intent = intent
	if(hud_used)
		if (hud_used.move_intent)
			hud_used.move_intent.icon_state = intent == "walk" ? "walking" : "running"


/obj/item/organ/internal/biostructure/proc/test_damage()
	owner.mind.changeling.damaged = FALSE
	for(var/limb_type in (owner.species.has_limbs | owner.organs_by_name))
		var/obj/item/organ/external/E = owner.organs_by_name[limb_type]
		if((E && E.damage > 0) || !E)
  			owner.mind.changeling.damaged = TRUE
  			break

////////////////No Brain Gen//////////////////////////////////////////////

/obj/item/organ/internal/biostructure
	name = "Strange biostructure"
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
	var/mob/living/carbon/brain/brainchan = null
	var/const/damage_threshold_count = 10
	var/damage_threshold_value
	var/healed_threshold = 1


/obj/item/organ/internal/biostructure/New(var/mob/living/carbon/holder)
	..()
	max_damage = 600
//	if(species)
//		max_damage = species.total_health
	min_bruised_damage = max_damage*0.25
	min_broken_damage = max_damage*0.75

	damage_threshold_value = round(max_damage / damage_threshold_count)
	spawn(5)
		if(brainchan && brainchan.client)
			brainchan.client.screen.len = null //clear the hud



/obj/item/organ/internal/biostructure/Destroy()
	QDEL_NULL(brainchan)
	. = ..()

/obj/item/organ/internal/biostructure/proc/transfer_identity(var/mob/living/carbon/H)
	if(status & ORGAN_DEAD) return

	if(!brainchan)
		brainchan = new(src)
		brainchan.SetName(H.real_name)
		brainchan.real_name = H.real_name
		brainchan.dna = H.dna.Clone()
		brainchan.timeofhostdeath = H.timeofdeath

	if(H.mind)
		H.mind.transfer_to(brainchan)

	to_chat(brainchan, "<span class='notice'>You feel slightly disoriented. That's normal.</span>")
	callHook("debrain", list(brainchan))



/obj/item/organ/internal/biostructure/removed(var/mob/living/user)
	if(!istype(owner))
		return ..()

	if(vital)
		transfer_identity(owner)

	..()

/obj/item/organ/internal/biostructure/replaced(var/mob/living/target)

	if(!..()) return 0

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
	if(owner)
		if(damage > max_damage / 2 && healed_threshold)
			spawn()
				alert(owner, "You have taken massive core damage! You need regeneration.", "Core Damaged")
			healed_threshold = 0
		if(damage <= max_damage / 2 && healed_threshold)
			while(owner && damage > 0 && owner.mind && owner.mind.changeling)
				owner.mind.changeling.chem_charges = max(owner.mind.changeling.chem_charges - 0.5, 0)
				damage--
				sleep(40)
			healed_threshold = 1
		if(owner.mind.changeling.heal)
			test_damage()
			while(owner.mind && owner.mind.changeling && owner.mind.changeling.heal && owner.mind.changeling.damaged)
				owner.mind.changeling.chem_charges = max(owner.mind.changeling.chem_charges - 0.5, 0)
				if(owner.getBruteLoss())
					owner.adjustBruteLoss(-5 * config.organ_regeneration_multiplier)	//Heal brute better than other ouchies.
				if(owner.getFireLoss())
					owner.adjustFireLoss(-2 * config.organ_regeneration_multiplier)
				if(owner.getToxLoss())
					owner.adjustToxLoss(-5 * config.organ_regeneration_multiplier)
					if(prob(5) && !owner.getBruteLoss() && !owner.getFireLoss())
						var/obj/item/organ/external/head/D = owner.organs_by_name["head"]
						if (D.disfigured)
							D.disfigured = 0
				for(var/bpart in shuffle(owner.internal_organs_by_name))
					var/obj/item/organ/internal/regen_organ = owner.internal_organs_by_name[bpart]
					if(regen_organ.robotic >= ORGAN_ROBOT)
						continue
					if(istype(regen_organ))
						if(regen_organ.damage > 0 && !(regen_organ.status & ORGAN_DEAD))
							regen_organ.damage = max(regen_organ.damage - 5, 0)
							if(prob(5))
								to_chat(owner, "<span class='warning'>You feel a soothing sensation as your [regen_organ] mends...</span>")
						if(regen_organ.status & ORGAN_DEAD)
							regen_organ.status &= ~ORGAN_DEAD
				if(prob(2))
					for(var/limb_type in owner.species.has_limbs)
						var/obj/item/organ/external/E = owner.organs_by_name[limb_type]
						if(E && E.organ_tag != BP_HEAD && !E.vital && !E.is_usable())	//Skips heads and vital bits...
							E.removed()//...because no one wants their head to explode to make way for a new one.
							qdel(E)
							E= null
						if(!E)
							var/list/organ_data = owner.species.has_limbs[limb_type]
							var/limb_path = organ_data["path"]
							var/obj/item/organ/external/O = new limb_path(owner)
							organ_data["descriptor"] = O.name
							to_chat(owner, "<span class='danger'>With a shower of fresh blood, a new [O.name] forms.</span>")
							owner.visible_message("<span class='danger'>With a shower of fresh blood, a length of biomass shoots from [owner]'s [O.amputation_point], forming a new [O.name]!</span>")
							var/datum/reagent/blood/B = locate(/datum/reagent/blood) in owner.vessel.reagent_list
							blood_splatter(owner,B,1)
							O.set_dna(owner.dna)
							owner.update_body()
							return
						else
							E.status &= ~ORGAN_ARTERY_CUT
							for(var/datum/wound/W in E.wounds)
								if(W.wound_damage() == 0 && prob(50))
									E.wounds -= W
				sleep(20)
				test_damage()


/obj/item/organ/internal/biostructure/die()
	QDEL_NULL(brainchan)
	owner.mind.changeling.true_dead = 1
	..()

/mob/living/carbon/proc/insert_biostructure()
	src.faction = "biomass"
	var/obj/item/organ/internal/brain/brain = src.internal_organs_by_name[BP_BRAIN]
	var/obj/item/organ/internal/biostructure/bio = src.internal_organs_by_name[BP_CHANG]

	if (brain)
		brain.vital = 0
	if (!bio)
		log_debug("The changeling biostructure appeares in [src.name].", notify_admin = TRUE)
		src.internal_organs_by_name[BP_CHANG] = new /obj/item/organ/internal/biostructure(src)

//////////////////changelling mob///////////////////////////////////////////////////////////


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
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = 0
	maxHealth = 100
	health = 100
	pass_flags = PASS_FLAG_TABLE
	harm_intent_damage = 15
	melee_damage_lower = 20
	melee_damage_upper = 10
	attacktext = "bitten"
	attack_sound = 'sound/weapons/bite.ogg'

	//Space carp aren't affected by atmos.
	min_gas = null
	max_gas = null
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_NOLIGHTING

	minbodytemp = 0
	maxbodytemp = 350
	break_stuff_probability = 15

	faction = "biomass"

/mob/living/simple_animal/hostile/little_changeling/New()
	verbs += /mob/living/proc/ventcrawl
	verbs += /mob/living/proc/hide
	..()

/mob/living/simple_animal/hostile/little_changeling/verb/paralyse(mob/living/target as mob in oview())
	set category = "Changeling"
	set name = "Paralyzing bite"
	set desc = "We bite our prey and inject paralyzing saliva into them, making them harmless to us for relatively long period of time."


	if(!sting_can_reach(target, 1))
		to_chat(src, "<span class='warning'>We are too far away.</span>")
		return

	if(!target)	return 0
	to_chat(target,"<span class='danger'>Your muscles begin to painfully tighten.</span>")
	if(target.isSynthetic())
		return
	target.Weaken(20)
	src.visible_message("<span class='warning'>[src] tears a chunk from \the [target]'s flesh!</span>")
	feedback_add_details("changeling_powers","PB")

	if(last_special > world.time)
		src << "<span class='warning'>We must wait a little while before we can use this ability again!</span>"
		return

	last_special = world.time + 100
	return


/mob/living/simple_animal/hostile/little_changeling/verb/Infest(mob/living/target as mob in oview())
	set category = "Changeling"
	set name = "Infest"
	set desc = "We latch onto potential host and merge with their body, taking control over it."

	var/mob/living/carbon/human/T = target
	if(!istype(T))
		to_chat(src, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return

	if(T.species.species_flags & SPECIES_FLAG_NO_SCAN)
		to_chat(src, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return

	if(HUSK in T.mutations)
		to_chat(src, "<span class='warning'>This creature's DNA is ruined beyond useability!</span>")
		return

	if(!sting_can_reach(T, 1))
		to_chat(src, "<span class='warning'>We are too far away.</span>")
		return

	if(src.mind.changeling.isabsorbing)
		to_chat(src, "<span class='warning'>We are already infesting!</span>")
		return
	src.mind.changeling.isabsorbing = 1
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				to_chat(src, "<span class='notice'>We bind our tegument to our prey.</span>")
				src.visible_message("<span class='warning'>[src]  merged their tegument with [target]</span>")
			if(2)
				to_chat(src, "<span class='notice'>We grow inwards.</span>")
				src.visible_message("<span class='warning'>[src] grown their appendages into [target]</span>")
				T.getBruteLoss(10)
			if(3)
				to_chat(src, "<span class='notice'> We merge with our prey.</span>")
				src.visible_message("<span class='danger'>[src]  dissolved in [target] and merged with them completely! Oh God!</span>")
				to_chat(T, "<span class='danger'>You feel a sharp stabbing pain!</span>")
				T.getBruteLoss(15)

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(src, T, 150))
			to_chat(src, "<span class='warning'>Our infestion of [target] has been interrupted!</span>")
			src.mind.changeling.isabsorbing = 0
			T.getBruteLoss(39)
			return
	if(src.mind)
		src.mind.transfer_to(target)
	else
		target.key = src.key
	target.forceMove(get_turf(src))
	qdel(src)
	target.make_changeling()
	to_chat(src, "<span class='notice'>We have infested [target]!</span>")
	src.mind.changeling.isabsorbing = 0
	return

/mob/living/simple_animal/hostile/little_changeling/Allow_Spacemove(var/check_drift = 0)
	return 0	//No drifting in space for space carp!	//original comments do not steal

/mob/living/simple_animal/hostile/little_changeling/FindTarget()
	. = ..()
	if(.)
		custom_emote(1,"nashes at [.]")

/mob/living/simple_animal/hostile/little_changeling/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(15))
			L.Weaken(3)
			L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")


/mob/living/simple_animal/hostile/little_changeling/arm_chan
	maxHealth = 50
	health = 50
	name = "Arm"
	icon_state = "gib_arm"
	icon_living = "gib_arm"
/mob/living/simple_animal/hostile/little_changeling/head_chan
	maxHealth = 50
	health = 50
	name = "Head"
	icon_state = "gib_head"
	icon_living = "gib_head"
/mob/living/simple_animal/hostile/little_changeling/chest_chan
	maxHealth = 200
	health = 200
	name = "Chest"
	icon_state = "gib_torso"
	icon_living = "gib_torso"
/mob/living/simple_animal/hostile/little_changeling/leg_chan
	maxHealth = 50
	health = 50
	name = "Leg"
	icon_state = "gib_leg"
	icon_living = "gib_leg"