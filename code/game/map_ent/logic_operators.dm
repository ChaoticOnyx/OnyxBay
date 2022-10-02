/obj/map_ent/logic_binary
	name = "logic_binary_template"
	icon_state = "logic_once" // temp icon_state, draw them!

	var/ev_compare_left
	var/ev_compare_right

	var/ev_tag

/obj/map_ent/logic_binary/activate()
	var/obj/map_ent/E = locate(ev_tag)

	if(!istype(E))
		util_crash_with("ev_tag is invalid")
		return

	return E

/obj/map_ent/logic_binary/andl
	name = "logic_and"
	icon_state = "logic_and"

/obj/map_ent/logic_binary/andl/activate()
	var/obj/map_ent/E = ..()

	if(ev_compare_left && ev_compare_right)
		E.activate()

/obj/map_ent/logic_binary/orl
	name = "logic_or"
	icon_state = "logic_or"

/obj/map_ent/logic_binary/orl/activate()
	var/obj/map_ent/E = ..()

	if(ev_compare_left || ev_compare_right)
		E.activate()

/obj/map_ent/logic_binary/equal
	name = "logic_equal"
	icon_state = "logic_equal"

/obj/map_ent/logic_binary/equal/activate()
	var/obj/map_ent/E = ..()

	if(ev_compare_left == ev_compare_right)
		E.activate()

/obj/map_ent/logic_binary/not_equal
	name = "logic_not_equal"
	icon_state = "logic_not_equal"

/obj/map_ent/logic_binary/not_equal/activate()
	var/obj/map_ent/E = ..()

	if(ev_compare_left != ev_compare_right)
		E.activate()

/obj/map_ent/logic_binary/less_than
	name = "logic_less_than"
	icon_state = "logic_less_than"

/obj/map_ent/logic_binary/less_than/activate()
	var/obj/map_ent/E = ..()

	if(ev_compare_left < ev_compare_right)
		E.activate()

/obj/map_ent/logic_binary/less_than_or_equal
	name = "less_than_or_equal"
	icon_state = "logic_less_than_or_equal"

/obj/map_ent/logic_binary/less_than_or_equal/activate()
	var/obj/map_ent/E = ..()

	if(ev_compare_left <= ev_compare_right)
		E.activate()

/obj/map_ent/logic_binary/greater_than
	name = "greater_than"
	icon_state = "logic_greater_than"

/obj/map_ent/logic_binary/greater_than/activate()
	var/obj/map_ent/E = ..()

	if(ev_compare_left > ev_compare_right)
		E.activate()

/obj/map_ent/logic_binary/greater_than_or_equal
	name = "greater_than_or_equal"
	icon_state = "logic_greater_than_or_equal"

/obj/map_ent/logic_binary/greater_than_or_equal/activate()
	var/obj/map_ent/E = ..()

	if(ev_compare_left >= ev_compare_right)
		E.activate()
