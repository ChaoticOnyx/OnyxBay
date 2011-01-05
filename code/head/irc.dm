var/dll = world.system_type == MS_WINDOWS ? "libircclient.dll" : "./merge.so"

mob/verb/ircstart()
	if(call(dll,"irc_create_session")())
		world << "yay?"
	else
		world << "DUNNO"
	if(call(dll,"irc_connect")())