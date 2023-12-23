/proc/generate_holomaps()
	for(var/zlevel = 1 to GLOB.using_map.map_levels.len)
		GLOB.holomaps += zlevel
		GLOB.holomaps[zlevel] = generate_holomap_z(zlevel)

/proc/generate_holomap_z(z)
	var/icon/map = icon('icons/480x480.dmi', "stationmap")
	if(!(z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION))) // If it is not a station level, then we simply use generic background image
		return map

	var/icon/canvas = icon('icons/480x480.dmi', "blank")
	var/icon/canvas_areas = icon('icons/480x480.dmi', "blank")

	var/turf/center = locate(world.maxx / 2, world.maxy / 2, z)
	if(!center)
		return

	var/list/turf/turfs = RANGE_TURFS(world.maxx / 2, center)

	for(var/turf/T in turfs)
		var/areacolor = get_area_color(T.loc)
		if(areacolor && !istype(T.loc, /area/space/))
			canvas_areas.DrawBox(areacolor, T.x + HOLOMAP_OFFSET_X, T.y + HOLOMAP_OFFSET_Y)

		if(isfloor(T))
			canvas.DrawBox(HOLOMAP_WALKABLE_TILE, T.x + HOLOMAP_OFFSET_X, T.y + HOLOMAP_OFFSET_Y)

		if(iswall(T) ||  locate(/obj/structure/grille) in T)
			canvas.DrawBox(HOLOMAP_CONCRETE_TILE, T.x + HOLOMAP_OFFSET_X, T.y + HOLOMAP_OFFSET_Y)

		if(locate(/obj/structure/window_frame) in T)
			canvas.DrawBox(HOLOMAP_GLASS_TILE, T.x + HOLOMAP_OFFSET_X, T.y + HOLOMAP_OFFSET_Y)

	canvas.Blend("#79ff79", ICON_MULTIPLY)
	canvas.Blend(canvas_areas, ICON_OVERLAY)
	canvas.Blend(map, ICON_OVERLAY)

	return canvas

/proc/get_area_color(area)
	if(!area)
		return

	if(istype(area, /area/bridge || istype(area, /area/turret_protected)) || istype(area, /area/crew_quarters/heads) || istype(area, /area/teleporter) || istype(area, /area/crew_quarters/captain))
		return HOLOMAP_AREACOLOR_COM

	else if(istype(area, /area/security))
		return HOLOMAP_AREACOLOR_SEC

	else if(istype(area, /area/medical))
		return HOLOMAP_AREACOLOR_MED

	else if(istype(area, /area/rnd))
		return HOLOMAP_AREACOLOR_RND

	else if(istype(area, /area/engineering) || istype(area, /area/solar))
		return HOLOMAP_AREACOLOR_ENG

	else if(istype(area, /area/supply) || istype(area, /area/quartermaster))
		return HOLOMAP_AREACOLOR_CRG

	else if(istype(area, /area/hallway/secondary/exit))
		return HOLOMAP_AREACOLOR_ESCAPE

	else if(istype(area, /area/hallway/secondary/entry))
		return HOLOMAP_AREACOLOR_ARRIVALS

	else if(istype(area, /area/crew_quarters) || istype(area, /area/chapel) || istype(area, /area/library) || istype(area, /area/crew_quarters))
		return HOLOMAP_AREACOLOR_CIV

	else if(istype(area, /area/syndicate_station) || istype(area, /area/rescue_base) || istype(area, /area/shuttle) || istype(area, /area/skipjack_station))
		return null

	else
		return HOLOMAP_AREACOLOR_HALLWAYS
