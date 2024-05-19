/datum/looping_sound/weather/wind
	mid_sounds = list(
		'sound/weather/wind/wind1.ogg' = 1,
		'sound/weather/wind/wind2.ogg' = 1,
		'sound/weather/wind/wind3.ogg' = 1,
		'sound/weather/wind/wind4.ogg' = 1,
		'sound/weather/wind/wind5.ogg' = 1,
		'sound/weather/wind/wind6.ogg' = 1
		)
	mid_length = 10 SECONDS // The lengths for the files vary, but the longest is ten seconds, so this will make it sound like intermittent wind.
	volume = 50

/datum/looping_sound/weather/wind/indoors
	volume = 30

/datum/looping_sound/weather/rain
	mid_sounds = list(
		'sound/weather/rain/acidrain_mid.ogg' = 1
		)
	mid_length = 15 SECONDS // The lengths for the files vary, but the longest is ten seconds, so this will make it sound like intermittent wind.
	start_sound = 'sound/weather/rain/acidrain_start.ogg'
	start_length = 13 SECONDS
	end_sound = 'sound/weather/rain/acidrain_end.ogg'
	volume = 50

/datum/looping_sound/weather/rain/indoors
	volume = 30
