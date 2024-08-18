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

/datum/vessel_lid/Destroy()
	owner = null
	return ..()

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
			owner.verbs |= /obj/item/reagent_containers/vessel/verb/drink_whole
		if(LID_CLOSED, LID_SEALED)
			owner.atom_flags &= ~ATOM_FLAG_OPEN_CONTAINER
			owner.verbs -= /obj/item/reagent_containers/vessel/verb/drink_whole

/datum/vessel_lid/proc/toggle(mob/user)
	return

/datum/vessel_lid/proc/get_icon_state()
	if(state == LID_CLOSED || state == LID_SEALED)
		return icon_state
	return "blank"

/datum/vessel_lid/proc/get_examine_hint()
	if(state == LID_CLOSED)
		return SPAN("notice", "The airtight [name] seals it completely.")

// Generic lids - the ol' good lids
/datum/vessel_lid/lid
	name = "lid"
	state = LID_CLOSED

/datum/vessel_lid/lid/toggle(mob/user)
	switch(state)
		if(LID_CLOSED)
			owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
			state = LID_OPEN
			playsound(owner.loc, 'sound/effects/pop.ogg', rand(20, 50), 1)
			if(user)
				to_chat(usr, SPAN("notice", "You take the [name] off \the [owner]."))
			owner.verbs |= /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
		if(LID_OPEN)
			owner.atom_flags &= ~ATOM_FLAG_OPEN_CONTAINER
			state = LID_CLOSED
			if(user)
				to_chat(usr, SPAN("notice", "You put the [name] on \the [owner]."))
			owner.verbs -= /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
	return FALSE

// Corks - cosmetic thingy, the same as a regular lid
/datum/vessel_lid/cork
	name = "cork"
	state = LID_CLOSED

/datum/vessel_lid/cork/toggle(mob/user)
	switch(state)
		if(LID_CLOSED)
			owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
			state = LID_OPEN
			playsound(owner.loc, 'sound/effects/cork.ogg', rand(20, 50), 1)
			if(user)
				to_chat(usr, SPAN("notice", "You pull the [name] out of \the [owner]."))
			owner.verbs |= /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
		if(LID_OPEN)
			owner.atom_flags &= ~ATOM_FLAG_OPEN_CONTAINER
			state = LID_CLOSED
			if(user)
				to_chat(usr, SPAN("notice", "You push the [name] into \the [owner]."))
			owner.verbs -= /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
	return FALSE

// Pop tabs - one-off openers for tin cans
/datum/vessel_lid/can
	name = "tab"
	state = LID_SEALED

/datum/vessel_lid/can/toggle(mob/user)
	if(state == LID_SEALED)
		playsound(owner.loc ,'sound/effects/canopen.ogg', rand(20, 50), 1)
		if(user)
			to_chat(user, SPAN("notice", "You open \the [src] with an audible pop!"))
		owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
		state = LID_NONE
		owner.verbs |= /obj/item/reagent_containers/vessel/verb/drink_whole
		return TRUE
	return FALSE

/datum/vessel_lid/can/get_icon_state()
	if(state == LID_NONE)
		return "lid_can" // A little nasty trick
	return "blank"

/datum/vessel_lid/can/get_examine_hint()
	if(state == LID_SEALED)
		return SPAN("notice", "It's still closed.")

// Metal caps - one-off openers for beer bottles and alikes
/datum/vessel_lid/beercap
	name = "cap"
	state = LID_SEALED

/datum/vessel_lid/beercap/toggle(mob/user)
	if(state == LID_SEALED)
		playsound(owner.loc ,'sound/effects/canopen.ogg', rand(20, 50), 1)
		if(user)
			to_chat(user, SPAN("notice", "You open \the [src] with an audible pop!"))
		owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
		state = LID_NONE
		owner.verbs |= /obj/item/reagent_containers/vessel/verb/drink_whole
		return TRUE
	return FALSE

/datum/vessel_lid/beercap/get_examine_hint()
	if(state == LID_SEALED)
		return SPAN("notice", "It's still closed.")

// Carton seals - the same as pop tabs, but for cartons
/datum/vessel_lid/carton
	name = "seal"
	state = LID_SEALED

/datum/vessel_lid/carton/toggle(mob/user)
	if(state == LID_SEALED)
		playsound(owner.loc, 'sound/effects/duct_tape_peeling_off.ogg', rand(30, 40), 1)
		if(user)
			to_chat(user, SPAN("notice", "You rip open \the [owner]!"))
		owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
		state = LID_NONE
		owner.verbs |= /obj/item/reagent_containers/vessel/verb/drink_whole
		return TRUE
	return FALSE

/datum/vessel_lid/carton/get_examine_hint()
	if(state == LID_SEALED)
		return SPAN("notice", "It's still closed.")

