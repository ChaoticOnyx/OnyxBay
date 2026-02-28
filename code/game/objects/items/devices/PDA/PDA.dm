
//The advanced pea-green monochrome lcd of tomorrow.

var/global/list/obj/item/device/pda/PDAs = list()

/obj/item/device/pda
	name = "\improper PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_ID | SLOT_BELT

	//Main variables
	var/owner = null
	var/default_cartridge = 0 // Access level defined by cartridge
	var/obj/item/cartridge/cartridge = null //current cartridge
	var/mode = PDA_MODE_HOME // Controls what menu the PDA will display.

	var/lastmode = PDA_MODE_HOME
	var/ui_tick = 0
	var/list/tgui_cache = list()

	//Secondary variables
	var/scanmode = PDA_SCANMODE_NONE // 1 is medical scanner, 2 is forensics, 3 is reagent scanner.
	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 3 //Luminosity for the flashlight function
	var/message_silent = 0 //To beep or not to beep, that is the question
	var/news_silent = 1 //To beep or not to beep, that is the question.  The answer is No.
	var/toff = 0 //If 1, messenger disabled
	var/tnote[0]  //Current Texts
	var/last_text //No text spamming
	var/last_honk //Also no honk spamming that's bad too
	var/ttone = "beep" //The PDA ringtone!
	var/newstone = "beep, beep" //The news ringtone!
	var/lock_code = "" // Lockcode to unlock uplink
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/note = "Thank you for choosing the Thinktronic 5230 Personal Data Assistant!" //Current note in the notepad function
	var/notehtml = ""
	var/cart = "" //A place to stick cartridge menu information
	var/detonate = 1 // Can the PDA be blown up?
	var/hidden = 0 // Is the PDA hidden from the PDA list?
	var/active_conversation = null // New variable that allows us to only view a single conversation.
	var/list/conversations = list()    // For keeping up with who we have PDA messsages from.
	var/new_message = 0			//To remove hackish overlay check
	var/new_news = 0
	var/list/tempmessage = list() // Used to store message in memory if sending failed

	var/active_feed				// The selected feed
	var/list/warrant			// The warrant as we last knew it
	var/list/feeds = list()		// The list of feeds as we last knew them
	var/list/feed_info = list()	// The data and contents of each feed as we last knew them

	var/list/cartmodes = list(PDA_MODE_SIGNALER, PDA_MODE_STATUS_DISPLAY, PDA_MODE_POWER_MONITOR, PDA_MODE_POWER_MONITOR_READING, PDA_MODE_MEDICAL_RECORDS, PDA_MODE_MEDICAL_RECORD, PDA_MODE_SECURITY_RECORDS, PDA_MODE_SECURITY_RECORD, PDA_MODE_SECURITY_BOT, PDA_MODE_MULE_CONTROL, PDA_MODE_SUPPLY_RECORDS, PDA_MODE_JANITOR_LOCATOR)
	var/list/no_auto_update = list(PDA_MODE_NOTES, PDA_MODE_SIGNALER, PDA_MODE_POWER_MONITOR, PDA_MODE_MEDICAL_RECORDS, PDA_MODE_MEDICAL_RECORD, PDA_MODE_SECURITY_RECORDS, PDA_MODE_SECURITY_RECORD)
	var/list/update_every_five = list(PDA_MODE_ATMOS_SCAN, PDA_MODE_CREW_MANIFEST, PDA_MODE_POWER_MONITOR_READING, PDA_MODE_SECURITY_BOT, PDA_MODE_SUPPLY_RECORDS, PDA_MODE_MULE_CONTROL, PDA_MODE_JANITOR_LOCATOR)

	var/obj/item/card/id/id = null //Making it possible to slot an ID card into the PDA so it can function as both.
	var/ownjob = null //related to above - this is assignment (potentially alt title)
	var/ownrank = null // this one is rank, never alt title
	var/pen = /obj/item/pen //determines what kind of pen spawns in a PDA

	var/obj/item/device/paicard/pai = null	// A slot for a personal AI device

/obj/item/device/pda/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) <= 1)
		. += "The time [stationtime2text()] is displayed in the corner of the screen."

/obj/item/device/pda/medical
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-m"

/obj/item/device/pda/viro
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-v"

/obj/item/device/pda/engineering
	default_cartridge = /obj/item/cartridge/engineering
	icon_state = "pda-e"

/obj/item/device/pda/security
	default_cartridge = /obj/item/cartridge/security
	icon_state = "pda-s"

/obj/item/device/pda/detective
	default_cartridge = /obj/item/cartridge/detective
	icon_state = "pda-det"

/obj/item/device/pda/warden
	default_cartridge = /obj/item/cartridge/security
	icon_state = "pda-warden"

/obj/item/device/pda/janitor
	default_cartridge = /obj/item/cartridge/janitor
	icon_state = "pda-j"
	ttone = "slip"

/obj/item/device/pda/science
	default_cartridge = /obj/item/cartridge/signal/science
	icon_state = "pda-tox"
	ttone = "boom"

/obj/item/device/pda/clown
	default_cartridge = /obj/item/cartridge/clown
	icon_state = "pda-clown"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	ttone = "honk"

/obj/item/device/pda/mime
	default_cartridge = /obj/item/cartridge/mime
	icon_state = "pda-mime"
	message_silent = 1
	news_silent = 1
	ttone = "silence"
	newstone = "silence"

/obj/item/device/pda/heads
	default_cartridge = /obj/item/cartridge/head
	icon_state = "pda-h"
	news_silent = 1

/obj/item/device/pda/heads/paperpusher
	pen = /obj/item/pen/fancy

/obj/item/device/pda/heads/hop
	default_cartridge = /obj/item/cartridge/hop
	icon_state = "pda-hop"

/obj/item/device/pda/heads/hos
	default_cartridge = /obj/item/cartridge/hos
	icon_state = "pda-hos"

/obj/item/device/pda/heads/ce
	default_cartridge = /obj/item/cartridge/ce
	icon_state = "pda-ce"

/obj/item/device/pda/heads/cmo
	default_cartridge = /obj/item/cartridge/cmo
	icon_state = "pda-cmo"

/obj/item/device/pda/heads/rd
	default_cartridge = /obj/item/cartridge/rd
	icon_state = "pda-rd"

/obj/item/device/pda/captain
	default_cartridge = /obj/item/cartridge/captain
	icon_state = "pda-c"
	detonate = 0
	//toff = 1

/obj/item/device/pda/ert
	default_cartridge = /obj/item/cartridge/captain
	icon_state = "pda-h"
	detonate = 0
	hidden = 1

/obj/item/device/pda/cargo
	default_cartridge = /obj/item/cartridge/quartermaster
	icon_state = "pda-cargo"

/obj/item/device/pda/quartermaster
	default_cartridge = /obj/item/cartridge/quartermaster
	icon_state = "pda-q"

/obj/item/device/pda/shaftminer
	icon_state = "pda-miner"

