/obj/machinery/door
	name = "Door"
	icon = 'doorint.dmi'
	icon_state = "door1"
	opacity = 1
	density = 1
	var/secondsElectrified = 0
	var/visible = 1
	var/p_open = 0
	var/operating = 0
	anchored = 1
	var/autoclose = 0
	var/autoopen = 1
	var/locked = 0 // Currently in use for airlocks and window doors (alien weeds forcing the window doors open)
	var/forcecrush = 0
/obj/machinery/door/firedoor
	name = "Firelock"
	explosionstrength = 4
	icon = 'Doorfire.dmi'
	icon_state = "door0"
	var/blocked = null
	opacity = 0
	density = 0
	var/nextstate = null

/obj/machinery/door/firedoor/border_only
	name = "Firelock"
	icon = 'door_fire2.dmi'
	icon_state = "door0"

/obj/machinery/door/poddoor
	explosionstrength = 3
	name = "Podlock"
	icon = 'rapid_pdoor.dmi'
	icon_state = "pdoor1"
	var/id = 1.0

/obj/machinery/door/window
	name = "Interior Door"
	icon = 'windoor.dmi'
	icon_state = "left"
	var/base_state = "left"
	visible = 0.0
	flags = ON_BORDER
	opacity = 0
	networking = PROCESS_RPCS
	security = 1
/obj/machinery/door/window/call_function(datum/function/F)
	..()
	if(uppertext(F.arg1) != net_pass)
		var/datum/function/R = new()
		R.name = "response"
		R.source_id = address
		R.destination_id = F.source_id
		R.arg1 += "Incorrect Access token"
		send_packet(src,F.source_id,R)
		return 0 // send a wrong password really.
	if(F.name == "open")
		if(src.density)
			open()
	else if(F.name == "close")
		if(!src.density)
			open()
/obj/machinery/door/window/brigdoor
	name = "Brig Door"
	icon = 'windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"
	var/id = 1.0


/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"


/obj/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

