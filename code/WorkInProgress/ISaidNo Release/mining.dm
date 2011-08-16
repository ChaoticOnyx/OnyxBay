// this goes in gameticker.dm's setup() proc
/*
		// Mining Setup
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
*/
// this is the entirety of mining.dm

// Turf Defines

/obj/landmark/mining
	name = "miningmarker"
	icon = 'mark.dmi'
	icon_state = "mining1"
	var/veinsetup = 0
	var/veintype = null
	var/ore1 = null
	var/ore2 = null
	var/hardness = 1
	var/amount = null
	var/event = null
	New()
		..()
		name = "miningmarker[rand(1,1000)]"


/*	New()	//Strumpetplaya - added for totally random asteroids
		..()
		name = "miningmarker[rand(1,10)]"
		switch(rand(1,10))
			if(1)
				veintype = 1
			if(2)
				veintype = 2
			if(3)
				veintype = 3
			if(4)
				veintype = 4
			if(5)
				veintype = 5
			if(6 to 10)
				veintype = null
*/
/obj/landmark/random_asteroid		//Strumpetplaya - added for totally random asteroids.  Place this landmark down wherever you want to generate a random asteroid.
	name = "RandomAsteroidMarker"
	icon = 'mark.dmi'
	icon_state = "mining1"
	var/randomness = 75
	var/finished = 0
	New()
		..()
	proc/spread()

		sleep(-1)
		if(src.loc.loc.name == "Space")
			return
		var/turf/simulated/wall/asteroid/newturf = new(src.loc)
		newturf.name = "Asteroid"

		if(randomness < 0)
			randomness = 0

		var/turf/northborder = get_step(src, NORTH)
		var/turf/eastborder = get_step(src, EAST)
		var/turf/westborder = get_step(src, WEST)
		var/turf/southborder = get_step(src, SOUTH)
		if(prob(randomness) && istype(northborder, /turf/space))
			var/obj/landmark/random_asteroid/newrandom = new(northborder)
			newrandom.randomness = src.randomness - 4
			//world << "north at [randomness] randomness"
		if(prob(randomness) && istype(eastborder, /turf/space))
			var/obj/landmark/random_asteroid/newrandom = new(eastborder)
			newrandom.randomness = src.randomness - 4
			//world << "east at [randomness] randomness"
		if(prob(randomness) && istype(southborder, /turf/space))
			var/obj/landmark/random_asteroid/newrandom = new(southborder)
			newrandom.randomness = src.randomness - 4
			//world << "south at [randomness] randomness"
		if(prob(randomness) && istype(westborder, /turf/space))
			var/obj/landmark/random_asteroid/newrandom = new(westborder)
			newrandom.randomness = src.randomness - 4
			//world << "west at [randomness] randomness"
		del(src)

/area/asteroid/randomzone			//Strumpetplaya - added to limit totally random asteroids
	name = "Asteroid Zone"
	icon_state = "random_asteroid"
	requires_power = 0

