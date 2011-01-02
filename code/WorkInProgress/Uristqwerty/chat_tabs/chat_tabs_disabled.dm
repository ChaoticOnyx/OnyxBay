//
//  Use this code file to redirect tabbed chat to regular chat.
//

/mob/proc/ctab_message(var/tab, var/message)
	src message

/client/proc/ctab_message(var/tab, var/message)
	src message