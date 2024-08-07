// the light switch
// can have multiple per area
// can also operate on non-loc area through "otherarea" var
/obj/machinery/light_switch
	name = "light switch"
	desc = "It turns lights on and off. What are you, simple?"
	icon = 'icons/obj/power.dmi'
	icon_state = "light0"
	anchored = 1.0
	idle_power_usage = 20 WATTS
	power_channel = STATIC_LIGHT
	var/on = 0
	var/area/connected_area = null
	var/other_area = null

/obj/machinery/light_switch/Initialize(mapload)
	. = ..()
	if(other_area)
		src.connected_area = locate(other_area)
	else
		src.connected_area = get_area(src)

	if(name == initial(name))
		SetName("light switch ([connected_area.name])")

	connected_area.set_lightswitch(on)
	update_icon()

/obj/machinery/light_switch/Destroy()
	connected_area = null
	other_area = null
	ClearOverlays()
	return ..()

/obj/machinery/light_switch/on_update_icon()
	ClearOverlays()
	if(stat & (NOPOWER|BROKEN))
		icon_state = "light-p"
		set_light(0)
	else
		icon_state = "light[on]"
		AddOverlays(emissive_appearance(icon, "light-ea"))
		set_light(0.15, 0.1, 1, 2, (on ? "#82ff4c" : "#f86060"))

/obj/machinery/light_switch/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) <= 1)
		. += "A light switch. It is [on? "on" : "off"]."

/obj/machinery/light_switch/proc/set_state(newstate)
	if(on != newstate)
		on = newstate
		connected_area.set_lightswitch(on)
		update_icon()

/obj/machinery/light_switch/proc/sync_state()
	if(connected_area && on != connected_area.lightswitch)
		on = connected_area.lightswitch
		update_icon()
		return 1

/obj/machinery/light_switch/attack_hand(mob/user)
	playsound(src, 'sound/effects/using/switch/lightswitch.ogg', 75)
	set_state(!on)

/obj/machinery/light_switch/powered()
	. = ..(power_channel, connected_area) //tie our powered status to the connected area

/obj/machinery/light_switch/power_change()
	. = ..()
	//synch ourselves to the new state
	if(connected_area) //If an APC initializes before we do it will force a power_change() before we can get our connected area
		sync_state()

/obj/machinery/light_switch/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	power_change()
	..(severity)
