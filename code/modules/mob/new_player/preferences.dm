datum/preferences
	var/real_name
	var/gender = MALE
	var/age = 30.0
	var/b_type = "A+"

	var/be_syndicate = 0
	var/be_random_name = 0
	var/underwear = 1

	var/occupation1 = "No Preference"
	var/occupation2 = "No Preference"
	var/occupation3 = "No Preference"

	var/h_style = "Short Hair"
	var/f_style = "Shaved"

	var/r_hair = 0.0
	var/g_hair = 0.0
	var/b_hair = 0.0

	var/r_facial = 0.0
	var/g_facial = 0.0
	var/b_facial = 0.0

	var/s_tone = 0.0
	var/r_eyes = 0.0
	var/g_eyes = 0.0
	var/b_eyes = 0.0
	var/curslot = 0
	var/icon/preview_icon = null

	New()
		randomize_name()

		..()

	proc/randomize_name()
		if (gender == MALE)
			real_name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
		else
			real_name = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))

	proc/update_preview_icon()
		del(preview_icon)

		var/g = "m"
		if (gender == MALE)
			g = "m"
		else if (gender == FEMALE)
			g = "f"

		preview_icon = new /icon('human.dmi', "body_[g]_s")

		// Skin tone
		if (s_tone >= 0)
			preview_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
		else
			preview_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)

		if (underwear > 0)
			preview_icon.Blend(new /icon('human.dmi', "underwear[underwear]_[g]_s"), ICON_OVERLAY)

		var/icon/eyes_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "eyes_s")
		eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)

		var/h_style_r = null
		switch(h_style)
			if("Short Hair")
				h_style_r = "hair_a"
			if("Long Hair")
				h_style_r = "hair_b"
			if("Cut Hair")
				h_style_r = "hair_c"
			if("Mohawk")
				h_style_r = "hair_d"
			if("Balding")
				h_style_r = "hair_e"
			if("Fag")
				h_style_r = "hair_f"
			if("Bedhead")
				h_style_r = "hair_bedhead"
			if("Dreadlocks")
				h_style_r = "hair_dreads"
			else
				h_style_r = "bald"

		var/f_style_r = null
		switch(f_style)
			if ("Watson")
				f_style_r = "facial_watson"
			if ("Chaplin")
				f_style_r = "facial_chaplin"
			if ("Selleck")
				f_style_r = "facial_selleck"
			if ("Neckbeard")
				f_style_r = "facial_neckbeard"
			if ("Full Beard")
				f_style_r = "facial_fullbeard"
			if ("Long Beard")
				f_style_r = "facial_longbeard"
			if ("Van Dyke")
				f_style_r = "facial_vandyke"
			if ("Elvis")
				f_style_r = "facial_elvis"
			if ("Abe")
				f_style_r = "facial_abe"
			if ("Chinstrap")
				f_style_r = "facial_chin"
			if ("Hipster")
				f_style_r = "facial_hip"
			if ("Goatee")
				f_style_r = "facial_gt"
			if ("Hogan")
				f_style_r = "facial_hogan"
			else
				f_style_r = "bald"

		var/icon/hair_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "[h_style_r]_s")
		hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)

		var/icon/facial_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "[f_style_r]_s")
		facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)

		var/icon/mouth_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "mouth_[g]_s")

		eyes_s.Blend(hair_s, ICON_OVERLAY)
		eyes_s.Blend(mouth_s, ICON_OVERLAY)
		eyes_s.Blend(facial_s, ICON_OVERLAY)

		preview_icon.Blend(eyes_s, ICON_OVERLAY)

		del(mouth_s)
		del(facial_s)
		del(hair_s)
		del(eyes_s)

	proc/ShowChoices(mob/user)
		update_preview_icon()
		user << browse_rsc(preview_icon, "previewicon.png")

		var/list/destructive = assistant_occupations.Copy()
		var/dat = "<html><body>"
		dat += "<b>Name:</b> "
		dat += "<a href=\"byond://?src=\ref[user];preferences=1;real_name=input\"><b>[real_name]</b></a> "
		dat += "(<a href=\"byond://?src=\ref[user];preferences=1;real_name=random\">&reg;</A>) "
		dat += "(&reg; = <a href=\"byond://?src=\ref[user];preferences=1;b_random_name=1\">[be_random_name ? "Yes" : "No"]</a>)"
		dat += "<br>"

		dat += "<b>Gender:</b> <a href=\"byond://?src=\ref[user];preferences=1;gender=input\"><b>[gender == MALE ? "Male" : "Female"]</b></a><br>"
		dat += "<b>Age:</b> <a href='byond://?src=\ref[user];preferences=1;age=input'>[age]</a>"

		dat += "<hr><b>Occupation Choices</b><br>"
		if (destructive.Find(occupation1))
			dat += "\t<a href=\"byond://?src=\ref[user];preferences=1;occ=1\"><b>[occupation1]</b></a><br>"
		else
			if (jobban_isbanned(user, occupation1))
				occupation1 = "Assistant"
			if (jobban_isbanned(user, occupation2))
				occupation2 = "Assistant"
			if (jobban_isbanned(user, occupation3))
				occupation3 = "Assistant"
			if (occupation1 != "No Preference")
				dat += "\tFirst Choice: <a href=\"byond://?src=\ref[user];preferences=1;occ=1\"><b>[occupation1]</b></a><br>"

				if (destructive.Find(occupation2))
					dat += "\tSecond Choice: <a href=\"byond://?src=\ref[user];preferences=1;occ=2\"><b>[occupation2]</b></a><BR>"

				else
					if (occupation2 != "No Preference")
						dat += "\tSecond Choice: <a href=\"byond://?src=\ref[user];preferences=1;occ=2\"><b>[occupation2]</b></a><BR>"
						dat += "\tLast Choice: <a href=\"byond://?src=\ref[user];preferences=1;occ=3\"><b>[occupation3]</b></a><BR>"

					else
						dat += "\tSecond Choice: <a href=\"byond://?src=\ref[user];preferences=1;occ=2\">No Preference</a><br>"
			else
				dat += "\t<a href=\"byond://?src=\ref[user];preferences=1;occ=1\">No Preference</a><br>"

		dat += "<hr><table><tr><td><b>Body</b><br>"
		dat += "Blood Type: <a href='byond://?src=\ref[user];preferences=1;b_type=input'>[b_type]</a><br>"
		dat += "Skin Tone: <a href='byond://?src=\ref[user];preferences=1;s_tone=input'>[-s_tone + 35]/220</a><br>"
		if (!IsGuestKey(user.key))
			dat += "Underwear: <a href =\"byond://?src=\ref[user];preferences=1;underwear=1\"><b>[underwear == 1 ? "Yes" : "No"]</b></a><br>"
		dat += "</td><td><b>Preview</b><br><img src=previewicon.png height=64 width=64></td></tr></table>"

		dat += "<hr><b>Hair</b><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;hair=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair, 2)]\"><table bgcolor=\"#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair)]\"><tr><td>IM</td></tr></table></font>"
