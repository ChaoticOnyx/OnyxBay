/mob/living/carbon/monkey/Login()
	..()
	if(name == "monkey")
		name = text("monkey ([rand(1, 1000)])")
	real_name = name