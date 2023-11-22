GLOBAL_LIST_EMPTY(monkey_recyclers)

/obj/item/circuitboard/machine/monkey_recycler

	name = "circuit board (monkey recycler)"
	build_path = /obj/machinery/monkey_recycler
	origin_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 1)
	req_components = list(
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/matter_bin = 1
							)
	board_type = "machine"

/obj/machinery/monkey_recycler
	name = "monkey recycler"
	desc = "A machine used for recycling dead monkeys into monkey cubes."
	icon = 'icons/obj/machines/gibber.dmi'
	icon_state = "gibber"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	anchored = TRUE
	var/stored_matter = 0
	var/cube_production = 0.2
	var/list/connected = list() //Keeps track of connected xenobio consoles, for deletion in /Destroy()
	component_types = list(
		/obj/item/circuitboard/machine/monkey_recycler,
		/obj/item/stock_parts/manipulator,
		/obj/item/stock_parts/matter_bin,
	)

/obj/machinery/monkey_recycler/Initialize(mapload)
	. = ..()
	if (mapload)
		GLOB.monkey_recyclers += src

/obj/machinery/monkey_recycler/Destroy()
	GLOB.monkey_recyclers -= src
	for(var/thing in connected)
		var/obj/machinery/computer/camera_advanced/xenobio/console = thing
		console.connected_recycler = null
	connected.Cut()
	return ..()

/obj/machinery/monkey_recycler/RefreshParts() //Ranges from 0.2 to 0.8 per monkey recycled
	. = ..()
	cube_production = 0
	for(var/obj/item/stock_parts/manipulator/manipulator in component_parts)
		cube_production += manipulator.rating * 0.1
	for(var/obj/item/stock_parts/matter_bin/matter_bin in component_parts)
		cube_production += matter_bin.rating * 0.1

/obj/machinery/monkey_recycler/_examine_text(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += SPAN_NOTICE("The status display reads: Producing <b>[cube_production]</b> cubes for every monkey inserted.")

/obj/machinery/monkey_recycler/update_icon()
	ClearOverlays()
	if(panel_open) AddOverlays("gibber-panel")

/obj/machinery/monkey_recycler/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, O, TRUE))
		return

	if(isWrench(O))
		anchored = !anchored
		power_change()
		to_chat(user, "You [anchored ? "attach" : "detach"] the [src] [anchored ? "to" : "from"] the ground")
		playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
		return

	if(default_deconstruction_crowbar(user, O))
		return

	if(isMultitool(O))
		if(panel_open)
			var/obj/item/device/multitool/MT = O
			to_chat(user, SPAN_NOTICE("You upload \the [src] data to \the [MT]'s buffer."))
			MT.set_buffer(src)
			return

	return ..()

/obj/machinery/monkey_recycler/MouseDrop_T(mob/living/target, mob/living/user)
	if(!istype(target))
		return
	if(isMonkey(target))
		stuff_monkey_in(target, user)

/obj/machinery/monkey_recycler/proc/stuff_monkey_in(mob/living/carbon/human/target, mob/living/user)
	if(!istype(target))
		return
	if(target.stat == CONSCIOUS)
		to_chat(user, SPAN_WARNING("The monkey is struggling far too much to put it in the recycler."))
		return
	if(target.buckled())
		to_chat(user, SPAN_WARNING("The monkey is attached to something."))
		return
	qdel(target)
	to_chat(user, SPAN_NOTICE("You stuff the monkey into the machine."))
	playsound(src.loc, 'sound/machines/juicer.ogg', 50, TRUE)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking
	set_power_use(active_power_usage)
	stored_matter += cube_production
	to_chat( user, SPAN_NOTICE("The machine now has [stored_matter] monkey\s worth of material stored."))

/obj/machinery/monkey_recycler/interact(mob/user)
	if(stored_matter >= 1)
		to_chat(user, SPAN_NOTICE("The machine hisses loudly as it condenses the ground monkey meat. After a moment, it dispenses a brand new monkey cube."))
		playsound(src.loc, 'sound/machines/hiss.ogg', 50, TRUE)
		for(var/i in 1 to Floor(stored_matter, 1))
			new /obj/item/reagent_containers/food/monkeycube(src.loc)
			stored_matter--
		to_chat(user, SPAN_NOTICE("The machine's display flashes that it has [stored_matter] monkeys worth of material left."))
	else
		to_chat(user, SPAN_DANGER("The machine needs at least 1 monkey worth of material to produce a monkey cube. It currently has [stored_matter]."))
