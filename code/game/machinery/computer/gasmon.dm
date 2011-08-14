var/global/last_core_overload = 0
var/global/last_core_explosion = 0

/obj/machinery/computer/gasmon
	name = "Gas Monitor"
	icon_state = "gas"
	brightnessred = 0
	brightnessgreen = 0
	brightnessblue = 2

	var/id = ""
	var/frequency = 1439
	var/label = ""
	var/datum/radio_frequency/radio_connection
	var/list/signal_info

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption)
			return

		if(signal.data["tag"] == id)
			signal_info = signal.data

			// core overload message
			if(id == "core")

				if(text2num(signal.data["temperature"]) >= 1700 && world.time > last_core_overload + 1000)
					last_core_overload = world.time
					radioalert("CORE OVERLOAD","Core control computer")
				if(text2num(signal.data["temperature"]) >= 2200 && world.time > last_core_explosion + 1000)
					last_core_explosion = world.time
					radioalert("CORE EXPLOSION IMMINENT","Core control computer")
		else
			..(signal)

	attackby(var/obj/O, var/mob/user)
		return src.attack_hand(user)

	attack_ai(var/mob/user as mob)
		return src.attack_hand(user)

	attack_paw(var/mob/user as mob)
		return src.attack_hand(user)

	attack_hand(var/mob/user as mob)
		user << browse(return_text(), "window=computer")
		user.machine = src
		onclose(user, "computer")

	proc/return_text()
		var/list/data = signal_info
		var/sensor_part = ""

		if(data)
			if(data["pressure"])
				sensor_part += "[data["pressure"]] kPa<BR>"
			if(data["temperature"])
				sensor_part += "[data["temperature"]] K<BR>"
			if(data["oxygen"]||data["toxins"]||data["n2"])
				sensor_part += "<B>Gas Composition</B>: <BR>"
				if(data["oxygen"] != null)
					sensor_part += "&nbsp;&nbsp;[data["oxygen"]] %O2 <BR>"
				if(data["toxins"] != null)
					sensor_part += "&nbsp;&nbsp;[data["toxins"]] %TX <BR>"
				if(data["n2"] != null)
					sensor_part += "&nbsp;&nbsp;[data["n2"]] %N2 <BR>"

		else
			sensor_part = "<FONT color='red'>NO DATA</FONT><BR>"

		var/output = {"<B>[label]</B><HR>
<B>Sensor Data: <BR></B>
[sensor_part]<HR>"}

		return output

	process()
		..()
		use_power(250)
		src.updateDialog()
		return

	initialize()
		set_frequency(frequency)

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[frequency]")
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, "[frequency]")

	New()
		label = tag
		..()