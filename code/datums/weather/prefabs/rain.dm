/datum/weather/rain
	name = "rain"
	desc = "Rain falling down the surface."

	foreshadowing_message = "<span class='notice'>Dark clouds hover above and you feel humidity in the air..</span>"
	foreshadowing_duration = 30 SECONDS
	foreshadowing_overlay = "rain"

	weather_message = "<span class='notice'>Rain starts to fall down..</span>"
	weather_overlay = "rain"
	weather_duration_lower = 1 MINUTE
	weather_duration_upper = 2 MINUTES

	end_duration = 30 SECONDS
	end_message = "<span class='notice'>The rain stops...</span>"

	protect_indoors = TRUE

	sound_active_outside = /datum/looping_sound/weather/rain/indoors
	sound_active_inside = /datum/looping_sound/weather/rain

	thunder_chance = 1
