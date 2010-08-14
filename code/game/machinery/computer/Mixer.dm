/obj/machinery/computer/atmosphere/mixer/process()
	..()
	updateDialog()

/obj/machinery/computer/atmosphere/mixer/New()
	..()
	spawn(2)
		for(var/obj/machinery/atmospherics/mixer/M in world)
			if (M.id == targettag)
				mixer = M
				rates[1] = M.node1_concentration * 100
				rates[2] = 100 - rates[1]
				rates[1] = min(max(rates[1], 0), 100)
				rates[2] = min(max(rates[2], 0), 100)
				mixer.node1_concentration = rates[1] / 100
				mixer.node2_concentration = rates[2] / 100
				return

/obj/machinery/computer/atmosphere/mixer/Topic(href, href_list)
	if(..() || !mixer)
		return
	usr.machine = src

	if(href_list["adjust"])
		var/t = text2num(href_list["adjust"])
		if (t > 2 || t < 1)
			return

		rates[t] += text2num(href_list["by"])
		rates[3-t] -= text2num(href_list["by"])

		rates[1] = min(max(rates[1], 0), 100)
		rates[2] = min(max(rates[2], 0), 100)

		mixer.node1_concentration = rates[1] / 100
		mixer.node2_concentration = rates[2] / 100

	if(href_list["power"])
		mixer.on = !mixer.on
		mixer.update_icon()

	src.updateUsrDialog()

/obj/machinery/computer/atmosphere/mixer/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/atmosphere/mixer/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/atmosphere/mixer/attack_hand(var/mob/user as mob)
	if(..())
		return

	user.machine = src

	if(!mixer)
		user << browse("<html><body>SYSTEM ERROR</body></html>", "window=mixer;size=200x115")
		onclose(user, "mixer")
		return

	var/air1_moles = mixer.air_in1.total_moles()
	if (!air1_moles)
		air1_moles = 1
	var/air2_moles = mixer.air_in2.total_moles()
	if (!air2_moles)
		air2_moles = 1
	var/airO_moles = mixer.air_out.total_moles()
	if (!airO_moles)
		airO_moles = 1

	var/Air1_Gas = "[round(100*mixer.air_in1.oxygen/air1_moles)] %O2 [round(100*mixer.air_in1.carbon_dioxide/air1_moles)] %CO2 [round(100*mixer.air_in1.nitrogen/air1_moles)] %N2 [round(100*mixer.air_in1.toxins/air1_moles)] %PL"
	var/Air2_Gas = "[round(100*mixer.air_in2.oxygen/air2_moles)] %O2 [round(100*mixer.air_in2.carbon_dioxide/air2_moles)] %CO2 [round(100*mixer.air_in2.nitrogen/air2_moles)] %N2 [round(100*mixer.air_in2.toxins/air2_moles)] %PL"
	var/AirO_Gas = "[round(100*mixer.air_out.oxygen/airO_moles)] %O2 [round(100*mixer.air_out.carbon_dioxide/airO_moles)] %CO2 [round(100*mixer.air_out.nitrogen/airO_moles)] %N2 [round(100*mixer.air_out.toxins/airO_moles)] %PL"


	var/dat = {"<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>Mixer Control</title>
</head>
<body style="background-color: #F5F5DC">
    <center>
        <img src="MixerComputer.png" alt="" style="border: inset 4px white" />
    </center>
    <hr />
    <tt>
    Mixing Control (<a href=\"?src=\ref[src];power=1\">[mixer.on ? "Mixing" : "Inactive"]</a>)<br />
    <br />
    <b>A Rate:</b>
    <a href="?src=\ref[src];adjust=1&by=-25">-</a>
    <a href="?src=\ref[src];adjust=1&by=-5">-</a>
    <a href="?src=\ref[src];adjust=1&by=-1">-</a>
    [rates[1]]
    <a href="?src=\ref[src];adjust=1&by=1">+</a>
    <a href="?src=\ref[src];adjust=1&by=5">+</a>
    <a href="?src=\ref[src];adjust=1&by=25">+</a><br />
    <b>B Rate:</b>
    <a href="?src=\ref[src];adjust=2&by=-25">-</a>
    <a href="?src=\ref[src];adjust=2&by=-5">-</a>
    <a href="?src=\ref[src];adjust=2&by=-1">-</a>
    [rates[2]]
    <a href="?src=\ref[src];adjust=2&by=1">+</a>
    <a href="?src=\ref[src];adjust=2&by=5">+</a>
    <a href="?src=\ref[src];adjust=2&by=25">+</a><br />
    <br />
    <b>Input Gas:</b><br />
    <b>A:</b> [mixer.air_in1.return_pressure()]kPa [round(mixer.air_in1.temperature, 0.1)]K<br />
    [Air1_Gas]<br />
    <b>B:</b> [mixer.air_in2.return_pressure()]kPa [round(mixer.air_in2.temperature, 0.1)]K<br />
    [Air2_Gas]<br />
    <br />
    <b>Output Gas:</b><br />
    [mixer.air_out.return_pressure()]kPa [round(mixer.air_out.temperature, 0.1)]K<br />
    [AirO_Gas]
    </tt>
    <hr />
    <tt>
    <a href="?src=\ref[user];mach_close=mixer">Close</a>
    </tt>
</body>
</html>
"}
	user << browse_rsc('MixerComputer.png')
	user << browse(dat, "window=mixer;size=300x435")
	onclose(user, "mixer")

/obj/machinery/computer/atmosphere/mixer/proc/post_status(var/command, var/data1, var/data2)

	var/datum/radio_frequency/rfrequency = radio_controller.return_frequency(frequency)

	if(!rfrequency) return



	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
		if("alert")
			status_signal.data["picture_state"] = data1

	rfrequency.post_signal(src, status_signal)
