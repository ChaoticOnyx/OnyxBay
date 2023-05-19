/proc/emoji_parse(client/C, text) //turns :ai: into an emoji in text.
	. = text
	if(!config.misc.emojis_allowed)
		return
	if(!C)
		return
	if(!check_rights(0, FALSE, C) && !C.donator_info.patreon_tier_available(PATREON_SCIENTIST))
		return
	var/static/list/emojis = icon_states(icon('icons/emoji.dmi'))
	var/parsed = ""
	var/pos = 1
	var/search = 0
	var/emoji = ""
	while(1)
		search = findtext(text, ":", pos)
		parsed += copytext(text, pos, search)
		if(search)
			pos = search
			search = findtext(text, ":", pos+1)
			if(search)
				emoji = lowertext(copytext(text, pos+1, search))
				if(emoji in emojis)
					parsed += icon2html('icons/emoji.dmi', world, emoji)
					pos = search + 1
				else
					parsed += copytext(text, pos, search)
					pos = search
				emoji = ""
				continue
			else
				parsed += copytext(text, pos, search)
		break
	return parsed
