//Adminpaper - it's like paper, but more adminny!
/obj/item/weapon/paper/admin
	name = "administrative paper"
	desc = "If you see this, something has gone horribly wrong."
	var/datum/admins/admindatum = null

	var/interactions = null
	var/isCrayon = 0
	var/origin = null
	var/mob/sender = null
	var/obj/machinery/photocopier/faxmachine/destination

	var/header = null
	var/headerOn = TRUE

	var/footer = null
	var/footerOn = FALSE

	var/logo_list = list("ntlogo.png","sollogo.png","terralogo.png")
	var/logo = ""

/obj/item/weapon/paper/admin/New()
	..()
	generateInteractions()


/obj/item/weapon/paper/admin/proc/generateInteractions()
	//clear first
	interactions = null

	//Snapshot is crazy and likes putting each topic hyperlink on a seperate line from any other tags so it's nice and clean.
	interactions += "<HR><center><font size= \"1\">The fax will transmit everything above this line</font><br>"
	interactions += "<A href='?src=\ref[src];confirm=1'>Send fax</A> "
	interactions += "<A href='?src=\ref[src];penmode=1'>Pen mode: [isCrayon ? "Crayon" : "Pen"]</A> "
	interactions += "<A href='?src=\ref[src];cancel=1'>Cancel fax</A> "
	interactions += "<BR>"
	interactions += "<A href='?src=\ref[src];changelogo=1'>Change logo</A> "
	interactions += "<A href='?src=\ref[src];toggleheader=1'>Toggle Header</A> "
	interactions += "<A href='?src=\ref[src];togglefooter=1'>Toggle Footer</A> "
	interactions += "<A href='?src=\ref[src];clear=1'>Clear page</A> "
	interactions += "</center>"

/obj/item/weapon/paper/admin/proc/generateHeader()
	var/originhash = md5("[origin]")
	var/challengehash = copytext(md5("[game_id]"),1,10) // changed to a hash of the game ID so it's more consistant but changes every round.
	var/text = null
	//TODO change logo based on who you're contacting.
	text = "<center><img src = [logo]></br>"
	text += "<b>[origin] Quantum Uplink Signed Message</b><br>"
	text += "<font size = \"1\">Encryption key: [originhash]<br>"
	text += "Challenge: [challengehash]<br></font></center><hr>"

	header = text

/obj/item/weapon/paper/admin/proc/generateFooter()
	var/text = null

	text = "<hr><font size= \"1\">"
	text += "This transmission is intended only for the addressee and may contain confidential information. Any unauthorized disclosure is strictly prohibited. <br><br>"
	text += "If this transmission is recieved in error, please notify both the sender and the office of [GLOB.using_map.boss_name] Internal Affairs immediately so that corrective action may be taken."
	text += "Failure to comply is a breach of regulation and may be prosecuted to the fullest extent of the law, where applicable."
	text += "</font>"

	footer = text


/obj/item/weapon/paper/admin/proc/adminbrowse()
	generateHeader()
	generateFooter()
	updateDisplay()

obj/item/weapon/paper/admin/proc/updateDisplay()
	show_browser(usr, "<HTML><meta charset=\"utf-8\"><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[headerOn ? header : ""][info_links][stamps][footerOn ? footer : ""][interactions]</BODY></HTML>", "window=[name];can_close=0")



/obj/item/weapon/paper/admin/Topic(href, href_list)
	if(href_list["write"])
		var/id = href_list["write"]
		if(free_space <= 0)
			to_chat(usr, "<span class='info'>There isn't enough space left on \the [src] to write anything.</span>")
			return

		var/t =  sanitize(input("Enter what you want to write:", "Write", null, null) as message, free_space, extra = 0)

		if(!t)
			return

		//t = html_encode(t)
		t = replacetext(t, "\n", "<BR>")
		t = parsepencode(t,,, isCrayon) // Encode everything from pencode to html

		var/terminated = FALSE
		if (findtext(t, @"[end]"))
			t = replacetext(t, @"[end]", "")
			terminated = TRUE

		addtofield(id, t, terminated) // He wants to edit a field, let him.
		if (id == "end" && terminated)
			appendable = FALSE

		update_space()

		updateDisplay()

		update_icon()
		return

	if(href_list["confirm"])
		switch(alert("Are you sure you want to send the fax as is?",, "Yes", "No"))
			if("Yes")
				if(headerOn)
					var/header_with_links = field_regex.Replace(header, "<font face=\"[deffont]\"><A href='?src=\ref[src];write=$1'>write</A></font>")
					header_with_links = sign_field_regex.Replace(header_with_links, " <I><A href='?src=\ref[src];signfield=$1'>sign here</A></I> ")
					info = header + info
					info_links = header_with_links + info_links
				if(footerOn)
					var/footer_with_links = field_regex.Replace(footer, "<font face=\"[deffont]\"><A href='?src=\ref[src];write=$1'>write</A></font>")
					footer_with_links = sign_field_regex.Replace(footer_with_links, " <I><A href='?src=\ref[src];signfield=$1'>sign here</A></I> ")
					info += footer
					info_links += footer_with_links

				close_browser(usr, "window=[name]")
				admindatum.faxCallback(src, destination)
		return

	if(href_list["penmode"])
		isCrayon = !isCrayon
		generateInteractions()
		updateDisplay()
		return

	if(href_list["cancel"])
		close_browser(usr, "window=[name]")
		qdel(src)
		return

	if(href_list["clear"])
		clearpaper()
		updateDisplay()
		return

	if(href_list["toggleheader"])
		headerOn = !headerOn
		updateDisplay()
		return

	if(href_list["togglefooter"])
		footerOn = !footerOn
		updateDisplay()
		return

	if(href_list["changelogo"])
		logo = input(usr, "What logo?", "Choose a logo", "") as null|anything in (logo_list)
		generateHeader()
		updateDisplay()
		return

/obj/item/weapon/paper/admin/get_signature()
	return input(usr, "Enter the name you wish to sign the paper with (will prompt for multiple entries, in order of entry)", "Signature") as text|null
