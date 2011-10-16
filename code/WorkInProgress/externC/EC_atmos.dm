// functions used to get and set the amount of air in a turf

// has to be called at start, allocates the given map in the simulation
//proc/setDimensions(x,y,z)

turf/proc/select() // make the given turf the active one
proc/setGas(name, amount)
proc/addGas(name, amount)
proc/remGas(name, amount)
proc/getGas(name)
proc/getTotalGas()

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


mob/verb/test()
	var/start = world.timeofday
	for(var/turf/simulated/T in world)
		world << "[T.x],[T.y],[T.z]"
		world << T.select()
		world << "a"
		call("BS12DLL.dll","setDefaultAtmosphere")()
		world << "b"
		if(T.density)
			call("BS12DLL.dll","setDensity")()
			world << "c"
	world << "DONE"
	world << world.timeofday - start

proc/setDimensions(x, y, z)
	var/success = call("BS12DLL.dll","allocateMap")(num2text(x), num2text(y), num2text(z))
	if(success != "success")
		world << "<b>FATAL ERROR during C map allocation."

turf/select()
	call("BS12DLL.dll","setTile")(num2text(x), num2text(y), num2text(z))

setGas(name, amount)
	call("BS12DLL.dll","setGas")(name, num2text(amount))

addGas(name, amount)
	call("BS12DLL.dll","setGas")(name, num2text(amount))

getGas(name)
	var/result = call("BS12DLL.dll","getGas")(name)
	return text2num(result)

getTotalGas()
	var/result = call("BS12DLL.dll","getTotalGas")()
	return text2num(result)


world/New()
	setDimensions(world.maxx, world.maxy, world.maxz)
	..()