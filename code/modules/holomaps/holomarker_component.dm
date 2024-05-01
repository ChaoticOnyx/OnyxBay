/// Plainest of them all, simply instantiates its own marker. Used for objects such as SMES or navbeacons.
/datum/component/holomarker
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/marker_filter = HOLOMAP_FILTER_STATIONMAP

	var/marker_z
	var/offset_x = HOLOMAP_CORRECTOR_X_SMALL
	var/offset_y = HOLOMAP_CORRECTOR_Y_SMALL
	var/marker_id = "you"
	var/marker_icon = 'icons/holomap/holomap_markers.dmi'

/datum/component/holomarker/Initialize(marker_id_, marker_filter_)
	. = ..()
	GLOB.holomarkers.Add(src)

	if(marker_id_)
		marker_id = marker_id_

	if(marker_filter_)
		marker_filter = marker_filter_

	instantiate_self_marker()

/datum/component/holomarker/proc/instantiate_self_marker()
	if(isatom(parent))
		var/atom/parent_ = parent
		marker_z = parent_.z
		GLOB.holocache["_\ref[src]"] = create_marker_image(parent_.x, parent_.y, marker_id, HUD_HOLOMARKER_LAYER)

/datum/component/holomarker/proc/create_marker_image(X, Y, icon_state, layer)
	var/image/marker_image = image(marker_icon, icon_state)
	marker_image.pixel_x = X + HOLOMAP_OFFSET_X - offset_x
	marker_image.pixel_y = Y + HOLOMAP_OFFSET_Y - offset_y
	marker_image.plane = HUD_PLANE
	marker_image.layer = layer
	return marker_image

/// Can be toggled on and off, updates only its own marker. For use with wayfinding pinpointer.
/datum/component/holomarker/toggleable
	var/toggled = FALSE
	var/should_have_legend = FALSE
	var/mob/activator
	var/image/holomap_base
	var/list/holomap_images = list()

/datum/component/holomarker/toggleable/Destroy()
	GLOB.holomarkers -= src

	if(istype(activator))
		unregister_signal(activator, SIGNAL_Z_CHANGED)
		activator?.client?.images -= holomap_images
		activator?.client?.images -= holomap_base

	if(istype(parent))
		unregister_signal(parent, SIGNAL_ITEM_UNEQUIPPED)

	activator = null
	holomap_base = null
	holomap_images.Cut()
	return ..()

/datum/component/holomarker/toggleable/Initialize(marker_id_, marker_filter_)
	. = ..()
	set_next_think(world.time + 1 SECOND)

/datum/component/holomarker/toggleable/instantiate_self_marker()
	..()
	var/atom/parent_ = parent
	marker_z = parent_.z
	GLOB.holocache["_\ref[src]_self"] = create_marker_image(parent_.x, parent_.y, "you", HUD_HOLOMARKER_SELF_LAYER)

/datum/component/holomarker/toggleable/proc/toggle(mob/user)
	if(!user || !user.client)
		return

	activator = user
	toggled = !toggled
	if(toggled)
		activate(user)
	else
		deactivate(user)

/datum/component/holomarker/toggleable/proc/activate()
	register_signal(activator, SIGNAL_Z_CHANGED, nameof(.proc/on_z_change))
	register_signal(parent, SIGNAL_ITEM_UNEQUIPPED, nameof(.proc/deactivate))

	holomap_base = image(GLOB.holomaps[get_z(activator)])

	if(should_have_legend)
		var/image/legend = image('icons/holomap/holomap_markers_64x64.dmi', "legend")
		legend.pixel_x = 3 * WORLD_ICON_SIZE
		legend.pixel_y = 3 * WORLD_ICON_SIZE
		holomap_base.AddOverlays(legend)

	holomap_base.loc = activator.hud_used.holomap_obj
	holomap_base.alpha = 0
	holomap_base.plane = HUD_PLANE
	holomap_base.layer = HUD_ABOVE_ITEM_LAYER

	animate(holomap_base, alpha = 255, time = 5, easing = LINEAR_EASING)
	activator.client.images |= holomap_base

/datum/component/holomarker/toggleable/proc/deactivate()
	toggled = FALSE
	unregister_signal(activator, SIGNAL_Z_CHANGED)
	unregister_signal(parent, SIGNAL_ITEM_UNEQUIPPED)
	if(holomap_base)
		animate(holomap_base, alpha = 0, time = 5, easing = LINEAR_EASING)

	activator?.client?.images -= holomap_images
	spawn(5)
		activator?.client?.images -= holomap_base

	activator = null

