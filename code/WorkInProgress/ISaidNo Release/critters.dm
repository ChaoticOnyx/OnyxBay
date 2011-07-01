// p much straight up copied from secbot code =I

/obj/critter/
	name = "critter"
	desc = "you shouldnt be able to see this"
	icon = 'critter.dmi'
	layer = 5.0
	density = 1
	anchored = 0
	var/alive = 1
	var/health = 10
	var/task = "thinking"
	var/aggressive = 0
	var/defensive = 0
	var/wanderer = 1
	var/opensdoors = 0
	var/frustration = 0
	var/last_found = null
	var/target = null
	var/oldtarget_name = null
	var/target_lastloc = null
	var/atkcarbon = 0
	var/atksilicon = 0
	var/atcritter = 0
	var/attack = 0
	var/attacking = 0
	var/steps = 0
	var/firevuln = 1
	var/brutevuln = 1
	var/seekrange = 7 // how many tiles away it will look for a target
	var/friend = null // used for tracking hydro-grown monsters's creator
	var/attacker = null // used for defensive tracking
	var/angertext = "charges at" // comes between critter name and target name

	attackby(obj/item/weapon/W as obj, mob/living/user as mob)
		..()
		if (!src.alive)
			..()
			return
		switch(W.damtype)
			if("fire")
				src.health -= W.force * src.firevuln
			if("brute")
				src.health -= W.force * src.brutevuln
			else
		if (src.alive && src.health <= 0) src.CritterDeath()
		if (src.defensive)
			src.target = user
			src.oldtarget_name = user.name
			for(var/mob/O in viewers(src, null))
				O.show_message("\red <b>[src]</b> [src.angertext] [user.name]!", 1)
			src.task = "chasing"

	attack_hand(var/mob/user as mob)
		..()
		if (!src.alive)
			..()
			return
		if (user.a_intent == "hurt")
			src.health -= rand(1,2) * src.brutevuln
			for(var/mob/O in viewers(src, null))
				O.show_message("\red <b>[user]</b> punches [src]!", 1)
			playsound(src.loc, "punch", 50, 1)
			if (src.alive && src.health <= 0) src.CritterDeath()
			if (src.defensive)
				src.target = user
				src.oldtarget_name = user.name
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <b>[src]</b> [src.angertext] [user.name]!", 1)
				src.task = "chasing"
		else
			for(var/mob/O in viewers(src, null))
				O.show_message("\red <b>[user]</b> pets [src]!", 1)

	proc/patrol_step()
		var/moveto = locate(src.x + rand(-1,1),src.y + rand(-1, 1),src.z)
		if (istype(moveto, /turf/simulated/floor) || istype(moveto, /turf/simulated/shuttle/floor) || istype(moveto, /turf/unsimulated/floor)) step_towards(src, moveto)
		if(src.aggressive) seek_target()
		steps += 1
		if (steps == rand(5,20)) src.task = "thinking"

	Bump(M as mob|obj)
		spawn(0)
			if ((istype(M, /obj/machinery/door)))
				var/obj/machinery/door/D = M
				if (src.opensdoors)
					D.open()
					src.frustration = 0
				else src.frustration ++
			else if ((istype(M, /mob/living/)) && (!src.anchored))
				src.loc = M:loc
				src.frustration = 0
			return
		return

	Bumped(M as mob|obj)
		spawn(0)
			var/turf/T = get_turf(src)
			M:loc = T
