/obj/machinery/computer/mecha
	name = "Exosuit Control"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "rd_key"
	icon_screen = "mecha"
	light_color = "#a97faa"
	req_access = list(access_robotics)
	circuit = /obj/item/weapon/circuitboard/mecha_control
	var/list/located = list()
	var/screen = 0
	var/stored_data

	attack_ai(var/mob/user as mob)
		return src.attack_hand(user)

	attack_hand(var/mob/user as mob)
		if(..())
			return
		user.set_machine(src)
		var/dat = "<html><meta charset=\"utf-8\"><head><title>[src.name]</title><style>h3 {margin: 0px; padding: 0px;}</style></head><body>"
		if(screen == 0)
			dat += "<h3>Tracking beacons data</h3>"
			for(var/obj/item/mecha_parts/mecha_tracking/TR in world)
				var/answer = TR.get_mecha_info()
				if(answer)
					dat += {"<hr>[answer]<br/>
							  <a href='?src=\ref[src];send_message=\ref[TR]'>Send message</a><br/>
							  <a href='?src=\ref[src];get_log=\ref[TR]'>Show exosuit log</a> | <a style='color: #f00;' href='?src=\ref[src];shock=\ref[TR]'>(EMP pulse)</a><br>"}

		if(screen==1)
			dat += "<h3>Log contents</h3>"
			dat += "<a href='?src=\ref[src];return=1'>Return</a><hr>"
			dat += "[stored_data]"

		dat += "<A href='?src=\ref[src];refresh=1'>(Refresh)</A><BR>"
		dat += "</body></html>"

		show_browser(user, dat, "window=computer;size=400x500")
		onclose(user, "computer")
		return

	Topic(href, href_list)
		if(..())
			return
		var/datum/topic_input/F = new /datum/topic_input(href,href_list)
		if(href_list["send_message"])
			var/obj/item/mecha_parts/mecha_tracking/MT = F.getObj("send_message")
			var/message = sanitize(input(usr,"Input message","Transmit message") as text)
			var/obj/mecha/M = MT.in_mecha()
			if(message && M)
				M.occupant_message(message)
			return
		if(href_list["shock"])
			var/obj/item/mecha_parts/mecha_tracking/MT = F.getObj("shock")
			MT.shock()
		if(href_list["get_log"])
			var/obj/item/mecha_parts/mecha_tracking/MT = F.getObj("get_log")
			stored_data = MT.get_mecha_log()
			screen = 1
		if(href_list["return"])
			screen = 0
		src.updateUsrDialog()
		return



/obj/item/mecha_parts/mecha_tracking
	name = "Exosuit tracking beacon"
	desc = "Device used to transmit exosuit data."
	icon = 'icons/obj/device.dmi'
	icon_state = "motion2"
	origin_tech = list(TECH_DATA = 2, TECH_MAGNET = 2)

	proc/get_mecha_info()
		var/obj/mecha/M = src.loc
		if(!in_mecha())
			return 0
		var/cell_charge = M.get_charge()
		var/answer = {"<b>Name:</b> [M.name]<br>
							<b>Integrity:</b> [M.health/initial(M.health)*100]%<br>
							<b>Cell charge:</b> [isnull(cell_charge)?"Not found":"[M.cell.percent()]%"]<br>
							<b>Airtank:</b> [M.return_pressure()]kPa<br>
							<b>Pilot:</b> [M.occupant||"None"]<br>
							<b>Location:</b> [get_area(M)||"Unknown"]<br>
							<b>Active equipment:</b> [M.selected||"None"]"}
		if(istype(M, /obj/mecha/working/ripley))
			var/obj/mecha/working/ripley/RM = M
			answer += "<b>Used cargo space:</b> [RM.cargo.len/RM.cargo_capacity*100]%<br>"

		return answer

	emp_act()
		qdel(src)
		return

	ex_act()
		qdel(src)
		return

	proc/in_mecha()
		if(istype(src.loc, /obj/mecha))
			return src.loc
		return 0

	proc/shock()
		var/obj/mecha/M = in_mecha()
		if(M)
			M.emp_act(2)
		qdel(src)

	proc/get_mecha_log()
		if(!src.in_mecha())
			return 0
		var/obj/mecha/M = src.loc
		return M.get_log_html()


/obj/structure/closet/crate/mechabeacons
	name = "exosuit tracking beacons crate"

/obj/structure/closet/crate/mechabeacons/WillContain()
	return list(/obj/item/mecha_parts/mecha_tracking = 7)
