/*ZAS3 - Necessitated by the obfuscating nature of gooncode.*/

#define FLOW_PERCENT 1 //Percent of gas to send between connected turfs.
#define VACUUM_SPEED 1.5 //Divisor of zone gases exposed directly to space (i.e. space tiles in members)

#define QUANTIZE(variable)		(round(variable,0.0001))

var/list/zones = list()
var/zone_update_delay = 5

turf/var/zone/zone

zone
	var
		list/members

		turf/starting_tile

		oxygen = 0
		nitrogen = 0
		co2 = 0

		temp = T20C

		oxygen_archive = 0
		nitrogen_archive = 0
		co2_archive = 0

		list/space_connections = list()

		temp_archive = T20C

		turf_oxy = 0
		turf_nitro = 0
		turf_co2 = 0

		volume = CELL_VOLUME
		pressure = ONE_ATMOSPHERE

		list/connections = list()
		list/direct_connections = list() //Zones with doors connecting them to us, so that we know not to merge.

		list/merge_with = list()

	proc

		Connect(turf/T) //Connects to T.zone with T as the point they connect at.
		Disconnect(turf/T) //Disconnects from T.zone with T as the point

		//THESE ARE CALLED AUTOMATICALLY//
		Split(turf/X,turf/Y) //Checks for splits in the zone at the specified locations.
		Merge(zone/Z) //Merges this zone with the specified zone.

		Update() //Loop which auto-calls some essential functions.

		HasSpace()

		oxygen(n) //When called with no args, these return moles/turf. When called with n, they set moles/turf to n.
		nitrogen(n)
		co2(n)
		add_oxygen(n) //Adds gas to the total.
		add_nitrogen(n)
		add_co2(n)
		rebuild_cache() //Recalculates turf_ values.
		update_members()

		AddTurf(turf/T) //Adds a turf to the zone, recalculates volume, and rebuilds the cache.
		RemoveTurf(turf/T) //Same, but removes a turf from the zone.

		pressure()
			return (oxygen+nitrogen+co2)*R_IDEAL_GAS_EQUATION*temp/volume

	//......................//

	New(turf/start,soxy = 0,snitro = 0,sco2 = 0,smembers,sspace = list())

		starting_tile = start

		if(!start.CanPass(null,start,0,0)) //Bug here.
			world << "Warning: Zone created on [start] at [start.x],[start.y],[start.z]."
			world << "A gray overlay has been applied to show the location."
			start.overlays += 'icons/Testing/turf_analysis.dmi'
			del src
			return 0

		zones += src //Add to the zone list
		if(smembers)
			members = smembers
			space_connections = sspace
		else
			members = FloodFill(start) //Do a floodfill to get new members.
			if(ticker)
				space_connections = tmp_spaceconnections
				tmp_spaceconnections.len = 0

		if(!members.len) //Bug here.
			world << "Warning: Zone created with no members at [start.x],[start.y],[start.z]."
			world << "A gray overlay has been applied to show the location."
			start.overlays += 'icons/Testing/turf_analysis.dmi'
			del src
			return 0

		for(var/turf/T in members)
			T.zone = src
		if(!ticker) //If this zone was created at startup, add gases.
			oxygen = MOLES_O2STANDARD * members.len
			nitrogen = MOLES_N2STANDARD * members.len
			oxygen_archive = oxygen
			nitrogen_archive = nitrogen
		else if(soxy > 0 || snitro > 0 || sco2 > 0)
			oxygen = soxy * members.len
			nitrogen = snitro * members.len
			co2 = sco2 * members.len

		volume = members.len * CELL_VOLUME

		spawn Update() //Call the update cycle.

		//.....................//

	Update()
		while(1)
			sleep(zone_update_delay)

			if(oxygen_archive != oxygen || nitrogen_archive != nitrogen || co2_archive != co2)
				rebuild_cache()
				update_members()

			oxygen_archive = oxygen		 //Update the archives, so we can do things like calculate delta.
			nitrogen_archive = nitrogen
			co2_archive = co2
			temp_archive = temp

			if(space_connections.len)				 //Throw gas into space if it has space connections.
				oxygen = QUANTIZE(oxygen/VACUUM_SPEED)
				nitrogen = QUANTIZE(nitrogen/VACUUM_SPEED)
				co2 = QUANTIZE(co2/VACUUM_SPEED)
				temp = min(TCMB,temp/VACUUM_SPEED)
				for(var/turf/simulated/M in members)
					var/datum/gas_mixture/GM = M.return_air()
					GM.toxins = QUANTIZE(GM.toxins/VACUUM_SPEED)
					for(var/datum/gas/gas in GM.trace_gases)
						gas.moles = QUANTIZE(gas.moles/VACUUM_SPEED)
				AirflowSpace(src)
			merge_with.len = 0
			for(var/zone/Z in connections)

				var/list/borders = connections[Z] //Get the list of border tiles.

				var/percent_flow = max(90,FLOW_PERCENT*borders.len) //This is the percentage of gas that will flow.

				Airflow(src,Z,pressure-Z.pressure)


				//Magic Happens Here
				var
					oxy_avg = (oxygen + Z.oxygen) / (members.len + Z.members.len)
					nit_avg = (nitrogen + Z.nitrogen) / (members.len + Z.members.len)
					co2_avg = (co2 + Z.co2) / (members.len + Z.members.len)

				oxygen( (oxygen() - oxy_avg) * (1-percent_flow/100) + oxy_avg )
				nitrogen( (nitrogen() - nit_avg) * (1-percent_flow/100) + nit_avg )
				co2( (co2() - co2_avg) * (1-percent_flow/100) + co2_avg )

				Z.oxygen( (Z.oxygen() - oxy_avg) * (1-percent_flow/100) + oxy_avg )
				Z.nitrogen( (Z.nitrogen() - nit_avg) * (1-percent_flow/100) + nit_avg )
				Z.co2( (Z.co2() - co2_avg) * (1-percent_flow/100) + co2_avg )
					//End Magic


			for(var/zone/Z in direct_connections)
				if(abs(turf_oxy - Z.turf_oxy) < 0.2 && abs(turf_nitro- Z.turf_nitro) < 0.2 && abs(turf_co2 - Z.turf_co2) < 0.2)
					Merge(Z)

	rebuild_cache()
		if(!members.len) del src
		turf_oxy = oxygen / members.len
		turf_nitro = nitrogen / members.len
		turf_co2 = co2 / members.len

		var/tempsum = 0

		for(var/turf/simulated/M in members)
			if(M.air)
				tempsum += M.air.temperature

		temp = tempsum / members.len

		pressure = pressure()

	oxygen(n)
		if(!n) return turf_oxy
		else
			turf_oxy = n
			oxygen = turf_oxy*members.len
	nitrogen(n)
		if(!n) return turf_nitro
		else
			turf_nitro = n
			nitrogen = turf_nitro*members.len
	co2(n)
		if(!n) return turf_co2
		else
			turf_co2 = n
			co2 = turf_co2*members.len

	add_oxygen(n)
		if(n < 0 && oxygen < abs(n))
			. = oxygen
			oxygen = 0
		else
			oxygen += n
		. = -n
	add_nitrogen(n)
		if(n < 0 && nitrogen < abs(n))
			. = nitrogen
			nitrogen = 0
		else
			nitrogen += n
		. = -n
	add_co2(n)
		if(n < 0 && co2 < abs(n))
			. = co2
			co2 = 0
		else
			co2 += n
		. = -n

	AddTurf(turf/T)
		if(T.zone) return
		members += T
		T.zone = src
		for(var/turf/space/S in range(1,T))
			space_connections += S
		volume = CELL_VOLUME*members.len
		rebuild_cache()
		update_members()
	RemoveTurf(turf/T)
		if(T.zone != src) return
		members -= T
		T.zone = null
		for(var/turf/space/S in range(1,T))
			space_connections -= S
		volume = CELL_VOLUME*members.len
		rebuild_cache()
		update_members()
		if(ticker)
			spawn(1) SplitCheck(T)


	update_members()
		for(var/turf/T in members)
			var/datum/gas_mixture/GM = T.return_air()
			GM.oxygen = oxygen()
			GM.nitrogen = nitrogen()
			GM.carbon_dioxide = co2()

	Connect(turf/S,turf/T,pc)
		if(!istype(T,/turf/simulated)) return
		if(!T.zone) return
		//if(!pc) world << "Connecting zones."
		if(!(T.zone in connections) && !(src in T.zone.connections))
			connections += T.zone
			T.zone.connections += src
			connections[T.zone] = list()
			T.zone.connections[src] = list()
		if(!(T in connections[T.zone]) && !(S in T.zone.connections[src]))
			connections[T.zone] += T
			T.zone.connections[src] += S
			//if(pc < 2)
			//	for(var/d in cardinal)
			//		var/turf/C = get_step(T,d)
			//		if(istype(C,/turf/space)) space_connections++
			//		if(!istype(C,/turf/simulated)) continue
			//		if(C.zone == T.zone || C.zone == src) continue
			//		if(C.zone in T.zone.connections || C.zone in connections) continue
			//		Connect(S,C,pc+1)
			//S.overlays += 'debug_connect.dmi'
			//S.overlays -= 'Zone.dmi'
			//T.overlays += 'debug_connect.dmi'
			//T.overlays -= 'Zone.dmi'
			if(!(S.HasDoor(1) || T.HasDoor(1)))
				direct_connections += T.zone
				T.zone.direct_connections += src

	Disconnect(turf/S,turf/T,pc)
		if(!istype(T,/turf/simulated)) return
		if(!T.zone) return
		//if(!pc) world << "Disconnecting zones."
		if((T in connections[T.zone]) && (S in T.zone.connections[src]))
			connections[T.zone] -= T
			T.zone.connections[src] -= S
			//if(pc < 2)
			//	for(var/d in cardinal)
			//		var/turf/C = get_step(T,d)
			//		if(istype(C,/turf/space)) space_connections--
			//		if(!istype(C,/turf/simulated)) continue
			//		if(C.zone == T.zone || C.zone == src) continue
			//		if(!(C.zone in connections)) continue
			//		Disconnect(S,C,pc+1)
			//S.overlays -= 'debug_connect.dmi'
			//S.overlays += 'Zone.dmi'
			//T.overlays -= 'debug_connect.dmi'
			//T.overlays += 'Zone.dmi'
			if(!(S.HasDoor(1) || T.HasDoor(1)))
				direct_connections -= T.zone
				T.zone.direct_connections -= src
		if(!length(connections[T.zone]))
			connections -= T.zone
			T.zone.connections -= src
			T.zone.direct_connections -= src
			direct_connections -= T.zone

	Split(turf/X,turf/Y)
		//world << "Split: Check procedure passed."
		var/list/old_members = list()
		var/list/old_space_connections = list()
		var
			zone_X = list()
			space_X = list()
			zone_Y = list()
			space_Y = list()
		for(var/turf/simulated/T in members)
			old_members += T
			T.zone = null
		zone_X = FloodFill(X)
		if(Y in zone_X)
			members = old_members //No need to change.
			for(var/turf/simulated/T in members)
				T.zone = src
		else
			space_X = tmp_spaceconnections
			tmp_spaceconnections.len = 0
			//world << "Split: Floodfill procedure passed. Creating new zones."
			zone_Y = old_members - zone_X
			space_Y = old_space_connections - space_X
			new/zone(Y,oxygen / old_members.len,nitrogen / old_members.len,co2 / old_members.len,zone_Y,space_Y)
			new/zone(X,oxygen / old_members.len,nitrogen / old_members.len,co2 / old_members.len,zone_X,space_X)
			del src

	Merge(zone/Z)
		//world << "Merging..."
		oxygen += Z.oxygen
		nitrogen += Z.nitrogen
		co2 += Z.co2
		temp = (temp+Z.temp)/2
		members += Z.members
		volume += Z.volume
		connections += Z.connections
		space_connections += Z.space_connections
		merge_with += Z.merge_with
		for(var/turf/simulated/T in Z.members)
			T.zone = src
		//world << "Merged zones."
		direct_connections -= Z
		del Z
