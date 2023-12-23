/// Plainest of them all, simply instantiates its own marker. Used for objects such as SMES or navbeacons.
/datum/component/holomap
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/marker_filter = HOLOMAP_FILTER_STATIONMAP

	var/marker_z
	var/offset_x = HOLOMAP_CORRECTOR_X_SMALL
	var/offset_y = HOLOMAP_CORRECTOR_Y_SMALL
	var/marker_id = "you"
	var/marker_icon = 'icons/holomap/holomap_markers.dmi'

/datum/component/holomap/Initialize(marker_id_, marker_filter_)
	. = ..()
	GLOB.holomarkers.Add(src)

	if(marker_id_)
		marker_id = marker_id_

	if(marker_filter_)
		marker_filter = marker_filter_

	instantiate_self_marker()

/datum/component/holomap/proc/instantiate_self_marker()
	if(isatom(parent))
		var/atom/parent_ = parent
		marker_z = parent_.z
		var/image/marker_image = image(marker_icon, marker_id)
		marker_image.pixel_x = parent_.x + HOLOMAP_OFFSET_X - offset_x
		marker_image.pixel_y = parent_.y + HOLOMAP_OFFSET_Y - offset_y
		marker_image.plane = HUD_PLANE
		marker_image.layer = HUD_HOLOMARKER_LAYER
		GLOB.holocache["_\ref[src]"] = marker_image

/// Can be toggled on and off, updates only its own marker. For use with wayfinding pinpointer.
/datum/component/holomap/toggleable
	var/toggled = FALSE
	var/should_have_legend = FALSE
	var/mob/activator
	var/image/holomap_base
	var/list/holomap_images = list()

/datum/component/holomap/toggleable/Initialize(marker_id_, marker_filter_)
	. = ..()
	set_next_think(world.time + 1 SECOND)

/datum/component/holomap/toggleable/instantiate_self_marker()
	..()
	var/atom/parent_ = parent
	marker_z = parent_.z
	var/image/self_image = image(marker_icon, "you")
	self_image.pixel_x = parent_.x + HOLOMAP_OFFSET_X - offset_x
	self_image.pixel_y = parent_.y + HOLOMAP_OFFSET_Y - offset_y
	self_image.plane = HUD_PLANE
	self_image.layer = HUD_HOLOMARKER_SELF_LAYER
	GLOB.holocache["_\ref[src]_self"] = self_image

/datum/component/holomap/toggleable/proc/toggle(mob/user)
	if(!user || !user.client)
		return

	activator = user
	toggled = !toggled
	if(toggled)
		activate(user)
	else
		deactivate(user)

/datum/component/holomap/toggleable/proc/activate()
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

/datum/component/holomap/toggleable/proc/deactivate()
	toggled = FALSE
	unregister_signal(activator, SIGNAL_Z_CHANGED)
	unregister_signal(parent, SIGNAL_ITEM_UNEQUIPPED)
	if(holomap_base)
		animate(holomap_base, alpha = 0, time = 5, easing = LINEAR_EASING)

	activator?.client?.images -= holomap_images
	spawn(5)
		activator?.client?.images -= holomap_base

	activator = null

/datum/component/holomap/toggleable/think()
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
/datum/component/holomap/toggleable/proc/handle_own_marker()
	var/image/I = GLOB.holocache["_\ref[src]"]
	var/turf/parent_loc = get_turf(parent)
	marker_z = parent_loc.z
	I.pixel_x = parent_loc.x + HOLOMAP_OFFSET_X - offset_x
	I.pixel_y = parent_loc.y + HOLOMAP_OFFSET_Y - offset_y

/// Handles self marker that will be shown to a user
/datum/component/holomap/toggleable/proc/handle_self_marker()
	if(!activator)
		return

	var/image/self = GLOB.holocache["_\ref[src]_self"]
	var/turf/parent_loc = get_turf(parent)
	self.pixel_x = parent_loc.x + HOLOMAP_OFFSET_X - HOLOMAP_CORRECTOR_X_SMALL
	self.pixel_y = parent_loc.y + HOLOMAP_OFFSET_Y - HOLOMAP_CORRECTOR_Y_SMALL
	self.loc = activator.hud_used.holomap_obj
	holomap_images += self

/// Handles markers of others
/datum/component/holomap/toggleable/proc/handle_markers()
	for(var/datum/component/holomap/H in GLOB.holomarkers)
		if(H == src)
			continue

		if(istype(H, /datum/component/holomap/toggleable/transmitting))
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

/datum/component/holomap/toggleable/proc/on_z_change(atom, old_turf, new_turf)
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
/datum/component/holomap/toggleable/transmitting
	var/list/transmitting = list("frequency" = RADIO_LOW_FREQ, "encryption" = 1)
	offset_x = HOLOMAP_CORRECTOR_X_BIG
	offset_y = HOLOMAP_CORRECTOR_Y_BIG

/datum/component/holomap/toggleable/transmitting/Initialize(marker_id_, marker_filter_)
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

/datum/component/holomap/toggleable/transmitting/handle_markers()
	for(var/datum/component/holomap/toggleable/transmitting/H in GLOB.holomarkers)
		if(H == src)
			continue

		if(H.transmitting["frequency"] != transmitting["frequency"])
			continue

		if(H.transmitting["encryption"] != transmitting["encryption"])
			continue

		if(H.marker_z != marker_z)
			continue

		if(istype(H, /datum/component/holomap/toggleable/transmitting/shuttle) && H.marker_filter != marker_filter)
			continue

		var/image/I = GLOB.holocache["_\ref[H]"]
		I.loc = activator.hud_used.holomap_obj
		holomap_images += I
		animate(I, alpha = 255, time = 8, loop = -1, easing = SINE_EASING)
		animate(I, alpha = 0, time = 5, easing = SINE_EASING)
		animate(I, alpha = 255, time = 2, easing = SINE_EASING)

/datum/component/holomap/toggleable/transmitting/tgui_act(action, params)
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

/datum/component/holomap/toggleable/transmitting/tgui_data(mob/user)
	var/list/data = list(
		"maxFrequency" = RADIO_HIGH_FREQ,
		"minFrequency" = RADIO_LOW_FREQ,
		"frequency" = transmitting["frequency"],
		"code" = text2num(transmitting["encryption"])
	)

	return data

/datum/component/holomap/toggleable/transmitting/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Holochip", "Holochip frequency")
		ui.open()

/datum/component/holomap/toggleable/transmitting/handle_own_marker()
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

/datum/component/holomap/toggleable/transmitting/proc/on_attached(obj/item/clothing/S)
	update_holomarker_image(S)

/datum/component/holomap/toggleable/transmitting/proc/on_removed()
	update_holomarker_image()

/datum/component/holomap/toggleable/transmitting/proc/update_holomarker_image(atom/holder)
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
/datum/component/holomap/toggleable/transmitting/shuttle
	marker_icon = 'icons/holomap/holomap_markers_32x32.dmi'
	marker_id = "skipjack"

/datum/component/holomap/toggleable/transmitting/shuttle/think()
	handle_own_marker()
	set_next_think(world.time + 1 SECOND)
