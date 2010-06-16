/obj/machinery/network/sniffer
	var/browser

/obj/machinery/network/sniffer/attack_hand(var/mob/user as mob)
	if(..())
		return
	usr.machine = src
	winshow(user, "obj/machinery/sniffer")
	updateuser(user)

/obj/machinery/network/sniffer/proc/updateuser(var/mob/user)
	user << output(browser, "obj/machinery/sniffer.browser")

/obj/machinery/network/sniffer/receivemessage(var/message, var/obj/sendingunit)
	browser = "[message] from [sendingunit:computernet.id] [sendingunit:computerID]<br>[browser]"
	updateUsrDialog()

/obj/machinery/network/sniffer/UIinput(message)
	switch(message)
		if("send")
			var/msg = winget(usr, "obj/machinery/sniffer.messageSend", "text")
			winset(usr, "obj/machinery/sniffer.messageSend", "text=\"\"")
			transmitmessage(msg)
		if("clear")
			usr << output("", "obj/machinery/sniffer.browser")
			browser = ""

/obj/machinery/computer/network/networksniffer
	var/browser

/obj/machinery/computer/network/networksniffer/attack_hand(var/mob/user as mob)
	if(..())
		return
	usr.machine = src
	winshow(user, "obj/machinery/sniffer")
	updateuser(user)

/obj/machinery/computer/network/networksniffer/proc/updateuser(var/mob/user)
	user << output(browser, "obj/machinery/sniffer.browser")

/obj/machinery/computer/network/networksniffer/receivemessage(var/message, var/obj/sendingunit)
	browser = "[message] from [sendingunit:computernet.id] [sendingunit:computerID]<br>[browser]"
	updateUsrDialog()

/obj/machinery/computer/network/networksniffer/UIinput(message)
	switch(message)
		if("send")
			var/msg = winget(usr, "obj/machinery/sniffer.messageSend", "text")
			winset(usr, "obj/machinery/sniffer.messageSend", "text=\"\"")
			transmitmessage(msg)
		if("clear")
			usr << output("", "obj/machinery/sniffer.browser")
			browser = ""