/*
		dat += " <font color=\"#[num2hex(r_hair, 2)]0000\">Red</font> - <a href='byond://?src=\ref[user];preferences=1;r_hair=input'>[r_hair]</a>"
		dat += " <font color=\"#00[num2hex(g_hair, 2)]00\">Green</font> - <a href='byond://?src=\ref[user];preferences=1;g_hair=input'>[g_hair]</a>"
		dat += " <font color=\"#0000[num2hex(b_hair, 2)]\">Blue</font> - <a href='byond://?src=\ref[user];preferences=1;b_hair=input'>[b_hair]</a><br>"
*/
		dat += "Style: <a href='byond://?src=\ref[user];preferences=1;h_style=input'>[h_style]</a>"

		dat += "<hr><b>Facial</b><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;facial=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial, 2)]\"><table bgcolor=\"#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial)]\"><tr><td>GO</td></tr></table></font>"
/*
		dat += " <font color=\"#[num2hex(r_facial, 2)]0000\">Red</font> - <a href='byond://?src=\ref[user];preferences=1;r_facial=input'>[r_facial]</a>"
		dat += " <font color=\"#00[num2hex(g_facial, 2)]00\">Green</font> - <a href='byond://?src=\ref[user];preferences=1;g_facial=input'>[g_facial]</a>"
		dat += " <font color=\"#0000[num2hex(b_facial, 2)]\">Blue</font> - <a href='byond://?src=\ref[user];preferences=1;b_facial=input'>[b_facial]</a><br>"
*/
		dat += "Style: <a href='byond://?src=\ref[user];preferences=1;f_style=input'>[f_style]</a>"

		dat += "<hr><b>Eyes</b><br>"
		dat += "<a href='byond://?src=\ref[user];preferences=1;eyes=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes, 2)]\"><table bgcolor=\"#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes)]\"><tr><td>KU</td></tr></table></font>"
