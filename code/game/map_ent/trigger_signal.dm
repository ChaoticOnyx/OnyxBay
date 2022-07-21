/obj/map_ent/trigger_signal
	name = "trigger_signal"
	icon_state = "trigger_signal"

	var/ev_signal
	var/ev_tag
	var/ev_signal_source

	var/weakref/_source

/obj/map_ent/trigger_signal/Initialize(mapload)
	. = ..()

	if(!ev_signal_source)
		register_global_signal(ev_signal, .proc/_on_signal)
		return

	var/atom/A = locate(ev_signal_source)
	if(!istype(A))
		crash_with("ev_signal_source is invalid")
		return INITIALIZE_HINT_QDEL
	
	_source = weakref(A)
	register_signal(A, ev_signal, .proc/_on_signal)

/obj/map_ent/trigger_signal/Destroy()
	if(!_source)
		unregister_global_signal(ev_signal)
		return

	var/atom/A = _source.resolve()
	unregister_signal(A, ev_signal)
	
	. = ..()

/obj/map_ent/trigger_signal/proc/_on_signal()
	var/obj/map_ent/E = locate(ev_tag)
	
	if(!istype(E))
		crash_with("ev_tag is invalid")
		return

	E.activate()
