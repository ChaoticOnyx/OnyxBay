/obj/item/cartridge
	name = "generic cartridge"
	desc = "A data cartridge for portable microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	w_class = ITEM_SIZE_TINY

	var/obj/item/radio/integrated/radio = null
	var/access_security = 0
	var/access_engine = 0
	var/access_atmos = 0
	var/access_medical = 0
	var/access_clown = 0
	var/access_mime = 0
	var/access_janitor = 0
//	var/access_flora = 0
	var/access_reagent_scanner = 0
	var/access_remote_door = 0 // Control some blast doors remotely!!
	var/remote_door_id = ""
	var/access_status_display = 0
	var/access_quartermaster = 0
	var/access_detonate_pda = 0
	var/access_hydroponics = 0
	var/charges = 0
	var/mode = null
	var/menu
	var/datum/data/record/active1 = null //General
	var/datum/data/record/active2 = null //Medical
	var/datum/data/record/active3 = null //Security
	var/selected_sensor = null // Power Sensor
	var/message1	// used for status_displays
	var/message2
	var/list/stored_data = list()

	drop_sound = SFX_DROP_COMPONENT
	pickup_sound = SFX_PICKUP_COMPONENT

/obj/item/cartridge/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/item/cartridge/engineering
	name = "\improper Power-ON cartridge"
	icon_state = "cart-e"
	access_engine = 1

/obj/item/cartridge/atmos
	name = "\improper BreatheDeep cartridge"
	icon_state = "cart-a"
	access_atmos = 1

/obj/item/cartridge/medical
	name = "\improper Med-U cartridge"
	icon_state = "cart-m"
	access_medical = 1

/obj/item/cartridge/chemistry
	name = "\improper ChemWhiz cartridge"
	icon_state = "cart-chem"
	access_reagent_scanner = 1

/obj/item/cartridge/security
	name = "\improper R.O.B.U.S.T. cartridge"
	icon_state = "cart-s"
	access_security = 1

/obj/item/cartridge/security/Initialize()
	radio = new /obj/item/radio/integrated/beepsky(src)
	. = ..()

/obj/item/cartridge/detective
	name = "\improper D.E.T.E.C.T. cartridge"
	icon_state = "cart-s"
	access_security = 1
	access_medical = 1


/obj/item/cartridge/janitor
	name = "\improper CustodiPRO cartridge"
	desc = "The ultimate in clean-room design."
	icon_state = "cart-j"
	access_janitor = 1

/obj/item/cartridge/lawyer
	name = "\improper P.R.O.V.E. cartridge"
	icon_state = "cart-s"
	access_security = 1

/obj/item/cartridge/clown
	name = "\improper Honkworks 5.0 cartridge"
	icon_state = "cart-clown"
	access_clown = 1
	charges = 5

/obj/item/cartridge/mime
	name = "\improper Gestur-O 1000 cartridge"
	icon_state = "cart-mi"
	access_mime = 1
	charges = 5
/*
/obj/item/cartridge/botanist
	name = "Green Thumb v4.20"
	icon_state = "cart-b"
	access_flora = 1
*/

/obj/item/cartridge/signal
	name = "generic signaler cartridge"
	desc = "A data cartridge with an integrated radio signaler module."
	var/qdeled = 0

/obj/item/cartridge/signal/science
	name = "\improper Signal Ace 2 cartridge"
	desc = "Complete with integrated radio signaler!"
	icon_state = "cart-tox"
	access_reagent_scanner = 1
	access_atmos = 1

/obj/item/cartridge/signal/Initialize()
	radio = new /obj/item/radio/integrated/signal(src)
	. = ..()

/obj/item/cartridge/quartermaster
	name = "\improper Space Parts & Space Vendors cartridge"
	desc = "Perfect for the Quartermaster on the go!"
	icon_state = "cart-q"
	access_quartermaster = 1

/obj/item/cartridge/head
	name = "\improper Easy-Record DELUXE"
	icon_state = "cart-h"
	access_status_display = 1

/obj/item/cartridge/hop
	name = "\improper HumanResources9001 cartridge"
	icon_state = "cart-h"
	access_status_display = 1
	access_quartermaster = 1
	access_janitor = 1
	access_security = 1

