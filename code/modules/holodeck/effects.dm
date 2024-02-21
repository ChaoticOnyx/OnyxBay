/obj/effect/holodeck_effect
	invisibility = INVISIBILITY_MAXIMUM

/obj/effect/holodeck_effect/proc/activate()
	return

/obj/effect/holodeck_effect/proc/deactivate()
	qdel(src)
	return

/obj/effect/holodeck_effect/proc/toggle_safety(safety = FALSE)
	return
