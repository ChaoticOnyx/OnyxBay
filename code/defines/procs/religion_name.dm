// Will finish this at a later date. - Wrongnumber

var/religion_name = null
/proc/religion_name()
	if (religion_name)
		return religion_name

	var/name = ""

	name += pick("bee", "science", "edu", "captain", "assistant", "monkey", "alien", "space", "unit", "sprocket", "gadget", "bomb", "revolution", "beyond", "station", "robot", "ivor", "hobnob")
	name += pick("ism", "ia", "ology", "istism", "ites", "ick", "ian", "ity")

	// Another quick back
	name = "Armokism"

	return capitalize(name)


/obj/item/weapon/paper/Religion
	name = "paper- 'Leter from the Pope'"
	info = "Greetings, and welcome. I am the Space Pope of your ships general religion, of which is [religion_name]. Do not sin, do not smoke, do not kill, you get the point."