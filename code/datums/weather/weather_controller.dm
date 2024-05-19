/datum/weather_controller
	/// Weighted list of possible weather types.
	var/list/possible_weathers
	/// The lowest interval between one naturally occuring weather and another
	var/wait_interval_low = 5 MINUTES
	/// The highest interval between one naturally occuring weather and another
	var/wait_interval_high = 10 MINUTES
	/// Next weather type.
	var/next_weather_type
	/// world.time of next weather type.
	var/next_weather = 0
	/// Current weathers. Associative 'type -> reference'
	var/list/current_weathers
	/// A simple cache to make sure we dont call updates with no changes
	var/last_checked_skyblock = 0
	/// Common cache for possible weathers list
	var/static/list/possible_weathers_cache = list()
	/// Z-level this datum controls.
	var/z_level

/datum/weather_controller/New(z_level)
	. = ..()
	if(possible_weathers)
		if(!possible_weathers_cache[type])
			possible_weathers_cache[type] = possible_weathers
		possible_weathers = possible_weathers_cache[type]
	src.z_level = z_level
	roll_next_weather()
	run_weather(next_weather_type)
	set_next_think(world.time + 5 SECONDS)

/datum/weather_controller/Destroy(force)
	if(!force)
		util_crash_with("A twat with permissions tried to delete /datum/weather_controller. Find and skullfuck him.")
		return QDEL_HINT_LETMELIVE

	if(current_weathers)
		for(var/i in current_weathers)
			var/datum/weather/W = current_weathers[i]
			W.end()

	return ..()

/datum/weather_controller/think()
	if(possible_weathers && world.time > next_weather)
		run_weather(next_weather_type)
		roll_next_weather()

	set_next_think(world.time + 5 SECONDS)

/datum/weather_controller/proc/roll_next_weather()
	if(!possible_weathers)
		return

	next_weather = world.time + rand(wait_interval_low, wait_interval_high)
	next_weather_type = util_pick_weight(possible_weathers)

/datum/weather_controller/proc/run_weather(datum/weather/weather_datum_type, foreshadow = TRUE)
	if(!ispath(weather_datum_type, /datum/weather))
		CRASH("run_weather called with invalid weather_datum_type: [weather_datum_type || "null"]")

	LAZYINITLIST(current_weathers)
	if(current_weathers[weather_datum_type])
		CRASH("run_weather tried to create a weather that was already simulated")

	var/datum/weather/weather = new weather_datum_type(src)
	if(foreshadow)
		weather.foreshadow()

	return weather

/datum/weather_controller/lush
	possible_weathers = list(
		/datum/weather/nuclear_fallout = 30,
		/datum/weather/acid_rain = 50,
	)