/*
		dat += " <font color=\"#[num2hex(r_eyes, 2)]0000\">Red</font> - <a href='byond://?src=\ref[user];preferences=1;r_eyes=input'>[r_eyes]</a>"
		dat += " <font color=\"#00[num2hex(g_eyes, 2)]00\">Green</font> - <a href='byond://?src=\ref[user];preferences=1;g_eyes=input'>[g_eyes]</a>"
		dat += " <font color=\"#0000[num2hex(b_eyes, 2)]\">Blue</font> - <a href='byond://?src=\ref[user];preferences=1;b_eyes=input'>[b_eyes]</a>"
*/
		dat += "<hr>"
		if(!jobban_isbanned(user, "Syndicate"))
			dat += "<b>Be syndicate?:</b> <a href =\"byond://?src=\ref[user];preferences=1;b_syndicate=1\"><b>[(be_syndicate ? "Yes" : "No")]</b></a><br>"
		else
			dat += "<b> You are banned from being syndicate.</b>"
			be_syndicate = 0
		dat += "<hr>"

		if (!IsGuestKey(user.key))
/*			var/list/slot = list()
			var/DBQuery/query = dbcon.NewQuery("SELECT `slot` FROM `players` WHERE ckey='[usr.ckey]'")
			if(!query.Execute())
				usr << "ERROR"
			while(query.NextRow())
				var/list/row = query.GetRowData()
				slot += row["slot"]

			for(var/T in slot)
				dat += "<a href='byond://?src=\ref[user];preferences=1;loadslot=[T]'>Load Slot [T]</a><br>"
				*/
			if(!curslot)
				dat += "<a href='byond://?src=\ref[user];preferences=1;saveslot=1'>Save Slot 1</a><br>"
			else
				dat += "<a href='byond://?src=\ref[user];preferences=1;saveslot=[curslot]'>Save Slot [curslot]</a><br>"
			dat += "<a href='byond://?src=\ref[user];preferences=1;loadslot2=1'>Load</a><br>"
		dat += "<a href='byond://?src=\ref[user];preferences=1;createslot=1'>Create New Slot</a><br>"
		dat += "<a href='byond://?src=\ref[user];preferences=1;reset_all=1'>Reset Setup</a><br>"
		dat += "</body></html>"

		user << browse(dat, "window=preferences;size=300x640")
	proc/loadsave(mob/user)
		var/dat = "<body>"
		dat += "<tt><center>"
		var/list/slot = list()
		var/list/slotname = list()
		var/DBQuery/query = dbcon.NewQuery("SELECT `slot`,`slotname` FROM `players` WHERE ckey='[usr.ckey]'")
		if(!query.Execute())
			usr << "ERROR"
		while(query.NextRow())
			var/list/row = query.GetRowData()
			slot += row["slot"]
			var/T = row["slot"]
			var/K = row["slotname"]
			slotname += row["slotname"]
			dat += "<a href='byond://?src=\ref[user];preferences=1;loadslot=[T]'>Load Slot [T]([K]) </a><a href='byond://?src=\ref[user];preferences=1;removeslot=[T]'>(R)</a><br><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;loadslot=CLOSE'>Close</a><br>"
		dat += "</center></tt>"
		user << browse(dat, "window=saves;size=300x640")
	proc/closesave(mob/user)
		user << browse(null, "window=saves;size=300x640")
	proc/SetChoices(mob/user, occ=1)
		var/HTML = "<body>"
		HTML += "<tt><center>"
		switch(occ)
			if(1.0)
				HTML += "<b>Which occupation would you like most?</b><br><br>"
			if(2.0)
				HTML += "<b>Which occupation would you like if you couldn't have your first?</b><br><br>"
			if(3.0)
				HTML += "<b>Which occupation would you like if you couldn't have the others?</b><br><br>"
			else
		for(var/job in uniquelist(occupations + assistant_occupations) )
			if ((job!="AI" || config.allow_ai) && !jobban_isbanned(user, job))
				HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[occ];job=[job]\">[job]</a><br>"

		if(!jobban_isbanned(user, "Captain"))
			HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[occ];job=Captain\">Captain</a><br>"
		HTML += "<br>"
		HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[occ];job=No Preference\">\[No Preference\]</a><br>"
		HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[occ];cancel=1\">\[Cancel\]</a>"
		HTML += "</center></tt>"

		user << browse(null, "window=preferences")
		user << browse(HTML, "window=mob_occupation;size=320x500")
		return

	proc/SetJob(mob/user, occ=1, job="Captain")
		if ((!( occupations.Find(job) ) && !( assistant_occupations.Find(job) ) && job != "Captain") && job != "No Preference")
			return
		if (job=="AI" && (!config.allow_ai))
			return
		if (jobban_isbanned(user, job))
			return

		switch(occ)
			if(1.0)
				if (job == occupation1)
					user << browse(null, "window=mob_occupation")
					return
				else
					if (job == "No Preference")
						occupation1 = "No Preference"
						ShowChoices(user)
					else
						if (job == occupation2)
							job = occupation1
							occupation1 = occupation2
							occupation2 = job
						else
							if (job == occupation3)
								job = occupation1
								occupation1 = occupation3
								occupation3 = job
							else
								occupation1 = job
			if(2.0)
				if (job == occupation2)
					user << browse(null, "window=mob_occupation")
					ShowChoices(user)
				else
					if (job == "No Preference")
						if (occupation3 != "No Preference")
							occupation2 = occupation3
							occupation3 = "No Preference"
						else
							occupation2 = "No Preference"
					else
						if (job == occupation1)
							if (occupation2 == "No Preference")
								user << browse(null, "window=mob_occupation")
								return
							job = occupation2
							occupation2 = occupation1
							occupation1 = job
						else
							if (job == occupation3)
								job = occupation2
								occupation2 = occupation3
								occupation3 = job
							else
								occupation2 = job
			if(3.0)
				if (job == occupation3)
					user << browse(null, "window=mob_occupation")
					ShowChoices(user)
				else
					if (job == "No Preference")
						occupation3 = "No Preference"
					else
						if (job == occupation1)
							if (occupation3 == "No Preference")
								user << browse(null, "window=mob_occupation")
								return
							job = occupation3
							occupation3 = occupation1
							occupation1 = job
						else
							if (job == occupation2)
								if (occupation3 == "No Preference")
									user << browse(null, "window=mob_occupation")
									return
								job = occupation3
								occupation3 = occupation2
								occupation2 = job
							else
								occupation3 = job

		user << browse(null, "window=mob_occupation")
		ShowChoices(user)

		return 1

	proc/process_link(mob/user, list/link_tags)

		if (link_tags["occ"])
			if (link_tags["cancel"])
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			else if(link_tags["job"])
				SetJob(user, text2num(link_tags["occ"]), link_tags["job"])
			else
				SetChoices(user, text2num(link_tags["occ"]))

			return 1

		if (link_tags["real_name"])
			var/new_name

			switch(link_tags["real_name"])
				if("input")
					new_name = input(user, "Please select a name:", "Character Generation")  as text
					var/list/bad_characters = list("_", "'", "\"", "<", ">", ";", "[", "]", "{", "}", "|", "\\")
					for(var/c in bad_characters)
						new_name = dd_replacetext(new_name, c, "")
					if(!new_name || (new_name == "Unknown"))
						alert("Don't do this")
						return

				if("random")
					if (gender == MALE)
						new_name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
					else
						new_name = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
			if(new_name)
				if(length(new_name) >= 26)
					new_name = copytext(new_name, 1, 26)
				real_name = new_name

		if (link_tags["age"])
			var/new_age = input(user, "Please select type in age: 20-45", "Character Generation")  as num

			if(new_age)
				age = max(min(round(text2num(new_age)), 45), 20)

		if (link_tags["b_type"])
			var/new_b_type = input(user, "Please select a blood type:", "Character Generation")  as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )

			if (new_b_type)
				b_type = new_b_type

		if (link_tags["hair"])
			var/new_hair = input(user, "Please select hair color.", "Character Generation") as color
			if(new_hair)
				r_hair = hex2num(copytext(new_hair, 2, 4))
				g_hair = hex2num(copytext(new_hair, 4, 6))
				b_hair = hex2num(copytext(new_hair, 6, 8))
