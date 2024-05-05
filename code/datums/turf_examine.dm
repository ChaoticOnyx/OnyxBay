/// Turf examine window holder, handles icon caching and turf tracking.
/client/var/datum/turf_examine/turf_examine

/datum/turf_examine
	/// Reference to the associated client.
	var/client/owner
	/// Reference to the currently viewed turf.
	var/turf/listed_turf
	/// List of atoms to show to a client via the object tab.
	var/list/atoms_to_show = list()
	/// List of atom -> asset key for objects we have had in the right click tab.
	var/list/atoms_to_images = list()
	/// List of atoms to turn into images for the object tab.
	var/list/atoms_to_imagify = list()

/datum/turf_examine/New(client/owner)
	src.owner = owner

/datum/turf_examine/Destroy(force)
	atoms_to_show = null
	atoms_to_images = null
	atoms_to_imagify = null
	owner.turf_examine = null
	owner = null
	return ..()

/datum/turf_examine/think()
	var/index = 0
	for (index in 1 to length(atoms_to_imagify))
		var/atom/atom_to_imagine = atoms_to_imagify[index]

		var/asset_key
		if (ismob(atom_to_imagine) || length(atom_to_imagine.overlays) > 2)
			asset_key = costly_icon2html(atom_to_imagine, owner, sourceonly = TRUE)
		else
			asset_key = icon2html(atom_to_imagine, owner, sourceonly = TRUE)

		atoms_to_images[atom_to_imagine] = asset_key

		if (TICK_CHECK)
			break

	if (index)
		atoms_to_imagify.Cut(1, index + 1)
		SStgui.update_uis(src)

/datum/turf_examine/proc/set_turf(turf/turf_to_list)
	listed_turf = listed_turf == turf_to_list ? null : turf_to_list

	if (isnull(listed_turf))
		atoms_to_show.Cut()
		atoms_to_imagify.Cut()

		set_next_think(0)
		SStgui.close_uis(src)
	else
		collect_turf_contents()

		set_next_think(world.time)
		tgui_interact(usr)

/datum/turf_examine/proc/collect_turf_contents()
	var/mob/owner_mob = owner.mob
	if (!istype(owner_mob))
		return

	var/list/overrides = list()
	for (var/image/target_image as anything in owner.images)
		if (!target_image.loc || target_image.loc.loc != listed_turf || !target_image.override)
			continue

		overrides += target_image.loc

	atoms_to_show.Cut()
	for (var/atom/turf_content in list(listed_turf) + listed_turf.contents)
		if (!turf_content.mouse_opacity)
			continue

		if (turf_content.invisibility > owner_mob.see_invisible)
			continue

		if (turf_content in overrides)
			continue

		atoms_to_show += turf_content

		if (LAZYISIN(atoms_to_images, turf_content))
			continue

		atoms_to_imagify |= turf_content
		atoms_to_images[turf_content] = null
		register_signal(turf_content, SIGNAL_QDELETING, nameof(.proc/viewing_atom_deleted))

/datum/turf_examine/proc/viewing_atom_deleted(atom/deleting)
	SIGNAL_HANDLER

	atoms_to_show -= deleting
	atoms_to_images -= deleting
	atoms_to_imagify -= deleting

	unregister_signal(deleting, SIGNAL_QDELETING)

/datum/turf_examine/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/turf_examine/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if (!ui)
		ui = new(user, src, "TurfExamine")
		ui.open()

/datum/turf_examine/tgui_data(mob/user)
	var/list/data = list()

	data["atoms"] = list()
	for (var/atom/atom_to_draw in atoms_to_show)
		data["atoms"] += list(list(
			"type" = atom_to_draw.type,
			"name" = atom_to_draw.name,
			"icon" = LAZYACCESS(atoms_to_images, atom_to_draw),
			"ref" = ref(atom_to_draw),
		))

	return data

/datum/turf_examine/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if (.)
		return

	if (action == "refresh")
		collect_turf_contents()
		return TRUE

/datum/turf_examine/ui_status(mob/user, datum/ui_state/state)
	if (isnull(listed_turf) || !owner.mob.TurfAdjacent(listed_turf))
		set_turf(null)
		return UI_CLOSE

	return ..()
