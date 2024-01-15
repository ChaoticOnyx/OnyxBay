/obj/machinery/embedded_controller
	var/datum/computer/file/embedded_program/program	//the currently executing program

	name = "Embedded Controller"
	anchored = 1
	idle_power_usage = 10 WATTS

	var/on = 1

/obj/machinery/embedded_controller/radio/Destroy()
	SSradio.remove_object(src,frequency)
	return ..()

/obj/machinery/embedded_controller/proc/post_signal(datum/signal/signal, comm_line)
	return 0

/obj/machinery/embedded_controller/receive_signal(datum/signal/signal, receive_param)
	if(!signal || signal.encryption) return

	if(program)
		program.receive_signal(signal, receive_param)
			//spawn(5) program.process() //no, program.process sends some signals and machines respond and we here again and we lag -rastaf0

/obj/machinery/embedded_controller/Process()
	if(program)
		program.process()

	update_icon()

/obj/machinery/embedded_controller/attack_ai(mob/user as mob)
	src.ui_interact(user)

/obj/machinery/embedded_controller/attack_hand(mob/user as mob)

	if(!user.IsAdvancedToolUser())
		return 0

	src.ui_interact(user)

/obj/machinery/embedded_controller/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/nanoui/master_ui = null, datum/topic_state/state = GLOB.default_state)
	return

/obj/machinery/embedded_controller/radio
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	power_channel = STATIC_ENVIRON
	density = 0

	var/id_tag
	//var/radio_power_use = 50 //power used to xmit signals

	var/frequency = 1379
	var/radio_filter = null
	var/datum/frequency/radio_connection
	unacidable = 1

/obj/machinery/embedded_controller/radio/Initialize()
	set_frequency(frequency)
	. = ..()

/obj/machinery/embedded_controller/radio/on_update_icon()
	if(!on || !program)
		icon_state = "airlock_control_off"
	else if(program.memory["processing"])
		icon_state = "airlock_control_process"
	else
		icon_state = "airlock_control_standby"

/obj/machinery/embedded_controller/radio/post_signal(datum/signal/signal, radio_filter = null)
	if(radio_connection)
		//use_power(radio_power_use)	//neat idea, but causes way too much lag.
		return radio_connection.post_signal(src, signal, radio_filter)
	else
		qdel(signal)

/obj/machinery/embedded_controller/radio/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, radio_filter)
