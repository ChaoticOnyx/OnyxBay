/mob
	/// List of movement speed modifiers applying to this mob
	var/list/movespeed_modification //Lazy list, see mob_movespeed.dm
	/// List of movement speed modifiers ignored by this mob. List -> List (id) -> List (sources)
	var/list/movespeed_mod_immunities //Lazy list, see mob_movespeed.dm
	/// The calculated mob speed slowdown based on the modifiers list
	var/cached_slowdown
	/// The calculated mob speed slowdown for /space turfs
	var/cached_slowdown_space

///Ignores specific slowdowns. Accepts a list of slowdowns.
/mob/proc/add_movespeed_mod_immunities(source, slowdown_type, update = TRUE)
	if(islist(slowdown_type))
		for(var/listed_type in slowdown_type)
			if(ispath(listed_type))
				listed_type = "[listed_type]"
			LAZYADDASSOC(movespeed_mod_immunities, listed_type, source)
	else
		if(ispath(slowdown_type))
			slowdown_type = "[slowdown_type]"
		LAZYADDASSOC(movespeed_mod_immunities, slowdown_type, source)
	if(update)
		update_movespeed()

///Unignores specific slowdowns. Accepts a list of slowdowns.
/mob/proc/remove_movespeed_mod_immunities(source, slowdown_type, update = TRUE)
	if(islist(slowdown_type))
		for(var/listed_type in slowdown_type)
			if(ispath(listed_type))
				listed_type = "[listed_type]"
			LAZYREMOVEASSOC(movespeed_mod_immunities, listed_type, source)
	else
		if(ispath(slowdown_type))
			slowdown_type = "[slowdown_type]"
		LAZYREMOVEASSOC(movespeed_mod_immunities, slowdown_type, source)
	if(update)
		update_movespeed()
