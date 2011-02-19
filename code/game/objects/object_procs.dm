// Alters the emote of a mob from emote() - Abi79
/obj/proc/alterMobEmote(var/message, var/type, var/m_type, var/mob/living/user)
	return message

// Overrides the spoken message of a living mob from say() - Abi79
/obj/proc/overrideMobSay(var/message, var/mob/living/user)
	return "not used"

// Catches a message from say() - Headswe
obj/proc/catchMessage(msg,mob/source)
	return

/*/obj/machinery/door/catchMessage(msg,mob/source)
	if(!findtext(msg,"door,open") && !findtext(msg,"door,close"))
		return
	if(istype(source,/mob/living/carbon/human))
		if(!locate(source) in view(3,src))
			return
		if(src.allowed(source))
			for(var/mob/M in viewers(src))
				M << "[src]: Access Granted"
			if(src.density && findtext(msg,"door,open"))
				open()
			else if(findtext(msg,"door,close"))
				close()
		else
			for(var/mob/M in viewers(src))
				M << "[src]: Access Denied"*/

/obj/proc/state(var/msg, var/color) // Yup, hmm... need to look into how to actually change the color via text
	for(var/mob/O in hearers(src, null))
		O.show_message("\icon[src] \blue [msg]", 2)

/obj/proc/updateUsrDialog()
	var/list/nearby = viewers(1, src)
	for(var/mob/M in nearby)
		if ((M.client && M.machine == src))
			src.attack_hand(M)
	if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
		if (!(usr in nearby))
			if (usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
				src.attack_ai(usr)
		else if (istype(usr, /mob/living/silicon/robot))
			if (usr.client && usr.machine==src)
				src.attack_ai(usr)

/obj/proc/updateDialog()
	var/list/nearby = viewers(1, src)
	for(var/mob/M in nearby)
		if ((M.client && M.machine == src))
			src.attack_hand(M)
	AutoUpdateAI(src)

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)

