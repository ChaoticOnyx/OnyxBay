// Some local macros to help with copypasta
#define GET_DECAL_DATA(name, path, coloured, precise) "name" = name, "path" = path, "icon" = icon2base64html(path), "coloured" = coloured, "precise" = precise

/obj/item/device/floor_painter
	name = "floor painter"
	icon = 'icons/obj/device.dmi'
	icon_state = "flpainter"
	item_state = "fl_painter"
	desc = "A slender and none-too-sophisticated device capable of painting, erasing, and applying decals to most types of floors."
	description_info = "Use this item in your hand to access a menu in which you may change the type of decal, applied direction, and color. Click any accessible tile on the floor to apply your choice."
	description_fluff = "This ubiquitous maintenance-grade floor painter isn't as fancy or convenient as modern consumer models, but with an internal synthesizer it never runs out of pigment!"
	description_antag = "This thing would be perfect for vandalism. Could you write your name in the halls?"

	var/decal =        /obj/effect/floor_decal/reset
	var/paint_dir =    "precise"
	var/paint_colour = COLOR_WHITE

	var/static/list/decals = list(
		//                  NAME:                             PATH:                                              COLOURED: PRECISE:
		list(GET_DECAL_DATA("industrial: hazard stripes",     /obj/effect/floor_decal/industrial/warning,        FALSE,    FALSE)),
		list(GET_DECAL_DATA("industrial: corner, hazard",     /obj/effect/floor_decal/industrial/warning/corner, FALSE,    FALSE)),
		list(GET_DECAL_DATA("industrial: hatched marking",    /obj/effect/floor_decal/industrial/hatch,          TRUE,     FALSE)),
		list(GET_DECAL_DATA("industrial: dashed outline",     /obj/effect/floor_decal/industrial/outline,        TRUE,     FALSE)),
		list(GET_DECAL_DATA("industrial: loading sign",       /obj/effect/floor_decal/industrial/loading,        FALSE,    FALSE)),
		list(GET_DECAL_DATA("mosaic: chapel",                 /obj/effect/floor_decal/chapel,                    FALSE,    FALSE)),
		list(GET_DECAL_DATA("tile decor: quarter-turf",       /obj/effect/floor_decal/corner,                    TRUE,     TRUE)),
		list(GET_DECAL_DATA("tile decor: steel-quarter-turf", /obj/effect/floor_decal/corner_steel_grid,         FALSE,    TRUE)),
		list(GET_DECAL_DATA("tile decor: edge drain",         /obj/effect/floor_decal/floordetail/edgedrain,     FALSE,    FALSE)),
		list(GET_DECAL_DATA("tile decor: dots",               /obj/effect/floor_decal/floordetail/tiled,         TRUE,     FALSE)),
		list(GET_DECAL_DATA("tile decor: traction",           /obj/effect/floor_decal/floordetail/traction,      TRUE,     FALSE)),
		list(GET_DECAL_DATA("tile decor: plain spline",       /obj/effect/floor_decal/spline/plain,              TRUE,     TRUE)),
		list(GET_DECAL_DATA("tile decor: wood spline",        /obj/effect/floor_decal/spline/fancy/wood,         FALSE,    TRUE)),
		list(GET_DECAL_DATA("sign: 1",                        /obj/effect/floor_decal/sign,                      FALSE,    FALSE)),
		list(GET_DECAL_DATA("sign: 2",                        /obj/effect/floor_decal/sign/two,                  FALSE,    FALSE)),
		list(GET_DECAL_DATA("sign: A",                        /obj/effect/floor_decal/sign/a,                    FALSE,    FALSE)),
		list(GET_DECAL_DATA("sign: B",                        /obj/effect/floor_decal/sign/b,                    FALSE,    FALSE)),
		list(GET_DECAL_DATA("sign: C",                        /obj/effect/floor_decal/sign/c,                    FALSE,    FALSE)),
		list(GET_DECAL_DATA("sign: D",                        /obj/effect/floor_decal/sign/d,                    FALSE,    FALSE)),
		list(GET_DECAL_DATA("sign: M",                        /obj/effect/floor_decal/sign/m,                    FALSE,    FALSE)),
		list(GET_DECAL_DATA("sign: V",                        /obj/effect/floor_decal/sign/v,                    FALSE,    FALSE)),
		list(GET_DECAL_DATA("sign: CMO",                      /obj/effect/floor_decal/sign/cmo,                  FALSE,    FALSE)),
		list(GET_DECAL_DATA("sign: Ex" ,                      /obj/effect/floor_decal/sign/ex,                   FALSE,    FALSE)),
		list(GET_DECAL_DATA("sign: Psy",                      /obj/effect/floor_decal/sign/p,                    FALSE,    FALSE)),
		list(GET_DECAL_DATA("remove all decals",              /obj/effect/floor_decal/reset,                     FALSE,    FALSE)),
	)

	var/static/list/paint_dirs = list(
		"north" =       NORTH,
		"northwest" =   NORTHWEST,
		"west" =        WEST,
		"southwest" =   SOUTHWEST,
		"south" =       SOUTH,
		"southeast" =   SOUTHEAST,
		"east" =        EAST,
		"northeast" =   NORTHEAST,
		"precise" = 0
		)

