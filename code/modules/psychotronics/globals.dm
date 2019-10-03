GLOBAL_DATUM_INIT(neuromods, /datum/neuromods, new)
GLOBAL_DATUM_INIT(lifeforms, /datum/lifeforms, new)
GLOBAL_LIST_EMPTY(psychoscope_hud_users)  // List of all entities using a psychoscope HUD.

/* LIST OF NEUROMODS */

/datum/neuromods
	var/list/datum/neuromod/list_of_neuromods = null

/datum/neuromods/proc/ToList(var/neuromod_path)
	var/datum/neuromod/N = Get(neuromod_path)

	if (!N) return null

	return (N.ToList())

/datum/neuromods/proc/Get(var/neuromod_path)
	if (!neuromod_path)
		return null

	if (!ispath(neuromod_path))
		neuromod_path = text2path(neuromod_path)

	var/datum/neuromod/N = (locate(neuromod_path) in list_of_neuromods)

	return N

/datum/neuromods/New()
	list_of_neuromods = list()

	for (var/N in subtypesof(/datum/neuromod))
		list_of_neuromods += (new N())

/* LIST OF LIFEFORMS */

/datum/lifeforms
	var/list/datum/lifeform/list_of_lifeforms = null

/datum/lifeforms/proc/ToList(mob/user, var/lifeform_path)
	if (!user) return null

	var/datum/lifeform/lifeform = Get(lifeform_path)

	if (!lifeform) return null

	return (lifeform.ToList(user))

/datum/lifeforms/proc/Get(var/lifeform_path)
	if (!lifeform_path)
		return

	if (istext(lifeform_path))
		return (locate(text2path(lifeform_path)) in list_of_lifeforms)
	else if (ispath(lifeform_path))
		return (locate(lifeform_path) in list_of_lifeforms)

	return null

/datum/lifeforms/proc/GetByMob(var/mob/M)
	if (!M)
		return null

	return (GetByMobType(M.type))

/datum/lifeforms/proc/GetByMobType(var/mob_type)
	for (var/datum/lifeform/L in list_of_lifeforms)
		if (L.mob_type == mob_type)
			return L

	return null

/datum/lifeforms/New()
	list_of_lifeforms = list()

	for (var/L in subtypesof(/datum/lifeform))
		list_of_lifeforms += (new L())