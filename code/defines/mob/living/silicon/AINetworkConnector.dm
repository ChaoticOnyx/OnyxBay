/obj/machinery/network/AIconnector
	name = "AI connector"
	icon = 'netcable.dmi'
	icon_state = "0-1"
	var/mob/living/silicon/ai/ai = null

/mob/living/silicon/ai
	var/obj/machinery/network/AIconnector/connectora
	var/obj/machinery/connector = null
	var/list/connectors = list()

/mob/living/silicon/ai/proc/AIreceivemessage(message as text, var/obj/machinery/sender)
	src << "\"[stripnetworkmessage(message)]\" received from [sender] \[[sender.computernet.id] [sender.computerID]]"

/mob/living/silicon/ai/proc/AItransmitmessage(message as text)
	if(connector)
		src << "Transmitting [message]"
		connector.transmitmessage(message)

/mob/living/silicon/ai/proc/send_raw_packet()
	set category = "AI Commands"
	set name = "Send Raw Packet"
	var/p = input("Enter Packet", "Send Packet", "NET UNIT COMMAND...")
	AItransmitmessage(p)

/mob/living/silicon/ai/proc/swapinterfaceto(var/obj/machinery/newinterface)
	if(connector)
		connector.ais -= src
	connector = newinterface
	connector.ais += src

/mob/living/silicon/ai/verb/send(message as text)
	set hidden = 1
	AItransmitmessage(message)

/mob/living/silicon/ai/proc/sendcommand(message as text,var/obj/machinery/sendto)
	if(connector)
		AItransmitmessage(connector.createmessagetomachine(message, sendto))

/mob/living/silicon/ai/proc/listinterfaces()
	set category = "AI Commands"
	set name = "List Network Interfaces"
	src << "<B>The following network interfaces are available for you to use</B>"
	for (var/I in src.connectors)
		var/obj/machinery/M = src.connectors[I]
		src << (routingtable.sourcenets[src.connector.computernet.id][M.computernet.id] || src.connector == M ? "\blue ":"\red ") + I

/mob/living/silicon/ai/proc/changeinterface2(obj/machinery/switchto in world)
	set category = null
	set name = "Use this Network Interface"

	if(!istype(switchto) || switchto.cnetdontadd || switchto.nohack)
		src << "\red That doesn't have a network interface you can use!"
		return

	if(switchto.stat & NOPOWER)
		src << "\red That machine has no power, try again when it does."
		return

	for(var/I in src.connectors)
		if (src.connectors[I] == switchto)
			src << "\blue Switched to [I] network interface."
			src.swapinterfaceto(switchto)
			return

	src << "\red You must hack this interface first!"


/mob/living/silicon/ai/proc/changeinterface(var/switchto in src.connectors)
	set category = "AI Commands"
	set name = "Select Network Interface"
	src << "\blue Switched to [switchto] network interface."
	src.swapinterfaceto(src.connectors[switchto])

/mob/living/silicon/ai/proc/hackinterface(var/obj/machinery/T in world)
	set name = "Hack Interface"
	for (var/I in src.connectors)
		if (src.connectors[I] == T)
			src << "\blue That device has already been hacked"
			return
	src << "Attempting to hack interface"
	sleep(rand(20, 60))
	if(rand(0,1))
		src << "Failed to hack interface"
		return
	src << "Interface hacked.  Uploading standby control program"
	sleep(rand(20, 80))
	src << "Control program ready.  You may switch to this network interface any time."
	sleep(5)
	var/a = alert("Would you like to assign this network interface a label?","Assign Label?","Yes","No")
	T.ailabel = T.name + " \[[T.loc.loc.name]]"
	while (a == "Yes" || src.connectors[T.ailabel])
		a = ""
		T.ailabel = input("Enter the label to use for this device","Enter Interface Label",T.ailabel)
		if (src.connectors[T.ailabel])
			src << "\red That label is in use"
	src.connectors[T.ailabel] = T

/mob/living/silicon/ai/proc/showpassword(var/obj/machinery/I in world)
	set name = "Show device password"
	if(!I.req_access)
		usr << "No passwords"
		return
	for (var/M in I.req_access)
		usr << get_access_desc(M) + ": " + accesspasswords["[M]"]

/mob/living/silicon/ai/proc/netid(var/obj/machinery/I in world)
	set name = "Show network and Device ID"
	if (!I.computernet)
		usr << "[I] is not connected to a network"
		return
	usr << "Network information for [I.name]: [I.computernet.id] [I.computerID]"