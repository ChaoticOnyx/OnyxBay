/atom/var/pressure_resistance = ONE_ATMOSPHERE
/atom/var/can_atmos_pass = ATMOS_PASS_YES

// Purpose: Determines if the object can pass this atom.
// Called by: Movement.
// Inputs: The moving atom, target turf.
// Outputs: Boolean if can pass.
// Airflow and ZAS zones now uses CanZASPass() instead of this proc.
/atom/proc/CanPass(atom/movable/mover, turf/target)
	return !density

// Purpose: Determines if airflow is allowed between T and loc.
// Called by: Airflow.
// Inputs: The turf the airflow is from, which may not be the same as loc. is_zone is for conditionally disallowing merging.
// Outputs: Boolean if airflow can pass.
/atom/proc/CanZASPass(turf/T, is_zone)
	// Behaviors defined here so when people directly call c_airblock it will still obey can_atmos_pass
	switch(can_atmos_pass)
		if(ATMOS_PASS_YES)
			return TRUE
		if(ATMOS_PASS_NO)
			return FALSE
		if(ATMOS_PASS_DENSITY)
			return !density
		if(ATMOS_PASS_PROC)
			// Cowardly refuse to recursively self-call CanZASPass. The hero BYOND needs?
			CRASH("can_atmos_pass = ATMOS_PASS_PROC but CanZASPass not overridden on [src] ([type])")
		else
			CRASH("Invalid can_atmos_pass = [can_atmos_pass] on [src] ([type])")

/turf/CanPass(atom/movable/mover, turf/target)
	if(!target)
		return FALSE
	if(istype(mover)) // turf/Enter(...) will perform more advanced checks
		return !density

/turf/CanZASPass(turf/T, is_zone)
	if(T.blocks_air || src.blocks_air)
		return FALSE
	for(var/obj/obstacle in src)
		if(!obstacle.CanZASPass(T, is_zone))
			return FALSE
	if(T != src)
		for(var/obj/obstacle in T)
			if(!obstacle.CanZASPass(src, is_zone))
				return FALSE
	return TRUE

//Convenience function for atoms to update turfs they occupy
/atom/movable/proc/update_nearby_tiles(need_rebuild)
	for(var/turf/simulated/turf in locs)
		SSair.mark_for_update(turf)
		turf.liquid_update_turf()

	return 1
