/var/list/validartifactprojectiles = list(
	/obj/item/projectile/beam,
	/obj/item/projectile/beam/practice,
	/obj/item/projectile/beam/heavylaser,
	/obj/item/projectile/beam/xray,
	/obj/item/projectile/beam/pulse,
	/obj/item/projectile/beam/mindflayer,
	/obj/item/projectile/energy/electrode,
	/obj/item/projectile/energy/declone,
	/obj/item/projectile/energy/bolt/large,
	/obj/item/projectile/ion,
	/obj/item/projectile/temp,
	/obj/item/projectile/kinetic,
	/obj/item/projectile/forcebolt
)

/datum/artifact_effect/projectiles
	name = "projectiles"
	effect = EFFECT_PULSE
	effectrange = 7
	var/projectiletype
	var/num_of_shots

/datum/artifact_effect/projectiles/New()
	..()
	effect_type = pick(EFFECT_ENERGY, EFFECT_ELECTRO, EFFECT_PARTICLE, EFFECT_BLUESPACE)
	chargelevelmax = rand(5, 20)
	projectiletype = pick(validartifactprojectiles)
	num_of_shots = pick(100;1, 100;2, 50;3, 25;4, 10;6)

/datum/artifact_effect/projectiles/DoEffectPulse()
	if(holder)
		var/possible_turfs = trange(effectrange, get_turf(holder)) - trange(effectrange - 1, get_turf(holder))
		for(var/i=0, i<num_of_shots, i++)
			var/turf/target = pick(possible_turfs)
			var/obj/item/projectile/P = new projectiletype(holder.loc)
			P.launch(target, holder)