/*	Strumpetplaya - Not supported
	bullet_act(var/datum/projectile/P)
		var/damage = 0
		damage = round((P.power*P.ks_ratio), 1.0)

		if((P.damage_type == D_KINETIC)||(P.damage_type == D_PIERCING)||(P.damage_type == D_SLASHING))
			src.health -= (damage*brutevuln)
		else if(P.damage_type == D_ENERGY)
			src.health -= damage
		else if(P.damage_type == D_BURNING)
			src.health -= (damage*firevuln)
		else if(P.damage_type == D_RADIOACTIVE)
			src.health -= 1
		else if(P.damage_type == D_TOXIC)
			src.health -= 1

		if (src.health <= 0)
			src.CritterDeath()
*/
	ex_act(severity)
		switch(severity)
			if(1.0)
				src.CritterDeath()
				return
			if(2.0)
				src.health -= 15
				if (src.health <= 0)
					src.CritterDeath()
				return
			else
				src.health -= 5
				if (src.health <= 0)
					src.CritterDeath()
				return
		return

	meteorhit()
		src.CritterDeath()
		return

	proc/check_health()
		if (src.health <= 0)
			src.CritterDeath()

	blob_act()
		if(prob(25))
			src.CritterDeath()
		return

	proc/process()
		set background = 1
		if (!src.alive) return
		check_health()
		switch(task)
			if("thinking")
				src.attack = 0
				src.target = null
				sleep(15)
				walk_to(src,0)
				if (src.aggressive) seek_target()
				if (src.wanderer && !src.target) src.task = "wandering"
			if("chasing")
				if (src.frustration >= 8)
					src.target = null
					src.last_found = world.time
					src.frustration = 0
					src.task = "thinking"
					walk_to(src,0)
				if (target)
					if (get_dist(src, src.target) <= 1)
						var/mob/living/carbon/M = src.target
						ChaseAttack(M)
						src.task = "attacking"
						src.anchored = 1
						src.target_lastloc = M.loc
					else
						var/turf/olddist = get_dist(src, src.target)
						walk_to(src, src.target,1,4)
						if ((get_dist(src, src.target)) >= (olddist))
							src.frustration++
						else
							src.frustration = 0
						sleep(5)
				else src.task = "thinking"
			if("attacking")
				// see if he got away
				if ((get_dist(src, src.target) > 1) || ((src.target:loc != src.target_lastloc)))
					src.anchored = 0
					src.task = "chasing"
				else
					if (get_dist(src, src.target) <= 1)
						var/mob/living/carbon/M = src.target
						if (!src.attacking) CritterAttack(src.target)
						if (!src.aggressive)
							src.task = "thinking"
							src.target = null
							src.anchored = 0
							src.last_found = world.time
							src.frustration = 0
							src.attacking = 0
						else
							if(M!=null)
								if (M.health < 0)
									src.task = "thinking"
									src.target = null
									src.anchored = 0
									src.last_found = world.time
									src.frustration = 0
									src.attacking = 0
					else
						src.anchored = 0
						src.attacking = 0
						src.task = "chasing"
			if("wandering")
				patrol_step()
				sleep(10)
		spawn(8)
			process()
		return


	New()
		spawn(0) process()
		..()

/obj/critter/proc/seek_target()
	src.anchored = 0
	for (var/mob/living/C in view(src.seekrange,src))
		if (src.target)
			src.task = "chasing"
			break
		if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
		if (istype(C, /mob/living/carbon/) && !src.atkcarbon) continue
		if (istype(C, /mob/living/silicon/) && !src.atksilicon) continue
		if (C.health < 0) continue
		if (C.name == src.friend) continue
		if (C.name == src.attacker) src.attack = 1
		if (istype(C, /mob/living/carbon/) && src.atkcarbon) src.attack = 1
		if (istype(C, /mob/living/silicon/) && src.atksilicon) src.attack = 1

		if (src.attack)
			src.target = C
			src.oldtarget_name = C.name
			for(var/mob/O in viewers(src, null))
				O.show_message("\red <b>[src]</b> [src.angertext] [C.name]!", 1)
			src.task = "chasing"
			break
		else
			continue




/obj/critter/proc/CritterDeath()
	if (!src.alive) return
	src.icon_state += "-dead"
	src.alive = 0
	src.anchored = 0
	src.density = 0
	walk_to(src,0)
	src.visible_message("<b>[src]</b> dies!")

/obj/critter/proc/ChaseAttack(mob/M)
	for(var/mob/O in viewers(src, null))
		O.show_message("\red <B>[src]</B> leaps at [src.target]!", 1)
	//playsound(src.loc, 'genhit1.ogg', 50, 1, -1)

/obj/critter/proc/CritterAttack(mob/M)
	src.attacking = 1
	for(var/mob/O in viewers(src, null))
		O.show_message("\red <B>[src]</B> bites [src.target]!", 1)
	src.target:bruteloss += 1
	spawn(25)
		src.attacking = 0

