/// Designates the atom as a "point of interest", meaning it can be directly orbited.
/datum/element/point_of_interest
	element_flags = ELEMENT_DETACH

/datum/element/point_of_interest/attach(datum/target)
	if (!isatom(target))
		return ELEMENT_INCOMPATIBLE

	/// Something is FUBAR if this tries to attach itself to a new player abstract mob.
	if(isnewplayer(target))
		return ELEMENT_INCOMPATIBLE

	SSpoints_of_interest.on_poi_element_added(target)
	return ..()

/datum/element/point_of_interest/detach(datum/target)
	SSpoints_of_interest.on_poi_element_removed(target)
	return ..()
