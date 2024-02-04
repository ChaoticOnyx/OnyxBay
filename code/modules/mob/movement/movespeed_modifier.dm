/*! Port of movespeed modifiers from /TG/ with changes.
Now, instead of recalculating movespeed every /Move(), we add modifier datums to mobs.
Nonvariable modifiers are globally cached, variable are instanced and changed when required through /add_or_update_variable_movespeed_modifier()
Movespeed modification list is a key = datum system. Key will be the datum's ID if it is overridden to not be null, or type if it is not.

DO NOT override datum IDs unless you are going to have multiple types that must overwrite each other; IDs are reserved for dynamic replacement of modifiers (e.g. walk/run modifier)
update_movespeed() calculates new slowdown based on present modifiers and stores it in a variable, readily available for /Move() and other procs.
*/

/datum/movespeed_modifier
	/// Whether or not this is a variable modifier. Variable modifiers can NOT be ever auto-cached. ONLY CHECKED VIA INITIAL(), EFFECTIVELY READ ONLY (and for very good reason)
	var/variable = FALSE

	/// Unique ID. You can never have different modifications with the same ID. By default, this SHOULD NOT be set. Only set it for cases where you're dynamically making modifiers/need to have two types overwrite each other. If unset, uses path (converted to text) as ID.
	var/id

	/// Flags for specific behaviour, for example if a modifier should overwrite movespeed.
	var/flags = 0

	/// Slowdown
	var/slowdown = 0

	/// Priority for cases when you need to calculate a given modifier last
	var/priority = MOVESPEED_PRIORITY_NORMAL

/datum/movespeed_modifier/New()
	. = ..()
	if(!id)
		id = "[type]" //We turn the path into a string.

GLOBAL_LIST_EMPTY(movespeed_modification_cache)

/// Grabs a STATIC MODIFIER datum from cache. YOU MUST NEVER EDIT THESE DATUMS, OR IT WILL AFFECT ANYTHING ELSE USING IT TOO!
/proc/get_cached_movespeed_modifier(modtype)
	if(!ispath(modtype, /datum/movespeed_modifier))
		CRASH("[modtype] is not a movespeed modification typepath.")
	var/datum/movespeed_modifier/M = modtype
	if(initial(M.variable))
		CRASH("[modtype] is a variable modifier, and can never be cached.")
	M = GLOB.movespeed_modification_cache[modtype]
	if(!M)
		M = GLOB.movespeed_modification_cache[modtype] = new modtype
	return M

///Add a move speed modifier to a mob. If a variable subtype is passed in as the first argument, it will make a new datum. If ID conflicts, it will overwrite the old ID.
/mob/proc/add_movespeed_modifier(datum/movespeed_modifier/type_or_datum, update = TRUE)
	if(ispath(type_or_datum))
		if(!initial(type_or_datum.variable))
			type_or_datum = get_cached_movespeed_modifier(type_or_datum)
		else
			type_or_datum = new type_or_datum
	var/datum/movespeed_modifier/existing = LAZYACCESS(movespeed_modification, type_or_datum.id)
	if(existing)
		if(existing == type_or_datum) //same thing don't need to touch
			return TRUE
		remove_movespeed_modifier(existing, FALSE)
	if(length(movespeed_modification))
		BINARY_INSERT(type_or_datum.id, movespeed_modification, /datum/movespeed_modifier, type_or_datum, priority, COMPARE_VALUE)
	LAZYSET(movespeed_modification, type_or_datum.id, type_or_datum)
	if(update)
		update_movespeed()
	return TRUE

/// Remove a move speed modifier from a mob, whether static or variable.
/mob/proc/remove_movespeed_modifier(datum/movespeed_modifier/type_id_datum, update = TRUE)
	var/key
	if(ispath(type_id_datum))
		key = initial(type_id_datum.id) || "[type_id_datum]" //id if set, path set to string if not.
	else if(!istext(type_id_datum)) //if it isn't text it has to be a datum, as it isn't a type.
		key = type_id_datum.id
	else //assume it's an id
		key = type_id_datum
	if(!LAZYACCESS(movespeed_modification, key))
		return FALSE
	LAZYREMOVE(movespeed_modification, key)
	if(update)
		update_movespeed()
	return TRUE

