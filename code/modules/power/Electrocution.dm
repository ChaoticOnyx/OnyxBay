/obj/proc/Electrocute(mob/user)
	if(!user)
		return 0

	var/prot = 1

	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user

		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves

			prot = G.siemens_coefficient
	else
		return 0

	if(prot == 0)		// elec insulted gloves protect completely
		return 0

	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
	s.set_up(5, 1, src)
	s.start()

	var/shock_damage = min(rand(20,80),rand(20,80))*prot

	user.burn_skin(shock_damage)
	user.fireloss += shock_damage
	user.updatehealth()
	user << "\red <B>You feel a powerful shock course through your body!</B>"
	sleep(1)

	if(user.stunned < shock_damage)	user.stunned = shock_damage
	if(user.weakened < 20*prot)	user.weakened = 20*prot
	for(var/mob/M in viewers(user))
		if(M == user)	continue
		M.show_message("\red [user.name] was shocked by the [name]!", 3, "\red You hear a heavy electrical crack", 2)
	return 1