// Sealed caps - the same as regular lids, but with an immersive effect upon the first opening
/datum/vessel_lid/cap
	name = "cap"
	state = LID_SEALED

/datum/vessel_lid/cap/toggle(mob/user)
	switch(state)
		if(LID_SEALED)
			playsound(owner.loc, 'sound/effects/bonebreak1.ogg', rand(20, 50), 1)
			if(user)
				to_chat(user, SPAN("notice", "You twist open \the [owner]'s [name], destroying the safety seal!"))
			owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
			state = LID_OPEN
			owner.verbs |= /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
		if(LID_CLOSED)
			owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
			state = LID_OPEN
			if(user)
				to_chat(usr, SPAN("notice", "You take \the [name] off \the [owner]."))
			owner.verbs |= /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
		if(LID_OPEN)
			owner.atom_flags &= ~ATOM_FLAG_OPEN_CONTAINER
			state = LID_CLOSED
			if(user)
				to_chat(usr, SPAN("notice", "You put \the [name] on \the [owner]."))
			owner.verbs -= /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
	return FALSE

/datum/vessel_lid/cap/get_examine_hint()
	if(state == LID_SEALED)
		return SPAN("notice", "It's safety seal is intact.")
	else if(state == LID_CLOSED)
		return SPAN("notice", "It's closed.")


// Flask caps - they are connected to the thing, thus have two icon states
/datum/vessel_lid/flask
	name = "cap"
	state = LID_CLOSED

/datum/vessel_lid/flask/toggle(mob/user)
	switch(state)
		if(LID_CLOSED)
			playsound(owner.loc, 'sound/effects/flask_lid2.ogg', rand(10, 30), 1)
			owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
			state = LID_OPEN
			if(user)
				to_chat(usr, SPAN("notice", "You open \the [owner]."))
			owner.verbs |= /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
		if(LID_OPEN)
			playsound(owner.loc, 'sound/effects/flask_lid1.ogg', rand(10, 30), 1)
			owner.atom_flags &= ~ATOM_FLAG_OPEN_CONTAINER
			state = LID_CLOSED
			if(user)
				to_chat(usr, SPAN("notice", "You close \the [owner]."))
			owner.verbs -= /obj/item/reagent_containers/vessel/verb/drink_whole
			return TRUE
	return FALSE

/datum/vessel_lid/flask/get_icon_state()
	if(state == LID_OPEN)
		return "o-[icon_state]"
	return "c-[icon_state]"

/datum/vessel_lid/flask/get_examine_hint()
	if(state == LID_CLOSED)
		return SPAN("notice", "It's closed.")

// Paper lids - for ramens and stuff
/datum/vessel_lid/paper
	name = "paper lid"
	state = LID_SEALED

/datum/vessel_lid/paper/toggle(mob/user)
	if(state == LID_SEALED)
		playsound(owner.loc, 'sound/effects/pageturn2.ogg', rand(20, 60), 1)
		if(user)
			to_chat(user, SPAN("notice", "You peel off \the [owner]'s [name]!"))
		owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
		state = LID_NONE
		owner.verbs |= /obj/item/reagent_containers/vessel/verb/drink_whole
		return TRUE
	return FALSE

/datum/vessel_lid/paper/get_icon_state()
	if(state == LID_SEALED)
		return "c-[icon_state]"
	return "o-[icon_state]"

/datum/vessel_lid/paper/get_examine_hint()
	if(state == LID_SEALED)
		return SPAN("notice", "It's [name] is intact.")


// Takeaway cup lids - they don't block drinking while closed
/datum/vessel_lid/takeaway
	name = "lid"
	state = LID_CLOSED

/datum/vessel_lid/takeaway/toggle(mob/user)
	playsound(owner.loc, 'sound/effects/using/bottles/papercup.ogg', rand(60, 80), 1)
	switch(state)
		if(LID_CLOSED)
			owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER // Still open, woah
			state = LID_OPEN
			if(user)
				to_chat(usr, SPAN("notice", "You take \the [name] off \the [owner]."))
			owner.verbs += /obj/item/reagent_containers/vessel/verb/drink_whole
			owner.amount_per_transfer_from_this = 10
			owner.possible_transfer_amounts = "5;10;15;30"
			return TRUE
		if(LID_OPEN)
			owner.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
			state = LID_CLOSED
			if(user)
				to_chat(usr, SPAN("notice", "You put \the [name] on \the [owner]."))
			owner.verbs -= /obj/item/reagent_containers/vessel/verb/drink_whole
			owner.amount_per_transfer_from_this = 3
			owner.possible_transfer_amounts = "3;5"
			return TRUE
	return FALSE

/datum/vessel_lid/takeaway/get_examine_hint()
	if(state == LID_OPEN)
		return SPAN("notice", "It's open.")
	else if(state == LID_CLOSED)
		return SPAN("notice", "It's closed.")