/turf/simulated/wall/asteroid
	name = "Asteroid"
	icon_state = "m1"
	var/ore1 = null
	var/ore2 = null
	var/event = null
	var/explosive = 0
	var/radioactive = 0
	var/radoverlay = 0
	var/hardness = 1
	var/weakened = 0
	var/amount = 0

	New()
		var/obj/landmark/mining/newlandmark = new(src)
		newlandmark.name = "Thisisdumb"
		update_icon()
		/*var/turf/northborder = get_step(src, NORTH)		//Strumeptplaya - moved all this to a new update_icon() proc
		var/turf/eastborder = get_step(src, EAST)
		var/turf/westborder = get_step(src, WEST)
		var/turf/southborder = get_step(src, SOUTH)
		icon_state = ""
		if(istype(northborder, /turf/space))
			icon_state += "n"
		if(istype(eastborder, /turf/space))
			icon_state += "e"
		if(istype(southborder, /turf/space))
			icon_state += "s"
		if(istype(westborder, /turf/space))
			icon_state += "w"
		switch (src.icon_state)
			if ("n")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "north[rand(1,3)]")
			if ("s")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "south[rand(1,3)]")
			if ("e")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "east[rand(1,3)]")
			if ("w")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "west[rand(1,3)]")
			if ("ne")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "ne[rand(1,3)]")
			if ("nw")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "nw[rand(1,3)]")
			if ("es")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "se[rand(1,3)]")
			if ("sw")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "sw[rand(1,3)]")
			if ("on1")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "on[rand(1,3)]")
			if ("os1")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "os[rand(1,3)]")
			if ("oe1")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "oe[rand(1,3)]")
			if ("ow1")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "ow[rand(1,3)]")
			if ("ine1")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "ine[rand(1,3)]")
			if ("inw1")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "inw[rand(1,3)]")
			if ("ise1")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "ise[rand(1,3)]")
			if ("isw1")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "isw[rand(1,3)]")
			else
				src.icon = 'walls.dmi'
				src.icon_state = "m[rand(1,3)]"*/
		src.amount = rand(1,3)
		..()

	proc/update_icon()
		var/turf/northborder = get_step(src, NORTH)
		var/turf/eastborder = get_step(src, EAST)
		var/turf/westborder = get_step(src, WEST)
		var/turf/southborder = get_step(src, SOUTH)
		icon_state = ""
		if(istype(northborder, /turf/space))
			icon_state += "n"
		if(istype(eastborder, /turf/space))
			icon_state += "e"
		if(istype(southborder, /turf/space))
			icon_state += "s"
		if(istype(westborder, /turf/space))
			icon_state += "w"
		switch (src.icon_state)
			if ("n")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "north[rand(1,3)]")
			if ("s")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "south[rand(1,3)]")
			if ("e")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "east[rand(1,3)]")
			if ("w")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "west[rand(1,3)]")
			if ("ne")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "ne[rand(1,3)]")
			if ("nw")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "nw[rand(1,3)]")
			if ("es")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "se[rand(1,3)]")
			if ("sw")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "sw[rand(1,3)]")
			if ("new")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "on[rand(1,3)]")
			if ("esw")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "os[rand(1,3)]")
			if ("nes")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "oe[rand(1,3)]")
			if ("nsw")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "ow[rand(1,3)]")
			if ("ine1")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "ine[rand(1,3)]")
			if ("inw1")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "inw[rand(1,3)]")
			if ("ise1")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "ise[rand(1,3)]")
			if ("isw1")
				src.icon = 'space.dmi'
				src.icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"
				src.overlays += image('walls.dmi', "isw[rand(1,3)]")
			else
				src.icon = 'walls.dmi'
				src.icon_state = "m[rand(1,3)]"




	ex_act(severity)
		switch(severity)
			if(1.0)
				//SN src = null
				src.ReplaceWithSpace()
				del(src)
				return
			if(2.0)
				src.destroy_asteroid()
			if(3.0)
				if (prob(50)) src.destroy_asteroid()
			else
		return

	examine()
		set src in oview(1)

		..()
		if (istype(usr, /mob/living/carbon/human/))
			if (usr.job == "Miner")
				if (src.ore1) usr << "It looks like it contains [src.ore1]."
				else usr << "Doesn't look like there's any valuable ore here."
				if (src.ore2 || src.event) usr << "\red There's something not quite right here..."
		return

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		var/turf/T = user.loc
		if(istype(W,/obj/item/weapon/cutter))
			if(!W:active)
				user << "\red You won't get very far without igniting it..."
				return

			playsound(user.loc, 'welder.ogg', 100, 1)
			user << "\blue You slash right through the rock!"
			for(var/mob/M in viewers(src))
				if(M == user)	continue
				M.show_message("\red [user.name] slices through the rock!")

			for(var/turf/simulated/wall/asteroid/A in view(1,user))
				if(A.radioactive)
					if (user.mining_radcheck(user) == 0)
						if (user.job == "Miner") user << "\red It's a bad idea to dig here without a full RIG Suit!"
						user.radiation += 15
				A.destroy_asteroid(1)
			return
		if(istype(W,/obj/item/weapon/drill) || istype(W,/obj/item/weapon/pickaxe/))
			if (istype(W,/obj/item/weapon/pickaxe/powered))
				if (W:status) playsound(user.loc, 'welder.ogg', 100, 1)
				//else playsound(user.loc, 'pickaxe.ogg', 100, 1)	Strumpetplaya - Commented out as it is currently unsupported
			//else if (istype(W,/obj/item/weapon/pickaxe)) playsound(user.loc, 'pickaxe.ogg', 100, 1)	Strumpetplaya - Commented out as it is currently unsupported
			else playsound(user.loc, 'welder.ogg', 100, 1)
			user << "You start cutting into the asteroid!"

			for(var/mob/M in viewers(src))
				if(M == user)	continue
				M.show_message("\red [user.name] starts to cut into the [src.name]!")

			var/cuttime = 5
			var/chance = 100
			var/spark = 0

			if(istype(W,/obj/item/weapon/cutter)) spark = 1
			if(istype(W,/obj/item/weapon/drill)) chance = 95
			if(istype(W,/obj/item/weapon/pickaxe/powered))
				if (W:status)
					spark = 1
					chance = 90
				else chance = 80
			if(istype(W,/obj/item/weapon/pickaxe)) chance = 80

			if (spark)
				if (istype(user, /mob/living/carbon/human/))
					if (user.job == "Miner" && src.explosive)
						user << "\red Your intuition as a Miner tells you this is an extremely bad idea!"
						cuttime += 2

			if (istype(user, /mob/living/carbon/human/))
				if (user.job == "Miner")
					if (src.event == "worm" || src.event == "volatile" || src.event == "artifact" || src.event == "radioactive")
						user << "\red There is something unusual here..."

			if(src.radioactive)
				if (user.mining_radcheck(user) == 0)
					if (user.job == "Miner") user << "\red It's a bad idea to dig here without a full RIG Suit!"
					user.radiation += 15

			var/minedifference = src.hardness - W:minelevel
			if (minedifference == -1)
				cuttime -= 2
				chance += 5
			else if (minedifference <= -2)
				cuttime -= 5
				chance = 100

			if (chance > 100) chance = 100
			cuttime *= 10
			if (cuttime < 10)
				cuttime = 1
				user << "\blue You effortlessly slice through [src.name]!"
			sleep(cuttime)
			if (minedifference > 0) user << "\red Your current tool is unable to penetrate this rock."
			else
				if(prob(chance))
					if ((user.loc == T && user.equipped() == W))
						if (cuttime >= 10) user << "You cut into the [src.name]."
						destroy_asteroid(spark)
				else user << "\red You fail to completely demolish the rock."

			if (istype(W,/obj/item/weapon/pickaxe/powered))
				if (W:status)
					W:charges--
					W:desc = "An energised mining tool. It has [W:charges] charges left."
					if (W:charges <= 0)
						user << "\red <b>[W] runs out of charge and powers down!</b>"
						W.overlays = null
						W:status = 0
						W:minelevel = 1

			for (var/turf/simulated/wall/asteroid/A in range(1,src))
				if (A.event == "radioactive"&& !A.radoverlay && prob(50))
					A.overlays += image('walls.dmi', "radiation")
					A.radoverlay = 1
			return

		else if(istype(W,/obj/item/weapon/powerhammer))
			if (!W:status)
				user << "\red [W] won't do anything to the rock if it isn't active!"
				return

			var/collapse = 0
			if (src.weakened && prob(90)) collapse = 1
			playsound(user.loc, 'welder.ogg', 100, 1)
			user << "You start hammering at the asteroid!"
			for(var/mob/M in viewers(src))
				if(M == user)	continue
				M.show_message("\red [user.name] starts bashing at the [src.name]!")
			if (src.explosive || src.event == "volatile")
				destroy_asteroid(1)
				return
			sleep(20)
			if ((user.loc == T && user.equipped() == W))
				if (collapse)
					if (src.event == "hard" || src.event == "hardnext" || src.hardness >= 3) user << "\red Nothing happens!"
					else
						src.hardness = 1
						src.ore1 = null
						src.ore2 = null
						src.amount = 5
						if (src.event == "worm") src.event = null
						user << "\red The rock collapses uselessly!"
						destroy_asteroid(0)
				else
					src.weakened = 1
					src.hardness -= 1
					src.overlays += image('walls.dmi', "weakened")
					user << "\blue You weakened the rock!"

			if (W:status)
				W:charges--
				W:desc = "An energised mining tool. It has [W:charges] charges left."
				if (W:charges <= 0)
					user << "\red <b>[W] runs out of charge and powers down!</b>"
					W.overlays = null
					W:status = 0

		else if (istype(W, /obj/item/weapon/oreprospector))
			user << "----------------------------------"
			user << "<B>Geological Report:</B>"
			user << ""
			if (src.ore1) user << "This stone contains [src.ore1]."
			else user << "This rock contains no known ores."
			user << "The rock here has a hardness rating of [src.hardness]."
			if (src.weakened) user << "The rock here has been weakened."
			if (src.ore1) user << "Analysis suggests [src.amount] units of viable ore are present."
			if (src.ore2) user << "Small extraneous mineral deposit detected."
			switch (src.event)
				if ("hard") user << "\red Caution! Epicenter of dense rock formation detected!"
				if ("hardnext") user << "\red Caution! Dense rock formation detected!"
				if ("soft") user << "\red Caution! Epicenter of weak rock formation detected!"
				if ("softnext") user << "\red Caution! Weak rock formation detected!"
				if ("volatile") user << "\red Caution! Volatile compounds detected!"
				if ("worm") user << "\red Caution! Life signs detected!"
				if ("artifact") user << "\red Caution! Large object embedded in rock!"
				if ("radioactive") user << "\red Caution! Radioactive mineral deposits detected!"
			user << "----------------------------------"

		else
			user << "\blue You hit the [src.name] with [W], but nothing happens!"
		return

	proc/destroy_asteroid(var/plasmacutter = 1)
		//if (src.event == "volatile")
		//	for(var/mob/M in viewers(src)) M.show_message("\red <b>The rock begins shaking violently and heating up!</b>")
		//	src.overlays += image('walls.dmi', "unstable")
		//	src.event = null
		//	var/boomtime = rand(3,6)
		//	boomtime *= 10
		//	sleep(boomtime)
		//	explosion(src, 1, 2, 4, 8)
		//	return
		var/makeores
		for(makeores = src.amount, makeores > 0, makeores--)
			//if (src.explosive && plasmacutter)
			//	for(var/mob/M in viewers(src)) M.show_message("\red <b>The rock violently explodes!</b>")
			//	explosion(src, 2, 4, 6, 12, 1)
			//	return
			switch(src.ore1)
				if("mauxite") new/obj/item/weapon/ore/mauxite(src)
				if("pharosium") new/obj/item/weapon/ore/pharosium(src)
				if("char") new/obj/item/weapon/ore/char(src)
				if("molitz") new/obj/item/weapon/ore/molitz(src)
				if("cobryl") new/obj/item/weapon/ore/cobryl(src)
				if("claretine") new/obj/item/weapon/ore/claretine(src)
				if("syreline") new/obj/item/weapon/ore/syreline(src)
				if("bohrum") new/obj/item/weapon/ore/bohrum(src)
				if("erebite") new/obj/item/weapon/ore/erebite(src)
				if("cerenkite") new/obj/item/weapon/ore/cerenkite(src)
				if("plasmastone") new/obj/item/weapon/ore/plasmastone(src)
				else new/obj/item/weapon/ore/rock(src)
			//if (src.ore1) score_oremined += 1		Strumpetplaya - Commented out as it is currently unsupported
		switch(src.ore2)
			if("cytine")
				new/obj/item/weapon/ore/cytine(src)
				for(var/mob/O in viewers(src, null)) O.show_message(text("\blue A cytine falls out of the rubble!"), 1)
			if("uqill")
				new/obj/item/weapon/ore/uqill(src)
				for(var/mob/O in viewers(src, null)) O.show_message(text("\blue An uqill nugget falls out of the rubble!"), 1)
			if("telecrystal")
				new/obj/item/weapon/ore/telecrystal(src)
				for(var/mob/O in viewers(src, null)) O.show_message(text("\blue A telecrystal falls out of the rubble!"), 1)
		//if (src.ore2) score_oremined += 1		Strumpetplaya - Commented out as it is currently unsupported
		switch(src.event)
			if("artifact")
				new/obj/item/weapon/artifact(src)
				for(var/mob/O in viewers(src, null)) O.show_message(text("\blue An artifact was unearthed!"), 1)
			if("worm")
				new/obj/critter/rockworm(src)
				for(var/mob/O in viewers(src, null)) O.show_message(text("\red A rock worm emerges from the rubble!"), 1)
		if(!icon_old) icon_old = icon_state
		var/turf/simulated/floor/plating/airless/asteroid/W
		var/old_dir = dir
		W = new /turf/simulated/floor/plating/airless/asteroid( locate(src.x, src.y, src.z) )
		W.dir = old_dir
		W.opacity = 1
		//W.sd_SetOpacity(0)	Strumpetplaya - Commented out as it is currently unsupported
		W.levelupdate()
		return W