/obj/item/device/pda/syndicate
	default_cartridge = /obj/item/cartridge/syndicate
	icon_state = "pda-syn"
	name = "Military PDA"
	owner = "John Doe"
	hidden = 1

/obj/item/device/pda/ninja
	icon_state = "pda-syn"
	name = "Stealth PDA"
	owner = "John Doe"
	hidden = 1

/obj/item/device/pda/chaplain
	icon_state = "pda-holy"
	ttone = "holy"

/obj/item/device/pda/iaa
	default_cartridge = /obj/item/cartridge/lawyer
	icon_state = "pda-iaa"
	ttone = "..."

/obj/item/device/pda/lawyer
	default_cartridge = /obj/item/cartridge/lawyer
	icon_state = "pda-lawyer"
	ttone = "OBJECTION!"

/obj/item/device/pda/botanist
	//default_cartridge = /obj/item/cartridge/botanist
	icon_state = "pda-hydro"

/obj/item/device/pda/roboticist
	icon_state = "pda-robot"

/obj/item/device/pda/librarian
	icon_state = "pda-libb"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a WGW-11 series e-reader."
	note = "Thank you for choosing the Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant!"
	message_silent = 1 //Quiet in the library!
	news_silent = 0		// Librarian is above the law!  (That and alt job title is reporter)

/obj/item/device/pda/clear
	icon_state = "pda-transp"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a special edition with a transparent case."
	note = "Thank you for choosing the Thinktronic 5230 Personal Data Assistant Deluxe Special Max Turbo Limited Edition!"

/obj/item/device/pda/chef
	icon_state = "pda-chef"

/obj/item/device/pda/bar
	icon_state = "pda-bar"

/obj/item/device/pda/atmos
	default_cartridge = /obj/item/cartridge/atmos
	icon_state = "pda-atmo"

/obj/item/device/pda/chemist
	default_cartridge = /obj/item/cartridge/chemistry
	icon_state = "pda-chem"

/obj/item/device/pda/geneticist
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-gene"

// Special AI/pAI PDAs that cannot explode.
/obj/item/device/pda/ai
	icon_state = "NONE"
	ttone = "data"
	newstone = "news"
	detonate = 0


/obj/item/device/pda/ai/proc/set_name_and_job(newname as text, newjob as text, newrank as null|text)
	owner = newname
	ownjob = newjob
	if(newrank)
		ownrank = newrank
	else
		ownrank = ownjob
	SetName(newname + " (" + ownjob + ")")


//AI verb and proc for sending PDA messages.
/obj/item/device/pda/ai/verb/cmd_send_pdamesg()
	set category = "AI IM"
	set name = "Send Message"
	set src in usr
	if(usr.stat == 2)
		to_chat(usr, "You can't send PDA messages because you are dead!")
		return
	var/list/plist = available_pdas()
	if (plist)
		var/c = input(usr, "Please select a PDA") as null|anything in sortList(plist)
		if (!c) // if the user hasn't selected a PDA file we can't send a message
			return
		var/selected = plist[c]
		create_message(usr, selected, 0)


/obj/item/device/pda/ai/verb/cmd_toggle_pda_receiver()
	set category = "AI IM"
	set name = "Toggle Sender/Receiver"
	set src in usr
	if(usr.stat == 2)
		to_chat(usr, "You can't do that because you are dead!")
		return
	toff = !toff
	to_chat(usr, "<span class='notice'>PDA sender/receiver toggled [(toff ? "Off" : "On")]!</span>")


/obj/item/device/pda/ai/verb/cmd_toggle_pda_silent()
	set category = "AI IM"
	set name = "Toggle Ringer"
	set src in usr
	if(usr.stat == 2)
		to_chat(usr, "You can't do that because you are dead!")
		return
	message_silent=!message_silent
	to_chat(usr, "<span class='notice'>PDA ringer toggled [(message_silent ? "Off" : "On")]!</span>")


/obj/item/device/pda/ai/verb/cmd_show_message_log()
	set category = "AI IM"
	set name = "Show Message Log"
	set src in usr
	if(usr.stat == 2)
		to_chat(usr, "You can't do that because you are dead!")
		return
	var/HTML = "<html><meta charset=\"utf-8\"><head><title>AI PDA Message Log</title></head><body>"
	for(var/index in tnote)
		if(index["sent"])
			HTML += addtext("<i><b>&rarr; To ", index["owner"], ":</b></i><br>", index["message"], "<br>")
		else
			HTML += addtext("<i><b>&larr; From ", index["owner"], ":</b></i><br>", index["message"], "<br>")
	HTML +="</body></html>"
	show_browser(usr, HTML, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")


/obj/item/device/pda/ai/can_use()
	return 1


/obj/item/device/pda/ai/attack_self(mob/user as mob)
	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)
	return


/obj/item/device/pda/ai/pai
	ttone = "assist"


/*
 *	The Actual PDA
 */

/obj/item/device/pda/New()
	..()
	PDAs += src
	PDAs = sortAtom(PDAs)
	if(default_cartridge)
		cartridge = new default_cartridge(src)
	new pen(src)

/obj/item/device/pda/proc/can_use()

	if(!ismob(loc))
		return 0

	var/mob/M = loc
	if(M.stat || M.restrained() || M.paralysis || M.stunned || M.weakened)
		return 0
	if((src in M.contents) || ( istype(loc, /turf) && in_range(src, M) ))
		return 1
	else
		return 0

/obj/item/device/pda/proc/toggle_light()
	if(can_use())
		if(fon)
			fon = 0
			set_light(0)
		else
			fon = 1
			set_light(0.25, 0.1, 2, 3, "#5cceed")

/obj/item/device/pda/GetAccess()
	if(id)
		return id.GetAccess()
	else
		return ..()

/obj/item/device/pda/get_id_card()
	return id

/obj/item/device/pda/MouseDrop(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /atom/movable/screen)) && can_use())
		return attack_self(M)
	return

/obj/item/device/pda/get_examine_line(examine_distance = 10)
	var/visible_name = examine_distance < 3 ? name : initial(name)
	if(is_bloodied)
		. = SPAN("warning", "\icon[src] a [(blood_color != SYNTH_BLOOD_COLOUR) ? "blood" : "oil"]-stained [SPAN("info", "<em>[visible_name]</em>")]")
	else
		. = "\icon[src] \a [SPAN("info", "<em>[visible_name]</em>")]"

