/datum/event/power_offline
	Announce()
		command_alert("The ship is preforming an automated power system grid check, please standby", "Maintenance alert")
		for(var/obj/machinery/power/apc/a in world)
			if(!a.crit)
				a.eventoff = 1
				spawn(200)
					a.eventoff = 0

