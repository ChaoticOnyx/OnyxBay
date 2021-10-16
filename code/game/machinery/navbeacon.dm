var/global/list/navbeacons = list()
GLOBAL_LIST_EMPTY(wayfindingbeacons)
/obj/machinery/navbeacon
	icon = 'icons/obj/objects.dmi'
	icon_state = "navbeacon0-f"
	name = "navigation beacon"
	desc = "A radio beacon used for bot navigation."
	level = 1
	layer = ABOVE_WIRE_LAYER
	anchored = 1

	var/wayfinding = FALSE
	var/open = FALSE	// true if cover is open
	var/locked = TRUE	// true if controls are locked
	var/location = ""	// location response text
	var/list/codes = list()		// assoc. list of transponder codes

	req_access = list(access_engine)

/obj/machinery/navbeacon/New()
	..()

	if(wayfinding)
		if(!location)
			var/obj/machinery/door/airlock/A = locate(/obj/machinery/door/airlock) in loc
			if(A)
				location = A.name
			else
				location = get_area(src)?.name || "Unknown"
		codes += list("wayfinding" = "[location]")
		GLOB.wayfindingbeacons += src

	var/turf/T = loc
	hide(!T.is_plating())

	navbeacons += src

/obj/machinery/navbeacon/hide(intact)
	set_invisibility(intact ? 101 : 0)
	update_icon()

/obj/machinery/navbeacon/update_icon()
	var/state="navbeacon[open]"

	if(invisibility)
		icon_state = "[state]-f"	// if invisible, set icon to faded version
									// in case revealed by T-scanner
	else
		icon_state = "[state]"

