/** Networking will use RPCs to send packets. These RPCs can also be
	used by computer terminals to process user input.
	http://whoopshop.com/index.php/topic,1529.msg23274.html#msg23274
**/

/datum/function
	var
		name = "None"
		arg1 = null
		arg2 = null
		arg3 = null
		arg4 = null
		arg5 = null

		source_id = 0
		destination_id = 0

	proc/get_args()
		var/list/rval = list()
		if(arg1 == null) return rval
		rval += arg1
		if(arg2 == null) return rval
		rval += arg2
		if(arg3 == null) return rval
		rval += arg3
		if(arg4 == null) return rval
		rval += arg4
		if(arg5 == null) return rval
		rval += arg5

var/global/const/PROCESS_RPCS = 2
/obj/machinery/var/networking = 0 // set to 1 if this object should be sent messages
								  // set to 2 if the received RPCs should be directly called
/obj/machinery/var/address = 0

/obj/machinery/proc/call_function(datum/function/F)

/obj/machinery/proc/receive_packet(var/obj/machinery/sender, var/datum/function/P)
	if(networking == PROCESS_RPCS)
		call_function(P)

// computers can have a console interaction
/obj/machinery/computer/var/mob/console_user
/obj/machinery/computer/var/datum/os/operating_system

/obj/machinery/computer/proc/display_console(mob/user)
	winshow(user, "console", 1)
	console_user = user
	if(!operating_system)
		operating_system = new(src)
	user.comp = operating_system
	operating_system.owner += user
	operating_system.Boot()

/obj/machinery/computer/process()
	if(console_user && !(console_user in range(1,src)) )
		winshow(console_user, "console", 0)
		console_user.comp = null
		src.operating_system.owner -= console_user
		console_user = null
	..()

mob/proc/display_console(var/obj/device)
	if(!src.console_device)
		winshow(src, "console", 1)
		device:console_user = src
		src.comp = device:OS
		src.console_device = device
		device:OS.owner += src
		if(!device:OS.boot)
			device:OS.ip = device:address
			device:OS.Boot()

mob/proc/hide_console()
	if(src.console_device)
		winshow(src, "console", 0)
		src.comp = null
		src.console_device:OS:owner -= src
		src.console_device:console_user = null
		src.console_device = null

proc/send_packet(var/obj/device, var/dest_address, var/datum/function/F)
	// for laptops, try to find a connection
	if(istype(device,/obj/item/weapon/laptop))
		if(device:R)
			device:R.connected -= src
			device:R = null
		device:address = 0
		for(var/obj/machinery/router/R in range(20,device.loc))
			R.connected += device
			device:R = R
			R.connect(device)
			break

	// first, find out what router belongs to the device, if any at all
	var/address = device:address

	if(!address)
		return "Not connected to network."

	// get the router bit from the address
	var/router = address >> 8

	for(var/obj/machinery/router/R in world)
		if(R.address_range == router)
			F.source_id = address
			F.destination_id = dest_address
			spawn R.receive_packet(device,F)
			return "Packet successfully transmitted to router"

	return "Not connected to network."

proc/text2ip(var/txt)
	var/list/parts = list()
	var/current_part = ""
	for(var/i = 1, i<=length(txt), i++)
		var/char = copytext(txt,i,i+1)
		if(char == ".")
			parts += current_part
			current_part = ""
		else if("1" <= char && char <= "9")
			current_part += char
		else
			return -1
	if(current_part != "")
		parts += current_part
		current_part = ""
	if(parts.len != 4)
		return -1
	if(parts[1] != "197")
		return -1
	if(parts[2] != "8")
		return -1
	var/rval = 0
	rval += text2num(parts[3]) * 256
	rval += text2num(parts[4])
	return rval

proc/ip2text(var/ip)
	var/x3 = ip >> 8
	var/x4 = ip & 255
	return "197.8.[x3].[x4]"