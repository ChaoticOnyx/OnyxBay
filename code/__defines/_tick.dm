#define TICK_LIMIT_RUNNING 85               // Tick limit while running normally
#define TICK_LIMIT_TO_RUN 75                // Tick limit used to resume things in stoplag
#define TICK_LIMIT_MC 84                    // Tick limit for MC while running
#define TICK_LIMIT_MC_INIT_DEFAULT 100      // Tick limit while initializing

#define TICK_USAGE world.tick_usage         // For general usage

#define TICK_CHECK ( TICK_USAGE > Master.current_ticklimit )
#define CHECK_TICK if TICK_CHECK stoplag()

#define TICKS *world.tick_lag

#define DS2TICKS(DS) (DS/world.tick_lag)

#define TICKS2DS(T) (T TICKS)

//"fancy" math for calculating time in ms from tick_usage percentage and the length of ticks
//percent_of_tick_used * (ticklag * 100(to convert to ms)) / 100(percent ratio)
//collapsed to percent_of_tick_used * tick_lag
#define TICK_DELTA_TO_MS(percent_of_tick_used) ((percent_of_tick_used) * world.tick_lag)
#define TICK_USAGE_TO_MS(starting_tickusage) (TICK_DELTA_TO_MS(TICK_USAGE - starting_tickusage))

//time of day but automatically adjusts to the server going into the next day within the same round.
//for when you need a reliable time number that doesn't depend on byond time.
#define REALTIMEOFDAY (world.timeofday + (MIDNIGHT_ROLLOVER * MIDNIGHT_ROLLOVER_CHECK))
#define MIDNIGHT_ROLLOVER_CHECK ( GLOB.rollovercheck_last_timeofday != world.timeofday ? update_midnight_rollover() : GLOB.midnight_rollovers )
