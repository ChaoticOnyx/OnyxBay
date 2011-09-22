/datum/event/blowout
	var/list/safezones = list(/area/maintenance, /area/ai_monitored/maintenance, /area/centcom, /area/admin, /area/adminsafety, /area/shuttle, /area/syndicate_station, /area/asteroid)
	New()
		..()
		Lifetime += 45
	Announce()
		command_alert("Warning: Ship approaching high-density radiation cloud. Seek cover immediately.")
	Tick()
		if(ActiveFor == 45)
			command_alert("Ship has entered radiation cloud. Do not leave cover until it has passed.")
		if(ActiveFor >= 45)
			for(var/mob/living/carbon/M in world)
				var/area = M.loc.loc
				while(!istype(area, /area))
					area = area:loc
				var/safe = 0
				for(var/A in safezones)
					if(istype(area,A))
						safe = 1
						break
				if(M.radiation < 95 && !M.stat && !safe)
					M.radiate(10)
	Die()
		command_alert("The ship has cleared the radiation cloud. It is now safe to leave cover.")