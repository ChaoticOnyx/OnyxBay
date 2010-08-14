// Controls the emergency shuttle



//This code needs major cleanup

//The way that the goons setup the shuttle was VERY VERY VERY wierd




// these define the time taken for the shuttle to get to SS13
// and the time before it leaves again
#define SHUTTLEARRIVETIME 10		// 10 minutes = 600 seconds

#define PODLAUNCHTIME 60

#define PODTRANSITTIME 60

#define SHUTTLELEAVETIME 10		// 3 minutes = 180 seconds

var/global/datum/shuttle/main_shuttle

var/global/list/datum/shuttle/shuttles = list()

datum/shuttle
	var
		name = "Shuttle"
		location = 1 //0 = somewhere far away, 1 = at SS13, 2 = returned from SS13 // 0 = Transit, 1 = Start, 2 = dest
		online = 0
		direction = 2 //-1 = going back to central command, 1 = going back to SS13 // 1 = Start, 2 = Dest




		area
			centcom
			station
			transit

		endtime			// timeofday that shuttle arrives
		//timeleft = 360 //600


	New(var/name,var/centcom,var/transit,var/station)
		src.centcom = centcom
		src.transit = transit
		src.station = station
		src.name = name

	// call the shuttle
	// if not called before, set the endtime to T+600 seconds
	// otherwise if outgoing, switch to incoming
	proc/depart()
		if(endtime)
			if(direction == -1)
				setdirection(1)
		else
			settimeleft(PODTRANSITTIME)
			online = 1
			direction = 2

	proc/recall()
		if(direction == 1)
			setdirection(2)
			online = 1
		else
			setdirection(1)
			online = 1

	proc/abletolaunch()
		if(location != 0 && online == 0)
			return 1
		else
			return 0


	// returns the time (in seconds) before shuttle arrival
	// note if direction = -1, gives a count-up to SHUTTLEARRIVETIME
	proc/timeleft()
		if(online)
			var/timeleft = round((endtime - world.timeofday)/10 ,1)
			if(direction == 1)
				return timeleft
			else
				return PODTRANSITTIME-timeleft
		else
			return PODTRANSITTIME

	// sets the time left to a given delay (in seconds)
	proc/settimeleft(var/delay)
		endtime = world.timeofday + delay * 10

	// sets the shuttle direction
	// 1 = towards SS13, -1 = back to centcom
	proc/setdirection(var/dirn)
		if(direction == dirn)
			return
		direction = dirn
		// if changing direction, flip the timeleft by SHUTTLEARRIVETIME
		var/ticksleft = endtime - world.timeofday
		endtime = world.timeofday + (SHUTTLEARRIVETIME*10 - ticksleft)
		return

	proc
		process()
		//	world << timeleft()
		//	world << "l:[location],d:[direction],o:[online]"
			if(!online) return
			var/timeleft = timeleft()
			if(timeleft > 1e5)		// midnight rollover protection
				timeleft = 0
			switch(location)

				if(1)
					if(timeleft>0)
						var/area/start_location = locate(centcom)
						var/area/end_location = locate(transit)
						for(var/mob/m in start_location)
							shake_camera(m, 3, 1)
						start_location.move_contents_to(end_location)
						location = 0
						direction = 2

				if(0)
					if(timeleft>PODTRANSITTIME)
				//		online = 0
				//		direction = 1
				//		endtime = null
						return 0

					else if(timeleft >= PODTRANSITTIME)
						location = direction

						var/area/start_location = locate(transit)
						var/area/end_location
						if(direction == 1)
							end_location = locate(centcom)
						else
							end_location = locate(station)

						var/list/dstturfs = list()
						var/throwy = world.maxy

						for(var/turf/T in end_location)
							dstturfs += T
							if(T.y < throwy)
								throwy = T.y

						// hey you, get out of the way!
						for(var/turf/T in dstturfs)
							// find the turf to move things to
							var/turf/D = locate(T.x, throwy - 1, 1)
							//var/turf/E = get_step(D, SOUTH)
							for(var/atom/movable/AM as mob|obj in T)
								AM.Move(D)
								// NOTE: Commenting this out to avoid recreating mass driver glitch
								/*
								spawn(0)
									AM.throw_at(E, 1, 1)
									return
								*/
							if(istype(T, /turf/simulated))
								del(T)
						for(var/mob/m in start_location)
							shake_camera(m, 3, 1)

						start_location.move_contents_to(end_location)

						return 1

				if(2)
					if(timeleft>0)
						var/area/start_location = locate(centcom)
						for(var/mob/m in start_location)
							shake_camera(m, 3, 1)
						var/area/end_location = locate(transit)
						start_location.move_contents_to(end_location)
						location = 0
						direction = 1

			/*		else
						location = 2
						var/area/start_location = locate(station)
						var/area/end_location = locate(centcom)

						start_location.move_contents_to(end_location)
						online = 0

						return 1
*/
				else
					return 1



proc/CreateShuttles() //Would do this via config, but map changes are rare and need source code anyway
	var/datum/shuttle/pod1 = new /datum/shuttle("Escape pod 1","/area/shuttle/escape/station/pod1","/area/shuttle/escape/transit/pod1","/area/shuttle/escape/centcom/pod1")
	var/datum/shuttle/pod2 = new /datum/shuttle("Escape pod 2","/area/shuttle/escape/station/pod2","/area/shuttle/escape/transit/pod2","/area/shuttle/escape/centcom/pod2")
	shuttles += pod1
	shuttles += pod2
	main_shuttle = pod1 // Hack, until proper gameplay for multiple shuttles is established

/datum/PodControl
	var/endtime
	var/online = 0

	var/last60 = 0

	proc/start()
		settimeleft(PODLAUNCHTIME)
		online = 1
		last60 = timeleft()

		for(var/area/ToggleAlert in world)
			if (ToggleAlert.applyalertstatus && ToggleAlert.type != /area)
				ToggleAlert.redalert = 1

	proc/stop()
		online = 0

	proc/timeleft()
		var/timeleft = round((endtime - world.timeofday)/10 ,1)
		return timeleft

	proc/settimeleft(var/delay)
		endtime = world.timeofday + delay * 10


	proc/process()
	//	world << "PODCON[timeleft()]"
		var/timeleft = timeleft()
		if(timeleft > 1e5)		// midnight rollover protection
			timeleft = 0

		if(timeleft() < last60 && online)
			if(timeleft > 60)
				radioalert("[round(timeleft()/60,1)] minutes until escape pod launch","Escape computer")
				if(timeleft() - 60 > 60)
					last60 = timeleft() - 60
				else
					last60 = 60
			if(timeleft > 30)
				radioalert("[round(timeleft(),1)] seconds until escape pod launch","Escape computer")
				if(timeleft() - 10 > 10)
					last60 = timeleft() - 10
				else
					last60 = timeleft() - 1
			else
				radioalert("[round(timeleft(),1)] seconds","Escape computer")
				last60 = timeleft() - 1


		if(timeleft <= 0 && online == 1)
			for(var/datum/shuttle/s in shuttles)
				s.depart()
			online = 0




/proc/radioalert(var/message,var/from)
	var/obj/item/device/radio/intercom/a = new /obj/item/device/radio/intercom(null)
	a.autosay(message,from)
