/obj/machinery/vending/wayfinding
	name = "PTech"
	desc = "A machine given the thankless job of trying to give wayfinding pinpointers. They point to common locations."
	icon_state = "cart"
	use_vend_state = TRUE
	vend_delay = 23
	products = list(/obj/item/weapon/pinpointer/wayfinding = 10)
	slogan_list = list("Find a wayfinding pinpointer? Give it to me! I'll make it worth your while. Please. Daddy needs his medicine.", //last sentence is a reference to Sealab 2021
						"See a wayfinding pinpointer? Don't let it go to the crusher! Recycle it with me instead. I'll pay you or not.", //I see these things heading for disposals through cargo all the time
						"Can't find the disk? Need a pinpointer? Buy a wayfinding pinpointer and find the captain's office today!",
						"Bleeding to death? Can't read? Find your way to medbay today!", //there are signs that point to medbay but you need basic literacy to get the most out of them
						"Voted tenth best pinpointer in the universe in 2560!", //there were no more than ten pinpointers in the game in 2020
						"Helping assistants find the departments they tide since 2560.", //not really but it's advertising
						"These pinpointers are flying out the airlock!", //because they're being thrown into space
						"Grey pinpointers for the grey tide!", //I didn't pick the colour but it works
						"Feeling lost? Find direction.",
						"Automate your sense of direction. Buy a wayfinding pinpointer today!",
						"Feed me a stray pinpointer.", //American Psycho reference
						"We need a slogan!") //Liberal Crime Squad reference

//Pinpointer itself
/obj/item/weapon/pinpointer/wayfinding //Help players new to a station find their way around
	name = "wayfinding pinpointer"
	desc = "A handheld tracking device that points to useful places."
	icon_state = "pinpointer_way"
	var/owner = null
	var/obj/machinery/navbeacon/wayfinding/way_target
	var/list/beacons = list()

/obj/item/weapon/pinpointer/wayfinding/attack_self(mob/living/user)
	if(active)
		..()
		return
	if(!owner)
		owner = user.real_name

	if(length(beacons))
		beacons.Cut()
	for(var/obj/machinery/navbeacon/B in GLOB.wayfindingbeacons)
		beacons[B.codes["wayfinding"]] = B

	if(!length(beacons))
		to_chat(user, SPAN_NOTICE("Your pinpointer fails to detect a signal."))
		return

	var/A = input(user, "", "Pinpoint") as null|anything in sortList(beacons)
	if(!A || QDELETED(src) || !user || !src.Adjacent(user) || user.incapacitated())
		return

	way_target = beacons[A]
	target = acquire_target()
	..()

/obj/item/weapon/pinpointer/wayfinding/toggle()
	..()
	if(!active)
		way_target = null

/obj/item/weapon/pinpointer/wayfinding/acquire_target()
	if(way_target)
		return weakref(way_target)

/obj/item/weapon/pinpointer/wayfinding/examine(mob/user)
	. = ..()
	var/msg = " Its tracking indicator reads "
	if(target)
		var/obj/machinery/navbeacon/wayfinding/B  = target
		msg += "\"[B.codes["wayfinding"]]\"."
	else
		msg = " Its tracking indicator is blank."
	if(owner)
		msg += " It belongs to [owner]."
	. += msg

//Navbeacon that initialises with wayfinding codes
/obj/machinery/navbeacon/wayfinding
	wayfinding = TRUE

/* Defining these here instead of relying on map edits because it makes it easier to place them */
//Command
/obj/machinery/navbeacon/wayfinding/bridge
	location = "Bridge"

/obj/machinery/navbeacon/wayfinding/vault
	location = "Vault"

/obj/machinery/navbeacon/wayfinding/teleporter
	location = "Teleporter"

/obj/machinery/navbeacon/wayfinding/gateway
	location = "Gateway"

/obj/machinery/navbeacon/wayfinding/eva
	location = "EVA Storage"

/obj/machinery/navbeacon/wayfinding/aiupload
	location = "AI Upload"

// head of staff offices
/obj/machinery/navbeacon/wayfinding/hos
	location = "Head of Security's Office"

/obj/machinery/navbeacon/wayfinding/hop
	location = "Head of Personnel's Office"

/obj/machinery/navbeacon/wayfinding/agent
	location = "IIA's Office"

/obj/machinery/navbeacon/wayfinding/ce
	location = "Chief Engineer's Office"

/obj/machinery/navbeacon/wayfinding/rd
	location = "Research Director's Office"

//Departments
/obj/machinery/navbeacon/wayfinding/sec
	location = "Security"

/obj/machinery/navbeacon/wayfinding/det
	location = "Detective's Office"

/obj/machinery/navbeacon/wayfinding/research
	location = "Research"

/obj/machinery/navbeacon/wayfinding/engineering
	location = "Engineering"

/obj/machinery/navbeacon/wayfinding/techstorage
	location = "Technical Storage"

/obj/machinery/navbeacon/wayfinding/atmos
	location = "Atmospherics"

/obj/machinery/navbeacon/wayfinding/med
	location = "Medical"

/obj/machinery/navbeacon/wayfinding/cargo
	location = "Cargo"

//Common areas
/obj/machinery/navbeacon/wayfinding/bar
	location = "Bar"

/obj/machinery/navbeacon/wayfinding/dorms
	location = "Dormitories"

/obj/machinery/navbeacon/wayfinding/court
	location = "Courtroom"

/obj/machinery/navbeacon/wayfinding/tools
	location = "Tool Storage"

/obj/machinery/navbeacon/wayfinding/library
	location = "Library"

/obj/machinery/navbeacon/wayfinding/chapel
	location = "Chapel"

/obj/machinery/navbeacon/wayfinding/cryo
	location = "Cryo Chambers"

//Service
/obj/machinery/navbeacon/wayfinding/kitchen
	location = "Kitchen"

/obj/machinery/navbeacon/wayfinding/hydro
	location = "Hydroponics"

/obj/machinery/navbeacon/wayfinding/janitor
	location = "Janitor's Closet"

//Shuttle docks
/obj/machinery/navbeacon/wayfinding/dockarrival
	location = "Arrival Shuttle Dock"

/obj/machinery/navbeacon/wayfinding/dockesc
	location = "Escape Shuttle Dock"

/obj/machinery/navbeacon/wayfinding/dockescpod1
	location = "Escape Pod 1 Dock"

/obj/machinery/navbeacon/wayfinding/dockescpod2
	location = "Escape Pod 2 Dock"

/obj/machinery/navbeacon/wayfinding/dockescpod3
	location = "Escape Pod 3 Dock"

/obj/machinery/navbeacon/wayfinding/dockescpod4
	location = "Escape Pod 4 Dock"
