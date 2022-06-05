/obj/item/organ/internal/heart/gland/plasma
	abductor_hint = "effluvium sanguine-synonym emitter. The abductee randomly emits clouds of plasma."
	cooldown_low = 1200
	cooldown_high = 1800
	icon_state = "slime"
	uses = -1
	mind_control_uses = 1
	mind_control_duration = 800

/obj/item/organ/internal/heart/gland/plasma/activate()
	to_chat(owner, SPAN_WARNING("You feel bloated."))
	addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, owner, SPAN_DANGER("A massive stomachache overcomes you.")), 150)
	addtimer(CALLBACK(src, .proc/vomit_plasma), 200)

/obj/item/organ/internal/heart/gland/plasma/proc/vomit_plasma()
	if(!owner)
		return
	if(owner.nutrition < 150)
		return
	owner.visible_message(SPAN_DANGER("[owner] vomits a cloud of plasma!"))
	var/turf/simulated/T = get_turf(owner)
	if(istype(T))

		if(istype(owner.body_build,/datum/body_build/fat))
			T.assume_gas("plasma", 200, T20C)
		else
			T.assume_gas("plasma", 100, T20C)
	owner.nutrition-=20
	owner.vomit()
