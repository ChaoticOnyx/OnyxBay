/obj/map_ent/func_strcat
	name = "func_strcat"
	icon_state = "func_strcat"

	var/ev_lvalue
	var/ev_rvalue
	var/ev_result

/obj/map_ent/func_strcat/activate()
	if(ev_rvalue == null)
		crash_with("ev_rvalue is null")
		return
	else if(isnum(ev_rvalue))
		ev_rvalue = num2text(ev_rvalue)

	if(ev_lvalue == null)
		crash_with("ev_lvalue is null")
		return
	else if(isnum(ev_lvalue))
		ev_lvalue = num2text(ev_lvalue)

	ev_result = ev_lvalue + ev_rvalue
