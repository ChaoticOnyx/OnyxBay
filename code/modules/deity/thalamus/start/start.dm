/datum/deity_power/phenomena/thalamus/droppod
	expected_type = /turf
	name = "Droppod arrival"
	icon = 'icons/hud/actions.dmi'
	icon_state = "set_drop"

/datum/deity_power/phenomena/thalamus/droppod/can_manifest(atom/target, mob/living/deity/D)
	if(!istype(target, expected_type))
		return FALSE

	return TRUE

/datum/deity_power/phenomena/thalamus/droppod/manifest(atom/target, mob/living/deity/D)
	if(!can_manifest(target, D))
		return FALSE

	var/choice = tgui_alert(D, "Is this the correct turf?", "Think twice", list("Yes", "No"))
	if(choice == "Yes")
		new /datum/random_map/droppod/thalamus(null, target.x-1, target.y-1, target.z, do_not_announce = TRUE)
		addtimer(CALLBACK(D.form, nameof(/datum/god_form/thalamus/proc/spawn_thalamus)), target, 1 SECOND)
	else
		return FALSE

/datum/god_form/thalamus/proc/spawn_thalamus(turf/target)
	deity.forceMove(target)
	pass()

/datum/random_map/droppod/thalamus
	limit_x = 4
	limit_y = 4

	wall_type = /turf/simulated/wall/thalamus
	door_type = /obj/structure/deity/thalamus/door
	floor_type = /turf/simulated/floor/misc/thalamus