/turf/simulated/floor/plating/airless/asteroid
	name = "asteroid"
	icon_state = "mf1"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

	New()
		icon_state = "[pick("mf1","mf2","mf3")]"
		..()
		name = "asteroid"

	ex_act(severity)
		switch(severity)
			if(1.0)
				src.ReplaceWithSpace()
			if(2.0)
				if (prob(30))src.ReplaceWithSpace()
		return

	proc/destroy_asteroid()
		return

// Tool Defines

/obj/item/weapon/cutter
	name = "Plasma Cutter"
	icon = 'mining.dmi'
	icon_state = "cutter"
	var/active = 0
	var/obj/item/weapon/tank/plasma/P = null
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 5.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 2
	w_class = 4.0
	m_amt = 30000
	g_amt = 50000
	//mats = 8	Strumpetplaya - Commented out as it is currently unsupported
	var/minelevel = 4

	process()
		if(!active)
			processing_items.Remove(src)
			return
		if(P)
			if(P.air_contents.toxins <= 0.0)
				src.active = 0
				src.force = 5.0
				src.damtype = "brute"
				icon_state = "cutter"
		var/turf/location = src.loc
		if(istype(location, /mob/))
			var/mob/M = location
			if(M.l_hand == src || M.r_hand == src) location = M.loc
		if (istype(location, /turf)) location.hotspot_expose(700, 5)

	attack_self(mob/user as mob)
		src.active = !( src.active )
		if (src.active)
			if(P)
				if (P.air_contents.toxins <= 0.00)
					user << "\blue Need more fuel!"
					src.active = 0
					return 0
				user << "\blue You turn the [src.name] on."
				src.force = 15.0
				src.damtype = "fire"
				//src.icon_state = "cutter +a+p"
				processing_items.Add(src)
			else
				user << "\red No plasma tank loaded!"
				src.active = 0
		else
			user << "\blue You turn the [src.name] off."
			src.active = 0
			src.force = 5.0
			src.damtype = "brute"
			//src.icon_state = "cutter -a+p"
		return

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/weapon/tank/plasma))
			if(src.P)
				user << "\red There appears to already be a plasma tank loaded!"
				return
			user << "\blue You attach the plasma tank, crowbar to remove."
			src.P = W
			W.loc = src
			if (user.client)
				user.client.screen -= W
			user.u_equip(W)
			//icon_state = "cutter -a+p"
			processing_items.Add(src)
			return

		if(istype(W, /obj/item/weapon/crowbar))
			if(!P)
				return
			var/obj/item/weapon/tank/plasma/Z = src.P
			Z.loc = get_turf(src)
			Z.layer = initial(Z.layer)
			src.P = null
			active = 0
			//icon_state = "cutter -a-p"
			return

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
		if(active)
			if(P)
				P.air_contents.toxins -= 0.01

		if (!ismob(target) && target.reagents)
			usr << "\blue You heat \the [target.name]"
			//target.reagents.temperature_reagents(1500,10)		Strumpetplaya - Commented out as it is currently unsupported

		if(ishuman(user)) eyecheck(user)
		return

	examine()
		set src in usr
		var/words = "lacks"
		if(P)
			words = "contains"
		usr << text("\icon[src] [src.name] [words] a plasma tank!")
		return

	proc/eyecheck(mob/user as mob)
		if(issilicon(user)) return
		//check eye protection
		var/safety = null
		if (istype(user:head, /obj/item/clothing/head/helmet/welding) || istype(user:head, /obj/item/clothing/head/helmet/space)) safety = 2
		else if (istype(user:glasses, /obj/item/clothing/glasses/sunglasses)) safety = 1
		else if (istype(user:glasses, /obj/item/clothing/glasses/thermal)) safety = -1
		else safety = 0
		switch(safety)
			if(1)
				usr << "\red Your eyes sting a little."
				user.eye_stat += rand(1, 2)
				if(user.eye_stat > 12) user.eye_blurry += rand(3,6)
			if(0)
				usr << "\red Your eyes burn."
				user.eye_stat += rand(2, 4)
				if(user.eye_stat > 10) user.eye_blurry += rand(4,10)
			if(-1)
				usr << "\red Your thermals intensify the [src.name]'s glow. Your eyes itch and burn severely."
				user.eye_blurry += rand(12,20)
				user.eye_stat += rand(12, 16)
		if(user.eye_stat > 10 && safety < 2)
			user << "\red Your eyes are really starting to hurt. This can't be good for you!"
		if (prob(user.eye_stat - 25 + 1))
			user << "\red You go blind!"
			user.sdisabilities |= 1
		else if (prob(user.eye_stat - 15 + 1))
			user << "\red You go blind!"
			user.eye_blind = 5
			user.eye_blurry = 5
			user.disabilities |= 1
			spawn(100)
				user.disabilities &= ~1

