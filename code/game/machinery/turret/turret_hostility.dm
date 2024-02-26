// A singleton useful for recycling hostility logic in things such as mobs or turrets.
/datum/hostility

// Returns a value determining whether or not whatever is calling should attack the target.
// Don't override this, go override `can_special_target()`, as this proc has 'the basics' that everything should use.
/datum/hostility/proc/can_target(atom/holder, atom/movable/target)
	SHOULD_NOT_OVERRIDE(TRUE)
	. = TRUE
	if(!istype(target))
		return FALSE
	if(isobserver(target))
		return FALSE

	if(isliving(target))
		var/mob/living/L = target
		if(L.stat)
			return FALSE

		if(isliving(holder))
			var/mob/living/H = holder
			if(L.faction == H.faction)
				return FALSE

	return can_special_target(holder, target)

// Override this for subtypes.
/datum/hostility/proc/can_special_target(atom/holder, atom/movable/target)
	return TRUE

/datum/hostility/turret/can_special_target(atom/movable/target)
	if(isliving(target))
		return TRUE

// Network turret hostility
/datum/hostility/turret/network
	var/static/threat_level_threshold = 4

/datum/hostility/turret/network/can_special_target(atom/holder, atom/movable/target)
	var/obj/machinery/turret/network/owner = holder
	if(!istype(holder))
		log_error("Network turret hostility referenced with a non turret holder: [holder]!")
		return

	if(target.invisibility >= INVISIBILITY_LEVEL_ONE)
		return FALSE

	if(!emagged && issilicon(target))
		return FALSE

	if(emagged && !isAI(target))
		return TRUE

	if(owner.check_synth && !issilicon(target))
		return TRUE

	if(!ishuman(target))
		// Attack any living, non-small/silicon/human target.
		if(owner.check_anomalies)
			if(isliving(target) && (!issilicon(target) && !issmall(target)))
				return TRUE
		return FALSE

	var/mob/living/L = target
	return L.assess_perp(holder, owner.check_access, owner.check_weapons, owner.check_records, owner.check_arrest) >= threat_level_threshold