/obj/item/device/pda/proc/build_tgui_data(mob/user)
	ui_tick++
	if((mode == lastmode) && ui_tick % 5 && (mode in update_every_five))
		return null

	lastmode = mode

	var/data[0]
	data["owner"] = owner
	data["ownjob"] = ownjob
	data["mode"] = mode
	data["scanmode"] = scanmode
	data["fon"] = fon
	data["pai"] = (isnull(pai) ? 0 : 1)
	data["note"] = note
	data["message_silent"] = message_silent
	data["news_silent"] = news_silent
	data["toff"] = toff
	data["ttone"] = ttone
	data["active_conversation"] = active_conversation
	data["skinType"] = icon_state
	data["idInserted"] = (id ? 1 : 0)
	data["idLink"] = (id ? text("[id.registered_name], [id.assignment]") : "--------")

	data["cart_loaded"] = cartridge ? 1 : 0
	if(cartridge)
		var/cartdata[0]
		cartdata["icon_state"] = cartridge.icon_state
		cartdata["access"] = list(\
			"access_security" = cartridge.access_security,\
			"access_engine" = cartridge.access_engine,\
			"access_atmos" = cartridge.access_atmos,\
			"access_medical" = cartridge.access_medical,\
			"access_clown" = cartridge.access_clown,\
			"access_mime" = cartridge.access_mime,\
			"access_janitor" = cartridge.access_janitor,\
			"access_quartermaster" = cartridge.access_quartermaster,\
			"access_hydroponics" = cartridge.access_hydroponics,\
			"access_reagent_scanner" = cartridge.access_reagent_scanner,\
			"access_remote_door" = cartridge.access_remote_door,\
			"access_status_display" = cartridge.access_status_display,\
			"access_detonate_pda" = cartridge.access_detonate_pda\
		)
		cartdata["remote_door_id"] = cartridge.remote_door_id

		if(mode in cartmodes)
			data["records"] = cartridge.create_tgui_values(user)

		if(mode == PDA_MODE_HOME)
			cartdata["name"] = cartridge.name
			if(QDELETED(cartridge.radio))
				cartdata["radio"] = 0
			else
				if(istype(cartridge.radio, /obj/item/radio/integrated/beepsky))
					cartdata["radio"] = 1
				if(istype(cartridge.radio, /obj/item/radio/integrated/signal))
					cartdata["radio"] = 2

		if(mode == PDA_MODE_MESSENGER || mode == PDA_MODE_MESSENGER_CONVERSATION)
			cartdata["charges"] = cartridge.charges ? cartridge.charges : 0
		data["cartridge"] = cartdata

	data["stationTime"] = stationtime2text()
	data["new_Message"] = new_message
	data["new_News"] = new_news

	var/datum/reception/reception = get_reception(src, do_sleep = 0)
	var/has_reception = reception && (reception.telecomms_reception & TELECOMMS_RECEPTION_SENDER)
	data["reception"] = has_reception

	if(mode == PDA_MODE_CREW_MANIFEST)
		data["crew_manifest"] = html_crew_manifest(1, 0)

	if(mode == PDA_MODE_MESSENGER || mode == PDA_MODE_MESSENGER_CONVERSATION)
		var/convopdas[0]
		var/pdas[0]
		var/count = 0
		for(var/obj/item/device/pda/P in PDAs)
			if(!P.owner || P.toff || P == src || P.hidden)
				continue
			if(conversations.Find("\ref[P]"))
				convopdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "1")))
			else
				pdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "0")))
			count++

		data["convopdas"] = convopdas
		data["pdas"] = pdas
		data["pda_count"] = count

	if(mode == PDA_MODE_MESSENGER_CONVERSATION)
		data["messagescount"] = tnote.len
		data["messages"] = tnote
	else
		data["messagescount"] = null
		data["messages"] = null

	if(active_conversation)
		for(var/c in tnote)
			if(c["target"] == active_conversation)
				data["convo_name"] = sanitize(c["owner"])
				data["convo_job"] = sanitize(c["job"])
				break

	if(mode == PDA_MODE_ATMOS_SCAN)
		var/turf/T = get_turf(user.loc)
		if(!isnull(T))
			var/datum/gas_mixture/environment = T.return_air()
			var/pressure = environment.return_pressure()
			var/total_moles = environment.total_moles

			if(total_moles)
				var/o2_level = environment.gas["oxygen"] / total_moles
				var/n2_level = environment.gas["nitrogen"] / total_moles
				var/co2_level = environment.gas["carbon_dioxide"] / total_moles
				var/unknown_level = 1 - (o2_level + n2_level + co2_level)
				data["aircontents"] = list(\
					"pressure" = "[round(pressure,0.1)]",\
					"nitrogen" = "[round(n2_level*100,0.1)]",\
					"oxygen" = "[round(o2_level*100,0.1)]",\
					"carbon_dioxide" = "[round(co2_level*100,0.1)]",\
					"other" = "[round(unknown_level*100,0.01)]",\
					"temp" = "[round(CONV_KELVIN_CELSIUS(environment.temperature),0.1)]",\
					"reading" = 1\
				)
		if(isnull(data["aircontents"]))
			data["aircontents"] = list("reading" = 0)

	if(mode == PDA_MODE_NEWS_FEED)
		if(has_reception)
			feeds.Cut()
			for(var/datum/feed_channel/channel in news_network.network_channels)
				feeds[++feeds.len] = list("name" = channel.channel_name, "censored" = channel.censored, "feed" = "\ref[channel]")
		data["feedChannels"] = feeds

	if(mode == PDA_MODE_NEWS_FEED_CHANNEL)
		var/datum/feed_channel/FC
		for(FC in news_network.network_channels)
			if(FC.channel_name == active_feed["name"])
				break

		if(FC)
			var/list/feed = feed_info[active_feed]
			if(!feed)
				feed = list()
				feed["channel"] = FC.channel_name
				feed["author"] = "Unknown"
				feed["censored"] = 0
				feed["updated"] = -1
				feed["views"] = 0
				feed_info[active_feed] = feed

			if(FC.updated > feed["updated"] && has_reception)
				feed["author"] = FC.author
				feed["updated"] = FC.updated
				feed["views"] = ++FC.views
				feed["censored"] = FC.censored

				var/list/messages = list()
				if(!FC.censored)
					var/index = 0
					for(var/datum/feed_message/FM in FC.messages)
						++index
						if(FM.img)
							ASSERT(user.client)
							send_asset(user.client, "newscaster_photo_[FC.channel_id]_[index].png")
						var/body = replacetext(FM.body, "\n", "<br>")
						messages[++messages.len] = list("author" = FM.author, "body" = body, "message_type" = FM.message_type, "time_stamp" = FM.time_stamp, "has_image" = (FM.img != null), "caption" = FM.caption, "index" = index)
				feed["messages"] = messages

			data["feed"] = feed

	return data

/obj/item/device/pda/tgui_data(mob/user)
	var/list/data = build_tgui_data(user)
	if(isnull(data))
		return tgui_cache
	tgui_cache = data
	return data

//NOTE: graphic resources are loaded on client login
/obj/item/device/pda/attack_self(mob/user as mob)
	var/datum/asset/assets = get_asset_datum(/datum/asset/directories/pda)
	ASSERT(user.client)
	assets.send(user.client)

	user.set_machine(src)

	var/datum/component/uplink/U = get_component(/datum/component/uplink)
	if(istype(U) && U.active)
		U.interact(user)
		return

	tgui_interact(user)
	return