/obj/item/weapon/drill
	name = "laser drill"
	desc = "Less efficient than a plasma cutter, but safer and doesn't need fuel."
	icon = 'mining.dmi'
	icon_state = "lasdrill"
	w_class = 2
	flags = ONBELT
	force = 7
	//mats = 4	Strumpetplaya - Commented out as it is currently unsupported
	var/minelevel = 3

/obj/item/weapon/pickaxe
	name = "pickaxe"
	desc = "A thing to bash rocks with until they become smaller rocks."
	icon = 'mining.dmi'
	icon_state = "pickaxe"
	w_class = 2
	flags = ONBELT
	force = 4
	var/minelevel = 1

/obj/item/weapon/pickaxe/powered
	name = "power pick"
	desc = "An energised mining tool. It has 30 charges left."
	icon = 'weapons.dmi'
	icon_state = "pickaxe0"
	flags = ONBELT
	w_class = 2
	var/charges = 30
	var/maximum_charges = 30
	var/status = 1
	minelevel = 1

	New()
		..()
		src.overlays += image('weapons.dmi', "pickaxe1")
		src.status = 1
		src.minelevel = 2

	attack_self(var/mob/user as mob)
		if (src.charges)
			if (!src.status)
				user << "You power up [src]."
				src.overlays += image('weapons.dmi', "pickaxe1")
				src.status = 1
				src.minelevel = 2
			else
				user << "You power down [src]."
				src.overlays = null
				src.status = 0
				src.minelevel = 1
		else user << "No charge left in [src]."

