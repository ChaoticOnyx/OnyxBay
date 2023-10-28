
// Summons bats.
/datum/vampire_power/bats
	name = "Summon Bats"
	desc = "You tear open the Veil for just a moment, in order to summon a pair of bats to assist you in combat."
	icon_state = "vamp_bats"
	blood_cost = 60

/datum/vampire_power/bats/activate()
	if(!..())
		return

	var/list/locs = list()

	for(var/direction in GLOB.alldirs)
		if(locs.len == 2)
			break

		var/turf/T = get_step(my_mob, direction)
		if(AStar(my_mob.loc, T, /turf/proc/AdjacentTurfs, /turf/proc/Distance, 1))
			locs += T

	var/list/spawned = list()
	if(locs.len)
		for(var/turf/to_spawn in locs)
			spawned += new /mob/living/simple_animal/hostile/scarybat(to_spawn, my_mob)

		if(spawned.len != 2)
			spawned += new /mob/living/simple_animal/hostile/scarybat(my_mob.loc, my_mob)
	else
		spawned += new /mob/living/simple_animal/hostile/scarybat(my_mob.loc, my_mob)
		spawned += new /mob/living/simple_animal/hostile/scarybat(my_mob.loc, my_mob)

	if(!spawned.len)
		return

	for(var/mob/living/simple_animal/hostile/scarybat/bat in spawned)
		LAZYADD(bat.friends, weakref(my_mob))

		if(vampire.thralls.len)
			LAZYADD(bat.friends, vampire.thralls)

	log_and_message_admins("summoned bats.")

	use_blood()
	set_cooldown(60 SECONDS)
