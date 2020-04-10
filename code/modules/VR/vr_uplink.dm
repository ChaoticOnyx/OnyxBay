/obj/item/device/uplink/vr_uplink
	var/datum/mind/vr_mind

/obj/item/device/uplink/vr_uplink/interact(mob/user)
	var/dat = "<body link='yellow' alink='white' bgcolor='#601414'><font color='white'>"
	dat += "<B>Thunderfield shop</B><BR>"
	dat += "Thunder-points left: [vr_mind.thunder_points]<BR>"
	dat += "<A href='byond://?src=\ref[src];exit=1'>Exit VR body</a>"
	dat += "<HR>"
	dat += "<B>Request item:</B><BR>"
	dat += "<I>Each item costs a number of thunder-points as indicated by the number following their name.</I><br><BR>"

	get_thunderfield_items()
	//Loop through items
	var/i = 0
	for(var/datum/thunderfield_item/item in GLOB.thunderfield_items)
		i++
		if(item.cost <= vr_mind.thunder_points)
			dat += "<A href='byond://?src=\ref[src];buy_item=1:[i]'>[item.name]</A> ([item.cost])"
		else
			dat += "<font color='grey'><i>[item.name] ([item.cost]) </i></font>"
		dat += "<BR>"
	dat += "<HR>"
	dat += "<A href='byond://?src=\ref[src];lock=1'>Lock</a>"
	dat += "</font></body>"
	user << browse(dat, "window=hidden")
	onclose(user, "hidden")
	return

/obj/item/device/uplink/vr_uplink/OnTopic(href, href_list)
	..()

	if(!active)
		return

	if(href_list["buy_item"])

		var/item = href_list["buy_item"]
		var/list/split = splittext(item, ":")

		var/number = text2num(split[2])
		var/list/uplink = GLOB.thunderfield_items
		if(uplink && uplink.len >= number)
			var/datum/thunderfield_item/I = uplink[number]
			if(I.cost > vr_mind.thunder_points)
				to_chat(usr, SPAN_NOTICE("<B>You dont have enough points.</B>"))
				interact(usr)
				return
			var/obj/item/O = new I.item(src)
			if(!usr.put_in_any_hand_if_possible(O))
				O.forceMove(get_turf(src.loc))
			usr.mind.thunder_points -= I.cost
	if(href_list["exit"])
		var/mob/living/carbon/human/vrhuman/V = usr
		V.exit_body()
	interact(usr)
