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
	avnums.Add(9)
	avnums.Add(1)
	avnums.Add(3)
	avnums.Add(5)
	avnums.Add(7)
	avnums.Add(14)
	avnums.Add(15)
	avnums.Add(16)
	avnums.Add(17)
	avnums.Add(18)
	avnums.Add(19)
	avnums.Add(20)
	avnums.Add(21)
	avnums.Add(22)
	avnums.Add(23)
	avnums.Add(24)
	avnums.Add(25)

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



	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	HEADACHEBLOCK = tempnum



	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	COUGHBLOCK = tempnum


	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	TWITCHBLOCK = tempnum

	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	NERVOUSBLOCK = tempnum

	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	NOBREATHBLOCK = tempnum

	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	REMOTEVIEWBLOCK = tempnum

	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	REGENERATEBLOCK = tempnum

	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	INCREASERUNBLOCK = tempnum

	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	REMOTETALKBLOCK = tempnum

	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	MORPHBLOCK = tempnum

	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	BLENDBLOCK = tempnum

	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	HALLUCINATIONBLOCK = tempnum

	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	NOPRINTSBLOCK = tempnum

	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	SHOCKIMMUNITYBLOCK = tempnum

	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	SMALLSIZEBLOCK = tempnum



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



proc
	setupmining()
