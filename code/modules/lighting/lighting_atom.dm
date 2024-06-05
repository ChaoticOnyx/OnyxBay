var/global/GLOW_BRIGHTNESS_BASE = 0.46
var/global/GLOW_BRIGHTNESS_POWER = -1.6
var/global/GLOW_CONTRAST_BASE = 10
var/global/GLOW_CONTRAST_POWER = -0.15
var/global/EXPOSURE_BRIGHTNESS_BASE = 0.2
var/global/EXPOSURE_BRIGHTNESS_POWER = -0.2
var/global/EXPOSURE_CONTRAST_BASE = 10
var/global/EXPOSURE_CONTRAST_POWER = 0

/atom
	var/light_max_bright = 1  // intensity of the light within the full brightness range. Value between 0 and 1
	var/light_inner_range = 1 // range, in tiles, the light is at full brightness
	var/light_outer_range = 0 // range, in tiles, where the light becomes darkness
	var/light_falloff_curve = 2 // adjusts curve for falloff gradient. Must be greater than 0.
	var/light_color // Hexadecimal RGB string representing the colour of the light

	var/datum/light_source/light
	var/list/light_sources

	var/glow_icon = 'icons/obj/lighting.dmi'
	var/exposure_icon = 'icons/effects/exposures.dmi'

	var/glow_icon_state
	var/glow_colored = FALSE

	var/exposure_icon_state
	var/exposure_colored = TRUE

	var/image/glow_overlay
	var/image/exposure_overlay

// Nonsensical value for l_color default, so we can detect if it gets set to null.
#define NONSENSICAL_VALUE -99999
#define DEFAULT_FALLOFF_CURVE (2)
/atom/proc/set_light(l_max_bright, l_inner_range, l_outer_range, l_falloff_curve = NONSENSICAL_VALUE, l_color = NONSENSICAL_VALUE)
	. = FALSE // don't update if nothing changed

	if(l_max_bright != null && l_max_bright != light_max_bright)
		light_max_bright = l_max_bright
		. = TRUE
	if(l_outer_range != null && l_outer_range != light_outer_range)
		light_outer_range = l_outer_range
		. = TRUE
	if(l_inner_range != null && l_inner_range != light_inner_range)
		if(light_inner_range >= light_outer_range)
			light_inner_range = light_outer_range / 4
		else
			light_inner_range = l_inner_range
		. = TRUE
	if(l_falloff_curve != NONSENSICAL_VALUE)
		if(!l_falloff_curve || l_falloff_curve <= 0)
			light_falloff_curve = DEFAULT_FALLOFF_CURVE
		if(l_falloff_curve != light_falloff_curve)
			light_falloff_curve = l_falloff_curve
			. = TRUE
	if(l_color != NONSENSICAL_VALUE && l_color != light_color)
		light_color = l_color
		. = TRUE

	if(.)
		update_light()

#undef NONSENSICAL_VALUE
#undef DEFAULT_FALLOFF_CURVE

/atom/proc/update_light()
	set waitfor = FALSE

	if(!light_max_bright || !light_outer_range || light_max_bright > 1)
		if(light)
			light.destroy()
			light = null
		if(light_max_bright > 1)
			light_max_bright = 1
			CRASH("Attempted to call update_light() on atom [src] \ref[src] with a light_max_bright value greater than one")
	else
		if(!istype(loc, /atom/movable))
			. = src
		else
			. = loc

		if(light)
			light.update(.)
		else
			light = new /datum/light_source(src, .)

	SEND_SIGNAL(src, SIGNAL_LIGHT_UPDATED, src)
	SEND_GLOBAL_SIGNAL(SIGNAL_LIGHT_UPDATED, src)

/atom/Destroy()
	if(light)
		light.destroy()
		light = null
	QDEL_NULL(glow_overlay)
	QDEL_NULL(exposure_overlay)
	return ..()

/atom/set_opacity()
	. = ..()
	if(.)
		var/turf/T = loc
		if(istype(T))
			T.RecalculateOpacity()

#define LIGHT_MOVE_UPDATE \
var/turf/old_loc = loc;\
. = ..();\
if(loc != old_loc) {\
	if(light_sources) {\
		for(var/datum/light_source/L in light_sources) {\
			L.source_atom.update_light();\
		}\
	}\
}

/atom/movable/Move(newloc, direct)
	LIGHT_MOVE_UPDATE

