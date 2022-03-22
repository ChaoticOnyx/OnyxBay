/obj/item/organ/internal/heart/gland/quantum
	abductor_hint = "quantic de-observation matrix. Periodically links with a random person in view, then the abductee later swaps positions with that person."
	cooldown_low = 150
	cooldown_high = 150
	uses = -1
	icon_state = "emp"
	mind_control_uses = 2
	mind_control_duration = 1200
	var/mob/living/carbon/entangled_mob

/obj/item/organ/internal/heart/gland/quantum/activate()
	if(entangled_mob)
		return
	for(var/mob/M in oview(owner, 7))
		if(!iscarbon(M) || isabductor(M))
			continue
		entangled_mob = M
		addtimer(CALLBACK(src, .proc/quantum_swap), rand(600, 2400))
		return

/obj/item/organ/internal/heart/gland/quantum/proc/quantum_swap()
	if(QDELETED(entangled_mob))
		entangled_mob = null
		return
	var/turf/T = get_turf(owner)
	do_teleport(owner, get_turf(entangled_mob))
	do_teleport(entangled_mob, T)
	owner.confused = max(owner.confused, rand(5,10))
	entangled_mob.confused = max(entangled_mob.confused, rand(5,10))
	to_chat(owner, SPAN_WARNING("You suddenly find yourself somewhere else!"))
	to_chat(entangled_mob, SPAN_WARNING("You suddenly find yourself somewhere else!"))
	if(!active_mind_control) //Do not reset entangled mob while mind control is active
		entangled_mob = null

/obj/item/organ/internal/heart/gland/quantum/mind_control(command, mob/living/user)
	if(..())
		if(entangled_mob && ishuman(entangled_mob) && (entangled_mob.stat < DEAD))
			to_chat(entangled_mob, SPAN_DANGER("You suddenly feel an irresistible compulsion to follow an order..."))
			to_chat(entangled_mob, SPAN_NOTICE(FONT_LARGE("[command]")))
			message_admins("[key_name(owner)] mirrored an abductor mind control message to [key_name(entangled_mob)]: [command]")
			log_game("[key_name(owner)] mirrored an abductor mind control message to [key_name(entangled_mob)]: [command]")
			update_gland_hud()

/obj/item/organ/internal/heart/gland/quantum/clear_mind_control()
	if(active_mind_control)
		to_chat(entangled_mob, SPAN_DANGER("You feel the compulsion fade, and you completely forget about your previous orders."))
	..()
