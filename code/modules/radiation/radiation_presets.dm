/datum/radiation_info/preset/New(activity_multiplier = 1)
	..(activity * activity_multiplier, ray_type, energy)

/datum/radiation_info/preset/uranium_238
	activity = 33.7 MICRO CURIE
	ray_type = RADIATION_ALPHA_RAY

/datum/radiation_info/preset/radium_226
	activity = 100 CURIE
	ray_type = RADIATION_ALPHA_RAY

/datum/radiation_info/preset/hawking
	activity = 5000 KILO CURIE
	ray_type = RADIATION_HAWKING_RAY

/datum/radiation_info/preset/supermatter
	activity = 50 KILO CURIE
	ray_type = RADIATION_BETA_RAY

/datum/radiation_info/preset/artifact
	activity = 5 KILO CURIE
	ray_type = RADIATION_GAMMA_RAY

/datum/radiation_info/preset/carbon_14
	activity = 450 CURIE
	ray_type = RADIATION_BETA_RAY