// Mining Setup
		for(var/turf/simulated/wall/asteroid/derp in world)
			derp.update_icon()

		var/turf/simulated/wall/asteroid/T = null
		var/list/T1veins = list()
		var/list/T2veins = list()
		var/list/T3veins = list()
		var/list/T4veins = list()
		var/list/T5veins = list()

		for(var/obj/landmark/mining/S in world)
			if (S.veintype == 1) T1veins.Add(S)
			if (S.veintype == 2) T2veins.Add(S)
			if (S.veintype == 3) T3veins.Add(S)
			if (S.veintype == 4) T4veins.Add(S)
			if (S.veintype == 5) T5veins.Add(S)

		for(var/obj/landmark/mining/O in T1veins)
			T = O.loc
			if (prob(8)) T.ore2 = pick("cytine","uqill")
			if (O.veinsetup) continue
			var/dense = 0
			if (prob(95))
				O.ore1 = pick("mauxite","pharosium","molitz")
				if (O.ore1 == "mauxite" || O.ore1 == "pharosium")
					if (prob(10)) dense = 1
				T.ore1 = O.ore1
				T.icon_state = "[T.ore1][rand(1,3)]"
				T.ore2 = O.ore2
				var/amtlower = 1
				var/amtupper = 3
				switch (O.ore1)
					if ("mauxite")
						if (dense)
							T.icon_state = "mauxdense[rand(1,3)]"
							O.hardness = 3
							amtlower = 5
							amtupper = 7
						else
							O.hardness = 1
							amtlower = 1
							amtupper = 3
					if ("pharosium")
						if (dense)
							T.icon_state = "phardense[rand(1,3)]"
							O.hardness = 3
							amtlower = 6
							amtupper = 7
						else
							O.hardness = 1
							amtlower = 2
							amtupper = 3
					if ("molitz")
						O.hardness = 1
						amtlower = 1
						amtupper = 4
				O.amount = rand(amtlower,amtupper)
				T.amount = O.amount
				T.hardness = O.hardness
				O.veinsetup = 1
				for(var/obj/landmark/mining/X in T1veins)
					if (O.name == X.name)
						T = X.loc
						T.ore1 = O.ore1
						T.hardness = O.hardness
						T.amount = rand(amtlower,amtupper)
						if (T.ore1 == "mauxite" && T.amount > 3) T.icon_state = "mauxdense[rand(1,3)]"
						else if (T.ore1 == "pharosium" && T.amount > 3) T.icon_state = "phardense[rand(1,3)]"
						else T.icon_state = "[T.ore1][rand(1,3)]"
						X.veinsetup = 1

		for(var/obj/landmark/mining/O in T2veins)
			T = O.loc
			if (prob(8)) T.ore2 = pick("cytine")
			if (O.veinsetup) continue
			if (prob(95))
				O.ore1 = pick("char","cobryl")
				T.ore1 = O.ore1
				T.icon_state = "[T.ore1][rand(1,3)]"
				T.ore2 = O.ore2
				var/amtlower = 1
				var/amtupper = 3
				switch (O.ore1)
					if ("char")
						O.hardness = 0
						amtlower = 2
						amtupper = 5
					if ("cobryl")
						O.hardness = 2
						amtlower = 1
						amtupper = 3
				O.amount = rand(amtlower,amtupper)
				T.amount = O.amount
				T.hardness = O.hardness
				O.veinsetup = 1
				for(var/obj/landmark/mining/X in T2veins)
					if (O.name == X.name)
						T = X.loc
						T.ore1 = O.ore1
						T.hardness = O.hardness
						T.amount = rand(amtlower,amtupper)
						T.icon_state = "[T.ore1][rand(1,3)]"
						X.veinsetup = 1

		for(var/obj/landmark/mining/O in T3veins)
			T = O.loc
			if (prob(8)) T.ore2 = pick("cytine", "telecrystal")
			if (O.veinsetup) continue
			if (prob(95))
				O.ore1 = pick("bohrum","claretine","syreline")
				T.ore1 = O.ore1
				T.icon_state = "[T.ore1][rand(1,3)]"
				T.ore2 = O.ore2
				var/amtlower = 1
				var/amtupper = 3
				switch (O.ore1)
					if ("bohrum")
						O.hardness = 3
						amtlower = 1
						amtupper = 2
					if ("claretine")
						O.hardness = 3
						amtlower = 0
						amtupper = 3
					if ("syreline")
						O.hardness = 4
						amtlower = 0
						amtupper = 2
				O.amount = rand(amtlower,amtupper)
				T.amount = O.amount
				T.hardness = O.hardness
				O.veinsetup = 1
				for(var/obj/landmark/mining/X in T3veins)
					if (O.name == X.name)
						T = X.loc
						T.ore1 = O.ore1
						T.hardness = O.hardness
						T.amount = rand(amtlower,amtupper)
						T.icon_state = "[T.ore1][rand(1,3)]"
						X.veinsetup = 1

		for(var/obj/landmark/mining/O in T4veins)
			T = O.loc
			if (prob(8)) T.ore2 = pick("cytine")
			if (O.veinsetup) continue
			if (prob(95))
				O.ore1 = pick("erebite","cerenkite","plasmastone")
				T.ore1 = O.ore1
				if (T.ore1 == "erebite" || T.ore1 == "plasmastone") T.explosive = 1
				T.icon_state = "[T.ore1][rand(1,3)]"
				T.ore2 = O.ore2
				var/amtlower = 1
				var/amtupper = 3
				switch (O.ore1)
					if ("erebite")
						O.hardness = 2
						amtlower = 2
						amtupper = 2
					if ("cerenkite")
						O.hardness = 3
						amtlower = 1
						amtupper = 2
					if ("plasmastone")
						O.hardness = 3
						amtlower = 0
						amtupper = 3
				O.amount = rand(amtlower,amtupper)
				T.amount = O.amount
				T.hardness = O.hardness
				O.veinsetup = 1
				for(var/obj/landmark/mining/X in T4veins)
					if (O.name == X.name)
						T = X.loc
						T.ore1 = O.ore1
						if (T.ore1 == "erebite" || T.ore1 == "plasmastone") T.explosive = 1
						T.hardness = O.hardness
						T.amount = rand(amtlower,amtupper)
						T.icon_state = "[T.ore1][rand(1,3)]"
						X.veinsetup = 1

		for(var/obj/landmark/mining/O in T5veins)
			T = O.loc
			if (prob(12)) T.event = "hard"
			if (prob(12)) T.event = "soft"
			if (prob(10)) T.event = "worm"
			if (prob(9)) T.event = "volatile"
			if (prob(9)) T.event = "radioactive"
			if (prob(5)) T.event = "gem"
			if (prob(1)) T.event = "artifact"

			if (T.event == "gem") T.ore2 = pick("cytine","uqill","telecrystal")
			if (T.event == "hard")
				T.hardness += 1
				for (var/turf/simulated/wall/asteroid/A in range(1,T))
					if (!A.event) A.event = "hardnext"
					A.hardness += 1
			if (T.event == "soft")
				T.hardness -= 1
				for (var/turf/simulated/wall/asteroid/A in range(1,T))
					if (!A.event) A.event = "softnext"
					A.hardness -= 1
			if (T.event == "radioactive")
				T.radioactive = 1
				for (var/turf/simulated/wall/asteroid/A in range(1,T))
					if (prob(66)) A.event = "radioactive"