/datum/component/holomarker/toggleable/think()
	handle_own_marker()

	if(!activator || !activator.client)
		if(toggled)
			deactivate()
		set_next_think(world.time + 1 SECOND)
		return

	if(holomap_images.len)
		activator.client.images -= holomap_images
		holomap_images.Cut()

	handle_self_marker()
	handle_markers()

	activator.client.images += holomap_images

	set_next_think(world.time + 1 SECOND)

/// Handles own marker that will be shown to other users
/datum/component/holomarker/toggleable/proc/handle_own_marker()
	var/image/I = GLOB.holocache["_\ref[src]"]
	var/turf/parent_loc = get_turf(parent)
	if(!istype(parent_loc))
		return

	marker_z = parent_loc.z
	I.pixel_x = parent_loc.x + HOLOMAP_OFFSET_X - offset_x
	I.pixel_y = parent_loc.y + HOLOMAP_OFFSET_Y - offset_y

/// Handles self marker that will be shown to a user
/datum/component/holomarker/toggleable/proc/handle_self_marker()
	if(!activator)
		return

	var/image/self = GLOB.holocache["_\ref[src]_self"]
	var/turf/parent_loc = get_turf(parent)
	self.pixel_x = parent_loc.x + HOLOMAP_OFFSET_X - HOLOMAP_CORRECTOR_X_SMALL
	self.pixel_y = parent_loc.y + HOLOMAP_OFFSET_Y - HOLOMAP_CORRECTOR_Y_SMALL
	self.loc = activator.hud_used.holomap_obj
	holomap_images += self

/// Handles markers of others
/datum/component/holomarker/toggleable/proc/handle_markers()
	for(var/datum/component/holomarker/H in GLOB.holomarkers)
		if(H == src)
			continue

		if(istype(H, /datum/component/holomarker/toggleable/transmitting) || istype(H, /datum/component/holomarker/toggleable))
			continue

		if(!isnull(marker_filter) && H.marker_filter != marker_filter)
			continue

		if(H.marker_z != marker_z)
			continue

		var/image/I = GLOB.holocache["_\ref[H]"]
		I.loc = activator.hud_used.holomap_obj
		holomap_images += I
		animate(I, alpha = 255, time = 8, loop = -1, easing = SINE_EASING)
		animate(I, alpha = 0, time = 5, easing = SINE_EASING)
		animate(I, alpha = 255, time = 2, easing = SINE_EASING)

/datum/component/holomarker/toggleable/proc/on_z_change(atom, old_turf, new_turf)
	var/atom/new_loc = new_turf
	if(!activator || !activator.client)
		return

	activator.client.images -= holomap_base

	holomap_base = image(GLOB.holomaps[get_z(new_loc)])

	if(should_have_legend)
		var/image/legend = image('icons/holomap/holomap_markers_64x64.dmi', "legend")
		legend.pixel_x = 3 * WORLD_ICON_SIZE
		legend.pixel_y = 3 * WORLD_ICON_SIZE
		holomap_base.AddOverlays(legend)

	holomap_base.plane = HUD_PLANE
	holomap_base.layer = HUD_ABOVE_ITEM_LAYER
	holomap_base.loc = activator.hud_used.holomap_obj
	activator.client.images |= holomap_base

/// Transmits & receives other holochips on the same frequency
/datum/component/holomarker/toggleable/transmitting
	var/list/transmitting = list("frequency" = RADIO_LOW_FREQ, "encryption" = 1)
	offset_x = HOLOMAP_CORRECTOR_X_BIG
	offset_y = HOLOMAP_CORRECTOR_Y_BIG

/datum/component/holomarker/toggleable/transmitting/Initialize(marker_id_, marker_filter_)
	. = ..()
	if(marker_filter_)
		switch(marker_filter_)
			if(HOLOMAP_FILTER_DEATHSQUAD)
				transmitting = GLOB.holomap_frequency_deathsquad
			if(HOLOMAP_FILTER_ERT)
				transmitting = GLOB.holomap_frequency_ert
			if(HOLOMAP_FILTER_NUKEOPS)
				transmitting = GLOB.holomap_frequency_nuke
			if(HOLOMAP_FILTER_ELITESYNDICATE)
				transmitting = GLOB.holomap_frequency_elitesyndie
			if(HOLOMAP_FILTER_VOX)
				transmitting = GLOB.holomap_frequency_vox

