//see also: goonchat
/client/proc/gunchat_init()
	src << output('code/modules/gunchat/gunchat.html',"browseroutput")

/client/verb/gunchat_toggle_combin()
	set name = "Toggle message combining"
	set category = "Chat"
	src << output("","browseroutput:toggleCombin")

/proc/to_chat(list/target, message)
	if(!target || !message)
		return
	if(!istext(message))
		if(istype(message, /image))
			spawn()
				CRASH("show_image should be used instead of to_chat")
		else if(istype(message, /sound))
			spawn()
				CRASH("sound_to should be used instead of to_chat")
		else if(istype(message, /savefile))
			spawn()
				CRASH("to_chat called with savefile")
		else
			spawn()
				CRASH("to_chat: wrong message")
		target << message //send it anyway because we can
		return
	if(target == world)
		target = GLOB.clients

	if(!islist(target))
		target = list(target)
	else
		if(!target.len)
			return
	//Some macros remain in the string even after parsing and fuck up the eventual output
	message = replacetext(message, "\improper", "")
	message = replacetext(message, "\proper", "")
	message = replacetext(message, "\n", "<br>")
	message = replacetext(message, "\t", "    ")

	for(var/pos = findtextEx(message,"[_GUNCHAT_MACRO]\[");pos;pos = findtextEx(message,"[_GUNCHAT_MACRO]\[",pos))
		message = copytext(message,1,pos)+icon2html_lite(locate(copytext(message,pos+length(_GUNCHAT_MACRO),pos+length(_GUNCHAT_MACRO)+11)),target)+copytext(message,pos+length(_GUNCHAT_MACRO)+11)
		//11 = length("[0x0000000]") = length("\ref[]")

	for(var/I in target)
		I << output(url_encode(message), "browseroutput:output")