/obj/critter/proc/CritterTeleport(var/telerange, var/dospark, var/dosmoke)
	if (!src.alive) return
	var/list/randomturfs = new/list()
	for(var/turf/T in orange(src, telerange))
		if(istype(T, /turf/space) || T.density) continue
		randomturfs.Add(T)
	src.loc = pick(randomturfs)
	if (dospark)
		var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
	if (dosmoke)
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(10, 0, src.loc)
		smoke.start()
	src.task = "thinking"




//
// Critter Defines
//

/obj/critter/roach
	name = "cockroach"
	desc = "An unpleasant insect that lives in filthy places."
	icon_state = "roach"
	health = 10
	aggressive = 0
	defensive = 0
	wanderer = 1
	opensdoors = 0
	atkcarbon = 0
	atksilicon = 0

	attack_hand(mob/user as mob)
		if (src.alive && (user.a_intent != "hurt"))
			src.visible_message("\red <b>[user]</b> pets [src]!")
			return
		if(prob(95))
			src.visible_message("\red <B>[user] stomps [src], killing it instantly!</B>")
			CritterDeath()
			return
		..()

/obj/critter/yeti
	name = "space yeti"
	desc = "Well-known as the single most aggressive, dangerous and hungry thing in the universe."
	icon_state = "yeti"
	density = 1
	health = 75
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = 0
	atkcarbon = 1
	atksilicon = 1
	firevuln = 3
	brutevuln = 1
	angertext = "starts chasing" // comes between critter name and target name

	New()
		src.seek_target()
		..()

	seek_target()
		src.anchored = 0
		for (var/mob/living/C in view(src.seekrange,src))
			if (src.target)
				src.task = "chasing"
				break
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (C.health < 0) continue
			if (C.name == src.attacker) src.attack = 1
			if (istype(C, /mob/living/carbon/)) src.attack = 1
			if (istype(C, /mob/living/silicon/)) src.attack = 1
			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <b>[src]</b> [src.angertext] [C.name]!", 1)
				//playsound(src.loc, pick('YetiGrowl.ogg'), 50, 0)	Strumpetplaya - Not supported
				src.task = "chasing"
				break
			else
				continue

	ChaseAttack(mob/M)
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src]</B> punches out [M]!", 1)
		playsound(src.loc, 'bang.ogg', 50, 1, -1)
		M.stunned = 10
		M.weakened = 10

	CritterAttack(mob/M)
		src.attacking = 1
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src]</B> devours [M] in one bite!", 1)
		playsound(src.loc, 'eatfood.ogg', 30, 1, -2)
		M.death(1)
		var/atom/movable/overlay/animation = null
		M.monkeyizing = 1
		M.canmove = 0
		M.icon = null
		M.invisibility = 101
		if(ishuman(M))
			animation = new(src.loc)
			animation.icon_state = "blank"
			animation.icon = 'mob.dmi'
			animation.master = src
		if (M.client)
			var/mob/dead/observer/newmob
			newmob = new/mob/dead/observer(M)
			M.client:mob = newmob
			M.mind.transfer_to(newmob)
		del(M)
		src.task = "thinking"
		src.seek_target()
		src.attacking = 0
		sleep(10)
		//playsound(src.loc, pick('burp_alien.ogg'), 50, 0)	Strumpetplaya - Not supported