/*
		if (link_tags["r_hair"])
			var/new_component = input(user, "Please select red hair component: 1-255", "Character Generation")  as text

			if (new_component)
				r_hair = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["g_hair"])
			var/new_component = input(user, "Please select green hair component: 1-255", "Character Generation")  as text

			if (new_component)
				g_hair = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["b_hair"])
			var/new_component = input(user, "Please select blue hair component: 1-255", "Character Generation")  as text

			if (new_component)
				b_hair = max(min(round(text2num(new_component)), 255), 1)
*/

		if (link_tags["facial"])
			var/new_facial = input(user, "Please select facial hair color.", "Character Generation") as color
			if(new_facial)
				r_facial = hex2num(copytext(new_facial, 2, 4))
				g_facial = hex2num(copytext(new_facial, 4, 6))
				b_facial = hex2num(copytext(new_facial, 6, 8))
/*
		if (link_tags["r_facial"])
			var/new_component = input(user, "Please select red facial component: 1-255", "Character Generation")  as text

			if (new_component)
				r_facial = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["g_facial"])
			var/new_component = input(user, "Please select green facial component: 1-255", "Character Generation")  as text

			if (new_component)
				g_facial = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["b_facial"])
			var/new_component = input(user, "Please select blue facial component: 1-255", "Character Generation")  as text

			if (new_component)
				b_facial = max(min(round(text2num(new_component)), 255), 1)
*/
		if (link_tags["eyes"])
			var/new_eyes = input(user, "Please select eye color.", "Character Generation") as color
			if(new_eyes)
				r_eyes = hex2num(copytext(new_eyes, 2, 4))
				g_eyes = hex2num(copytext(new_eyes, 4, 6))
				b_eyes = hex2num(copytext(new_eyes, 6, 8))
