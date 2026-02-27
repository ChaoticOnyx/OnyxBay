/mob/living/carbon/larva/xenomorph/feral
	name = "alien feral larva"
	real_name = "alien feral larva"

/mob/living/carbon/larva/xenomorph/feral/confirm_evolution()
	to_chat(src, DESC_EVOLVE + DESC_HUNTER_FERAL + DESC_SENTINEL + DESC_DRONE)
	var/alien_caste = alert(src, "Please choose which alien caste you shall belong to.",,"Feral Hunter","Sentinel","Drone")
	return alien_caste ? "Xenomorph [alien_caste]" : null

/mob/living/carbon/larva/xenomorph/primal
	name = "alien primal larva"
	real_name = "alien primal larva"

/mob/living/carbon/larva/xenomorph/primal/confirm_evolution()
	to_chat(src, DESC_EVOLVE + DESC_HUNTER+ DESC_SENTINEL_PRIMAL + DESC_DRONE)
	var/alien_caste = alert(src, "Please choose which alien caste you shall belong to.",,"Hunter","Primal Sentinel","Drone")
	return alien_caste ? "Xenomorph [alien_caste]" : null

/mob/living/carbon/larva/xenomorph/vile
	name = "alien vile larva"
	real_name = "alien vile larva"

/mob/living/carbon/larva/xenomorph/vile/confirm_evolution()
	to_chat(src, DESC_EVOLVE + DESC_HUNTER + DESC_SENTINEL + DESC_DRONE_VILE)
	var/alien_caste = alert(src, "Please choose which alien caste you shall belong to.",,"Hunter","Sentinel","Vile Drone")
	return alien_caste ? "Xenomorph [alien_caste]" : null

#undef DESC_EVOLVE
#undef DESC_HUNTER
#undef DESC_SENTINEL
#undef DESC_DRONE
#undef DESC_HUNTER_FERAL
#undef DESC_SENTINEL_PRIMAL
#undef DESC_DRONE_VILE
