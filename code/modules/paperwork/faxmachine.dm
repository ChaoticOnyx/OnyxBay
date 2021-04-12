GLOBAL_LIST_EMPTY(allfaxes)
GLOBAL_LIST_EMPTY(alldepartments)

GLOBAL_LIST_EMPTY(adminfaxes)	//cache for faxes that have been sent to admins

/obj/machinery/photocopier/faxmachine
	name = "fax machine"
	icon = 'icons/obj/library.dmi'
	icon_state = "fax"
	insert_anim = "faxsend"
	req_one_access = list(access_lawyer, access_heads, access_armory, access_qm)

	idle_power_usage = 30
	active_power_usage = 200
	layer = BELOW_OBJ_LAYER

	var/obj/item/weapon/card/id/scan = null // identification
	var/authenticated = 0
	var/sendcooldown = 0 // to avoid spamming fax messages
	var/print_cooldown = 0 //to avoid spamming printing complaints
	var/department = "Unknown" // our department
	var/destination = null // the department we're sending to

	var/static/list/admin_departments

/obj/machinery/photocopier/faxmachine/Initialize()
	. = ..()

	if(!admin_departments)
		admin_departments = list("[GLOB.using_map.boss_name]", "Colonial Marshal Service", "[GLOB.using_map.boss_short] Supply") + GLOB.using_map.map_admin_faxes
	GLOB.allfaxes += src
	if(!destination) destination = "[GLOB.using_map.boss_name]"
	if( !(("[department]" in GLOB.alldepartments) || ("[department]" in admin_departments)))
		GLOB.alldepartments |= department

/obj/machinery/photocopier/faxmachine/attack_hand(mob/user as mob)
	user.set_machine(src)

	var/dat = "<meta charset=\"utf-8\">Fax Machine<BR>"

	var/scan_name
	if(scan)
		scan_name = scan.name
	else
		scan_name = "--------"

	dat += "Confirm Identity: <a href='byond://?src=\ref[src];scan=1'>[scan_name]</a><br>"

	if(authenticated)
		dat += "<a href='byond://?src=\ref[src];logout=1'>{Log Out}</a>"
	else
		dat += "<a href='byond://?src=\ref[src];auth=1'>{Log In}</a>"

	dat += "<hr>"

	if(authenticated)
		dat += "<b>Logged in to:</b> [GLOB.using_map.boss_name] Quantum Entanglement Network<br><br>"

		if(copyitem)
			dat += "<a href='byond://?src=\ref[src];remove=1'>Remove Item</a><br><br>"

			if(sendcooldown)
				dat += "<b>Transmitter arrays realigning. Please stand by.</b><br>"

			else

				dat += "<a href='byond://?src=\ref[src];send=1'>Send</a><br>"
				dat += "<b>Currently sending:</b> [copyitem.name]<br>"
				dat += "<b>Sending to:</b> <a href='byond://?src=\ref[src];dept=1'>[destination]</a><br>"

		else
			if(sendcooldown)
				dat += "Please insert paper to send via secure connection.<br><br>"
				dat += "<b>Transmitter arrays realigning. Please stand by.</b><br>"
			else
				dat += "Please insert paper to send via secure connection.<br><br>"
		if (print_cooldown)
			dat += "<b> Complaint printer is recharging. Please stand by. </b><br>"
		else
			dat += "<a href ='byond://?src=\ref[src];print_complaint=1'>Print complaint kit</a><br>"
	else
		dat += "Proper authentication is required to use this device.<br><br>"

		if(copyitem)
			dat += "<a href ='byond://?src=\ref[src];remove=1'>Remove Item</a><br>"


	user << browse(dat, "window=copier")
	onclose(user, "copier")
	return

/obj/machinery/photocopier/faxmachine/proc/print_cooldown_check()
	if (print_cooldown)
		return
	print_cooldown = 30 SECONDS
	addtimer(CALLBACK(src, .go_off_print_cooldown), print_cooldown)
	return TRUE

/obj/machinery/photocopier/faxmachine/proc/go_off_print_cooldown()
	print_cooldown = 0

/obj/machinery/photocopier/faxmachine/Topic(href, href_list)
	. = ..()
	if (. != TOPIC_NOACTION)
		return
	if(href_list["print_complaint"])
		if (print_cooldown_check())
			playsound(src.loc, 'sound/signals/processing20.ogg', 25)
			var/id = IAAJ_generate_fake_id()
			ASSERT(id)
			new /obj/item/weapon/complaint_folder(src.loc, id)
			. =  TOPIC_HANDLED
	if(href_list["send"])
		if(copyitem)
			if (destination in admin_departments)
				playsound(src.loc, 'sound/signals/processing19.ogg', 25)
				send_admin_fax(usr, destination)
			else
				playsound(src.loc, 'sound/signals/processing19.ogg', 25)
				sendfax(destination)

			if (sendcooldown)
				spawn(sendcooldown) // cooldown time
					sendcooldown = 0

	else if(href_list["remove"])
		if(copyitem)
			copyitem.loc = usr.loc
			usr.put_in_hands(copyitem)
			to_chat(usr, "<span class='notice'>You take \the [copyitem] out of \the [src].</span>")
			copyitem = null
			updateUsrDialog()

	if(href_list["scan"])
		if (scan)
			if(ishuman(usr))
				scan.loc = usr.loc
				if(!usr.get_active_hand())
					usr.put_in_hands(scan)
				scan = null
			else
				scan.loc = src.loc
				scan = null
		else
			var/obj/item/I = usr.get_active_hand()
			if (istype(I, /obj/item/weapon/card/id) && usr.unEquip(I))
				I.loc = src
				scan = I
		authenticated = 0

	if(href_list["dept"])
		var/lastdestination = destination
		destination = input(usr, "Which department?", "Choose a department", "") as null|anything in (GLOB.alldepartments + admin_departments)
		if(!destination) destination = lastdestination

	if(href_list["auth"])
		if ( (!( authenticated ) && (scan)) )
			if (check_access(scan))
				authenticated = 1

	if(href_list["logout"])
		authenticated = 0

	updateUsrDialog()