/obj/critter/maneater
	name = "man-eating plant"
	desc = "It looks hungry..."
	icon_state = "maneater"
	density = 1
	health = 30
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = 0
	atkcarbon = 1
	atksilicon = 0
	firevuln = 2
	brutevuln = 0.5

	New()
		..()
		//playsound(src.loc, pick('MEilive.ogg'), 50, 0)	Strumpetplaya - Not supported

	seek_target()
		src.anchored = 0
		for (var/mob/living/C in view(src.seekrange,src))
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (istype(C, /mob/living/carbon/) && !src.atkcarbon) continue
			if (istype(C, /mob/living/silicon/) && !src.atksilicon) continue
			if (C.job == "Botanist") continue
			if (C.health < 0) continue
			if (C.name == src.friend) continue
			if (istype(C, /mob/living/carbon/) && src.atkcarbon) src.attack = 1
			if (istype(C, /mob/living/silicon/) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <b>[src]</b> charges at [C.name]!", 1)
				//playsound(src.loc, pick('MEhunger.ogg', 'MEraaargh.ogg', 'MEruncoward.ogg', 'MEbewarecoward.ogg'), 50, 0)	Strumpetplaya - Not supported
				src.task = "chasing"
				break
			else continue

	ChaseAttack(mob/M)
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src]</B> slams into [M]!", 1)
		playsound(src.loc, 'genhit1.ogg', 50, 1, -1)
		M.stunned += rand(1,4)
		M.weakened += rand(1,4)

	CritterAttack(mob/M)
		src.attacking = 1
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src]</B> starts trying to eat [M]!", 1)
		spawn(60)
			if (get_dist(src, M) <= 1 && ((M:loc == target_lastloc)))
				if(istype(M,/mob/living/carbon))
					for(var/mob/O in viewers(src, null))
						O.show_message("\red <B>[src]</B> ravenously wolfs down [M]!", 1)
					playsound(src.loc, 'eatfood.ogg', 30, 1, -2)
					M.death(1)
					var/atom/movable/overlay/animation = null
					M.monkeyizing = 1
					M.canmove = 0
					M.icon = null
					M.invisibility = 101
					if(ishuman(M))
						animation = new(src.loc)
						animation.icon_state = "blank"
						animation.icon = 'mob.dmi'
						animation.master = src
					if (M.client)
						var/mob/dead/observer/newmob
						newmob = new/mob/dead/observer(M)
						M.client:mob = newmob
						M.mind.transfer_to(newmob)
					del(M)
					sleep(25)
					src.target = null
					src.task = "thinking"
					//playsound(src.loc, pick('burp_alien.ogg'), 50, 0)	Strumpetplaya - Not supported
			else
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[src]</B> gnashes its teeth in fustration!", 1)
			src.attacking = 0

/obj/critter/killertomato
	name = "killer tomato"
	desc = "Today, Space Station 13 - tomorrow, THE WORLD!"
	icon_state = "ktomato"
	density = 1
	health = 15
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = 1
	atkcarbon = 1
	atksilicon = 1
	firevuln = 2
	brutevuln = 2

	seek_target()
		src.anchored = 0
		for (var/mob/living/C in view(src.seekrange,src))
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (istype(C, /mob/living/carbon/) && !src.atkcarbon) continue
			if (istype(C, /mob/living/silicon/) && !src.atksilicon) continue
			if (C.health < 0) continue
			if (C.name == src.attacker) src.attack = 1
			if (istype(C, /mob/living/carbon/) && src.atkcarbon) src.attack = 1
			if (istype(C, /mob/living/silicon/) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <b>[src]</b> charges at [C:name]!", 1)
				//playsound(src.loc, pick('MEhunger.ogg', 'MEraaargh.ogg', 'MEruncoward.ogg', 'MEbewarecoward.ogg'), 50, 0)	Strumpetplaya - Not supported
				src.task = "chasing"
				break
			else
				continue

	ChaseAttack(mob/M)
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src]</B> viciously lunges at [M]!", 1)
		if (prob(20)) M.stunned += rand(1,3)
		M.bruteloss += rand(2,5)

	CritterAttack(mob/M)
		src.attacking = 1
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src]</B> bites [src.target]!", 1)
		src.target:bruteloss += rand(1,2)
		spawn(10)
			src.attacking = 0

	CritterDeath()
		src.visible_message("<b>[src]</b> messily splatters into a puddle of tomato sauce!")
		src.alive = 0
		playsound(src.loc, 'splat.ogg', 100, 1)
		var/obj/decal/cleanable/blood/B = new(src.loc)
		B.name = "ruined tomato"
		del src

