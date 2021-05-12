#define FORWARD -1
#define BACKWARD 1

/datum/construction
	var/list/steps
	var/atom/holder
	var/result
	var/list/steps_desc

/datum/construction/New(atom)
	..()
	holder = atom
	// don't want this without a holder
	if(!holder)
		spawn
			qdel(src)
	set_desc(steps.len)
	return

/datum/construction/proc/next_step()
	steps.len--
	if(!steps.len)
		spawn_result()
	else
		set_desc(steps.len)
	return

/datum/construction/proc/action(atom/used_atom, mob/user)
	CAN_BE_REDEFINED(TRUE)
	return

// check last step only
/datum/construction/proc/check_step(atom/used_atom, mob/user)
	var/valid_step = is_right_key(used_atom)
	if(valid_step)
		if(custom_action(valid_step, used_atom, user))
			next_step()
			return 1
	return 0

// returns current step num if used_atom is of the right type.
/datum/construction/proc/is_right_key(atom/used_atom)
	var/list/L = steps[steps.len]
	if(istype(used_atom, L["key"]))
		return steps.len
	return 0

/datum/construction/proc/custom_action(step, used_atom, user)
	CAN_BE_REDEFINED(TRUE)
	return 1

// check all steps, remove matching one.
/datum/construction/proc/check_all_steps(atom/used_atom, mob/user)
	for(var/i=1;i<=steps.len;i++)
		var/list/L = steps[i];
		if(istype(used_atom, L["key"]))
			if(custom_action(i, used_atom, user))
				// stupid byond list from list removal...
				steps[i] = null
				listclearnulls(steps)
				if(!steps.len)
					spawn_result()
				return 1
	return 0


/datum/construction/proc/spawn_result()
	if(result)
		new result(get_turf(holder))
		spawn()
			qdel(holder)
	return

/datum/construction/proc/set_desc(index)
	var/list/step = steps[index]
	holder.desc = step["desc"]
	return

/datum/construction/reversible
	var/index

/datum/construction/reversible/New(atom)
	..()
	index = steps.len
	return

/datum/construction/reversible/proc/update_index(diff)
	index+=diff
	if(index==0)
		spawn_result()
	else
		set_desc(index)
	return

// returns index step
/datum/construction/reversible/is_right_key(atom/used_atom)
	var/list/L = steps[index]
	if(istype(used_atom, L["key"]))
		// to the first step -> forward
		return FORWARD
	else if(L["backkey"] && istype(used_atom, L["backkey"]))
		// to the last step -> backwards
		return BACKWARD
	return 0

/datum/construction/reversible/check_step(atom/used_atom, mob/user)
	var/diff = is_right_key(used_atom)
	if(diff)
		if(custom_action(index, diff, used_atom, user))
			update_index(diff)
			return 1
	return 0

/datum/construction/reversible/custom_action(index, diff, used_atom, user)
	CAN_BE_REDEFINED(TRUE)
	return 1
