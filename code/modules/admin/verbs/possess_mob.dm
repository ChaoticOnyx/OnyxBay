GLOBAL_LIST_EMPTY(available_mobs_for_possess)

/client/proc/toggle_possess_mode(mob/living/M in range(view))
	set name = "Toggle Possess Mode"
	set desc = "Allows players to occupy a mob."
	set category = "Fun"

	if(!check_rights(R_FUN))
		return
	if(!isliving(M))
		return
	if(M.client)
		to_chat(src, SPAN_WARNING("You can't toggle possess mode for mobs with client!"), confidential = TRUE)
		return
	if(M.ckey && copytext(M.ckey, 1, 2) == "@")
		to_chat(src, SPAN_WARNING("[M] is occupied with aghosted admin."), confidential = TRUE)
		return
	if(M.stat == DEAD)
		to_chat(src, SPAN_WARNING("[M] is dead. There's no point to toggle possess mode!"), confidential = TRUE)
		return

	M.controllable = !M.controllable
	log_and_message_admins("switched [M] possess mode for ghosts to [M.controllable ? "ON" : "OFF"]!", target = M)

	if(M.controllable)
		ghost_announce(M)
		GLOB.available_mobs_for_possess += M
	else
		GLOB.available_mobs_for_possess -= M

/proc/ghost_announce(mob/living/M)
	for(var/mob/observer/ghost/G in GLOB.player_list)
		if(G.client)
			if(jobban_isbanned(G, "Animal"))
				continue
			to_chat(G, SPAN_DEADSAY("<b>[create_ghost_link(G, M, "(F)")] [capitalize(M.name)] is now available to possess! [possess_link(G, M)]</b>"), confidential = TRUE)

/proc/possess_link(mob/observer/ghost/G, mob/living/M)
	return "<a href='byond://?src=\ref[G];possess=\ref[M]'>(Occupy)</a>"
