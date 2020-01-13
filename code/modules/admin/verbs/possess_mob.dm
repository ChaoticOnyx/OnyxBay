GLOBAL_LIST_EMPTY(available_mobs_for_possess)

/client/proc/toggle_possess_mode(mob/living/M in range(world.view))
	set name = "Toggle possess mode for ghosts"

	if(M.controllable)
		if(M.client)
			to_chat(src, SPAN_WARNING("You can't toggle ON possess mode for mobs with client!"))
			return
		if(M.stat == DEAD)
			to_chat(src, SPAN_WARNING("[M] is dead. There's no point to toggle possess mode!"))
			return

	M.controllable = !M.controllable
	log_and_message_admins("Switched [M] possess mode for ghosts to [M.controllable ? "ON" : "OFF"]! [get_admin_jump_link(M)]")

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
			to_chat(G, SPAN_DEADSAY("[possess_link(M, G)] [create_ghost_link(M, G, "(F)")] is now available to possess!"))

/proc/possess_link(mob/living/M, mob/observer/ghost/G)
	return "<a href='?src=\ref[G];possess=\ref[M]'>[M] (Occupy)</a>"
