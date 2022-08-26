/obj/map_ent/func_proc_call
	name = "func_proc_call"
	icon_state = "func_proc_call"

	var/ev_proc_name
	var/ev_object_ref
	var/list/ev_args = list()

/obj/map_ent/func_proc_call/activate()
	var/datum/call_object = locate(ev_object_ref)

	if(!call_object)
		crash_with("Can't find object with ref: [ev_object_ref].")
		return

	if(!hascall(call_object, ev_proc_name))
		crash_with("Can't find proc for datum ref: [ev_object_ref].")
		return

	if(is_proc_protected(ev_proc_name))
		log_and_message_admins("Alert! One of instance of func_proc_call attemped to call forbidden proc ([ev_proc_name]). Blame the map loader (eventer)!. This instance will be deleted to prevent further alerts.")
		crash_with("Alert! Attemped to call forbidden proc ([ev_proc_name]). This instance will be deleted to prevent further alerts.")
		QDEL(src)
		return

	call(call_object, ev_proc_name)(arglist(ev_args))
