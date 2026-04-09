/obj/item/organ_module/active/nerve_dampeners
	name = "nerve dampeners"
	icon_state = "emotional_manipulator"
	action_button_name = "Engage nerve dampeners"
	desc = "Each activation of this augment provides a strong painkilling effect for around thirty seconds, but will be followed by a powerful comedown. Excessive short-term use may cause brain damage."
	module_flags = OM_FLAG_SCANNABLE | OM_FLAG_BIOLOGICAL
	origin_tech = list(TECH_BIO = 6, TECH_COMBAT = 7)
	cooldown = 2 MINUTES
	loadout_cost = 0
	available_in_charsetup = TRUE
	allowed_organs = list(BP_CHEST)
	allowed_roles = list(/datum/job/hos, /datum/job/warden, /datum/job/officer, /datum/job/paramedic, /datum/job/captain, /datum/job/mining)
	cpu_load = 1
	augment_cost = 7
	w_class = 1
	matter = list(
		MATERIAL_PLASTIC = 4000,
		MATERIAL_SILVER = 8000
	)
	var/stop_thinking_at
	var/pain_disabled = FALSE

/obj/item/organ_module/active/nerve_dampeners/activate(obj/item/organ/E, mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(H.isSynthetic())
		to_chat(H, SPAN_NOTICE("You feel no effect from [name]."))
		return

	to_chat(H, SPAN_NOTICE("You activate your [name], and feel a wave of numbness wash over you!"))
	sound_to(H, sound('sound/effects/nerve_dampeners_on.ogg', volume = 50))
	H.visible_message(SPAN_NOTICE("[H] twitches and loses tension in muscles!"), null, H)
	if(!H.no_pain)
		H.no_pain = TRUE
		pain_disabled = TRUE

	stop_thinking_at = world.time + 30 SECONDS
	set_next_think(world.time + 1 SECOND)
	var/brain_loss = H.getBrainLoss()
	if(brain_loss > 0 && prob(brain_loss))
		to_chat(H, SPAN_DANGER("You slump to the ground and black out."))
		H.Paralyse(10)
	if(H.drowsyness)
		to_chat(H, SPAN_DANGER("Your body slackens as you lose sensation."))
		H.adjustBrainLoss(H.drowsyness)

/obj/item/organ_module/active/nerve_dampeners/ui_action_click()
	var/obj/item/organ/O = loc
	if(!istype(O))
		return

	if(!can_activate(O, usr))
		return

	THROTTLE(activate_cd, cooldown)
	if(!activate_cd)
		var/cpu_name = "CPU"
		var/mob/living/carbon/human/H = O?.owner
		var/obj/item/organ/external/head/head = H?.external_organs_by_name[BP_HEAD]
		if(istype(head))
			for(var/obj/item/organ_module/module in head.organ_modules)
				if(initial(module.module_type) == OM_TYPE_PROCESSOR)
					cpu_name = module.name
					break
		to_chat(usr, SPAN_WARNING("Your [cpu_name] sends a signal to nerve dampeners, but it is not ready to be used again!"))
		return

	activate(O, O?.owner)

/obj/item/organ_module/active/nerve_dampeners/think()
	var/obj/item/organ/external/chest = loc
	var/mob/living/carbon/human/H = chest?.loc
	if(!istype(H))
		set_next_think(0)
		return

	if(!stop_thinking_at)
		set_next_think(0)
		return

	if(world.time >= stop_thinking_at)
		stop_thinking_at = null
		set_next_think(0)
		sound_to(H, sound('sound/effects/nerve_dampeners_off.ogg', volume = 50))
		to_chat(H, SPAN_WARNING("You abruptly feel intensely exhausted as sensation returns."))
		if(H.getHalLoss() > 0)
			H.emote("scream_long")
		if(pain_disabled)
			H.no_pain = FALSE
			pain_disabled = FALSE
		H.drowsyness = max(H.drowsyness, 15)
		H.confused += 15
		H.slurring = max(H.slurring, 30)
		H.damage_poise(10)
		return

	set_next_think(world.time + 2 SECONDS)

/obj/item/organ_module/active/nerve_dampeners/emp_act(severity)
	. = ..()

	var/obj/item/organ/O = loc
	var/mob/living/carbon/human/H = O?.owner
	if(!istype(H))
		return

	var/chance = 10 * (4 - severity)
	if(!prob(chance))
		return

	H.adjustBrainLoss(rand(0, 10))
	H.custom_pain("Your nerves flare with agony!", 60)

/obj/item/organ_module/active/nerve_dampeners/deactivate(obj/item/organ/E, mob/living/carbon/human/H)
	if(stop_thinking_at)
		stop_thinking_at = null
		set_next_think(0)
		if(istype(H) && pain_disabled)
			H.no_pain = FALSE
			pain_disabled = FALSE

/obj/item/organ_module/active/nerve_dampeners/is_cpu_active(mob/living/carbon/human/H)
	return stop_thinking_at && world.time < stop_thinking_at

/obj/item/organ_module/active/nerve_dampeners/can_install_in(obj/item/organ/affected, mob/user)
	if(!..())
		return FALSE
	if(affected?.owner?.isSynthetic())
		if(user)
			to_chat(user, SPAN_NOTICE("You cannot install [name] into synthetic bodies."))
		return FALSE
	return TRUE
