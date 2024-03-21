/datum/event
	var/_mtth_passed = 0
	var/_waiting_option = 0

	var/id = null
	var/name = "EVENT_NAME"
	var/description = "EVENT_DESCRIPTION"

	/// Median time to happen.
	var/mtth = 0
	var/fired = FALSE
	var/triggered_only = FALSE
	var/fire_only_once = FALSE
	var/list/options = list()
	var/hide = FALSE
	/// Some storytellers have difficulty caps, which use this value.
	var/difficulty = 10

	var/list/blacklisted_maps = list()

/datum/event/New()
	ASSERT(id != null)
	ASSERT(mtth >= 0)

	if(!triggered_only && mtth == 0)
		CRASH("event '[name]' has invalid mtth: [mtth]")

	for(var/datum/event_option/O in options)
		O._event = src

/datum/event/Destroy()
	SSevents.scheduled_events -= src
	SSevents.total_events -= id
	QDEL_LIST(options)

	. = ..()

/datum/event/proc/get_conditions_description()
	return

/datum/event/proc/get_description()
	return description

/datum/event/proc/calc_chance()
	var/time = get_mtth()

	if(time == 0)
		return 0

	var/tick_chance = 1 - (2.718 ** (log(0.5) / mtth))

	return 1 - (2.718 ** (_mtth_passed * log(1 - tick_chance)))

/datum/event/proc/get_mtth()
	return mtth * abs(SSstoryteller.character.rarity_ratio)

/datum/event/proc/check_conditions()
	return TRUE

/datum/event/proc/on_fire()
	return

/datum/event/proc/ai_choose()
	if(!length(options))
		_waiting_option = 0
		return

	var/list/options_weight = list()

	for(var/datum/event_option/O in options)
		var/o_weight = round(O.get_weight())
		if(o_weight > 0)
			options_weight[O] = o_weight

	var/datum/event_option/O = util_pick_weight(options_weight)
	log_and_message_admins("AI has chosen the option '[O.name]' ([O.id]) for the event '[name]' ([id])")
	_waiting_option = 0
	O.choose()

/datum/event/proc/notify_admins()
	for(var/client/C in GLOB.admins)
		var/mob/M = C.mob

		if(!C.holder || !M.has_admin_rights() || C.get_preference_value(/datum/client_preference/staff/show_events) != GLOB.PREF_SHOW)
			continue

		new /datum/event_window(C.holder, src)

/datum/event/proc/fire()
	if(_mtth_passed)
		_mtth_passed = 0

	if(fire_only_once)
		if(fired)
			CRASH("Event '[name]' ([id]) fired twice")

		fired = TRUE

	log_and_message_admins("Firing the event '[name]' ([id])")
	on_fire()

	if(length(options))
		log_and_message_admins("Waiting for an option for the event '[name]' ([id])")
		_waiting_option = world.time + 2 MINUTES
	else
		after_fire()

	if(!hide)
		notify_admins()

/datum/event/proc/after_fire()
	log_debug("After fire event '[name]' ([id])")
	_waiting_option = 0
