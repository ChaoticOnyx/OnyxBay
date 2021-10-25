
///////////
// EASEL //
///////////

/obj/structure/easel
	name = "easel"
	desc = "Only for the finest of art!"
	icon = 'icons/obj/artstuff.dmi'
	icon_state = "easel"
	density = TRUE
	var/obj/item/canvas/painting = null

//Adding canvases
/obj/structure/easel/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/canvas))
		var/obj/item/canvas/canvas = I
		user.drop_item(canvas)
		painting = canvas
		canvas.forceMove(get_turf(src))
		canvas.layer = layer+0.1
		user.visible_message(SPAN("notice", "[user] puts \the [canvas] on \the [src]."), SPAN("notice", "You place \the [canvas] on \the [src]."))
	else
		return ..()


//Stick to the easel like glue
/obj/structure/easel/Move()
	var/turf/T = get_turf(src)
	. = ..()
	if(painting && painting.loc == T) //Only move if it's near us.
		painting.forceMove(get_turf(src))
	else
		painting = null

/obj/item/canvas
	name = "canvas"
	desc = "Draw out your soul on this canvas!"
	icon = 'icons/obj/artstuff.dmi'
	icon_state = "11x11"
	var/width = 11
	var/height = 11
	var/list/grid
	var/canvas_color = "#ffffff" //empty canvas color
	var/used = FALSE
	var/painting_name = "Untitled Artwork" //Painting name, this is set after framing.
	var/finalized = FALSE //Blocks edits
	var/author_ckey
	var/icon_generated = FALSE
	var/list/image/canvas_overlay = list()
	var/taped = FALSE
	var/wip_detail_added = FALSE
	///boolean that blocks persistence from saving it. enabled from printing copies, because we do not want to save copies.
	var/no_save = FALSE

	// Painting overlay offset when framed
	var/framed_offset_x = 9
	var/framed_offset_y = 10

	// for gamemodes
	var/is_poster = FALSE
	var/is_marked = FALSE
	var/is_corp = FALSE
	var/is_rev = FALSE

/obj/item/canvas/Initialize()
	. = ..()
	reset_grid()

/obj/item/canvas/pickup()
	. = ..()
	if(is_poster)
		is_poster = FALSE
		area_manipulation()

/obj/item/canvas/proc/area_manipulation()
	if(!is_marked)
		return
	var/turf/T = get_turf(src)
	var/area/A = T?.loc
	if(!A)
		return
	if(is_poster)
		if(is_corp)
			A.add_corp_poster(src)
		if(is_rev)
			A.add_rev_poster(src)
	else
		if(is_corp)
			A.remove_corp_poster(src)
		if(is_rev)
			A.remove_rev_poster(src)

/obj/item/canvas/proc/reset_grid()
	grid = new /list(width,height)
	for(var/x in 1 to width)
		for(var/y in 1 to height)
			grid[x][y] = canvas_color

/obj/item/canvas/attack_self(mob/user)
	. = ..()
	tgui_interact(user)

/obj/item/canvas/tgui_state(mob/user)
	if(finalized)
		return GLOB.physical_obscured_state
	else
		return GLOB.tgui_physical_state

/obj/item/canvas/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Canvas", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/canvas/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/tape_roll))
		to_chat(user, SPAN_NOTICE("You add some tape to back of canvas."))
		taped = TRUE
	if(user.a_intent == I_HELP)
		tgui_interact(user)
	else
		return ..()

/obj/item/canvas/tgui_data(mob/user)
	. = ..()
	.["grid"] = grid
	.["name"] = painting_name
	.["finalized"] = finalized

/obj/item/canvas/examine(mob/user)
	. = ..()
	tgui_interact(user)
	if(!user.mind || !is_marked)
		return
	var/datum/antagonist/antag = GLOB.all_antag_types_[MODE_LOYALIST]
	var/is_loyalist_user = antag.is_antagonist(user.mind) || (user.mind.assigned_role in GLOB.command_positions)
	antag = GLOB.all_antag_types_[MODE_REVOLUTIONARY]
	var/is_rev_user = antag.is_antagonist(user.mind)
	var/message = SPAN_DANGER("You hate \the [src]. You want to burn \the [src] down!")
	if((is_rev && is_loyalist_user) || (is_rev_user && is_corp))
		. += "\n" + message

/obj/item/canvas/tgui_act(action, params)
	. = ..()
	if(. || finalized)
		return
	var/mob/user = usr
	switch(action)
		if("paint")
			var/obj/item/I = user.get_active_hand()
			var/color = get_paint_tool_color(I)
			if(!color)
				return FALSE
			var/x = text2num(params["x"])
			var/y = text2num(params["y"])
			grid[x][y] = color
			used = TRUE
			update_icon()
			. = TRUE
		if("finalize")
			. = TRUE
			if(!finalized)
				finalize(user)

/obj/item/canvas/proc/finalize(mob/user)
	finalized = TRUE
	author_ckey = user.ckey
	paint_image()
	try_rename(user)
	var/turf/epicenter = get_turf(src)
	if(!epicenter)
		return
	message_admins("The new art has been created by [author_ckey] in <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[epicenter.x];Y=[epicenter.y];Z=[epicenter.z]'>(x:[epicenter.x], y:[epicenter.y], z:[epicenter.z])</a>")

