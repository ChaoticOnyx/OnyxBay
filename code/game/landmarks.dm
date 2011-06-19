/obj/landmark/New()

	..()
	src.tag = text("landmark*[]", src.name)
	src.invisibility = 101

	if (name == "shuttle")
		shuttle_z = src.z
		del(src)

	if (name == "airtunnel_stop")
		airtunnel_stop = src.x

	if (name == "airtunnel_start")
		airtunnel_start = src.x

	if (name == "airtunnel_bottom")
		airtunnel_bottom = src.y

	if (name == "monkey")
		monkeystart += src.loc
		del(src)
	if (name == "start")
		newplayer_start += src.loc
		del(src)

	if (name == "wizard")
		wizardstart += src.loc
		del(src)
	if (name == "DerelictStart")
		derelictstart += src.loc
		del(src)

	if (name == "JoinLate")
		latejoin += src.loc
		del(src)

	//prisoners
	if (name == "prisonwarp")
		prisonwarp += src.loc
		del(src)
	if (name == "mazewarp")
		mazewarp += src.loc
	if (name == "tdome1")
		tdome1	+= src.loc
	if (name == "tdome2")
		tdome2 += src.loc
	//not prisoners
	if (name == "prisonsecuritywarp")
		prisonsecuritywarp += src.loc
		del(src)

	if (name == "blobstart")
		blobstart += src.loc
		del(src)

	//Pod Spawn point.
	//Place this 20 or so tiles NORTH of an escape pod dock in centcom or elsewhere.
	if(name == "Pod-Spawn")
		podspawns += src.loc
		del(src)

	//Pod Dock point
	//Place this in the middle of a pod dock in order to have it properly accept escape pods.
	//Have one open pod door to the north and one closed one to the south.  When a pod enters the north door and lands
	//On this tile, it'll stop due to the south door.  The game wil automatically close the north door and open the south one.
	//After air has entered the lock from the south, the player can leave the pod and figure out where they are.
	if(name == "Pod-Dock")
		poddocks += src.loc
		del(src)

	return 1

/obj/landmark/start/New()
	..()
	src.tag = "start*[src.name]"
	src.invisibility = 101

	return 1