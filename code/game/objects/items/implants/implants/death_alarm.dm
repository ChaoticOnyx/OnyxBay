/obj/item/implant/death_alarm
	name = "death alarm implant"
	desc = "An alarm which monitors host vital signs and transmits a radio message upon death."
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 2, TECH_DATA = 1)
	known = 1
	var/mobname = "Will Robinson"

/obj/item/implant/death_alarm/get_data()
	return {"
	<b>Implant Specifications:</b><BR>
	<b>Name:</b> [GLOB.using_map.company_name] \"Profit Margin\" Class Employee Lifesign Sensor<BR>
	<b>Life:</b> Activates upon death.<BR>
	<b>Important Notes:</b> Alerts crew to crewmember death.<BR>
	<HR>
	<b>Implant Details:</b><BR>
	<b>Function:</b> Contains a compact radio signaler that triggers when the host's lifesigns cease.<BR>
	<b>Special Features:</b> Alerts crew to crewmember death.<BR>
	<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}

/obj/item/implant/death_alarm/islegal()
	return TRUE

/obj/item/implant/death_alarm/think()
	if (!implanted) return
	var/mob/M = imp_in

	if(QDELETED(M)) // If the mob got gibbed
		activate()
		return
	else if(M.is_ic_dead())
		activate("death")
		return

	set_next_think(world.time + 1 SECOND)

/obj/item/implant/death_alarm/activate(cause)
	var/location
	if (cause == "emp" && prob(50))
		location =  pick(playerlocs)
	else
		var/mob/M = imp_in
		var/area/t = get_area(M)
		location = t?.name
	var/death_message
	if(!cause || !location)
		death_message = "A message from [name] has been received. [mobname] has died-zzzzt in-in-in..."
	else
		var/additional_info = " The neural lace signature not found in the body."
		var/mob/living/carbon/human/H = imp_in
		var/obj/item/organ/internal/stack/S = H?.internal_organs_by_name[BP_STACK]
		if(istype(S))
			additional_info = " The neural lace signature found in the body."
		death_message = "A message from [name] has been received. [mobname] has died in [location]![additional_info]"
	set_next_think(0)

	for(var/channel in list("Security", "Medical", "Command"))
		GLOB.global_headset.autosay(death_message, ("[mobname]'s Death Alarm"), channel)

/obj/item/implant/death_alarm/emp_act(severity)			//for some reason alarms stop going off in case they are emp'd, even without this
	if (malfunction)		//so I'm just going to add a meltdown chance here
		return
	malfunction = MALFUNCTION_TEMPORARY

	if(prob(20))
		activate("emp")	//let's shout that this dude is dead
	if(severity == 1)
		if(prob(40))	//small chance of obvious meltdown
			meltdown()
		else if (prob(60))	//but more likely it will just quietly die
			malfunction = MALFUNCTION_PERMANENT
		set_next_think(0)

	spawn(20)
		malfunction = 0

/obj/item/implant/death_alarm/implanted(mob/source as mob)
	mobname = source.real_name
	set_next_think(world.time)
	return TRUE

/obj/item/implant/death_alarm/removed()
	..()
	set_next_think(0)

/obj/item/implantcase/death_alarm
	name = "glass case - 'death alarm'"
	imp = /obj/item/implant/death_alarm
