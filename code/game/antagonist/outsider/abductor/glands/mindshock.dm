/obj/item/organ/internal/heart/gland/mindshock
	abductor_hint = "neural crosstalk uninhibitor. The abductee emits a disrupting psychic wave every so often. This will either stun, cause hallucinations or deal random brain damage to people nearby."
	cooldown_low = 400
	cooldown_high = 700
	uses = -1
	icon_state = "mindshock"
	mind_control_uses = 1
	mind_control_duration = 6000
	var/min_brain_damage = 2
	var/max_brain_damage = 10
	var/list/mob/living/carbon/human/broadcasted_mobs = list()

/obj/item/organ/internal/heart/gland/mindshock/activate()
	to_chat(owner, SPAN_NOTICE("You get a headache."))

	var/turf/T = get_turf(owner)
	for(var/mob/living/carbon/H in orange(4,T))
		if(H == owner || isabductor(H))
			continue
		switch(pick(1,3))
			if(1)
				to_chat(H, SPAN_DANGER("You hear a loud buzz in your head, silencing your thoughts!"))
				H.Stun(5)
			if(2)
				to_chat(H, SPAN_WARNING("You hear an annoying buzz in your head."))
				H.confused = max(H.confused, 10)
				if(!H.should_have_organ(BP_BRAIN)) return //no brain

				var/obj/item/organ/internal/brain/brain = H.internal_organs_by_name[BP_BRAIN]
				if(!brain) return //no brain

				H.setBrainLoss(rand(min_brain_damage,max_brain_damage))
			if(3)
				H.hallucination += 20

/obj/item/organ/internal/heart/gland/mindshock/mind_control(command, mob/living/user)
	if(!ownerCheck() || !mind_control_uses || active_mind_control)
		return FALSE
	mind_control_uses--
	for(var/mob/M in oview(7, owner))
		if(!ishuman(M))
			continue
		var/mob/living/carbon/human/H = M
		if(H.stat)
			continue

		broadcasted_mobs += H
		to_chat(H, SPAN_DANGER("You suddenly feel an irresistible compulsion to follow an order..."))
		to_chat(H, SPAN_NOTICE(FONT_LARGE("[command]")))

		message_admins("[key_name(user)] broadcasted an abductor mind control message from [key_name(owner)] to [key_name(H)]: [command]")
		log_game("[key_name(user)] broadcasted an abductor mind control message from [key_name(owner)] to [key_name(H)]: [command]")

	if(LAZYLEN(broadcasted_mobs))
		active_mind_control = TRUE
		addtimer(CALLBACK(src, .proc/clear_mind_control), mind_control_duration)

	update_gland_hud()
	return TRUE

/obj/item/organ/internal/heart/gland/mindshock/clear_mind_control()
	if(!active_mind_control || !LAZYLEN(broadcasted_mobs))
		return FALSE
	for(var/M in broadcasted_mobs)
		var/mob/living/carbon/human/H = M
		to_chat(H, SPAN_DANGER("You feel the compulsion fade, and you <i>completely forget</i> about your previous orders."))
	active_mind_control = FALSE
	return TRUE
