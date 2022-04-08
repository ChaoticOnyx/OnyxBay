/*
		name
		key
		description
		role
		comments
		ready = 0
*/

/datum/paiCandidate/proc/savefile_path(client/user)
	return "data/players/[user.ckey]/pai.sav"

/datum/paiCandidate/proc/savefile_save(client/user)
	if(IsGuestKey(user.key))
		return 0

	var/savefile/F = new /savefile(src.savefile_path(user))

	to_file(F["name"],        name)
	to_file(F["description"], description)
	to_file(F["role"],        role)
	to_file(F["comments"],    comments)

	to_file(F["version"], 1)

	return 1

// loads the savefile corresponding to the mob's ckey
// if silent=true, report incompatible savefiles
// returns 1 if loaded (or file was incompatible)
// returns 0 if savefile did not exist

/datum/paiCandidate/proc/savefile_load(client/user, silent = 1)
	if (IsGuestKey(user.key))
		return 0

	var/path = savefile_path(user)

	if (!fexists(path))
		return 0

	var/savefile/F = new /savefile(path)

	if(!F) return //Not everyone has a pai savefile.
	var/version = null
	to_file(F["version"], version)

	if (isnull(version) || version != 1)
		fdel(path)
		if (!silent)
			alert(user, "Your savefile was incompatible with this version and was deleted.")
		return 0

	to_file(F["name"],        src.name)
	to_file(F["description"], src.description)
	to_file(F["role"],        src.role)
	to_file(F["comments"],    src.comments)
	return 1
