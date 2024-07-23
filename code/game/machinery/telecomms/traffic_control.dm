//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32





/obj/machinery/computer/telecomms/traffic
	name = "Telecommunications Traffic Control"
	icon_screen = "generic"

	var/screen = 0				// the screen number:
	var/list/servers = list()	// the servers located by the computer
	var/obj/machinery/telecomms/server/SelectedServer

	var/network = "NULL"		// the network to probe
	var/temp = ""				// temporary feedback messages

	req_access = list(access_tcomsat)

	attack_hand(mob/user as mob)
		if(stat & (BROKEN|NOPOWER))
			return
		user.set_machine(src)
		var/dat = "<meta charset=\"utf-8\"><TITLE>Telecommunication Traffic Control</TITLE><center><b>Telecommunications Traffic Control</b></center>"

		switch(screen)


		  // --- Main Menu ---

			if(0)
				dat += "<br>[temp]<br>"
				dat += "<br>Current Network: <a href='?src=\ref[src];network=1'>[network]</a><br>"
				if(servers.len)
					dat += "<br>Detected Telecommunication Servers:<ul>"
					for(var/obj/machinery/telecomms/T in servers)
						dat += "<li><a href='?src=\ref[src];viewserver=[T.id]'>\ref[T] [T.name]</a> ([T.id])</li>"
					dat += "</ul>"
					dat += "<br><a href='?src=\ref[src];operation=release'>\[Flush Buffer\]</a>"

				else
					dat += "<br>No servers detected. Scan for servers: <a href='?src=\ref[src];operation=scan'>\[Scan\]</a>"


		  // --- Viewing Server ---

			if(1)
				dat += "<br>[temp]<br>"
				dat += "<center><a href='?src=\ref[src];operation=mainmenu'>\[Main Menu\]</a>     <a href='?src=\ref[src];operation=refresh'>\[Refresh\]</a></center>"
				dat += "<br>Current Network: [network]"
				dat += "<br>Selected Server: [SelectedServer.id]<br><br>"


		show_browser(user, dat, "window=traffic_control;size=575x400")
		onclose(user, "server_control")

		temp = ""
		return


	Topic(href, href_list)
		if(..())
			return

		usr.set_machine(src)
		if(!src.allowed(usr) && !emagged)
			to_chat(usr, "<span class='warning'>ACCESS DENIED.</span>")
			return

		if(href_list["viewserver"])
			screen = 1
			for(var/obj/machinery/telecomms/T in servers)
				if(T.id == href_list["viewserver"])
					SelectedServer = T
					break

		if(href_list["operation"])
			switch(href_list["operation"])

				if("release")
					servers = list()
					screen = 0

				if("mainmenu")
					screen = 0

				if("scan")
					if(servers.len > 0)
						temp = "<font color = #d70b00>- FAILED: CANNOT PROBE WHEN BUFFER FULL -</font>"

					else
						for(var/obj/machinery/telecomms/server/T in range(25, src))
							if(T.network == network)
								servers.Add(T)

						if(!servers.len)
							temp = "<font color = #d70b00>- FAILED: UNABLE TO LOCATE SERVERS IN \[[network]\] -</font>"
						else
							temp = "<font color = #336699>- [servers.len] SERVERS PROBED & BUFFERED -</font>"

						screen = 0

		if(href_list["network"])

			var/newnet = sanitize(input(usr, "Which network do you want to view?", "Comm Monitor", network) as null|text)

			if(newnet && ((usr in range(1, src) || issilicon(usr))))
				if(length(newnet) > 15)
					temp = "<font color = #d70b00>- FAILED: NETWORK TAG STRING TOO LENGHTLY -</font>"

				else

					network = newnet
					screen = 0
					servers = list()
					temp = "<font color = #336699>- NEW NETWORK TAG SET IN ADDRESS \[[network]\] -</font>"

		updateUsrDialog()
		return

	attackby(obj/item/D as obj, mob/user as mob)
		if(isScrewdriver(D))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			if(do_after(user, 20, src, luck_check_type = LUCK_CHECK_ENG))
				if (src.stat & BROKEN)
					to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					new /obj/item/material/shard( src.loc )
					var/obj/item/circuitboard/comm_traffic/M = new /obj/item/circuitboard/comm_traffic( A )
					for (var/obj/C in src)
						C.dropInto(loc)
					A.circuit = M
					A.state = 3
					A.icon_state = "3"
					A.anchored = 1
					qdel(src)
				else
					to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					var/obj/item/circuitboard/comm_traffic/M = new /obj/item/circuitboard/comm_traffic( A )
					for (var/obj/C in src)
						C.dropInto(loc)
					A.circuit = M
					A.state = 4
					A.icon_state = "4"
					A.anchored = 1
					qdel(src)
		src.updateUsrDialog()
		return

/obj/machinery/computer/telecomms/traffic/emag_act(remaining_charges, mob/user)
	if(!emagged)
		playsound(src.loc, 'sound/effects/computer_emag.ogg', 25)
		emagged = 1
		to_chat(user, "<span class='notice'>You you disable the security protocols</span>")
		src.updateUsrDialog()
		return 1
