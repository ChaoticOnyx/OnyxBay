// functions used to get and set the amount of air in a turf

// has to be called at start, allocates the given map in the simulation
//proc/setDimensions(x,y,z)

turf/proc/select() // make the given turf the active one
turf/proc/setGas(name, amount)
turf/proc/addGas(name, amount)
turf/proc/remGas(name, amount)
turf/proc/getGas(name)
turf/proc/getTotalGas()

turf/proc/getAirflow() // returns a string representing the strength and direction of airflow
turf/proc/C_reset()    // resets all the C data

// updates the turf's flags in the C simulation
// each turf in the C simulation has a set of flags that represent how they're affected by airflow
// flags include:
// air-density: 6 flags that represent whether air flows from north,south,east,west,up,down to the local tile
// objects:     1 flag, set to 1 only if there's objects on the tile that could be moved by airflow
// space:       1 flag, if this flag is unset, air moving into this tile will disappear(space is default)
turf/proc/updateFlags()

proc/getEvent() // returns an event that describes something that happened in the C simulation
proc/EC_tick()  // invokes a simulation step in the C process

// describes an event as returned by getEvent()
datum/EC_event

// airflow event
datum/EC_event/airflow_push/var/dir
datum/EC_event/airflow_push/var/power

turf/simulated/Entered(atom/movable/M)
	..()
	if(!istype(M,/obj) || !M:anchored)
		call("BS12DLL.dll","setDensity")("setObject")

turf/simulated/Exited()
	..()
	var/hasobj = 0
	for(var/obj/O in src) if(!O.anchored)
		hasobj = 1
	if(!hasobj)
		src.select()
		call("BS12DLL.dll","setDensity")("unsetObject")

mob/verb/test()
	var/start = world.timeofday
	var/i = 0
	for(var/turf/simulated/T in world)
		i++
		T.select()
		T.SetCardinals()
		call("BS12DLL.dll","setDefaultAtmosphere")()
		if(T.blocks_air)
			call("BS12DLL.dll","setDensity")("all")
		else
			call("BS12DLL.dll","setDensity")("none")
			if(!T.north || !T.CanPass(null,T.north,0,1))
				call("BS12DLL.dll","setDensity")("NORTH")
			if(!T.south || !T.CanPass(null,T.south,0,1))
				call("BS12DLL.dll","setDensity")("SOUTH")
			if(!T.west || !T.CanPass(null,T.west,0,1))
				call("BS12DLL.dll","setDensity")("WEST")
			if(!T.east || !T.CanPass(null,T.east,0,1))
				call("BS12DLL.dll","setDensity")("EAST")
			if(!T.up || !T.CanPass(null,T.up,0,1))
				call("BS12DLL.dll","setDensity")("UP")
			if(!T.down || !T.CanPass(null,T.down,0,1))
				call("BS12DLL.dll","setDensity")("DOWN")

		var/hasobj = 0
		for(var/obj/O in T) if(!O.anchored)
			hasobj = 1
		if(hasobj) call("BS12DLL.dll","setObject")("")

	world << i
	world << world.timeofday - start
	world << "DONE"
	call("BS12DLL.dll","tick")()

proc/setDimensions(x, y, z)
	var/success = call("BS12DLL.dll","allocateMap")(num2text(x), num2text(y), num2text(z))
	if(success != "success")
		world << "<b>FATAL ERROR during C map allocation."

turf/select()
	var/result = call("BS12DLL.dll","setTile")(num2text(x), num2text(y), num2text(z))
	if(result)
		world << result

turf/setGas(name, amount)
	src.select()
	call("BS12DLL.dll","setGas")(name, num2text(amount))

turf/addGas(name, amount)
	src.select()
	call("BS12DLL.dll","setGas")(name, num2text(amount))

turf/getGas(name)
	src.select()
	var/result = call("BS12DLL.dll","getGas")(name)
	return text2num(result)

turf/getTotalGas()
	src.select()
	var/result = call("BS12DLL.dll","getTotalGas")()
	return text2num(result)


world/New()
	setDimensions(world.maxx, world.maxy, world.maxz)
	..()