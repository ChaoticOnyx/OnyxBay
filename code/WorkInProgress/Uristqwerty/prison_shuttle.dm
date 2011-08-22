

/datum/prison_shuttle
	var/location = "prison"
	var/destination = "prison"
	var/timer = 0
	var/transit_time = 180
	var/list/destinations = list(	"transit"	= /area/shuttle/prison/transit,
									"prison"	= /area/shuttle/prison/prison,
									"ship"		= /area/shuttle/prison/station)//temporary



/datum/prison_shuttle/proc/travel(var/new_destination, var/instant, var/override)
	return
	if(location == "transit" && !override)
		return
	if(destination == new_destination && !instant)
		return
	if(!instant)
		if(location == "transit")
			timer = 10
		else
			timer = 0
		destination = new_destination
	else
		var/area/current = locate(destinations[location])
		var/area/dest = locate(destinations[new_destination])
		current.move_contents_to(dest, /turf/space)
		destination = new_destination
		location = destination


/datum/prison_shuttle/New()
	..()
	spawn()
		while(1)
			if(location != destination)
				timer--
				if(timer < 1)
					var/area/current = locate(destinations[location])
					var/area/dest
					if(location == "transit")
						dest = locate(destinations[destination])
						current.move_contents_to(dest, /turf/space)
						location = destination
					else
						dest = locate(destinations["transit"])
						current.move_contents_to(dest, /turf/space)
						location = "transit"
						timer = transit_time
			sleep(10)



var/datum/prison_shuttle/prison_shuttle = new



/datum/game_mode/proc/allow_prison_shuttle(var/mob/usr, var/show_reject_message)
	return 1



/proc/call_prison_shuttle(var/mob/usr)
	if(!ticker || !ticker.mode || !ticker.mode.allow_prison_shuttle(usr, 1))
		return

	if(prison_shuttle.location == "transit" && (prison_shuttle.destination == "ship" || prison_shuttle.destination == "prison"))
		usr << "\red The prison shuttle is already in transit!"
	else if(prison_shuttle.location == "prison")
		usr << "The prison shuttle will arrive in a few minutes durr"
		prison_shuttle.travel("ship")
	else if(prison_shuttle.location == "ship")
		usr << "The prison shuttle has departed."
		prison_shuttle.travel("prison")
	else
		usr << "\red The prison shuttle is currently busy. Please try again later"

	//Old mode denial messages, for reference.
	/*if(ticker.mode.name == "blob" || ticker.mode.name == "Corporate Restructuring" || ticker.mode.name == "Sandbox")
		usr << "Under directive 7-10, [station_name()] is quarantined until further notice."
		return
	if(ticker.mode.name == "revolution")
		usr << "Centcom will not allow the shuttle to be called, due to the possibility of sabotage by revolutionaries."
		return
	if(ticker.mode.name == "AI malfunction")
		usr << "Centcom will not allow the shuttle to be called."
		return*/

///client/verb/test_prison_shuttle(var/dest as anything in prison_shuttle.destinations, var/instant as num, var/override as num)
//	prison_shuttle.travel(dest, instant, override)

