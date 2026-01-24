/mob/living/carbon/alien/ex_act(severity)
	if(!blinded)
		flash_eyes()
	var/b_loss = 0
	var/f_loss = 0
	switch(severity)
		if(1.0)
			b_loss += 500
			gib()
			return
		if(2.0)
			b_loss += 60
			f_loss += 60
			adjustEarDamage(30, 120)
		if(3.0)
			b_loss += 30
			if(prob(50))
				Paralyse(1)
			adjustEarDamage(15, 60)

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

/mob/living/carbon/alien/adjustBruteLoss(damage)
	..()
	updatehealth()

/mob/living/carbon/alien/adjustFireLoss(damage)
	..()
	updatehealth()

/mob/living/carbon/alien/adjustToxLoss(damage)
	..()
	updatehealth()

/mob/living/carbon/alien/adjustOxyLoss(damage)
	..()
	updatehealth()
