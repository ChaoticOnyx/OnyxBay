
turf/Write(savefile/F)
	var/list/newcontents = src.contents.Copy() // REMOVEING THEM FROM THE OBJECTS CAUSES THEM TO GET DELETED. or stashed in null space forgot that part
	for(var/mob/M in newcontents)
		if(M.client)
			newcontents -= M
	F.cd = "[src.x],[src.y],[src.z]"
	..()
	F["contents"] << newcontents
	F.cd = ".."
	return
mob/verb/load()
	world.load()
mob/verb/save()
	world.save()
world/proc/save()
	var/savefile/F = new("world.sav",-1)
	for(var/turf/T in world)
		T.Write(F)
		sleep(1)
	world.log << "Save done!"
world/proc/load()
	var/savefile/F = new("world.sav",-1)
	for(var/area/A in world)
		for(var/turf/T in A.contents)
			T.Read(F)
	world.log << "Load done!"
turf/Write(savefile/F)
	var/list/newcontents = src.contents.Copy() // REMOVEING THEM FROM THE OBJECTS CAUSES THEM TO GET DELETED. or stashed in null space forgot that part
	for(var/mob/M in newcontents)
		if(M.client)
			newcontents -= M
	F.cd = "[src.x],[src.y],[src.z]"
	F["[src.x],[src.y],[src.z]"] << src
	..()
	F["contents"] << newcontents
	F["icon"] << null
	F.cd = ".."
	return
turf/Read(savefile/F)
	F.cd = "[src.x],[src.y],[src.z]"
	..()
	src.icon = initial(src.icon)
	F.cd = ".."
	return