/obj/critter/spore
	name = "plasma spore"
	desc = "A barely intelligent colony of organisms. Very volatile."
	icon_state = "spore"
	density = 1
	health = 1
	aggressive = 0
	defensive = 0
	wanderer = 1
	opensdoors = 0
	atkcarbon = 0
	atksilicon = 0
	firevuln = 2
	brutevuln = 2

	CritterDeath()
		src.visible_message("<b>[src]</b> ruptures and explodes!")
		src.alive = 0
		var/turf/T = get_turf(src.loc)
		if(T)
			T.hotspot_expose(700,125)
			explosion(T, -1, -1, 2, 3)
		del src

	ex_act(severity)
		CritterDeath()

	bullet_act(flag, A as obj)
		CritterDeath()

/obj/critter/mouse
	name = "space-mouse"
	desc = "A mouse.  In space."
	icon_state = "mouse"
	density = 0
	health = 2
	aggressive = 0
	defensive = 1
	wanderer = 1
	opensdoors = 0
	atkcarbon = 0
	atksilicon = 0
	firevuln = 1
	brutevuln = 1

	CritterAttack(mob/M)
		src.attacking = 1
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src]</B> bites [src.target]!", 1)
		src.target:bruteloss += 1
		spawn(10)
			src.attacking = 0

/obj/critter/mimic
	name = "mechanical toolbox"
	desc = null
	icon_state = "mimic1"
	health = 20
	aggressive = 1
	defensive = 1
	wanderer = 0
	atkcarbon = 1
	atksilicon = 1
	brutevuln = 0.5
	seekrange = 1
	angertext = "suddenly comes to life and lunges at"

	process()
		..()
		if (src.alive)
			switch(task)
				if("thinking")
					src.icon_state = "mimic1"
					src.name = "mechanical toolbox"
				if("chasing")
					src.icon_state = "mimic2"
					src.name = "mimic"
				if("attacking")
					src.icon_state = "mimic2"
					src.name = "mimic"

	ChaseAttack(mob/M)
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src]</B> hurls itself at [M]!", 1)
		if (prob(33)) M.weakened += rand(3,6)

	CritterAttack(mob/M)
		src.attacking = 1
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src]</B> bites [src.target]!", 1)
		src.target:bruteloss += rand(2,4)
		spawn(25)
			src.attacking = 0

	CritterDeath()
		src.visible_message("<b>[src]</b> crumbles to pieces!")
		src.alive = 0
		density = 0
		walk_to(src,0)
		src.icon_state = "mimic-dead"

/obj/critter/martian
	name = "martian"
	desc = "Genocidal monsters from Mars."
	icon_state = "martian"
	density = 1
	health = 20
	aggressive = 0
	defensive = 1
	wanderer = 1
	opensdoors = 1
	atkcarbon = 1
	atksilicon = 1
	firevuln = 1.5
	brutevuln = 1

	attackby(obj/item/weapon/W as obj, mob/living/user as mob)
		..()
		if (!src.alive) return
		switch(W.damtype)
			if("fire") src.health -= W.force * src.firevuln
			if("brute") src.health -= W.force * src.brutevuln
		if (src.alive && src.health <= 0) src.CritterDeath()
		if (src.defensive)
			MartianPsyblast(user)
			for(var/mob/O in viewers(src, null))
				O.show_message("\red <b>[src]</b> teleports away!", 1)
			CritterTeleport(20, 1, 0)

	attack_hand(var/mob/user as mob)
		if (!src.alive) return
		if (user.a_intent == "hurt")
			src.health -= rand(1,2) * src.brutevuln
			for(var/mob/O in viewers(src, null))
				O.show_message("\red <b>[user]</b> punches [src]!", 1)
			playsound(src.loc, pick('punch1.ogg','punch2.ogg','punch3.ogg','punch4.ogg'), 100, 1)
			if (src.alive && src.health <= 0) src.CritterDeath()
			if (src.defensive)
				MartianPsyblast(user)
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <b>[src]</b> teleports away!", 1)
				CritterTeleport(20, 1, 0)
		else
			for(var/mob/O in viewers(src, null))
				O.show_message("\red <b>[user]</b> pets [src]!", 1)
			for(var/mob/O in hearers(src, null))
				O.show_message("<b>[src]</b> screeches, 'KXBQUB IJFDQVW??'", 1)


