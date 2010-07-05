/obj/machinery/computer/gasmon
	name = "Gas Monitor"
	icon_state = "gas"
	var/id = ""
	var/frequency = 1439
	var/datum/radio_frequency/radio_connection
	var/list/signal_info

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption)
			return

		if(signal.data["tag"] == id)
			signal_info = signal.data
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
				sensor_part += "[data["pressure"]] kPa"
				if(data["temperature"])
					sensor_part += ", [data["temperature"]] K"
				sensor_part += "<BR>"
			else if(data["temperature"])
				sensor_part += "[data["temperature"]] K<BR>"

			if(data["oxygen"]||data["toxins"])
				sensor_part += "<B>Gas Composition</B>: "
				if(data["oxygen"])
					sensor_part += "[data["oxygen"]] %O2"
					if(data["toxins"])
						sensor_part += ", [data["toxins"]] %TX"
					sensor_part += "<BR>"
				else if(data["toxins"])
					sensor_part += "[data["toxins"]] %TX<BR>"

		else
			sensor_part = "<FONT color='red'>NO DATA</FONT><BR>"

		var/output = {"<B>[tag]</B><HR>
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