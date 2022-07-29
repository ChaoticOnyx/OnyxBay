/datum/component/train_auto
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/weakref/train

/datum/component/train_auto/Initialize()
	if(!istype(parent, /datum/shuttle/autodock/ferry/train))
		return COMPONENT_INCOMPATIBLE

	train = weakref(parent)
	register_signal(parent, SIGNAL_SHUTTLE_ARRIVED, .proc/arrived)
	arrived()

/datum/component/train_auto/proc/arrived()
	addtimer(CALLBACK(src, .proc/launch), 10 SECONDS)

/datum/component/train_auto/proc/launch()
	if(QDELETED(train))
		qdel(src)
		return
	
	var/datum/shuttle/autodock/ferry/train/T = train.resolve()

	if(QDELETED(T))
		qdel(src)
		return

	if(GLOB.using_map.level_has_trait(T.current_location.z, ZTRAIT_BLUESPACE_EXIT))
		// Wait for the next try.
		arrived()
	else
		T.launch()
