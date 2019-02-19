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


/mob/living/update_transform()
	// First, get the correct size.
	var/desired_scale = icon_scale
	for(var/datum/modifier/M in modifiers)
		if(!isnull(M.icon_scale_percent))
			desired_scale *= M.icon_scale_percent

	// Now for the regular stuff.
	var/matrix/M = matrix()
	M.Scale(desired_scale)
	M.Translate(0, 16*(desired_scale-1))
	animate(src, transform = M, time = 10)

/mob/living/carbon/human/update_transform()
	// First, get the correct size.
	var/desired_scale = icon_scale

	desired_scale *= species.icon_scale

	for(var/datum/modifier/M in modifiers)
		if(!isnull(M.icon_scale_percent))
			desired_scale *= M.icon_scale_percent

	// Regular stuff again.
	var/matrix/M = matrix()
	var/anim_time = 3

	//Due to some involuntary means, you're laying now
	if(lying && !resting && !sleeping)
		anim_time = 1 //Thud

	if(lying && !species.prone_icon) //Only rotate them if we're not drawing a specific icon for being prone.
		M.Turn(90)
		M.Scale(desired_scale)
		M.Translate(1,-6)
		layer = MOB_LAYER -0.01 // Fix for a byond bug where turf entry order no longer matters
	else
		M.Scale(desired_scale)
		M.Translate(0, 16*(desired_scale-1))
		layer = MOB_LAYER // Fix for a byond bug where turf entry order no longer matters

	animate(src, transform = M, time = anim_time)


/mob/living/proc/update_modifier_visuals()
	return

/atom/movable
	var/icon_scale = 1 // Used to scale icons up or down in update_transform().
	var/icon_rotation = 0 // Used to rotate icons in update_transform()


/atom/movable/proc/update_transform()
	var/matrix/M = matrix()
	M.Scale(icon_scale)
	M.Turn(icon_rotation)
	src.transform = M

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
			effects.overlays += I //TODO, this compositing is annoying.

	overlays_standing[MODIFIER_EFFECTS_LAYER] = effects

	apply_layer(MODIFIER_EFFECTS_LAYER)


/mob/living/carbon/human/proc/apply_layer(cache_index)
	if((. = overlays_standing[cache_index]))
		overlays.Add(.)

/mob/living/carbon/human/proc/remove_layer(cache_index)
	var/I = overlays_standing[cache_index]
	if(I)
		overlays.Cut(I)
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

