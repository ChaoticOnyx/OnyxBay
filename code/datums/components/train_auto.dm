/datum/component/train_auto
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/weakref/train

/datum/component/train_auto/Initialize()
	if(!istype(parent, /datum/shuttle/autodock/ferry/train))
		return COMPONENT_INCOMPATIBLE

	train = weakref(parent)
	register_signal(parent, SIGNAL_SHUTTLE_ARRIVED, .proc/arrived)
	set_next_think(world.time)

/datum/component/train_auto/think()
	if(QDELETED(train))
		qdel(src)
		return
	
	var/datum/shuttle/autodock/ferry/train/T = train.resolve()

	if(QDELETED(T))
		qdel(src)
		return

	if(T.process_state == IDLE_STATE)
		T.launch()
	
	set_next_think(world.time + 30 SECONDS)

/datum/component/train_auto/proc/arrived()
	set_next_think(world.time + 30 SECONDS)