/obj/item/cartridge/hos
	name = "\improper R.O.B.U.S.T. DELUXE"
	icon_state = "cart-hos"
	access_status_display = 1
	access_security = 1

/obj/item/cartridge/hos/Initialize()
	radio = new /obj/item/radio/integrated/beepsky(src)
	. = ..()

/obj/item/cartridge/ce
	name = "\improper Power-On DELUXE"
	icon_state = "cart-ce"
	access_status_display = 1
	access_engine = 1
	access_atmos = 1

/obj/item/cartridge/cmo
	name = "\improper Med-U DELUXE"
	icon_state = "cart-cmo"
	access_status_display = 1
	access_reagent_scanner = 1
	access_medical = 1

/obj/item/cartridge/rd
	name = "\improper Signal Ace DELUXE"
	icon_state = "cart-rd"
	access_status_display = 1
	access_reagent_scanner = 1
	access_atmos = 1

/obj/item/cartridge/rd/Initialize()
	radio = new /obj/item/radio/integrated/signal(src)
	. = ..()

/obj/item/cartridge/captain
	name = "\improper Value-PAK cartridge"
	desc = "Now with 200% more value!"
	icon_state = "cart-c"
	access_quartermaster = 1
	access_janitor = 1
	access_engine = 1
	access_security = 1
	access_medical = 1
	access_reagent_scanner = 1
	access_status_display = 1
	access_atmos = 1

/obj/item/cartridge/syndicate
	name = "\improper Detomatix cartridge"
	icon_state = "cart"
	access_remote_door = 1
	access_detonate_pda = 1
	remote_door_id = "smindicate" //Make sure this matches the syndicate shuttle's shield/door id!!	//don't ask about the name, testing.
	charges = 4

/obj/item/cartridge/proc/post_status(command, data1, data2)
	var/datum/frequency/frequency = SSradio.return_frequency(1435)
	if(!frequency)
		return

	var/list/data = list(
		"command" = command
	)

	switch(command)
		if("message")
			data["msg1"] = data1
			data["msg2"] = data2
			if(loc)
				var/obj/item/PDA = loc
				var/mob/user = PDA.fingerprintslast
				if(istype(PDA.loc,/mob/living))
					SetName(PDA.loc)
				log_admin("STATUS: [user] set status screen with [PDA]. Message: [data1] [data2]")
				message_admins("STATUS: [user] set status screen with [PDA]. Message: [data1] [data2]")

		if("image")
			data["picture_state"] = data1

	var/datum/signal/status_signal = new(data)
	frequency.post_signal(src, status_signal)


/*
	This generates the nano values of the cart menus.
	Because we close the UI when we insert a new cart
	we don't have to worry about null values on items
	the user can't access.  Well, unless they are href hacking.
	But in that case their UI will just lock up.
*/


