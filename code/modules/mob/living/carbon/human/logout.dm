/mob/living/carbon/human/Logout()
	toggle_twohanded_mode(FALSE, TRUE)
	..()
	if(species) species.handle_logout_special(src)
	return