/atom/movable/forceMove()
	LIGHT_MOVE_UPDATE

#undef LIGHT_MOVE_UPDATE

/obj/item/equipped()
	. = ..()
	update_light()

/obj/item/pickup()
	. = ..()

	update_light()

/obj/item/dropped()
	. = ..()
	update_light()

/atom/proc/update_bloom()
	CutOverlays(glow_overlay)
	CutOverlays(exposure_overlay)
	if(glow_icon && glow_icon_state)
		if(!glow_overlay)
			glow_overlay = image(icon = glow_icon, icon_state = glow_icon_state, dir = dir, layer = 1)

		glow_overlay.plane = LIGHTING_LAMPS_PLANE
		glow_overlay.blend_mode = BLEND_OVERLAY
		glow_overlay.appearance_flags |= RESET_ALPHA | RESET_COLOR | KEEP_APART
		glow_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

		if(glow_colored)
			var/datum/ColorMatrix/MATRIX = new(light_color, GLOW_CONTRAST_BASE + GLOW_CONTRAST_POWER * light_max_bright, GLOW_BRIGHTNESS_BASE + GLOW_BRIGHTNESS_POWER * light_max_bright)
			glow_overlay.color = MATRIX.Get()

		AddOverlays(glow_overlay)

	if(exposure_icon && exposure_icon_state)
		if(!exposure_overlay)
			exposure_overlay = image(icon = exposure_icon, icon_state = exposure_icon_state, dir = dir, layer = -1)

		exposure_overlay.plane = LIGHTING_EXPOSURE_PLANE
		exposure_overlay.blend_mode = BLEND_ADD
		exposure_overlay.appearance_flags = RESET_ALPHA | RESET_COLOR | KEEP_APART
		exposure_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

		var/datum/ColorMatrix/MATRIX = new(1, EXPOSURE_CONTRAST_BASE + EXPOSURE_CONTRAST_POWER * light_max_bright, EXPOSURE_BRIGHTNESS_BASE + EXPOSURE_BRIGHTNESS_POWER * light_max_bright)
		if(exposure_colored)
			MATRIX.SetColor(light_color, EXPOSURE_CONTRAST_BASE + EXPOSURE_CONTRAST_POWER * light_max_bright, EXPOSURE_BRIGHTNESS_BASE + EXPOSURE_BRIGHTNESS_POWER * light_max_bright)

		exposure_overlay.color = MATRIX.Get()

		var/icon/EX = icon(icon = exposure_icon, icon_state = exposure_icon_state)
		exposure_overlay.pixel_x = 16 - EX.Width() / 2
		exposure_overlay.pixel_y = 16 - EX.Height() / 2

		AddOverlays(exposure_overlay)

/datum/ColorMatrix
	var/list/matrix
	var/combined = 1
	var/const/lumR = 0.3086 //  or  0.2125
	var/const/lumG = 0.6094 //  or  0.7154
	var/const/lumB = 0.0820 //  or  0.0721

/datum/ColorMatrix/New(mat, contrast = 1, brightness = null)
	..()

	if(istext(mat))
		SetPreset(mat)
		if(!matrix)
			SetColor(mat, contrast, brightness)
	else if(isnum(mat))
		SetSaturation(mat, contrast, brightness)
	else
		matrix = mat

/datum/ColorMatrix/proc/Reset()
	matrix = list(1,0,0,
				  0,1,0,
				  0,0,1)

/datum/ColorMatrix/proc/Get(contrast = 1)
	var/list/mat = matrix
	mat = mat.Copy()

	for(var/i = 1 to min(mat.len, 12))
		mat[i] *= contrast

	return mat

/datum/ColorMatrix/proc/SetSaturation(s, c = 1, b = null)
	var/sr = (1 - s) * lumR
	var/sg = (1 - s) * lumG
	var/sb = (1 - s) * lumB

	matrix = list(c * (sr + s), c * (sr),     c * (sr),
				  c * (sg),     c * (sg + s), c * (sg),
				  c * (sb),     c * (sb),     c * (sb + s))

	SetBrightness(b)

