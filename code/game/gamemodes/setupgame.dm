/proc/setupgenetics()

	if (prob(50))
		BLOCKADD = rand(-300,300)
	if (prob(75))
		DIFFMUT = rand(0,20)

	var/list/avnums = new/list()
	var/tempnum

	avnums.Add(2)
	avnums.Add(12)
	avnums.Add(10)
	avnums.Add(8)
	avnums.Add(4)
	avnums.Add(11)
	avnums.Add(13)
	avnums.Add(6)

	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	HULKBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	TELEBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	FIREBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	XRAYBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	CLUMSYBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	FAKEBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	DEAFBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	BLINDBLOCK = tempnum

proc/setupdooralarms()		//LORAK ADD 9/27/10 Automated Secondary Alarms on Fire Doors
	for(var/obj/machinery/door/firedoor/D in world)
		var/turf/T = D.loc
		var/area/A = T.loc
		var/AName = A.name
		var/area/ANorth = locate(D.x,D.y+1,D.z)
		var/area/AEast = locate(D.x+1,D.y,D.z)
		var/area/ASouth = locate(D.x,D.y-1,D.z)
		var/area/AWest = locate(D.x-1,D.y,D.z)
		if(ANorth.density != 1)
			ANorth = ANorth.loc
			if(ANorth.name != AName)
				D.secondary_alarm = ANorth.name
		if(AEast.density != 1)
			AEast = AEast.loc
			if(AEast.name != AName)
				D.secondary_alarm = AEast.name
		if(ASouth.density != 1)
			ASouth = ASouth.loc
			if(ASouth.name != AName)
				D.secondary_alarm = ASouth.name
		if(AWest.density != 1)
			AWest = AWest.loc
			if(AWest.name != AName)
				D.secondary_alarm = AWest.name



