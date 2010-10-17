/mob/living/carbon/human/var/sprinting = 0
/mob/living/carbon/human/var/sprintcool = 0
/mob/living/carbon/human/verb/sprint()
	if(!sprintcool)
		usr << "You start sprinting!"
		sprinting = 1
		sprintcool = 1
		spawn(150) sprinting = 0
		spawn(600) sprintcool = 0
	else
		usr << "You don't feel up too it."