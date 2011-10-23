client/proc/Zone_Info(turf/T as null|turf)
	set category = "Debug"
	if(T)
		if(T.zone)
			T.zone.DebugDisplay(mob)
		else
			mob << "No zone here."
	else
		for(T in world)
			T.overlays -= 'debug_space.dmi'
			T.overlays -= 'debug_group.dmi'
			T.overlays -= 'debug_connect.dmi'

zone/proc
	DebugDisplay(mob/M)
		if(!dbg_output)
			dbg_output = 1
			for(var/turf/T in contents)
				T.overlays += 'debug_group.dmi'

			for(var/turf/space/S in space_tiles)
				S.overlays += 'debug_space.dmi'

			M << "<u>Zone Air Contents</u>"
			M << "Oxygen: [air.oxygen]"
			M << "Nitrogen: [air.nitrogen]"
			M << "Plasma: [air.toxins]"
			M << "Carbon Dioxide: [air.carbon_dioxide]"
			M << "Temperature: [air.temperature]"
			M << "Heat Energy: [air.thermal_energy()]"
			M << "Pressure: [air.return_pressure()]"
			M << ""
			M << "<u>Connections: [length(connections)]</u>"

			for(var/connection/C in connections)
				M << "[C.A] --> [C.B] [(C.indirect?"Indirect":"Direct")]"
				C.A.overlays += 'debug_connect.dmi'
				C.B.overlays += 'debug_connect.dmi'
				/*C.A.overlays += 'zone_connection_A.dmi'
				C.B.overlays += 'zone_connection_B.dmi'
				spawn(50)
					C.A.overlays -= 'zone_connection_A.dmi'
					C.B.overlays -= 'zone_connection_B.dmi'*/

		else
			dbg_output = 0

			for(var/turf/T in contents)
				T.overlays -= 'debug_group.dmi'

			for(var/turf/space/S in space_tiles)
				S.overlays -= 'debug_space.dmi'
