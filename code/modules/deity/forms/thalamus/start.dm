/datum/deity_power/phenomena/thalamus/droppod
	expected_type = /turf
	name = "Droppod arrival"
	icon = 'icons/hud/actions.dmi'
	icon_state = "set_drop"
	can_switch = FALSE

/datum/deity_power/phenomena/thalamus/droppod/can_manifest(atom/target, mob/living/deity/D)
	if(!istype(target, expected_type))
		return FALSE

	return TRUE

/datum/deity_power/phenomena/thalamus/droppod/manifest(atom/target, mob/living/deity/D)
	if(!can_manifest(target, D))
		return FALSE

	var/choice = tgui_alert(D, "Is this the correct turf?", "Think twice", list("Yes", "No"))
	if(choice == "Yes")
		var/datum/deity_form/thalamus/thalamus = D.form
		thalamus.spawn_thalamus(target)
		D.set_selected_power(null, TRUE)
	else
		return FALSE

/datum/deity_form/thalamus/proc/spawn_thalamus(turf/target)
	var/datum/map_template/thalamus/thalamus = new /datum/map_template/thalamus()
	thalamus.load(target, TRUE, TRUE)
	var/list/spawned = thalamus.created_atoms
	for(var/obj/structure/deity/thalamus/T in spawned)
		T.linked_deity = deity
	deity.forceMove(target)

/datum/map_template/thalamus
	name = "Thalamus"
	returns_created_atoms = TRUE
	mappaths = list("maps/thalamus.dmm")
