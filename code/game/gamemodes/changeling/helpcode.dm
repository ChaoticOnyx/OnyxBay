/obj/item/organ/internal/biostructure/proc/check_damage()
	if(owner)
		if (owner.has_damaged_organ())
			owner.mind.changeling.damaged = TRUE
		else
			owner.mind.changeling.damaged = FALSE
	else
		if(brainchan)
			brainchan.mind.changeling.damaged = FALSE
////////////////No Brain Gen//////////////////////////////////////////////

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
	var/mob/living/carbon/brain/brainchan = null 	//notice me, biostructure-kun~ (✿˵•́ ‸ •̀˵)
	var/const/damage_threshold_count = 10
	var/last_regen_time = 0
	var/damage_threshold_value
	var/healing_threshold = 1
	var/moving = 0

/obj/item/organ/internal/biostructure/New(var/mob/living/holder)
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
		brainchan.container = src

	if(H.mind)
		H.mind.transfer_to(brainchan)

	to_chat(brainchan, "<span class='notice'>You feel slightly disoriented.</span>")
	callHook("debrain", list(brainchan))
	
/obj/item/organ/internal/biostructure/removed(var/mob/living/user)
	if(!istype(owner))
		return ..()

	if(vital)
		transfer_identity(owner)

	..()
	spawn()
		if (istype(src.loc,/obj/item/organ/external))
			brainchan.verbs += /mob/proc/transform_into_little_changeling
		else
			brainchan.verbs += /mob/proc/aggressive

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
	if(damage > max_damage / 2 && healing_threshold)
		if (owner)
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
	
