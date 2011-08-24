// Because Byond's spawn()s and sleep()s work on ticks, rather than real time tenths of seconds

#define tick_multiplier 2 // 1/tick_lag

/world/New()
	world.tick_lag = 0.5
	return ..()