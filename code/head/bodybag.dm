obj/bodybag
	icon = 'bodybag.dmi'
	icon_state = "b00"
	var/mob/captured
	var/open
obj/bodybag/proc/close()
	for(var/mob/M in src.loc)
		if(M.lying)
			captured = M
			M.loc = src
			break
	var/hasmob = 0
	open = 0
	if(captured) hasmob=1
	icon_state = "b[open][hasmob]"
obj/bodybag/proc/open()
	if(captured)
		captured.loc = src.loc
		captured = null
	open = 1
	icon_state = "b[open]0"
obj/bodybag/attack_hand(mob/user)
	if(open)
		close()
	else
		open()