/obj/machinery/computer/textadv
	name = "Quest for Macguffin"
	icon = 'computer.dmi'
	icon_state = "arcade"
	var/datum/textadv/ta = new/datum/textadv
	var/list/msgs = list()
	var/turns
	var/lastcharge
	var/credits = 0
	brightnessred = 0
	brightnessgreen = 2
	brightnessblue = 0



/obj/machinery/computer/textadv/attack_hand(var/mob/user)
	var/inmsg = input(">") as text
	var/outmsg = ta.Do(uppertext(inmsg))
	msgs+=">[inmsg]"
	msgs+=outmsg
	user<<">[inmsg]"
	user<<outmsg