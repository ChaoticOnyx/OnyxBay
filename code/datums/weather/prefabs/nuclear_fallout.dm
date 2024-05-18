/datum/weather/nuclear_fallout
	name = "nuclear fallout"
	desc = "Irradiated dust falls down everywhere."

	foreshadowing_duration = 20 SECONDS
	foreshadowing_message = "The air suddenly becomes dusty.."
	foreshadowing_overlay = "fallout"

	weather_message = "<i>You feel a wave of hot ash fall down on you.</i>"
	weather_overlay = "snowfall_heavy"
	weather_duration_lower = 600
	weather_duration_upper = 1500

	protect_indoors = TRUE

	weather_color = "green"
	weather_sound = 'sound/weather/fallout/falloutwind.ogg'
	end_duration = 100

	end_message = "The ash stops falling."

/datum/weather/nuclear_fallout/weather_act(mob/living/victim)
	victim.rad_act(new /datum/radiation_source(new /datum/radiation(rand(1 TERA BECQUEREL, 1.5 TERA BECQUEREL), RADIATION_ALPHA_PARTICLE), src))