/obj/machinery/navbeacon/attackby(obj/item/I, mob/user)
	var/turf/T = loc
	if(!T.is_plating())
		return		// prevent intraction when T-scanner revealed

	if(isScrewdriver(I))
		open = !open

		user.visible_message("\The [user] [open ? "opens" : "closes"] cover of \the [src].", "You [open ? "open" : "close"] cover of \the [src].")

		update_icon()

	else if(I.GetIdCard())
		if(open)
			if (src.allowed(user))
				src.locked = !src.locked
				to_chat(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")
			updateDialog()
		else
			to_chat(user, "You must open the cover first!")
	return

/obj/machinery/navbeacon/attack_ai(mob/user)
	interact(user, 1)

/obj/machinery/navbeacon/attack_hand(mob/user)

	if(!user.IsAdvancedToolUser())
		return 0

	interact(user, 0)

/obj/machinery/navbeacon/interact(mob/user, ai = 0)
	var/turf/T = loc
	if(!T.is_plating())
		return		// prevent intraction when T-scanner revealed

	if(!open && !ai)	// can't alter controls if not open, unless you're an AI
		to_chat(user, "The beacon's control cover is closed.")
		return

	var/t

	if(locked && !ai)
		t = {"<meta charset=\"utf-8\"><TT><B>Navigation Beacon</B><HR><BR>
<i>(swipe card to unlock controls)</i><BR><HR>
Location: [location ? location : "(none)"]</A><BR>
Transponder Codes:<UL>"}

		for(var/key in codes)
			t += "<LI>[key] ... [codes[key]]"
		t+= "<UL></TT>"

	else

		t = {"<meta charset=\"utf-8\"><TT><B>Navigation Beacon</B><HR><BR>
<i>(swipe card to lock controls)</i><BR><HR>
Location: <A href='byond://?src=\ref[src];locedit=1'>[location ? location : "(none)"]</A><BR>
Transponder Codes:<UL>"}

		for(var/key in codes)
			t += "<LI>[key] ... [codes[key]]"
			t += " <small><A href='byond://?src=\ref[src];edit=1;code=[key]'>(edit)</A>"
			t += " <A href='byond://?src=\ref[src];delete=1;code=[key]'>(delete)</A></small><BR>"
		t += "<small><A href='byond://?src=\ref[src];add=1;'>(add new)</A></small><BR>"
		t+= "<UL></TT>"

	show_browser(user, t, "window=navbeacon")
	onclose(user, "navbeacon")
	return

/obj/machinery/navbeacon/Topic(href, href_list)
	..()
	if (usr.stat)
		return
	if ((in_range(src, usr) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon)))
		if(open && !locked)
			usr.set_machine(src)

			if(href_list["locedit"])
				var/newloc = sanitize(input("Enter New Location", "Navigation Beacon", location) as text|null)
				if(newloc)
					location = newloc
					updateDialog()

			else if(href_list["edit"])
				var/codekey = href_list["code"]

				var/newkey = input("Enter Transponder Code Key", "Navigation Beacon", codekey) as text|null
				if(!newkey)
					return

				var/codeval = codes[codekey]
				var/newval = input("Enter Transponder Code Value", "Navigation Beacon", codeval) as text|null
				if(!newval)
					newval = codekey
					return

				codes.Remove(codekey)
				codes[newkey] = newval

				updateDialog()

			else if(href_list["delete"])
				var/codekey = href_list["code"]
				codes.Remove(codekey)
				updateDialog()

			else if(href_list["add"])

				var/newkey = input("Enter New Transponder Code Key", "Navigation Beacon") as text|null
				if(!newkey)
					return

				var/newval = input("Enter New Transponder Code Value", "Navigation Beacon") as text|null
				if(!newval)
					newval = "1"
					return

				if(!codes)
					codes = new()

				codes[newkey] = newval

				updateDialog()

/obj/machinery/navbeacon/Destroy()
	if(wayfinding)
		GLOB.wayfindingbeacons -= src
	navbeacons.Remove(src)
	return ..()

// Box station patrol beacons.

/obj/machinery/navbeacon/box/ROBOTICS
	location = "ROBOTICS"
	codes = list("patrol" = 1, "next_patrol" = "CH_EAST2")

/obj/machinery/navbeacon/box/SEC
	location = "SEC"
	codes = list("patrol" = 1, "next_patrol" = "CH_NORTH1")

/obj/machinery/navbeacon/box/CH_NORTH1
	location = "CH_NORTH1"
	codes = list("patrol" = 1, "next_patrol" = "LOCKERS")

/obj/machinery/navbeacon/box/LOCKERS
	location = "LOCKERS"
	codes = list("patrol" = 1, "next_patrol" = "CH_NORTHWEST")

/obj/machinery/navbeacon/box/CH_NORTHWEST
	location = "CH_NORTHWEST"
	codes = list("patrol" = 1, "next_patrol" = "QM")

/obj/machinery/navbeacon/box/QM
	location = "QM"
	codes = list("patrol" = 1, "next_patrol" = "AI1")

/obj/machinery/navbeacon/box/AI1
	location = "AI1"
	codes = list("patrol" = 1, "next_patrol" = "AFTH")

/obj/machinery/navbeacon/box/AFTH
	location = "AFTH"
	codes = list("patrol" = 1, "next_patrol" = "AI2")

/obj/machinery/navbeacon/box/AI2
	location = "AI2"
	codes = list("patrol" = 1, "next_patrol" = "CH_EAST1")

/obj/machinery/navbeacon/box/CH_EAST1
	location = "CH_EAST1"
	codes = list("patrol" = 1, "next_patrol" = "ESCAPE")

/obj/machinery/navbeacon/box/ESCAPE
	location = "ESCAPE"
	codes = list("patrol" = 1, "next_patrol" = "CH_EAST2")

/obj/machinery/navbeacon/box/CH_EAST2
	location = "CH_EAST2"
	codes = list("patrol" = 1, "next_patrol" = "DORM")

/obj/machinery/navbeacon/box/DORM
	location = "DORM"
	codes = list("patrol" = 1, "next_patrol" = "CH_NORTHEAST")

/obj/machinery/navbeacon/box/CH_NORTHEAST
	location = "CH_NORTHEAST"
	codes = list("patrol" = 1, "next_patrol" = "CH_NORTH2")

/obj/machinery/navbeacon/box/CH_NORTH2
	location = "CH_NORTH2"
	codes = list("patrol" = 1, "next_patrol" = "SEC")

// Frontier patrol beacons.

/obj/machinery/navbeacon/frontier/SEC
	location = "SEC"
	codes = list("patrol" = 1, "next_patrol" = "SE1")

/obj/machinery/navbeacon/frontier/SE1
	location = "SE1"
	codes = list("patrol" = 1, "next_patrol" = "DOME_E1")

/obj/machinery/navbeacon/frontier/DOME_E1
	location = "DOME_E1"
	codes = list("patrol" = 1, "next_patrol" = "DOME_SE")

/obj/machinery/navbeacon/frontier/DOME_SE
	location = "DOME_SE"
	codes = list("patrol" = 1, "next_patrol" = "DOME_S1")

/obj/machinery/navbeacon/frontier/DOME_S1
	location = "DOME_S1"
	codes = list("patrol" = 1, "next_patrol" = "ARRIVALS1")

/obj/machinery/navbeacon/frontier/ARRIVALS1
	location = "ARRIVALS1"
	codes = list("patrol" = 1, "next_patrol" = "DEPARTURES")

/obj/machinery/navbeacon/frontier/DEPARTURES
	location = "DEPARTURES"
	codes = list("patrol" = 1, "next_patrol" = "ARRIVALS2")

/obj/machinery/navbeacon/frontier/ARRIVALS2
	location = "ARRIVALS2"
	codes = list("patrol" = 1, "next_patrol" = "DOME_S2")

/obj/machinery/navbeacon/frontier/DOME_S2
	location = "DOME_S2"
	codes = list("patrol" = 1, "next_patrol" = "DOME_SW")

/obj/machinery/navbeacon/frontier/DOME_SW
	location = "DOME_SW"
	codes = list("patrol" = 1, "next_patrol" = "DOME_W1")

/obj/machinery/navbeacon/frontier/DOME_W1
	location = "DOME_W1"
	codes = list("patrol" = 1, "next_patrol" = "ENG")

/obj/machinery/navbeacon/frontier/ENG
	location = "ENG"
	codes = list("patrol" = 1, "next_patrol" = "DOME_W2")

/obj/machinery/navbeacon/frontier/DOME_W2
	location = "DOME_W2"
	codes = list("patrol" = 1, "next_patrol" = "DOME_NW")

/obj/machinery/navbeacon/frontier/DOME_NW
	location = "DOME_NW"
	codes = list("patrol" = 1, "next_patrol" = "DOME_N")

/obj/machinery/navbeacon/frontier/DOME_N
	location = "DOME_N"
	codes = list("patrol" = 1, "next_patrol" = "DOME_NE")

/obj/machinery/navbeacon/frontier/DOME_NE
	location = "DOME_NE"
	codes = list("patrol" = 1, "next_patrol" = "DOME_E2")

/obj/machinery/navbeacon/frontier/DOME_E2
	location = "DOME_E2"
	codes = list("patrol" = 1, "next_patrol" = "BAR")

/obj/machinery/navbeacon/frontier/BAR
	location = "BAR"
	codes = list("patrol" = 1, "next_patrol" = "CRYO")

/obj/machinery/navbeacon/frontier/CRYO
	location = "CRYO"
	codes = list("patrol" = 1, "next_patrol" = "BHALLWAY")

/obj/machinery/navbeacon/frontier/BHALLWAY
	location = "BHALLWAY"
	codes = list("patrol" = 1, "next_patrol" = "SEC")


// Delivery types below.

/obj/machinery/navbeacon/delivery/QM1
	location = "QM #1"
	codes = list("delivery" = 1, "dir" = 8)

/obj/machinery/navbeacon/delivery/QM2
	location = "QM #2"
	codes = list("delivery" = 1, "dir" = 8)

/obj/machinery/navbeacon/delivery/QM3
	location = "QM #3"
	codes = list("delivery" = 1, "dir" = 8)

/obj/machinery/navbeacon/delivery/QM4
	location = "QM #4"
	codes = list("delivery" = 1, "dir" = 8)

/obj/machinery/navbeacon/delivery/Research
	location = "Research Division"
	codes = list("delivery" = 1, "dir" = 8)

/obj/machinery/navbeacon/delivery/Janitor
	location = "Janitor"
	codes = list("delivery" = 1, "dir" = 8)

/obj/machinery/navbeacon/delivery/SecurityD
	location = "Security"
	codes = list("delivery" = 1, "dir" = 8)

/obj/machinery/navbeacon/delivery/ToolStorage
	location = "Tool Storage"
	codes = list("delivery" = 1, "dir" = 8)

/obj/machinery/navbeacon/delivery/Medbay
	location = "Medbay"
	codes = list("delivery" = 1, "dir" = 4)

/obj/machinery/navbeacon/delivery/Engineering
	location = "Engineering"
	codes = list("delivery" = 1, "dir" = 4)

/obj/machinery/navbeacon/delivery/Bar
	location = "Bar"
	codes = list("delivery" = 1, "dir" = 2)

/obj/machinery/navbeacon/delivery/Kitchen
	location = "Kitchen"
	codes = list("delivery" = 1, "dir" = 2)

/obj/machinery/navbeacon/delivery/Hydroponics
	location = "Hydroponics"
	codes = list("delivery" = 1, "dir" = 2)
