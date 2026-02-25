#define BRAIN_DAMAGE_THRESHOLD 10

/obj/item/organ/internal/cerebrum/brain
	name = "\improper Brain"
	desc = "A piece of juicy meat found in a person's head."

	food_organ_type = /obj/item/reagent_containers/food/organ/brain

	var/damage_threshold_value
	var/healed_threshold = 1

/obj/item/organ/internal/cerebrum/brain/New(newLoc, mob/living/carbon/holder)
	. = ..()

	max_damage = isnull(holder?.species) ? 100 : species.total_health
	min_bruised_damage = max_damage * 0.25
	min_broken_damage = max_damage * 0.75

	damage_threshold_value = round(max_damage / BRAIN_DAMAGE_THRESHOLD)

/obj/item/organ/internal/cerebrum/brain/update_desc()
	desc = initial(desc)
	if(brainmob?.is_ic_dead())
		desc += SPAN("deadsay", "\nThis one seems particularly lifeless. Perhaps it will regain some of its luster later...")
	else if(brainmob?.ssd_check())
		desc += SPAN("deadsay", "\nYou can feel the small spark of life still left in this one.")

/obj/item/organ/internal/cerebrum/brain/_setup_brainmob(mob/living/brain_self, mob/living/carbon/old_self)
	brain_self.dna = old_self.dna.Clone()
	brain_self.languages = old_self.languages
	for(var/datum/modifier/M in old_self.modifiers)
		if(!(M.flags & MODIFIER_GENETIC))
			continue
		brain_self.add_modifier(M.type)
	return ..()

/obj/item/organ/internal/cerebrum/brain/robotize()
	replace_self_with(/obj/item/organ/internal/cerebrum/posibrain)

/obj/item/organ/internal/cerebrum/brain/mechassist()
	replace_self_with(/obj/item/organ/internal/cerebrum/mmi)

/obj/item/organ/internal/cerebrum/brain/proc/replace_self_with(replace_path)
	var/mob/living/carbon/human/tmp_owner = owner
	qdel(src)
	if(tmp_owner)
		tmp_owner.internal_organs_by_name[organ_tag] = new replace_path(tmp_owner, tmp_owner)
		tmp_owner = null

/obj/item/organ/internal/cerebrum/brain/getToxLoss()
	return 0

/obj/item/organ/internal/cerebrum/brain/proc/get_current_damage_threshold()
	return round(damage / damage_threshold_value)

/obj/item/organ/internal/cerebrum/brain/proc/past_damage_threshold(threshold)
	return (get_current_damage_threshold() > threshold)

/obj/item/organ/internal/cerebrum/brain/think()
	if(isnull(owner))
		return ..()

	if(damage > max_damage / 2 && healed_threshold)
		spawn()
			alert(owner, "You have taken massive brain damage! You will not be able to remember the events leading up to your injury.", "Brain Damaged")
		healed_threshold = 0

	if(damage < (max_damage / 4))
		healed_threshold = 1

	handle_disabilities()
	handle_damage_effects()

	// Brain damage from low oxygenation or lack of blood.
	if(owner.should_have_organ(BP_HEART) && !(isundead(owner)))

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
					heal_damage(1)
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(prob(1))
					to_chat(owner, SPAN("warning", "You feel a bit [pick("dizzy","woozy","faint")]..."))
				damprob = owner.chem_effects[CE_STABLE] ? 10 : 40
				if(!past_damage_threshold(2) && prob(damprob))
					take_internal_damage(0.5)
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				owner.eye_blurry = max(owner.eye_blurry, 6)
				damprob = owner.chem_effects[CE_STABLE] ? 30 : 60
				if(!past_damage_threshold(4) && prob(damprob))
					take_internal_damage(0.5)
				if(!owner.weakened && prob(10))
					owner.Weaken(rand(1,3))
					to_chat(owner, SPAN("warning", "You feel [pick("dizzy","woozy","faint")]..."))
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				owner.eye_blurry = max(owner.eye_blurry, 6)
				damprob = owner.chem_effects[CE_STABLE] ? 50 : 80
				if(!past_damage_threshold(6) && prob(damprob))
					take_internal_damage(0.5)
				if(!owner.paralysis && prob(15))
					owner.visible_message("<B>[owner]</B> faints!", \
											SPAN("warning", "You feel extremely [pick("dizzy","woozy","faint")]..."))
					owner.Paralyse(3,5)
			if(-(INFINITY) to BLOOD_VOLUME_SURVIVE) // Also see heart.dm, being below this point puts you into cardiac arrest.
				owner.eye_blurry = max(owner.eye_blurry, 6)
				damprob = owner.chem_effects[CE_STABLE] ? 70 : 100
				if(prob(damprob))
					take_internal_damage(1.0)

	return ..()

/obj/item/organ/internal/cerebrum/brain/proc/handle_disabilities()
	if(owner.stat)
		return

	if((owner.disabilities & EPILEPSY) && prob(1))
		to_chat(owner, SPAN("warning", "You have a seizure!"))
		owner.visible_message(SPAN("danger", "\The [owner] starts having a seizure!"))
		owner.Paralyse(10)
		owner.make_jittery(1000)
	else if((owner.disabilities & TOURETTES) && prob(10))
		owner.Stun(10)
		switch(rand(1, 3))
			if(1)
				owner.emote("twitch")
			if(2 to 3)
				owner.say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")
		owner.make_jittery(100)
	else if((owner.disabilities & NERVOUS) && prob(10))
		owner.stuttering = max(10, owner.stuttering)

/obj/item/organ/internal/cerebrum/brain/proc/handle_damage_effects()
	if(owner.stat)
		return

	if(damage > 0.1 * max_damage && prob(1))
		owner.custom_pain(SPAN("warning", "Your head feels numb and painful."), 10)

	if(is_bruised() && prob(1) && owner.eye_blurry <= 0)
		to_chat(owner, SPAN("warning", "It becomes hard to see for some reason."))
		owner.eye_blurry = 10

	if(damage >= 0.5 * max_damage && prob(1) && (owner.get_active_hand() || owner.get_inactive_hand()))
		to_chat(owner, SPAN("danger", "Your hand won't respond properly, and you drop what you are holding!"))
		owner.drop_active_hand()
		owner.drop_inactive_hand()

	if(damage >= 0.6 * max_damage)
		owner.slurring = max(owner.slurring, 2)

	if(is_broken())
		if(!owner.lying)
			to_chat(owner, SPAN("danger", "You black out!"))
		owner.Paralyse(10)

/obj/item/organ/internal/cerebrum/brain/xeno
	name = "thinkpan"
	desc = "It looks kind of like an enormous wad of purple bubblegum."
	icon = 'icons/mob/alien.dmi'
	icon_state = "chitin"

/obj/item/organ/internal/cerebrum/brain/metroid
	name = "metroid core"
	desc = "A complex, organic knot of jelly and crystalline particles."
	icon = 'icons/mob/metroids.dmi'
	icon_state = "green metroid extract"

/obj/item/organ/internal/cerebrum/brain/golem
	name = "adamantite brain"
	desc = "What else could be inside the adamantite creature's head?"
	icon = 'icons/obj/materials.dmi'
	icon_state = "adamantine"