/obj/critter/martian/proc/MartianPsyblast(mob/target as mob)
	for(var/mob/O in hearers(src, null))
		O.show_message("<b>[src]</b> screeches, 'GBVQW UVQWIBJZ PKDDR!!!'", 1)
	target << "\red You are blasted by psychic energy!"
	playsound(target.loc, 'ghost2.ogg', 100, 1)
	target.paralysis += 10
	target.stuttering += 60
	target.brainloss += 20
	target.fireloss += 5

/obj/critter/martian/soldier
	name = "martian soldier"
	desc = "Genocidal monsters from Mars."
	icon_state = "martianS"
	health = 35
	aggressive = 1
	seekrange = 7

	seek_target()
		src.anchored = 0
		for (var/mob/living/C in view(src.seekrange,src))
			if (!src.alive) break
			if (C.health < 0) continue
			if (C.name == src.attacker) src.attack = 1
			if (istype(C, /mob/living/carbon/) && src.atkcarbon) src.attack = 1
			if (istype(C, /mob/living/silicon/) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <b>[src]</b> shoots at [C.name]!", 1)
				//playsound(src.loc, 'lasermed.ogg', 100, 1)	Strumpetplaya - Not supported
				if (prob(66))
					C.fireloss += rand(3,5)
					var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
					s.set_up(3, 1, C)
					s.start()
				else target << "\red The shot missed!"
				src.attack = 0
				sleep(12)
				seek_target()
				src.task = "thinking"
				break
			else continue

/obj/critter/martian/psychic
	name = "martian mutant"
	desc = "Genocidal monsters from Mars."
	icon_state = "martianP"
	health = 10
	aggressive = 1
	seekrange = 4

	seek_target()
		src.anchored = 0
		for (var/mob/living/C in view(src.seekrange,src))
			if (!src.alive) break
			if (C.health < 0) continue
			if (C.name == src.attacker) src.attack = 1
			if (istype(C, /mob/living/carbon/) && src.atkcarbon) src.attack = 1
			if (istype(C, /mob/living/silicon/) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <b>[src]</b> stares at [C.name]!", 1)
				//playsound(src.loc, 'phaseroverload.ogg', 100, 1)	Strumpetplaya - Not supported
				C << "\red You feel a horrible pain in your head!"
				C.stunned += rand(1,2)
				sleep(55)
				if ((get_dist(src, C) <= 6) && src.alive)
					for(var/mob/O in viewers(C, null))
						O.show_message("\red <b>[C.name]'s</b> head explodes!", 1)
					C.gib()
				else
					for(var/mob/O in viewers(src, null))
						O.show_message("\red <b>[src]</b> screeches, 'VWYK QWU!!'", 1)
				src.attack = 0
				sleep(30)
				src.task = "thinking"
				break
			else continue

/obj/critter/martian/warrior
	name = "martian warrior"
	desc = "Genocidal monsters from Mars."
	icon_state = "martianW"
	health = 35
	aggressive = 1
	seekrange = 7

	ChaseAttack(mob/M)
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src]</B> grabs at [M]!", 1)
		if (prob(33)) M.weakened += rand(2,4)
		spawn(25)
			if (get_dist(src, M) <= 1)
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[src]</B> starts strangling [M]!", 1)

	CritterAttack(mob/M)
		src.attacking = 1
		if (prob(95))
			if (prob(10))
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[src]</B> wraps its tentacles around [M]'s neck!", 1)
			M:oxyloss += 2
			M.weakened += 1
		else
			for(var/mob/O in viewers(src, null))
				O.show_message("\red <B>[src]'s</B> grip slips!", 1)
			M.stunned = 0
			sleep(10)
			for(var/mob/O in viewers(src, null))
				O.show_message("\red <b>[src]</b> screeches, 'KBWKB WVYPGD!!'", 1)
			src.task = "thinking"
		spawn(10)
			src.attacking = 0

/obj/critter/martian/sapper
	name = "martian sapper"
	desc = "Genocidal monsters from Mars."
	icon_state = "martianSP"
	health = 10
	aggressive = 0
	defensive = 0
	atkcarbon = 0
	atksilicon = 0
	task = "wandering"

	New()
		..()
		src.task = "wandering"


	process()
		set background = 1
		if (!src.alive) return
		switch(task)
			if("thinking")
				var/obj/machinery/martianbomb/B = new(src.loc)
				B.icon_state = "mbomb-timing"
				B.active = 1
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[src];s</B> plants a bomb and teleports away!", 1)
				del src
			if("wandering")
				patrol_step()
				sleep(10)
		spawn(10)
			process()

/obj/machinery/martianbomb
	name = "martian bomb"
	desc = "You'd best destroy this thing fast."
	icon = 'critter.dmi'
	icon_state = "mbomb-off"
	anchored = 1
	density = 1
	var/health = 100
	var/active = 0
	var/timeleft = 120
	//mats = 15		Strumpetplaya - not supported

	process()
		if (src.active)
			src.icon_state = "mbomb-timing"
			src.timeleft -= 1
			if (src.timeleft <= 10) src.icon_state = "mbomb-det"
			if (src.timeleft == 0)
				explosion(src.loc, 5, 10, 15, 20)
				del src
			//proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
		else
			src.icon_state = "mbomb-off"

	ex_act(severity)
		if(severity)
			for(var/mob/O in viewers(src, null))
				O.show_message("\blue <B>[src]</B> crumbles away into dust!", 1)
			del src
		return
/*	Strumpetplaya - Not supported
	bullet_act(var/datum/projectile/P)
		var/damage = 0
		damage = round((P.power*P.ks_ratio), 1.0)


		if(P.damage_type == D_KINETIC)
			if(damage >= 20)
				src.health -= damage
			else
				damage = 0
		else if(P.damage_type == D_PIERCING)
			src.health -= (damage*2)
		else if(P.damage_type == D_ENERGY)
			src.health -= damage
		else
			damage = 0

		if(damage >= 15)
			if (src.active && src.timeleft > 10)
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[src]</B> begins buzzing loudly!", 1)
				src.timeleft = 10

		if (src.health <= 0)
			for(var/mob/O in viewers(src, null))
				O.show_message("\blue <B>[src]</B> crumbles away into dust!", 1)
			del src
*/
	attackby(obj/item/weapon/W as obj, mob/user as mob)
		..()
		src.health -= W.force
		if (src.active && src.timeleft > 10)
			for(var/mob/O in viewers(src, null))
				O.show_message("\red <B>[src]</B> begins buzzing loudly!", 1)
			src.timeleft = 10
		if (src.health <= 0)
			for(var/mob/O in viewers(src, null))
				O.show_message("\blue <B>[src]</B> crumbles away into dust!", 1)
			del src

/obj/critter/rockworm
	name = "rock worm"
	desc = "Tough lithovoric worms."
	icon_state = "rockworm"
	density = 0
	health = 80
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = 0
	atkcarbon = 0
	atksilicon = 0
	firevuln = 0.1
	brutevuln = 1
	angertext = "hisses at"
	var/eaten = 0

	seek_target()
		src.anchored = 0
		for (var/obj/item/weapon/ore/C in view(src.seekrange,src))
			if (src.target)
				src.task = "chasing"
				break
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <b>[src]</b> sees [C.name]!", 1)
				src.task = "chasing"
				break
			else
				continue

	CritterAttack(mob/M)
		src.attacking = 1

		if(istype(M, /obj/item/weapon/ore/))
			src.visible_message("\red <b>[src]</b> hungrily eats [src.target]!")
			playsound(src.loc, 'eatfood.ogg', 30, 1, -2)
			del(src.target)
			src.eaten++
			src.target = null
			src.task = "thinking"

		src.attacking = 0
		return

	CritterDeath()
		src.alive = 0
		src.target = null
		src.task = "dead"
		density = 0
		src.icon_state = "rockworm-dead"
		walk_to(src,0)
		for(var/mob/O in viewers(src, null)) O.show_message("<b>[src]</b> dies!",1)
		//var/countstones = 0	Strumpetplaya - Not supported
		//while (src.eaten)
			//countstones++
			//if (countstones == 10)
			//	if (prob(50)) new /obj/item/weapon/ore/cytine(src.loc)
			//	else new /obj/item/weapon/ore/uqill(src.loc)
			//	countstones = 0
			//src.eaten--