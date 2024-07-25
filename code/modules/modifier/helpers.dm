#define MODIFIER_EFFECTS_LAYER 28
// TODO [V] Get rid of this temporary define. Equals HO_MODIFIER_EFFECTS_LAYER

// Converts a hexadecimal color (e.g. #FF0050) to a list of numbers for red, green, and blue (e.g. list(255,0,80) ).
/proc/hex2rgb(hex)
	// Strips the starting #, in case this is ever supplied without one, so everything doesn't break.
	if(findtext(hex,"#",1,2))
		hex = copytext(hex, 2)
	return list(hex2rgb_r(hex), hex2rgb_g(hex), hex2rgb_b(hex))

// The three procs below require that the '#' part of the hex be stripped, which hex2rgb() does automatically.
/proc/hex2rgb_r(hex)
	var/hex_to_work_on = copytext(hex,1,3)
	return hex2num(hex_to_work_on)

/proc/hex2rgb_g(hex)
	var/hex_to_work_on = copytext(hex,3,5)
	return hex2num(hex_to_work_on)

/proc/hex2rgb_b(hex)
	var/hex_to_work_on = copytext(hex,5,7)
	return hex2num(hex_to_work_on)


/mob/living/proc/update_transform()
	animate(
		src,
		transform = matrix().Update(
			scale_x = (tf_scale_x || 1),
			scale_y = (tf_scale_y || 1),
			rotation = (tf_rotation || 0) + (hanging ? 180 : 0),
			offset_x = (tf_offset_x || 0),
			offset_y = (tf_offset_y || 0) + 16 * ((tf_scale_y || 1) - 1)
		),
		time = 10
	)

/mob/living/carbon/human/update_transform(anim_time = 3)
	var/rotate_deg = (tf_rotation || 0)
	var/translate_x = 0
	var/translate_y = 16 * ((tf_scale_y || 1) * body_height - 1) + species.y_shift

	//Due to some involuntary means, you're laying now
	if(lying && !resting && !sleeping)
		anim_time = 1 //Thud
	if(lying && !species.prone_icon) //Only rotate them if we're not drawing a specific icon for being prone.
		rotate_deg += 90
		translate_x = 1
		translate_y = -6
	else if(hanging && !species.prone_icon)
		rotate_deg += 180
		translate_y = -16 * ((tf_scale_y || 1) * body_height - 1)

	reset_layer()

	animate(
		src,
		transform = matrix().Update(
			scale_x = (tf_scale_x || 1),
			scale_y = (tf_scale_y || 1) * body_height,
			rotation = (tf_rotation || 0) + rotate_deg,
			offset_x = (tf_offset_x || 0) + translate_x,
			offset_y = (tf_offset_y || 0) + translate_y
		),
		time = anim_time
	)