/obj/item/cartridge/proc/create_NanoUI_values(mob/user as mob)
	var/values[0]

	/*		Signaler (Mode: 40)				*/


	if(istype(radio,/obj/item/radio/integrated/signal) && (mode==40))
		var/obj/item/radio/integrated/signal/R = radio
		values["signal_freq"] = format_frequency(R.frequency)
		values["signal_code"] = R.code


	/*		Station Display (Mode: 42)			*/

	if(mode==42)
		values["message1"] = message1 ? message1 : "(none)"
		values["message2"] = message2 ? message2 : "(none)"



	/*		Power Monitor (Mode: 43 / 433)			*/

	if(mode==43 || mode==433)
		var/list/sensors = list()
		var/obj/machinery/power/sensor/MS = null

		for(var/obj/machinery/power/sensor/S in SSmachines.machinery)
			sensors.Add(list(list("name_tag" = S.name_tag)))
			if(S.name_tag == selected_sensor)
				MS = S
		values["power_sensors"] = sensors
		if(selected_sensor && MS)
			values["sensor_reading"] = MS.return_reading_data()

	/*		Security Bot Control (Mode: 46)		*/

	if(mode==46)
		var/botsData[0]
		var/beepskyData[0]
		if(istype(radio,/obj/item/radio/integrated/beepsky))
			var/obj/item/radio/integrated/beepsky/SC = radio
			beepskyData["active"] = SC.active
			if(SC.active && !isnull(SC.botstatus))
				var/area/loca = SC.botstatus["loca"]
				var/loca_name = sanitize(loca.name)
				beepskyData["botstatus"] = list("loca" = loca_name, "mode" = SC.botstatus["mode"])
			else
				beepskyData["botstatus"] = list("loca" = null, "mode" = -1)
			var/botsCount=0
			if(SC.botlist && SC.botlist.len)
				for(var/mob/living/bot/B in SC.botlist)
					botsCount++
					if(B.loc)
						botsData[++botsData.len] = list("Name" = sanitize(B.name), "Location" = sanitize(B.loc.loc.name), "ref" = "\ref[B]")

			if(!botsData.len)
				botsData[++botsData.len] = list("Name" = "No bots found", "Location" = "Invalid", "ref"= null)

			beepskyData["bots"] = botsData
			beepskyData["count"] = botsCount

		else
			beepskyData["active"] = 0
			botsData[++botsData.len] = list("Name" = "No bots found", "Location" = "Invalid", "ref"= null)
			beepskyData["botstatus"] = list("loca" = null, "mode" = null)
			beepskyData["bots"] = botsData
			beepskyData["count"] = 0

		values["beepsky"] = beepskyData


	/*		MULEBOT Control	(Mode: 48)		*/

	if(mode==48)
		var/mulebotsData[0]
		var/count = 0

		for(var/mob/living/bot/mulebot/M in GLOB.living_mob_list_)
			if(!M.on)
				continue
			++count
			var/muleData[0]
			muleData["name"] = M.suffix
			muleData["location"] = get_area(M)
			muleData["paused"] = M.paused
			muleData["home"] = M.homeName
			muleData["target"] = M.targetName
			muleData["ref"] = "\ref[M]"
			muleData["load"] = M.load ? M.load.name : "Nothing"

			mulebotsData[++mulebotsData.len] = muleData.Copy()

		values["mulebotcount"] = count
		values["mulebots"] = mulebotsData



	/*	Supply Shuttle Requests Menu (Mode: 47)		*/

	if(mode==47)
		var/supplyData[0]
		var/datum/shuttle/autodock/ferry/supply/shuttle = SSsupply.shuttle
		if (shuttle)
			supplyData["shuttle_moving"] = shuttle.has_arrive_time()
			supplyData["shuttle_eta"] = shuttle.eta_minutes()
			supplyData["shuttle_loc"] = shuttle.at_station() ? "Station" : "Dock"
		var/supplyOrderCount = 0
		var/supplyOrderData[0]
		for(var/S in SSsupply.shoppinglist)
			var/datum/supply_order/SO = S

			supplyOrderData[++supplyOrderData.len] = list("Number" = SO.ordernum, "Name" = html_encode(SO.object.name), "ApprovedBy" = SO.orderedby, "Comment" = html_encode(SO.comment))
		if(!supplyOrderData.len)
			supplyOrderData[++supplyOrderData.len] = list("Number" = null, "Name" = null, "OrderedBy"=null)

		supplyData["approved"] = supplyOrderData
		supplyData["approved_count"] = supplyOrderCount

		var/requestCount = 0
		var/requestData[0]
		for(var/S in SSsupply.requestlist)
			var/datum/supply_order/SO = S
			requestCount++
			requestData[++requestData.len] = list("Number" = SO.ordernum, "Name" = html_encode(SO.object.name), "OrderedBy" = SO.orderedby, "Comment" = html_encode(SO.comment))
		if(!requestData.len)
			requestData[++requestData.len] = list("Number" = null, "Name" = null, "orderedBy" = null, "Comment" = null)

		supplyData["requests"] = requestData
		supplyData["requests_count"] = requestCount


		values["supply"] = supplyData



	/* 	Janitor Supplies Locator  (Mode: 49)      */
	if(mode==49)
		var/JaniData[0]
		var/turf/cl = get_turf(src)

		if(cl)
			JaniData["user_loc"] = list("x" = cl.x, "y" = cl.y)
		else
			JaniData["user_loc"] = list("x" = 0, "y" = 0)
		var/MopData[0]
		for(var/obj/item/mop/M in world)
			var/turf/ml = get_turf(M)
			if(ml)
				if(ml.z != cl.z)
					continue
				var/direction = get_dir(src, M)
				MopData[++MopData.len] = list ("x" = ml.x, "y" = ml.y, "dir" = uppertext(dir2text(direction)), "status" = M.reagents.total_volume ? "Wet" : "Dry")

		if(!MopData.len)
			MopData[++MopData.len] = list("x" = 0, "y" = 0, dir=null, status = null)


		var/BucketData[0]
		for(var/obj/structure/mopbucket/B in world)
			var/turf/bl = get_turf(B)
			if(bl)
				if(bl.z != cl.z)
					continue
				var/direction = get_dir(src,B)
				BucketData[++BucketData.len] = list ("x" = bl.x, "y" = bl.y, "dir" = uppertext(dir2text(direction)), "status" = B.reagents.total_volume/100)

		if(!BucketData.len)
			BucketData[++BucketData.len] = list("x" = 0, "y" = 0, dir=null, status = null)

		var/CbotData[0]
		for(var/mob/living/bot/cleanbot/B in world)
			var/turf/bl = get_turf(B)
			if(bl)
				if(bl.z != cl.z)
					continue
				var/direction = get_dir(src,B)
				CbotData[++CbotData.len] = list("x" = bl.x, "y" = bl.y, "dir" = uppertext(dir2text(direction)), "status" = B.on ? "Online" : "Offline")


		if(!CbotData.len)
			CbotData[++CbotData.len] = list("x" = 0, "y" = 0, dir=null, status = null)
		var/CartData[0]
		for(var/obj/structure/janitorialcart/B in world)
			var/turf/bl = get_turf(B)
			if(bl)
				if(bl.z != cl.z)
					continue
				var/direction = get_dir(src,B)
				CartData[++CartData.len] = list("x" = bl.x, "y" = bl.y, "dir" = uppertext(dir2text(direction)), "status" = B.reagents.total_volume/100)
		if(!CartData.len)
			CartData[++CartData.len] = list("x" = 0, "y" = 0, dir=null, status = null)




		JaniData["mops"] = MopData
		JaniData["buckets"] = BucketData
		JaniData["cleanbots"] = CbotData
		JaniData["carts"] = CartData
		values["janitor"] = JaniData

	return values





