/datum/visual_cache
	var/turf/trf
	var/image/img
	var/trf_loc

/datum/visual_cache/proc/UpdateTurf()
	trf = locate(trf_loc)

// Client vars
/client/var/datum/visuals/visuals = null

/datum/visuals
	var/client/owner = null
	var/list/cache = list()
	var/last_proc = null
	var/list/last_arguments = null

/datum/visuals/New(client/owner)
	if (!owner)
		crash_with("owner is null")

	src.owner = owner

/datum/visuals/proc/UpdateTurfs()
	for (var/datum/visual_cache/C in cache)
		if (!C.trf)
			C.UpdateTurf()

/datum/visuals/proc/CreateCache()
	if (cache || cache.len)
		cache = list()

	for (var/turf/T in block(locate(1, 1, owner.mob.loc.z), locate(world.maxx, world.maxy, owner.mob.loc.z)))
		var/datum/visual_cache/C = new()

		C.trf = T
		C.img = image('icons/effects/lighting_overlay.dmi', T, "transparent")
		C.trf_loc = T.loc

		owner.images += C.img

		cache += C

/datum/visuals/proc/RemoveVisuals()
	if (cache || cache.len)
		for (var/datum/visual_cache/C in cache)
			owner.images -= C.img

	cache = list()
	src.last_proc = null
	src.last_arguments = null

/datum/visuals/proc/ApplyVisual(visual_proc, arguments)
	if (!owner || !owner.mob)
		return

	if (!visual_proc && !src.last_proc)
		RemoveVisuals()
		return

	if (!cache || !cache.len)
		CreateCache()

	if (visual_proc)
		src.last_proc = visual_proc

	if (arguments)
		src.last_arguments = list(cache) + arguments

	if (!src.last_proc || !src.last_arguments)
		return

	call(src.last_proc)(arglist(src.last_arguments))

/client/verb/visualize_gas()
	set category = "Visualize"
	set name = "Visualize Gas"

	if (!check_rights(R_DEBUG) || !mob || !mob.loc)
		return

	var/gas_name = sanitize(input("Enter a gas name", "Gas Name"))

	if (!mob || !mob.loc)
		return

	var/mode = sanitize(input("Select a mode", "Mode") in list("temperature", "volume", "pressure"))

	if (!mob || !mob.loc)
		return

	if (!visuals)
		visuals = new(src)

	visuals.ApplyVisual(visual_proc=/client/proc/VisualizeGas, arguments=list(gas_name, mode))

// Visualize a gas
/client/proc/VisualizeGas(list/cache, gas_name, mode)
	if (!(mode in list("temperature", "volume", "pressure")))
		return

	// Colors
	var/const/rMin = 98
	var/const/gMin = 64
	var/const/bMin = 41

	var/const/rMax = 25
	var/const/gMax = 98
	var/const/bMax = 100

	// Relative numbers
	var/min_value = 0
	var/max_value = 50

	for (var/datum/visual_cache/C in cache)
		var/turf/T = C.trf

		if (!T)
			C.UpdateTurf()
			T = C.trf

		var/image/I = C.img
		I.layer = DECAL_LAYER
		I.plane = FULLSCREEN_PLANE
		I.alpha = 120
		I.blend_mode = BLEND_OVERLAY

		var/datum/gas_mixture/mix = T.return_air()
		var/normalized = 0

		if (!mix)
			I.color = rgb(rMin, gMin, bMin)
			continue

		switch (mode)
			if ("volume")
				var/gas = mix.get_gas(gas_name)

				if (!gas)
					I.color = rgb(rMin, gMin, bMin)
					continue

				normalized = ((gas - min_value) / max_value)
			if ("temperature")
				max_value = 50000
				normalized = ((mix.temperature - min_value) / max_value)
			if ("pressure")
				max_value = 200
				normalized = ((mix.volume - min_value) / max_value)

		// Interpolate color
		var/r = ceil(rMin + ((rMax - rMin) * normalized))
		var/g = ceil(gMin + ((gMax - gMin) * normalized))
		var/b = ceil(bMin + ((bMax - bMin) * normalized))

		I.color = rgb(r, g, b)

// Remove all atmos' visuals
/client/verb/remove_visuals()
	set category = "Visualize"
	set name = "Remove Visuals"

	if (!visuals)
		return

	visuals.RemoveVisuals()