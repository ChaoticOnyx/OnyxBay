/datum/weather/rain
	name = "rain"
	desc = "Rain falling down the surface."

	foreshadowing_message = "Dark clouds hover above and you feel humidity in the air."
	foreshadowing_duration = 30 SECONDS
	foreshadowing_overlay = "rain"

	weather_message = "Rain starts to fall down."
	weather_overlay = "rain"
	weather_duration_lower = 1 MINUTE
	weather_duration_upper = 2 MINUTES

	end_duration = 30 SECONDS
	end_message = "The rain stops."

	protect_indoors = TRUE

	sound_active_outside = /datum/looping_sound/weather/rain/indoors
	sound_active_inside = /datum/looping_sound/weather/rain

	thunder_chance = 1
