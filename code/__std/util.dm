/// Call to generate a stack trace and print to runtime logs
/proc/util_crash_with(msg)
	CRASH(msg)

/// Picks a random element from a list based on a weighting system.
/// For example, given the following list:
/// A = 6, B = 3, C = 1, D = 0
/// A would have a 60% chance of being picked,
/// B would have a 30% chance of being picked,
/// C would have a 10% chance of being picked,
/// and D would have a 0% chance of being picked.
/// You should only pass integers in.
/proc/util_pick_weight(list/list_to_pick)
	var/total = 0
	var/item
	for(item in list_to_pick)
		if(list_to_pick[item] == null)
			list_to_pick[item] = 1
		total += list_to_pick[item]

	total = rand(0, total)
	for(item in list_to_pick)
		total -= list_to_pick[item]
		if(total <= 0 && list_to_pick[item])
			return item

	return null

// Walks up the loc tree until it finds wrong loc or go to null
// stop_on is list of types of loc where check also must stop
/proc/check_locs(atom/A, list/stop_on, checking_proc)
	var/atom/loc = A.loc
	var/is_correct = TRUE

	while(loc && is_correct)
		for(var/type in stop_on)
			if(istype(loc, type))
				return TRUE
		is_correct = call(A, checking_proc)(loc)
		loc = loc.loc
	return is_correct

// Walks up the loc tree until loc is mob or turf.
// Needed for check of presence of any embedded item/effect etc in hand of character.
/proc/get_top_holder_obj(atom/A)
	var/atom/holder = A
	while(holder.loc && istype(holder.loc, /obj))
		holder = holder.loc
	return holder