/* For random mining shit.  Copying and commenting out for now, as I believe it to be too unreliable and unstable.
proc
	setupmining()
// Mining Setup
		var/asteroidcycle = 50
		while(asteroidcycle >= 0)
			for(var/obj/landmark/random_asteroid/herp in world)
				herp.spread()
			asteroidcycle--



		for(var/turf/simulated/wall/asteroid/derp in world)
			derp.update_icon()

		var/turf/simulated/wall/asteroid/T = null
		var/list/T1veins = list()
		var/list/T2veins = list()
		var/list/T3veins = list()
		var/list/T4veins = list()
		var/list/T5veins = list()

		for(var/obj/landmark/mining/S in world)
			var/turf/northborder = get_step(src, NORTH)
			var/turf/eastborder = get_step(src, EAST)
			var/turf/westborder = get_step(src, WEST)
			var/turf/southborder = get_step(src, SOUTH)
			if(!istype(northborder, /turf/space) && !istype(eastborder, /turf/space) && !istype(southborder, /turf/space) && !istype(westborder, /turf/space))
				if (S.veintype == 1) T1veins.Add(S)
				if (S.veintype == 2) T2veins.Add(S)
				if (S.veintype == 3) T3veins.Add(S)
				if (S.veintype == 4) T4veins.Add(S)
				if (S.veintype == 5) T5veins.Add(S)

		for(var/obj/landmark/mining/O in T1veins)
			T = O.loc
			if (prob(8)) T.ore2 = pick("cytine","uqill")
			if (O.veinsetup) continue
			var/dense = 0
			if (prob(95))
				O.ore1 = pick("mauxite","pharosium","molitz")
				if (O.ore1 == "mauxite" || O.ore1 == "pharosium")
					if (prob(10)) dense = 1
				T.ore1 = O.ore1
				T.icon_state = "[T.ore1][rand(1,3)]"
				T.ore2 = O.ore2
				var/amtlower = 1
				var/amtupper = 3
				switch (O.ore1)
					if ("mauxite")
						if (dense)
							T.icon_state = "mauxdense[rand(1,3)]"
							O.hardness = 3
							amtlower = 5
							amtupper = 7
						else
							O.hardness = 1
							amtlower = 1
							amtupper = 3
					if ("pharosium")
						if (dense)
							T.icon_state = "phardense[rand(1,3)]"
							O.hardness = 3
							amtlower = 6
							amtupper = 7
						else
							O.hardness = 1
							amtlower = 2
							amtupper = 3
					if ("molitz")
						O.hardness = 1
						amtlower = 1
						amtupper = 4
				O.amount = rand(amtlower,amtupper)
				T.amount = O.amount
				T.hardness = O.hardness
				O.veinsetup = 1
				for(var/obj/landmark/mining/X in T1veins)
					if (O.name == X.name)
						T = X.loc
						T.ore1 = O.ore1
						T.hardness = O.hardness
						T.amount = rand(amtlower,amtupper)
						if (T.ore1 == "mauxite" && T.amount > 3) T.icon_state = "mauxdense[rand(1,3)]"
						else if (T.ore1 == "pharosium" && T.amount > 3) T.icon_state = "phardense[rand(1,3)]"
						else T.icon_state = "[T.ore1][rand(1,3)]"
						X.veinsetup = 1

		for(var/obj/landmark/mining/O in T2veins)
			T = O.loc
			if (prob(8)) T.ore2 = pick("cytine")
			if (O.veinsetup) continue
			if (prob(95))
				O.ore1 = pick("char","cobryl")
				T.ore1 = O.ore1
				T.icon_state = "[T.ore1][rand(1,3)]"
				T.ore2 = O.ore2
				var/amtlower = 1
				var/amtupper = 3
				switch (O.ore1)
					if ("char")
						O.hardness = 0
						amtlower = 2
						amtupper = 5
					if ("cobryl")
						O.hardness = 2
						amtlower = 1
						amtupper = 3
				O.amount = rand(amtlower,amtupper)
				T.amount = O.amount
				T.hardness = O.hardness
				O.veinsetup = 1
				for(var/obj/landmark/mining/X in T2veins)
					if (O.name == X.name)
						T = X.loc
						T.ore1 = O.ore1
						T.hardness = O.hardness
						T.amount = rand(amtlower,amtupper)
						T.icon_state = "[T.ore1][rand(1,3)]"
						X.veinsetup = 1

		for(var/obj/landmark/mining/O in T3veins)
			T = O.loc
			if (prob(8)) T.ore2 = pick("cytine", "telecrystal")
			if (O.veinsetup) continue
			if (prob(95))
				O.ore1 = pick("bohrum","claretine","syreline")
				T.ore1 = O.ore1
				T.icon_state = "[T.ore1][rand(1,3)]"
				T.ore2 = O.ore2
				var/amtlower = 1
				var/amtupper = 3
				switch (O.ore1)
					if ("bohrum")
						O.hardness = 3
						amtlower = 1
						amtupper = 2
					if ("claretine")
						O.hardness = 3
						amtlower = 0
						amtupper = 3
					if ("syreline")
						O.hardness = 4
						amtlower = 0
						amtupper = 2
				O.amount = rand(amtlower,amtupper)
				T.amount = O.amount
				T.hardness = O.hardness
				O.veinsetup = 1
				for(var/obj/landmark/mining/X in T3veins)
					if (O.name == X.name)
						T = X.loc
						T.ore1 = O.ore1
						T.hardness = O.hardness
						T.amount = rand(amtlower,amtupper)
						T.icon_state = "[T.ore1][rand(1,3)]"
						X.veinsetup = 1

		for(var/obj/landmark/mining/O in T4veins)
			T = O.loc
			if (prob(8)) T.ore2 = pick("cytine")
			if (O.veinsetup) continue
			if (prob(95))
				O.ore1 = pick("erebite","cerenkite","plasmastone")
				T.ore1 = O.ore1
				if (T.ore1 == "erebite" || T.ore1 == "plasmastone") T.explosive = 1
				T.icon_state = "[T.ore1][rand(1,3)]"
				T.ore2 = O.ore2
				var/amtlower = 1
				var/amtupper = 3
				switch (O.ore1)
					if ("erebite")
						O.hardness = 2
						amtlower = 2
						amtupper = 2
					if ("cerenkite")
						O.hardness = 3
						amtlower = 1
						amtupper = 2
					if ("plasmastone")
						O.hardness = 3
						amtlower = 0
						amtupper = 3
				O.amount = rand(amtlower,amtupper)
				T.amount = O.amount
				T.hardness = O.hardness
				O.veinsetup = 1
				for(var/obj/landmark/mining/X in T4veins)
					if (O.name == X.name)
						T = X.loc
						T.ore1 = O.ore1
						if (T.ore1 == "erebite" || T.ore1 == "plasmastone") T.explosive = 1
						T.hardness = O.hardness
						T.amount = rand(amtlower,amtupper)
						T.icon_state = "[T.ore1][rand(1,3)]"
						X.veinsetup = 1

		for(var/obj/landmark/mining/O in T5veins)
			T = O.loc
			if (prob(12)) T.event = "hard"
			if (prob(12)) T.event = "soft"
			if (prob(10)) T.event = "worm"
			if (prob(9)) T.event = "volatile"
			if (prob(9)) T.event = "radioactive"
			if (prob(5)) T.event = "gem"
			if (prob(1)) T.event = "artifact"

			if (T.event == "gem") T.ore2 = pick("cytine","uqill","telecrystal")
			if (T.event == "hard")
				T.hardness += 1
				for (var/turf/simulated/wall/asteroid/A in range(1,T))
					if (!A.event) A.event = "hardnext"
					A.hardness += 1
			if (T.event == "soft")
				T.hardness -= 1
				for (var/turf/simulated/wall/asteroid/A in range(1,T))
					if (!A.event) A.event = "softnext"
					A.hardness -= 1
			if (T.event == "radioactive")
				T.radioactive = 1
				for (var/turf/simulated/wall/asteroid/A in range(1,T))
					if (prob(66)) A.event = "radioactive"
*/