/datum/ColorMatrix/proc/SetBrightness(brightness)
	if(brightness == null) return

	if(!matrix)
		Reset()


	if(matrix.len == 9 || matrix.len == 16)
		matrix += brightness
		matrix += brightness
		matrix += brightness

		if(matrix.len == 16)
			matrix += 0

	else if(matrix.len == 12)
		for(var/i = matrix.len to matrix.len - 3 step -1)
			matrix[i] = brightness

	else if(matrix.len == 3)
		for(var/i = matrix.len - 1 to matrix.len - 4 step -1)
			matrix[i] = brightness

/datum/ColorMatrix/proc/hex2value(hex)
	var/num1 = copytext(hex, 1, 2)
	var/num2 = copytext(hex, 2)

	if(isnum(text2num(num1)))
		num1 = text2num(num1)
	else
		num1 = text2ascii(lowertext(num1)) - 87

	if(isnum(text2num(num1)))
		num2 = text2num(num1)
	else
		num2 = text2ascii(lowertext(num2)) - 87

	return num1 * 16 + num2

/datum/ColorMatrix/proc/SetColor(color, contrast = 1, brightness = null)
	var/rr = hex2value(copytext(color, 2, 4)) / 255
	var/gg = hex2value(copytext(color, 4, 6)) / 255
	var/bb = hex2value(copytext(color, 6, 8)) / 255

	rr = round(rr * 1000) / 1000 * contrast
	gg = round(gg * 1000) / 1000 * contrast
	bb = round(bb * 1000) / 1000 * contrast

	matrix = list(rr, gg, bb,
				  rr, gg, bb,
				  rr, gg, bb)

	SetBrightness(brightness)

/datum/ColorMatrix/proc/SetPreset(preset)
	switch(lowertext(preset))
		if("invert")
			matrix = list(-1,0,0,
						  0,-1,0,
						  0,0,-1,
						  1,1,1)
		if("nightsight")
			matrix = list(1,1,1,
						  0,0,0,
						  0,0,0,
						  0.3,0.3,0.3)
		if("nightsight_glasses")
			matrix = list(1,1,1,
						  0,0,0,
						  0,0,0,
						  0.2,0.2,0.2)
		if("thermal")
			matrix = list(1.1, 0, 0,
						  0, 1, 0,
						  0, 0, 1,
						  0, 0, 0)
		if("hos")
			matrix = list(1.2, 0.1, 0,
						  0, 1, 0,
						  0, 0, 1,
						  0, 0, 0)
		if("nvg")
			matrix = list(1,0,0,
						  0,1.1,0,
						  0,0,1,
						  0,0,0)
		if("meson")
			matrix = list(1, 0, 0,
						  0, 1.1, 0,
						  0, 0, 1,
						  -0.05, -0.05, -0.05)
		if("sci")
			matrix = list(1, 0, 0.05,
						  0.05, 0.95, 0.05,
						  0.05, 0, 1,
						  0, 0, 0)
		if("greyscale")
			matrix =  list(0.33, 0.33, 0.33,
						   0.33, 0.33, 0.33,
						   0.33, 0.33, 0.33,
						   0, 0, 0)
		if("sepia")
			matrix = list(0.393,0.349,0.272,
						  0.769,0.686,0.534,
						  0.189,0.168,0.131,
						  0,0,0)
		if("black & white")
			matrix = list(1.5,1.5,1.5,
						  1.5,1.5,1.5,
						  1.5,1.5,1.5,
						  -1,-1,-1)
		if("polaroid")
			matrix = list(1.438,-0.062,-0.062,
						  0.122,1.378,-0.122,
						  0.016,-0.016,1.483,
						  -0.03,0.05,-0.02)
		if("bgr_d")
			matrix = list(0,0,1,
						  0,1,0,
						  1,0,0,
						  0,0,-0.5)
		if("brg_d")
			matrix = list(0,0,1,
						  1,0,0,
						  0,1,0,
						  0,-0.5,0)
		if("gbr_d")
			matrix = list(0,1,0,
						  0,0,1,
						  1,0,0,
						  0,0,-0.5)
		if("grb_d")
			matrix = list(0,1,0,
						  1,0,0,
						  0,0,1,
						  0,-0.5,0)
		if("rbg_d")
			matrix = list(1,0,0,
						  0,0,1,
						  0,1,0,
						  -0.5,0,0)
		if("rgb_d")
			matrix = list(1,0,0,
						  0,1,0,
						  0,0,1,
						  -0.3,-0.3,-0.3)
		if("rgb")
			matrix = list(1,0,0,
						  0,1,0,
						  0,0,1,
						  0,0,0)
