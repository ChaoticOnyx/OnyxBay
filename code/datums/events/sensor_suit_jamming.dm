/datum/event/sensor_suit_jamming_base
	id = "sensor_suit_jamming_base"
	name = "Sensor Suit Jamming"
	description = "For a while, people's sensors will be jammed"

	fire_only_once = TRUE
	mtth = 3 HOURS

	options = newlist(
		/datum/event_option/sensor_suit_jamming_option {
			id = "option_mundande";
			name = "Mundane Level";
			weight = 3;
			event_id = "sensor_suit_jamming";
			description = "";
			severity = EVENT_LEVEL_MUNDANE;
		},
		/datum/event_option/sensor_suit_jamming_option {
			id = "option_moderate";
			name = "Moderate Level";
			weight = 2;
			event_id = "sensor_suit_jamming";
			description = "";
			severity = EVENT_LEVEL_MODERATE;
		},
		/datum/event_option/sensor_suit_jamming_option {
			id = "option_major";
			name = "Major Level";
			weight = 1;
			event_id = "sensor_suit_jamming";
			description = "";
			severity = EVENT_LEVEL_MAJOR;
		}
	)

/datum/event/sensor_suit_jamming/get_mtth()
	. = ..()
	. -= (SSevents.triggers.living_players_count * (4 MINUTES))
	. -= (SSevents.triggers.roles_count["Medical"] * (8 MINUTES))
	. -= (SSevents.triggers.roles_count["AI"] * (20 MINUTES))
	. = max(1 HOUR, .)

/datum/event_option/sensor_suit_jamming_option
	var/severity = EVENT_LEVEL_MUNDANE

/datum/event_option/sensor_suit_jamming_option/on_choose()
	SSevents.evars["sensor_suit_jamming_severity"] = severity

/datum/event/sensor_suit_jamming
	id = "sensor_suit_jamming"
	name = "Sensor Suit Jamming"

	triggered_only = TRUE

	var/suit_sensor_jammer_method/jamming_method

/datum/event/sensor_suit_jamming/on_fire()
	var/severity = SSevents.evars["sensor_suit_jamming_severity"]
	var/endWhen = (rand(1, 3) * severity) MINUTES

	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			jamming_method = new /suit_sensor_jammer_method/random/major()
		if(EVENT_LEVEL_MODERATE)
			jamming_method = new /suit_sensor_jammer_method/random/moderate()
		else
			jamming_method = new /suit_sensor_jammer_method/random()

	jamming_method.enable()

	if(prob(75))
		addtimer(CALLBACK(GLOB.using_map, /datum/map/proc/ion_storm_announcement), 30 SECONDS)

	addtimer(CALLBACK(src, .proc/end), endWhen)

/datum/event/sensor_suit_jamming/proc/end()
	jamming_method.disable()
	qdel(jamming_method)
	jamming_method = null
