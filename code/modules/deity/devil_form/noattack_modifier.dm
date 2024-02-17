/datum/modifier/noattack
	/// Atom that cannot be attacked
	var/weakref/atom_target
	var/applies_to_ranged = FALSE

/datum/modifier/noattack/New(new_holder, new_origin, atom/target)
	. = ..()
	if(!istype(target))
		qdel_self()

	atom_target = weakref(target)
