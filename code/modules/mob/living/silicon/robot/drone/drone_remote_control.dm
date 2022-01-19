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

/obj/machinery/drone_fabricator/attack_ai(mob/living/silicon/ai/user)
	// Request received, turning it off for now
	if(!Debug2)
		return

	if(!istype(user) || user.controlling_robot || !config.allow_drone_spawn)
		return

	if(stat & NOPOWER)
		to_chat(user, "<span class='warning'>\The [src] is unpowered.</span>")
		return

	if(!produce_drones)
		to_chat(user, "<span class='warning'>\The [src] is disabled.</span>")
		return

	if(drone_progress < 100)
		to_chat(user, "<span class='warning'>\The [src] is not ready to produce a new drone.</span>")
		return

	if(count_drones() >= config.max_maint_drones)
		to_chat(user, "<span class='warning'>The drone control subsystems are tasked to capacity; they cannot support any more drones.</span>")
		return

	var/mob/living/silicon/robot/drone/new_drone = create_drone()
	new_drone.assume_control(user)

/mob/living/silicon/robot/drone/release_ai_control_verb()
	set name = "Release Control"
	set desc = "Release control of a remote drone."
	set category = "Silicon Commands"

	release_ai_control("Remote session terminated.")
