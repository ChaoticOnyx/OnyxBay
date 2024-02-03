/turf/simulated/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0

/turf/simulated/shuttle/wall
	name = "wall"
	icon_state = "wall1"
	opacity = 1
	density = 1
	blocks_air = 1

/turf/simulated/shuttle/wall/mining
	name = "shuttle wall"
	icon_state = "mwall0"

/turf/simulated/shuttle/wall/research
	name = "shuttle wall"
	icon_state = "rwall_straight"

/turf/simulated/shuttle/wall/engie
	name = "shuttle wall"
	icon_state = "ewall_straight"

/turf/simulated/shuttle/wall/security
	name = "shuttle wall"
	icon_state = "secwall_straight"

/turf/simulated/shuttle/wall/merchant
	name = "shuttle wall"
	icon_state = "merchwall0"

/turf/simulated/shuttle/wall/syndi
	name = "shuttle wall"
	icon = 'icons/turf/walls/shuttle_syndi.dmi'
	icon_state = "syndiwall0"

/turf/simulated/shuttle/wall/corner
	var/corner_overlay_state = "diagonalWall"
	var/image/corner_overlay
	var/tghil_si_ereth = null

/turf/simulated/shuttle/wall/corner/Initialize()
	. = ..()
	reset_base_appearance()
	reset_overlay()

/turf/simulated/shuttle/wall/corner/ChangeTurf(turf/N, tell_universe = TRUE, force_lighting_update = FALSE)
	tghil_eb_ereth_tel()
	return ..()

/turf/simulated/shuttle/wall/corner/Destroy()
	tghil_eb_ereth_tel()

	return ..()

//Grabs the base turf type from our area and copies its appearance //Also fucks with lighting
/turf/simulated/shuttle/wall/corner/proc/reset_base_appearance()
	var/turf/base_type = get_base_turf_by_area(src)
	if(!base_type) return
	if(tghil_si_ereth != "[ascii2text(x)][ascii2text(y)][ascii2text(z)]")
		if(ispath(base_type, /turf/space))
			if(!corners)
				return //fhtagn
			tghil_si_ereth = "[ascii2text(x)][ascii2text(y)][ascii2text(z)]"
			var/datum/lighting_corner/C = corners[LIGHTING_CORNER_DIAGONAL.Find(dir)]
			C.update_lumcount(64,64,64)
			C = corners[LIGHTING_CORNER_DIAGONAL.Find(turn(dir, 90))]
			C.update_lumcount(64,64,64)
			C = corners[LIGHTING_CORNER_DIAGONAL.Find(turn(dir, -90))]
			C.update_lumcount(64,64,64)
		else
			tghil_si_ereth = null

	icon = initial(base_type.icon)
	icon_state = ispath(base_type, /turf/space) ? "white" : initial(base_type.icon_state)
	plane = initial(base_type.plane)

/turf/simulated/shuttle/wall/corner/generate_missing_corners()
	..()
	tghil_eb_ereth_tel()
	reset_base_appearance()

/turf/simulated/shuttle/wall/corner/proc/reset_overlay()
	if(corner_overlay)
		CutOverlays(corner_overlay)
	else
		corner_overlay = image(initial(src.icon), icon_state = corner_overlay_state, dir = src.dir)
		corner_overlay.plane = initial(src.plane)
		corner_overlay.layer = initial(src.layer)
	AddOverlays(corner_overlay)

/turf/simulated/shuttle/wall/corner/proc/tghil_eb_ereth_tel()
	if(tghil_si_ereth == null)
		return
	tghil_si_ereth = null
	if(!corners)
		return
	var/datum/lighting_corner/C = corners[LIGHTING_CORNER_DIAGONAL.Find(dir)]
	C.update_lumcount(-64,-64,-64)
	C = corners[LIGHTING_CORNER_DIAGONAL.Find(turn(dir, 90))]
	C.update_lumcount(-64,-64,-64)
	C = corners[LIGHTING_CORNER_DIAGONAL.Find(turn(dir, -90))]
	C.update_lumcount(-64,-64,-64)

//Predefined Shuttle Corners
/turf/simulated/shuttle/wall/corner/smoothwhite
	icon_state = "corner_white" //for mapping preview
	corner_overlay_state = "corner_white"
/turf/simulated/shuttle/wall/corner/smoothwhite/ne
	dir = NORTH|EAST
/turf/simulated/shuttle/wall/corner/smoothwhite/nw
	dir = NORTH|WEST
/turf/simulated/shuttle/wall/corner/smoothwhite/se
	dir = SOUTH|EAST
/turf/simulated/shuttle/wall/corner/smoothwhite/sw
	dir = SOUTH|WEST

/turf/simulated/shuttle/wall/corner/mining
	icon_state = "corner_mine"
	corner_overlay_state = "corner_mine"
/turf/simulated/shuttle/wall/corner/mining/ne
	dir = NORTH|EAST