/obj/item/device/floor_painter/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "FloorPainter", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/item/device/floor_painter/tgui_act(action, list/params)
	. = ..()

	if(.)
		return

	switch(action)
		if("choose_color")
			choose_color()
			return TRUE
		if("set_decal")
			set_decal(text2path(params["path"]))
			return TRUE
		if("set_direction")
			set_direction(params["direction"])
			return TRUE

/obj/item/device/floor_painter/proc/set_direction(direction)
	if(isnull(paint_dirs[direction]))
		return

	paint_dir = direction
	to_chat(usr, SPAN("notice", "You set \the [src] direction to '[paint_dir]'."))

/obj/item/device/floor_painter/proc/set_decal(path)
	for(var/D in decals)
		if(D["path"] == path)
			decal = path
			to_chat(usr, SPAN("notice", "You set \the [src] decal to '[D["name"]]'."))
			return

/obj/item/device/floor_painter/proc/choose_color(color)
	var/new_colour = input(usr, "Choose a colour.", "Floor painter", paint_colour) as color | null

	if(new_colour && new_colour != paint_colour)
		paint_colour = new_colour
		to_chat(usr, SPAN("notice", "You set \the [src] to paint with <font color='[paint_colour]'>a new colour</font>."))

/obj/item/device/floor_painter/tgui_static_data(mob/user)
	return list(
		"decals" = decals,
	)

/obj/item/device/floor_painter/tgui_data(mob/user)
	return list(
		"settings" = list(
			"paint_colour" = paint_colour,
			"paint_dir" = paint_dir,
			"decal" = decal
		)
	)

/obj/item/device/floor_painter/afterattack(atom/A, mob/user, proximity, params)
	if(!proximity)
		return

	add_fingerprint(user)
	var/turf/simulated/floor/F = A

	if(!istype(F))
		to_chat(user, SPAN("warning", "\The [src] can only be used on actual flooring."))
		return

	if(!F.flooring || !F.flooring.can_paint || F.broken || F.burnt)
		to_chat(user, SPAN("warning", "\The [src] cannot paint broken tiles."))
		return

	var/list/decal_data
	var/painting_decal = decal

	for(var/D in decals)
		if(D["path"] == painting_decal)
			decal_data = D
			break

	if(!decal_data)
		to_chat(user, SPAN("warning", "\The [src] flashes an error light. You might need to reconfigure it."))
		return

	if(F.decals && F.decals.len > 5 && painting_decal != /obj/effect/floor_decal/reset)
		to_chat(user, SPAN("warning", "\The [F] has been painted too much; you need to clear it off."))
		return

	var/painting_dir = paint_dirs[paint_dir]
	if(paint_dir == "precise")
		if(!decal_data["precise"])
			painting_dir = user.dir
		else
			var/list/mouse_control = params2list(params)
			var/mouse_x = text2num(mouse_control["icon-x"])
			var/mouse_y = text2num(mouse_control["icon-y"])

			if(isnum(mouse_x) && isnum(mouse_y))
				if(mouse_x <= 16)
					if(mouse_y <= 16)
						painting_dir = WEST
					else
						painting_dir = NORTH
				else
					if(mouse_y <= 16)
						painting_dir = SOUTH
					else
						painting_dir = EAST
			else
				painting_dir = user.dir

	var/painting_colour

	if(decal_data["coloured"] && paint_colour)
		painting_colour = paint_colour

	playsound(src, 'sound/effects/spray3.ogg', 30, 1, -6)
	new painting_decal(F, painting_dir, painting_colour)

/obj/item/device/floor_painter/attack_self(mob/user)
	. = ..()
	tgui_interact(user)

/obj/item/device/floor_painter/_examine_text(mob/user)
	. = ..()
	. += "\nIt is configured to produce the '[decal]' decal with a direction of '[paint_dir]' using [paint_colour] paint."


#undef GET_DECAL_DATA
