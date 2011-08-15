/*ZAS3 - Necessitated by the obfuscating nature of gooncode.*/

vs_control/var
	FLOW_PERCENT = 15 //Percent of gas to send between connected turfs.
	VACUUM_SPEED = 1.2 //Divisor of zone gases exposed directly to space (i.e. space tiles in members)

#define QUANTIZE(variable)		(round(variable,0.0001))
#define PLASMA_GFX 1
var/list/zones = list()
var/zone_update_delay = 5
var/stop_zones = 0

turf/var/zone/zone
turf/var/image/z_image

turf/simulated/var/disable_connections = 0

proc/ZoneSetup()
	world << "\red <b>Defining Zones...</b>"
	for(var/turf/simulated/S in world)
		if(S.HasDoor())
			spawn(1) S.add_to_other_zone()
		else
			if(S.CanPass(null,S,0,0) && !S.zone)
				new/zone(S)
	world << "\red <b>Zone Definition Complete.</b>"

zone
	var
		list/members

		turf/starting_tile

		oxygen = 0
		nitrogen = 0
		co2 = 0
		plasma = 0
		temp = T20C

		oxygen_archive = 0
		nitrogen_archive = 0
		co2_archive = 0
		plasma_archive = 0
		list/space_connections = list()

		temp_archive = T20C
		//graphic = ""
		shows_plasma = 0
		turf_oxy = 0
		turf_nitro = 0
		turf_co2 = 0
		turf_plasma = 0
		turf_other = 0
		//image/images
		volume = CELL_VOLUME
		pressure = ONE_ATMOSPHERE

		list/connections = list()
		list/direct_connections = list() //Zones with doors connecting them to us, so that we know not to merge.

		list/zone_space_connections = list()

		//list/merge_with = list()
		//list/edges = list()

		list/update_mixtures = list()

		needs_rebuild = 0

		disable_connections = 0

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
		plasma(n)
		add_oxygen(n) //Adds gas to the total.
		add_nitrogen(n)
		add_co2(n)
		add_plasma(n)
		rebuild_cache() //Recalculates turf_ values.
		update_members()
		update_visuals()
		AddTurf(turf/T) //Adds a turf to the zone, recalculates volume, and rebuilds the cache.
		RemoveTurf(turf/T) //Same, but removes a turf from the zone.

		AddSpace(turf/space/S)
		RemoveSpace(turf/space/S)
		UpdateSpace()

		pressure()
			return (oxygen+nitrogen+co2+plasma)*R_IDEAL_GAS_EQUATION*temp/volume

		total_moles()
			return (oxygen+nitrogen+co2+plasma)


		other_gas()
			for(var/turf/T in members)
				var/datum/gas_mixture/GM = T.return_air(1)
				//. += GM.toxins
				for(var/datum/gas/G in GM.trace_gases)
					. += G.moles

	//......................//

	New(turf/start,soxy = 0,snitro = 0,sco2 = 0, spla2 = 0,smembers,sspace)//,sedges)

		starting_tile = start

		if(!start.CanPass(null,start,0,1)) //Bug here.
			//world.log << "Zone created on [start] (airtight turf) at [start.x],[start.y],[start.z]."
			//world.log << "A gray overlays has been applied to show the location."
			//start.overlays += 'icons/Testing/turf_analysis.dmi'
			del src
			return 0

		zones += src //Add to the zone list
		if(smembers)
			members = smembers
			if(!sspace) sspace = list()
			space_connections = sspace
			//edges = sedges
		else
			tmp_spaceconnections.len = 0
			//tmp_edges.len = 0
			members = FloodFill(start) //Do a floodfill to get new members.
			if(ticker)
				space_connections = tmp_spaceconnections.Copy()
				tmp_spaceconnections.len = 0
			//edges = tmp_edges.Copy()
			//tmp_edges.len = 0

		if(!members.len) //Bug here.
			//world << "Zone created with no members at [start.x],[start.y],[start.z]."
			//world << "A gray overlays has been applied to show the location."
			//start.overlays += 'icons/Testing/turf_analysis.dmi'
			del src
			return 0

		for(var/turf/simulated/T in members)
			T.zone = src
			if(T.disable_connections)
				disable_connections = 1
		if(!ticker) //If this zone was created at startup, add gases.
			if(start.oxygen != MOLES_O2STANDARD || start.nitrogen != MOLES_N2STANDARD || start.carbon_dioxide)
				oxygen = start.oxygen*members.len
				nitrogen = start.nitrogen*members.len
				co2 = start.carbon_dioxide*members.len
			else if(istype(start,/turf/simulated/floor/airless) || istype(start,/turf/simulated/floor/engine/vacuum) || istype(start,/turf/simulated/floor/plating/airless))
				oxygen = 0
				nitrogen = 0.0001
				co2 = 0
			else
				oxygen = MOLES_O2STANDARD * members.len
				nitrogen = MOLES_N2STANDARD * members.len
		else if(soxy > 0 || snitro > 0 || sco2 > 0 || spla2 > 0)
			oxygen = soxy * members.len
			nitrogen = snitro * members.len
			co2 = sco2 * members.len
			plasma = spla2 * members.len
		volume = members.len * CELL_VOLUME

		spawn Update() //Call the update cycle.

		//.....................//

	Del()
		zones -= src
		. = ..()

	Update()
		while(1)
			sleep(vsc.zone_update_delay * tick_multiplier)
			if(stop_zones) continue
			if(!members.len) del src

			for(var/datum/gas_mixture/G in update_mixtures)
				add_oxygen(G.oxygen - G.zone_oxygen)
				add_nitrogen(G.nitrogen - G.zone_nitrogen)
				add_co2(G.carbon_dioxide - G.zone_co2)
				add_plasma(G.toxins - G.zone_plasma)
				update_mixtures -= G

			if(oxygen_archive != oxygen || nitrogen_archive != nitrogen || co2_archive != co2 || plasma_archive != plasma)
				turf_oxy = oxygen / members.len
				turf_nitro = nitrogen / members.len
				turf_co2 = co2 / members.len
				turf_plasma = plasma / members.len
				pressure = pressure()

			oxygen = max(0,oxygen)
			nitrogen = max(0,nitrogen)
			co2 = max(0,co2)
			plasma = max(0,plasma)

			oxygen_archive = oxygen		 //Update the archives, so we can do things like calculate delta.
			nitrogen_archive = nitrogen
			co2_archive = co2
			temp_archive = temp
			plasma_archive = plasma
			for(var/turf/T in space_connections)
				//if(!istype(T,/turf/space) && !istype(T,/turf/space/hull))
				if(!istype(T,/turf/space))
					RemoveSpace(T)

			for(var/Z in zone_space_connections)
				if(!istype(Z,/zone)) zone_space_connections -= Z
				else if(!Z:space_connections.len) zone_space_connections -= Z

			if(space_connections.len || zone_space_connections.len)				 //Throw gas into space if it has space connections.
				oxygen = QUANTIZE(oxygen/vsc.VACUUM_SPEED)
				nitrogen = QUANTIZE(nitrogen/vsc.VACUUM_SPEED)
				co2 = QUANTIZE(co2/vsc.VACUUM_SPEED)
				plasma = QUANTIZE(plasma/vsc.VACUUM_SPEED)
				//temp = min(TCMB,temp/vsc.VACUUM_SPEED)
				for(var/turf/simulated/M in members)
					var/datum/gas_mixture/GM = M.return_air(1)
					GM.remove_ratio(1/vsc.VACUUM_SPEED)
				spawn AirflowSpace(src)
			//merge_with.len = 0
			//if(pressure > 225)
			//	for(var/turf/T in edges)
			//		for(var/obj/window/W in T)
			//			if(prob(25))
			//				W.ex_act(pick(2,3))
			//				W.visible_message("\red A window bursts from the pressure!",1,"\red You hear glass breaking.")
			if(!disable_connections)
				for(var/zone/Z in direct_connections)
					if(abs(turf_oxy - Z.turf_oxy) < 0.2 && abs(turf_nitro- Z.turf_nitro) < 0.2 && abs(turf_co2 - Z.turf_co2) < 0.2 && abs(turf_plasma - Z.turf_plasma) < 0.2)
						Merge(Z)
				for(var/zone/Z in connections)
					if(Z == src) connections -= Z

					var/list/borders = connections[Z] //Get the list of border tiles.

					if(!istype(borders,/list))
						connections -= Z
						continue
					var/percent_flow = max(90,vsc.FLOW_PERCENT*borders.len) //This is the percentage of gas that will flow.

					spawn
						if(Z) Airflow(src,Z,pressure-Z.pressure)


					//Magic Happens Here
					var
						oxy_avg = (oxygen + Z.oxygen) / (members.len + Z.members.len)
						nit_avg = (nitrogen + Z.nitrogen) / (members.len + Z.members.len)
						co2_avg = (co2 + Z.co2) / (members.len + Z.members.len)
						plasma_avg = (plasma + Z.plasma) / (members.len + Z.members.len)

					turf_oxy = (turf_oxy - oxy_avg) * (1-percent_flow/100) + oxy_avg
					turf_nitro = (turf_nitro - nit_avg) * (1-percent_flow/100) + nit_avg
					turf_co2 = (turf_co2 - co2_avg) * (1-percent_flow/100) + co2_avg
					turf_plasma = (turf_plasma - plasma_avg) * (1-percent_flow/100) + plasma_avg

					oxygen = turf_oxy * members.len
					nitrogen = turf_nitro * members.len
					co2 = turf_co2 * members.len
					plasma = turf_plasma * members.len

					Z.turf_oxy = (Z.turf_oxy - oxy_avg) * (1-percent_flow/100) + oxy_avg
					Z.turf_nitro = (Z.turf_nitro - nit_avg) * (1-percent_flow/100) + nit_avg
					Z.turf_co2 = (Z.turf_co2 - co2_avg) * (1-percent_flow/100) + co2_avg
					Z.turf_plasma = (Z.turf_plasma - plasma_avg) * (1-percent_flow/100) + plasma_avg

					Z.oxygen = Z.turf_oxy * Z.members.len
					Z.nitrogen = Z.turf_nitro * Z.members.len
					Z.co2 = Z.turf_co2 * Z.members.len
					Z.plasma = Z.turf_plasma * Z.members.len

					//End Magic

				for(var/crap in connections) //Clean out invalid connections.
					if(!istype(crap,/zone))
						connections -= crap
			if(turf_plasma > MOLES_PLASMA_VISIBLE)
				if(!shows_plasma)
					shows_plasma = 1
					for(var/turf/A in members)
						A.z_image = image('tile_effects.dmi',A,"plasma")
						world << A.z_image
			else
				if(shows_plasma)
					shows_plasma = 0
					for(var/turf/A in members)
						del A.z_image
	oxygen(n)
		if(!n) return turf_oxy
		else
			turf_oxy = max(0,n)
			oxygen = max(0,turf_oxy*members.len)
	nitrogen(n)
		if(!n) return turf_nitro
		else
			turf_nitro = max(0,n)
			nitrogen = max(0,turf_nitro*members.len)
	co2(n)
		if(!n) return turf_co2
		else
			turf_co2 = max(0,n)
			co2 = max(0,turf_co2*members.len)
	plasma(n)
		if(!n) return turf_plasma
		else
			turf_plasma = max(0,n)
			plasma = max(0,turf_plasma*members.len)

	add_oxygen(n)
		if(n < 0 && oxygen < abs(n))
			. = oxygen
			oxygen = 0
		else
			oxygen += n
			oxygen = max(0,oxygen)
			. = abs(n)
	add_nitrogen(n)
		if(n < 0 && nitrogen < abs(n))
			. = nitrogen
			nitrogen = 0
		else
			nitrogen += n
			nitrogen = max(0,nitrogen)
			. = abs(n)
	add_co2(n)
		if(n < 0 && co2 < abs(n))
			. = co2
			co2 = 0
		else
			co2 += n
			co2 = max(0,co2)
			. = abs(n)
	add_plasma(n)
		if(n < 0 && plasma < abs(n))
			. = plasma
			plasma = 0
		else
			plasma += n
			plasma = max(0,plasma)
			. = abs(n)
	AddTurf(turf/T)
		if(T.zone) return
		if(stop_zones)
			needs_rebuild = 1
			return
		members += T
		T.zone = src
		for(var/turf/space/S in T.GetUnblockedCardinals())
			AddSpace(S)
		volume = CELL_VOLUME*members.len
		if(!ticker)
			oxygen += MOLES_O2STANDARD
			nitrogen += MOLES_N2STANDARD
		rebuild_cache()
		update_members()
	RemoveTurf(turf/T)
		if(T.zone != src) return
		if(stop_zones)
			needs_rebuild = 1
			return
		members -= T
		T.zone = null
		for(var/turf/space/S in T.GetBasicCardinals())
			RemoveSpace(S)
		volume = CELL_VOLUME*members.len
		rebuild_cache()
		update_members()
		if(ticker)
			spawn(1 * tick_multiplier) SplitCheck(T)

	AddSpace(turf/space/S)
		if(S in space_connections) return
		space_connections += S
		for(var/zone/Z in connections)
			if(!(src in Z.zone_space_connections))
				Z.zone_space_connections += src
			Z.zone_space_connections[src] = space_connections.len

	UpdateSpace()
		for(var/zone/Z in connections)
			if(!space_connections.len)
				if(!space_connections.len)
					Z.zone_space_connections -= src
				else
					Z.zone_space_connections[src] = space_connections.len
			else
				if(!(src in Z.zone_space_connections))
					Z.zone_space_connections += src
				Z.zone_space_connections[src] = space_connections.len

	RemoveSpace(turf/space/S)
		if(!(S in space_connections)) return
		space_connections -= S
		for(var/zone/Z in connections)
			if(!(src in Z.zone_space_connections))
				continue
			if(!space_connections.len)
				Z.zone_space_connections -= src
			else
				Z.zone_space_connections[src] = space_connections.len