/obj/item/weapon/powerhammer
	name = "power hammer"
	desc = "An energised mining tool. It has 15 charges left."
	icon = 'mining.dmi'
	icon_state = "powerhammer"
	w_class = 2
	var/charges = 15
	var/maximum_charges = 15
	var/status = 1

	New()
		..()
		src.overlays += image('mining.dmi', "ph-glow")
		src.status = 1

	attack_self(var/mob/user as mob)
		if (src.charges)
			if (!src.status)
				user << "You power up [src]."
				src.overlays += image('mining.dmi', "ph-glow")
				src.status = 1
			else
				user << "You power down [src]."
				src.overlays = null
				src.status = 0
		else user << "No charge left in [src]."

/obj/item/weapon/breaching_charge/mining
	name = "Mining Explosive"
	desc = "It is set to detonate in 5 seconds."
	flags = ONBELT
	w_class = 1
	var/emagged = 0
	/*expl_heavy = 1	Strumpetplaya - Commented out as it is currently unsupported
	expl_light = 6
	expl_flash = 10*/

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (user.equipped() == src)
			/*if (!src.state)		Strumpetplaya - Commented out as it is currently unsupported
				if (user.mutations & 16)
					user << "\red Huh? How does this thing work?!"
					spawn( 5 )
						//boom()	Strumpetplaya - Commented out as it is currently unsupported
						del src
						return
				else
					if (istype(target, /turf/simulated/wall/asteroid/) && !src.emagged)
						//user << "\red You slap the charge on [target], [det_time/10] seconds!"	Strumpetplaya - Commented out as it is currently unsupported
						user.visible_message("\red [user] has attached [src] to [target].")
						src.icon_state = "bcharge2"
						user.drop_item()

						user.dir = get_dir(user, target)
						user.drop_item()
						var/t = (isturf(target) ? target : target.loc)
						step_towards(src, t)


						spawn( src.det_time )
							//boom()	Strumpetplaya - Commented out as it is currently unsupported
							if(target)
								if(istype(target,/obj/machinery))
									del(target)
							del(src)
							return
					else if (src.emagged) ..()
					else user << "\red These will only work on asteroids."*/
			return

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/card/emag))
			user << "\blue You short out the restrictor circuit!"
			src.emagged = 1
		else ..()

/obj/item/weapon/breaching_charge/mining/light
	name = "Low-Yield Mining Explosive"
	desc = "It is set to detonate in 5 seconds."
	flags = ONBELT
	w_class = 1
	/*expl_heavy = 0	Strumpetplaya - Commented out as it is currently unsupported
	expl_light = 2
	expl_flash = 4*/

