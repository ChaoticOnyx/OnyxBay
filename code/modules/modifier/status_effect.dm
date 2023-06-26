/datum/modifier/status_effect
	var/duration = 0
	var/alert_type = null
	var/obj/screen/movable/alert/linked_alert = null

/datum/modifier/status_effect/New(new_holder, new_origin)
	..()
	if(duration)
		expire_at = world.time + duration

	if(alert_type)
		linked_alert = holder.throw_alert("\ref[src]",alert_type)

/datum/modifier/status_effect/on_expire()
	. = ..()
	holder.clear_alert("\ref[src]")