var/list/tmp_spaceconnections = list()
proc/FloodFill(turf/start)
	if(!istype(start,/turf/simulated)) return
	tmp_spaceconnections.len = 0 //Clear the space list in case it's still full of data.
	. = list()
	var/list/borders = list()
	borders += start
	while(borders.len)
		for(var/turf/simulated/T in borders)
			var/unblocked = T.GetUnblockedCardinals()
			for(var/turf/simulated/U in unblocked)
				if((U in borders) || (U in .)) continue
				borders += U
			for(var/turf/space/S in unblocked)
				tmp_spaceconnections += T
				break
			. += T
			//T.overlays += 'Zone.dmi'
			borders -= T
//proc/DoorFill(turf/start)
//	. = list()
//	var/list/borders = list()
//	borders += start
//	while(borders.len)
//		sleep(1)
//		for(var/turf/T in borders)
//			for(var/turf/U in T.GetDoorCardinals())
//				if((U in borders) || (U in .)) continue
//				borders += U
//				U.overlays += 'Confirm.dmi'
//			. += T
//			T.overlays -= 'Confirm.dmi'
//			T.overlays += 'Zone.dmi'
//			borders -= T
turf/var
	floodupdate = 1 //If 1, will reset unblocked_dirs on next call to GetUnblockedCardinals().
	unblocked_dirs = 0 //Archived unblocked directions.
	turf
		north
		south
		east
		west
		up
		down

