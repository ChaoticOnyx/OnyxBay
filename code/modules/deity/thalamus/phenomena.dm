/datum/deity_power/phenomena/release_lymphocytes
	name = "Phenomena: Warp Body"
	desc = "Gain the ability to warp the very structure of a target's body, wracking pain and weakness."
	expected_type = /turf

/datum/deity_power/phenomena/release_lymphocytes/manifest(atom/target, mob/living/deity/D)
	if(!..())
		return FALSE

	for(var/i = 0 to rand(2, 4))
		new /mob/living/simple_animal/hostile/lymphocyte(target, D)
