/mob/living/deity/verb/jump_to_follower()
	set category = "Godhood"

	if(!minions)
		return

	var/list/could_follow = list()
	for(var/m in minions)
		var/datum/mind/M = m
		if(M.current && M.current.stat != DEAD)
			could_follow += M.current

	if(!could_follow.len)
		return

	var/choice = input(src, "Jump to follower", "Teleport") as null|anything in could_follow
	if(choice)
		follow_follower(choice)

/mob/living/deity/proc/follow_follower(mob/living/L)
	if(!L || L.stat == DEAD || !is_follower(L, silent=1))
		return
	if(following)
		stop_follow()
	eyeobj.setLoc(get_turf(L))
	to_chat(src, "<span class='notice'>You begin to follow \the [L].</span>")
	following = L
	register_signal(L, SIGNAL_MOVED, /mob/living/deity/proc/keep_following)
	register_signal(L, SIGNAL_QDELETING, /mob/living/deity/proc/stop_follow)
	register_signal(L, SIGNAL_MOB_DEATH, /mob/living/deity/proc/stop_follow)

/mob/living/deity/proc/stop_follow()
	unregister_signal(following, SIGNAL_MOVED)
	unregister_signal(following, SIGNAL_QDELETING)
	unregister_signal(following, SIGNAL_MOB_DEATH)
	to_chat(src, "<span class='notice'>You stop following \the [following].</span>")
	following = null

/mob/living/deity/proc/keep_following(atom/movable/moving_instance, atom/old_loc, atom/new_loc)
	eyeobj.setLoc(new_loc)
