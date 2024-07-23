/obj/machinery/atmospherics/unary/vent_scrubber
	icon = 'icons/atmos/vent_scrubber.dmi'
	icon_state = "map_scrubber_off"
	plane = TURF_PLANE

	name = "Air Scrubber"
	desc = "Has a valve and pump attached to it."
	use_power = POWER_USE_OFF
	idle_power_usage = 150 WATTS //internal circuitry, friction losses and stuff
	power_rating = 7500			//7500 W ~ 10 HP

	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_SCRUBBER //connects to regular and scrubber pipes

	level = 1

	var/area/initial_loc
	var/id_tag = null
	var/frequency = 1439
	var/datum/frequency/radio_connection

	var/hibernate = 0 //Do we even process?
	var/scrubbing = 1 //0 = siphoning, 1 = scrubbing
	var/list/scrubbing_gas

	var/panic = 0 //is this scrubber panicked?

	var/area_uid
	var/radio_filter_out
	var/radio_filter_in

	var/welded = 0
	var/broken = VENT_UNDAMAGED

/obj/machinery/atmospherics/unary/vent_scrubber/on
	use_power = POWER_USE_IDLE
	icon_state = "map_scrubber_on"

/obj/machinery/atmospherics/unary/vent_scrubber/Initialize()
	. = ..()
	air_contents.volume = ATMOS_DEFAULT_VOLUME_FILTER
	icon = null

/obj/machinery/atmospherics/unary/vent_scrubber/Destroy()
	SSradio.remove_object(src, frequency)
	if(initial_loc)
		initial_loc.air_scrub_info -= id_tag
		initial_loc.air_scrub_names -= id_tag
		initial_loc = null
	return ..()

/obj/machinery/atmospherics/unary/vent_scrubber/on_update_icon(safety = 0)
	if(!check_icon_cache())
		return

	ClearOverlays()


	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	var/scrubber_icon = "scrubber"
	if(broken)
		switch(broken)
			if(VENT_DAMAGED_STAGE_ONE)
				scrubber_icon += "damaged_1"
			if(VENT_DAMAGED_STAGE_TWO)
				scrubber_icon += "damaged_2"
			if(VENT_DAMAGED_STAGE_THREE)
				scrubber_icon += "damaged_3"
			if(VENT_BROKEN)
				scrubber_icon += "broken"
	else if(welded)
		scrubber_icon += "weld"
	else if(!powered())
		scrubber_icon += "off"
	else
		scrubber_icon += "[use_power ? "[scrubbing ? "on" : "in"]" : "off"]"

	AddOverlays(icon_manager.get_atmos_icon("device", , , scrubber_icon))

/obj/machinery/atmospherics/unary/vent_scrubber/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		if(!T.is_plating() && node && node.level == 1 && istype(node, /obj/machinery/atmospherics/pipe))
			return
		else
			if(node)
				add_underlay(T, node, dir, node.icon_connect_type)
			else
				add_underlay(T,, dir)

/obj/machinery/atmospherics/unary/vent_scrubber/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, radio_filter_in)

/obj/machinery/atmospherics/unary/vent_scrubber/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/list/data = list(
			"area" = area_uid,
			"tag" = id_tag,
			"device" = "AScr",
			"timestamp" = world.time,
			"power" = use_power,
			"scrubbing" = scrubbing,
			"panic" = panic,
			"filter_o2" = ("oxygen" in scrubbing_gas),
			"filter_n2" = ("nitrogen" in scrubbing_gas),
			"filter_co2" = ("carbon_dioxide" in scrubbing_gas),
			"filter_plasma" = ("plasma" in scrubbing_gas),
			"filter_n2o" = ("sleeping_agent" in scrubbing_gas),
			"sigtype" = "status"
		)

	if(!initial_loc.air_scrub_names[id_tag])
		var/new_name = "[initial_loc.name] Air Scrubber #[initial_loc.air_scrub_names.len+1]"
		initial_loc.air_scrub_names[id_tag] = new_name
		src.SetName(new_name)

	initial_loc.air_scrub_info[id_tag] = data

	var/datum/signal/signal = new(data)
	radio_connection.post_signal(src, signal, radio_filter_out)

	return 1

