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
		if(!list_to_pick[item])
			list_to_pick[item] = 0
		total += list_to_pick[item]

	total = rand(0, total)
	for(item in list_to_pick)
		total -= list_to_pick[item]
		if(total <= 0 && list_to_pick[item])
			return item

	return null
