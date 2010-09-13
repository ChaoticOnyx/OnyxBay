/mob/living/carbon/alien/name = "alien"
/mob/living/carbon/alien/voice_name = "alien"
/mob/living/carbon/alien/voice_message = "hisses"
/mob/living/carbon/alien/icon = 'alien.dmi'
/mob/living/carbon/alien/toxloss = 250
/mob/living/carbon/alien/species = "Alien"

/mob/living/carbon/alien/var/toxgain = 5 // How much toxins is gained from weeds per tick
/mob/living/carbon/alien/var/alien_invis = 0.0

/mob/living/carbon/alien/updatehealth()
	if (!nodamage)
	//oxyloss is only used for suicide
	//toxloss isn't used for aliens, its actually used as alien powers!!
		health = health_full - (oxyloss + fireloss + bruteloss)
	else
		health = health_full
		stat = 0

/mob/living/carbon/alien/FireBurn() // Should probably make this affect all carbon mobs except for aliens (This applies to contaminate and pl_effects as well)
/mob/living/carbon/alien/contaminate()
/mob/living/carbon/alien/pl_effects()

/mob/living/carbon/alien/New()
	..()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src

	update_clothing()

	src << "\blue Your icons have been generated!"

/mob/living/carbon/alien/Bump(atom/movable/AM as mob|obj, yes)
	spawn(0)
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & 32)
				if(prob(70))
					for(var/mob/M in viewers(src, null))
						if(M.client)
							M << "\red <B>[src] fails to push [tmob]'s fat ass out of the way.</B>"
					now_pushing = 0
					return
		now_pushing = 0
		..()
		if (!( istype(AM, /atom/movable) ))
			return
		if (!( now_pushing ))
			now_pushing = 1
			if (!( AM.anchored ))
				var/t = get_dir(src, AM)
				step(AM, t)
			now_pushing = null
		return
	return

/mob/living/carbon/alien/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (health > 0)
		bruteloss += (istype(O, /obj/meteor/small) ? 10 : 25)
		fireloss += 30

		updatehealth()
	return