/// Gathers all offsets into one proc. Prevents conflicting animations/offsets from overwriting each other and causing awful visuals.
/// Never, ever set pixel offset on mobs directly. You have been warned!
/mob/proc/update_offsets(anim_time = 3)
	var/last_pixel_x = pixel_x
	var/last_pixel_y = pixel_y
	var/last_pixel_z = pixel_z

	var/new_pixel_x =  default_pixel_x
	var/new_pixel_y =  default_pixel_y
	var/new_pixel_z =  default_pixel_z

	var/turf/T = loc
	if(istype(loc))
		// Updating grab offsets
		if(length(grabbed_by))
			for(var/obj/item/grab/G as anything in grabbed_by)
				var/grab_dir = get_dir(G.assailant, src)
				if(grab_dir && G.current_grab.shift > 0)
					if(grab_dir & WEST)
						new_pixel_x = min(new_pixel_x + G.current_grab.shift, default_pixel_x + G.current_grab.shift)
					else if(grab_dir & EAST)
						new_pixel_x = max(new_pixel_x - G.current_grab.shift, default_pixel_x - G.current_grab.shift)
					if(grab_dir & NORTH)
						new_pixel_y = max(new_pixel_y - G.current_grab.shift, default_pixel_y - G.current_grab.shift)
					else if(grab_dir & SOUTH)
						new_pixel_y = min(new_pixel_y + G.current_grab.shift, default_pixel_y + G.current_grab.shift)

		// Updating turf height offset.
		if(!isghost(src) || invisibility == 0)
			new_pixel_z = T.turf_height

		// Update offsets from our buckled atom.
		if(buckled && buckled.buckle_pixel_shift)
			var/list/pixel_shift = buckled.buckle_pixel_shift
			if(istext(pixel_shift))
				pixel_shift = cached_key_number_decode(pixel_shift)
			if(islist(pixel_shift))
				var/list/directional_offset = LAZYACCESS(pixel_shift, num2text(dir))
				if(!directional_offset)
					if(dir & EAST)
						directional_offset = LAZYACCESS(pixel_shift, num2text(EAST))
					else if(dir & WEST)
						directional_offset = LAZYACCESS(pixel_shift, num2text(WEST))
				if(islist(directional_offset))
					pixel_shift = directional_offset
				new_pixel_x += pixel_shift["x"] || 0
				new_pixel_y += pixel_shift["y"] || 0
				new_pixel_z += pixel_shift["z"] || 0

	if(last_pixel_x != new_pixel_x || last_pixel_y != new_pixel_y || last_pixel_z != new_pixel_z)
		if(anim_time > 0)
			animate(src, pixel_x = new_pixel_x, pixel_y = new_pixel_y, pixel_z = new_pixel_z, anim_time, 1, (LINEAR_EASING | EASE_IN))
		else
			pixel_x = new_pixel_x
			pixel_y = new_pixel_y
			pixel_z = new_pixel_z

/mob/observer/virtual/update_offsets()
	return

/mob/living/proc/update_modifier_visuals()
	return

/mob/proc/update_client_color()
	if(client && client.color)
		animate(client, color = null, time = 10)
	return

/mob/living/carbon/human/update_modifier_visuals()
	if(QDESTROYING(src))
		return

	remove_layer(MODIFIER_EFFECTS_LAYER)

	if(!LAZYLEN(modifiers))
		return //No modifiers, no effects.

	var/image/effects = new()
	for(var/datum/modifier/M in modifiers)
		if(M.mob_overlay_state)
			var/image/I = image(icon = 'icons/mob/modifier_effects.dmi', icon_state = M.mob_overlay_state)
			effects.AddOverlays(I) //TODO, this compositing is annoying.

	overlays_standing[MODIFIER_EFFECTS_LAYER] = effects

	apply_layer(MODIFIER_EFFECTS_LAYER)


/mob/living/carbon/human/proc/apply_layer(cache_index)
	if((. = overlays_standing[cache_index]))
		AddOverlays(.)

/mob/living/carbon/human/proc/remove_layer(cache_index)
	var/I = overlays_standing[cache_index]
	if(I)
		CutOverlays(I)
		overlays_standing[cache_index] = null


// This handles setting the client's color variable, which makes everything look a specific color.
// This proc is here so it can be called without needing to check if the client exists, or if the client relogs.
/mob/living/update_client_color()
	if(!client)
		return

	var/list/colors_to_blend = list()
	for(var/datum/modifier/M in modifiers)
		if(!isnull(M.client_color))
			if(islist(M.client_color)) //It's a color matrix! Forget it. Just use that one.
				animate(client, color = M.client_color, time = 10)
				return
			colors_to_blend += M.client_color

	if(colors_to_blend.len)
		var/final_color
		if(colors_to_blend.len == 1) // If it's just one color we can skip all of this work.
			final_color = colors_to_blend[1]

		else // Otherwise we need to do some messy additive blending.
			var/R = 0
			var/G = 0
			var/B = 0

			for(var/C in colors_to_blend)
				var/RGB = hex2rgb(C)
				R = between(0, R + RGB[1], 255)
				G = between(0, G + RGB[2], 255)
				B = between(0, B + RGB[3], 255)
			final_color = rgb(R,G,B)

		if(final_color)
			var/old_color = client.color // Don't know if BYOND has an internal optimization to not care about animate() calls that effectively do nothing.
			if(final_color != old_color) // Gonna do a check just incase.
				animate(client, color = final_color, time = 10)

	else // No colors, so remove the client's color.
		animate(client, color = null, time = 10)