/obj/item/device/pda/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PDA", "Personal Data Assistant")
		ui.open()
	ui.set_autoupdate(!(mode in no_auto_update))

/obj/item/device/pda/proc/mode_from_choice(choice)
	switch(choice)
		if("0")
			return PDA_MODE_HOME
		if("1")
			return PDA_MODE_NOTES
		if("2")
			return PDA_MODE_MESSENGER
		if("21")
			return PDA_MODE_MESSENGER_CONVERSATION
		if("3")
			return PDA_MODE_ATMOS_SCAN
		if("4")
			return PDA_MODE_HOME
		if("chatroom")
			return PDA_MODE_CHATROOM
		if("40")
			return PDA_MODE_SIGNALER
		if("41")
			return PDA_MODE_CREW_MANIFEST
		if("42")
			return PDA_MODE_STATUS_DISPLAY
		if("43")
			return PDA_MODE_POWER_MONITOR
		if("433")
			return PDA_MODE_POWER_MONITOR_READING
		if("44")
			return PDA_MODE_MEDICAL_RECORDS
		if("441")
			return PDA_MODE_MEDICAL_RECORD
		if("45")
			return PDA_MODE_SECURITY_RECORDS
		if("451")
			return PDA_MODE_SECURITY_RECORD
		if("46")
			return PDA_MODE_SECURITY_BOT
		if("47")
			return PDA_MODE_SUPPLY_RECORDS
		if("48")
			return PDA_MODE_MULE_CONTROL
		if("49")
			return PDA_MODE_JANITOR_LOCATOR
		if("6")
			return PDA_MODE_NEWS_FEED
		if("61")
			return PDA_MODE_NEWS_FEED_CHANNEL
	return null

/obj/item/device/pda/proc/set_pda_mode(new_mode)
	if(isnull(new_mode))
		return
	mode = new_mode
	if(cartridge)
		cartridge.mode = new_mode

/obj/item/device/pda/proc/handle_return_mode()
	switch(mode)
		if(PDA_MODE_MESSENGER_CONVERSATION)
			active_conversation = null
			set_pda_mode(PDA_MODE_MESSENGER)
		if(PDA_MODE_NEWS_FEED_CHANNEL)
			set_pda_mode(PDA_MODE_NEWS_FEED)
		if(PDA_MODE_POWER_MONITOR_READING)
			set_pda_mode(PDA_MODE_POWER_MONITOR)
		if(PDA_MODE_MEDICAL_RECORD)
			set_pda_mode(PDA_MODE_MEDICAL_RECORDS)
		if(PDA_MODE_SECURITY_RECORD)
			set_pda_mode(PDA_MODE_SECURITY_RECORDS)
		else
			set_pda_mode(PDA_MODE_HOME)

