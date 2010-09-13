/mob/living/silicon/robot/Login()
	..()
	if(real_name == "Cyborg")
		real_name += " [pick(rand(1, 999))]"
		name = real_name
	if(!connected_ai)
		for(var/mob/living/silicon/ai/A in world)
			connected_ai = A
			A.connected_robots += src
			break