//	update_members()
		//for(var/turf/T in members)
			//var/datum/gas_mixture/GM = T.return_air()
		//	GM.oxygen = oxygen()
		//	GM.nitrogen = turf_nitro
		//	GM.carbon_dioxide = turf_co2

	Connect(turf/S,turf/T,pc)
		if(!istype(T,/turf/simulated)) return
		if(!T.zone || !S.zone) return
		if(T.zone == src)
			var/turf/U = S
			S = T
			T = U
		if(S.zone == T.zone) return
		if(!S.CanPass(null,T,0,0)) return //Ensure consistency in airflow.
		if(!(T.zone in connections) && !(src in T.zone.connections))
			connections += T.zone
			T.zone.connections += src
			connections[T.zone] = list()
			T.zone.connections[src] = list()
			if(space_connections)
				if(!(src in T.zone.zone_space_connections))
					T.zone.zone_space_connections += src
				T.zone.zone_space_connections[src] = space_connections.len
			if(T.zone.space_connections)
				if(!(T.zone in zone_space_connections))
					zone_space_connections += T.zone
				zone_space_connections[T.zone] = T.zone.space_connections.len

		if(!(T in connections[T.zone]) && !(S in T.zone.connections[src]))
			connections[T.zone] += T
			T.zone.connections[src] += S
			if(!(S.HasDoor(1) || T.HasDoor(1)))
				direct_connections += T.zone
				T.zone.direct_connections += src

	Disconnect(turf/S,turf/T)
		if(!istype(T,/turf/simulated)) return
		if(!T.zone || !S.zone) return
		if(T.zone == src)
			var/turf/U = S
			S = T
			T = U
		if((T in connections[T.zone]) && (S in T.zone.connections[src]))
			connections[T.zone] -= T
			T.zone.connections[src] -= S
			direct_connections -= T.zone
			T.zone.direct_connections -= src
		if(!length(connections[T.zone]))
			connections -= T.zone
			T.zone.connections -= src
			T.zone.direct_connections -= src
			direct_connections -= T.zone
		T.zone.zone_space_connections -= src
		zone_space_connections -= T.zone

	Split(turf/X,turf/Y)
		if(disable_connections) return
		if(stop_zones) return
		var/list
			old_members = list()
			old_space_connections = list()
			//old_edges = list()
		var
			zone_X = list()
			space_X = list()
			edge_X = list()
			zone_Y = list()
			space_Y = list()
			edge_Y = list()
		for(var/turf/simulated/T in members)
			old_members += T
			T.zone = null
		old_space_connections = space_connections
		//old_edges = edges
		zone_X = FloodFill(X)
		if(Y in zone_X)
			members = old_members //No need to change.
			for(var/turf/simulated/T in old_members)
				T.zone = src
		else
			space_X = tmp_spaceconnections.Copy()
			tmp_spaceconnections.len = 0
			//edge_X = tmp_edges.Copy()
			//tmp_edges.len = 0
			zone_Y = old_members - zone_X
			space_Y = old_space_connections - space_X
			new/zone(Y,oxygen / old_members.len,nitrogen / old_members.len,co2 / old_members.len,plasma / old_members.len,zone_Y,space_Y,edge_Y)
			new/zone(X,oxygen / old_members.len,nitrogen / old_members.len,co2 / old_members.len,plasma / old_members.len,zone_X,space_X,edge_X)
			del src

	Merge(zone/Z)
		if(stop_zones) return
		if(disable_connections) return
		oxygen += Z.oxygen
		nitrogen += Z.nitrogen
		co2 += Z.co2
		plasma += Z.plasma
		members += Z.members
		volume += Z.volume
		connections += Z.connections
		space_connections += Z.space_connections
		//edges += Z.edges
		for(var/turf/simulated/T in Z.members)
			T.zone = src
		direct_connections -= Z
		connections -= Z
		del Z
		sleep(1)
		UpdateSpace()

