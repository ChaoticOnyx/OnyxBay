/atom/movable/screen/splash
	name = "Chaotic Onyx"
	desc = "This shouldn't be read."
	icon = ""
	appearance_flags = parent_type::appearance_flags | TILE_BOUND
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE

	/// Reference to the currently used lobby art.
	var/datum/lobby_art/using_art

INITIALIZE_IMMEDIATE(/atom/movable/screen/splash)

/atom/movable/screen/splash/Initialize(mapload, datum/lobby_art/art_to_use)
	. = ..()

	apply_art(art_to_use)

/atom/movable/screen/splash/Destroy()
	using_art = null
	return ..()

/atom/movable/screen/splash/proc/apply_art(datum/lobby_art/art_to_apply)
	using_art = art_to_apply

	name = using_art.name

	var/icon/icon_to_use = art_to_apply.get_icon()

	var/icon_height = icon_to_use.Height()
	var/icon_width = icon_to_use.Width()

	icon = icon_to_use
	screen_loc = "CENTER:-[icon_width / 2 - 16],CENTER:-[icon_height / 2 - 16]"

/// Screen object used by `SSlobby`, this one is global and shouldn't be deleted.
/atom/movable/screen/splash/persistent

/atom/movable/screen/splash/persistent/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE

	return ..()

/atom/movable/screen/splash/persistent/proc/show_to(client/target_client)
	if(!istype(target_client))
		return

	to_chat(target_client, using_art.get_desc())
	target_client.screen += src

/// This exists solely to create a neat animation when a client leaves lobby and enters the game.
/atom/movable/screen/splash/fake
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	/// Refrence to a client that is currently viewing this screen.
	var/client/my_client

/atom/movable/screen/splash/fake/Initialize(mapload, out = TRUE, client/my_client, datum/lobby_art/art_to_use)
	. = ..(mapload, art_to_use)

	if(isnull(my_client))
		return INITIALIZE_HINT_QDEL

	src.my_client = my_client
	my_client.screen += src

	INVOKE_ASYNC(src, nameof(.proc/fade), out)

/atom/movable/screen/splash/fake/Destroy(force)
	if(!isnull(my_client))
		my_client.screen -= src
		my_client = null

	return ..()

/atom/movable/screen/splash/fake/proc/fade(out)
	if(out)
		animate(src, alpha = 0, time = 30)
	else
		alpha = 0
		animate(src, alpha = 255, time = 30)

	QDEL_IN(src, 30)
