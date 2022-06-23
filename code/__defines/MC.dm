#define MC_TICK_CHECK ( ( TICK_USAGE > Master.current_ticklimit || src.state != SS_RUNNING ) ? pause() : 0 )
#define GAME_STATE 2 ** (Master.current_runlevel - 1)

#define MC_SPLIT_TICK_INIT(phase_count) var/original_tick_limit = Master.current_ticklimit; var/split_tick_phases = ##phase_count
#define MC_SPLIT_TICK \
	if(split_tick_phases > 1){\
		Master.current_ticklimit = ((original_tick_limit - TICK_USAGE) / split_tick_phases) + TICK_USAGE;\
		--split_tick_phases;\
	} else {\
		Master.current_ticklimit = original_tick_limit;\
	}

// Used to smooth out costs to try and avoid oscillation.
#define MC_AVERAGE_FAST(average, current) (0.7 * (average) + 0.3 * (current))
#define MC_AVERAGE(average, current) (0.8 * (average) + 0.2 * (current))
#define MC_AVERAGE_SLOW(average, current) (0.9 * (average) + 0.1 * (current))

#define MC_AVG_FAST_UP_SLOW_DOWN(average, current) (average > current ? MC_AVERAGE_SLOW(average, current) : MC_AVERAGE_FAST(average, current))
#define MC_AVG_SLOW_UP_FAST_DOWN(average, current) (average < current ? MC_AVERAGE_SLOW(average, current) : MC_AVERAGE_FAST(average, current))

#define NEW_SS_GLOBAL(varname) if(varname != src){if(istype(varname)){Recover();qdel(varname);}varname = src;}

#define START_PROCESSING(Processor, Datum) \
if (Datum.is_processing) {\
	if(Datum.is_processing != #Processor)\
	{\
		crash_with("Failed to start processing. [log_info_line(Datum)] is already being processed by [Datum.is_processing] but queue attempt occured on [#Processor]."); \
	}\
} else {\
	Datum.is_processing = #Processor;\
	Processor.processing += Datum;\
}

#define STOP_PROCESSING(Processor, Datum) \
if(Datum.is_processing) {\
	if(Processor.processing.Remove(Datum)) {\
		Datum.is_processing = null;\
	} else {\
		crash_with("Failed to stop processing. [log_info_line(Datum)] is being processed by [Datum.is_processing] but de-queue attempt occured on [#Processor]."); \
	}\
}

//SubSystem flags (Please design any new flags so that the default is off, to make adding flags to subsystems easier)

//subsystem does not initialize.
#define SS_NO_INIT 1

//subsystem does not fire.
//	(like can_fire = 0, but keeps it from getting added to the processing subsystems list)
//	(Requires a MC restart to change)
#define SS_NO_FIRE 2

//subsystem only runs on spare cpu (after all non-background subsystems have ran that tick)
//	SS_BACKGROUND has its own priority bracket
#define SS_BACKGROUND 4

//subsystem does not tick check, and should not run unless there is enough time (or its running behind (unless background))
#define SS_NO_TICK_CHECK 8

//Treat wait as a tick count, not DS, run every wait ticks.
//	(also forces it to run first in the tick, above even SS_NO_TICK_CHECK subsystems)
//	(implies all runlevels because of how it works)
//	(overrides SS_BACKGROUND)
//	This is designed for basically anything that works as a mini-mc (like SStimer)
#define SS_TICKER 16

//keep the subsystem's timing on point by firing early if it fired late last fire because of lag
//	ie: if a 20ds subsystem fires say 5 ds late due to lag or what not, its next fire would be in 15ds, not 20ds.
#define SS_KEEP_TIMING 32

// Calculate its next fire after its fired.
//	(IE: if a 5ds wait SS takes 2ds to run, its next fire should be 5ds away, not 3ds like it normally would be)
//	This flag overrides SS_KEEP_TIMING
#define SS_POST_FIRE_TIMING 64

//! ## Timing subsystem
/**
 * Don't run if there is an identical unique timer active
 *
 * if the arguments to addtimer are the same as an existing timer, it doesn't create a new timer,
 * and returns the id of the existing timer
 */
#define TIMER_UNIQUE (1<<0)

/// For unique timers: Replace the old timer rather then not start this one
#define TIMER_OVERRIDE (1<<1)

/**
 * Timing should be based on how timing progresses on clients, not the server.
 *
 * Tracking this is more expensive,
 * should only be used in conjuction with things that have to progress client side, such as
 * animate() or sound()
 */
#define TIMER_CLIENT_TIME (1<<2)

/// Timer can be stopped using deltimer()
#define TIMER_STOPPABLE (1<<3)

/// prevents distinguishing identical timers with the wait variable
///
/// To be used with TIMER_UNIQUE
#define TIMER_NO_HASH_WAIT (1<<4)

/// Loops the timer repeatedly until qdeleted
///
/// In most cases you want a subsystem instead, so don't use this unless you have a good reason
#define TIMER_LOOP (1<<5)

/// Delete the timer on parent datum Destroy() and when deltimer'd
#define TIMER_DELETE_ME (1<<6)

/// Empty ID define
#define TIMER_ID_NULL -1

/**
	Create a new timer and add it to the queue.
	* Arguments:
	* * callback the callback to call on timer finish
	* * wait deciseconds to run the timer for
	* * flags flags for this timer, see: code\__DEFINES\subsystems.dm
*/
#define addtimer(args...) _addtimer(args, file = __FILE__, line = __LINE__)

//SUBSYSTEM STATES
#define SS_IDLE 0		//aint doing shit.
#define SS_QUEUED 1		//queued to run
#define SS_RUNNING 2	//actively running
#define SS_PAUSED 3		//paused by mc_tick_check
#define SS_SLEEPING 4	//fire() slept.
#define SS_PAUSING 5 	//in the middle of pausing

#define SUBSYSTEM_DEF(X) GLOBAL_REAL(SS##X, /datum/controller/subsystem/##X);\
/datum/controller/subsystem/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
}\
/datum/controller/subsystem/##X

#define PROCESSING_SUBSYSTEM_DEF(X) GLOBAL_REAL(SS##X, /datum/controller/subsystem/processing/##X);\
/datum/controller/subsystem/processing/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
}\
/datum/controller/subsystem/processing/##X/Recover() {\
	if(istype(SS##X.processing)) {\
		processing = SS##X.processing; \
	}\
}\
/datum/controller/subsystem/processing/##X
