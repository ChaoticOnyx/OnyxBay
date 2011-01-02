mob/living/proc/CheckHandcuff(var/mob/living/M)
	set name = "Check handcuff"
	set category  = "Admin"
	if(M.handcuffed  && M.lasthandcuff)
		var/time =  world.timeofday - M.lasthandcuff
		time /= 10
		if(time >= 60)
			time /= 60
			usr << "[M] has been handcuffed for [time] minutes"
		else
			usr << "[M] has been handcuffed for [round(time)] seconds"