/obj/item/weapon/cargotele
	name = "Cargo Transporter"
	desc = "A device for teleporting crated goods. 10 charges remain."
	icon = 'MTransporter.dmi'
	icon_state = "Norm"
	var/charges = 10
	var/maximum_charges = 10.0
	var/robocharge = 250
	var/target = null
	w_class = 2
	flags = ONBELT
	//mats = 4		Strumpetplaya - Commented out as it is currently unsupported

	proc/cargoteleport(var/obj/A, var/mob/user)
		var/list/padsloc = list()
		var/list/L = list()
		var/list/areaindex = list()

		//Make sure that the sendee is on an active pad.
		var/obj/submachine/cargopad/D = locate() in A.loc
		if(D != null)
			if(D.active != 1)
				usr << "\red Please place the [A] on an active pad."
				src.icon_state = "Bad"
				spawn(25)
				src.icon_state = "Norm"
				return
		else
			usr << "\red Please place the [A] on an active pad."
			src.icon_state = "Bad"
			spawn(25)
			src.icon_state = "Norm"
			return

		//List all active pads in the worl, putting their area in L and the turf in padsloc
		for(var/obj/submachine/cargopad/B in world)
			if(B.active == 1)
				var/turf/C = find_loc(B)
				if (!C)	continue
				var/tmpname = C.loc.name
				if(areaindex[tmpname])
					tmpname = "[tmpname] ([++areaindex[tmpname]])"
				else
					areaindex[tmpname] = 1
				L[tmpname] = B
				padsloc[tmpname] = get_turf(B)
		if (!L.len)
			usr << "\red No recievers available."
			src.icon_state = "Bad"
			spawn(25)
			src.icon_state = "Norm"
		else
			//Let the player shoose which location to send to. (Don't ask about the syntax. Goons did it and it works somehow)
			var/selection = input("Select Cargo Pad Location:", "Cargo Pads", null, null) as null|anything in L
			if(!selection)
				return
			var/turf/T = padsloc[selection]
			if (!T)
				usr << "\red Target not set!"
				return
			usr << "Target set to [T.loc]."
			src.target = T
		//Check to make sure a target is set (This should honestly never come up)
		if (!src.target)
			user << "\red You need to set a target first!"
			return
		//Check for charge
		if (src.charges < 1)
			user << "\red The transporter is out of charge."
			src.icon_state = "Bad"
			spawn(25)
			src.icon_state = "Norm"
			return

		//Commented out because this has to do with a goon robot teleporter module
		//if (istype(user,/mob/living/silicon/robot))
		//	var/mob/living/silicon/robot/R = user
		//	if (R.cell.charge < src.robocharge)
		//		user << "\red There is not enough charge left in your cell to use this."
		//		return
		user << "Teleporting [A]..."
		playsound(user.loc, 'click.ogg', 50, 1)
		src.icon_state = "Working"
		for(var/obj/submachine/cargopad in src.target)
			var/obj/submachine/cargopad/H = locate() in src.target
			H.icon_state = "PadIn"
		D.icon_state = "PadIn"
		if(do_after(user, 25)) //Wait a few while the item does it's magic
			var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
			s.set_up(5, 1, A)
			s.start()

			//Make a crate, bodybag, or mob on the receiver land on the receiver.
			for(var/obj/crate in src.target)
				var/obj/crate/E = locate() in src.target
				if(E != null)
					E.loc = A.loc
			for(var/obj/bodybag in src.target)
				var/obj/bodybag/F = locate() in src.target
				if(F != null)
					F.loc = A.loc
			for(var/mob/living/carbon in src.target)
				var/mob/living/carbon/G = locate() in src.target
				if(G != null)
					G.oxyloss = 110
					G.loc = A.loc

			A.loc = src.target //Actually change position

			var/datum/effects/system/spark_spread/s2 = new /datum/effects/system/spark_spread
			s2.set_up(5, 1, A)
			s2.start()

			//if (istype(user,/mob/living/silicon/robot))
			//	var/mob/living/silicon/robot/R = user
			//	R.cell.charge -= src.robocharge
			//else
			src.charges -= 1
			src.target = null
			src.desc = "A device for teleporting crated goods. [src.charges] charges remain."
			user << "[src.charges] charges remain."
			src.icon_state = "Good"
			spawn(25)
			src.icon_state = "Norm"
			for(var/obj/submachine/cargopad in src.target)
				var/obj/submachine/cargopad/H = locate() in src.target
				H.icon_state = "PadOn"
			D.icon_state = "PadOn"
		return

/obj/item/weapon/oreprospector
	name = "geological scanner"
	desc = "A device capable of detecting nearby mineral deposits."
	icon = 'mining.dmi'
	icon_state = "minanal"
	flags = ONBELT
	w_class = 1.0
	var/working = 0

	attack_self(var/mob/user as mob)
		if (src.working == 1)
			user << "\red Please wait! The scanner is working!"
			return
		user << "\blue Taking geological reading, please do not move..."
		var/staystill = user.loc
		src.working = 1
		var/stone = 0
		var/metalH = 0
		var/metalL = 0
		var/sediment = 0
		var/crystal = 0
		var/unusual = 0
		for (var/turf/simulated/wall/asteroid/T in range(user,6))
			stone++
			if (T.ore1 == "mauxite" || T.ore1 == "bohrum" || T.ore2 == "uqill") metalH++
			if (T.ore1 == "pharosium" || T.ore1 == "cobryl" || T.ore1 == "syreline") metalL++
			if (T.ore1 == "molitz" || T.ore2 == "cytine" || T.ore2 == "telecrystal") crystal++
			if (T.ore1 == "char" || T.ore2 == "claretine") sediment++
			if (T.ore1 == "erebite" || T.ore1 == "cerenkite" || T.ore1 == "plasmastone" || T.event) unusual++
			switch (T.event)
				if("worm") unusual++
				if("volatile") unusual++
				if("radioactive") unusual++
				if("artifact") unusual++
		sleep(30)
		src.working = 0
		if (user.loc != staystill) user << "\red Scan error. Try again."
		else
			user << "----------------------------------"
			user << "<B>Geological Report:</B>"
			user << ""
			user << "Units of stone scanned: [stone]"
			user << "Dense Metals: [metalH]"
			user << "Light Metals: [metalL]"
			user << "Crystallines: [crystal]"
			user << "Sedimentaries: [sediment]"
			user << "Anomalous Readings: [unusual]"
			user << "----------------------------------"
			for (var/turf/simulated/wall/asteroid/T in range(user,6))
				if (T.event)
					var/image/O = image('mining.dmi',T,"scan-anom",AREA_LAYER+1)
					user << O
					spawn(1200)
						del O
				if (T.ore2)
					var/image/G = image('mining.dmi',T,"scan-gem",AREA_LAYER+1)
					user << G
					spawn(1200)
						del G