/obj/machinery/photocopier/faxmachine/proc/sendfax(destination)
	if(stat & (BROKEN|NOPOWER))
		return

	use_power_oneoff(200)

	var/success = 0
	for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
		if( F.department == destination )
			success = F.recievefax(copyitem)

	if (success)
		visible_message("[src] beeps, \"Message transmitted successfully.\"")
		//sendcooldown = 600
	else
		visible_message("[src] beeps, \"Error transmitting message.\"")

/obj/machinery/photocopier/faxmachine/proc/recievefax(obj/item/incoming)
	if(stat & (BROKEN|NOPOWER))
		return 0

	if(department == "Unknown")
		return 0	//You can't send faxes to "Unknown"

	flick("faxreceive", src)
	playsound(loc, 'sound/machines/dotprinter.ogg', 50, 1)

	// give the sprite some time to flick
	sleep(20)

	if (istype(incoming, /obj/item/weapon/paper))
		copy(incoming)
	else if (istype(incoming, /obj/item/weapon/photo))
		photocopy(incoming)
	else if (istype(incoming, /obj/item/weapon/paper_bundle))
		bundlecopy(incoming)
	else
		return 0

	use_power_oneoff(active_power_usage)
	return 1

/obj/machinery/photocopier/faxmachine/proc/send_admin_fax(mob/sender, destination)
	if(stat & (BROKEN|NOPOWER))
		return

	use_power_oneoff(200)

	//recieved copies should not use toner since it's being used by admins only.
	var/obj/item/rcvdcopy
	if (istype(copyitem, /obj/item/weapon/paper))
		rcvdcopy = copy(copyitem, 0)
	else if (istype(copyitem, /obj/item/weapon/photo))
		rcvdcopy = photocopy(copyitem, 0)
	else if (istype(copyitem, /obj/item/weapon/paper_bundle))
		rcvdcopy = bundlecopy(copyitem, 0)
	else if (istype(copyitem, /obj/item/weapon/complaint_folder))
		var/obj/item/weapon/complaint_folder/CF = copyitem
		var/fail_reason = CF.prevalidate()
		if (fail_reason)
			visible_message("[src] beeps, \"Error transmitting message: [fail_reason].\"")
			sendcooldown = 100 //here to prevent spam
			return
		rcvdcopy = complaintcopy(copyitem, 0)
	else
		visible_message("[src] beeps, \"Error transmitting message.\"")
		return

	rcvdcopy.loc = null //hopefully this shouldn't cause trouble
	GLOB.adminfaxes += rcvdcopy

	var/mob/intercepted = check_for_interception()


	//message badmins that a fax has arrived
	var/msg_color = null
	if (destination == GLOB.using_map.boss_name)
		msg_color = "#006100"
	else if (destination == "Colonial Marshal Service")
		msg_color = "#1f66a0"
	else if (destination == "[GLOB.using_map.boss_short] Supply")
		msg_color = "#5f4519"
	else if (destination in GLOB.using_map.map_admin_faxes)
		msg_color = "#510b74"
	else
		destination = "UNKNOWN"

	fax_message_admins(sender, "[uppertext(destination)] FAX[intercepted ? "(Intercepted by [intercepted])" : null]", rcvdcopy, destination, msg_color)

	var/obj/item/weapon/complaint_folder/CF = rcvdcopy
	if (istype(CF))
		var/fail_reason = CF.validate()
		if (fail_reason)
			message_admins("Complaint automatically rejected: [fail_reason].")
		else
			fail_reason = CF.postvalidate()
			if (fail_reason)
				message_admins("Complaint postvalidation failed: [fail_reason]. Check received fax to manually correct it.")

	sendcooldown = 1800
	sleep(50)
	visible_message("[src] beeps, \"Message transmitted successfully.\"")


/obj/machinery/photocopier/faxmachine/proc/fax_message_admins(mob/sender, faxname, obj/item/sent, reply_type, font_colour="#006100")
	var/msg = "<span class='notice'><b><font color='[font_colour]'>[faxname]: </font>[get_options_bar(sender, 2,1,1)]"
	msg += "(<A HREF='?_src_=holder;take_ic=\ref[sender]'>TAKE</a>) (<a href='?_src_=holder;FaxReply=\ref[sender];originfax=\ref[src];replyorigin=[reply_type]'>REPLY</a>)</b>: "
	msg += "Receiving '[sent.name]' via secure connection ... <a href='?_src_=holder;AdminFaxView=\ref[sent]'>view message</a></span>"

	for(var/client/C in GLOB.admins)
		if(check_rights((R_ADMIN|R_MOD),0,C))
			to_chat(C, msg)
			sound_to(C, 'sound/machines/dotprinter.ogg')
