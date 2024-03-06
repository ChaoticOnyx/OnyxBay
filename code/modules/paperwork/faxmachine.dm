GLOBAL_LIST_EMPTY(allfaxes)
GLOBAL_LIST_EMPTY(alldepartments)

GLOBAL_LIST_EMPTY(adminfaxes)	//cache for faxes that have been sent to admins

#define FAX_PRINT_COOLDOWN 30 SECONDS
#define FAX_SEND_COOLDOWN 60 SECONDS

/obj/machinery/photocopier/faxmachine
	name = "fax machine"
	icon = 'icons/obj/library.dmi'
	icon_state = "fax"
	insert_anim = "faxsend"
	req_one_access = list(access_iaa, access_heads, access_armory, access_qm)

	idle_power_usage = 30 WATTS
	active_power_usage = 200 WATTS
	layer = BELOW_OBJ_LAYER

	var/obj/item/card/id/inserted_id
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
	if(!destination)
		destination = "[GLOB.using_map.boss_name]"
	if(!(("[department]" in GLOB.alldepartments) || ("[department]" in admin_departments)))
		GLOB.alldepartments |= department

/obj/machinery/photocopier/faxmachine/Destroy()
	QDEL_NULL(inserted_id)
	GLOB.allfaxes -= src
	return ..()

/obj/machinery/photocopier/faxmachine/attack_hand(mob/user)
	if(inoperable(MAINT))
		return

	if(user.lying || user.is_ic_dead())
		return

	tgui_interact(user)

/obj/machinery/photocopier/faxmachine/tgui_state(mob/user)
	return GLOB.tgui_machinery_noaccess_state

/obj/machinery/photocopier/faxmachine/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Fax")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/photocopier/faxmachine/tgui_data(mob/user)
	var/list/data = list(
		"user" = user?.name,
		"idCard" = inserted_id?.registered_name,
		"isAuthenticated" = check_access(inserted_id),
		"paper" = copyitem?.name,
		"printCooldown" = print_cooldown,
		"canSend" = (world.time > sendcooldown ? TRUE : FALSE)
	)

	var/list/possible_destinations = GLOB.alldepartments + admin_departments

	for(var/fax in possible_destinations)
		var/list/faxlist = list(
			"fax_name" = fax
		)
		data["faxes"] += list(faxlist)

	return data

/obj/machinery/photocopier/faxmachine/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return TRUE

	switch(action)
		if("idInteract")
			if(inserted_id)
				if(ishuman(usr))
					usr.pick_or_drop(inserted_id, loc)
					inserted_id = null
				else
					inserted_id.forceMove(loc)
					inserted_id = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/card/id) && usr.drop(I, src))
					inserted_id = I
			return TRUE
		if("paperInteract")
			if(copyitem)
				usr.pick_or_drop(copyitem, loc)
				to_chat(usr, SPAN_NOTICE("You take \the [copyitem] out of \the [src]."))
				copyitem = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(!istype(I, /obj/item/paper) && !istype(I, /obj/item/photo) && !istype(I, /obj/item/paper_bundle) && !istype(copyitem, /obj/item/complaint_folder))
					return

				if(!usr.drop(I, src))
					return

				copyitem = I
				to_chat(usr, SPAN_NOTICE("You insert \the [I] into \the [src]."))
				flick(insert_anim, src)
			return TRUE
		if("print_kit")
			if(world.time < print_cooldown)
				return

			playsound(src.loc, 'sound/signals/processing20.ogg', 25)
			var/id = IAAJ_generate_fake_id()
			new /obj/item/complaint_folder(src.loc, id)
			print_cooldown = world.time + FAX_PRINT_COOLDOWN
			return TRUE
		if("send")
			if(world.time < sendcooldown)
				return

			if(params["destination"] in admin_departments)
				playsound(src.loc, 'sound/signals/processing19.ogg', 25)
				INVOKE_ASYNC(src, send_admin_fax(.proc/sendfax), usr, params["destination"])
			else if(params["destination"] in GLOB.alldepartments)
				playsound(src.loc, 'sound/signals/processing19.ogg', 25)
				INVOKE_ASYNC(src, nameof(.proc/sendfax), params["destination"])
			return TRUE

