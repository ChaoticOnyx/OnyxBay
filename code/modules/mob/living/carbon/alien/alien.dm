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
		health = health_full - (oxyloss - fireloss - bruteloss)
	else
		health = health_full
		stat = 0