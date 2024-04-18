/datum/lobby_art
	/// Generated name of the datum, mostly used for human-readable text in input.
	var/name
	/// Title of the art, can be `null`.
	var/title
	/// Author of the art, can be `null`.
	var/author
	/// Link to author's social network, can be only one, can be `null`.
	var/socials
	/// Path to the image file.
	var/file_path
	/// Generated icon, allows tracking of whether file was already added to the rsc.
	var/icon/icon

/datum/lobby_art/New(title, author, socials, file_path)
	src.title = title
	src.author = author
	src.socials = socials
	src.file_path = file_path

	name = isnull(title) ? "Onyx Lobby ([rand(0, 100)])" : capitalize(title)

/// Adds icon file to the game's resources and returns an icon.
/datum/lobby_art/proc/get_icon()
	ASSERT(fexists(file_path))

	if(isnull(icon))
		icon = new (fcopy_rsc(file_path))

	return icon

/// Genearates description with url and formatting to be later used in chat.
/datum/lobby_art/proc/get_desc()
	var/desc = "Now Seeing:\n"

	desc += name

	if(!isnull(author))
		desc +=  isnull(socials) ? " by [author]" : " by <a href='[socials]'>[author]</a>"

	return "<span class='good'>[desc]</span>"
