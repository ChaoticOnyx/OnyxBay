/obj/skybox
	name = "skybox"
	mouse_opacity = 0
	blend_mode = BLEND_MULTIPLY
	plane = SKYBOX_PLANE
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
	overlays += image

	if(SSskybox.use_stars)
		stars = image('icons/turf/skybox.dmi', src, SSskybox.star_state)
		stars.appearance_flags = DEFAULT_APPEARANCE_FLAGS | RESET_COLOR
		overlays += stars
	DoRotate()
	update()

/obj/skybox/proc/update()
	if(isnull(owner) || isnull(owner.client))
		qdel(src)
	else
		var/view_size = owner.client.view
		var/view_maxx
		var/view_maxy

		if(istext(view_size))
			var/splitted = splittext(view_size, "x")
			view_maxx = text2num(splitted[1]) + 1
			view_maxy = text2num(splitted[2]) + 1
		else
			view_maxx = view_maxy = view_size + 1

		var/atom/position = owner.client.eye
		var/normalized_x = (position.x - TRANSITION_EDGE) / (world.maxx - (TRANSITION_EDGE * 2))
		var/normalized_y = (position.y - TRANSITION_EDGE) / (world.maxy - (TRANSITION_EDGE * 2))
		var/result_x = round(view_maxx * WORLD_ICON_SIZE * normalized_x)
		var/result_y = round(view_maxy * WORLD_ICON_SIZE * normalized_y)
		screen_loc = "BOTTOM:[-result_y],LEFT:[-result_x]"

/obj/skybox/proc/DoRotate()
	var/matrix/rotation = matrix()
	rotation.TurnTo(SSskybox.BGrot)
	appearance = rotation

/obj/skybox/Destroy()
	overlays.Cut()
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

/mob/Move()
	. = ..()
	if(. && skybox)
		skybox.update()

/mob/forceMove()
	. = ..()
	if(. && skybox)
		skybox.update()

/mob/Login()
	if(!skybox)
		skybox = new(src)
		skybox.owner = src
	client.screen += skybox
	..()

/mob/Destroy()
	if(client)
		client.screen -= skybox
	QDEL_NULL(skybox)
	return ..()
