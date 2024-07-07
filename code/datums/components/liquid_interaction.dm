/// This element allows for items to interact with liquids on turfs.

/datum/component/liquids_interaction
	///Callback interaction called when the turf has some liquids on it
	var/datum/callback/interaction_callback

/datum/component/liquids_interaction/Initialize(on_interaction_callback)
	. = ..()

	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE

	interaction_callback = CALLBACK(parent, on_interaction_callback)

/datum/component/liquids_interaction/register_with_parent()
	register_signal(parent, SIGNAL_CLEAN_LIQUIDS, .proc/AfterAttack) //The only signal allowing item -> turf interaction

/datum/component/liquids_interaction/unregister_from_parent()
	unregister_signal(parent, SIGNAL_CLEAN_LIQUIDS)

/datum/component/liquids_interaction/proc/AfterAttack(turf/turf_target, mob/user)
	SIGNAL_HANDLER

	if(!isturf(turf_target) || !turf_target.liquids)
		return

	if(interaction_callback.Invoke(turf_target, user, turf_target.liquids))
		return