var/list/tmp_spaceconnections = list()
//var/list/tmp_edges = list()
proc/FloodFill(turf/start,remove_extras)
	if(!istype(start,/turf/simulated)) return
	tmp_spaceconnections.len = 0 //Clear the space list in case it's still full of data.
	//tmp_edges.len = 0
	. = list()
	var/list/borders = list()
	borders += start
	while(borders.len)
		for(var/turf/simulated/T in borders)
			if(T.HasDoor())
				. += T
				borders -= T
				//tmp_edges += T
				continue
			var/unblocked = T.GetUnblockedCardinals()

			for(var/turf/simulated/U in unblocked)
				if((U in borders) || (U in .)) continue
				borders += U
			if(!remove_extras)
				for(var/turf/space/S in unblocked)
					tmp_spaceconnections += S
			. += T
			borders -= T

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

proc/GetAirCardinals(turf/T)
	var/density_list = list()
	for(var/obj/O in T)
		if(istype(O,/obj/machinery/door))
			density_list += O
			density_list[O] = O.density
			O.density = 0
	. = list()
	for(var/d in cardinal)
		var/turf/simulated/U = get_step(T,d)
		if(!istype(U)) continue
		if(U.CanPass(null,T,0,0))
			. += U
	for(var/obj/O in density_list)
		O.density = density_list[O]

