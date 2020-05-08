#define GIBBER_HACK_WIRE 1
#define GIBBER_SHOCK_WIRE 2
#define GIBBER_DISABLE_WIRE 4

/datum/wires/gibber

	holder_type = /obj/machinery/gibber
	wire_count = 6

/datum/wires/gibber/GetInteractWindow()
	var/obj/machinery/gibber/A = holder
	. += ..()
	. += "<BR>The red light is [A.disabled ? "off" : "on"]."
	. += "<BR>The green light is [A.shocked ? "off" : "on"]."
	. += "<BR>The blue light is [A.hacked ? "off" : "on"].<BR>"

/datum/wires/gibber/CanUse()
	var/obj/machinery/gibber/A = holder
	if(A.panel_open)
		return 1
	return 0

/datum/wires/gibber/Interact(mob/living/user)
	if(CanUse(user))
		var/obj/machinery/gibber/V = holder
		V.attack_hand(user)

/datum/wires/gibber/UpdateCut(index, mended)
	var/obj/machinery/gibber/A = holder
	switch(index)
		if(GIBBER_HACK_WIRE)
			A.hacked = !mended
		if(GIBBER_SHOCK_WIRE)
			A.shocked = !mended
		if(GIBBER_DISABLE_WIRE)
			A.disabled = !mended

/datum/wires/gibber/UpdatePulsed(index)
	if(IsIndexCut(index))
		return
	var/obj/machinery/gibber/A = holder
	switch(index)
		if(GIBBER_HACK_WIRE)
			A.hacked = !A.hacked
			spawn(50)
				if(A && !IsIndexCut(index))
					A.hacked = 0
					Interact(usr)
		if(GIBBER_SHOCK_WIRE)
			A.shocked = !A.shocked
			spawn(50)
				if(A && !IsIndexCut(index))
					A.shocked = 0
					Interact(usr)
		if(GIBBER_DISABLE_WIRE)
			A.disabled = !A.disabled
			spawn(50)
				if(A && !IsIndexCut(index))
					A.disabled = 0
					Interact(usr)

#undef GIBBER_HACK_WIRE
#undef GIBBER_SHOCK_WIRE
#undef GIBBER_DISABLE_WIRE