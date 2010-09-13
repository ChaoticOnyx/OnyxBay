/mob/living/carbon/alien/emote(var/act)

	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)
	var/muzzled = istype(wear_mask, /obj/item/clothing/mask/muzzle)
	var/m_type = 1
	var/message

	switch(act)
		if("sign")
			if (!restrained())
				message = text("<B>The alien</B> signs[].", (text2num(param) ? text(" the number []", text2num(param)) : null))
				m_type = 1
		if ("burp")
			if (!muzzled)
				message = "<B>[src]</B> burps."
				m_type = 2
		if("scratch")
			if (!restrained())
				message = "<B>The [name]</B> scratches."
				m_type = 1
		if("whimper")
			if (!muzzled)
				message = "<B>The [name]</B> whimpers."
				m_type = 2
		if("roar")
			if (!muzzled)
				message = "<B>The [name]</B> roars."
				m_type = 2
		if("tail")
			message = "<B>The [name]</B> waves his tail."
			m_type = 1
		if("gasp")
			message = "<B>The [name]</B> gasps."
			m_type = 2
		if("shiver")
			message = "<B>The [name]</B> shivers."
			m_type = 2
		if("drool")
			message = "<B>The [name]</B> drools."
			m_type = 1
		if("scretch")
			if (!muzzled)
				message = "<B>The [name]</B> scretches."
				m_type = 2
		if("choke")
			message = "<B>The [name]</B> chokes."
			m_type = 2
		if("moan")
			message = "<B>The [name]</B> moans!"
			m_type = 2
		if("nod")
			message = "<B>The [name]</B> nods his head."
			m_type = 1
		if("sit")
			message = "<B>The [name]</B> sits down."
			m_type = 1
		if("sway")
			message = "<B>The [name]</B> sways around dizzily."
			m_type = 1
		if("sulk")
			message = "<B>The [name]</B> sulks down sadly."
			m_type = 1
		if("twitch")
			message = "<B>The [name]</B> twitches violently."
			m_type = 1
		if("dance")
			if (!restrained())
				message = "<B>The [name]</B> dances around happily."
				m_type = 1
		if("roll")
			if (!restrained())
				message = "<B>The [name]</B> rolls."
				m_type = 1
		if("shake")
			message = "<B>The [name]</B> shakes his head."
			m_type = 1
		if("gnarl")
			if (!muzzled)
				message = "<B>The [name]</B> gnarls and shows his teeth.."
				m_type = 2
		if("jump")
			message = "<B>The [name]</B> jumps!"
			m_type = 1
		if("collapse")
			if (!paralysis)	paralysis += 2
			message = text("<B>[]</B> collapses!", src)
			m_type = 2
		if("help")
			src << "choke, collapse, dance, drool, gasp, shiver, gnarl, jump, moan, nod, roar, roll, scratch,\nscretch, shake, sign-#, sit, sulk, sway, tail, twitch, whimper"
		else
			src << text("Invalid Emote: []", act)
	if ((message && stat == 0))
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(703)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(746)
	return