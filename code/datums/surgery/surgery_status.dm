/datum/surgery_status
	/**
	 * List of zones where surgery steps are currently performed.
	 */
	var/list/ongoing_steps = list()
	/**
	 * Associative list of string -> type, where string is zone name and
	 * type is a reference to an operated organ.
	 */
	var/list/operated_organs = list()

/datum/surgery_status/proc/start_surgery(obj/item/organ/target_organ, target_zone)
	LAZYADD(ongoing_steps, target_zone)
	LAZYADDASSOC(operated_organs, target_zone, target_organ)

/datum/surgery_status/proc/stop_surgery(target_zone)
	LAZYREMOVE(ongoing_steps, target_zone)
	LAZYREMOVE(operated_organs, target_zone)
