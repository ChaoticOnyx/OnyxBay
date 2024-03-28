/// The number of raw vis spawned per deity
#define VIS_PER_DEITY 5

/// It is a singleton-like datum, so
GLOBAL_DATUM_INIT(raw_vis_tracker, /datum/raw_vis_tracker, new)

/**
 * A global singleton data that tracks all raw vis
 * and all of the minds that can see them.
 *
 * Ensures that all minds can see vis sources, generates new raw vis
 * And also handles so that minds will see newly generated vis sources.
 */
/datum/raw_vis_tracker
	/// The total number of sources that have been drained, for tracking.
	var/num_drained = 0
	/// List of tracked raw vis sources
	var/list/obj/effect/raw_vis/vises = list()
	/// List of minds with the ability to see vis sources
	var/list/datum/mind/tracked_minds = list()
	/// Subtypes of areas where raw vis can spawn
	var/list/area/areas = list(
		/area/security,
		/area/engineering,
		/area/medical,
		/area/rnd,
		/area/crew_quarters/heads,
		/area/bridge,
		/area/teleporter,
		/area/turret_protected,
		/area/crew_quarters/captain
	)

/datum/raw_vis_tracker/Destroy()
	if(GLOB.raw_vis_tracker == src)
		message_admins("The [type] was deleted. Deities and godcultists may no longer collect raw vis. Please, create a bug report on github.")
		CRASH("[type] was deleted. Please, create a bug report on github.")

	QDEL_LIST(vises)
	tracked_minds.Cut()
	return ..()

/// Fixes vis and minds, fixes any probably bugs
/datum/raw_vis_tracker/proc/rework_network()
	for(var/datum/mind/mind in tracked_minds)
		if(isnull(mind))
			tracked_minds -= mind
			continue

		if(!istype(mind.current))
			continue

		for(var/obj/effect/raw_vis/vis in vises)
			vis.refresh_images(mind.current)

/// Allows [mind/to_add] to see all vis sources. Use /proc/add_tracked_mind() instead of this.
/datum/raw_vis_tracker/proc/_add_to_sources(datum/mind/to_add)
	for(var/obj/effect/raw_vis/vis in vises)
		vis.add_mind(to_add)

/// Removes [mind/to_remove] from all tracked vis sources, making them invisible to a given mind. Use /proc/remove_tracked_mind() instead of this.
/datum/raw_vis_tracker/proc/_remove_from_sources(datum/mind/to_remove)
	for(var/obj/effect/raw_vis/vis in vises)
		vis.remove_mind(to_remove)

/// Generates a set amount of raw vis, based on the number of already existing vis sources and the number of deities.
/datum/raw_vis_tracker/proc/generate_new_vis()
	var/how_many_can_we_make = 0
	for(var/antags_count in 1 to length(tracked_minds))
		how_many_can_we_make += max(VIS_PER_DEITY - antags_count + 1, 1)

	var/location_sanity = 0
	while((length(vises) + num_drained) < how_many_can_we_make && location_sanity < 100)
		var/chosen_area = pick(areas)
		var/turf/chosen_turf = pick_subarea_turf(chosen_area, list(/proc/is_station_turf, /proc/not_turf_contains_dense_objects))
		var/list/nearby_things = range(1, chosen_turf) // At least one tile of separation between vis sources
		var/obj/effect/raw_vis/existing_vis = locate() in nearby_things
		if(istype(existing_vis))
			location_sanity++
			continue

		new /obj/effect/raw_vis(chosen_turf)

	rework_network()

/// Adds a mind to the list of players that can see raw vis sources.
/datum/raw_vis_tracker/proc/add_tracked_mind(datum/mind/antag)
	if(antag in tracked_minds)
		rework_network()
		return

	tracked_minds |= antag

	// If our antag is on station, generate some new vis sources
	if(!isnull(antag.current) && ishuman(antag.current) && isStationLevel(antag.current.z))
		generate_new_vis()

	_add_to_sources(antag)

/// Removes a mind from the list of players that can see raw vis sources.
/datum/raw_vis_tracker/proc/remove_tracked_mind(datum/mind/antag)
	tracked_minds -= antag

	_remove_from_sources(antag)

/obj/effect/raw_vis
	name = "raw vis"
	icon = 'icons/obj/cult.dmi'
	icon_state = "pierced_illusion"
	anchored = TRUE
	invisibility = INVISIBILITY_OBSERVER
	/// Whether we're currently being drained or not.
	var/being_drained = FALSE
	/// The icon state applied to the image created for this vis source.
	var/real_icon_state = "reality_smash"
	/// A list of all minds that can see us.
	var/list/datum/mind/minds = list()
	/// The image shown to antags
	var/image/antag_image
	/// We hold the turf we're on so we can remove and add the 'no prints' flag.
	var/turf/on_turf

/obj/effect/raw_vis/Initialize(mapload)
	. = ..()
	GLOB.raw_vis_tracker.vises += src
	antag_image = image(icon, src, real_icon_state, layer)
	antag_image.appearance_flags |= KEEP_APART | RESET_ALPHA | RESET_TRANSFORM
	on_turf = get_turf(src)
	if(!istype(on_turf))
		return

/obj/effect/raw_vis/Destroy()
	GLOB.raw_vis_tracker.vises -= src
	for(var/datum/mind/antag in minds)
		remove_mind(antag)

	QDEL_NULL(antag_image)
	return ..()

/obj/effect/raw_vis/proc/drain_influence(mob/living/user, knowledge_to_gain)
	being_drained = TRUE
	show_splash_text(user, "draining influence")

	if(!do_after(user, 10 SECONDS, src))
		being_drained = FALSE
		show_splash_text(user, "interrupted!")
		return

	// We don't need to set being_drained back since we delete after anyways
	show_splash_text(user, "influence drained")

	if(istype(user.mind?.godcultist))
		user.mind?.godcultist.points += knowledge_to_gain
	else if(istype(user.mind?.deity))
		user.mind?.deity.knowledge_points += knowledge_to_gain
	else
		after_drain(user)

	after_drain(user)

/obj/effect/raw_vis/proc/after_drain(mob/living/user)
	if(user)
		to_chat(user, SPAN_WARNING("[src] begins to fade!"))

	GLOB.raw_vis_tracker.num_drained++
	qdel_self()

/// Add a mind to the list of tracked minds, makes added user able to see the effect.
/obj/effect/raw_vis/proc/add_mind(datum/mind/antag)
	minds |= antag
	antag.current?.client?.images |= antag_image
	register_signal(antag?.current, SIGNAL_LOGGED_IN, nameof(.proc/refresh_images))
	register_signal(antag?.current, SIGNAL_QDELETING, nameof(.proc/on_mob_qdel))

/obj/effect/raw_vis/proc/refresh_images(mob/user)
	user.client?.images |= antag_image

/// Remove a mind from the list of tracked minds, removes image from the client also.
/obj/effect/raw_vis/proc/remove_mind(datum/mind/antag)
	if(!(antag in minds))
		CRASH("[type] - remove_mind called with a mind not present in the minds list!")

	minds -= antag
	antag.current?.client?.images -= antag_image

/obj/effect/raw_vis/proc/on_mob_qdel(mob/user)
	unregister_signal(user, SIGNAL_LOGGED_IN)

#undef VIS_PER_DEITY
