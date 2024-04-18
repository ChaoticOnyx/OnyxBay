SUBSYSTEM_DEF(lobby)
	name = "Lobby Screen"
	flags = SS_NO_FIRE
	init_order = SS_INIT_LOBBY

	/// Reference to the currently used lobby art datum.
	var/datum/lobby_art/current_lobby_art
	/// List of all pre-loaded lobby art datums.
	var/list/datum/lobby_art/loaded_lobby_arts

	/// Reference to the global lobby screen object, do not delete this!
	var/atom/movable/screen/splash/persistent/lobby_screen

/datum/controller/subsystem/lobby/Initialize(start_timeofday)
	. = ..()

	var/list/splash_files = flist(LOBBY_CONFIG)

	for(var/file_name in splash_files)
		if(findtext(file_name, GLOB.is_json))
			continue

		if(!findtext(file_name, GLOB.is_image))
			util_crash_with("Unsupported image or image meta file found in config: '[file_name]'!")
			continue

		LAZYADD(loaded_lobby_arts, load_lobby_art(file_name))

	if(length(loaded_lobby_arts))
		current_lobby_art = pick(loaded_lobby_arts)

	if(isnull(current_lobby_art))
		current_lobby_art = new (file_path = "icons/runtime/default_lobby.dmi")
		LAZYADD(loaded_lobby_arts, current_lobby_art)

	lobby_screen = new(null, current_lobby_art)

	for(var/mob/new_player/player in GLOB.player_list)
		if(isnull(player.client))
			continue

		lobby_screen.show_to(player.client)

/datum/controller/subsystem/lobby/Shutdown()
	for(var/client in GLOB.clients)
		if(isnull(client))
			continue

		new /atom/movable/screen/splash/fake(null, FALSE, client, current_lobby_art)

/datum/controller/subsystem/lobby/Recover()
	current_lobby_art = SSlobby.current_lobby_art
	loaded_lobby_arts = SSlobby.loaded_lobby_arts
	lobby_screen = SSlobby.lobby_screen

/datum/controller/subsystem/lobby/proc/load_lobby_art(file_name)
	RETURN_TYPE(/datum/lobby_art)

	var/file_path = "[LOBBY_CONFIG][file_name]"
	var/meta_path = "[LOBBY_CONFIG][splittext(file_name, ".")[1]].json"

	var/list/image_meta

	if(fexists(meta_path))
		image_meta = json_decode(file2text(meta_path))

	return new /datum/lobby_art(
		title = LAZYACCESS(image_meta, "title"),
		author = LAZYACCESS(image_meta, "author"),
		socials = LAZYACCESS(image_meta, "socials"),
		file_path = file_path
	)

/// Helper proc to properly hande lobby art change, updates variables, notifies all new players.
/datum/controller/subsystem/lobby/proc/change_lobby_art(datum/lobby_art/art_to_use)
	if(!istype(art_to_use))
		return

	current_lobby_art = art_to_use
	lobby_screen.apply_art(art_to_use)

	var/art_description = current_lobby_art.get_desc()
	for(var/mob/new_player/player in GLOB.player_list)
		to_chat(player, art_description)
