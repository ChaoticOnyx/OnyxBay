/obj/machinery
	var/cnetnum = 0
	var/cnetdontadd = 0
	var/datum/computernet/computernet = null
	var/uniqueid = null
	var/directwiredCnet = 1
	var/computerID = 0
	var/typeID = null
	var/netID = 0
	var/sniffer = 0
	var/ailabel = ""
	var/list/mob/living/silicon/ai/ais = list()
	var/nohack = 0
//***************************************
//		    Networking Helpers
//***************************************
proc/gettypeid(var/T)
	if (usedtypes["[T]"])
		return usedtypes["[T]"]
	else
		usedtypes["[T]"] = num2hex(rand(1, 16777215), 6)
		return usedtypes["[T]"]

proc/GetUnitId()
	var/I = 0
	while ((I==0) || usedids.Find(I))
		I = rand(1, 65535) //0001 - FFFF
	usedids += I
	return I

/proc/stripnetworkmessage(message as text)
	var/list/messagelist = dd_text2list(message," ",null)
	if(uppertext(messagelist[2]) == "MULTI")
		return copytext(message,15 + (messagelist[3] == "***" ? 0 : 3),0) //"123 MULTI 456789 COMMAND" => "COMMAND"
	else																 //"123 MULTI *** COMMAND" => "COMMAND"
		return copytext(message,10) //"123 4567 COMMAND" => "COMMAND"

/proc/checkcommand(var/list/message,var/index,var/word)
	if(message.len >= index)
		if(message[index] == word)
			return 1
	return 0

//***************************************
//		Machinery Procs and helpers
//***************************************

/obj/machinery/proc/receivemessage(var/message, var/obj/srcmachine)
	if (stat & BROKEN) return 1 //Broken things never respond, but they may be able to recieve packets when off
							  	//(Networks have a small amount of implied power)
	for (var/mob/living/silicon/ai/AI in ais)
		AI.AIreceivemessage(message,srcmachine)

	var/list/commands = dd_text2list(uppertext(stripnetworkmessage(message)), " ", null)
	if(commands.len < 1)
		return 1
	switch (commands[1])
		if ("POWER")
			switch (commands[2])
				if ("ON")
					stat &= ~NOPOWER
				if ("OFF")
					stat |= NOPOWER
			return 1
		if ("IDENT")
			transmitmessage(createmessagetomachine("REPORT UNIT [src.typeID] [replace(name, " ", "")] [src.identinfo()]", srcmachine))
			return 1
		if ("PING")
			if(commands.len == 1)
				transmitmessage(createmessagetomachine("PING REPLY", srcmachine))
			return 1
		if("CONTROL")
			attack_ai(usr)
			return 1
	return 0

/obj/machinery/proc/transmitmessage(message as text)
	if (!message || !computernet || (stat & (NOPOWER|BROKEN))) //If not connected, busted, or powerless then don't bother sending
		return 0
	computernet.send(message, src) //Moved this into the computernet's send proc.
	return 1

obj/machinery/proc/createmulticast(var/netid as text, var/typeid as text, var/message as text)
	if (!src.computernet)
		return
	return uppertext("[netid] MULTI [typeid] [message]")

obj/machinery/proc/createmessagetomachine(var/message as text, var/obj/destmachine)
	if (!destmachine:computernet || !src.computernet) //Both have to be connected to a network to attempt this
		return
	var/nid = "000"
	if (src.computernet != destmachine:computernet)
		nid = destmachine:computernet.id
	return uppertext("[nid] [destmachine:computerID] [message]")

/obj/machinery/proc/identinfo() //Meant to be overridden by machines
	return ""

/obj/machinery/proc/getcommandlist(var/message as text)
	return dd_text2list(uppertext(stripnetworkmessage(message)), " ", null)

/obj/machinery/New()
	..()
	computerID = uppertext(num2hex(GetUnitId(), 4))
	typeID = gettypeid(type)
	var/obj/computercable/C = locate() in loc
	if(!cnetdontadd && C && C.cnetnum)
		computernet = computernets[C.cnetnum]
		computernet.nodes += src
		computernet.nodes[computerID] = src