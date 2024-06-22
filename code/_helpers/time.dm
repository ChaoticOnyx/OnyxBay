#define TimeOfGame (get_game_time())
#define TimeOfTick (world.tick_usage*0.01*world.tick_lag)
/proc/get_game_time()
	var/global/time_offset = 0
	var/global/last_time = 0
	var/global/last_usage = 0

	var/wtime = world.time
	var/wusage = world.tick_usage * 0.01

	if(last_time < wtime && last_usage > 1)
		time_offset += last_usage - 1

	last_time = wtime
	last_usage = wusage

	return wtime + (time_offset + wusage) * world.tick_lag

var/roundstart_hour
var/station_date = ""
var/next_station_date_change = 1 DAY

#define duration2stationtime(time) time2text(station_time_in_ticks + time, "hh:mm")
#define worldtime2stationtime(time) time2text(roundstart_hour HOURS + time, "hh:mm")
#define round_duration_in_ticks (round_start_time ? world.time - round_start_time : 0)
#define station_time_in_ticks (roundstart_hour HOURS + round_duration_in_ticks)

/proc/stationtime2text()
	return time2text(station_time_in_ticks, "hh:mm")

/proc/stationdate2text()
	var/update_time = FALSE
	if(station_time_in_ticks > next_station_date_change)
		next_station_date_change += 1 DAY
		update_time = TRUE
	if(!station_date || update_time)
		var/extra_days = round(station_time_in_ticks / (1 DAY)) DAYS
		var/timeofday = world.timeofday + extra_days
		station_date = num2text((text2num(time2text(timeofday, "YYYY"))+544)) + "-" + time2text(timeofday, "MM-DD")
	return station_date

/proc/time_stamp()
	return time2text(world.timeofday, "hh:mm:ss")

/proc/ticks_to_text(var/ticks)
	if(ticks%1 != 0)
		return "ERROR"
	var/response = ""
	var/counter = 0
	while(ticks >= 1 DAYS)
		ticks -= 1 DAYS
		counter++
	if(counter)
		response += "[counter] Day[counter>1 ? "s" : ""][ticks ? ", " : ""]"
	counter=0
	while(ticks >= 1 HOURS)
		ticks -= 1 HOURS
		counter++
	if(counter)
		response += "[counter] Hour[counter>1 ? "s" : ""][ticks?", ":""]"
	counter=0
	while(ticks >= 1 MINUTES)
		ticks -= 1 MINUTES
		counter++
	if(counter)
		response += "[counter] Minute[counter>1 ? "s" : ""][ticks?", ":""]"
		counter=0
	while(ticks >= 1 SECONDS)
		ticks -= 1 SECONDS
		counter++
	if(counter)
		response += "[counter][ticks?".[ticks]" : ""] Second[counter>1 ? "s" : ""]"
	return response

/* Returns 1 if it is the selected month and day */
/proc/isDay(month, day)
	if(isnum(month) && isnum(day))
		var/MM = text2num(time2text(world.timeofday, "MM")) // get the current month
		var/DD = text2num(time2text(world.timeofday, "DD")) // get the current day
		if(month == MM && day == DD)
			return 1

		// Uncomment this out when debugging!
		//else
			//return 1

var/next_duration_update = 0
var/last_round_duration = 0
var/round_start_time = 0

/hook/roundstart/proc/start_timer()
	round_start_time = world.time
	return 1

/proc/roundduration2text()
	if(!round_start_time)
		return "00:00"
	if(last_round_duration && world.time < next_duration_update)
		return last_round_duration

	var/mills = round_duration_in_ticks // 1/10 of a second, not real milliseconds but whatever
	//var/secs = ((mills % 36000) % 600) / 10 //Not really needed, but I'll leave it here for refrence.. or something
	var/mins = round((mills % 36000) / 600)
	var/hours = round(mills / 36000)

	mins = mins < 10 ? add_zero(mins, 1) : mins
	hours = hours < 10 ? add_zero(hours, 1) : hours

	last_round_duration = "[hours]:[mins]"
	next_duration_update = world.time + 1 MINUTES
	return last_round_duration

/hook/startup/proc/set_roundstart_hour()
	roundstart_hour = pick(2,7,12,17)
	return 1

GLOBAL_VAR_INIT(midnight_rollovers, 0)
GLOBAL_VAR_INIT(rollovercheck_last_timeofday, 0)
/proc/update_midnight_rollover()
	if (world.timeofday < GLOB.rollovercheck_last_timeofday) //TIME IS GOING BACKWARDS!
		return GLOB.midnight_rollovers++
	return GLOB.midnight_rollovers

///Increases delay as the server gets more overloaded, as sleeps aren't cheap and sleeping only to wake up and sleep again is wasteful
#define DELTA_CALC max(((max(TICK_USAGE, world.cpu) / 100) * max(Master.sleep_delta - 1,1)), 1)

///Returns the number of ticks slept
/proc/stoplag(initial_delay)
	if (!Master || !(GAME_STATE & RUNLEVELS_DEFAULT))
		sleep(world.tick_lag)
		return 1
	if (!initial_delay)
		initial_delay = world.tick_lag
	. = 0
	var/i = DS2TICKS(initial_delay)
	do
		. += CEILING(i * DELTA_CALC, 1)
		sleep(i * world.tick_lag * DELTA_CALC)
		i *= 2
	while (TICK_USAGE > min(TICK_LIMIT_TO_RUN, Master.current_ticklimit))

#undef DELTA_CALC

/*
	Simple throttle realization.
	Initial value is TRUE.
	Using example:

	THROTTLE(cooldown, 1 SECOND)
	if(cooldown)
		do_something()
*/
#define THROTTLE(variable, delay) var/static/__throttle##variable=list(); var/##variable = FALSE; if(__throttle##variable["\ref[src]"] == null) {__throttle##variable["\ref[src]"] = world.time-delay-1} if(world.time > __throttle##variable["\ref[src]"] + delay) {__throttle##variable["\ref[src]"] = world.time; variable = TRUE} else{variable = FALSE}

/*
	Works like THROTTLE but uses a shared counter.
	Example:
	/datum/foo
		var/last_action = 0

	/datum/foo/proc/do()
		THROTTLE_SHARED(cooldown, 1 SECOND, last_action)
		if(cooldown)
			do_something()

	/datum/foo/proc/do2()
		THROTTLE_SHARED(cooldown, 1 SECOND, last_action)
		if(cooldown)
			do_something2()
*/
#define THROTTLE_SHARED(variable, delay, counter) var/##variable = (world.time > counter + delay); if(variable) {counter = world.time}
