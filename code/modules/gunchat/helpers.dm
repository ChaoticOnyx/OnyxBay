//this one is actually used
/proc/icon2html_lite(thing, list/target)
	if (!thing)
		return

	var/icon_state
	var/icon/I = thing
	if (!isicon(I))
		var/atom/A = thing
		icon_state = A.icon_state
		I = A.icon
	else
		icon_state = ""

	I = icon(I, icon_state, SOUTH)

	var/key = "[generate_asset_name(I)].png"
	register_asset(key, I)
	for (var/thing2 in target)
		send_asset(thing2, key, FALSE)

	return "<img class='icon' src=\"[url_encode(key)]\" onerror=\"imgerror(this)\">"

//// ///// // /// // ///// //// //////// ///// //// / / // // // / // // / / // // / /// /// /

/proc/generate_asset_name(var/file)
	return "asset.[md5(fcopy_rsc(file))]"

//// ///// // /// // ///// //// //////// ///// //// / / // // // / // // / / // // / /// /// /

GLOBAL_DATUM_INIT(iconCache, /savefile, new("data/iconCache.sav")) //Cache of icons for the browser output

//// ///// // /// // ///// //// //////// ///// //// / / // // // / // // / / // // / /// /// /

//Converts an icon to base64. Operates by putting the icon in the iconCache savefile,
// exporting it as text, and then parsing the base64 from that.
// (This relies on byond automatically storing icons in savefiles as base64)
/proc/icon2base64(icon/icon, iconKey = "misc")
	if (!isicon(icon))
		return FALSE
	to_file(GLOB.iconCache[iconKey], icon)
	var/iconData = GLOB.iconCache.ExportText(iconKey)
	var/list/partial = splittext(iconData, "{")
	return replacetext(copytext(partial[2], 3, -5), "\n", "")

/proc/icon2html(thing, list/target, icon_state, dir, frame = 1, moving = FALSE)
	if (!thing || !target)
		return
	if (target == world)
		target = GLOB.clients
	if (!islist(target))
		target = list(target)
	else
		if (!target.len)
			return

	var/key
	var/icon/I = thing
	if (!isicon(I))
		if (isfile(thing)) //special snowflake
			var/name = sanitize_filename("[generate_asset_name(thing)].png")
			register_asset(name, thing)
			for (var/thing2 in target)
				send_asset(thing2, key, FALSE)
			return "<img class='icon icon-misc' src=\"[url_encode(name)]\" onerror=\"imgerror(this)\">"
		var/atom/A = thing
		if (isnull(dir))
			dir = A.dir
		if (isnull(icon_state))
			icon_state = A.icon_state
		I = A.icon
		/*
		if (ishuman(thing)) // Shitty workaround for a BYOND issue.
			var/icon/temp = I
			I = icon()
			I.Insert(temp, dir = SOUTH)
			dir = SOUTH
		*/
	else
		if (isnull(dir))
			dir = SOUTH
		if (isnull(icon_state))
			icon_state = ""

	I = icon(I, icon_state, dir, frame, moving)

	key = "[generate_asset_name(I)].png"
	register_asset(key, I)
	for (var/thing2 in target)
		send_asset(thing2, key, FALSE)

	if(I.Width() <> I.Height() || I.Width() != 32)
		return "<img class='icon icon-[icon_state]' style='width:[I.Width()]px;height:[I.Height()]px' src=\"[url_encode(key)]\" onerror=\"imgerror(this)\">"

	return "<img class='icon icon-[icon_state]' src=\"[url_encode(key)]\" onerror=\"imgerror(this)\">"

/proc/icon2base64html(thing)
	if (!thing)
		return
	var/static/list/bicon_cache = list()
	if (isicon(thing))
		var/icon/I = thing
		var/icon_base64

		if (I.Height() > world.icon_size || I.Width() > world.icon_size)
			var/icon_md5 = md5(icon_base64)
			icon_base64 = bicon_cache[icon_md5]
			if (!icon_base64) // Doesn't exist yet, make it.
				bicon_cache[icon_md5] = icon_base64 = icon2base64(I)
		else
			icon_base64 = icon2base64(I)


		return "<img class='icon icon-misc' src='data:image/png;base64,[icon_base64]' onerror='imgerror(this)'>"

	// Either an atom or somebody fucked up and is gonna get a runtime, which I'm fine with.
	var/atom/A = thing
	var/key = "[istype(A.icon, /icon) ? "\ref[A.icon]" : A.icon]:[A.icon_state]"


	if (!bicon_cache[key]) // Doesn't exist, make it.
		var/icon/I = icon(A.icon, A.icon_state, SOUTH, 1)
		if (ishuman(thing)) // Shitty workaround for a BYOND issue.
			var/icon/temp = I
			I = icon()
			I.Insert(temp, dir = SOUTH)

		bicon_cache[key] = icon2base64(I, key)

	return "<img class='icon icon-[A.icon_state]' src='data:image/png;base64,[bicon_cache[key]]' onerror='imgerror(this)'>"

//Costlier version of icon2html() that uses getFlatIcon() to account for overlays, underlays, etc. Use with extreme moderation, ESPECIALLY on mobs.
/proc/costly_icon2html(thing, target)
	if (!thing)
		return

	if (isicon(thing))
		return icon2html(thing, target)

	var/icon/I = getFlatIcon(thing)
	return icon2html(I, target)

//// ///// // /// // ///// //// //////// ///// //// / / // // // / // // / / // // / /// /// /

//Removes a few problematic characters
/proc/sanitize_simple(t,list/repl_chars = list("\n"="#","\t"="#"))
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+1)
			index = findtext(t, char, index+1)
	return t

/proc/sanitize_filename(t)
	return sanitize_simple(t, list("\n"="", "\t"="", "/"="", "\\"="", "?"="", "%"="", "*"="", ":"="", "|"="", "\""="", "<"="", ">"=""))
