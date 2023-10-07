/datum/radiation/preset/New(activity_multiplier = 1)
	..(activity * activity_multiplier, radiation_type, energy)

/datum/radiation/preset/uranium_238
	activity = 33.7 MICRO CURIE
	radiation_type = RADIATION_ALPHA_PARTICLE
	energy = 4.2 MEGA ELECTRONVOLT

/datum/radiation/preset/radium_226
	activity = 100 CURIE
	radiation_type = RADIATION_ALPHA_PARTICLE
	energy = 4.8 MEGA ELECTRONVOLT

/datum/radiation/preset/singularity_beta
	activity = 15 KILO CURIE
	radiation_type = RADIATION_BETA_PARTICLE
	energy = 3.2 MEGA ELECTRONVOLT

/datum/radiation/preset/hawking
	activity = 0.2 MEGA CURIE
	radiation_type = RADIATION_HAWKING
	energy = 50 MILLI ELECTRONVOLT
/datum/radiation/preset/gravitaty_generator
	activity = 0.1 MEGA CURIE
	radiation_type = RADIATION_HAWKING
	energy = 122 MILLI ELECTRONVOLT

/datum/radiation/preset/supermatter
	activity = 30 KILO CURIE
	radiation_type = RADIATION_BETA_PARTICLE
	energy = 500 KILO ELECTRONVOLT

/datum/radiation/preset/artifact
	activity = 15 KILO CURIE
	radiation_type = RADIATION_BETA_PARTICLE
	energy = 233 KILO ELECTRONVOLT

/datum/radiation/preset/carbon_14
	activity = 450 CURIE
	radiation_type = RADIATION_BETA_PARTICLE
	energy = 156 KILO ELECTRONVOLT
