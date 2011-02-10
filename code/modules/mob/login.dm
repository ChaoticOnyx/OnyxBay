/mob/Login()
	log_access("Login: [key_name(src)] from [client.address ? client.address : "localhost"]")
	lastKnownIP = client.address
	computer_id = client.computer_id
	if (config.log_access)
		for (var/mob/M in world)
			if(M == src)
				continue
			if(M.client && M.client.address == client.address)
				log_access("Notice: [key_name(src)] has same IP address as [key_name(M)]")
				message_admins("<font color='red'><B>Notice: </B><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same IP address as <A href='?src=\ref[usr];priv_msg=\ref[M]'>[key_name_admin(M)]</A></font>", 1)
			else if (M.lastKnownIP && M.lastKnownIP == client.address && M.ckey != ckey && M.key)
				log_access("Notice: [key_name(src)] has same IP address as [key_name(M)] did ([key_name(M)] is no longer logged in).")
				message_admins("<font color='red'><B>Notice: </B><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same IP address as [key_name_admin(M)] did ([key_name_admin(M)] is no longer logged in).</font>", 1)
			if(M.client && M.client.computer_id == client.computer_id)
				log_access("Notice: [key_name(src)] has same computer ID as [key_name(M)]")
				message_admins("<font color='red'><B>Notice: </B><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same <font color='red'><B>computer ID</B><font color='blue'> as <A href='?src=\ref[usr];priv_msg=\ref[M]'>[key_name_admin(M)]</A></font>", 1)
				spawn() alert("You have logged in already with another key this round, please log out of this one NOW or risk being banned!")
			else if (M.computer_id && M.computer_id == client.computer_id && M.ckey != ckey && M.key)
				log_access("Notice: [key_name(src)] has same computer ID as [key_name(M)] did ([key_name(M)] is no longer logged in).")
				message_admins("<font color='red'><B>Notice: </B><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same <font color='red'><B>computer ID</B><font color='blue'> as [key_name_admin(M)] did ([key_name_admin(M)] is no longer logged in).</font>", 1)
				spawn() alert("You have logged in already with another key this round, please log out of this one NOW or risk being banned!")
	if(!dna) dna = new /datum/dna(null)
	//client.screen -= main_hud1.contents
	world.update_status()
	//if (!hud_used)
	//	hud_used = main_hud1

	if (!hud_used)
		hud_used = new/obj/hud( src )
	else
		del(hud_used)
		hud_used = new/obj/hud( src )
	world.makejson()
	next_move = 1
	sight |= SEE_SELF
	logged_in = 1
	if (!client.changes)
		changes()

	..()
