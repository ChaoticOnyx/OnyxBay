/* Using the HUD procs is simple. Call these procs in the life.dm of the intended mob.
Use the regular_hud_updates() proc before process_med_hud(mob) or process_sec_hud(mob) so
the HUD updates properly! */

// hud overlay image type, used for clearing client.images precisely
/image/hud_overlay
	appearance_flags = RESET_COLOR|RESET_TRANSFORM|KEEP_APART
	layer = ABOVE_HUMAN_LAYER
	plane = DEFAULT_PLANE

//Medical HUD outputs. Called by the Life() proc of the mob using it, usually.
/proc/process_med_hud(mob/original_mob, local_scanner, mob/proxy_mob)
	if(!can_process_hud(original_mob))
		return

	GLOB.med_hud_users |= original_mob
	proxy_mob = proxy_mob || original_mob

	for(var/mob/living/carbon/human/target in proxy_mob.in_view(get_turf(proxy_mob)))
		if(target.is_invisible_to(proxy_mob))
			continue
		if(local_scanner)
			original_mob.add_client_image(target.hud_list[HEALTH_HUD])
			original_mob.add_client_image(target.hud_list[STATUS_HUD])
		else
			var/sensor_level = getsensorlevel(target)
			if(sensor_level >= SUIT_SENSOR_VITAL)
				original_mob.add_client_image(target.hud_list[HEALTH_HUD])
			if(sensor_level >= SUIT_SENSOR_BINARY)
				original_mob.add_client_image(target.hud_list[LIFE_HUD])

//Security HUDs. Pass a value for the second argument to enable implant viewing or other special features.
/proc/process_sec_hud(mob/original_mob, advanced_mode, mob/proxy_mob)
	if(!can_process_hud(original_mob))
		return

	GLOB.sec_hud_users |= original_mob
	proxy_mob = proxy_mob || original_mob

	for(var/mob/living/carbon/human/target in proxy_mob.in_view(get_turf(proxy_mob)))
		if(target.is_invisible_to(proxy_mob))
			continue
		original_mob.add_client_image(target.hud_list[ID_HUD])
		if(advanced_mode)
			original_mob.add_client_image(target.hud_list[WANTED_HUD])
			original_mob.add_client_image(target.hud_list[IMPTRACK_HUD])
			original_mob.add_client_image(target.hud_list[IMPLOYAL_HUD])
			original_mob.add_client_image(target.hud_list[IMPCHEM_HUD])

/proc/process_xeno_hud(mob/original_mob, mob/proxy_mob)
	if(!can_process_hud(original_mob))
		return

	GLOB.xeno_hud_users |= original_mob
	proxy_mob = proxy_mob || original_mob

	for(var/mob/living/carbon/human/target in proxy_mob.in_view(get_turf(proxy_mob)))
		if(target.is_invisible_to(proxy_mob))
			continue
		original_mob.add_client_image(target.hud_list[XENO_HUD])

/proc/can_process_hud(mob/M)
	if(!M)
		return 0
	if(!M.client)
		return 0
	if(M.stat != CONSCIOUS)
		return 0
	return 1

//Deletes the current HUD images so they can be refreshed with new ones.
/mob/proc/handle_hud_glasses() //Used in the life.dm of mobs that can use HUDs.
	for(var/image/hud_overlay/hud in client_images)
		remove_client_image(hud)

	GLOB.med_hud_users -= src
	GLOB.sec_hud_users -= src
	GLOB.xeno_hud_users -= src
	GLOB.gland_hud_users -= src

/mob/proc/in_view(turf/T)
	return view(T)

/mob/observer/eye/in_view(turf/T)
	var/list/viewed = new
	for(var/mob/living/carbon/human/H in SSmobs.mob_list)
		if(get_dist(H, T) <= 7)
			viewed += H
	return viewed