/obj/machinery/atmospherics/unary/vent_scrubber/Initialize()
	. = ..()
	initial_loc = get_area(loc)
	area_uid = initial_loc.uid
	if (!id_tag)
		assign_uid()
		id_tag = num2text(uid)
	radio_filter_in = frequency==initial(frequency)?(RADIO_FROM_AIRALARM):null
	radio_filter_out = frequency==initial(frequency)?(RADIO_TO_AIRALARM):null
	if (frequency)
		set_frequency(frequency)
		src.broadcast_status()
	if(!scrubbing_gas)
		scrubbing_gas = list()
		for(var/g in gas_data.gases)
			if(g != "oxygen" && g != "nitrogen")
				scrubbing_gas += g

/obj/machinery/atmospherics/unary/vent_scrubber/Process()
	..()

	if (hibernate > world.time)
		return 1

	if (!node)
		update_use_power(POWER_USE_OFF)
	//broadcast_status()
	if(!use_power || (stat & (NOPOWER|BROKEN)))
		return 0
	if(welded)
		return 0
	if(broken)
		return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/power_draw = -1
	if(scrubbing)
		//limit flow rate from turfs
		var/transfer_moles = min(environment.total_moles, environment.total_moles*MAX_SCRUBBER_FLOWRATE/environment.volume)	//group_multiplier gets divided out here

		power_draw = scrub_gas(src, scrubbing_gas, environment, air_contents, transfer_moles, power_rating)
	else //Just siphon all air
		//limit flow rate from turfs
		var/transfer_moles = min(environment.total_moles, environment.total_moles*MAX_SIPHON_FLOWRATE/environment.volume)	//group_multiplier gets divided out here

		power_draw = pump_gas(src, environment, air_contents, transfer_moles, power_rating)

	if(scrubbing && power_draw <= 0)	//99% of all scrubbers
		//Fucking hibernate because you ain't doing shit.
		hibernate = world.time + (rand(100,200))

	if (power_draw >= 0)
		last_power_draw = power_draw
		use_power_oneoff(power_draw)

	if(network)
		network.update = 1

	return 1

/obj/machinery/atmospherics/unary/vent_scrubber/hide(i) //to make the little pipe section invisible, the icon changes.
	update_icon()
	update_underlays()

/obj/machinery/atmospherics/unary/vent_scrubber/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
		return 0

	if(signal.data["power"] != null)
		update_use_power(sanitize_integer(text2num(signal.data["power"]), POWER_USE_OFF, POWER_USE_ACTIVE, use_power))
	if(signal.data["power_toggle"] != null)
		update_use_power(!use_power)

	if(signal.data["panic_siphon"]) //must be before if("scrubbing" thing
		panic = text2num(signal.data["panic_siphon"])
		if(panic)
			update_use_power(POWER_USE_IDLE)
			scrubbing = 0
		else
			scrubbing = 1
	if(signal.data["toggle_panic_siphon"] != null)
		panic = !panic
		if(panic)
			update_use_power(POWER_USE_IDLE)
			scrubbing = 0
		else
			scrubbing = 1

	if(signal.data["scrubbing"] != null)
		scrubbing = text2num(signal.data["scrubbing"])
		if(scrubbing)
			panic = 0
	if(signal.data["toggle_scrubbing"])
		scrubbing = !scrubbing
		if(scrubbing)
			panic = 0

	var/list/toggle = list()

	if(!isnull(signal.data["o2_scrub"]) && text2num(signal.data["o2_scrub"]) != ("oxygen" in scrubbing_gas))
		toggle += "oxygen"
	else if(signal.data["toggle_o2_scrub"])
		toggle += "oxygen"

	if(!isnull(signal.data["n2_scrub"]) && text2num(signal.data["n2_scrub"]) != ("nitrogen" in scrubbing_gas))
		toggle += "nitrogen"
	else if(signal.data["toggle_n2_scrub"])
		toggle += "nitrogen"

	if(!isnull(signal.data["co2_scrub"]) && text2num(signal.data["co2_scrub"]) != ("carbon_dioxide" in scrubbing_gas))
		toggle += "carbon_dioxide"
	else if(signal.data["toggle_co2_scrub"])
		toggle += "carbon_dioxide"

	if(!isnull(signal.data["tox_scrub"]) && text2num(signal.data["tox_scrub"]) != ("plasma" in scrubbing_gas))
		toggle += "plasma"
	else if(signal.data["toggle_tox_scrub"])
		toggle += "plasma"

	if(!isnull(signal.data["n2o_scrub"]) && text2num(signal.data["n2o_scrub"]) != ("sleeping_agent" in scrubbing_gas))
		toggle += "sleeping_agent"
	else if(signal.data["toggle_n2o_scrub"])
		toggle += "sleeping_agent"

	scrubbing_gas ^= toggle

	if(signal.data["init"] != null)
		SetName(signal.data["init"])
		return

	if(signal.data["status"] != null)
		spawn(2)
			broadcast_status()
		return //do not update_icon

