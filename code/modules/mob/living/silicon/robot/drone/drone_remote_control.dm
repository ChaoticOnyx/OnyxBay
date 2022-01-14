/mob/living/silicon/robot/drone/attack_ai(mob/living/silicon/ai/user)

	if(!istype(user) || controlling_ai || !config.allow_drone_spawn)
		return

	if(stat != 2 || client || key)
		to_chat(user, "<span class='warning'>You cannot take control of an autonomous, active drone.</span>")
		return

	if(health < -35 || emagged)
		to_chat(user, "<span class='notice'><b>WARNING:</b> connection timed out.</span>")
		return

	assume_control(user)
