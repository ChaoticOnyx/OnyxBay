/datum/thalamus_start
	var/name
	var/tooltip
	var/price
	var/selected = FALSE

/datum/thalamus_start/spawn_loc/proc/deploy(mob/living/deity/deity)
	pass()

/datum/thalamus_start/spawn_loc/droppod
	name = "Precise drop"
	tooltip = ""
	price = 150

/datum/thalamus_start/spawn_loc/droppod/deploy(mob/living/deity/deity)
	var/datum/deity_power/phenomena/thalamus/droppod/pod_power = new ()
	deity.set_selected_power(pod_power)

/datum/thalamus_start/spawn_loc/random
	name = "Random location"
	tooltip = ""
	price = 100

/datum/thalamus_start/spawn_loc/random/deploy(mob/living/deity/deity)
	var/turf/target = get_safe_random_station_turf(GLOB.station_areas)
	var/datum/deity_form/thalamus/thalamus = deity.form
	thalamus.spawn_thalamus(target)

/datum/thalamus_start/spawn_loc/meteor
	name = "Meteor start"
	tooltip = ""
	price = 75

/datum/thalamus_start/spawn_loc/meteor/deploy(mob/living/deity/deity)
	SSannounce.play_station_announce(/datum/announce/meteors_detected)
	var/start_side = pick(GLOB.cardinal)
	var/zlevel = pick(GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION))
	var/turf/target_turf
	for(var/i = 0; i < rand(4, 8); i++)
		var/turf/pickedstart = spaceDebrisStartLoc(start_side, zlevel)
		var/turf/pickedgoal = spaceDebrisFinishLoc(start_side, zlevel)

		var/meteor_type = util_pick_weight(meteors_moderate)
		var/obj/effect/meteor/M = new meteor_type(pickedstart)
		M.dest = pickedgoal
		walk_towards(M, M.dest, 1)

		target_turf = pickedgoal

	var/datum/deity_form/thalamus/thalamus = deity.form
	thalamus.spawn_thalamus(target_turf)

/datum/thalamus_start/spawn_opt/defense
	name = "Advanced defense unlocked"
	tooltip = ""
	price = 50

/datum/thalamus_start/spawn_opt/walls
	name = "Reinforced Walls"
	tooltip = ""
	price = 50

/datum/thalamus_start/spawn_opt/conversion
	name = "Conversion unlocked"
	tooltip = ""
	price = 50
