//#define ZASDBG
#define MULTIZAS

#define AIR_BLOCKED 1
#define ZONE_BLOCKED 2
#define BLOCKED 3

#define ZONE_MIN_SIZE 14 //zones with less than this many turfs will always merge, even if the connection is not direct

// Used for quickly making certain things allow airflow or not.
// More complicated, conditional airflow should override CanZASPass().
#define ATMOS_PASS_YES      1 // Always blocks air and zones.
#define ATMOS_PASS_NO       2 // Never blocks air or zones.
#define ATMOS_PASS_DENSITY  3 // Blocks air and zones if density = 1, allows both if density = 0
#define ATMOS_PASS_PROC     4 // Call CanZASPass()

#define NORTHUP (NORTH|UP)
#define EASTUP (EAST|UP)
#define SOUTHUP (SOUTH|UP)
#define WESTUP (WEST|UP)
#define NORTHDOWN (NORTH|DOWN)
#define EASTDOWN (EAST|DOWN)
#define SOUTHDOWN (SOUTH|DOWN)
#define WESTDOWN (WEST|DOWN)

#define TURF_HAS_VALID_ZONE(T) (istype(T, /turf/simulated) && T:zone && !T:zone:invalid)
#define SHOULD_PARTICIPATE_IN_ZONES(T) (isturf(T) && T:zone_membership_candidate && (!T:external_atmosphere_participation || !T:is_outside()))

#define ATMOS_CANPASS_MOVABLE(ret, AM, TARG_TURF) \
	switch (AM.can_atmos_pass) { \
		if (ATMOS_PASS_DENSITY) { \
			if (AM.density) { \
				ret |= AIR_BLOCKED; \
			} \
		} \
		if (ATMOS_PASS_PROC) { \
			ret |= (AIR_BLOCKED * !AM.CanZASPass(TARG_TURF, FALSE))|(ZONE_BLOCKED * !AM.CanZASPass(TARG_TURF, TRUE)); \
		} \
		if (ATMOS_PASS_NO) { \
			ret = BLOCKED; \
		} \
	}

#ifdef MULTIZAS

GLOBAL_LIST_INIT(gzn_check, list(NORTH, SOUTH, EAST, WEST, UP, DOWN))
GLOBAL_LIST_INIT(csrfz_check, list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST, NORTHUP, EASTUP, WESTUP, SOUTHUP, NORTHDOWN, EASTDOWN, WESTDOWN, SOUTHDOWN))

#define ATMOS_CANPASS_TURF(ret,A,B) \
	if (A.blocks_air & AIR_BLOCKED || B.blocks_air & AIR_BLOCKED) { \
		ret = BLOCKED; \
	} \
	else if (B.z != A.z) { \
		if (B.z < A.z) { \
			if (!istype(A, /turf/simulated/open)) { \
				ret = BLOCKED; \
			} else { \
				ret = ZONE_BLOCKED; \
			} \
		} \
		else { \
			if (!istype(B, /turf/simulated/open)) { \
				ret = BLOCKED; \
			} else { \
				ret = ZONE_BLOCKED; \
			} \
		} \
	} \
	else if (A.blocks_air & ZONE_BLOCKED || B.blocks_air & ZONE_BLOCKED) { \
		ret = (A.z == B.z) ? ZONE_BLOCKED : AIR_BLOCKED; \
	} \
	else if (A.contents.len) { \
		ret = 0;\
		for (var/thing in A) { \
			var/atom/movable/AM = thing; \
			ATMOS_CANPASS_MOVABLE(ret, AM, B); \
			if (ret == BLOCKED) { \
				break;\
			}\
		}\
	}
#else

GLOBAL_LIST_INIT(gzn_check, list(NORTH, SOUTH, EAST, WEST))
GLOBAL_LIST_INIT(csrfz_check, list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))

#define ATMOS_CANPASS_TURF(ret,A,B) \
	if (A.blocks_air & AIR_BLOCKED || B.blocks_air & AIR_BLOCKED) { \
		ret = BLOCKED; \
	} \
	else if (A.blocks_air & ZONE_BLOCKED || B.blocks_air & ZONE_BLOCKED) { \
		ret = ZONE_BLOCKED; \
	} \
	else if (A.contents.len) { \
		ret = 0;\
		for (var/thing in A) { \
			var/atom/movable/AM = thing; \
			switch (AM.can_atmos_pass) { \
				if (ATMOS_PASS_YES) { \
					continue; \
				} \
				if (ATMOS_PASS_DENSITY) { \
					if (AM.density) { \
						ret |= AIR_BLOCKED; \
					} \
				} \
				if (ATMOS_PASS_PROC) { \
					ret |= AM.c_airblock(B); \
				} \
				if (ATMOS_PASS_NO) { \
					ret = BLOCKED; \
				} \
			} \
			if (ret == BLOCKED) { \
				break;\
			}\
		}\
	}

#endif