/obj/item/device/pda/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return TRUE

	var/mob/living/U = usr
	if(!U)
		return TRUE
	if(usr.is_ic_dead())
		return TRUE
	if(!can_use())
		U.unset_machine()
		if(ui)
			ui.close()
		return TRUE

	U.set_machine(src)

	if(action == "cartridge_action" && !QDELETED(cartridge))
		if(cartridge.tgui_handle_action(U, params["choice"], params))
			if(ui)
				ui.set_autoupdate(!(mode in no_auto_update))
			return TRUE

	if(action == "radio_action" && !QDELETED(cartridge) && !QDELETED(cartridge.radio) && istype(cartridge.radio, /obj/item/radio/integrated/beepsky))
		if(cartridge.radio:tgui_handle_action(params["op"], params))
			if(ui)
				ui.set_autoupdate(!(mode in no_auto_update))
			return TRUE

	var/choice = action
	if(action == "choice")
		choice = params["choice"]

	switch(choice)
		if("Close")
			U.unset_machine()
			if(ui)
				ui.close()
			return TRUE

		if("Refresh")
			// No-op, frontend re-renders after successful act.

		if("Return")
			handle_return_mode()

		if("Authenticate")
			id_check(U, 1)

		if("UpdateInfo")
			if(id)
				set_rank_job(id.rank, id.assignment)

		if("Eject")
			verb_remove_cartridge()

		if("Light")
			toggle_light()

		if("Medical Scan")
			if(scanmode == PDA_SCANMODE_MEDICAL)
				scanmode = PDA_SCANMODE_NONE
			else if((!QDELETED(cartridge)) && cartridge.access_medical)
				scanmode = PDA_SCANMODE_MEDICAL

		if("Reagent Scan")
			if(scanmode == PDA_SCANMODE_REAGENT)
				scanmode = PDA_SCANMODE_NONE
			else if((!QDELETED(cartridge)) && cartridge.access_reagent_scanner)
				scanmode = PDA_SCANMODE_REAGENT

		if("Halogen Counter")
			if(scanmode == PDA_SCANMODE_HALOGEN)
				scanmode = PDA_SCANMODE_NONE
			else if((!QDELETED(cartridge)) && cartridge.access_engine)
				scanmode = PDA_SCANMODE_HALOGEN

		if("Honk")
			if(!(last_honk && world.time < last_honk + 20))
				playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
				last_honk = world.time

		if("Gas Scan")
			if(scanmode == PDA_SCANMODE_GAS)
				scanmode = PDA_SCANMODE_NONE
			else if((!QDELETED(cartridge)) && cartridge.access_atmos)
				scanmode = PDA_SCANMODE_GAS

		if("Edit")
			var/n = input(U, "Please enter message", html_decode(name), notehtml)
			if(in_range(src, U) && loc == U)
				if(mode == PDA_MODE_NOTES)
					n = sanitize(n)
					note = html_decode(n)
					note = replacetext(note, "\n", "<br>")
					notehtml = n
			else if(ui)
				ui.close()

		if("Toggle Messenger")
			toff = !toff

		if("Toggle Ringer")
			message_silent = !message_silent

		if("Toggle News")
			news_silent = !news_silent

		if("Clear")
			if(params["option"] == "All")
				tnote.Cut()
				conversations.Cut()
			if(params["option"] == "Convo")
				var/new_tnote[0]
				for(var/i in tnote)
					if(i["target"] != active_conversation)
						new_tnote[++new_tnote.len] = i
				tnote = new_tnote
				conversations.Remove(active_conversation)

			active_conversation = null
			if(mode == PDA_MODE_MESSENGER_CONVERSATION)
				set_pda_mode(PDA_MODE_MESSENGER)

		if("Ringtone")
			var/t
			if(!isnull(params["ringtone"]))
				t = params["ringtone"]
			else
				t = input(U, "Please enter new ringtone", name, ttone) as text

			if(Adjacent(src, U) && loc == U)
				if(t)
					var/datum/component/uplink/uplink = get_component(/datum/component/uplink)
					if(uplink?.unlock_code == t)
						to_chat(U, "\The [src] beeps softly.")
						uplink.locked = FALSE
						if(ui)
							ui.close()
						uplink.interact(U)
					else
						t = sanitize(t, 20)
						ttone = t
			else if(ui)
				ui.close()
				return TRUE

		if("Newstone")
			var/t2 = input(U, "Please enter new news tone", name, newstone) as text
			if(in_range(src, U) && loc == U)
				if(t2)
					t2 = sanitize(t2, 20)
					newstone = t2
			else if(ui)
				ui.close()
				return TRUE

		if("Message")
			var/obj/item/device/pda/P = locate(params["target"])
			var/tap = istype(U, /mob/living/carbon) && isnull(params["message"])
			create_message(U, P, tap, params["message"])
			if(mode == PDA_MODE_MESSENGER)
				if(params["target"] in conversations)
					active_conversation = params["target"]
					set_pda_mode(PDA_MODE_MESSENGER_CONVERSATION)

		if("Select Conversation")
			var/selected = params["convo"]
			for(var/n in conversations)
				if(selected == n)
					active_conversation = selected
					set_pda_mode(PDA_MODE_MESSENGER_CONVERSATION)

		if("Select Feed")
			var/feed_name = params["name"]
			for(var/f in feeds)
				if(f["name"] == feed_name)
					active_feed = f
					set_pda_mode(PDA_MODE_NEWS_FEED_CHANNEL)

		if("Send Honk")
			if(cartridge && cartridge.access_clown)
				var/obj/item/device/pda/P_honk = locate(params["target"])
				if(!QDELETED(P_honk))
					if(!P_honk.toff && cartridge.charges > 0)
						cartridge.charges--
						U.show_message("<span class='notice'>Virus sent!</span>", 1)
						P_honk.honkamt = rand(15,20)
				else
					to_chat(U, "PDA not found.")
			else if(ui)
				ui.close()
				return TRUE

		if("Send Silence")
			if(cartridge && cartridge.access_mime)
				var/obj/item/device/pda/P_silence = locate(params["target"])
				if(!QDELETED(P_silence))
					if(!P_silence.toff && cartridge.charges > 0)
						cartridge.charges--
						U.show_message("<span class='notice'>Virus sent!</span>", 1)
						P_silence.message_silent = 1
						P_silence.news_silent = 1
						P_silence.ttone = "silence"
						P_silence.newstone = "silence"
				else
					to_chat(U, "PDA not found.")
			else if(ui)
				ui.close()
				return TRUE

		if("Toggle Door")
			if(cartridge && cartridge.access_remote_door)
				for(var/obj/machinery/door/blast/M in world)
					if(M.id == cartridge.remote_door_id)
						if(M.density)
							M.open()
						else
							M.close()

		if("Detonate")
			if(cartridge && cartridge.access_detonate_pda)
				var/obj/item/device/pda/P_det = locate(params["target"])
				var/datum/reception/reception = get_reception(src, P_det, "", do_sleep = 0)
				if(!(reception.message_server && reception.telecomms_reception & TELECOMMS_RECEPTION_SENDER))
					U.show_message("<span class='warning'>An error flashes on your [src]: Connection unavailable</span>", 1)
					return TRUE
				if(reception.telecomms_reception & TELECOMMS_RECEPTION_RECEIVER == 0)
					U.show_message("<span class='warning'>An error flashes on your [src]: Recipient unavailable</span>", 1)
					return TRUE
				if(!QDELETED(P_det))
					if(!P_det.toff && cartridge.charges > 0)
						cartridge.charges--
						var/difficulty = 2
						if(P_det.cartridge)
							difficulty += P_det.cartridge.access_medical
							difficulty += P_det.cartridge.access_security
							difficulty += P_det.cartridge.access_engine
							difficulty += P_det.cartridge.access_clown
							difficulty += P_det.cartridge.access_janitor
							var/datum/component/uplink/uplink = P_det.get_component(/datum/component/uplink)
							if(istype(uplink))
								difficulty += 3

						if(prob(difficulty))
							U.show_message("<span class='warning'>An error flashes on your [src].</span>", 1)
						else if(prob(difficulty * 7))
							U.show_message("<span class='warning'>Energy feeds back into your [src]!</span>", 1)
							if(ui)
								ui.close()
							detonate_act(src)
							log_admin("[key_name(U)] just attempted to blow up [P_det] with the Detomatix cartridge but failed, blowing themselves up")
							message_admins("[key_name_admin(U)] just attempted to blow up [P_det] with the Detomatix cartridge but failed.", 1)
						else
							U.show_message("<span class='notice'>Success!</span>", 1)
							log_admin("[key_name(U)] just attempted to blow up [P_det] with the Detomatix cartridge and succeeded")
							message_admins("[key_name_admin(U)] just attempted to blow up [P_det] with the Detomatix cartridge and succeeded.", 1)
							detonate_act(P_det)
					else
						to_chat(U, "No charges left.")
				else
					to_chat(U, "PDA not found.")
			else
				U.unset_machine()
				if(ui)
					ui.close()
				return TRUE

		if("pai")
			if(pai)
				if(pai.loc != src)
					pai = null
				else
					switch(params["option"])
						if("1")
							pai.attack_self(U)
						if("2")
							var/turf/T = get_turf_or_move(src.loc)
							if(T)
								pai.dropInto(T)
								pai = null

		else
			var/new_mode = mode_from_choice(choice)
			if(!isnull(new_mode))
				set_pda_mode(new_mode)

	if(mode == PDA_MODE_MESSENGER || mode == PDA_MODE_MESSENGER_CONVERSATION)
		new_message = 0
		update_icon()

	if(mode == PDA_MODE_NEWS_FEED || mode == PDA_MODE_NEWS_FEED_CHANNEL)
		new_news = 0
		update_icon()

	if((honkamt > 0) && prob(60))
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)

	if(ui)
		ui.set_autoupdate(!(mode in no_auto_update))
	return TRUE

/obj/item/device/pda/on_update_icon()
	..()

	ClearOverlays()
	if(new_message || new_news)
		AddOverlays(image('icons/obj/pda.dmi', "pda-r"))

