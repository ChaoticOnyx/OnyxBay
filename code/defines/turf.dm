/turf
	icon = 'floors.dmi'
	var/intact = 1

	level = 1.0

	var
		//Properties for open tiles (/floor)
		oxygen = 0
		carbon_dioxide = 0
		nitrogen = 0
		toxins = 0

		//Properties for airtight tiles (/wall)
		thermal_conductivity = 0.05
		heat_capacity = 1

		//Properties for both
		temperature = T20C

		blocks_air = 0
		icon_old = null
		pathweight = 1
		list/obj/machinery/network/wirelessap/wireless = list( )

/turf/space
	icon = 'space.dmi'
	name = "space"
	icon_state = "placeholder"

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

/turf/space/New()
	..()
	icon = 'space.dmi'
	icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"

/turf/simulated
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null

	var/thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000

/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0.001
	temperature = TCMB

/turf/simulated/floor/

/turf/simulated/floor
	name = "floor"
	icon = 'floors.dmi'
	icon_state = "floor"
	thermal_conductivity = 0.040
	heat_capacity = 225000
	var/broken = 0
	var/burnt = 0
	var/turf/simulated/floor/open/open = null

	New()
		..()
		var/turf/T = locate(x,y,z-1)
		if(T)
			if(T.type == /turf/simulated/floor/open)
				open = T

	Enter(var/atom/movable/AM)
		. = ..()
		spawn()
			if(open)
				open.update()

	airless
		name = "airless floor"
		oxygen = 0.01
		nitrogen = 0.01
		temperature = TCMB

		New()
			..()
			name = "floor"

	open
		name = "open space"
		intact = 0
		icon_state = "open"
		pathweight = 100000 //Seriously, don't try and path over this one numbnuts
		var/icon/darkoverlay = null
		var/turf/floorbelow

		New()
			..()
			spawn(1)
				floorbelow = locate(x, y, z + 1)
				if(ticker)
					add_to_other_zone()
				if(zone && floorbelow.zone)
					zone.Connect(src,floorbelow)
				update()
			var/turf/T = locate(x, y, z + 1)
			switch (T.type) //Somehow, I don't think I thought this cunning plan all the way through - Sukasa
				if (/turf/simulated/floor)
					//Do nothing - valid
				if (/turf/simulated/floor/plating)
					//Do nothing - valid
				if (/turf/simulated/floor/engine)
					//Do nothing - valid
				if (/turf/simulated/floor/engine/vacuum)
					//Do nothing - valid
				if (/turf/simulated/floor/airless)
					//Do nothing - valid
				if (/turf/simulated/floor/grid)
					//Do nothing - valid
				if (/turf/simulated/floor/plating/airless)
					//Do nothing - valid
				if (/turf/simulated/floor/open)
					//Do nothing - valid
				if (/turf/space)
					var/turf/space/F = new(src)									//Then change to a Space tile (no falling into space)
					F.name = F.name
					return
				else
					var/turf/simulated/floor/plating/F = new(src)				//Then change to a floor tile (no falling into unknown crap)
					F.name = F.name
					return
		Del()
			if(zone)
				zone.Disconnect(src,floorbelow)
			. = ..()


		Enter(var/atom/movable/AM)
			if (1) //TODO make this check if gravity is active (future use) - Sukasa
				spawn(1)
					AM.Move(locate(x, y, z + 1))
					if (istype(AM, /mob))
						AM:bruteloss += 5
						AM:updatehealth()
			return ..()

		proc
			update() //Update the overlays to make the openspace turf show what's down a level
				src.clearoverlays()
				src.addoverlay(floorbelow)

				for(var/obj/o in floorbelow.contents)
					src.addoverlay(image(o, dir=o.dir))
				if(istype(floorbelow,/turf/simulated))
					air.share(floorbelow:air)
					air.temperature_share(floorbelow:air,FLOOR_HEAT_TRANSFER_COEFFICIENT)
				else
					air.mimic(floorbelow,1)
					air.temperature_mimic(floorbelow,FLOOR_HEAT_TRANSFER_COEFFICIENT,1)

	plating
		name = "plating"
		icon_state = "plating"
		intact = 0



/proc/update_open()
	for(var/turf/simulated/floor/open/a in world)
		a.update()

/turf/simulated/floor/plating/airless
	name = "airless plating"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

	New()
		..()
		name = "plating"

/turf/simulated/floor/grid
	icon = 'floors.dmi'
	icon_state = "circuit"

/turf/simulated/wall/r_wall
	name = "r wall"
	icon = 'walls.dmi'
	icon_state = "r_wall"
	opacity = 1
	density = 1
	var/d_state = 0

/turf/simulated/wall
	name = "wall"
	icon = 'walls.dmi'
	opacity = 1
	density = 1
	blocks_air = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m steel wall


/turf/simulated/wall/heatshield
	thermal_conductivity = 0
	opacity = 0
	name = "heatshield"
	icon = 'thermal.dmi'
	icon_state = "thermal"


/turf/simulated/shuttle
	name = "shuttle"
	icon = 'shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0

/turf/simulated/shuttle/wall
	name = "wall"
	icon_state = "wall1"
	opacity = 1
	density = 1
	blocks_air = 1

/turf/simulated/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/unsimulated
	name = "command"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/unsimulated/floor
	name = "floor"
	icon = 'floors.dmi'
	icon_state = "Floor3"

/turf/unsimulated/wall
	name = "wall"
	icon = 'walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1

/turf/unsimulated/wall/other
	icon_state = "r_wall"

/turf/proc
	AdjacentTurfs()

		var/L[] = new()
		for(var/turf/simulated/t in oview(src,1))
			if(!t.density && !LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)

		return L
	Distance(turf/t)
		if(get_dist(src, t) == 1 || src.z != t.z)
			var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y) + (src.z - t.z) * (src.z - t.z) * 3
			cost *= (pathweight+t.pathweight)/2
			return cost
		else
			return max(get_dist(src,t), 1)
	AdjacentTurfsSpace()
		var/L[] = new()
		for(var/turf/t in oview(src,1))
			if(!t.density)
				if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
					L.Add(t)

		return L
