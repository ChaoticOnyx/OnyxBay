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

//setupdooralarms() goes through every door in the world before the game starts, checks all the squares
//adjacent to them, and if the adjacent square does not contain a dense turf and is not in the same
//area as the door, then the door is added to that adjacent area's auxdoor list to be used later on for
//atmos and fire alarms.
proc/setupdooralarms()		//Strumpetplaya added 11/09/10 Automated Secondary Alarms on Doors
	//world << "Setting up doors"
	for(var/obj/machinery/door/D in world)
		var/turf/T = D.loc
		var/area/A = T.loc
		//world << "Door located in [A.name] being setup"
		var/AName = A.name
		var/turf/ANorth = locate(D.x,D.y+1,D.z)
		var/turf/AEast = locate(D.x+1,D.y,D.z)
		var/turf/ASouth = locate(D.x,D.y-1,D.z)
		var/turf/AWest = locate(D.x-1,D.y,D.z)

		if(ANorth.density != 1)
			var/area/ANorthA = ANorth.loc
			if(ANorthA.name != AName)
				ANorthA.auxdoors += D
				//world << "Door located in [A.name] added to auxillary door list for [ANorthA.name]"

		if(AEast.density != 1)
			var/area/AEastA = AEast.loc
			if(AEastA.name != AName)
				AEastA.auxdoors += D
				//world << "Door located in [A.name] added to auxillary door list for [AEastA.name]"

		if(ASouth.density != 1)
			var/area/ASouthA = ASouth.loc
			if(ASouthA.name != AName)
				ASouthA.auxdoors += D
				//world << "Door located in [A.name] added to auxillary door list for [ASouthA.name]"

		if(AWest.density != 1)
			var/area/AWestA = AWest.loc
			if(AWestA.name != AName)
				AWestA.auxdoors += D
				//world << "Door located in [A.name] added to auxillary door list for [AWestA.name]"