/obj/submachine/cargopad
	name = "Cargo Pad"
	desc = "Used to recieve objects transported by a Cargo Transporter."
	icon = 'MTransporter.dmi'
	icon_state = "PadOff"
	anchored = 0
	var/active = 0

	New()
		src.overlays += image('objects.dmi', "cpad-rec")

	attack_hand(var/mob/user as mob)
		if (src.anchored == 0)
			user << "\red You must first wrench the pad to the ground!"
		else
			if (src.active == 1)
				user << "\blue You switch the reciever off."
				src.icon_state = "PadOff"
				src.active = 0
			else
				user << "\blue You switch the reciever on."
				src.icon_state = "PadOn"
				src.active = 1

/obj/submachine/cargopad/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/wrench))
		if(src.active == 1)
			user << "\red You must first deactivate the pad!"
		else
			if(src.anchored == 0)
				user << "\blue You wrench the pad to the ground."
				src.anchored = 1
			else
				user << "\blue You detach the pad from the ground."
				src.anchored = 0

/obj/item/weapon/storage/miningbelt
	name = "miner's belt"
	desc = "Can hold various mining tools."
	icon = 'mining.dmi'
	icon_state = "minerbelt"
	item_state = "utility"
	can_hold = list("/obj/item/weapon/pickaxe","/obj/item/weapon/pickaxe/powered","/obj/item/weapon/drill","/obj/item/weapon/oreprospector","/obj/item/weapon/satchel/mining","/obj/item/weapon/cargotele","/obj/item/weapon/breaching_charge/mining","/obj/item/weapon/breaching_charge/mining/light","/obj/item/weapon/powerhammer","/obj/item/device/gps")
	flags = FPRINT | TABLEPASS | ONBELT

// Ore Defines

/obj/item/weapon/ore/
	name = "ore"
	desc = "placeholder item!"
	icon = 'mining.dmi'
	force = 4
	throwforce = 6
	var/manuaccept = 1 // can it be loaded into a manufacturing unit?

	New()
		..()
		src.pixel_x = rand(-8, 8)
		src.pixel_y = rand(-8, 8)

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		/*if (istype(W, /obj/item/weapon/satchel/mining))	Strumpetplaya - Commented out as it is currently unsupported
			if (W:contents.len < W:maxitems)
				src.loc = W
				var/oreamt = W:contents.len
				//if ((user.client && user.s_active != src))
				//	user.client.screen -= W
				user << "\blue You put [src] in [W]."
				src.desc = "A leather bag. It holds [oreamt]/[W:maxitems] [W:itemstring]."
				if (oreamt == W:maxitems) user << "\blue [src] is now full!"
			else user << "\red [W] is full!"
		else*/ ..()

/obj/item/weapon/ore/rock
	name = "rock"
	desc = "It's plain old space rock. Pretty worthless!"
	icon_state = "rock1"
	force = 8
	throwforce = 10
	manuaccept = 0

	New()
		..()
		src.icon_state = pick("rock1","rock2","rock3")

// Common Vein Ores

/obj/item/weapon/ore/mauxite
	name = "mauxite ore"
	desc = "A chunk of Mauxite, a sturdy common metal."
	icon_state = "mauxite"

/obj/item/weapon/ore/molitz
	name = "molitz crystal"
	desc = "A crystal of Molitz, a common crystalline substance."
	icon_state = "molitz"

/obj/item/weapon/ore/pharosium
	name = "pharosium ore"
	desc = "A chunk of Pharosium, a conductive metal."
	icon_state = "pharosium"

// Common Cluster Ores

/obj/item/weapon/ore/cobryl
	name = "cobryl ore"
	desc = "A chunk of Cobryl, a somewhat valuable metal."
	icon_state = "cobryl"
	manuaccept = 0

/obj/item/weapon/ore/char
	name = "char ore"
	desc = "A heap of Char, a fossil energy source similar to coal."
	icon_state = "char"
	manuaccept = 0

// Rare Vein Ores

/obj/item/weapon/ore/claretine
	name = "claretine ore"
	desc = "A heap of Claretine, a highly conductive salt."
	icon_state = "claretine"

/obj/item/weapon/ore/bohrum
	name = "bohrum ore"
	desc = "A chunk of Bohrum, a heavy and highly durable metal."
	icon_state = "bohrum"

/obj/item/weapon/ore/syreline
	name = "syreline ore"
	desc = "A chunk of Syreline, an extremely valuable and coveted metal."
	icon_state = "syreline"
	manuaccept = 0

// Rare Cluster Ores

/obj/item/weapon/ore/erebite
	name = "erebite ore"
	desc = "A chunk of Erebite, an extremely volatile high-energy mineral."
	icon_state = "erebite"

	attack_hand(var/mob/user as mob)
		if (istype(user, /mob/living/carbon/human/))
			if (user:job == "Miner") user << "\red This stuff is really volatile! Better be careful..."
			..()
		else ..()

	ex_act(severity)
		//Honestly, what idiot thought this was a good idea? - Aryn
		//switch(severity)
		//	if(1)
		//		explosion(src.loc, 2, 4, 6, 8, 1)
		//		del src
		//	if(2)
		//		explosion(src.loc, 1, 2, 4, 6, 1)
		//		del src
		//	if(3)
		//		explosion(src.loc, 0, 1, 2, 4, 1)
		//		del src
		del src
		return

	temperature_expose(null, temp, volume)
		explosion(src.loc, 1, 2, 4, 6, 1)
		del src

