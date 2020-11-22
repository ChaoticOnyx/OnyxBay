#define DISABILITY_GIVE_DELAY 2*60*10
/obj/item/organ/internal/brain
	name = "brain"
	desc = "A piece of juicy meat found in a person's head."
	organ_tag = BP_BRAIN
	parent_organ = BP_HEAD
	vital = 1
	icon_state = "brain2"
	force = 1.0
	w_class = ITEM_SIZE_SMALL
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = list(TECH_BIO = 3)
	attack_verb = list("attacked", "slapped", "whacked")
	relative_size = 60

	var/can_use_mmi = TRUE
	var/mob/living/carbon/brain/brainmob = null
	var/const/damage_threshold_count = 10
	var/damage_threshold_value
	var/healed_threshold = 1

	var/relative_activity = 0

	var/last_disability_give     = 0
	var/last_schizophrenia_attack = 0
	var/schizophrenia_delay       = 0

// in procents
/obj/item/organ/internal/brain/proc/get_activity()
	return max(100 * (1.0-(damage / max_damage)) + relative_activity, 0)

/obj/item/organ/internal/brain/robotize()
	replace_self_with(/obj/item/organ/internal/posibrain)

/obj/item/organ/internal/brain/mechassist()
	replace_self_with(/obj/item/organ/internal/mmi_holder)

/obj/item/organ/internal/brain/getToxLoss()
	return 0

/obj/item/organ/internal/brain/proc/replace_self_with(replace_path)
	var/mob/living/carbon/human/tmp_owner = owner
	qdel(src)
	if(tmp_owner)
		tmp_owner.internal_organs_by_name[organ_tag] = new replace_path(tmp_owner, 1)
		tmp_owner = null

/obj/item/organ/internal/brain/xeno
	name       = "thinkpan"
	desc       = "It looks kind of like an enormous wad of purple bubblegum."
	icon 	   = 'icons/mob/alien.dmi'
	icon_state = "chitin"

/obj/item/organ/internal/brain/robotize()
	. = ..()
	icon_state = "brain-prosthetic"

/obj/item/organ/internal/brain/New(mob/living/carbon/holder)
	..()
	max_damage = species? (species.total_health/2) : 100

	min_bruised_damage = max_damage*0.25
	min_broken_damage  = max_damage*0.75

	damage_threshold_value = round(max_damage / damage_threshold_count)
	spawn(5)
		if(brainmob && brainmob.client)
			brainmob.client.screen.len = null //clear the hud

/obj/item/organ/internal/brain/Destroy()
	QDEL_NULL(brainmob)
	. = ..()

/obj/item/organ/internal/brain/proc/transfer_identity(mob/living/carbon/H)

	if(!brainmob)
		brainmob = new(src)
		brainmob.SetName(H.real_name)
		brainmob.real_name = H.real_name
		brainmob.dna = H.dna.Clone()
		brainmob.timeofhostdeath = H.timeofdeath
		// Copy modifiers.
		for(var/datum/modifier/M in H.modifiers)
			if(M.flags & MODIFIER_GENETIC)
				brainmob.add_modifier(M.type)

	if(H.mind)
		H.mind.transfer_to(brainmob)

	to_chat(brainmob, "<span class='notice'>You feel slightly disoriented. That's normal when you're just \a [initial(src.name)].</span>")
	callHook("debrain", list(brainmob))

/obj/item/organ/internal/brain/examine(mob/user) // -- TLE
	. = ..()
	if(brainmob && brainmob.client)//if thar be a brain inside... the brain.
		. += "\nYou can feel the small spark of life still left in this one."
	else
		. += "\nThis one seems particularly lifeless. Perhaps it will regain some of its luster later.."

/obj/item/organ/internal/brain/removed(mob/living/user)
	if(!istype(owner))
		return ..()

	if(name == initial(name))
		name = "\the [owner.real_name]'s [initial(name)]"

	var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()

	if(borer)
		borer.detatch() //Should remove borer if the brain is removed - RR

	if(vital)
		transfer_identity(owner)

	..()

/obj/item/organ/internal/brain/replaced(mob/living/target)

	if(!..()) return 0

	if(target.key)
		target.ghostize()

	if(brainmob)
		if(brainmob.mind)
			brainmob.mind.transfer_to(target)
		else
			target.key = brainmob.key

	return 1

/obj/item/organ/internal/brain/slime
	name = "slime core"
	desc = "A complex, organic knot of jelly and crystalline particles."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "green slime extract"

/obj/item/organ/internal/brain/golem
	name = "chem"
	desc = "A tightly furled roll of paper, covered with indecipherable runes."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"


/obj/item/organ/internal/brain/proc/get_current_damage_threshold()
	return round(damage / damage_threshold_value)

/obj/item/organ/internal/brain/proc/past_damage_threshold(threshold)
	return (get_current_damage_threshold() > threshold)

