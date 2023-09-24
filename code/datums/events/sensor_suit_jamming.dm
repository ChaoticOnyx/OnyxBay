/datum/event/sensor_suit_jamming_base
	id = "sensor_suit_jamming_base"
	name = "Sensor Suit Jamming"
	description = "For a while, people's sensors will be jammed"

	mtth = 1 HOURS
	difficulty = 35
	fire_only_once = TRUE

	options = newlist(
		/datum/event_option/sensor_suit_jamming_option {
			id = "option_mundande";
			name = "Mundane Level";
			weight = 75;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION_R;
			event_id = "sensor_suit_jamming";
			description = "";
			severity = EVENT_LEVEL_MUNDANE;
		},
		/datum/event_option/sensor_suit_jamming_option {
			id = "option_moderate";
			name = "Moderate Level";
			weight = 15;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION;
			event_id = "sensor_suit_jamming";
			description = "";
			severity = EVENT_LEVEL_MODERATE;
		},
		/datum/event_option/sensor_suit_jamming_option {
			id = "option_major";
			name = "Major Level";
			weight = 10;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION;
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

	hide = TRUE
	triggered_only = TRUE

	var/suit_sensor_jammer_method/jamming_method

/datum/event/sensor_suit_jamming/New()
	. = ..()

	add_think_ctx("announce", CALLBACK(src, nameof(.proc/announce), 0))
	add_think_ctx("end", CALLBACK(src, nameof(.proc/end)), 0)

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
		set_next_think_ctx("announce", world.time + (30 SECONDS))

	set_next_think_ctx("end", world.time + endWhen)

/datum/event/sensor_suit_jamming/proc/end()
	jamming_method.disable()
	qdel(jamming_method)
	jamming_method = null

/datum/event/sensor_suit_jamming/proc/announce()
	SSannounce.play_station_announce(/datum/announce/level_7_biohazard)