/datum/component/holomarker/toggleable/transmitting/handle_markers()
	for(var/datum/component/holomarker/toggleable/transmitting/H in GLOB.holomarkers)
		if(H == src)
			continue

		if(H.transmitting["frequency"] != transmitting["frequency"])
			continue

		if(H.transmitting["encryption"] != transmitting["encryption"])
			continue

		if(H.marker_z != marker_z)
			continue

		if(istype(H, /datum/component/holomarker/toggleable/transmitting/shuttle) && H.marker_filter != marker_filter)
			continue

		var/image/I = GLOB.holocache["_\ref[H]"]
		I.loc = activator.hud_used.holomap_obj
		holomap_images += I
		animate(I, alpha = 255, time = 8, loop = -1, easing = SINE_EASING)
		animate(I, alpha = 0, time = 5, easing = SINE_EASING)
		animate(I, alpha = 255, time = 2, easing = SINE_EASING)

/datum/component/holomarker/toggleable/transmitting/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("adjust")
			if(params["freq"])
				transmitting["frequency"] = sanitize_frequency(text2num(params["freq"]), RADIO_LOW_FREQ, RADIO_HIGH_FREQ)
			else if(params["code"])
				transmitting["encryption"] = clamp(text2num(params["code"]), 1, 100)
		if("reset")
			if(params["reset"])
				switch(params["reset"])
					if("freq")
						transmitting["frequency"] = RADIO_LOW_FREQ
					if("code")
						transmitting["encryption"] = text2num("1")

	return TRUE

/datum/component/holomarker/toggleable/transmitting/tgui_data(mob/user)
	var/list/data = list(
		"maxFrequency" = RADIO_HIGH_FREQ,
		"minFrequency" = RADIO_LOW_FREQ,
		"frequency" = transmitting["frequency"],
		"code" = text2num(transmitting["encryption"])
	)

	return data

/datum/component/holomarker/toggleable/transmitting/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Holochip", "Holochip frequency")
		ui.open()

/datum/component/holomarker/toggleable/transmitting/handle_own_marker()
	var/image/I = GLOB.holocache["_\ref[src]"]
	var/turf/parent_loc = get_turf(parent)
	marker_z = parent_loc.z
	I.pixel_x = parent_loc.x + HOLOMAP_OFFSET_X - offset_x
	I.pixel_y = parent_loc.y + HOLOMAP_OFFSET_Y - offset_y
	if(!istype(parent, /obj/item/clothing/accessory/holochip))
		return

	var/obj/item/clothing/accessory/holochip/holochip = parent
	if(!holochip.has_suit)
		return

	var/obj/item/clothing/S = holochip.has_suit
	if(!isliving(S.loc))
		return

	I.filters = null
	var/mob/living/wearer = S.loc
	if(wearer.is_ic_dead())
		I.filters += filter(type = "outline", size = 2, color = COLOR_HMAP_DEAD)
	else if(wearer.incapacitated() || wearer.stat == UNCONSCIOUS)
		I.filters += filter(type = "outline", size = 2, color = COLOR_HMAP_INCAPACITATED)
	else
		I.filters += filter(type = "outline", size = 2, color = COLOR_HMAP_DEFAULT)

/datum/component/holomarker/toggleable/transmitting/proc/on_attached(obj/item/clothing/S)
	update_holomarker_image(S)

/datum/component/holomarker/toggleable/transmitting/proc/on_removed()
	update_holomarker_image()

/datum/component/holomarker/toggleable/transmitting/proc/update_holomarker_image(atom/holder)
	var/atom/image_origin
	if(holder)
		image_origin = holder
	else
		image_origin = parent

	if(!istype(image_origin))
		return

	var/image/NI = image(image_origin.icon, image_origin.icon_state)
	NI.transform /= 2.5
	GLOB.holocache["_\ref[src]"] = NI

/// For use with shuttle consoles, do not forget to set up FILTER
/datum/component/holomarker/toggleable/transmitting/shuttle
	marker_icon = 'icons/holomap/holomap_markers_32x32.dmi'
	marker_id = "skipjack"

/datum/component/holomarker/toggleable/transmitting/shuttle/think()
	handle_own_marker()
	set_next_think(world.time + 1 SECOND)