/obj/item/weapon/ore/cerenkite
	name = "cerenkite ore"
	desc = "A chunk of Cerenkite, a highly radioactive mineral."
	icon_state = "cerenkite"

	attack_hand(var/mob/user as mob)
		if (user.mining_radcheck(user)) ..()
		else
			if (user:job == "Miner") user << "\red It really isn't a good idea to handle this stuff without a full RIG suit!"
			user:radiation += 10
			..()

/mob/proc/mining_radcheck(var/mob/user as mob)
	/*if (istype(user, /mob/living/carbon/human/))	Strumpetplaya - Commented out as it is currently unsupported
		if (istype(user:wear_suit, /obj/item/clothing/suit/armor/mining_rig)||istype(user:wear_suit, /obj/item/clothing/suit/space/engineering_rig)) return 1
		else return 0
	else return 1*/

/obj/item/weapon/ore/plasmastone
	name = "plasmastone"
	desc = "A piece of plasma in its solid state."
	icon_state = "plasmastone"

// Gems

/obj/item/weapon/ore/cytine
	name = "cytine"
	desc = "A Cytine gemstone, somewhat valuable but not paticularly useful."
	icon_state = "cytine"
	force = 1
	throwforce = 3
	manuaccept = 0
	var/icon/gemovl = null

	New()
		..()
		var/gemR = rand(50,255)
		var/gemG = rand(50,255)
		var/gemB = rand(50,255)
		gemovl = icon('mining.dmi', "cytineOVL")
		gemovl.Blend(rgb(gemR, gemG, gemB), ICON_ADD)
		src.overlays += image("icon" = gemovl, "layer" = FLOAT_LAYER)

/obj/item/weapon/ore/uqill
	name = "uqill nugget"
	desc = "A nugget of Uqill, a rare and very dense stone."
	icon_state = "uqill"

/obj/item/weapon/ore/telecrystal
	name = "telecrystal"
	desc = "A large unprocessed telecrystal, a gemstone with space-warping properties."
	icon_state = "telecrystal"

// Misc building material

/obj/item/weapon/ore/fabric // not really an ore as such, but...
	name = "fabric"
	desc = "Some spun cloth. Useful if you want to make clothing."
	icon_state = "fabric"




/obj/item/weapon/satchel
	name = "satchel"
	desc = "A leather bag. It holds 0/20 items."
	icon = 'mining.dmi'
	icon_state = "satchel"
	flags = ONBELT
	w_class = 1
	var/maxitems = 20
	var/list/allowed = list(/obj/item/)
	var/itemstring = "items"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		var/proceed = 0
		for(var/check_path in src.allowed)
			if(istype(W, check_path))
				proceed = 1
				break
		if (!proceed)
			user << "\red [src] cannot hold that kind of item!"
			return

		if (src.contents.len < src.maxitems)
			user.u_equip(W)
			W.loc = src
			if ((user.client && user.s_active != src))
				user.client.screen -= W
			W.dropped()
			user << "\blue You put [W] in [src]."
			var/itemamt = src.contents.len
			src.desc = "A leather bag. It holds [itemamt]/[src.maxitems] [src.itemstring]."
			if (itemamt == src.maxitems) user << "\blue [src] is now full!"
		else user << "\red [src] is full!"

	attack_self(var/mob/user as mob)
		if (src.contents.len)
			var/turf/T = user.loc
			for (var/obj/item/I in src.contents)
				I.loc = T
			user << "\blue You empty out [src]."
			src.desc = "A leather bag. It holds 0/[src.maxitems] [src.itemstring]."
		else ..()

	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		var/proceed = 0
		for(var/check_path in src.allowed)
			if(istype(O, check_path))
				proceed = 1
				break
		if (!proceed)
			user << "\red [src] cannot hold that kind of item!"
			return

		if (src.contents.len < src.maxitems)
			for(var/mob/V in viewers(user, null)) V.show_message(text("\blue [] begins quickly filling []!", user, src), 1)
			var/staystill = user.loc
			var/amt
			for(var/obj/item/I in view(1,user))
				if (!istype(I, O)) continue
				I.loc = src
				amt = src.contents.len
				src.desc = "A leather bag. It holds [amt]/[src.maxitems] [src.itemstring]."
				sleep(3)
				if (user.loc != staystill) break
				if (src.contents.len >= src.maxitems)
					user << "\blue [src] is now full!"
					break
			user << "\blue You finish filling [src]!"
		else user << "\red [src] is full!"

/obj/item/weapon/satchel/mining
	name = "mining satchel"
	desc = "A leather bag. It holds 0/20 ores."
	icon_state = "miningsatchel"
	allowed = list(/obj/item/weapon/ore/)
	itemstring = "ores"

/obj/item/weapon/satchel/hydro
	name = "produce satchel"
	desc = "A leather bag. It holds 0/50 items of produce."
	icon_state = "hydrosatchel"
	maxitems = 50
	allowed = list(/obj/item/weapon/seed/,/obj/item/weapon/plant/,/obj/item/weapon/reagent_containers/food/)
	itemstring = "items of produce"