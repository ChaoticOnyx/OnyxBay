/proc/parse_zone(zone)
	if(zone == "r_hand") return "right hand"
	else if (zone == "l_hand") return "left hand"
	else if (zone == "l_arm") return "left arm"
	else if (zone == "r_arm") return "right arm"
	else if (zone == "l_leg") return "left leg"
	else if (zone == "r_leg") return "right leg"
	else if (zone == "l_foot") return "left foot"
	else if (zone == "r_foot") return "right foot"
	else return zone

/proc/text2dir(direction)
	switch(uppertext(direction))
		if("NORTH")
			return 1
		if("SOUTH")
			return 2
		if("EAST")
			return 4
		if("WEST")
			return 8
		if("NORTHEAST")
			return 5
		if("NORTHWEST")
			return 9
		if("SOUTHEAST")
			return 6
		if("SOUTHWEST")
			return 10
		else
	return

/proc/get_turf(turf/location as turf)
	while (location)
		if (istype(location, /turf))
			return location

		location = location.loc
	return null

/proc/get_turf_or_move(turf/location as turf)
	location = get_turf(location)
	return location



/proc/dir2text(direction)
	switch(direction)
		if(1.0)
			return "north"
		if(2.0)
			return "south"
		if(4.0)
			return "east"
		if(8.0)
			return "west"
		if(5.0)
			return "northeast"
		if(6.0)
			return "southeast"
		if(9.0)
			return "northwest"
		if(10.0)
			return "southwest"
		else
	return

/obj/proc/hear_talk(mob/M as mob, message,italics,alt_name)
	var/mob/mo = locate(/mob) in src
	var/list/understood = list()
	var/list/didnot = list()
	if(mo)
		for(var/mob/mos in src)
			if(mos.say_understands(M))
				understood += mos
				continue
			else
				didnot += mos
	var/rendered
	if (length(understood))
		var/message_a = M.say_quote(message)
		if (italics)
			message_a = "<i>[message_a]</i>"

		if (!istype(M, /mob/living/carbon/human) || istype(M.wear_mask, /obj/item/clothing/mask/gas/voice))
			rendered = "<span class='game say'><span class='name'>[M.name]</span> <span class='message'>[message_a]</span></span>"
		else if(M.face_dmg)
			rendered = "<span class='game say'><span class='name'>Unknown</span> <span class='message'>[message_a]</span></span>"
		else
			rendered = "<span class='game say'><span class='name'>[M.real_name]</span>[alt_name] <span class='message'>[message_a]</span></span>"

		for (var/mob/MS in understood)
			MS.show_message(rendered, 6)

	if (length(didnot))
		var/message_b

		if(M.say_unknown())
			message_b = M.say_unknown()

		else if (M.voice_message)
			message_b = M.voice_message
		else
			message_b = Ellipsis(message)
			message_b = M.say_quote(message_b)

		if (italics)
			message_b = "<i>[message_b]</i>"

		rendered = "<span class='game say'><span class='name'>[M.voice_name]</span> <span class='message'>[message_b]</span></span>"

		for (var/mob/MS in didnot)
			MS.show_message(rendered, 6)

	// I HATE YOU FOR THIS