turf/proc/SetCardinals()
	north = get_step(src,NORTH)
	south = get_step(src,SOUTH)
	east = get_step(src,EAST)
	west = get_step(src,WEST)

	up = get_step(src,UP)
	down = get_step(src,DOWN)

turf/proc/GetUnblockedCardinals()
	. = list()
	if(floodupdate)
		SetCardinals()

	if(!north.floodupdate && !floodupdate)
		if((unblocked_dirs & NORTH) && (north.unblocked_dirs & SOUTH))
			. += north
	else
		if(CanPass(null,north,0,1))
			. += north
			north.unblocked_dirs |= SOUTH
			unblocked_dirs |= NORTH
		else
			unblocked_dirs &= ~(NORTH)
			north.unblocked_dirs &= ~(SOUTH)

	if(!south.floodupdate && !floodupdate)
		if((unblocked_dirs & SOUTH) && (south.unblocked_dirs & NORTH))
			. += south
	else
		if(CanPass(null,south,0,1))
			. += south
			south.unblocked_dirs |= NORTH
			unblocked_dirs |= SOUTH
		else
			unblocked_dirs &= ~(SOUTH)
			south.unblocked_dirs &= ~(NORTH)

	if(!east.floodupdate && !floodupdate)
		if((unblocked_dirs & EAST) && (east.unblocked_dirs & WEST))
			. += east
	else
		if(CanPass(null,east,0,1))
			. += east
			east.unblocked_dirs |= WEST
			unblocked_dirs |= EAST
		else
			unblocked_dirs &= ~(EAST)
			east.unblocked_dirs &= ~(WEST)

	if(!west.floodupdate && !floodupdate)
		if((unblocked_dirs & WEST) && (north.unblocked_dirs & EAST))
			. += west
	else
		if(CanPass(null,west,0,1))
			. += west
			west.unblocked_dirs |= EAST
			unblocked_dirs |= WEST
		else
			unblocked_dirs &= ~(WEST)
			west.unblocked_dirs &= ~(EAST)

	if(up)
		if(!up.floodupdate && !floodupdate)
			if((unblocked_dirs & UP) && (up.unblocked_dirs & DOWN))
				. += up
		else
			if(CanPass(null,up,0,1))
				. += up
				up.unblocked_dirs |= DOWN
				unblocked_dirs |= UP
			else
				unblocked_dirs &= ~(UP)
				up.unblocked_dirs &= ~(DOWN)

	if(down)
		if(!down.floodupdate && !floodupdate)
			if((unblocked_dirs & DOWN) && (north.unblocked_dirs & UP))
				. += down
		else
			if(CanPass(null,down,0,1))
				. += down
				down.unblocked_dirs |= UP
				unblocked_dirs |= DOWN
			else
				unblocked_dirs &= ~(DOWN)
				down.unblocked_dirs &= ~(UP)
	floodupdate = 0

