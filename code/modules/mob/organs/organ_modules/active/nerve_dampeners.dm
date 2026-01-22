/obj/item/organ_module/active/nerve_dampeners
	name = "nerve dampeners"
	icon_state = "emotional_manipulator"
	action_button_name = "Engage nerve dampeners"
	desc = "Each activation of this augment provides a strong painkilling effect for around thirty seconds, but will be followed by a powerful comedown. Excessive short-term use may cause brain damage."
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	origin_tech = list(TECH_DATA = 4, TECH_BIO = 4)
	cooldown = 2 MINUTES
	loadout_cost = 0
	available_in_charsetup = TRUE
	allowed_organs = list(BP_CHEST)
	var/stop_thinking_at

/obj/item/organ_module/active/nerve_dampeners/activate(obj/item/organ/E, mob/living/carbon/human/H)
	if(!istype(H))
		return

	to_chat(H, SPAN_NOTICE("You activate your [name], and feel a wave of numbness wash over you!"))
	H.no_pain = TRUE
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
		var/obj/item/organ/external/head/head = H?.organs_by_name[BP_HEAD]
		if(istype(head))
			for(var/obj/item/organ_module/module in head.organ_modules)
				if(initial(module.module_type) == OM_TYPE_PROCESSOR)
					cpu_name = module.name
					break
		to_chat(usr, SPAN_WARNING("Your [cpu_name] send a signal to nerve dumpeners, but it is not ready to be used again!"))
		return

	activate(O, O?.owner)

/obj/item/organ_module/active/nerve_dampeners/think()
	var/obj/item/organ/external/chest = loc
	var/mob/living/carbon/human/H = chest?.loc
	if(!istype(H))
		set_next_think(0)
		return

	if(world.time >= stop_thinking_at)
		stop_thinking_at = null
		set_next_think(0)
		to_chat(H, SPAN_WARNING("You abruptly feel intensely exhausted as sensation returns."))
		H.no_pain = FALSE
		H.drowsyness = max(H.drowsyness, 15)
		H.confused += 15
		H.slurring = max(H.slurring, 30)
		H.chem_effects[CE_PAINKILLER] = 0
		H.damage_poise(10)
		return

	H.add_chemical_effect(CE_PAINKILLER, 160)
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