/obj/item/cartridge/Topic(href, href_list)
	if((. = ..()))
		usr.unset_machine()
		close_browser(usr, "window=pda")
		return

	switch(href_list["choice"])
		if("Send Signal")
			spawn( 0 )
				radio:send_signal("ACTIVATE")
				return

		if("Signal Frequency")
			var/new_frequency = sanitize_frequency(radio:frequency + text2num(href_list["sfreq"]))
			radio:set_frequency(new_frequency)

		if("Signal Code")
			radio:code += text2num(href_list["scode"])
			radio:code = round(radio:code)
			radio:code = min(100, radio:code)
			radio:code = max(1, radio:code)

		if("Status")
			switch(href_list["statdisp"])
				if("message")
					post_status("message", message1, message2)
				if("image")
					post_status("image", href_list["image"])
				if("setmsg1")
					message1 = reject_bad_text(sanitize(input("Line 1", "Enter Message Text", message1) as text|null, 40), 40)
					updateSelfDialog()
				if("setmsg2")
					message2 = reject_bad_text(sanitize(input("Line 2", "Enter Message Text", message2) as text|null, 40), 40)
					updateSelfDialog()
				else
					post_status(href_list["statdisp"])

		if("Power Select")
			selected_sensor = href_list["target"]
			loc:mode = 433
			mode = 433
		if("Power Clear")
			selected_sensor = null
			loc:mode = 43
			mode = 43

		if("MULEbot")
			var/mob/living/bot/mulebot/M = locate(href_list["ref"])
			if(istype(M))
				M.obeyCommand(href_list["command"])


	return 1
