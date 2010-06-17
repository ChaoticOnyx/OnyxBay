/obj/machinery/network/mailserver
	name = "Mail Server"
	icon = 'netobjs.dmi'
	icon_state = "mailserv"
	anchored = 1
	density = 1
	desc = "This chunky computer system handles all non-voice electronic communications on the station"

/obj/machinery/network/chatserver
	name = "Message server"
	var/servername = "DEFAULT"
	var/list/networkaddresses = list()
	icon = 'netobjs.dmi'
	icon_state = "mailserv"

//This is a standin for a proper networking thing
//The PDAs should report their network address to receive updates

/obj/machinery/network/chatserver/ReceiveNetworkPacket(message as text, var/obj/srcmachine)
	if (..())
		return
	var/list/commands = GetPacketContentUppercased(message)
	if(commands.len < 2)
		return
	if(commands[1] == "MESSAGE")
		for(var/address in networkaddresses)
			TransmitNetworkPacket(address + " [message]")
	if(commands[1] == "UPDATE")
		networkaddresses["[commands[2]]"] = commands[2] + " " + commands[3]