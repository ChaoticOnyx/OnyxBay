
/obj/item/mcu_module/signaler
	name = "signaler module"
	desc = "A signaler module for a MCU."
	icon_state = "signaler"

	var/datum/frequency/__radio_connection = null
	var/__code = 30
	var/__callback_ip = null

/obj/item/mcu_module/signaler/Destroy()
	if(__radio_connection != null)
		SSradio.remove_object(src, __radio_connection.frequency)

	. = ..()

/obj/item/mcu_module/signaler/receive_signal(datum/signal/signal)
	if(signal == null || __radio_connection == null || __host == null || __callback_ip == null)
		return

	if(signal.encryption != __code)
		return

	var/obj/item/device/mcu/M = __host.resolve()

	if(!M.__interrupts_enabled)
		return

	if(!M.push_callstack())
		return

	M.__script.set_ip(__callback_ip)

/obj/item/mcu_module/signaler/think()
	ready = TRUE

/obj/item/mcu_module/signaler/__reset(attached)
	set_next_think(0)
	ready = TRUE

/obj/item/mcu_module/signaler/proc/__send_function()
	if(!ready)
		return Z_SCRIPT_FUNCTION_ERROR

	if(__radio_connection == null)
		return Z_SCRIPT_FUNCTION_ERROR

	playsound(src.loc, 'sound/signals/signaler.ogg', 35)

	var/datum/signal/signal = new(list("message" = "ACTIVATE"), encryption = __code)
	__radio_connection.post_signal(src, signal)

	ready = FALSE
	set_next_think(world.time + config.mcu.signaler_send_cooldown)

	return Z_SCRIPT_FUNCTION_OK

/obj/item/mcu_module/signaler/proc/__set_frequency_function()
	if(!ready)
		return Z_SCRIPT_FUNCTION_ERROR
	
	var/frequency = args[1]
	var/code = args[2]

	if(frequency < RADIO_LOW_FREQ || frequency > RADIO_HIGH_FREQ)
		return Z_SCRIPT_FUNCTION_ERROR

	if(code < 1 || code > 100)
		return Z_SCRIPT_FUNCTION_ERROR

	if(__radio_connection != null)
		SSradio.remove_object(src, frequency)

	__radio_connection = SSradio.add_object(src, frequency, RADIO_CHAT)
	__code = code

	set_next_think(world.time + config.mcu.signaler_set_cooldown)
	ready = FALSE

	return Z_SCRIPT_FUNCTION_OK

/obj/item/mcu_module/signaler/proc/__set_pulse_callback_function()
	__callback_ip = args[1]

	return Z_SCRIPT_FUNCTION_OK
