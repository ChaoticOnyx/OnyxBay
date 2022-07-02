/datum/wires/vending
	holder_type = /obj/machinery/vending
	wire_count = 5

var/const/VENDING_WIRE_THROW = 1
var/const/VENDING_WIRE_CONTRABAND = 2
var/const/VENDING_WIRE_ELECTRIFY = 4
var/const/VENDING_WIRE_IDSCAN = 8
var/const/VENDING_POWER = 16

/datum/wires/vending/CanUse(mob/living/L)
	var/obj/machinery/vending/V = holder
	if(!istype(L, /mob/living/silicon))
		if(V.seconds_electrified)
			if(V.shock(L, 100))
				return 0
	if(V.panel_open)
		return 1
	return 0

/datum/wires/vending/GetInteractWindow()
	var/obj/machinery/vending/V = holder
	. += ..()
	. += "<BR>The blue light is [isActive(V)? "off" : "on"].<BR>"
	. += "The orange light is [isActive(V) && V.seconds_electrified ? "off" : "on"].<BR>"
	. += "The red light is [isActive(V) && V.shoot_inventory ? "blinking" : "off"].<BR>"
	. += "The green light is [isActive(V) && (V.categories & CAT_HIDDEN) ? "on" : "off"].<BR>"
	. += "The [isActive(V) && V.scan_id ? "purple" : "yellow"] light is on.<BR>"

/datum/wires/vending/UpdatePulsed(index)
	var/obj/machinery/vending/V = holder
	if(V.stat & POWEROFF)
		return
	switch(index)
		if(VENDING_WIRE_THROW)
			V.shoot_inventory = !V.shoot_inventory
		if(VENDING_WIRE_CONTRABAND)
			V.categories ^= CAT_HIDDEN
		if(VENDING_WIRE_ELECTRIFY)
			V.seconds_electrified = 30
		if(VENDING_WIRE_IDSCAN)
			V.scan_id = !V.scan_id
		if(VENDING_POWER)
			V.stat |= POWEROFF
			V.update_icon()

/datum/wires/vending/UpdateCut(index, mended)
	var/obj/machinery/vending/V = holder
	switch(index)
		if(VENDING_WIRE_THROW)
			V.shoot_inventory = !mended
		if(VENDING_WIRE_CONTRABAND)
			V.categories &= ~CAT_HIDDEN
		if(VENDING_WIRE_ELECTRIFY)
			if(mended)
				V.seconds_electrified = 0
			else
				V.seconds_electrified = -1
		if(VENDING_WIRE_IDSCAN)
			V.scan_id = 1
		if(VENDING_POWER)
			if(mended)
				V.stat &= ~POWEROFF
			else
				V.stat |= POWEROFF
			V.update_icon()

/datum/wires/vending/proc/isActive(obj/machinery/vending/V)
	if(V.stat & POWEROFF)
		return FALSE
	return TRUE
