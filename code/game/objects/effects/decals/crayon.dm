/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/obj/rune.dmi'
	anchored = 1

	New(location,main = "#ffffff",shade = "#000000", drawing = "rune1", visible_name = "drawing")
		..()
		loc = location

		name = visible_name
		desc = "A [visible_name] drawn in crayon."
		overlays += get_crayon_preview(main, shade, drawing)

		add_hiddenprint(usr)

// Returns icon if receiver is not specified, or name of created .png file otherwise
/proc/get_crayon_preview(main = "#ffffff",shade = "#000000", drawing = "rune1", mob/receiver)
	var/icon_file
	for(var/file in list('icons/effects/crayondecal.dmi', 'icons/effects/crayongraffiti.dmi'))
		if(drawing in icon_states(file))
			icon_file = file
			break
	if(!icon_file)
		CRASH("Crayon drawing named '[drawing]' doesn't exist")

	var/icon/mainOverlay = new /icon(icon_file, drawing, 2.1)
	mainOverlay.Blend(main,ICON_ADD)

	var/shade_drawing = "[drawing]_s"
	if(shade_drawing in icon_states(icon_file))
		var/icon/shadeOverlay = new /icon(icon_file, shade_drawing, 2.1)
		shadeOverlay.Blend(shade,ICON_ADD)
		mainOverlay.Blend(shadeOverlay, ICON_OVERLAY)

	if(!receiver)
		return mainOverlay
	else
		var/resourse_name = "[drawing]-crayon-[copytext(main,2)]-[copytext(shade,2)].png"
		receiver << browse(mainOverlay, "file=[resourse_name];display=0")
		return resourse_name
