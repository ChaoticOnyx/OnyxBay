/mob/dead/observer/New(mob/corpse)
	invisibility = 10
	sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	see_invisible = 15
	see_in_dark = 100
	verbs += /mob/dead/observer/proc/dead_tele

	if(corpse)
		corpse = corpse
		loc = get_turf(corpse.loc)
		real_name = corpse.real_name
		name = corpse.real_name
		verbs += /mob/dead/observer/proc/reenter_corpse

/mob/proc/ghostize()
	set name = "Ghost"
	set desc = "You cannot be revived as a ghost"
	if(client)
		client.mob = new/mob/dead/observer(src)
	return

/mob/dead/observer/Move(NewLoc, direct)
	if(NewLoc)
		loc = NewLoc
		return
	if((direct & NORTH) && y < world.maxy)
		y++
	if((direct & SOUTH) && y > 1)
		y--
	if((direct & EAST) && x < world.maxx)
		x++
	if((direct & WEST) && x > 1)
		x--

/mob/dead/observer/examine()
	if(usr)
		usr << desc

/mob/dead/observer/can_use_hands()	return 0
/mob/dead/observer/is_active()		return 0

/mob/dead/observer/Stat()
	..()
	statpanel("Status")
	if (client.statpanel == "Status")
		if(LaunchControl.online && main_shuttle.location < 2)
			var/timeleft = LaunchControl.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

/mob/dead/observer/proc/reenter_corpse()
	set category = "Special Verbs"
	set name = "Re-enter Corpse"
	if(!corpse)
		alert("You don't have a corpse!")
		return
//	if(corpse.stat == 2)
//		alert("Your body is dead!")
//		return
	if(client && client.holder && client.holder.state == 2)
		var/rank = client.holder.rank
		client.clear_admin_verbs()
		client.holder.state = 1
		client.update_admins(rank)
	client.mob = corpse
	del(src)

/mob/dead/observer/proc/dead_tele()
	set category = "Special Verbs"
	set name = "Teleport"
	set desc= "Teleport"
	if((usr.stat != 2) || !istype(usr, /mob/dead/observer))
		usr << "Not when you're not dead!"
		return
	var/A
	usr.verbs -= /mob/dead/observer/proc/dead_tele
	spawn(50)
		usr.verbs += /mob/dead/observer/proc/dead_tele
	A = input("Area to jump to", "BOOYEA", A) in list("Engine","Hallways","Toxins","Storage","Maintenance","Crew Quarters","Medical","Security","Chapel","Bridge","Thunderdome")
	var/t = A
	switch (A)
		if ("Engine")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/engine) && !istype(B, /area/engine/combustion) && !istype(B, /area/engine/engine_walls))
					L += B
			A = L
		if ("Hallways")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/hallway))
					L += B
			A = L
		if ("Toxins")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/toxins) && !istype(B, /area/toxins/test_area))
					L += B
			A = L
		if ("Storage")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/storage))
					L += B
			A = L
		if ("Maintenance")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/maintenance))
					L += B
			A = L
		if ("Crew Quarters")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/crew_quarters))
					L += B
			A = L
		if ("Medical")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/medical))
					L += B
			A = L
		if ("Security")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/security))
					L += B
			A = L
		if ("Chapel")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/chapel))
					L += B
			A = L
		if ("Bridge")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/bridge))
					L += B
			A = L
		if ("Thunderdome")
			usr << "\red Two men enter, one leaves"
			return
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/tdome))
					L += B
			A = L

	var/list/L = list()
	for(var/area/AR in A)
		for(var/turf/T in AR)
			if(!T.density)
				var/clear = 1
				for(var/obj/O in T)
					if(O.density)
						clear = 0
						break
				if(clear)
					L+=T
	if (!L.len)
		log_admin("TELEPORT ERROR ([t])")
	usr.loc = pick(L)


