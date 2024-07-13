/obj/item/organ_module/active/nerve_dampeners
	name = "nerve dampeners"
	icon_state = "emotional_manipulator"
	desc = "Each activation of this augment provides a strong painkilling effect for around thirty seconds, but will be followed by a powerful comedown. Excessive short-term use may cause brain damage."
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	origin_tech = list(TECH_DATA = 4, TECH_BIO = 4)
	cooldown = 1 MINUTE
	loadout_cost = 15
	available_in_charsetup = TRUE
	allowed_organs = list(BP_CHEST)
	var/stop_thinking_at

/obj/item/organ_module/active/nerve_dampeners/activate()
	var/obj/item/organ/external/chest = loc
	var/mob/living/carbon/human/H = chest?.loc
	if(!istype(H))
		return

	to_chat(H, SPAN_NOTICE("You activate your [name], and feel a wave of numbness wash over you!"))
	stop_thinking_at = world.time + 30 SECONDS
	set_next_think(world.time + 1 SECOND)
	if(H.drowsyness)
		to_chat(H, SPAN_DANGER("Your body slackens as you lose sensation."))
		if(prob(H.getBrainLoss()))
			to_chat(H, SPAN_DANGER("You slump to the ground and black out."))
			H.Paralyse(10)
		H.adjustBrainLoss(H.drowsyness)

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
		H.drowsyness = max(H.drowsyness, 15)
		H.confused += 15
		H.slurring = max(H.slurring, 30)
		H.chem_effects[CE_PAINKILLER] = 0
		H.damage_poise(10)
		return

	H.add_chemical_effect(CE_PAINKILLER, 160)
	set_next_think(world.time + 2 SECONDS)