/obj/item/organ/internal/brain/Process()
	if(owner)
		if(damage > max_damage / 2 && healed_threshold)
			spawn()
				alert(owner, "You have taken massive brain damage! You will not be able to remember the events leading up to your injury.", "Brain Damaged")
			healed_threshold = 0

		if(damage < (max_damage / 4))
			healed_threshold = 1

		handle_disabilities()
		handle_damage_effects()

		var/stabilizer = 1.25 + (owner.chem_effects[CE_ANTIEPILEPTIC]*3)
		relative_activity -= clamp(get_activity()-100, -stabilizer, stabilizer)

		// Brain damage from low oxygenation or lack of blood.
		if(owner.should_have_organ(BP_HEART))

			// No heart? You are going to have a very bad time. Not 100% lethal because heart transplants should be a thing.
			var/blood_volume = owner.get_blood_oxygenation()

			if(owner.is_asystole()) // Heart is missing or isn't beating and we're not breathing (hardcrit)
				owner.Paralyse(3)
			var/can_heal = damage && damage < max_damage && (damage % damage_threshold_value || owner.chem_effects[CE_BRAIN_REGEN] || (!past_damage_threshold(3) && owner.chem_effects[CE_STABLE]))
			var/damprob
			//Effects of bloodloss
			switch(blood_volume)

				if(BLOOD_VOLUME_SAFE to INFINITY)
					if(can_heal)
						damage--
				if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
					if(prob(1))
						to_chat(owner, SPAN("warning", "You feel a bit [pick("dizzy","woozy","faint")]..."))
					damprob = owner.chem_effects[CE_STABLE] ? 10 : 40
					if(!past_damage_threshold(2) && prob(damprob))
						take_internal_damage(0.5)
						owner.add_brain_activity(-10)
				if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
					owner.eye_blurry = max(owner.eye_blurry, 6)
					damprob = owner.chem_effects[CE_STABLE] ? 30 : 60
					if(!past_damage_threshold(4) && prob(damprob))
						take_internal_damage(0.5)
						owner.add_brain_activity(-10)
					if(!owner.weakened && prob(10))
						owner.Weaken(rand(1,3))
						to_chat(owner, SPAN_WARNING("You feel [pick("dizzy","woozy","faint")]..."))
				if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
					owner.eye_blurry = max(owner.eye_blurry, 6)
					damprob = owner.chem_effects[CE_STABLE] ? 50 : 80
					if(!past_damage_threshold(6) && prob(damprob))
						take_internal_damage(0.5)
						owner.add_brain_activity(-10)
					if(!owner.paralysis && prob(15))
						owner.visible_message("<B>[owner]</B> faints!", \
											  SPAN_WARNING("You feel extremely [pick("dizzy","woozy","faint")]..."))
						if(prob(50))
							owner.Paralyse(3)
						else
							owner.Stun(3)
				if(-(INFINITY) to BLOOD_VOLUME_SURVIVE) // Also see heart.dm, being below this point puts you into cardiac arrest.
					owner.eye_blurry = max(owner.eye_blurry, 6)
					damprob = owner.chem_effects[CE_STABLE] ? 70 : 100
					if(prob(damprob))
						take_internal_damage(1.0)
	..()

/obj/item/organ/internal/brain/proc/handle_disabilities()
	if((owner.disabilities & EPILEPSY) && prob(1))
		relative_activity += 50


	if(damage > 0.70*max_damage && world.time > last_disability_give + DISABILITY_GIVE_DELAY)
		if(prob(15))
			owner.disabilities |= EPILEPSY
		else
			owner.add_random_disease()
		last_disability_give = world.time

/obj/item/organ/internal/brain/proc/handle_damage_effects()
	// From brain damage
	if(prob(1))
		switch(damage/max_damage)
			if(0.1 to 0.3)
				owner.custom_pain("Your feel pain.", 10)
			if(0.3 to 0.5)
				owner.custom_pain("Your feel strong pain.", 25)
			if(0.5 to INFINITY)
				owner.custom_pain("Your feel a lot of pain.", 40)

	if(is_bruised() && prob(1) && owner.eye_blurry <= 0)
		to_chat(owner, SPAN("warning", "It becomes hard to see for some reason."))
		owner.eye_blurry = 10

	if(is_bruised() && prob(1))
		owner.hallucination(15, 15)

	if(damage >= 0.5*max_damage && prob(1) && owner.get_active_hand())
		to_chat(owner, SPAN("danger", "Your hand won't respond properly, and you drop what you are holding!"))
		owner.drop_item()

	if(damage >= 0.6*max_damage)
		owner.slurring = max(owner.slurring, 2)

	if(is_broken())
		if(!owner.lying)
			to_chat(owner, SPAN("warning", "You black out!"))
		owner.Paralyse(10)

	// From brain activity
	if(get_activity() > (owner.disabilities & EPILEPSY ? 150 : 220))
		if(!owner.lying)
			to_chat(owner, SPAN("warning", "You have a seizure!"))
			owner.visible_message(SPAN("danger", "\The [owner] having a seizure!"))
		owner.Paralyse(10)
		owner.make_jittery(100)
		owner.stuttering = max(10, owner.stuttering)
		damage += 1.5
	if(get_activity() <= 10)
		if(!owner.lying)
			to_chat(owner, SPAN("warning", "You black out!"))
		owner.Paralyse(10)

	if(!prob(1))
		return

	switch(get_activity())
		if(160 to INFINITY)
			owner.custom_pain("Your feel a lot of pain.", 40)
		if(140 to 160)
			owner.custom_pain("Your feel strong pain.", 25)
		if(120 to 140)
			owner.custom_pain("Your feel pain.", 10)

		if(80 to 60)
			owner.Weaken(5)
		if(60 to 30)
			to_chat(owner, SPAN("warning", "It becomes hard to see for some reason."))
			owner.eye_blurry = 10
		if(30 to 40)
			owner.Stun(5)
		if(40 to 20)
			if(!owner.get_active_hand())
				return
			to_chat(owner, SPAN("danger", "Your hand won't respond properly, and you drop what you are holding!"))
			owner.drop_item()
		if(20 to 0)
			damage += 2
