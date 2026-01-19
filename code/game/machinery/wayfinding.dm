//Pinpointer itself
/obj/item/pinpointer/wayfinding //Help players new to a station find their way around
	name = "wayfinding pinpointer"
	desc = "A handheld tracking device that points to useful places."
	icon_state = "pinpointer_way"
	var/owner = null
	var/list/beacons = list()

/obj/item/pinpointer/wayfinding/Initialize()
	. = ..()
	var/datum/component/holomarker/toggleable/H = AddComponent(/datum/component/holomarker/toggleable)
	H.should_have_legend = TRUE

/obj/item/pinpointer/wayfinding/attack_self(mob/living/user)
	var/datum/component/holomarker/toggleable/H = get_component(/datum/component/holomarker/toggleable)
	if(isnull(H))
		return

	H.toggle(user)

//Navbeacon that initialises with wayfinding codes
/obj/machinery/navbeacon/wayfinding
	wayfinding = TRUE

/* Defining these here instead of relying on map edits because it makes it easier to place them */
//Command
/obj/machinery/navbeacon/wayfinding/bridge
	location = "Bridge"

/obj/machinery/navbeacon/wayfinding/bridge/Initialize()
	. = ..()
	var/datum/component/holomarker/holomap = AddComponent(/datum/component/holomarker, location)
	holomap.marker_id = location

/obj/machinery/navbeacon/wayfinding/vault
	location = "Vault"

/obj/machinery/navbeacon/wayfinding/teleporter
	location = "Teleporter"

/obj/machinery/navbeacon/wayfinding/gateway
	location = "Gateway"

/obj/machinery/navbeacon/wayfinding/eva
	location = "EVA Storage"

/obj/machinery/navbeacon/wayfinding/eva/Initialize()
	. = ..()
	var/datum/component/holomarker/holomap = AddComponent(/datum/component/holomarker, location)
	holomap.marker_id = location

/obj/machinery/navbeacon/wayfinding/aiupload
	location = "AI Upload"

/obj/machinery/navbeacon/wayfinding/aiupload/Initialize()
	. = ..()
	var/datum/component/holomarker/holomap = AddComponent(/datum/component/holomarker, location)
	holomap.marker_id = location

// head of staff offices
/obj/machinery/navbeacon/wayfinding/hos
	location = "Head of Security's Office"

/obj/machinery/navbeacon/wayfinding/hop
	location = "Head of Provisioning's Office"

/obj/machinery/navbeacon/wayfinding/hop/Initialize()
	. = ..()
	var/datum/component/holomarker/holomap = AddComponent(/datum/component/holomarker, location)
	holomap.marker_id = location

/obj/machinery/navbeacon/wayfinding/agent
	location = "IIA's Office"

/obj/machinery/navbeacon/wayfinding/ce
	location = "Chief Engineer's Office"

/obj/machinery/navbeacon/wayfinding/rd
	location = "Research Director's Office"

//Departments
/obj/machinery/navbeacon/wayfinding/sec
	location = "Security"

/obj/machinery/navbeacon/wayfinding/sec/Initialize()
	. = ..()
	var/datum/component/holomarker/holomap = AddComponent(/datum/component/holomarker, location)
	holomap.marker_id = location

/obj/machinery/navbeacon/wayfinding/det
	location = "Detective's Office"

/obj/machinery/navbeacon/wayfinding/research
	location = "Research"

/obj/machinery/navbeacon/wayfinding/engineering
	location = "Engineering"

/obj/machinery/navbeacon/wayfinding/engineering/Initialize()
	. = ..()
	var/datum/component/holomarker/holomap = AddComponent(/datum/component/holomarker, location)
	holomap.marker_id = location

/obj/machinery/navbeacon/wayfinding/techstorage
	location = "Technical Storage"

/obj/machinery/navbeacon/wayfinding/atmos
	location = "Atmospherics"

/obj/machinery/navbeacon/wayfinding/med
	location = "Medical"

/obj/machinery/navbeacon/wayfinding/med/Initialize()
	. = ..()
	var/datum/component/holomarker/holomap = AddComponent(/datum/component/holomarker, location)
	holomap.marker_id = location

/obj/machinery/navbeacon/wayfinding/cargo
	location = "Cargo"

//Common areas
/obj/machinery/navbeacon/wayfinding/bar
	location = "Bar"

/obj/machinery/navbeacon/wayfinding/bar/Initialize()
	. = ..()
	var/datum/component/holomarker/holomap = AddComponent(/datum/component/holomarker, location)
	holomap.marker_id = location

/obj/machinery/navbeacon/wayfinding/dorms
	location = "Dormitories"

/obj/machinery/navbeacon/wayfinding/court
	location = "Courtroom"

/obj/machinery/navbeacon/wayfinding/tools
	location = "Tool Storage"

/obj/machinery/navbeacon/wayfinding/library
	location = "Library"

/obj/machinery/navbeacon/wayfinding/library/Initialize()
	. = ..()
	var/datum/component/holomarker/holomap = AddComponent(/datum/component/holomarker, location)
	holomap.marker_id = location

/obj/machinery/navbeacon/wayfinding/chapel
	location = "Chapel"

/obj/machinery/navbeacon/wayfinding/chapel/Initialize()
	. = ..()
	var/datum/component/holomarker/holomap = AddComponent(/datum/component/holomarker, location)
	holomap.marker_id = location

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
