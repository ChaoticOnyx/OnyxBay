/obj/item/organ/internal/heart/gland/emp
	abductor_hint = "electron accumulator/discharger. The abductee will randomly discharge electro magnetic impulse."
	cooldown_low = 800
	cooldown_high = 1200
	icon_state = "species"
	uses = -1
	mind_control_uses = 2
	mind_control_duration = 900

/obj/item/organ/internal/heart/gland/emp/activate()
	owner.visible_message(SPAN_DANGER("[owner]'s skin starts emitting electric arcs!"),\
	SPAN_WARNING("You feel electric energy building up inside you!"))
	playsound(get_turf(owner), GET_SFX(SFX_SPARK_MEDIUM), 100, TRUE)
	addtimer(CALLBACK(src, .proc/zap), rand(30, 150))

/obj/item/organ/internal/heart/gland/emp/proc/zap()
	empulse(owner, rand(2,5),rand(4,7))
	if(prob(35))
		to_chat(owner, SPAN_WARNING("You are overwhelmed with electricity from the inside!"))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
		s.set_up(5, 1, owner)
		s.start()