/obj/item/device/pda/proc/detonate_act(obj/item/device/pda/P)
	//TODO: sometimes these attacks show up on the message server
	var/i = rand(1,100)
	var/j = rand(0,1) //Possibility of losing the PDA after the detonation
	var/message = ""
	var/mob/living/M = null
	if(ismob(P.loc))
		M = P.loc

	//switch(i) //Yes, the overlapping cases are intended.
	if(i<=10) //The traditional explosion
		P.explode()
		j=1
		message += "Your [P] suddenly explodes!"
	if(i>=10 && i<= 20) //The PDA burns a hole in the holder.
		j=1
		if(M && isliving(M))
			M.apply_damage( rand(30,60) , BURN)
		message += "You feel a searing heat! Your [P] is burning!"
	if(i>=20 && i<=25) //EMP
		empulse(P.loc, 3, 6, 1)
		message += "Your [P] emits a wave of electromagnetic energy!"
	if(i>=25 && i<=40) //Smoke
		var/datum/effect/effect/system/smoke_spread/S = new /datum/effect/effect/system/smoke_spread
		S.attach(P.loc)
		S.set_up(10, 0, P.loc)
		playsound(P.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
		S.start()
		message += "Large clouds of smoke billow forth from your [P]!"
	if(i>=40 && i<=45) //Bad smoke
		var/datum/effect/effect/system/smoke_spread/bad/B = new /datum/effect/effect/system/smoke_spread/bad
		B.attach(P.loc)
		B.set_up(10, 0, P.loc)
		playsound(P.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
		B.start()
		message += "Large clouds of noxious smoke billow forth from your [P]!"
	if(i>=65 && i<=75) //Weaken
		if(M && isliving(M))
			M.apply_effects(weaken = 1)
		message += "Your [P] flashes with a blinding white light! You feel weaker."
	if(i>=75 && i<=85) //Stun and stutter
		if(M && isliving(M))
			M.apply_effects(stun = 1, stutter = 1)
		message += "Your [P] flashes with a blinding white light! You feel weaker."
	if(i>=85) //Sparks
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(2, 1, P.loc)
		s.start()
		message += "Your [P] begins to spark violently!"
	if(i>45 && i<65 && prob(50)) //Nothing happens
		message += "Your [P] bleeps loudly."
		j = prob(10)

	if(j) //This kills the PDA
		qdel(P)
		if(message)
			message += "It melts in a puddle of plastic."
		else
			message += "Your [P] shatters in a thousand pieces!"

	if(M && isliving(M))
		message = "<span class='warning'>[message]</span>"
		M.show_message(message, 1)

/obj/item/device/pda/proc/remove_id()
	if(!id)
		return
	id.forceMove(get_turf(src))
	if(ismob(loc))
		var/mob/M = loc
		M.pick_or_drop(id)
	to_chat(usr, SPAN("notice", "You remove the ID from the [name]."))
	id = null

/obj/item/device/pda/AltClick()
	if(Adjacent(usr))
		verb_remove_id()

/obj/item/device/pda/CtrlAltClick()
	toggle_light()

/obj/item/device/pda/proc/create_message(mob/living/U = usr, obj/item/device/pda/P, tap = 1, forced_message = null)
	if(!istype(P))
		to_chat(U, "<span class='notice'>ERROR: This user does not accept messages.</span>")
		return
	if(tap)
		U.visible_message("<span class='notice'>\The [U] taps on \his PDA's screen.</span>")
	var/message
	if(isnull(forced_message))
		message = input(U, "Please enter message", P.name, tempmessage[P]) as text
	else
		message = "[forced_message]"
	message = sanitizeSafe(message, extra = 0)
	//t = readd_quotes(t)
	message = replace_characters(message, list("&#34;" = "\""))
	if (!message)
		return
	if (!in_range(src, U) && loc != U)
		return

	if (QDELETED(P) ||P.toff || toff)
		return

	if (last_text && world.time < last_text + 5)
		return

	if(!can_use())
		return

	last_text = world.time
	tempmessage.Remove(P)
	var/datum/reception/reception = get_reception(src, P, message)
	if(!get_message_server(z))
		to_chat(U, "<span class='notice'>ERROR: Messaging server is not responding.</span>")
		tempmessage[P] = message
		return
	if(!get_message_server(P.z))
		to_chat(U, "<span class='notice'>ERROR: Receiving messaging server is not responding.</span>")
		tempmessage[P] = message
		return
	if(reception.telecomms_reception & TELECOMMS_RECEPTION_SENDER) // only send the message if it's stable
		if(reception.telecomms_reception & TELECOMMS_RECEPTION_RECEIVER == 0) // Does our recipient have a broadcaster on their level?
			to_chat(U, "ERROR: Cannot reach recipient.")
			tempmessage[P] = message
			return
		var/send_result = reception.message_server.send_pda_message("[P.owner]","[owner]","[message]")
		if (send_result)
			to_chat(U, "ERROR: Messaging server rejected your message. Reason: contains '[send_result]'.")
			tempmessage[P] = message
			return

		var/utf_message = html_decode(message)
		tnote.Add(list(list("sent" = 1, "owner" = "[P.owner]", "job" = "[P.ownjob]", "message" = "[utf_message]", "timestamp" = stationtime2text(), "target" = "\ref[P]")))
		P.tnote.Add(list(list("sent" = 0, "owner" = "[owner]", "job" = "[ownjob]", "message" = "[utf_message]", "timestamp" = stationtime2text(), "target" = "\ref[src]")))

		for(var/mob/M in GLOB.player_list)
			if(M.is_ooc_dead() && M.get_preference_value(/datum/client_preference/ghost_radio) == GLOB.PREF_ALL_CHATTER) // src.client is so that ghosts don't have to listen to mice
				if(istype(M, /mob/new_player))
					continue
				M.show_message("<span class='game say'>PDA Message - <span class='name'>[owner]</span> -> <span class='name'>[P.owner]</span>: <span class='message'>[message]</span></span>")

		if(!conversations.Find("\ref[P]"))
			conversations.Add("\ref[P]")
		if(!P.conversations.Find("\ref[src]"))
			P.conversations.Add("\ref[src]")


		if (prob(15)) //Give the AI a chance of intercepting the message
			var/who = src.owner
			if(prob(50))
				who = P.owner
			for(var/mob/living/silicon/ai/ai in GLOB.silicon_mob_list)
				// Allows other AIs to intercept the message but the AI won't intercept their own message.
				if(ai.aiPDA != P && ai.aiPDA != src)
					ai.show_message("<i>Intercepted message from <b>[who]</b>: [message]</i>")

		U.client.spellcheck(message)

		P.new_message_from_pda(src, message)
		SStgui.update_user_uis(U, src) // Update the sending user's PDA UI so that they can see the new message

/obj/item/device/pda/proc/new_info(beep_silent, message_tone, reception_message)
	if (!beep_silent)
		playsound(loc, 'sound/signals/ping5.ogg', 50, 0)
		for (var/mob/O in hearers(2, loc))
			O.show_message(text("\icon[src] *[message_tone]*"))
	//Search for holder of the PDA.
	var/mob/living/L = null
	if(loc && isliving(loc))
		L = loc
		if(L.mind && L.mind.syndicate_awareness == SYNDICATE_SUSPICIOUSLY_AWARE)
			reception_message = highlight_codewords(reception_message, GLOB.code_phrase_highlight_rule)  //  Same can be done with code_response or any other list of words, using regex created by generate_code_regex(). You can also add the name of CSS class as argument to change highlight style.
	//Maybe they are a pAI!
	else
		L = get(src, /mob/living/silicon)

	if(L)
		if(reception_message)
			to_chat(L, reception_message)
		SStgui.update_user_uis(L, src) // Update the receiving user's PDA UI so that they can see the new message

/obj/item/device/pda/proc/new_news(message)
	new_info(news_silent, newstone, news_silent ? "" : "\icon[src] <b>[message]</b>")

	if(!news_silent)
		new_news = 1
		update_icon()

/obj/item/device/pda/ai/new_news(message)
	// Do nothing

/obj/item/device/pda/proc/new_message_from_pda(obj/item/device/pda/sending_device, message)
	new_message(sending_device, sending_device.owner, sending_device.ownjob, message)

/obj/item/device/pda/proc/new_message(sending_unit, sender, sender_job, message)
	var/reception_message = "\icon[src] <b>Message from [sender] ([sender_job]), </b>\"[message]\""
	new_info(message_silent, ttone, reception_message)

	log_pda("[key_name(usr)] (PDA: [sending_unit]) sent \"[message]\" to [name]")
	new_message = 1
	update_icon()

/obj/item/device/pda/ai/new_message(atom/movable/sending_unit, sender, sender_job, message)
	if(!istype(sending_unit))
		to_chat(usr, "<span class='bad'>This destination does not accept messages.</span>")
		return
	var/track = ""
	if(ismob(sending_unit.loc) && isAI(loc))
		track = "(<a href='byond://?src=\ref[loc];track=\ref[sending_unit.loc];trackname=[html_encode(sender)]'>Follow</a>)"

	var/reception_message = "\icon[src] <b>Message from [sender] ([sender_job]), </b>\"[message]\" [track]"
	new_info(message_silent, newstone, reception_message)

	log_pda("[usr] (PDA: [sending_unit]) sent \"[message]\" to [name]")
	new_message = 1

/obj/item/device/pda/verb/verb_reset_pda()
	set category = "Object"
	set name = "Reset PDA"
	set src in usr

	if(issilicon(usr))
		return

	if(can_use(usr))
		set_pda_mode(PDA_MODE_HOME)
		SStgui.update_uis(src)
		to_chat(usr, "<span class='notice'>You press the reset button on \the [src].</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this.</span>")

/obj/item/device/pda/verb/verb_remove_id()
	set category = "Object"
	set name = "Remove id"
	set src in usr

	if(issilicon(usr))
		return

	if(!can_use(usr))
		to_chat(usr, "<span class='notice'>You cannot do this.</span>")
		return

	if(id)
		remove_id()
	else
		to_chat(usr, "<span class='notice'>\The [src] does not have an ID in it.</span>")

/obj/item/device/pda/verb/verb_remove_pen()
	set category = "Object"
	set name = "Remove pen"
	set src in usr

	if(issilicon(usr))
		return

	if(!can_use(usr))
		to_chat(usr, "<span class='notice'>You cannot do this.</span>")
		return

	var/obj/item/pen/O = locate() in src
	if(!O)
		to_chat(usr, SPAN("notice", "\The [src] does not have a pen in it."))
		return

	O.forceMove(get_turf(src))
	if(ismob(loc))
		var/mob/M = loc
		M.pick_or_drop(O)
	to_chat(usr, SPAN("notice", "You remove \the [O] from \the [src]."))

/obj/item/device/pda/verb/verb_remove_cartridge()
	set category = "Object"
	set name = "Remove cartridge"
	set src in usr

	if(issilicon(usr))
		return

	if(QDELETED(cartridge))
		to_chat(usr, SPAN("notice", "\The [src] does not have a cartridge in it."))
		return

	if(!can_use(usr))
		to_chat(usr, SPAN("notice", "You cannot do this."))
		return

	cartridge.forceMove(get_turf(src))
	if(ismob(loc))
		var/mob/M = loc
		M.pick_or_drop(cartridge)
	set_pda_mode(PDA_MODE_HOME)
	scanmode = PDA_SCANMODE_NONE
	if(cartridge.radio)
		cartridge.radio.hostpda = null
	to_chat(usr, SPAN("notice", "You remove \the [cartridge] from the [name]."))
	cartridge = null

/obj/item/device/pda/proc/id_check(mob/user as mob, choice as num)//To check for IDs; 1 for in-pda use, 2 for out of pda use.
	if(choice == 1)
		if (id)
			remove_id()
			return 1
		else
			var/obj/item/I = user.get_active_hand()
			if(istype(I, /obj/item/card/id) && user.drop(I, src))
				id = I
			return 1
	else
		var/obj/item/card/I = user.get_active_hand()
		if (istype(I, /obj/item/card/id) && I:registered_name && user.drop(I, src))
			var/obj/old_id = id
			id = I
			if(old_id)
				user.pick_or_drop(old_id)
			return 1
	return 0

// access to status display signals
/obj/item/device/pda/attackby(obj/item/C as obj, mob/user as mob)
	..()
	if(istype(C, /obj/item/cartridge) && !cartridge)
		if(!user.drop(C, src))
			return
		cartridge = C
		to_chat(user, "<span class='notice'>You insert [cartridge] into [src].</span>")
		SStgui.update_uis(src) // update all UIs attached to src
		if(cartridge.radio)
			cartridge.radio.hostpda = src

	else if(istype(C, /obj/item/card/id))
		var/obj/item/card/id/idcard = C
		if(!idcard.registered_name)
			to_chat(user, "<span class='notice'>\The [src] rejects the ID.</span>")
			return
		if(!owner)
			set_owner_rank_job(idcard.registered_name, idcard.rank, idcard.assignment)
			SetName("PDA-[owner] ([ownjob])")
			to_chat(user, "<span class='notice'>Card scanned.</span>")
		else
			//Basic safety check. If either both objects are held by user or PDA is on ground and card is in hand.
			if(((src in user.contents) && (C in user.contents)) || (istype(loc, /turf) && in_range(src, user) && (C in user.contents)) )
				if(id_check(user, 2))
					to_chat(user, "<span class='notice'>You put the ID into \the [src]'s slot.</span>")
					SStgui.update_uis(src)
			return	//Return in case of failed check or when successful.
		SStgui.update_uis(src)
	else if(istype(C, /obj/item/device/paicard) && !src.pai)
		if(!user.drop(C, src))
			return
		pai = C
		to_chat(user, "<span class='notice'>You slot \the [C] into [src].</span>")
		SStgui.update_uis(src) // update all UIs attached to src
	else if(istype(C, /obj/item/pen))
		var/obj/item/pen/O = locate() in src
		if(O)
			to_chat(user, "<span class='notice'>There is already a pen in \the [src].</span>")
		else if(user.drop(C, src))
			to_chat(user, "<span class='notice'>You slide \the [C] into \the [src].</span>")
	return

/obj/item/device/pda/attack(mob/living/C as mob, mob/living/user as mob)
	if (istype(C, /mob/living/carbon))
		switch(scanmode)
			if(PDA_SCANMODE_MEDICAL)

				for (var/mob/O in viewers(C, null))
					O.show_message("<span class='warning'>\The [user] has analyzed [C]'s vitals!</span>", 1)
				user.show_message(medical_scan_results(C, 1))

			if(PDA_SCANMODE_FORENSICS)
				if (!istype(C:dna, /datum/dna))
					to_chat(user, "<span class='notice'>No fingerprints found on [C]</span>")
				else
					to_chat(user, text("<span class='notice'>\The [C]'s Fingerprints: [md5(C:dna.uni_identity)]</span>"))
				if ( !(C:blood_DNA) )
					to_chat(user, "<span class='notice'>No blood found on [C]</span>")
					if(C:blood_DNA)
						qdel(C:blood_DNA)
				else
					to_chat(user, "<span class='notice'>Blood found on [C]. Analysing...</span>")
					spawn(15)
						for(var/blood in C:blood_DNA)
							to_chat(user, "<span class='notice'>Blood type: [C:blood_DNA[blood]]\nDNA: [blood]</span>")

			if(PDA_SCANMODE_HALOGEN)
				for (var/mob/O in viewers(C, null))
					O.show_message("<span class='warning'>\The [user] has analyzed [C]'s radiation levels!</span>", 1)

				user.show_message("<span class='notice'>Analyzing Results for [C]:</span>")
				user.show_message("<span class='notice'>Radiation dose: [fmt_siunit(C.radiation, "Sv", 3)]</span>")

/obj/item/device/pda/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	switch(scanmode)

		if(PDA_SCANMODE_REAGENT)
			if(!isobj(A))
				return
			if(!QDELETED(A.reagents))
				if(A.reagents.reagent_list.len > 0)
					var/reagents_length = A.reagents.reagent_list.len
					to_chat(user, "<span class='notice'>[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found.</span>")
					for (var/re in A.reagents.reagent_list)
						to_chat(user, "<span class='notice'>    [re]</span>")
				else
					to_chat(user, "<span class='notice'>No active chemical agents found in [A].</span>")
			else
				to_chat(user, "<span class='notice'>No significant chemical agents found in [A].</span>")

		if(PDA_SCANMODE_GAS)
			analyze_gases(A, user)

	if (scanmode == PDA_SCANMODE_NONE && istype(A, /obj/item/paper) && owner)
		// JMO 20140705: Makes scanned document show up properly in the notes. Not pretty for formatted documents,
		// as this will clobber the HTML, but at least it lets you scan a document. You can restore the original
		// notes by editing the note again. (Was going to allow you to edit, but scanned documents are too long.)
		var/raw_scan = (A:info)
		var/formatted_scan = ""
		// Scrub out the tags (replacing a few formatting ones along the way)

		// Find the beginning and end of the first tag.
		var/tag_start = findtext(raw_scan,"<")
		var/tag_stop = findtext(raw_scan,">")

		// Until we run out of complete tags...
		while(tag_start&&tag_stop)
			var/pre = copytext(raw_scan,1,tag_start) // Get the stuff that comes before the tag
			var/tag = lowertext(copytext(raw_scan,tag_start+1,tag_stop)) // Get the tag so we can do intellegent replacement
			var/tagend = findtext(tag," ") // Find the first space in the tag if there is one.

			// Anything that's before the tag can just be added as is.
			formatted_scan = formatted_scan+pre

			// If we have a space after the tag (and presumably attributes) just crop that off.
			if (tagend)
				tag=copytext(tag,1,tagend)

			if (tag=="p"||tag=="/p"||tag=="br") // Check if it's I vertical space tag.
				formatted_scan=formatted_scan+"<br>" // If so, add some padding in.

			raw_scan = copytext(raw_scan,tag_stop+1) // continue on with the stuff after the tag

			// Look for the next tag in what's left
			tag_start = findtext(raw_scan,"<")
			tag_stop = findtext(raw_scan,">")

		// Anything that is left in the page. just tack it on to the end as is
		formatted_scan=formatted_scan+raw_scan

		// If there is something in there already, pad it out.
		if (length(note)>0)
			note = note + "<br><br>"

		// Store the scanned document to the notes
		note = "Scanned Document. Edit to restore previous notes/delete scan.<br>----------<br>" + formatted_scan + "<br>"
		// notehtml ISN'T set to allow user to get their old notes back. A better implementation would add a "scanned documents"
		// feature to the PDA, which would better convey the availability of the feature, but this will work for now.

		// Inform the user
		to_chat(user, "<span class='notice'>Paper scanned and OCRed to notekeeper.</span>")//concept of scanning paper copyright brainoblivion 2009




/obj/item/device/pda/proc/explode() //This needs tuning. //Sure did.
	if(!src.detonate) return
	var/turf/T = get_turf(src.loc)
	if(T)
		T.hotspot_expose(700,125)
		explosion(T, 0, 0, 1, rand(1,2))
	return

/obj/item/device/pda/Destroy()
	PDAs -= src
	if (src.id && prob(90)) //IDs are kept in 90% of the cases
		src.id.forceMove(get_turf(src.loc))
	else
		QDEL_NULL(src.id)
	QDEL_NULL(src.cartridge)
	QDEL_NULL(src.pai)
	return ..()

/obj/item/device/pda/clown/Crossed(AM) //Clown PDA is slippery.
	if(istype(AM, /mob/living))
		var/mob/living/M = AM
		if(M.slip_on_obj(src, 3) && M.real_name != owner && istype(cartridge, /obj/item/cartridge/clown))
			if(cartridge.charges < 5)
				cartridge.charges++

/obj/item/device/pda/proc/available_pdas()
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if (toff)
		to_chat(usr, "Turn on your receiver in order to send messages.")
		return

	for (var/obj/item/device/pda/P in PDAs)
		if (!P.owner)
			continue
		else if(P.hidden)
			continue
		else if (P == src)
			continue
		else if (P.toff)
			continue

		var/name = P.owner
		if (name in names)
			namecounts[name]++
			SetName(text("[name] ([namecounts[name]])"))
		else
			names.Add(name)
			namecounts[name] = 1

		plist[text("[name]")] = P
	return plist


//Some spare PDAs in a box
/obj/item/storage/box/PDAs
	name = "box of spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon_state = "pda"

	New()
		..()
		new /obj/item/device/pda(src)
		new /obj/item/device/pda(src)
		new /obj/item/device/pda(src)
		new /obj/item/device/pda(src)
		new /obj/item/cartridge/head(src)

		var/newcart = pick(	/obj/item/cartridge/engineering,
							/obj/item/cartridge/security,
							/obj/item/cartridge/medical,
							/obj/item/cartridge/signal/science,
							/obj/item/cartridge/quartermaster)
		new newcart(src)

// Pass along the pulse to atoms in contents, largely added so pAIs are vulnerable to EMP
/obj/item/device/pda/emp_act(severity)
	for(var/atom/A in src)
		A.emp_act(severity)

/obj/item/device/pda/proc/set_owner(owner)
	src.owner = owner
	update_label()

/obj/item/device/pda/proc/set_rank_job(owner, rank, job)
	ownrank = rank
	ownjob = job ? job : rank
	update_label()

/obj/item/device/pda/proc/set_owner_rank_job(owner, rank, job)
	set_owner(owner)
	set_rank_job(rank, job)

/obj/item/device/pda/proc/update_label()
	name = "PDA-[owner] ([ownjob])"
