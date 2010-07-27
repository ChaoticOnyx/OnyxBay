/obj/machinery/computer/atmosphere/mixer/process()
	..()
	updateDialog()

/obj/machinery/computer/atmosphere/mixer/Topic(href, href_list)
	if(..())
		return
	usr.machine = src

	if(!href_list["adjust"])
		return
	var/t = text2num(href_list["adjust"])
	if (t > 2 || t < 1)
		return

	rates[t] += text2num(href_list["by"])

	mixer.node1_concentration = rates[1]
	mixer.node2_concentration = rates[2]

	src.updateUsrDialog()

/obj/machinery/computer/atmosphere/mixer/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/atmosphere/mixer/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/atmosphere/mixer/attack_hand(var/mob/user as mob)
	if(..())
		return

	user.machine = src


	var/dat = {"<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>Mixer Control</title>
</head>
<body style="background-color: #F5F5DC">
    <center>
        <img src="UI/MixerComputer.png" alt="" style="border: inset 4px white" />
    </center>
    <hr />
    <tt>
    Mixing Control<br />
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
    <b>A:</b> [mixer.air_in1.return_pressure()]kPa [round(mixer.air_in1.temperature, 0.1)]K 21%O2 79%N2<br />
    <b>B:</b> [mixer.air_in2.return_pressure()]kPa [round(mixer.air_in2.temperature, 0.1)]K 100%PL<br />
    <br />
    <b>Output Gas:</b><br />
    [mixer.air_out.return_pressure()]kPa [round(mixer.air_out.temperature, 0.1)]K<br />
    11.5%O2 39.5%N2 50%PL
    </tt>
    <hr />
    <tt>
    <a href="?src=\ref[user];mach_close=mixer">Close</a>
    </tt>
</body>
</html>
"}
	user << browse_rsc('MixerComputer.png')
	user << browse(dat, "window=mixer;size=200x115")
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
