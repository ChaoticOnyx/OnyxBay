/obj/machinery/meter
	name = "meter"
	desc = "A gas flow meter."
	icon = 'icons/obj/meter.dmi'
	icon_state = "meterX"
	var/atom/target = null //A pipe for the base type
	anchored = 1.0
	power_channel = STATIC_ENVIRON
	var/frequency = 0
	var/id
	idle_power_usage = 15 WATTS
	var/static/list/meter_ea_overlays
	var/last_level = "INIT"
	var/last_val = -666
	var/last_light = -666

/obj/machinery/meter/Initialize()
	. = ..()
	if(!target)
		set_target(locate(/obj/machinery/atmospherics/pipe) in loc)
	if(!meter_ea_overlays)
		generate_overlays()

/obj/machinery/meter/proc/generate_overlays()
	meter_ea_overlays = new
	meter_ea_overlays.len = 10

	meter_ea_overlays[1] = emissive_appearance(icon, "level_1", cache = FALSE)
	meter_ea_overlays[2] = emissive_appearance(icon, "level_2", cache = FALSE)
	meter_ea_overlays[3] = emissive_appearance(icon, "level_3", cache = FALSE)
	meter_ea_overlays[4] = emissive_appearance(icon, "level_4", cache = FALSE)

	meter_ea_overlays[5] = emissive_appearance(icon, "val_1", cache = FALSE)
	meter_ea_overlays[6] = emissive_appearance(icon, "val_2", cache = FALSE)
	meter_ea_overlays[7] = emissive_appearance(icon, "val_3", cache = FALSE)
	meter_ea_overlays[8] = emissive_appearance(icon, "val_4", cache = FALSE)
	meter_ea_overlays[9] = emissive_appearance(icon, "val_5", cache = FALSE)
	meter_ea_overlays[10] = emissive_appearance(icon, "val_6", cache = FALSE)

/obj/machinery/meter/proc/set_target(atom/new_target)
	clear_target()
	target = new_target
	register_signal(target, SIGNAL_QDELETING, nameof(.proc/clear_target))

/obj/machinery/meter/proc/clear_target()
	if(target)
		unregister_signal(target, SIGNAL_QDELETING)
		target = null

/obj/machinery/meter/Destroy()
	clear_target()
	. = ..()

/obj/machinery/meter/Process()
	var/meter_level = ""
	var/meter_val = -1
	var/meter_light = 0

	if(!target)
		meter_level = -1

	else if(stat & (BROKEN|NOPOWER))
		meter_level = 0

	else
		var/datum/gas_mixture/environment = target.return_air()
		if(environment)
			var/env_pressure = environment.return_pressure()
			if(env_pressure <= 0.15 * ONE_ATMOSPHERE)
				meter_level = 0
			else if(env_pressure <= 1.8 * ONE_ATMOSPHERE)
				meter_level = 1
				meter_val = round(env_pressure / (ONE_ATMOSPHERE * 0.3) + 0.5)
				meter_light = 0.35
			else if(env_pressure <= 30 * ONE_ATMOSPHERE)
				meter_level = 2
				meter_val = round(env_pressure / (ONE_ATMOSPHERE * 5) - 0.35) + 1
				meter_light = 0.3
			else if(env_pressure <= 59 * ONE_ATMOSPHERE)
				meter_level = 3
				meter_val = round(env_pressure / (ONE_ATMOSPHERE * 5) - 6) + 1
				meter_light = 0.4
			else
				meter_level = 4
				meter_light = 0.45

			if(frequency)
				var/datum/frequency/radio_connection = SSradio.return_frequency(frequency)

				if(!radio_connection)
					return

				var/datum/signal/signal = new()
				signal.source = src
				signal.data = list(
					"tag" = id,
					"device" = "AM",
					"pressure" = round(env_pressure),
					"sigtype" = "status"
				)
				radio_connection.post_signal(src, signal)

	if(meter_light != last_light)
		if(meter_light)
			set_light(meter_light, 0.35, 1.0, 2, "#99FF33")
		else
			set_light(0)

	if(meter_val != last_val || meter_level != last_level)
		ClearOverlays()
		switch(meter_level)
			if(-1, 0)
				icon_state = "meter[meter_level]"
			if(4)
				icon_state = "meter4"
				AddOverlays(meter_ea_overlays[4])
				AddOverlays(meter_ea_overlays[10])
			else
				icon_state = "meter[meter_level]_[meter_val]"
				AddOverlays(meter_ea_overlays[meter_level])
				AddOverlays(meter_ea_overlays[meter_val + 4])

	last_level = meter_level
	last_val = meter_val
	last_light = meter_light


/obj/machinery/meter/examine(mob/user, infix)
	. = ..()

	if(get_dist(user, src) > 3 && !(istype(user, /mob/living/silicon/ai) || isghost(user)))
		. += SPAN_WARNING("You are too far away to read it.")

	else if(stat & (NOPOWER|BROKEN))
		. += SPAN_WARNING("The display is off.")

	else if(src.target)
		var/datum/gas_mixture/environment = target.return_air()
		if(environment)
			. += "The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [round(environment.temperature,0.01)]K ([round(CONV_KELVIN_CELSIUS(environment.temperature), 0.01)]&deg;C)"
		else
			. += "The sensor error light is blinking."
	else
		. += "The connect error light is blinking."


/obj/machinery/meter/Click()

	if(istype(usr, /mob/living/silicon/ai)) // ghosts can call ..() for examine
		usr.examinate(src)
		return 1

	return ..()

/obj/machinery/meter/attackby(obj/item/W as obj, mob/user as mob)
	if(!isWrench(W))
		return ..()
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
	if (do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG))
		user.visible_message( \
			"<span class='notice'>\The [user] unfastens \the [src].</span>", \
			"<span class='notice'>You have unfastened \the [src].</span>", \
			"You hear ratchet.")
		new /obj/item/pipe_meter(src.loc)
		qdel(src)

// TURF METER - REPORTS A TILE'S AIR CONTENTS

/obj/machinery/meter/turf/Initialize()
	if (!target)
		set_target(loc)
	. = ..()

/obj/machinery/meter/turf/attackby(obj/item/W as obj, mob/user as mob)
