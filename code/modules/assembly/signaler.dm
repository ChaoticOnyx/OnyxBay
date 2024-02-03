/obj/item/device/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices."
	icon_state = "signaller"
	item_state = "signaler"
	origin_tech = list(TECH_MAGNET = 1)
	matter = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 200, MATERIAL_WASTE = 100)
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE

	var/code = 30
	var/frequency = 1457
	var/delay = 0
	var/airlock_wire = null
	var/datum/wires/connected = null
	var/datum/frequency/radio_connection
	var/deadman = FALSE

	drop_sound = SFX_DROP_COMPONENT
	pickup_sound = SFX_PICKUP_COMPONENT

/obj/item/device/assembly/signaler/New()
	..()
	addtimer(CALLBACK(src, nameof(.proc/set_frequency), frequency), 4 SECOND)
	return


/obj/item/device/assembly/signaler/activate()
	if(!..())
		return FALSE
	signal()
	return TRUE

/obj/item/device/assembly/signaler/on_update_icon()
	if(holder)
		holder.update_icon()
	return

/obj/item/device/assembly/signaler/attack_self(mob/user)
	tgui_interact(user)

/obj/item/device/assembly/signaler/tgui_host(mob/user)
	if(holder)
		return holder
	else
		return ..()

/obj/item/device/assembly/signaler/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Signaler", "Remote Signaling Device")
		ui.open()

/obj/item/device/assembly/signaler/tgui_data(mob/user)
	var/list/data = list(
		"maxFrequency" = RADIO_HIGH_FREQ,
		"minFrequency" = RADIO_LOW_FREQ,
		"frequency" = frequency,
		"code" = code
	)

	return data

/obj/item/device/assembly/signaler/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("adjust")
			if(params["freq"])
				set_frequency(sanitize_frequency(text2num(params["freq"]), RADIO_LOW_FREQ, RADIO_HIGH_FREQ))
			else if(params["code"])
				code = clamp(text2num(params["code"]), 1, 100)
		if("reset")
			if(params["reset"])
				switch(params["reset"])
					if("freq")
						set_frequency(RADIO_LOW_FREQ)
					if("code")
						code = 1
		if("signal")
			activate()
	. = TRUE

	return

/obj/item/device/assembly/signaler/proc/signal()
	if(!radio_connection)
		return

	playsound(src.loc, 'sound/signals/signaler.ogg', 35)

	var/datum/signal/signal = new(list("message" = "ACTIVATE"), encryption = code)
	radio_connection.post_signal(src, signal)

	return

/obj/item/device/assembly/signaler/pulse(radio = 0)
	if(src.connected && src.wires)
		connected.Pulse(src)
	else if(holder)
		holder.process_activation(src, 1, 0)
	else if(istype(loc, /obj/structure/window_frame))
		var/obj/structure/window_frame/WF = loc
		WF.signaler_pulse()
	else
		..(radio)
	return 1


/obj/item/device/assembly/signaler/receive_signal(datum/signal/signal)
	if(!signal)
		return 0
	if(signal.encryption != code)
		return 0
	if(!(src.wires & WIRE_RADIO_RECEIVE))
		return 0
	pulse(1)

	if(!holder)
		for(var/mob/O in hearers(1, src.loc))
			O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	return


/obj/item/device/assembly/signaler/proc/set_frequency(new_frequency)
	set waitfor = 0
	if(!frequency)
		return
	if(!SSradio)
		sleep(20)
	if(!SSradio)
		return
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_CHAT)
	return

/obj/item/device/assembly/signaler/think()
	if(!deadman)
		return
	var/mob/M = src.loc
	if(!M || !ismob(M))
		if(prob(5))
			signal()
		deadman = 0
		return
	else if(prob(5))
		M.visible_message("[M]'s finger twitches a bit over [src]'s signal button!")

	set_next_think(world.time + 1 SECOND)

/obj/item/device/assembly/signaler/verb/deadman_it()
	set src in usr
	set name = "Threaten to push the button!"
	set desc = "BOOOOM!"

	if(!deadman)
		deadman = TRUE
		set_next_think(world.time)
		log_and_message_admins("is threatening to trigger a signaler deadman's switch")
		usr.visible_message(SPAN("danger", "[usr] moves their finger over [src]'s signal button..."))
	else
		deadman = FALSE
		set_next_think(0)
		log_and_message_admins("stops threatening to trigger a signaler deadman's switch")
		usr.visible_message(SPAN("notice", "[usr] moves their finger away from [src]'s signal button."))


/obj/item/device/assembly/signaler/Destroy()
	SSradio.remove_object(src, frequency)
	frequency = 0
	. = ..()
