// The vessel has no lid and cannot be opened or closed (drinking glasses, etc.)
#define LID_NONE 0
// The vessel has a lid, and it's open now.
#define LID_OPEN 1
// The vessel has a lid, and it's closed now.
#define LID_CLOSED 2
// The vessel has a lid, and it's never been opened yet (cans, water bottles, etc.)
#define LID_SEALED 3

/datum/vessel_lid
	var/name = "lid"
	var/obj/item/reagent_containers/vessel/owner = null
	var/state = LID_NONE
	var/icon
	var/icon_state = "lid"

/datum/vessel_lid/proc/setup(obj/item/reagent_containers/vessel/new_owner, override_state, override_icon_state)
	owner = new_owner
	icon = owner.icon
	icon_state = "lid_[owner.base_icon]"
	if(!isnull(override_state))
		state = override_state
	if(!isnull(override_icon_state))
		icon_state = override_icon_state
	switch(state)
		if(LID_NONE, LID_OPEN)
			owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
			owner.verbs += /obj/item/reagent_containers/vessel/verb/drink_whole
		if(LID_CLOSED, LID_SEALED)
			owner.atom_flags ^= ATOM_FLAG_OPEN_CONTAINER
			owner.verbs |= /obj/item/reagent_containers/vessel/verb/drink_whole

/datum/vessel_lid/proc/toggle(mob/user)
	return

/datum/vessel_lid/proc/get_icon_state()
	if(state == LID_CLOSED || state == LID_SEALED)
		return icon_state
	return "blank"

/datum/vessel_lid/proc/get_examine_hint()
	if(lid_state == LID_CLOSED)
		return SPAN("notice", "The airtight [name] seals it completely.")

// Generic lids - the ol' good lids
/datum/vessel_lid/lid
	name = "lid"
	state = LID_CLOSED

/datum/vessel_lid/lid/toggle(mob/user)
	switch(lid_state)
		if(LID_CLOSED)
			owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
			state = LID_OPEN
			if(user)
				to_chat(usr, SPAN("notice", "You take the [name] off \the [owner]."))
			owner.verbs += /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
		if(LID_OPEN)
			owner.atom_flags ^= ATOM_FLAG_OPEN_CONTAINER
			state = LID_CLOSED
			if(user)
				to_chat(usr, SPAN("notice", "You put the [name] on \the [owner]."))
			owner.verbs |= /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
	return FALSE

// Corks - cosmetic thingy, the same as a regular lid
/datum/vessel_lid/cork
	name = "cork"
	state = LID_CLOSED

/datum/vessel_lid/cork/toggle(mob/user)
	switch(lid_state)
		if(LID_CLOSED)
			owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
			state = LID_OPEN
			if(user)
				to_chat(usr, SPAN("notice", "You pull the [name] out of \the [owner]."))
			owner.verbs += /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
		if(LID_OPEN)
			owner.atom_flags ^= ATOM_FLAG_OPEN_CONTAINER
			state = LID_CLOSED
			if(user)
				to_chat(usr, SPAN("notice", "You push the [name] into \the [owner]."))
			owner.verbs |= /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
	return FALSE

// Pop tabs - one-off openers for tin cans
/datum/vessel_lid/can
	name = "tab"
	state = LID_SEALED

/datum/vessel_lid/can/toggle(mob/user)
	if(lid_state == LID_SEALED)
		playsound(owner.loc ,'sound/effects/canopen.ogg', rand(10, 50), 1)
		if(user)
			to_chat(user, SPAN("notice", "You open \the [src] with an audible pop!"))
		owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
		state = LID_NONE
		owner.verbs += /obj/item/reagent_containers/vessel/verb/drink_whole
		return TRUE
	return FALSE

/datum/vessel_lid/can/get_icon_state()
	if(state == LID_NONE)
		return "lid_can" // A little nasty trick
	return "blank"

/datum/vessel_lid/can/get_examine_hint()
	if(lid_state == LID_SEALED)
		return SPAN("notice", "It's still closed.")

// Metal caps - one-off openers for beer bottles and alikes
/datum/vessel_lid/beercap
	name = "cap"
	state = LID_SEALED

/datum/vessel_lid/beercap/toggle(mob/user)
	if(lid_state == LID_SEALED)
		playsound(owner.loc ,'sound/effects/canopen.ogg', rand(10, 50), 1)
		if(user)
			to_chat(user, SPAN("notice", "You open \the [src] with an audible pop!"))
		owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
		state = LID_NONE
		owner.verbs += /obj/item/reagent_containers/vessel/verb/drink_whole
		return TRUE
	return FALSE

/datum/vessel_lid/beercap/get_examine_hint()
	if(lid_state == LID_SEALED)
		return SPAN("notice", "It's still closed.")

// Carton seals - the same as pop tabs, but for cartons
/datum/vessel_lid/carton
	name = "seal"
	state = LID_SEALED

/datum/vessel_lid/carton/toggle(mob/user)
	if(lid_state == LID_SEALED)
		if(user)
			to_chat(user, SPAN("notice", "You rip open \the [src]!"))
		owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
		state = LID_NONE
		owner.verbs += /obj/item/reagent_containers/vessel/verb/drink_whole
		return TRUE
	return FALSE

/datum/vessel_lid/carton/get_examine_hint()
	if(lid_state == LID_SEALED)
		return SPAN("notice", "It's still closed.")

// Sealed caps - the same as regular lids, but with an immersive effect upon the first opening
/datum/vessel_lid/cap
	name = "cap"
	state = LID_SEALED

/datum/vessel_lid/cap/toggle(mob/user)
	switch(lid_state)
		if(LID_SEALED)
			playsound(owner.loc, 'sound/effects/bonebreak1.ogg', rand(10, 50), 1)
			if(user)
				to_chat(user, SPAN("notice", "You twist open \the [owner]'s [cap], destroying the safety seal!"))
			owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
			state = LID_OPEN
			owner.verbs += /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
		if(LID_CLOSED)
			owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
			state = LID_OPEN
			if(user)
				to_chat(usr, SPAN("notice", "You put \the [name] on \the [owner]."))
			owner.verbs += /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
		if(LID_OPEN)
			owner.atom_flags ^= ATOM_FLAG_OPEN_CONTAINER
			state = LID_CLOSED
			if(user)
				to_chat(usr, SPAN("notice", "You take \the [name] off \the [owner]."))
			owner.verbs |= /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
	return FALSE

/datum/vessel_lid/cap/get_examine_hint()
	if(lid_state == LID_SEALED)
		return SPAN("notice", "It's safety seal is intact.")
	else if(lid_state == LID_CLOSED)
		return SPAN("notice", "It's closed.")
