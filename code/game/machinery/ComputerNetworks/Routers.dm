/obj/machinery/network/router
	name = "Router"
	icon = 'netobjs.dmi'
	icon_state = "router"
	desc = "A high-speed network router.  The lights are mesmerizing"
	anchored = 1.0
	density = 1
	var/id = 0
	var/list/datum/computernet/connectednets = list()
	var/list/datum/computernet/disconnectednets = list()

/obj/machinery/network/router/attack_ai(mob/living/silicon/ai/user as mob)
	if(stat)
		user << "\red The router is not responding"
		return

	user.machine = src
	if (istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon/ai))
		var/dat = {"<HTML><HEAD></HEAD><BODY><TT>[loc.loc.name] Network Router<BR>
Primary operating system online<HR>
Servicing [connectednets.len + disconnectednets.len] Networks<BR>
[netlist()]
</TT></BODY></HTML>"}
		user << browse(dat, "window=router")
	return

/obj/machinery/network/router/ReceiveNetworkPacket(message as text, obj/machinery/srcmachine)
	if (..())
		return
	var/list/commands = GetPacketContentUppercased(message)
	if(commands.len < 3)
		return
	if (!check_password(commands[1]))
		return
	var/datum/computernet/cnet = null
	for (var/datum/computernet/net in computernets)
		if(net.id == commands[3])
			cnet = net
			break
	if (commands[2] == "DISCON")
		connectednets -= cnet
		disconnectednets += cnet
		BuildRoutingTable()
	else if (commands[2] == "RECON")
		connectednets += cnet
		disconnectednets -= cnet
		BuildRoutingTable()

/obj/machinery/network/router/attack_hand(mob/user as mob)
	user << connectednets.len

/obj/machinery/network/router/Topic(href, href_list)
	if (stat & (BROKEN|NOPOWER))
		return
	if (istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/aiusr = usr
		usr.machine = src
		var/datum/computernet/cnet
		var/pw = get_password()
		if (href_list["toggle"])
			for (var/datum/computernet/net in computernets)
				if(net.id == href_list["toggle"])
					cnet = net
					break
			if(cnet in connectednets)
				aiusr.sendcommand("[pw] DISCON [href_list["toggle"]]", src)
			else if (cnet in disconnectednets)
				aiusr.sendcommand("[pw] RECON [href_list["toggle"]]", src)
			src.updateUsrDialog()

/obj/machinery/network/router/proc/netlist()
	var/dat = "Active Networks:<BR>"
	for(var/datum/computernet/net in connectednets)
		dat += "Network [net.id] \[<A href='?src=\ref[src];toggle=[net.id]'>Disconnect</A>]<BR>"
	dat += "Inactive Networks: <BR>"
	for(var/datum/computernet/net in disconnectednets)
		dat += "Network [net.id] \[<A href='?src=\ref[src];toggle=[net.id]'>Connect</A>]<BR>"
	return dat

/obj/machinery/network/router/Del()
	..()
	for(var/turf/T in range(100,src))
		if(T.wireless.Find(src))
			T.wireless.Remove(src)

/obj/machinery/network/router/verb/ResetWifi()
	var/wificount
	for(var/turf/T in range(100,src))
		if(!T.wireless.Find(src))
			T.wireless.Add(src)
		wificount += 1

	usr << wificount

/obj/machinery/network/router/NetworkIdentInfo()
	var/list/c = list( )
	for(var/datum/computernet/CN in connectednets)
		c += CN.id
	return "SERVICING \[[dd_list2text(c," ")]\] AT [replace(loc.loc.name," ","")]"