turf/proc/GetBasicCardinals()
	. = list()
	for(var/direction in cardinal)
		var/turf/T = get_step(src,direction)
		. += T

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
			if(CanPass(null,up,0,1) && !istype(up,/turf/space))
				. += up
				up.unblocked_dirs |= DOWN
				unblocked_dirs |= UP
			else
				unblocked_dirs &= ~(UP)
				up.unblocked_dirs &= ~(DOWN)

	if(down)
		if(!down.floodupdate && !floodupdate)
			if((unblocked_dirs & DOWN) && (down.unblocked_dirs & UP))
				. += down
		else
			if(CanPass(null,down,0,1) && !istype(down,/turf/space))
				. += down
				down.unblocked_dirs |= UP
				unblocked_dirs |= DOWN
			else
				unblocked_dirs &= ~(DOWN)
				down.unblocked_dirs &= ~(UP)
	floodupdate = 0

var/zone_debug_verbs = 0

turf/proc/ZoneInfo()
	set src in view()
	usr << "Zone #[zones.Find(zone)]"
	usr << "Members: [zone.members.len]"
	usr << "O2: [zone.turf_oxy]/tile ([zone.oxygen])"
	usr << "N2: [zone.turf_nitro]/tile ([zone.nitrogen])"
	usr << "CO2: [zone.turf_co2]/tile ([zone.co2])"
	usr << "Plasma: [zone.turf_plasma]/tile ([zone.plasma])"
	usr << "Space Connections: [zone.space_connections.len]"
	usr << "Zone Connections: [zone.connections.len]"
	usr << "Direct Connections: [zone.direct_connections.len]"
	usr << "Indirect Space Connections: [zone.zone_space_connections.len]"
	for(var/turf/simulated/T)
		T.overlays -= 'debug_group.dmi'
		T.overlays -= 'debug_space.dmi'
		T.overlays -= 'debug_connect.dmi'
	for(var/turf/T in zone.members)
		T.overlays += 'debug_group.dmi'
	for(var/turf/T in zone.space_connections)
		T.overlays += 'debug_space.dmi'
		usr << "Space connection located: [T.x],[T.y],[T.z]"
		usr << "Turf: [T]"
	for(var/Z in zone.connections)
		if(istype(Z,/zone))
			usr << "Z[zones.Find(Z)] - Connected"
			var/turflist = zone.connections[Z]
			for(var/turf/T in turflist)
				T.overlays += 'debug_connect.dmi'
		else
			usr << "Not A Zone: [Z]"
	for(var/Z in zone.direct_connections)
		if(istype(Z,/zone))
			if(abs(zone.turf_oxy - Z:turf_oxy) < 0.2 && abs(zone.turf_nitro- Z:turf_nitro) < 0.2 && abs(zone.turf_co2 - Z:turf_co2) < 0.2)
				usr << "Z[zones.Find(Z)] - Success"
			else
				usr << "Z[zones.Find(Z)] - Failure"
		else
			usr << "[Z] - N/A"

	usr << "Connection Info:"
	for(var/d in cardinal)
		var/turf/C = get_step(src,d)
		usr << "Direction [d]: [CanPass(null,C,0,0)] Normal, [CanPass(null,C,0,1)] AirGroup, [CanPass(usr,C,1.5,0)] Mover"

client/proc/Zone_Info(turf/T as null|turf)
	set category = "Debug"
	if(T)
		T.ZoneInfo()
	else
		for(T in world)
			T.overlays -= 'debug_space.dmi'
			T.overlays -= 'debug_group.dmi'

turf/proc
	HasDoor(window)
		for(var/obj/machinery/door/D in src)
			if(!window && istype(D,/obj/machinery/door/window)) continue
			if(D.density || window) return 1
		return 0
	add_to_other_zone()
		for(var/turf/simulated/T in GetAirCardinals(src))
			if(T.zone)
				T.zone.AddTurf(src)
				break
		if(!zone)
			new/zone(src)

proc/SplitCheck(turf/T)
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
	var/turf
		D = get_step(T,DOWN)
	if(D)
		if(!istype(T,/turf/simulated/floor/open))
			if(T.zone && D.zone)
				if(D.zone == T.zone)
					T.zone.Split(T,D)

proc/RebuildAll()
	stop_zones = 0
	for(var/zone/Z in zones)
		if(Z.needs_rebuild)
			var/turf/T = Z.starting_tile
			del Z
			spawn(1 * tick_multiplier)
				new/zone(T)
		sleep(-1)