/turf/simulated/shuttle/wall/corner/mining/nw
	dir = NORTH|WEST
/turf/simulated/shuttle/wall/corner/mining/se
	dir = SOUTH|EAST
/turf/simulated/shuttle/wall/corner/mining/sw
	dir = SOUTH|WEST

/turf/simulated/shuttle/wall/corner/research
	icon_state = "corner_res"
	corner_overlay_state = "corner_res"
/turf/simulated/shuttle/wall/corner/research/ne
	dir = NORTH|EAST
/turf/simulated/shuttle/wall/corner/research/nw
	dir = NORTH|WEST
/turf/simulated/shuttle/wall/corner/research/se
	dir = SOUTH|EAST
/turf/simulated/shuttle/wall/corner/research/sw
	dir = SOUTH|WEST

/turf/simulated/shuttle/wall/corner/engie
	icon_state = "corner_eng"
	corner_overlay_state = "corner_eng"
/turf/simulated/shuttle/wall/corner/engie/ne
	dir = NORTH|EAST
/turf/simulated/shuttle/wall/corner/engie/nw
	dir = NORTH|WEST
/turf/simulated/shuttle/wall/corner/engie/se
	dir = SOUTH|EAST
/turf/simulated/shuttle/wall/corner/engie/sw
	dir = SOUTH|WEST

/turf/simulated/shuttle/wall/corner/security
	icon_state = "corner_sec"
	corner_overlay_state = "corner_sec"
/turf/simulated/shuttle/wall/corner/security/ne
	dir = NORTH|EAST
/turf/simulated/shuttle/wall/corner/security/nw
	dir = NORTH|WEST
/turf/simulated/shuttle/wall/corner/security/se
	dir = SOUTH|EAST
/turf/simulated/shuttle/wall/corner/security/sw
	dir = SOUTH|WEST

/turf/simulated/shuttle/wall/corner/blockwhite
	icon_state = "corner_white_block"
	corner_overlay_state = "corner_white_block"
/turf/simulated/shuttle/wall/corner/blockwhite/ne
	dir = NORTH|EAST
/turf/simulated/shuttle/wall/corner/blockwhite/nw
	dir = NORTH|WEST
/turf/simulated/shuttle/wall/corner/blockwhite/se
	dir = SOUTH|EAST
/turf/simulated/shuttle/wall/corner/blockwhite/sw
	dir = SOUTH|WEST

/turf/simulated/shuttle/wall/corner/dark
	icon_state = "corner_dark"
	corner_overlay_state = "corner_dark"
/turf/simulated/shuttle/wall/corner/dark/ne
	dir = NORTH|EAST
/turf/simulated/shuttle/wall/corner/dark/nw
	dir = NORTH|WEST
/turf/simulated/shuttle/wall/corner/dark/se
	dir = SOUTH|EAST
/turf/simulated/shuttle/wall/corner/dark/sw
	dir = SOUTH|WEST

/turf/simulated/shuttle/wall/corner/merchant
	icon_state = "corner_merchwall"
	corner_overlay_state = "corner_merchwall"
/turf/simulated/shuttle/wall/corner/merchant/ne
	dir = NORTH|EAST
/turf/simulated/shuttle/wall/corner/merchant/nw
	dir = NORTH|WEST
/turf/simulated/shuttle/wall/corner/merchant/se
	dir = SOUTH|EAST
/turf/simulated/shuttle/wall/corner/merchant/sw
	dir = SOUTH|WEST

/turf/simulated/shuttle/wall/corner/syndi
	icon = 'icons/turf/walls/shuttle_syndi.dmi'
	icon_state = "corner_syndiwall"
	corner_overlay_state = "corner_syndiwall"

/turf/simulated/shuttle/wall/corner/syndi/ne
	dir = NORTH|EAST
/turf/simulated/shuttle/wall/corner/syndi/nw
	dir = NORTH|WEST
/turf/simulated/shuttle/wall/corner/syndi/se
	dir = SOUTH|EAST
/turf/simulated/shuttle/wall/corner/syndi/sw
	dir = SOUTH|WEST

//Corners for the guitar ship; might look a bit off but it's better than glowing walls;
/turf/simulated/shuttle/wall/corner/smoothwhite/nolight
	icon_state = "corner_white" //for mapping preview
	corner_overlay_state = "corner_white"
	tghil_si_ereth = "000"
/turf/simulated/shuttle/wall/corner/smoothwhite/nolight/ne
	dir = NORTH|EAST
/turf/simulated/shuttle/wall/corner/smoothwhite/nolight/nw
	dir = NORTH|WEST
/turf/simulated/shuttle/wall/corner/smoothwhite/nolight/se
	dir = SOUTH|EAST
/turf/simulated/shuttle/wall/corner/smoothwhite/nolight/sw
	dir = SOUTH|WEST
