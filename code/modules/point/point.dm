#define POINT_TIME (2.5 SECONDS)

/**
 * Point at (atom)
 *
 * Standardizes the pointing animation.
 */

/atom/movable/proc/point_at(atom/pointed_atom, params, mob/M)
	if(!isturf(loc))
		return

	if(pointed_atom in src)
		create_point_bubble(pointed_atom)
		return

	var/turf/tile = get_turf(pointed_atom)
	if(!tile)
		return

	var/turf/our_tile = get_turf(src)
	var/obj/visual = new /obj/effect/decal/point(our_tile, invisibility, POINT_TIME)

	// Sets position
	var/final_x = (tile.x - our_tile.x) * world.icon_size + pointed_atom.pixel_x
	var/final_y = (tile.y - our_tile.y) * world.icon_size + pointed_atom.pixel_y
	var/list/click_params = params2list(params)
	if(!length(click_params) || !click_params["screen-loc"])
		animate(visual, pixel_x = (tile.x - our_tile.x) * world.icon_size + pointed_atom.pixel_x, pixel_y = (tile.y - our_tile.y) * world.icon_size + pointed_atom.pixel_y, time = 0.17 SECONDS, easing = EASE_OUT)
		return
	else
		var/list/actual_view = get_view_size(isnull(M.client) ? world.view : M.client.view)
		var/list/split_coords = splittext(click_params["screen-loc"], ",")
		final_x = (text2num(splittext(split_coords[1], ":")[1]) - actual_view[1] / 2) * world.icon_size + (text2num(splittext(split_coords[1], ":")[2]) - world.icon_size)
		final_y = (text2num(splittext(split_coords[2], ":")[1]) - actual_view[2] / 2) * world.icon_size + (text2num(splittext(split_coords[2], ":")[2]) - world.icon_size)

	// Sets rotation
	var/matrix/rotated_matrix = new()
	var/matrix/old_visual = visual.transform
	rotated_matrix.TurnTo(0, get_pixel_angle(-final_y, -final_x))
	visual.transform = rotated_matrix

	animate(visual, pixel_x = final_x, pixel_y = final_y, time = 1.7, easing = EASE_OUT, transform = old_visual)

/atom/movable/proc/create_point_bubble(atom/pointed_atom)
	var/mutable_appearance/thought_bubble = mutable_appearance(
		'icons/mob/effects/talk.dmi',
		"thought_bubble",
		layer = POINTER_LAYER,
	)

	thought_bubble.appearance_flags |= KEEP_APART

	var/mutable_appearance/pointed_atom_appearance = new(pointed_atom.appearance)
	pointed_atom_appearance.blend_mode = BLEND_INSET_OVERLAY
	pointed_atom_appearance.plane = FLOAT_PLANE
	pointed_atom_appearance.layer = FLOAT_LAYER
	pointed_atom_appearance.pixel_x = 0
	pointed_atom_appearance.pixel_y = 0
	thought_bubble.overlays += pointed_atom_appearance

	thought_bubble.pixel_x = 16
	thought_bubble.pixel_y = 32
	thought_bubble.alpha = 200

	var/mutable_appearance/point_visual = mutable_appearance(
		'icons/effects/effects.dmi',
		"arrow",
		layer = POINTER_LAYER,
	)

	thought_bubble.overlays += point_visual

	AddOverlays(thought_bubble)
	spawn(POINT_TIME)
		CutOverlays(thought_bubble)

/obj/effect/decal/point
	name = "arrow"
	desc = "It's an arrow hanging in mid-air. There may be a wizard about."
	icon = 'icons/effects/effects.dmi'
	icon_state = "arrow"
	layer = POINTER_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE

/obj/effect/decal/point/Initialize(mapload, invisibility, time_to_live)
	. = ..()
	var/atom/old_loc = loc
	forceMove(get_turf(src))
	pixel_x = old_loc.pixel_x
	pixel_y = old_loc.pixel_y
	set_invisibility(invisibility)
	INVOKE_ASYNC(src, nameof(.proc/destroy_after), time_to_live) // QDEL_IN uses spawn() which can probably bork `Initialize()`

/obj/effect/decal/point/proc/destroy_after(ttl)
	QDEL_IN(src, ttl)

#undef POINT_TIME

/**
 * Point at an atom
 *
 * ghosts can point, intentionally
 *
 * overridden here and in /mob/dead/observer for different point span classes and sanity checks
 */
/mob/verb/pointed(atom/A as mob|obj|turf in view(), params = "" as text)
	set name = "Point To"
	set category = "Object"

	THROTTLE(cooldown, 1 SECOND)
	if(!cooldown)
		return

	if(client && !(A in view(client.view, src)))
		return FALSE

	if(istype(A, /obj/effect/decal/point))
		return FALSE

	face_atom(A)
	point_at(A, params, usr)

	return TRUE