//			log_admin("DEBUG \[[world.timeofday]\]: vent_scrubber/receive_signal: unknown command \"[signal.data["command"]]\"\n[signal.debug_print()]")
	spawn(2)
		broadcast_status()
	update_icon()
	return

/obj/machinery/atmospherics/unary/vent_scrubber/attackby(obj/item/W as obj, mob/user as mob)
	if(isWrench(W))
		if (!(stat & NOPOWER) && use_power)
			to_chat(user, "<span class='warning'>You cannot unwrench \the [src], turn it off first.</span>")
			return 1
		var/turf/T = src.loc
		if (node && node.level==1 && isturf(T) && !T.is_plating())
			to_chat(user, "<span class='warning'>You must remove the plating first.</span>")
			return 1
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
		if (do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG))
			user.visible_message( \
				"<span class='notice'>\The [user] unfastens \the [src].</span>", \
				"<span class='notice'>You have unfastened \the [src].</span>", \
				"You hear a ratchet.")
			var/obj/item/pipe/P = new(loc, null, null, src)
			if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
				to_chat(user, "<span class='warning'>\the [src] flies off because of the overpressure in it!</span>")
				P.throw_at_random(0, round((int_air.return_pressure()-env_air.return_pressure()) / 100), 30)
			qdel(src)
		return 1

	if(isWelder(W))

		var/obj/item/weldingtool/WT = W

		if(broken)
			if(!WT.use_tool(src, user, delay = 2 SECONDS, amount = 5))
				return

			if(QDELETED(src) || !user)
				return

			user.visible_message(SPAN_NOTICE("\The [user] repairing \the [src]."), \
				SPAN_NOTICE("Now repairing \the [src]."), \
				"You hear welding.")

			switch(broken)
				if(VENT_DAMAGED_STAGE_ONE)
					broken=VENT_UNDAMAGED
				if(VENT_DAMAGED_STAGE_TWO)
					broken=VENT_DAMAGED_STAGE_ONE
				if(VENT_DAMAGED_STAGE_THREE)
					broken=VENT_DAMAGED_STAGE_TWO
				if(VENT_BROKEN)
					to_chat(user, SPAN_NOTICE("\The [src] is ruined! You can't repair it!"))
					return

			update_icon()
			return

		else
			if(!WT.use_tool(src, user, delay = 2 SECONDS, amount = 5))
				return

			if(QDELETED(src) || !user)
				return

			welded = !welded
			update_icon()
			user.visible_message("<span class='notice'>\The [user] [welded ? "welds \the [src] shut" : "unwelds \the [src]"].</span>", \
				"<span class='notice'>You [welded ? "weld \the [src] shut" : "unweld \the [src]"].</span>", \
				"You hear welding.")
			return

	return ..()

/obj/machinery/atmospherics/unary/vent_scrubber/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) <= 1)
		. += "A small gauge in the corner reads [round(last_flow_rate, 0.1)] L/s; [round(last_power_draw)] W"
	else
		. += "You are too far away to read the gauge."

	if(welded)
		. += "It seems welded shut."

	if(broken)
		switch(broken)
			if(VENT_DAMAGED_STAGE_ONE)
				. += "It seems slightly damaged."
			if(VENT_DAMAGED_STAGE_TWO)
				. += "It seems pretty damaged."
			if(VENT_DAMAGED_STAGE_THREE)
				. += "It seems heavily damaged."
			if(VENT_BROKEN)
				. += "It seems absolutely destroyed."
