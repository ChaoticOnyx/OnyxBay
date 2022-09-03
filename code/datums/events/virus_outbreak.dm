/datum/event2/virus_outbreak_base
	id = "virus_outbreak_base"
	name = "Virus Outbreak Incoming"
	description = "An unknown virus appears at the station"

	mtth = 4 HOURS
	fire_only_once = TRUE

	options = newlist(
		/datum/event_option {
			id = "option_minor";
			name = "Minor Virus";
			description = "A not too strong virus will appear on the station";
			weight = 2;
			event_id = "virus_outbreak_minor";
		},
		/datum/event_option {
			id = "option_major";
			name = "Major Virus";
			description = "A fairly powerful virus will appear on the station";
			weight = 1;
			event_id = "virus_outbreak_major";
		}
	)

/datum/event2/virus_outbreak_base/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Medical"] * (12 MINUTES))
	. = max(1 HOUR, .)

/datum/event2/virus_outbreak_minor
	id = "virus_outbreak_minor"
	name = "Virus Outbreak (minor)"

	triggered_only = TRUE

/datum/event2/virus_outbreak_minor/on_fire()
	var/next_outbreak = pick(
		/datum/ictus/retrovirus,
		/datum/ictus/cold9,
		/datum/ictus/flu,
		/datum/ictus/vulnerability,
		/datum/ictus/xeno,
		/datum/ictus/hisstarvation,
		/datum/ictus/musclerace,
		/datum/ictus/space_migraine)

	new next_outbreak

/datum/event2/virus_outbreak_major
	id = "virus_outbreak_major"
	name = "Virus Outbreak (major)"

	triggered_only = TRUE

/datum/event2/virus_outbreak_major/on_fire()
	var/next_outbreak = pick(
		/datum/ictus/gbs,
		/datum/ictus/fake_gbs,
		/datum/ictus/nuclear,
		/datum/ictus/fluspanish,
		/datum/ictus/emp)

	new next_outbreak