/obj/machinery/photocopier/faxmachine/proc/sendfax(destination)
	if(stat & (BROKEN|NOPOWER))
		return

	use_power_oneoff(200)
	sendcooldown = world.time + FAX_SEND_COOLDOWN

	for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
		if(F.department != destination)
			continue

		if(F.recievefax(copyitem))
			show_splash_text(usr, "nessage transmitted successfully")

	show_splash_text(usr, "error transmitting message")

/obj/machinery/photocopier/faxmachine/proc/recievefax(obj/item/incoming)
	if(stat & (BROKEN|NOPOWER))
		return FALSE

	if(department == "Unknown")
		return FALSE

	flick("faxreceive", src)
	playsound(loc, 'sound/machines/dotprinter.ogg', 50, 1)

	// give the sprite some time to flick
	sleep(20)

	if(istype(incoming, /obj/item/paper))
		copy(incoming)
	else if(istype(incoming, /obj/item/photo))
		photocopy(incoming)
	else if(istype(incoming, /obj/item/paper_bundle))
		bundlecopy(incoming)
	else
		return FALSE

	use_power_oneoff(active_power_usage)
	return TRUE

/obj/machinery/photocopier/faxmachine/proc/send_admin_fax(mob/sender, destination)
	if(stat & (BROKEN|NOPOWER))
		return

	use_power_oneoff(200)

	sendcooldown = world.time + FAX_SEND_COOLDOWN

	//recieved copies should not use toner since it's being used by admins only.
	var/obj/item/rcvdcopy
	if (istype(copyitem, /obj/item/paper))
		rcvdcopy = copy(copyitem, 0)
	else if (istype(copyitem, /obj/item/photo))
		rcvdcopy = photocopy(copyitem, 0)
	else if (istype(copyitem, /obj/item/paper_bundle))
		rcvdcopy = bundlecopy(copyitem, 0)
	else if (istype(copyitem, /obj/item/complaint_folder))
		var/obj/item/complaint_folder/CF = copyitem
		var/fail_reason = CF.prevalidate()
		if (fail_reason)
			show_splash_text(usr, "error transmitting message")
			return
		rcvdcopy = complaintcopy(copyitem, 0)
	else
		show_splash_text(usr, "error transmitting message")
		return

	rcvdcopy.forceMove(null) //hopefully this shouldn't cause trouble
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

	var/obj/item/complaint_folder/CF = rcvdcopy
	if (istype(CF))
		var/fail_reason = CF.validate()
		if (fail_reason)
			message_admins("Complaint automatically rejected: [fail_reason].")
		else
			fail_reason = CF.postvalidate()
			if (fail_reason)
				message_admins("Complaint postvalidation failed: [fail_reason]. Check received fax to manually correct it.")

	sleep(50)
	show_splash_text(usr, "message transmitted successfully")

/obj/machinery/photocopier/faxmachine/proc/fax_message_admins(mob/sender, faxname, obj/item/sent, reply_type, font_colour="#006100")
	var/msg = "<span class='notice'><b><font color='[font_colour]'>[faxname]: </font>[get_options_bar(sender, 2,1,1)]"
	msg += "(<A HREF='?_src_=holder;take_ic=\ref[sender]'>TAKE</a>) (<a href='?_src_=holder;FaxReply=\ref[sender];originfax=\ref[src];replyorigin=[reply_type]'>REPLY</a>)</b>: "
	msg += "Receiving '[sent.name]' via secure connection ... <a href='?_src_=holder;AdminFaxView=\ref[sent]'>view message</a></span>"

	for(var/client/C in GLOB.admins)
		if(check_rights((R_ADMIN|R_MOD),0,C))
			to_chat(C, msg)
			sound_to(C, sound('sound/machines/dotprinter.ogg'))
