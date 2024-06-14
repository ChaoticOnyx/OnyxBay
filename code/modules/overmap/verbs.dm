#define WRAP_AROUND_VALUE(value, min, max) ( min + ((value - min) % (max - min)) )

/// Holds all the overmap ship panel verbs
/obj/structure/overmap/proc/verb_check(mob/user, require_pilot = TRUE)
	if(!user)
		user = usr

	if(user != pilot)
		to_chat(user, SPAN_NOTICE("You can't reach the controls from here"))
		return FALSE

	return !user.incapacitated() && isliving(user)

/// Control Scheme Verbs
/obj/structure/overmap/verb/toggle_brakes()
	set name = "Toggle Handbrake"
	set category = "Ship"

	if(!verb_check() || !can_brake())
		return

	brakes = !brakes
	to_chat(usr, SPAN_NOTICE("You toggle the brakes [brakes ? "on" : "off"]."))

/obj/structure/overmap/verb/toggle_inertia()
	set name = "Toggle IAS"
	set category = "Ship"

	if(!verb_check() || !can_brake())
		return

	if(!toggle_dampeners(user = usr))
		return

	to_chat(usr, SPAN_NOTICE("Inertial assistance system [inertial_dampeners ? "ONLINE" : "OFFLINE"]."))

/obj/structure/overmap/verb/toggle_move_mode()
	set name = "Change movement mode"
	set category = "Ship"

	if(!verb_check())
		return

	move_by_mouse = !move_by_mouse
	to_chat(usr, SPAN_NOTICE("You [move_by_mouse ? "activate" : "deactivate"] [src]'s laser guided movement system."))

/// General Overmap Verbs
/obj/structure/overmap/verb/show_dradis()
	set name = "Show DRADIS"
	set category = "Ship"

	pass()

/obj/structure/overmap/verb/cycle_firemode()
	set name = "Switch firemode"
	set category = "Ship"
	if(usr != gunner)
		return

	pass()

/// Small Craft Specific Verbs
/obj/structure/overmap/small_craft/verb/show_control_panel()
	set name = "Show control panel"
	set category = "Ship"

	if(!verb_check())
		return

	tgui_interact(usr)

/obj/structure/overmap/small_craft/verb/change_name()
	set name = "Change name"
	set category = "Ship"

	if(!verb_check())
		return

	var/new_name = tgui_input_text(usr, message = "What do you want to name \
		your fighter? Keep in mind that particularly terrible names may be \
		rejected by your employers.")
	if(!new_name || length(new_name) <= 0)
		return

	name = new_name

/obj/structure/overmap/verb/toggle_safety()
	set name = "Toggle Gun Safeties"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check() || !can_change_safeties())
		return

	weapon_safety = !weapon_safety
	to_chat(usr, SPAN_NOTICE("You toggle [src]'s weapon safeties [weapon_safety ? "on" : "off"]."))

/obj/structure/overmap/small_craft/verb/countermeasure()
	set name = "Deploy Countermeasures"
	set category = "Ship"

	if(!verb_check())
		return

	fire_countermeasure()

/obj/structure/overmap/verb/show_tactical()
	set name = "Show Tactical"
	set category = "Ship"

	pass()
