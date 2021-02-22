// Teleport Suppressor
/turf/proc/check_unallow_suppressor_flag(var/flag, var/warning_message)
	for(var/obj/machinery/power/vortex_suppressor/VS in world)
		if(VS.check_flag(flag) && VS.running)
			var/turf/VS_turf = get_turf(VS)
			if(z == VS_turf.z)
				if(x in VS_turf.x - VS.suppressor_radius to VS_turf.x + VS.suppressor_radius)
					if(y in VS_turf.y - VS.suppressor_radius to VS_turf.y + VS.suppressor_radius)
						to_chat(usr, SPAN_WARNING(warning_message))
						return 1

/turf/proc/check_unallow_incoming()
	return check_unallow_suppressor_flag(MODEFLAG_VORTEX_SUPPRESSOR_INCOMING, "Your manipulator does not teleport you in this location!")

/turf/proc/check_unallow_outgoing()
	return check_unallow_suppressor_flag(MODEFLAG_VORTEX_SUPPRESSOR_OUTGOING, "Your manipulator does not work in this area!")