//turf/proc/GetDoorCardinals()
//	. = list()
//	north = get_step(src,NORTH)
//	south = get_step(src,SOUTH)
//	east = get_step(src,EAST)
//	west = get_step(src,WEST)
//	if(locate(/obj/machinery/door) in north) . += north
//	if(locate(/obj/machinery/door) in south) . += south
//	if(locate(/obj/machinery/door) in east) . += east
//	if(locate(/obj/machinery/door) in west) . += west

/*turf/verb/ZoneInfo()
	set src in view()
	world << "O2: [zone.oxygen()]/tile ([zone.oxygen])"
	world << "N2: [zone.nitrogen()]/tile ([zone.nitrogen])"
	world << "CO2: [zone.co2()]/tile ([zone.co2])"
	world << "Space Connections: [zone.space_connections.len]"
	world << "Zone Connections: [zone.connections.len]"
	world << "Direct Connections: [zone.direct_connections.len]"
	for(var/turf/simulated/T)
		T.overlays -= 'debug_group.dmi'
		T.overlays -= 'debug_space.dmi'
	for(var/turf/T in zone.members)
		T.overlays += 'debug_group.dmi'
	for(var/turf/T in zone.space_connections)
		T.overlays += 'debug_space.dmi'
	for(var/Z in zone.direct_connections)
		if(istype(Z,/zone))
			if(abs(zone.turf_oxy - Z:turf_oxy) < 0.2 && abs(zone.turf_nitro- Z:turf_nitro) < 0.2 && abs(zone.turf_co2 - Z:turf_co2) < 0.2)
				world << "Z[zones.Find(Z)] - Success"
			else
				world << "Z[zones.Find(Z)] - Failure"
		else
			world << "[Z] - N/A"*/

