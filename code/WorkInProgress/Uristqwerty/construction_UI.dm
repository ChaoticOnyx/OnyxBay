
//Surprisingly simple construction UI:
//    Pop up a browser to let the user select what to build by it's icon state, rather than getting text with input()
//    Also allows the user to preview the construction in-place and cancel it entirely.

/mob/var/datum/construction_UI/construction_UI

/datum/construction_UI
	var/default_state = ""
	var/default_dir = 2
	var/selected
	var/selected_dir
	var/list/states = list()
	var/list/state_images = list()
	var/global/list/state_images_cache = list()
	var/image/tile_image
	var/mob/user
	var/display_mode = "icons only" //Use anything else to add line breaks and show the name of the state (or the associated text, if there is an association (like list("somestate" = "Show This Text"))
	var/tint = rgb(100, 100, 255, 200)
	var/icon/tile_image_icon
	var/atom/loc
	var/icon/icon


/datum/construction_UI/New(atom/loc, mob/user)
	..()

	if(!user.client)
		del(src)
		return

	user.construction_UI = src
	src.loc = loc

	src.user = user
	tile_image_icon = new(icon)
	tile_image_icon.Blend(tint, ICON_MULTIPLY)
	tile_image = image(tile_image_icon, loc, default_state, FLY_LAYER, default_dir)
	user << tile_image

	var/t = "Click to select what you want to build<br>"

	for(var/state in states)
		var/icon_state = state
		var/dir = 2
		if(findtext(state, "&dir="))
			var/pos = findtext(state, "&dir=")
			dir = text2num(copytext(state, pos + 5))
			icon_state = copytext(state, 1, pos)

		if(!state_images_cache["[icon]:[icon_state]:[dir]"])
			state_images_cache["[icon]:[icon_state]:[dir]"] = icon(icon, icon_state, dir)

		state_images[state] = state_images_cache["[icon]:[icon_state]:[dir]"]

		user << browse_rsc(state_images[state], "[state].png")

		if(display_mode == "icons only")
			t += "<a href='?src=\ref[src];state=[icon_state];direction=[dir]'><img src=[state].png></a> "
		else
			t += "<a href='?src=\ref[src];state=[icon_state];direction=[dir]'><img src=[state].png> [states[state]?states[state]:state]</a><br>"


	t += "<br><br><a href='?src=\ref[src];cancel-build=1'>cancel</a>"
	t += "<br><a href='?src=\ref[src];use-selected=1'>use selected</a>"

	selected = default_state
	selected_dir = default_dir

	user << browse(t, "window=construction_UI;can_close=0")

/datum/construction_UI/Topic(href,href_list[])
	if(href_list["state"])
		selected = href_list["state"]
		selected_dir = text2num(href_list["direction"])

		del(tile_image)
		tile_image = image(tile_image_icon, loc, selected, FLY_LAYER, selected_dir)
		user << tile_image

	else if(href_list["cancel-build"])
		del(src)

	else if(href_list["use-selected"])

		build(selected, selected_dir)
		del(src)


/datum/construction_UI/Del()
	user << browse(null, "window=construction_UI")
	del(tile_image_icon)
	del(tile_image)
	..()

/datum/construction_UI/proc/build(state, dir)
	return




//Example usage. Won't work in SS13.

/*

/datum/construction_UI/pipe
	states = list(	"1A-2A", "1A-2B", "1A-2C",
					"1B-2A", "1B-2B", "1B-2C",
					"1C-2A", "1C-2B", "1C-2C",

					"1A-4A", "1A-4B", "1A-4C",
					"1B-4A", "1B-4B", "1B-4C",
					"1C-4A", "1C-4B", "1C-4C",

					"1A-8A", "1A-8B", "1A-8C",
					"1B-8A", "1B-8B", "1B-8C",
					"1C-8A", "1C-8B", "1C-8C",

					"2A-4A", "2A-4B", "2A-4C",
					"2B-4A", "2B-4B", "2B-4C",
					"2C-4A", "2C-4B", "2C-4C",

					"2A-8A", "2A-8B", "2A-8C",
					"2B-8A", "2B-8B", "2B-8C",
					"2C-8A", "2C-8B", "2C-8C",

					"4A-8A", "4A-8B", "4A-8C",
					"4B-8A", "4B-8B", "4B-8C",
					"4C-8A", "4C-8B", "4C-8C")

	icon = 'icons/obj/network/pipe.dmi'
	default_state = "1A-2A"


/datum/construction_UI/pipe/build(state)
	var/obj/network/pipe/p = new /obj/network/pipe(loc)
	p.icon_state = state

*/