/*
		if (link_tags["r_eyes"])
			var/new_component = input(user, "Please select red eyes component: 1-255", "Character Generation")  as text

			if (new_component)
				r_eyes = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["g_eyes"])
			var/new_component = input(user, "Please select green eyes component: 1-255", "Character Generation")  as text

			if (new_component)
				g_eyes = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["b_eyes"])
			var/new_component = input(user, "Please select blue eyes component: 1-255", "Character Generation")  as text

			if (new_component)
				b_eyes = max(min(round(text2num(new_component)), 255), 1)
*/
		if (link_tags["s_tone"])
			var/new_tone = input(user, "Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation")  as text

			if (new_tone)
				s_tone = max(min(round(text2num(new_tone)), 220), 1)
				s_tone =  -s_tone + 35

		if (link_tags["h_style"])
			var/new_style = input(user, "Please select hair style", "Character Generation")  as null|anything in list( "Cut Hair", "Short Hair", "Long Hair", "Mohawk", "Balding", "Fag", "Bedhead", "Dreadlocks", "Bald" )

			if (new_style)
				h_style = new_style

		if (link_tags["f_style"])
			var/new_style = input(user, "Please select facial style", "Character Generation")  as null|anything in list("Watson", "Chaplin", "Selleck", "Full Beard", "Long Beard", "Neckbeard", "Van Dyke", "Elvis", "Abe", "Chinstrap", "Hipster", "Goatee", "Hogan", "Shaved")

			if (new_style)
				f_style = new_style

		if (link_tags["gender"])
			if (gender == MALE)
				gender = FEMALE
			else
				gender = MALE

		if (link_tags["underwear"])
			if(!IsGuestKey(user.key))
				if (underwear == 1)
					underwear = 0
				else
					underwear = 1

		if (link_tags["b_syndicate"])
			be_syndicate = !( be_syndicate )

		if (link_tags["b_random_name"])
			be_random_name = !be_random_name

		if(!IsGuestKey(user.key))
			if(link_tags["saveslot"])
				var/slot = link_tags["saveslot"]
				var/DBQuery/query = dbcon.NewQuery("REPLACE INTO `players` (`ckey`,`slot`,`real_name`, `gender`, `ages`, `occupation1`, `occupation2`, `occupation3`,`hair_red`, `hair_green`, `hair_blue`, `facial_red`, `facial_green`, `facial_blue`, `skin_tone`, `hair_style_name`, `facial_style_name`, `eyes_red`,`eyes_green`, `eyes_blue`, `blood_type`, `be_syndicate`, `underwear`,`name_is_always_random`) VALUES ('[user.ckey]','[slot]' ,'[real_name]', '[lowertext(gender)]', '[age]', '[occupation1]','[occupation2]', '[occupation3]', '[r_hair]', '[g_hair]', '[b_hair]', '[r_facial]', '[g_facial]', '[b_facial]', '[s_tone]', '[h_style]', '[f_style]', '[r_eyes]', '[g_eyes]', '[b_eyes]', '[b_type]', '[be_syndicate]', '[underwear]','[be_random_name]');")
				if(!query.Execute())
					usr << query.ErrorMsg()
					usr << "Report this."
				else
					usr << "Saved"

			else if(link_tags["loadslot"])
				var/slot = link_tags["loadslot"]
				if(slot == "CLOSE")
					closesave(user)
					return
				if(!savefile_load(user, 0,slot))
					alert(user, "You do not have a savefile.")
				else
					curslot = slot
					loadsave(user)
		if(link_tags["removeslot"])
			var/slot = link_tags["removeslot"]
			if(!slot)
				return
			var/DBQuery/query = dbcon.NewQuery("DELETE FROM `players`WHERE ckey='[usr.ckey]' AND slot='[slot]'")
			if(!query.Execute())
				usr << query.ErrorMsg()
				usr << "Report this."
			else
				usr << "Slot [slot] Deleted."
				loadsave(usr)
		if(link_tags["loadslot2"])
			loadsave(user)
		if(link_tags["createslot"])
			var/list/slot = list()
			var/DBQuery/querys = dbcon.NewQuery("SELECT `slot` FROM `players` WHERE ckey='[usr.ckey]'")
			if(!querys.Execute())
				usr << "ERROR"
			while(querys.NextRow())
				var/list/row = querys.GetRowData()
				slot += row["slot"]
			var/count = slot.len
			count++
			if(count > 10)
				usr << "You have reached the character limit."
				return
			var/slotname = input(usr,"Choose a name for your slot","Name","Default")
			slotname = dbcon.Quote(slotname)
			var/DBQuery/query = dbcon.NewQuery("REPLACE INTO `players` (`ckey`,`slot`,`slotname`,`real_name`, `gender`, `ages`, `occupation1`, `occupation2`, `occupation3`,`hair_red`, `hair_green`, `hair_blue`, `facial_red`, `facial_green`, `facial_blue`, `skin_tone`, `hair_style_name`, `facial_style_name`, `eyes_red`,`eyes_green`, `eyes_blue`, `blood_type`, `be_syndicate`, `underwear`,`name_is_always_random`) VALUES ('[user.ckey]','[count]',[slotname] ,'New Char', 'MALE', '30', 'No Preference','No Preference', 'No Preference', '0', '0', '0', '0', '0', '0', '0', 'Short Hair', 'Shaved', '0', '0', '0', 'A+', '1', '1','0');")
			if(!query.Execute())
				usr << query.ErrorMsg()
				usr << "Report this."
			else
				usr << "Saved"
			if(!savefile_load(user, 0,count))
				alert(user, "You do not have a savefile.")
			else
				curslot = count
				closesave(user)
		if (link_tags["reset_all"])
			gender = MALE
			randomize_name()

			age = 30
			occupation1 = "No Preference"
			occupation2 = "No Preference"
			occupation3 = "No Preference"
			underwear = 1
			be_syndicate = 0
			be_random_name = 0
			r_hair = 0.0
			g_hair = 0.0
			b_hair = 0.0
			r_facial = 0.0
			g_facial = 0.0
			b_facial = 0.0
			h_style = "Short Hair"
			f_style = "Shaved"
			r_eyes = 0.0
			g_eyes = 0.0
			b_eyes = 0.0
			s_tone = 0.0
			b_type = "A+"


		ShowChoices(user)

	proc/copy_to(mob/living/carbon/human/character)
		if(be_random_name)
			randomize_name()
		character.real_name = real_name

		character.gender = gender

		character.age = age
		character.b_type = b_type

		character.r_eyes = r_eyes
		character.g_eyes = g_eyes
		character.b_eyes = b_eyes

		character.r_hair = r_hair
		character.g_hair = g_hair
		character.b_hair = b_hair

		character.r_facial = r_facial
		character.g_facial = g_facial
		character.b_facial = b_facial

		character.s_tone = s_tone

		character.h_style = h_style
		character.f_style = f_style

		switch(h_style)
			if("Short Hair")
				character.hair_icon_state = "hair_a"
			if("Long Hair")
				character.hair_icon_state = "hair_b"
			if("Cut Hair")
				character.hair_icon_state = "hair_c"
			if("Mohawk")
				character.hair_icon_state = "hair_d"
			if("Balding")
				character.hair_icon_state = "hair_e"
			if("Fag")
				character.hair_icon_state = "hair_f"
			if("Bedhead")
				character.hair_icon_state = "hair_bedhead"
			if("Dreadlocks")
				character.hair_icon_state = "hair_dreads"
			else
				character.hair_icon_state = "bald"

		switch(f_style)
			if ("Watson")
				character.face_icon_state = "facial_watson"
			if ("Chaplin")
				character.face_icon_state = "facial_chaplin"
			if ("Selleck")
				character.face_icon_state = "facial_selleck"
			if ("Neckbeard")
				character.face_icon_state = "facial_neckbeard"
			if ("Full Beard")
				character.face_icon_state = "facial_fullbeard"
			if ("Long Beard")
				character.face_icon_state = "facial_longbeard"
			if ("Van Dyke")
				character.face_icon_state = "facial_vandyke"
			if ("Elvis")
				character.face_icon_state = "facial_elvis"
			if ("Abe")
				character.face_icon_state = "facial_abe"
			if ("Chinstrap")
				character.face_icon_state = "facial_chin"
			if ("Hipster")
				character.face_icon_state = "facial_hip"
			if ("Goatee")
				character.face_icon_state = "facial_gt"
			if ("Hogan")
				character.face_icon_state = "facial_hogan"
			else
				character.face_icon_state = "bald"

		if (underwear == 1)
			character.underwear = pick(1,2,3,4,5)
		else
			character.underwear = 0

		character.update_face()
		character.update_body()

/*

	if (!M.real_name || M.be_random_name)
		if (M.gender == "male")
			M.real_name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
		else
			M.real_name = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
	for(var/mob/living/carbon/human/H in world)
		if(cmptext(H.real_name,M.real_name))
			usr << "You are using a name that is very similar to a currently used name, please choose another one using Character Setup."
			return
	if(cmptext("Unknown",M.real_name))
		usr << "This name is reserved for use by the game, please choose another one using Character Setup."
		return

*/