/obj/item/organ_module/actuators
	name = "Organ actuator"
	icon_state = "ams"
	desc = "A mechanic actuator, used to connect augmentations from organic limbs to CPU. Without it - nithing will work, nor hand, nor augmentation."
	allowed_organs = list(BP_L_ARM, BP_R_ARM, BP_L_HAND, BP_R_HAND)
	module_type = OM_TYPE_ACTUATOR
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	origin_tech = list(TECH_ENGINEERING = 2, TECH_MAGNET = 2)
	matter = list(
		MATERIAL_PLASTIC = 2000,
		MATERIAL_STEEL = 2000,
		MATERIAL_GLASS = 2000
	)
	cpu_load = 0
	loadout_cost = 0
	available_in_charsetup = TRUE
	augment_cost = 1

/obj/item/organ_module/processor
	name = "CPU"
	icon_state = "cpu"
	desc = "Standard processor for prosthetic devices."
	allowed_organs = list(BP_HEAD)
	module_type = OM_TYPE_PROCESSOR
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	cpu_power = 2
	cpu_load = 0
	loadout_cost = 0
	available_in_charsetup = TRUE
	augment_cost = 0
	w_class = 1
	origin_tech = list(TECH_BIO = 1, TECH_DATA = 1)
	matter = list(
		MATERIAL_GOLD = 50,
		MATERIAL_PLASTEEL = 1000,
		MATERIAL_PLASTIC = 1000
	)

/obj/item/organ_module/processor/post_install(obj/item/organ/E)
	. = ..()
	var/mob/living/carbon/human/H = E?.owner
	if(!istype(H))
		return
	for(var/obj/item/organ/external/O in H.external_organs)
		for(var/obj/item/organ_module/active/A in O.organ_modules)
			if(A.organ_action)
				A.organ_action.Grant(H)
	for(var/obj/item/organ/internal/I in H.internal_organs)
		for(var/obj/item/organ_module/active/A in I.organ_modules)
			if(A.organ_action)
				A.organ_action.Grant(H)

/obj/item/organ_module/processor/post_removed(obj/item/organ/E)
	. = ..()
	var/mob/living/carbon/human/H = E?.owner
	if(!istype(H))
		return
	for(var/obj/item/organ/external/O in H.external_organs)
		for(var/obj/item/organ_module/active/A in O.organ_modules)
			if(A.organ_action)
				A.organ_action.Remove(H)
	for(var/obj/item/organ/internal/I in H.internal_organs)
		for(var/obj/item/organ_module/active/A in I.organ_modules)
			if(A.organ_action)
				A.organ_action.Remove(H)

/obj/item/organ_module/processor/has_duplicate_in(obj/item/organ/E)
	for(var/obj/item/organ_module/module in E.organ_modules)
		if(module == src)
			continue
		if(initial(module.module_type) == OM_TYPE_PROCESSOR)
			return TRUE
	return FALSE

/obj/item/organ_module/processor/advanced
	name = "Biotech Sigma CPU"
	icon_state = "cpu_adv"
	desc = "Advanced CPU capable of supporting a large number of prosthetic modules."
	cpu_power = 4
	loadout_cost = 0
	available_in_charsetup = TRUE
	augment_cost = 5
	origin_tech = list(TECH_BIO = 3, TECH_DATA = 3)
	matter = list(
		MATERIAL_GOLD = 150,
		MATERIAL_PLASTEEL = 3000,
		MATERIAL_PLASTIC = 3000,
		MATERIAL_GLASS = 1000
	)

/obj/item/organ_module/processor/super
	name = "Raven Microcyber MK.3"
	icon_state = "cpu_super"
	desc = "Produced by Raven Biotech corporation, this CPU is considered to be one of the most advanced processors for prosthetics."
	cpu_power = 6
	loadout_cost = 0
	available_in_charsetup = TRUE
	augment_cost = 8
	origin_tech = list(TECH_BIO = 6, TECH_DATA = 6, TECH_BLUESPACE = 6)
	matter = list(
		MATERIAL_GOLD = 150,
		MATERIAL_PLASTEEL = 3000,
		MATERIAL_PLASTIC = 3000,
		MATERIAL_GLASS = 1000,
		MATERIAL_DIAMOND = 1500
	)

/obj/item/organ_module/processor/emp_act(severity)
	. = ..()

	var/obj/item/organ/O = loc
	var/mob/living/carbon/human/H = O?.owner
	if(!istype(H))
		return

	var/chance = 10 * (4 - severity)
	if(!prob(chance))
		return

	var/list/effects = list("brain", "confuse", "slur", "intent", "click")
	var/list/picked = list(pick(effects))
	if(prob(chance / 2))
		var/extra = pick(effects - picked[1])
		if(extra)
			picked += extra

	for(var/effect in picked)
		switch(effect)
			if("brain")
				H.adjustBrainLoss(rand(0, 10))
				to_chat(H, SPAN_DANGER("Your CPU surges, stabbing pain through your head!"))
			if("confuse")
				H.confused = max(H.confused, 10)
				to_chat(H, SPAN_WARNING("Your CPU scrambles your senses."))
			if("slur")
				H.slurring = max(H.slurring, 30)
				to_chat(H, SPAN_WARNING("Your CPU glitches and your speech slurs."))
			if("intent")
				var/new_intent = pick(I_HELP, I_DISARM, I_GRAB, I_HURT)
				H.a_intent = new_intent
				to_chat(H, SPAN_WARNING("Your CPU misfires and your intent shifts."))
				if(H.hud_used?.action_intent)
					var/icon_state = "intent_help"
					switch(new_intent)
						if(I_HURT)
							icon_state = "intent_harm"
						if(I_DISARM)
							icon_state = "intent_disarm"
						if(I_GRAB)
							icon_state = "intent_grab"
					H.hud_used.action_intent.icon_state = icon_state
			if("click")
				var/list/target_list = istype(H.get_active_hand(), /obj/item/gun) ? view(H) : view(1, H)
				target_list -= (H.external_organs + H.internal_organs)
				var/list/target_list_clear = list()
				for(var/T in target_list)
					if(istype(T, /obj) || istype(T, /turf) || istype(T, /mob))
						target_list_clear += T
				if(LAZYLEN(target_list_clear))
					to_chat(H, SPAN_WARNING("Your CPU twitches your muscles!"))
					H.ClickOn(pick(target_list_clear))
