connection
	var
		turf //The turfs involved in the connection.
			A
			B
		indirect = 0 //If the connection is purely indirect, the zones should not join.
		last_updated //The tick at which this was last updated.
	New(turf/T,turf/O)
		A = T
		B = O
		if(A.zone)
			if(!A.zone.connections) A.zone.connections = new()
			A.zone.connections += src
		if(B.zone)
			if(!B.zone.connections) B.zone.connections = new()
			B.zone.connections += src
	Del()
		if(A.zone)
			A.zone.connections -= src
		if(B.zone)
			B.zone.connections -= src
		. = ..()

	proc/Cleanup()
		if(A.zone == B.zone) del src
		if(!A.zone || !B.zone) del src