/obj/item/canvas/afterattack(atom/a, mob/user, proximity)
	if(proximity && istype(a ,/turf) && a.density && taped)
		var/turf/T = a
		mount_canvas(T,user)

/obj/item/canvas/proc/mount_canvas(turf/on_wall, mob/user)
	if(get_dist(on_wall,user)>1)
		return
	var/ndir = get_dir(on_wall, user)
	if(!(ndir in GLOB.cardinal))
		return
	var/turf/T = get_turf(user)
	if(!isfloor(T) && on_wall.density)
		to_chat(user, SPAN_WARNING("You cannot place [src] on this spot!"))
		return
	if(gotwallitem(T, ndir))
		to_chat(user, SPAN_WARNING("There's already an item on this wall!"))
		return
	playsound(src.loc, 'sound/machines/click.ogg', 75, 1)
	user.visible_message("[user.name] attaches [src] to the wall.",
		SPAN_NOTICE("You attach [src] to the wall."),
		SPAN_NOTICE("You hear clicking."))
	is_poster = TRUE
	area_manipulation()
	if(user.unEquip(src,T))
		switch(ndir)
			if(NORTH)
				pixel_y = -32
				pixel_x = 0
			if(SOUTH)
				pixel_y = 21
				pixel_x = 0
			if(EAST)
				pixel_x = -27
				pixel_y = 0
			if(WEST)
				pixel_x = 27
				pixel_y = 0
		update_icon()

/obj/item/canvas/update_icon()
	. = ..()
	if(icon_generated)
		overlays = canvas_overlay
		if(blood_overlay)
			overlays += blood_overlay
		return
	if(!wip_detail_added && used)
		var/mutable_appearance/detail = new(image(icon, "[icon_state]wip"))
		detail.pixel_x = framed_offset_x
		detail.pixel_y = framed_offset_y
		wip_detail_added = TRUE
		overlays += detail

/obj/item/canvas/proc/paint_image(x_offset = framed_offset_x, y_offset = framed_offset_y) // y_offset = 1
	if(icon_generated)
		return
	QDEL_LIST(canvas_overlay)
	for(var/y in 1 to height)
		for(var/x in 1 to width)
			var/image/pixel = image(icon, "onepixel", pixel_x = x + x_offset, pixel_y = height - y + y_offset)
			pixel.color = grid[x][y]
			canvas_overlay.Add(pixel)
	icon_generated = TRUE
	update_icon()

//Todo make this element ?
/obj/item/canvas/proc/get_paint_tool_color(obj/item/I)
	if(!I)
		return
	if(istype(I, /obj/item/weapon/pen/crayon))
		var/obj/item/weapon/pen/crayon/crayon = I
		return crayon.colour
	else if(istype(I, /obj/item/weapon/pen))
		var/obj/item/weapon/pen/P = I
		switch(P.colour)
			if("black")
				return COLOR_BLACK
			if("blue")
				return COLOR_BLUE
			if("red")
				return COLOR_RED
		return P.colour
	else if(istype(I, /obj/item/weapon/soap) || istype(I, /obj/item/weapon/reagent_containers/glass/rag))
		return canvas_color

/obj/item/canvas/proc/try_rename(mob/user)
	var/new_name = sanitize(input(user,"What do you want to name the painting?"))
	if(new_name != painting_name && new_name && CanUseTopic(user, GLOB.physical_state))
		painting_name = new_name
		SStgui.update_uis(src)
		desc = "[desc]\nIt has name of [painting_name]"

/obj/item/canvas/verb/make_rev_poster()
	set name = "Make Revolutionary Poster"
	set desc = "Die corporation die!"
	set category = "Poster"
	var/mob/living/H = usr
	var/datum/antagonist/antag = GLOB.all_antag_types_[MODE_REVOLUTIONARY]
	if(!istype(H) || !H.mind || !antag.is_antagonist(H.mind) || is_marked)
		return
	is_marked = TRUE
	is_corp = FALSE
	is_rev = TRUE
	to_chat(usr, "You've added a revolutionary slogan to the poster.")

/obj/item/canvas/verb/make_corp_poster()
	set name = "Make Corporate Poster"
	set desc = "Make the corporation great again!"
	set category = "Poster"
	var/mob/living/H = usr
	var/datum/antagonist/antag = GLOB.all_antag_types_[MODE_LOYALIST]
	if(!istype(H) || !H.mind || !(antag.is_antagonist(H.mind) || (H.mind.assigned_role in GLOB.command_positions)) || is_marked)
		return
	is_marked = TRUE
	is_corp = TRUE
	is_rev = FALSE
	to_chat(usr, "You've added a corporate slogan to poster.")

/obj/item/canvas/nineteen_nineteen
	icon_state = "19x19"
	width = 19
	height = 19
	framed_offset_x = 6
	framed_offset_y = 8

/obj/item/canvas/twentythree_nineteen
	icon_state = "23x19"
	width = 23
	height = 19
	framed_offset_x = 4
	framed_offset_y = 7

/obj/item/canvas/twentythree_twentythree
	icon_state = "23x23"
	width = 23
	height = 23
	framed_offset_x = 4
	framed_offset_y = 4

/obj/item/canvas/twentyfour_twentyfour
	icon_state = "24x24"
	width = 24
	height = 24
	framed_offset_x = 3
	framed_offset_y = 3