turf/proc
	HasDoor(window)
		for(var/obj/machinery/door/D in src)
			if(!window && istype(D,/obj/machinery/door)) continue
			if(D.density || window) return 1
		return 0
	add_to_other_zone()
		for(var/turf/simulated/T in orange(1,src))
			if(T.zone)
				T.zone.AddTurf(src)
				break
		if(!zone)
			new/zone(src)

proc/SplitCheck(turf/T)
	//T.overlays += ad_splitcheck
	var/blocks = 0
	if(T.HasDoor(1)) return
	T.SetCardinals()
	for(var/d in cardinal + list(5,7,9,10))
		var/turf/X = get_step(T,d)
		if(!X.CanPassOneWay(null,T,0,0))
			blocks |= d
	if( ( (blocks & NORTH) && (blocks & SOUTH) ) )
		if(T.east.CanPassOneWay(null,T,0,0) && T.west.CanPassOneWay(null,T,0,0) )
			if(istype(T.north,/turf/simulated) && istype(T.south,/turf/simulated))
				if((T.east.zone && T.west.zone) && T.east.zone == T.west.zone)
					T.east.zone.Split(T.east,T.west)
	if( ( (blocks & EAST) && (blocks & WEST) ) )
		if(T.north.CanPassOneWay(null,T,0,0) && T.south.CanPassOneWay(null,T,0,0) )
			if(istype(T.north,/turf/simulated) && istype(T.south,/turf/simulated))
				if((T.north.zone && T.south.zone) && T.north.zone == T.south.zone)
					T.north.zone.Split(T.north,T.south)

//var/icon
	//ad_splitcheck = new('debug_group.dmi',"check")
	//ad_update = new('debug_group.dmi',"update")
	//ad_process = new('debug_group.dmi',"process")

//mob/verb/ClearTags()
//	for(var/turf/T)
	//	T.overlays -= ad_splitcheck
//		T.overlays -= ad_update
//		T.overlays -= ad_process