/obj/item/organ/internal/biostructure/proc/change_host(atom/destination)
	var/atom/source = src.loc
	//deleteing biostructure from external organ so when that organ is deleted biostructure wont be deleted
	if (istype(source,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = source		
		var/obj/item/organ/external/E = H.get_organ(parent_organ)
		if(E) 
			E.internal_organs -= src
		H.internal_organs_by_name[BP_CHANG] = null
		H.internal_organs_by_name -= BP_CHANG
		H.internal_organs_by_name -= null
		H.internal_organs -= src
	else if (istype(source,/obj/item/organ/external))	
		var/obj/item/organ/external/E = source
		if(E) 
			E.internal_organs -= src

	forceMove(destination)

	//connecting organ
	if(istype(destination,/mob/living/carbon/human))	
		var/mob/living/carbon/human/H = destination	
		owner = H
		H.internal_organs_by_name[BP_CHANG] = src
		var/obj/item/organ/external/E = H.get_organ(parent_organ)
		if(E)	//wont happen but just in case
			E.internal_organs |= src
			if(E.status & ORGAN_CUT_AWAY)
				E.status &= ~ORGAN_CUT_AWAY
		var/obj/item/organ/internal/brain/brain = H.internal_organs_by_name[BP_BRAIN]
		if (brain)
			brain.vital = 0

/mob/living/proc/insert_biostructure()
	var/obj/item/organ/internal/biostructure/BIO = locate() in src.contents
	if (!BIO)
		BIO = new /obj/item/organ/internal/biostructure(src)
	src.faction = "biomass"
	log_debug("The changeling biostructure appeares in [src.name].")

/mob/living/carbon/insert_biostructure()
	
	var/obj/item/organ/internal/brain/brain = src.internal_organs_by_name[BP_BRAIN]
	var/obj/item/organ/internal/biostructure/BIO = src.internal_organs_by_name[BP_CHANG]

	if (brain)
		brain.vital = 0
	if (!BIO)
		BIO = new /obj/item/organ/internal/biostructure(src)
		src.internal_organs_by_name[BP_CHANG] = BIO
	else
		src.internal_organs |= BIO
	..()


/mob/living/carbon/proc/move_biostructure()
	var/obj/item/organ/internal/biostructure/BIO = src.internal_organs_by_name[BP_CHANG]
	if (!BIO)
		return
	if (!BIO.moving)
		var/list/available_limbs = src.organs.Copy()
		for (var/obj/item/organ/external/E in available_limbs)
			if (E.organ_tag == BP_R_HAND || E.organ_tag == BP_L_HAND || E.organ_tag == BP_R_FOOT || E.organ_tag == BP_L_FOOT || E.is_stump())
				available_limbs -= E
		var/obj/item/organ/external/new_parent = input(src, "Where do you want to move [BIO]?") as null|anything in available_limbs
		
		if (new_parent)
			to_chat(src, "<span class='notice'>We started to move our [BIO] to \the [new_parent].</span>")
			BIO.moving = 1
			var/move_time
			if(src.mind.changeling.recursive_enhancement)
				move_time = rand(20,50)
			else
				move_time = rand(80,150)
			if(do_after(src, move_time, can_move = 1, needhand = 0, incapacitation_flags = 0))
				BIO.moving = 0
				if (src.mind)
					if (istype(src,/mob/living/carbon/human))
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
	set desc = "If we find ourselves inside severed limb we grow little legs and jaw."

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
		"<span class='alert'><h1><b>We transformed into mobile form! We have to survive!</b></h1></span>")
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
	pixel_z = 6
	..()

/mob/living/simple_animal/hostile/little_changeling/death(gibbed, deathmessage = "ripped open!", show_dead_message)
	var/obj/item/organ/internal/biostructure/BIO = locate() in src.contents
	if (BIO)
		BIO.removed()
		BIO.forceMove(get_turf(src))
	..()

/mob/living/simple_animal/hostile/little_changeling/Destroy()
	var/obj/item/organ/internal/biostructure/BIO = locate() in src.contents
	if (BIO)
		BIO.removed()
		BIO.forceMove(get_turf(src))
	..()

/mob/living/simple_animal/hostile/little_changeling/verb/paralyse(mob/living/target as mob in oview(1))
	set category = "Changeling"
	set name = "Paralyzing sting"
	set desc = "We sting our prey and inject paralyzing venom into them, making them harmless to us for relatively long period of time."


	if(!sting_can_reach(target, 1))
		to_chat(src, "<span class='warning'>We are too far away.</span>")
		return

	if(!target)	return 0
	
	if(target.isSynthetic())
		return

	to_chat(target,"<span class='danger'>Your muscles begin to painfully tighten.</span>")
	target.Weaken(20)
	src.visible_message("<span class='warning'>[src] pierce \the [target] with it's sting!</span>")
	feedback_add_details("changeling_powers","PB")

	if(last_special > world.time)
		to_chat(src, "<span class='warning'>We must wait a little while before we can use this ability again!</span>")
		return

	last_special = world.time + 100
	return


/mob/living/simple_animal/hostile/little_changeling/verb/Infest(mob/living/target as mob in oview(1))
	set category = "Changeling"
	set name = "Infest"
	set desc = "We latch onto potential host and merge with their body, taking control over it."

	var/mob/living/carbon/human/T = target

	if(!sting_can_reach(T, 1))
		to_chat(src, "<span class='warning'>We are too far away.</span>")
		return

	if(!istype(T))
		to_chat(src, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return

	if(T.species.species_flags & SPECIES_FLAG_NO_SCAN)
		to_chat(src, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return

	if(HUSK in T.mutations)
		to_chat(src, "<span class='warning'>This creature's DNA is ruined beyond useability!</span>")
		return

	if(src.mind.changeling.isabsorbing)
		to_chat(src, "<span class='warning'>We are already infesting!</span>")
		return

	src.visible_message("<span class='danger'>[src] has latched onto \the [T].</span>", \
						"<span class='danger'>We have latched onto \the [T].</span>")
	
	src.mind.changeling.isabsorbing = 1
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(2)
				src.visible_message("<span class='warning'>[src] merged their tegument with [target]</span>", \
						"<span class='notice'>We bind our tegument to our prey.</span>")
				T.getBruteLoss(10)
			if(3)
				src.visible_message("<span class='warning'>[src] grown their appendages into [target]</span>", \
						"<span class='notice'>We grow inwards.</span>")
				T.getBruteLoss(15)

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(src, T, 150))
			to_chat(src, "<span class='warning'>Our infestion of [target] has been interrupted!</span>")
			src.mind.changeling.isabsorbing = 0
			T.getBruteLoss(39)
			return

	src.visible_message("<span class='danger'>[src] dissolved in [target] and merged with them completely!</span>", \
						"<span class='notice'>We merged with our prey.</span>")

	to_chat(T, "<span class='danger'>You feel a sharp stabbing pain!</span>")
	src.mind.changeling.isabsorbing = 0

	if(istype(src,/mob/living/simple_animal/hostile/little_changeling/arm_chan))
		if(!T.has_limb(BP_L_ARM))
			T.restore_limb(BP_L_ARM)
			T.restore_limb(BP_L_HAND)
		else if (!T.has_limb(BP_R_ARM))
			T.restore_limb(BP_R_ARM)
			T.restore_limb(BP_R_HAND)
	else if(istype(src,/mob/living/simple_animal/hostile/little_changeling/leg_chan))
		if(!T.has_limb(BP_L_LEG))
			T.restore_limb(BP_L_LEG)
			T.restore_limb(BP_L_FOOT)
		else if (!T.has_limb(BP_R_LEG))
			T.restore_limb(BP_R_LEG)
			T.restore_limb(BP_R_FOOT)
	else if(istype(src,/mob/living/simple_animal/hostile/little_changeling/head_chan))
		if(!T.has_limb(BP_HEAD))
			T.restore_limb(BP_HEAD)
			T.internal_organs_by_name[BP_BRAIN] = new /obj/item/organ/internal/brain(T)
			T.internal_organs_by_name[BP_EYES] = new/obj/item/organ/internal/eyes(T)

	T.sync_organ_dna()
	T.regenerate_icons()

	var/datum/absorbed_dna/newDNA = new(T.real_name, T.dna, T.species.name, T.languages)
	absorbDNA(newDNA)

	changeling_transfer_mind(T)

	qdel(src)

	return

/mob/living/simple_animal/hostile/little_changeling/Allow_Spacemove(var/check_drift = 0)
	return 0

/mob/living/simple_animal/hostile/little_changeling/FindTarget()
	. = ..()
	if(.)
		custom_emote(1,"nashes at [.]")

/mob/living/simple_animal/hostile/little_changeling/AttackingTarget()
	if (!harm_intent_damage)
		return
	. =..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(15))
			L.Weaken(3)
			L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")


/mob/living/simple_animal/hostile/little_changeling/arm_chan
	maxHealth = 50
	health = 50
	name = "disfigured arm"
	icon_state = "gib_arm"
	icon_living = "gib_arm"
/mob/living/simple_animal/hostile/little_changeling/head_chan
	maxHealth = 50
	health = 50
	name = "disfigured head"
	icon_state = "gib_head"
	icon_living = "gib_head"
/mob/living/simple_animal/hostile/little_changeling/chest_chan
	maxHealth = 200
	health = 200
	name = "disfigured chest"
	icon_state = "gib_torso"
	icon_living = "gib_torso"
/mob/living/simple_animal/hostile/little_changeling/leg_chan
	maxHealth = 50
	health = 50
	name = "disfigured leg"
	icon_state = "gib_leg"
	icon_living = "gib_leg"


/mob/living/simple_animal/hostile/little_changeling/headcrab/death(gibbed, deathmessage = "went limp!", show_dead_message)
	var/obj/item/organ/internal/biostructure/BIO = locate() in src.contents
	if (BIO)
		BIO.die()
	..()

/mob/living/simple_animal/hostile/little_changeling/headcrab
	maxHealth = 15
	health = 15
	harm_intent_damage = 0
	speed = 4
	name = "headcrab"
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"