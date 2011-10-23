#define QUANTIZE(variable)		(round(variable,0.0001))
var/explosion_halt = 0
zone
	proc/process()
		if(rebuild)
			var
				turf/sample = pick(contents)
				list/new_contents = FloodFill(sample)
				problem = 0
			for(var/turf/T in contents)
				if(!(T in new_contents))
					problem = 1

			if(problem)
				var/list/rebuild_turfs = list()
				for(var/turf/T in contents - new_contents)
					contents -= T
					rebuild_turfs += T
					T.zone = null
				for(var/turf/T in rebuild_turfs)
					if(!T.zone)
						var/datum/gas_mixture/copy_air = new
						copy_air.copy_from(air)
						new/zone(T,copy_air)
			rebuild = 0

		if(space_tiles)
			for(var/T in space_tiles)
				if(!istype(T,/turf/space)) space_tiles -= T
			if(space_tiles.len)
				air.temperature_mimic(space_tiles[1],OPEN_HEAT_TRANSFER_COEFFICIENT,space_tiles.len)
				air.remove(MOLES_CELLSTANDARD * 0.5 * space_tiles.len)
				if(dbg_output) world << "Space removed [MOLES_CELLSTANDARD*0.25 * space_tiles.len] moles of air."

		var/check = air.check_tile_graphic()
		for(var/turf/T in contents)
			if(T.zone && T.zone != src)
				RemoveTurf(T)
				if(dbg_output) world << "Removed invalid turf."
			else if(!T.zone)
				T.zone = src

			if(istype(T,/turf/simulated))
				var/turf/simulated/S = T
				if(check)
					if(S.HasDoor(1))
						S.update_visuals()
					else
						S.update_visuals(air)

				if(air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
					for(var/atom/movable/item in S)
						item.temperature_expose(air, air.temperature, CELL_VOLUME)
					S.temperature_expose(air, air.temperature, CELL_VOLUME)
		air.graphic_archived = air.graphic

		if(length(connections))
			for(var/connection/C in connections)
				C.Cleanup()
			for(var/zone/Z in connected_zones)
				air.share_ratio(Z.air,connected_zones[Z]*(vsc.zone_share_percent/100))


zone/proc
	connected_zones()
		. = list()
		for(var/connection/C in connections)
			var/zone/Z
			if(C.A.zone == src)
				Z = C.B.zone
			else
				Z = C.A.zone

			if(Z in .)
				.[Z]++
			else
				. += Z
				.[Z] = 1