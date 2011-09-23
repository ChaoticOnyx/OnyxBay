/area/var/radsafe = 0
/area/maintenance/radsafe = 1
/area/ai_monitored/maintenance/radsafe = 1
/area/centcom/radsafe = 1
/area/admin/radsafe = 1
/area/adminsafety/radsafe = 1
/area/shuttle/radsafe = 1
/area/syndicate_station/radsafe = 1
/area/asteroid/radsafe = 1
/area/crew_quarters/sleeping/radsafe = 1

/datum/event/blowout
	New()
		..()
		Lifetime += 45
	Announce()
		if(!forced && prob(90))
			ActiveEvent = null
			SpawnEvent()
			del src
		command_alert("Warning: Ship approaching high-density radiation cloud. Seek cover immediately.")
	Tick()
		if(ActiveFor == 45)
			command_alert("Ship has entered radiation cloud. Do not leave cover until it has passed.")
		if(ActiveFor == (Lifetime+45)/3 || ActiveFor == (Lifetime+45)*2/3)	//1/3 and 2/3 f the way after it start proper make peope be half dead mostly
			for(var/mob/living/carbon/M in world)
				var/area = M.loc.loc
				while(!istype(area, /area))
					area = area:loc
				if(area:radsafe)
					continue
				if(!M.stat)
					M.radiate(100)
	Die()
		command_alert("The ship has cleared the radiation cloud. It is now safe to leave cover.")