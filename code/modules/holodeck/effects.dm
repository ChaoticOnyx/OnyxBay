/obj/effect/holodeck_effect
	icon = 'icons/misc/landmarks.dmi'
	invisibility = INVISIBILITY_MAXIMUM

/obj/effect/holodeck_effect/proc/activate()
	return

/obj/effect/holodeck_effect/proc/deactivate()
	SHOULD_CALL_PARENT(TRUE)

	qdel(src)

/obj/effect/holodeck_effect/proc/nerf(nerf = TRUE)
	return

/obj/effect/holodeck_effect/carp
	icon_state = "holocarp"

	var/weakref/carp_ref

/obj/effect/holodeck_effect/carp/activate()
	var/mob/living/simple_animal/hostile/carp/holographic/holo_carp = new(get_turf(src))

	carp_ref = weakref(holo_carp)

	return holo_carp

/obj/effect/holodeck_effect/carp/nerf(nerf = TRUE)
	var/mob/living/simple_animal/hostile/carp/holographic/holo_carp = carp_ref.resolve()
	if(!istype(holo_carp))
		return

	holo_carp.faction = nerf ? "neutral" : "carp"

/obj/effect/holodeck_effect/carp/random
	icon_state = "holocarp_random"

/obj/effect/holodeck_effect/carp/random/activate()
	if(prob(4))
		return ..()
