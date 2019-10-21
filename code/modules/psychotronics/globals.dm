GLOBAL_DATUM_INIT(neuromods, /datum/neuromods, new)
GLOBAL_DATUM_INIT(lifeforms, /datum/lifeforms, new)
GLOBAL_LIST_EMPTY(psychoscope_hud_users)  // List of all entities using a psychoscope HUD.

/* LIST OF NEUROMODS */

/datum/neuromods
	var/list/datum/neuromod/list_of_neuromods = null

/*
	Returns an ui-compatible list with a neuromod data.

	Inputs:
	neuromod_path - `path` or `string` of a neuromod

	Returns:
	list(...) - see /datum/neuromod/ToList() proc
	OR
	null
*/
/datum/neuromods/proc/ToList(neuromod_path)
	if (!neuromod_path)
		crash_with("neuromod_path is null")
		return null

	var/datum/neuromod/N = Get(neuromod_path)

	if (!N)
		crash_with("trying to get [neuromod_path] but it is not exists")
		return null

	return (N.ToList())

/*
	Get a reference of a neuromod by a path

	Inputs:
	neuromod_path - `path` or `string` of a neuromod

	Returns:
	/datum/neuromod/
	OR
	null
*/
/datum/neuromods/proc/Get(neuromod_path)
	if (!neuromod_path)
		crash_with("neuromod_path is null")
		return null

	if (!ispath(neuromod_path))
		neuromod_path = text2path(neuromod_path)

	var/datum/neuromod/N = (locate(neuromod_path) in list_of_neuromods)

	if (!N)
		crash_with("trying to get [neuromod_path] but is is not exists")

	return N

/datum/neuromods/New()
	list_of_neuromods = list()

	for (var/N in subtypesof(/datum/neuromod))
		list_of_neuromods += (new N())

/* LIST OF LIFEFORMS */

/datum/lifeforms
	var/list/datum/lifeform/list_of_lifeforms = null

/*
	Returns an ui-compatible list with a lifeform data

	Inputs:
	user - required for icon2html proc
	lifeform_path - `path` or `string` of a lifeform

	Returns:
	list(...) - see /datum/lifeform/ToList() proc
	OR
	null
*/
/datum/lifeforms/proc/ToList(mob/user, lifeform_path)
	if (!user)
		crash_with("user is null")
		return null

	if (!lifeform_path)
		crash_with("lifeform_path is null")
		return null

	var/datum/lifeform/lifeform = Get(lifeform_path)

	if (!lifeform)
		crash_with("trying to get [lifeform_path] but it is not exists")
		return null

	return (lifeform.ToList(user))

/*
	Get a reference for a lifeform

	Inputs:
	lifeform_path - `path` or `string` for a lifeform

	Returns:
	/datum/lifeform/
	OR
	null
*/
/datum/lifeforms/proc/Get(lifeform_path)
	if (!lifeform_path)
		crash_with("lifeform_path is null")

	if (istext(lifeform_path))
		lifeform_path = text2path(lifeform_path)

	var/datum/lifeform/L = (locate(lifeform_path) in list_of_lifeforms)

	if (!L)
		crash_with("trying to get [lifeform_path] but it is not exists")
		return null

	return L

/*
	Get a reference of a lifeform by a mob reference

	Inputs:
	target - mob reference

	Returns
	/datum/lifeform/
	OR
	null
*/
/datum/lifeforms/proc/GetByMob(mob/target)
	if (!target)
		return null

	return (GetByMobType(target.type))

/*
	Get a reference of a lifeform by a mob type

	Inputs:
	mob_type - `path` or `string` of a mob

	Returns
	/datum/lifeform/
	OR
	null
*/
/datum/lifeforms/proc/GetByMobType(mob_type)
	if (!mob_type)
		crash_with("mob_type is null")

	if (istext(mob_type))
		mob_type = text2path(mob_type)

	for (var/datum/lifeform/L in list_of_lifeforms)
		if (L.mob_type == mob_type)
			return L

	crash_with("trying to get [mob_type] but it is not exists")
	return null

/datum/lifeforms/New()
	list_of_lifeforms = list()

	for (var/L in subtypesof(/datum/lifeform))
		list_of_lifeforms += (new L())