/obj/skybox
	name = "skybox"
	plane = SKYBOX_PLANE
	layer = SKYBOX_LAYER
	mouse_opacity = 0
	anchored = TRUE
	var/mob/owner
	var/image/image
	var/image/stars

/obj/skybox/Initialize()
	. = ..()
	var/mob/M = loc
	SSskybox.skyboxes += src
	owner = M
	loc = null
	image = image('icons/turf/skybox.dmi', src, "background_[SSskybox.BGstate]")
	image.plane = SKYBOX_PLANE
	image.layer = SKYBOX_LAYER
	AddOverlays(image)

	if(SSskybox.use_stars)
		stars = image('icons/turf/skybox.dmi', src, SSskybox.star_state)
		stars.plane = DUST_PLANE
		stars.layer = DUST_LAYER
		stars.appearance_flags = RESET_COLOR
		AddOverlays(stars)
	DoRotate()
	update()

/obj/skybox/proc/update()
	if(QDELETED(owner) || !owner.client)
		qdel(src)
	else
		var/list/view_sizes = get_view_size(owner.client.view)
		var/view_maxx = ceil(view_sizes[1] / 2)
		var/view_maxy = ceil(view_sizes[2] / 2)

		var/atom/position = owner.client.eye
		var/normalized_x = (position.x - TRANSITION_EDGE) / (world.maxx - (TRANSITION_EDGE * 2))
		var/normalized_y = (position.y - TRANSITION_EDGE) / (world.maxy - (TRANSITION_EDGE * 2))

		var/result_x = round(view_maxx * WORLD_ICON_SIZE * normalized_x)
		var/result_y = round(view_maxy * WORLD_ICON_SIZE * normalized_y)

		var/max_offset = abs(view_sizes[1] - view_sizes[2]) * WORLD_ICON_SIZE

		if(view_maxx > view_maxy)
			result_x = min(max_offset, result_x)

		if(view_maxy > view_maxx)
			result_y = min(max_offset, result_y)

		screen_loc = "BOTTOM:[-result_y],LEFT:[-result_x]"

/obj/skybox/proc/DoRotate()
	var/matrix/rotation = matrix()
	rotation.TurnTo(SSskybox.BGrot)
	appearance = rotation

/obj/skybox/Destroy()
	ClearOverlays()
	if(owner)
		if(owner.skybox == src)
			owner.skybox = null
		owner = null
	image = null
	stars = null
	SSskybox.skyboxes -= src
	return ..()

/mob
	var/obj/skybox/skybox

/mob/Move(newloc, direct)
	. = ..()
	if(. && skybox)
		skybox.update()
	reset_view()

/mob/forceMove()
	. = ..()
	if(. && skybox)
		skybox.update()
	reset_view()