/*! Used for variable slowdowns like hunger/health loss/etc, works somewhat like the old list-based modification adds. Returns the modifier datum if successful
	How this SHOULD work is:
	1. Ensures type_id_datum one way or another refers to a /variable datum. This makes sure it can't be cached. This includes if it's already in the modification list.
	2. Instantiate a new datum if type_id_datum isn't already instantiated + in the list, using the type. Obviously, wouldn't work for ID only.
	3. Add the datum if necessary using the regular add proc
	4. If any of the rest of the args are not null (slowdown for example), modify the datum
	5. Update if necessary
*/
/mob/proc/add_or_update_variable_movespeed_modifier(datum/movespeed_modifier/type_id_datum, update = TRUE, slowdown)
	var/modified = FALSE
	var/inject = FALSE
	var/datum/movespeed_modifier/final
	if(istext(type_id_datum))
		final = LAZYACCESS(movespeed_modification, type_id_datum)
		if(!final)
			CRASH("Couldn't find existing modification when provided a text ID.")
	else if(ispath(type_id_datum))
		if(!initial(type_id_datum.variable))
			CRASH("Not a variable modifier")
		final = LAZYACCESS(movespeed_modification, initial(type_id_datum.id) || "[type_id_datum]")
		if(!final)
			final = new type_id_datum
			inject = TRUE
			modified = TRUE
	else
		if(!initial(type_id_datum.variable))
			CRASH("Not a variable modifier")
		final = type_id_datum
		if(!LAZYACCESS(movespeed_modification, final.id))
			inject = TRUE
			modified = TRUE
	if(!isnull(slowdown))
		final.slowdown = slowdown
		modified = TRUE
	if(inject)
		add_movespeed_modifier(final, FALSE)
	if(update && modified)
		update_movespeed(TRUE)
	return final

///Is there a movespeed modifier for this mob
/mob/proc/has_movespeed_modifier(datum/movespeed_modifier/datum_type_id)
	var/key
	if(ispath(datum_type_id))
		key = initial(datum_type_id.id) || "[datum_type_id]"
	else if(istext(datum_type_id))
		key = datum_type_id
	else
		key = datum_type_id.id
	return LAZYACCESS(movespeed_modification, key)

/// Get the global config movespeed of a mob by type
/mob/proc/get_config_multiplicative_speed()
	return config.movement.human_delay

/// Go through the list of movespeed modifiers and calculate a final movespeed. ANY ADD/REMOVE DONE IN UPDATE_MOVESPEED MUST HAVE THE UPDATE ARGUMENT SET AS FALSE!
/mob/proc/update_movespeed()
	var/calculated_slowdown = 0
	var/calculated_slowdown_space = 0
	for(var/key in get_movespeed_modifiers())
		var/datum/movespeed_modifier/M = movespeed_modification[key]
		var/amt = M.slowdown
		calculated_slowdown += amt

		if(M.flags & MOVESPEED_FLAG_SPACEMOVEMENT)
			calculated_slowdown_space += amt

		if(M.flags & MOVESPEED_FLAG_OVERRIDING_SPEED)
			cached_slowdown = M.slowdown
			return

	cached_slowdown = calculated_slowdown
	cached_slowdown_space = calculated_slowdown_space
	SEND_SIGNAL(src, SIGNAL_MOB_MOVESPEED_UPDATED)

/// Get the move speed modifiers list of the mob
/mob/proc/get_movespeed_modifiers()
	. = LAZYCOPY(movespeed_modification)
	for(var/id in movespeed_mod_immunities)
		. -= id
