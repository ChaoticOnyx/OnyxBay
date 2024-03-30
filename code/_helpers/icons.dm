/*
	IconProcs README

	A BYOND library for manipulating icons and colors

	by Lummox JR

	version 1.0

	The IconProcs library was made to make a lot of common icon operations much easier. BYOND's icon manipulation
	routines are very capable but some of the advanced capabilities like using alpha transparency can be unintuitive to beginners.

	CHANGING ICONS

	Several new procs have been added to the /icon datum to simplify working with icons. To use them,
	remember you first need to setup an /icon var like so:

	var/icon/my_icon = new('iconfile.dmi')
*/

#define TO_HEX_DIGIT(n) ascii2text((n&15) + ((n&15)<10 ? 48 : 87))

/icon/proc/MakeLying()
	var/icon/I = new(src, dir=SOUTH)
	I.BecomeLying()
	return I

/icon/proc/BecomeLying()
	Turn(90)
	Shift(SOUTH, 6)
	Shift(EAST, 1)

/*
 Multiply all alpha values by this float
 A very common operation in DM is to try to make an icon more or less transparent. Making an icon more
 transparent is usually much easier than making it less so, however. This proc basically is a frontend
 for MapColors() which can change opacity any way you like, in much the same way that SetIntensity()
 can make an icon lighter or darker. If amount is 0.5, the opacity of the icon will be cut in half.
 If amount is 2, opacity is doubled and anything more than half-opaque will become fully opaque.
*/
/icon/proc/ChangeOpacity(opacity = 1.0)
	MapColors(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, opacity, 0, 0, 0, 0)

// Converts the icon to grayscale instead of a fully colored icon. Alpha values are left intact.
/icon/proc/GrayScale()
	MapColors(0.3, 0.3, 0.3, 0.59, 0.59, 0.59, 0.11, 0.11, 0.11, 0, 0,0)

/*
 Similar to GrayScale(), this proc converts the icon to a range of black -> tone -> white, where tone is an
 RGB color (its alpha is ignored). This can be used to create a sepia tone or similar effect.
 See also the global ColorTone() proc.
*/
/icon/proc/ColorTone(tone)
	GrayScale()

	var/list/TONE = ReadRGB(tone)
	var/gray = round(TONE[1]*0.3 + TONE[2]*0.59 + TONE[3]*0.11, 1)

	var/icon/upper = (255 - gray) ? new(src) : null

	if(gray)
		MapColors(255/gray, 0, 0, 0, 255/gray, 0, 0, 0, 255/gray, 0, 0, 0)
		Blend(tone, ICON_MULTIPLY)
	else SetIntensity(0)
	if(255 - gray)
		upper.Blend(rgb(gray, gray, gray), ICON_SUBTRACT)
		upper.MapColors((255 - TONE[1])/(255 - gray),0 ,0 ,0, 0,(255 - TONE[2])/(255 - gray),0, 0, 0, 0,(255 - TONE[3])/(255 - gray),0, 0, 0, 0, 0, 0, 0, 0, 1)
		Blend(upper, ICON_ADD)

/*
 Take the minimum color of two icons; combine transparency as if blending with ICON_ADD
 The icon is blended with a second icon where the minimum of each RGB pixel is the result.
 Transparency may increase, as if the icons were blended with ICON_ADD. You may supply a color in place of an icon.
*/
/icon/proc/MinColors(icon)
	var/icon/I = new(src)
	I.Opaque()
	I.Blend(icon, ICON_SUBTRACT)
	Blend(I, ICON_SUBTRACT)

/*
 Take the maximum color of two icons; combine opacity as if blending with ICON_OR
 The icon is blended with a second icon where the maximum of each RGB pixel is the result.
 Opacity may increase, as if the icons were blended with ICON_OR. You may supply a color in place of an icon.
*/
/icon/proc/MaxColors(icon)
	var/icon/I
	if(isicon(icon))
		I = new(icon)
	else
		// solid color
		I = new(src)
		I.Blend("#000000", ICON_OVERLAY)
		I.SwapColor("#000000", null)
		I.Blend(icon, ICON_OVERLAY)
	var/icon/J = new(src)
	J.Opaque()
	I.Blend(J, ICON_SUBTRACT)
	Blend(I, ICON_OR)

// make this icon fully opaque--transparent pixels become black
// All alpha values are set to 255 throughout the icon. Transparent pixels become black, or whatever background color you specify.
/icon/proc/Opaque(background = "#000000")
	SwapColor(null, background)
	MapColors(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1)

// Change a grayscale icon into a white icon where the original color becomes the alpha
// I.e., black -> transparent, gray -> translucent white, white -> solid white
/icon/proc/BecomeAlphaMask()
	SwapColor(null, "#000000ff") // don't let transparent become gray
	MapColors(0, 0, 0, 0.3, 0, 0, 0, 0.59, 0, 0, 0, 0.11, 0, 0, 0, 0, 1, 1, 1, 0)

/icon/proc/UseAlphaMask(mask)
	Opaque()
	AddAlphaMask(mask)

/icon/proc/AddAlphaMask(mask)
	var/icon/M = new(mask)
	M.Blend("#ffffff", ICON_SUBTRACT)
	// apply mask
	Blend(M, ICON_ADD)

/*
 HSV format is represented as "#hhhssvv" or "#hhhssvvaa"

 Hue ranges from 0 to 0x5ff (1535)
 	0x000 = red
 	0x100 = yellow
 	0x200 = green
 	0x300 = cyan
 	0x400 = blue
 	0x500 = magenta

 Saturation is from 0 to 0xff (255)
 	More saturation = more color
 	Less saturation = more gray

 Value ranges from 0 to 0xff (255)
 	Higher value means brighter color
 */

/proc/ReadRGB(rgb)
	if(!rgb) return

	// interpret the HSV or HSVA value
	var/i = 1, start = 1
	if(text2ascii(rgb) == 35) ++start // skip opening #
	var/ch, which = 0, r = 0, g = 0, b = 0, alpha = 0, usealpha
	var/digits = 0
	for(i = start, i <= length(rgb), ++i)
		ch = text2ascii(rgb, i)
		if(ch < 48 || (ch > 57 && ch < 65) || (ch > 70 && ch < 97) || ch > 102) break
		++digits
		if(digits == 8) break

	var/single = digits < 6
	if(digits != 3 && digits != 4 && digits != 6 && digits != 8) return
	if(digits == 4 || digits == 8) usealpha = 1
	for(i = start, digits > 0, ++i)
		ch = text2ascii(rgb, i)
		if(ch >= 48 && ch <= 57) ch -= 48
		else if(ch >= 65 && ch <= 70) ch -= 55
		else if(ch >= 97 && ch <= 102) ch -= 87
		else break
		--digits
		switch(which)
			if(0)
				r = (r << 4) | ch
				if(single)
					r |= r << 4
					++which
				else if(!(digits & 1)) ++which
			if(1)
				g = (g << 4) | ch
				if(single)
					g |= g << 4
					++which
				else if(!(digits & 1)) ++which
			if(2)
				b = (b << 4) | ch
				if(single)
					b |= b << 4
					++which
				else if(!(digits & 1)) ++which
			if(3)
				alpha = (alpha << 4) | ch
				if(single) alpha |= alpha << 4

	. = list(r, g, b)
	if(usealpha) . += alpha

/proc/ReadHSV(hsv)
	if(!hsv) return

	// interpret the HSV or HSVA value
	var/i = 1, start = 1
	if(text2ascii(hsv) == 35) ++start // skip opening #
	var/ch, which = 0, hue = 0, sat = 0, val = 0, alpha = 0, usealpha
	var/digits = 0
	for(i = start, i <= length(hsv), ++i)
		ch = text2ascii(hsv, i)
		if(ch < 48 || (ch > 57 && ch < 65) || (ch > 70 && ch < 97) || ch > 102) break
		++digits
		if(digits == 9) break
	if(digits > 7) usealpha = 1
	if(digits <= 4) ++which
	if(digits <= 2) ++which
	for(i = start, digits > 0, ++i)
		ch = text2ascii(hsv, i)
		if(ch >= 48 && ch <= 57) ch -= 48
		else if(ch >= 65 && ch <= 70) ch -= 55
		else if(ch >= 97 && ch <= 102) ch -= 87
		else break
		--digits
		switch(which)
			if(0)
				hue = (hue << 4) | ch
				if(digits == (usealpha ? 6 : 4)) ++which
			if(1)
				sat = (sat << 4) | ch
				if(digits == (usealpha ? 4 : 2)) ++which
			if(2)
				val = (val << 4) | ch
				if(digits == (usealpha ? 2 : 0)) ++which
			if(3)
				alpha = (alpha << 4) | ch

	. = list(hue, sat, val)
	if(usealpha) . += alpha

/proc/HSVtoRGB(hsv)
	if(!hsv) return "#000000"
	var/list/HSV = ReadHSV(hsv)
	if(!HSV) return "#000000"

	var/hue = HSV[1]
	var/sat = HSV[2]
	var/val = HSV[3]

	// Compress hue into easier-to-manage range
	hue -= hue >> 8
	if(hue >= 0x5fa) hue -= 0x5fa

	var/hi, mid, lo, r, g, b
	hi = val
	lo = round((255 - sat) * val / 255, 1)
	mid = lo + round(abs(round(hue, 510) - hue) * (hi - lo) / 255, 1)
	if(hue >= 765)
		if(hue >= 1275)      {r = hi;  g = lo;  b = mid}
		else if(hue >= 1020) {r = mid; g = lo;  b = hi }
		else                 {r = lo;  g = mid; b = hi }
	else
		if(hue >= 510)       {r = lo;  g = hi;  b = mid}
		else if(hue >= 255)  {r = mid; g = hi;  b = lo }
		else                 {r = hi;  g = mid; b = lo }

	return (HSV.len > 3) ? rgb(r, g, b, HSV[4]) : rgb(r, g, b)

/proc/RGBtoHSV(rgb)
	if(!rgb) return "#0000000"
	var/list/RGB = ReadRGB(rgb)
	if(!RGB) return "#0000000"

	var/r = RGB[1]
	var/g = RGB[2]
	var/b = RGB[3]
	var/hi = max(r, g, b)
	var/lo = min(r, g, b)

	var/val = hi
	var/sat = hi ? round((hi - lo) * 255 / hi, 1) : 0
	var/hue = 0

	if(sat)
		var/dir
		var/mid
		if(hi == r)
			if(lo == b) {hue = 0; dir = 1; mid = g}
			else {hue = 1535; dir = -1; mid = b}
		else if(hi == g)
			if(lo == r) {hue = 512; dir = 1; mid = b}
			else {hue = 511; dir = -1; mid = r}
		else if(hi == b)
			if(lo == g) {hue = 1024; dir = 1; mid = r}
			else {hue = 1023; dir =-1; mid = g}
		hue += dir * round((mid - lo) * 255 / (hi - lo), 1)

	return hsv(hue, sat, val, (RGB.len > 3 ? RGB[4] : null))

/proc/hsv(hue, sat, val, alpha)
	if(hue < 0 || hue >= 1536) hue %= 1536
	if(hue < 0) hue += 1536
	if((hue & 0xFF) == 0xFF)
		++hue
		if(hue >= 1536) hue = 0
	if(sat < 0) sat = 0
	if(sat > 255) sat = 255
	if(val < 0) val = 0
	if(val > 255) val = 255
	. = "#"
	. += TO_HEX_DIGIT(hue >> 8)
	. += TO_HEX_DIGIT(hue >> 4)
	. += TO_HEX_DIGIT(hue)
	. += TO_HEX_DIGIT(sat >> 4)
	. += TO_HEX_DIGIT(sat)
	. += TO_HEX_DIGIT(val >> 4)
	. += TO_HEX_DIGIT(val)
	if(!isnull(alpha))
		if(alpha < 0) alpha = 0
		if(alpha > 255) alpha = 255
		. += TO_HEX_DIGIT(alpha >> 4)
		. += TO_HEX_DIGIT(alpha)

/*
	Smooth blend between HSV colors

	amount=0 is the first color
	amount=1 is the second color
	amount=0.5 is directly between the two colors

	amount<0 or amount>1 are allowed
*/
/proc/BlendHSV(hsv1, hsv2, amount)
	var/list/HSV1 = ReadHSV(hsv1)
	var/list/HSV2 = ReadHSV(hsv2)

	// add missing alpha if needed
	if(HSV1.len < HSV2.len) HSV1 += 255
	else if(HSV2.len < HSV1.len) HSV2 += 255
	var/usealpha = HSV1.len > 3

	// normalize hsv values in case anything is screwy
	if(HSV1[1] > 1536) HSV1[1] %= 1536
	if(HSV2[1] > 1536) HSV2[1] %= 1536
	if(HSV1[1] < 0) HSV1[1] += 1536
	if(HSV2[1] < 0) HSV2[1] += 1536
	if(!HSV1[3]) {HSV1[1] = 0; HSV1[2] = 0}
	if(!HSV2[3]) {HSV2[1] = 0; HSV2[2] = 0}

	// no value for one color means don't change saturation
	if(!HSV1[3]) HSV1[2] = HSV2[2]
	if(!HSV2[3]) HSV2[2] = HSV1[2]
	// no saturation for one color means don't change hues
	if(!HSV1[2]) HSV1[1] = HSV2[1]
	if(!HSV2[2]) HSV2[1] = HSV1[1]

	// Compress hues into easier-to-manage range
	HSV1[1] -= HSV1[1] >> 8
	HSV2[1] -= HSV2[1] >> 8

	var/hue_diff = HSV2[1] - HSV1[1]
	if(hue_diff > 765) hue_diff -= 1530
	else if(hue_diff <= -765) hue_diff += 1530

	var/hue = round(HSV1[1] + hue_diff * amount, 1)
	var/sat = round(HSV1[2] + (HSV2[2] - HSV1[2]) * amount, 1)
	var/val = round(HSV1[3] + (HSV2[3] - HSV1[3]) * amount, 1)
	var/alpha = usealpha ? round(HSV1[4] + (HSV2[4] - HSV1[4]) * amount, 1) : null

	// normalize hue
	if(hue < 0 || hue >= 1530) hue %= 1530
	if(hue < 0) hue += 1530
	// decompress hue
	hue += round(hue / 255)

	return hsv(hue, sat, val, alpha)

/*
	Smooth blend between RGB colors

	amount=0 is the first color
	amount=1 is the second color
	amount=0.5 is directly between the two colors

	amount<0 or amount>1 are allowed
*/
/proc/BlendRGB(rgb1, rgb2, amount)
	var/list/RGB1 = ReadRGB(rgb1)
	var/list/RGB2 = ReadRGB(rgb2)

	// add missing alpha if needed
	if(RGB1.len < RGB2.len) RGB1 += 255
	else if(RGB2.len < RGB1.len) RGB2 += 255
	var/usealpha = RGB1.len > 3

	var/r = round(RGB1[1] + (RGB2[1] - RGB1[1]) * amount, 1)
	var/g = round(RGB1[2] + (RGB2[2] - RGB1[2]) * amount, 1)
	var/b = round(RGB1[3] + (RGB2[3] - RGB1[3]) * amount, 1)
	var/alpha = usealpha ? round(RGB1[4] + (RGB2[4] - RGB1[4]) * amount, 1) : null

	return isnull(alpha) ? rgb(r, g, b) : rgb(r, g, b, alpha)

/proc/BlendRGBasHSV(rgb1, rgb2, amount)
	return HSVtoRGB(RGBtoHSV(rgb1), RGBtoHSV(rgb2), amount)

/proc/HueToAngle(hue)
	// normalize hsv in case anything is screwy
	if(hue < 0 || hue >= 1536) hue %= 1536
	if(hue < 0) hue += 1536
	// Compress hue into easier-to-manage range
	hue -= hue >> 8
	return hue / (1530/360)

/proc/AngleToHue(angle)
	// normalize hsv in case anything is screwy
	if(angle < 0 || angle >= 360) angle -= 360 * round(angle / 360)
	var/hue = angle * (1530/360)
	// Decompress hue
	hue += round(hue / 255)
	return hue


// positive angle rotates forward through red->green->blue
/proc/RotateHue(hsv, angle)
	var/list/HSV = ReadHSV(hsv)

	// normalize hsv in case anything is screwy
	if(HSV[1] >= 1536) HSV[1] %= 1536
	if(HSV[1] < 0) HSV[1] += 1536

	// Compress hue into easier-to-manage range
	HSV[1] -= HSV[1] >> 8

	if(angle < 0 || angle >= 360) angle -= 360 * round(angle / 360)
	HSV[1] = round(HSV[1] + angle * (1530/360), 1)

	// normalize hue
	if(HSV[1] < 0 || HSV[1] >= 1530) HSV[1] %= 1530
	if(HSV[1] < 0) HSV[1] += 1530
	// decompress hue
	HSV[1] += round(HSV[1] / 255)

	return hsv(HSV[1], HSV[2], HSV[3], (HSV.len > 3 ? HSV[4] : null))

// Convert an rgb color to grayscale
/proc/GrayScale(rgb)
	var/list/RGB = ReadRGB(rgb)
	var/gray = RGB[1]*0.3 + RGB[2]*0.59 + RGB[3]*0.11
	return (RGB.len > 3) ? rgb(gray, gray, gray, RGB[4]) : rgb(gray, gray, gray)

// Change grayscale color to black->tone->white range
/proc/ColorTone(rgb, tone)
	var/list/RGB = ReadRGB(rgb)
	var/list/TONE = ReadRGB(tone)

	var/gray = RGB[1]*0.3 + RGB[2]*0.59 + RGB[3]*0.11
	var/tone_gray = TONE[1]*0.3 + TONE[2]*0.59 + TONE[3]*0.11

	if(gray <= tone_gray) return BlendRGB("#000000", tone, gray / (tone_gray || 1))
	else return BlendRGB(tone, "#ffffff", (gray - tone_gray) / ((255 - tone_gray) || 1))

/*
	Get flat icon by DarkCampainger. As it says on the tin, will return an icon with all the overlays
	as a single icon. Useful for when you want to manipulate an icon via the above as overlays are not normally included.
	The _flatIcons list is a cache for generated icon files.
*/

// Creates a single icon from a given /atom or /image.  Only the first argument is required.
/proc/getFlatIcon(image/appearance, defdir, deficon, defstate, defblend, start = TRUE, no_anim = FALSE, always_use_defdir = FALSE)
	// Loop through the underlays, then overlays, sorting them into the layers list
	#define PROCESS_OVERLAYS_OR_UNDERLAYS(flat, process, base_layer) \
		for (var/i in 1 to process.len) { \
			var/image/current = process[i]; \
			if (!current) { \
				continue; \
			} \
			if (current.plane != FLOAT_PLANE && current.plane != appearance.plane) { \
				continue; \
			} \
			var/current_layer = current.layer; \
			if (current_layer < 0) { \
				if (current_layer <= -1000) { \
					return flat; \
				} \
				current_layer = base_layer + appearance.layer + current_layer / 1000; \
			} \
			for (var/index_to_compare_to in 1 to layers.len) { \
				var/compare_to = layers[index_to_compare_to]; \
				if (current_layer < layers[compare_to]) { \
					layers.Insert(index_to_compare_to, current); \
					break; \
				} \
			} \
			layers[current] = current_layer; \
		}

	var/static/icon/flat_template = icon('icons/effects/blank.dmi')

	if(!appearance || appearance.alpha <= 0)
		return icon(flat_template)

	if(start)
		if(!defdir)
			defdir = appearance.dir
		if(!deficon)
			deficon = appearance.icon
		if(!defstate)
			defstate = appearance.icon_state
		if(!defblend)
			defblend = appearance.blend_mode

	var/curicon = appearance.icon || deficon
	var/curstate = appearance.icon_state || defstate
	var/curdir = (!appearance.dir || appearance.dir == SOUTH || always_use_defdir) ? defdir : appearance.dir

	var/render_icon = curicon

	if(render_icon)
		var/curstates = icon_states(curicon)
		if(!(curstate in curstates))
			if ("" in curstates)
				curstate = ""
			else
				render_icon = FALSE

	var/base_icon_dir //We'll use this to get the icon state to display if not null BUT NOT pass it to overlays as the dir we have

	//Try to remove/optimize this section ASAP, CPU hog.
	//Determines if there's directionals.
	if(render_icon && curdir != SOUTH)
		if (
			!length(icon_states(icon(curicon, curstate, NORTH))) \
			&& !length(icon_states(icon(curicon, curstate, EAST))) \
			&& !length(icon_states(icon(curicon, curstate, WEST))) \
		)
			base_icon_dir = SOUTH

	if(!base_icon_dir)
		base_icon_dir = curdir

	var/curblend = appearance.blend_mode || defblend

	if(appearance.overlays.len || appearance.underlays.len)
		var/icon/flat = icon(flat_template)
		// Layers will be a sorted list of icons/overlays, based on the order in which they are displayed
		var/list/layers = list()
		var/image/copy
		// Add the atom's icon itself, without pixel_x/y offsets.
		if(render_icon)
			copy = image(icon=curicon, icon_state=curstate, layer=appearance.layer, dir=base_icon_dir)
			copy.color = appearance.color
			copy.alpha = appearance.alpha
			copy.blend_mode = curblend
			layers[copy] = appearance.layer

		PROCESS_OVERLAYS_OR_UNDERLAYS(flat, appearance.underlays, 0)
		PROCESS_OVERLAYS_OR_UNDERLAYS(flat, appearance.overlays, 1)

		var/icon/add // Icon of overlay being added

		var/flatX1 = 1
		var/flatX2 = flat.Width()
		var/flatY1 = 1
		var/flatY2 = flat.Height()

		var/addX1 = 0
		var/addX2 = 0
		var/addY1 = 0
		var/addY2 = 0

		for(var/I in layers)
			var/image/layer_image = I
			if(layer_image.plane == EMISSIVE_PLANE) // Just replace this with whatever it is TG is doing these days sometime. Getflaticon breaks emissives
				continue

			if(layer_image.alpha == 0)
				continue

			if(layer_image == copy) // 'layer_image' is an /image based on the object being flattened.
				curblend = BLEND_OVERLAY
				add = icon(layer_image.icon, layer_image.icon_state, base_icon_dir)
			else // 'I' is an appearance object.
				add = getFlatIcon(image(layer_image), curdir, curicon, curstate, curblend, FALSE, no_anim, always_use_defdir)
			if(!add)
				continue

			// Find the new dimensions of the flat icon to fit the added overlay
			addX1 = min(flatX1, layer_image.pixel_x + 1)
			addX2 = max(flatX2, layer_image.pixel_x + add.Width())
			addY1 = min(flatY1, layer_image.pixel_y + 1)
			addY2 = max(flatY2, layer_image.pixel_y + add.Height())

			if (
				addX1 != flatX1 \
				&& addX2 != flatX2 \
				&& addY1 != flatY1 \
				&& addY2 != flatY2 \
			)
				// Resize the flattened icon so the new icon fits
				flat.Crop(
					addX1 - flatX1 + 1,
					addY1 - flatY1 + 1,
					addX2 - flatX1 + 1,
					addY2 - flatY1 + 1
				)

				flatX1 = addX1
				flatX2 = addY1
				flatY1 = addX2
				flatY2 = addY2

			// Blend the overlay into the flattened icon
			flat.Blend(add, blendMode2iconMode(curblend), layer_image.pixel_x + 2 - flatX1, layer_image.pixel_y + 2 - flatY1)

		if(appearance.color)
			if(islist(appearance.color))
				flat.MapColors(arglist(appearance.color))
			else
				flat.Blend(appearance.color, ICON_MULTIPLY)

		if(appearance.alpha < 255)
			flat.Blend(rgb(255, 255, 255, appearance.alpha), ICON_MULTIPLY)

		if(no_anim)
			//Clean up repeated frames
			var/icon/cleaned = new /icon()
			cleaned.Insert(flat, "", SOUTH, 1, 0)
			return cleaned
		else
			return icon(flat, "", SOUTH)
	else if (render_icon) // There's no overlays.
		var/icon/final_icon = icon(icon(curicon, curstate, base_icon_dir), "", SOUTH, no_anim ? TRUE : null)

		if (appearance.alpha < 255)
			final_icon.Blend(rgb(255,255,255, appearance.alpha), ICON_MULTIPLY)

		if (appearance.color)
			if (islist(appearance.color))
				final_icon.MapColors(arglist(appearance.color))
			else
				final_icon.Blend(appearance.color, ICON_MULTIPLY)

		return final_icon

	#undef PROCESS_OVERLAYS_OR_UNDERLAYS

//By yours truly. Creates a dynamic mask for a mob/whatever. /N
/proc/getIconMask(atom/A)
	var/icon/alpha_mask = new(A.icon, A.icon_state) // So we want the default icon and icon state of A.
	for(var/V in A.overlays) // For every image in overlays. var/image/I will not work, don't try it.
		var/image/I = V
		if(I.layer > A.layer)
			continue // If layer is greater than what we need, skip it.
		var/icon/image_overlay = new(I.icon, I.icon_state) // Blend only works with icon objects.
		// Also, icons cannot directly set icon_state. Slower than changing variables but whatever.
		alpha_mask.Blend(image_overlay, ICON_OR) // OR so they are lumped together in a nice overlay.
	return alpha_mask // And now return the mask.

// A is the atom which we are using as the overlay.
/mob/proc/AddCamoOverlay(atom/A)
	var/icon/opacity_icon = new(A.icon, A.icon_state) // Don't really care for overlays/underlays.
	// Now we need to culculate overlays+underlays and add them together to form an image for a mask.
	// var/icon/alpha_mask = getFlatIcon(src) Accurate but SLOW. Not designed for running each tick. Could have other uses I guess.
	// Which is why I created that proc. Also a little slow since it's blending a bunch of icons together but good enough.
	var/icon/alpha_mask = getIconMask(src)
	// Likely the main source of lag for this proc. Probably not designed to run each tick.
	opacity_icon.AddAlphaMask(alpha_mask)
	// Front end for MapColors so it's fast. 0.5 means half opacity and looks the best in my opinion.
	opacity_icon.ChangeOpacity(0.4)
	// And now we add it as overlays. It's faster than creating an icon and then merging it.
	for(var/i = 0, i < 5, i++)
		// So it's above other stuff but below weapons and the like.
		var/image/I = image("icon" = opacity_icon, "icon_state" = A.icon_state, "layer" = layer+0.8)
		// Now to determine offset so the result is somewhat blurred.
		switch(i)
			if(1)	I.pixel_x--
			if(2)	I.pixel_x++
			if(3)	I.pixel_y--
			if(4)	I.pixel_y++
		AddOverlays(I) // And finally add the overlay.

// For determining the color of holopads based on whether they're short or long range.
#define HOLOPAD_SHORT_RANGE 1
#define HOLOPAD_LONG_RANGE 2

// If safety is on, a new icon is not created.
/proc/getHologramIcon(icon/A, safety = 1, noDecolor = FALSE, hologram_color = HOLOPAD_SHORT_RANGE)
	// Has to be a new icon to not constantly change the same icon.
	var/icon/flat_icon = safety ? A : new(A)
	if (noDecolor == FALSE)
		if(hologram_color == HOLOPAD_LONG_RANGE)
			flat_icon.ColorTone(rgb(225, 223, 125)) // Light yellow if it's a call to a long-range holopad.
		else
			flat_icon.ColorTone(rgb(125, 180, 225)) // Let's make it bluish.
	flat_icon.ChangeOpacity(0.5) // Make it half transparent.
	// Scanline effect.
	var/icon/alpha_mask = new('icons/effects/effects.dmi', "scanline-[hologram_color]")
	flat_icon.AddAlphaMask(alpha_mask) // Finally, let's mix in a distortion effect.
	return flat_icon

// For photo camera.
/proc/build_composite_icon(atom/A)
	var/icon/composite = icon(A.icon, A.icon_state, A.dir, 1)
	for(var/O in A.overlays)
		var/image/I = O
		composite.Blend(icon(I.icon, I.icon_state, I.dir, 1), ICON_OVERLAY)
	return composite

/proc/adjust_brightness(color, value)
	if (!color) return "#ffffff"
	if (!value) return color

	var/list/RGB = ReadRGB(color)
	RGB[1] = Clamp(RGB[1]+value, 0, 255)
	RGB[2] = Clamp(RGB[2]+value, 0, 255)
	RGB[3] = Clamp(RGB[3]+value, 0, 255)
	return rgb(RGB[1],RGB[2],RGB[3])

/proc/sort_atoms_by_layer(list/atoms)
	// Comb sort icons based on levels
	var/list/result = atoms.Copy()
	var/gap = result.len
	var/swapped = 1
	while (gap > 1 || swapped)
		swapped = 0
		if(gap > 1)
			gap = round(gap / 1.3) // 1.3 is the emperic comb sort coefficient
		if(gap < 1)
			gap = 1
		for(var/i = 1; gap + i <= result.len; i++)
			var/atom/l = result[i] // Fucking hate
			var/atom/r = result[gap + i] // how lists work here
			// no "result[i].layer" for me
			if(l.plane > r.plane || (l.plane == r.plane && l.layer > r.layer))
				result.Swap(i, gap + i)
				swapped = 1
	return result
/*
	generate_image function generates image of specified range and location
	arguments tx, ty, tz are target coordinates (requred), range defines render distance to opposite corner (requred)
	cap_mode is capturing mode (optional), user is capturing mob (requred only wehen cap_mode = CAPTURE_MODE_REGULAR),
	lighting determines lighting capturing (optional), suppress_errors suppreses errors and continues to capture (optional).
*/
/proc/generate_image(tx, ty, tz, range, cap_mode = CAPTURE_MODE_PARTIAL, mob/living/user, lighting = 1, suppress_errors = 1, see_ghosts = FALSE)
	var/list/turfstocapture = list()
	// Lines below determine what tiles will be rendered
	for(var/xoff = 0 to range)
		for(var/yoff = 0 to range)
			var/turf/T = locate(tx + xoff, ty + yoff, tz)
			if(T)
				if(cap_mode == CAPTURE_MODE_REGULAR)
					if(user.can_capture_turf(T))
						turfstocapture.Add(T)
						continue
				else
					turfstocapture.Add(T)
			else
				// Capture includes non-existan turfs
				if(!suppress_errors)
					return
	// Lines below determine what objects will be rendered
	var/list/atoms = list()
	for(var/turf/T in turfstocapture)
		atoms.Add(T)
		for(var/atom/A in T)
			if(istype(A, /atom/movable/lighting_overlay) && lighting) // Special case for lighting
				atoms.Add(A)
				continue
			if(isghost(A) && (prob(1 + GLOB.cult.cult_rating * 0.1) || see_ghosts))
				atoms.Add(A)
				continue
			if(A.invisibility)
				continue
			atoms.Add(A)
	// Lines below actually render all colected data
	atoms = sort_atoms_by_layer(atoms)
	var/icon/cap = icon('icons/effects/96x96.dmi', "")
	cap.Scale(range * 32, range * 32)
	cap.Blend("#000", ICON_OVERLAY)
	for(var/atom/A in atoms)
		if(A)
			var/icon/img = ishuman(A) ? A.get_flat_icon(user) : getFlatIcon(A, no_anim = TRUE)
			if(istype(img, /icon))
				if(istype(A, /mob/living) && A:lying)
					img.BecomeLying()
				var/xoff = (A.x - tx) * 32
				var/yoff = (A.y - ty) * 32
				cap.Blend(img, blendMode2iconMode(A.blend_mode),  A.pixel_x + xoff, A.pixel_y + yoff)

	return cap

/proc/icon2html(thing, target, icon_state, dir, frame = 1, moving = FALSE, realsize = FALSE, sourceonly = FALSE, class = null)
	if (!thing)
		return

	var/key
	var/icon/I = thing
	if (!target)
		return
	if (target == world)
		target = GLOB.clients

	var/list/targets
	if (!islist(target))
		targets = list(target)
	else
		targets = target
		if (!targets.len)
			return
	if (!isicon(I))
		if (isfile(thing)) // special snowflake
			var/name = "[generate_asset_name(thing)].png"
			register_asset(name, thing)
			for (var/thing2 in targets)
				ASSERT(isclient(thing2) || ismob(thing2))
				if(ismob(thing2))
					var/mob/M = thing2
					if(!M.client)
						continue
					thing2 = M.client
				send_asset(thing2, key, FALSE)

			if(sourceonly)
				return url_encode(key)

			return "<img class='icon icon-misc [class]' src=\"[url_encode(name)]\">"
		var/atom/A = thing
		if (isnull(dir))
			dir = A.dir
		if (isnull(icon_state))
			icon_state = A.icon_state
		I = A.icon
		if (ishuman(thing)) // Shitty workaround for a BYOND issue.
			var/icon/temp = I
			I = icon()
			I.Insert(temp, dir = SOUTH)
			dir = SOUTH
	else
		if (isnull(dir))
			dir = SOUTH
		if (isnull(icon_state))
			icon_state = ""

	I = icon(I, icon_state, dir, frame, moving)

	key = "[generate_asset_name(I)].png"
	register_asset(key, I)
	for (var/thing2 in targets)
		ASSERT(isclient(thing2) || ismob(thing2))
		if(ismob(thing2))
			var/mob/M = thing2
			if(!M.client)
				continue
			thing2 = M.client
		send_asset(thing2, key, FALSE)

	if(sourceonly)
		return url_encode(key)

	if(realsize)
		return "<img class='icon icon-[icon_state] [class]' style='width:[I.Width()]px;height:[I.Height()]px;min-height:[I.Height()]px' src=\"[url_encode(key)]\">"

	return "<img class='icon icon-[icon_state] [class]' src=\"[url_encode(key)]\">"

/proc/build_composite_icon_omnidir(atom/A)
	var/icon/composite = icon('icons/effects/effects.dmi', "icon_state"="nothing")
	for(var/O in A.underlays)
		var/image/I = O
		composite.Blend(new /icon(I.icon, I.icon_state), ICON_OVERLAY)
	var/icon/ico_omnidir = new(A.icon)
	if(A.icon_state in ico_omnidir.IconStates())
		composite.Blend(new /icon(ico_omnidir, A.icon_state), ICON_OVERLAY)
	else
		composite.Blend(new /icon(ico_omnidir, null), ICON_OVERLAY)
	for(var/O in A.overlays)
		var/image/I = O
		composite.Blend(new /icon(I.icon, I.icon_state), ICON_OVERLAY)
	return composite

/// Costlier version of icon2html() that uses getFlatIcon() to account for overlays, underlays, etc. Use with extreme moderation, ESPECIALLY on mobs.
/proc/costly_icon2html(thing, target, sourceonly = FALSE)
	if (!thing)
		return

	if (isicon(thing))
		return icon2html(thing, target)

	var/icon/I = getFlatIcon(thing)
	return icon2html(I, target, sourceonly = sourceonly)

/proc/path2icon(path, dir = SOUTH, frame = 1, moving = FALSE)
	var/atom/A = path
	return icon(initial(A.icon), initial(A.icon_state), dir, frame, moving)

/*
 *	Converts an icon to base64. Operates by putting the icon in the iconCache savefile,
 *	exporting it as text, and then parsing the base64 from that.
 *	(This relies on byond automatically storing icons in savefiles as base64)
 */
/proc/icon2base64(icon/icon)
	ASSERT(isicon(icon))

	var/savefile/dummySave = new("tmp/dummySave.sav")
	dummySave["dummy"] << icon
	var/iconData = dummySave.ExportText("dummy")
	var/list/partial = splittext(splittext(iconData, "{")[2], "}")[1]

	// If cleanup fails we want to still return the correct base64
	. = replacetext(copytext_char(partial, 3, -2), "\n", "")
	dummySave.Unlock()
	dummySave = null

	// If you get the idea to try and make this more optimized,
	// make sure to still call unlock on the savefile after every write to unlock it.
	fdel("tmp/dummySave.sav")

// This proc accepts an icon or a path you need the icon from.
/proc/icon2base64html(thing)
	var/static/list/bicon_cache = list()

	ASSERT(thing)

	if(ispath(thing))
		var/atom/A = thing
		var/key = "[initial(A.icon)]-[initial(A.icon_state)]"
		var/cached = bicon_cache[key]

		if(!cached)
			bicon_cache[key] = cached = icon2base64(path2icon(A))

		return "<img class='game-icon' src='data:image/png;base64,[cached]'>"
	if(isicon(thing))
		var/key = "\ref[thing]"
		var/cached = bicon_cache[key]

		if(!cached)
			bicon_cache[key] = cached = icon2base64(thing)

		return "<img class='game-icon' src='data:image/png;base64,[cached]'>"

	CRASH("[thing] is must be a path or an icon")

/mob/living/carbon/human/proc/generate_preview()
	var/icon/flat = icon('icons/effects/blank.dmi') // Final flattened icon

	// Layers will be a sorted list of icons/overlays, based on the order in which they are displayed
	var/list/layers = overlays.Copy()
	var/icon/add // Icon of overlay being added

	for(var/I in layers)
		if(isnull(I))
			continue
		var/image/layer_image = I
		if(layer_image.plane != FLOAT_PLANE)
			continue

		if(!layer_image.icon)
			continue

		if(layer_image.alpha == 0)
			continue

		//add = icon(layer_image.icon, layer_image.icon_state, dir)
		add = getFlatIcon(image(I), dir, null, null, null, FALSE, TRUE, TRUE)
		flat.Blend(add, ICON_OVERLAY)

	if(color)
		flat.Blend(color, ICON_MULTIPLY)
	if(alpha < 255)
		flat.Blend(rgb(255, 255, 255, alpha), ICON_MULTIPLY)

	return icon(flat, "", SOUTH)

// Returns a flattened icon of an atom with emissive blockers stripped.
// The icon gets rendered on 'caller's side. If there's no 'caller' provided or the 'caller' has no client,
// the icon will be rendered on a random client's side (unless 'allow_ratty_rendering = FALSE', in this case we give up).
// 'dir' accepts either a single dir, uses 'src.dir' if not provided.
// I'm not completely sure how ethical the 'allow_ratty_rendering' usage is, since it's basically lowkey cryptomining, but who fucking cares?
/atom/proc/get_flat_icon(mob/caller, dir, force_appearance_flags, allow_ratty_rendering = TRUE)
	var/client/rendering_client
	if(caller?.client)
		rendering_client = caller.client // We are good, let the caller deal with their own stuff.
	else if(allow_ratty_rendering)
		for(var/mob/prey in shuffle(GLOB.player_list)) // We are not that good, randomly choosing a poor being to deal with rendering.
			if(prey?.client)
				rendering_client = prey.client
				break

	if(!rendering_client)
		return null // Everything's broken somehow, giving up.

	if(!dir)
		dir = src.dir

	var/obj/dummy = new
	dummy.appearance_flags = DEFAULT_APPEARANCE_FLAGS | NO_CLIENT_COLOR
	dummy.icon = icon
	dummy.icon_state = icon_state
	dummy.alpha = alpha
	dummy.color = color
	dummy.transform = transform
	dummy.dir = dir

	for(var/entry in overlays)
		var/image/I = entry
		var/mutable_appearance/MA = new(I)
		if(MA.plane == EMISSIVE_PLANE)
			continue
		MA.dir = dir
		MA.appearance_flags = I.appearance_flags | force_appearance_flags
		dummy.underlays += MA

	for(var/entry in overlays)
		var/image/I = entry
		var/mutable_appearance/MA = new(I)
		if(MA.plane == EMISSIVE_PLANE)
			continue
		MA.dir = dir
		MA.appearance_flags = I.appearance_flags | force_appearance_flags
		dummy.overlays += MA

	qdel(dummy)
	return icon(rendering_client.RenderIcon(dummy))

// Extended version of the above. It can accept 'dirs' as a list, and returns an icon with all the provided directions inserted.
// It's cheaper than calling 'get_flat_icon' multiple times.
/atom/proc/get_flat_icon_directional(mob/caller, dirs = null, force_appearance_flags, allow_ratty_rendering = TRUE)
	var/client/rendering_client
	if(caller?.client)
		rendering_client = caller.client // We are good, let the caller deal with their own stuff.
	else if(allow_ratty_rendering)
		for(var/mob/prey in shuffle(GLOB.player_list)) // We are not that good, randomly choosing a poor being to deal with rendering.
			if(prey?.client)
				rendering_client = prey.client
				break

	if(!rendering_client)
		return list() // Everything's broken somehow, giving up.

	var/dirs_list = list() // Final list of directions we'll use
	dirs_list |= LAZYLEN(dirs) ? dirs : GLOB.cardinal

	 // Multiple dummies. Apparently, RenderIcon() is a bit slow (it waits for the next tick, I guess), so if we were to use a single dummy object,
	 // it would return some icons AFTER we've already turned it to match the next direction, resulting in wrong directions in the resulting icon.
	var/list/dummies = list()
	for(var/_dir in dirs_list)
		var/obj/dummy = new

		dummy.appearance_flags = DEFAULT_APPEARANCE_FLAGS | NO_CLIENT_COLOR | force_appearance_flags
		dummy.icon = icon
		dummy.icon_state = icon_state
		dummy.alpha = alpha
		dummy.color = color
		dummy.transform = transform

		dummies["[_dir]"] = dummy

	var/icon/ret = icon('icons/effects/blank.dmi')

	for(var/current_dir in dirs_list)
		var/obj/dummy = dummies["[current_dir]"]
		dummy.dir = current_dir

		for(var/entry in overlays)
			var/image/I = entry
			var/mutable_appearance/MA = new(I)
			if(MA.plane == EMISSIVE_PLANE)
				continue
			MA.dir = current_dir
			MA.appearance_flags = I.appearance_flags | force_appearance_flags
			dummy.underlays += MA

		for(var/entry in overlays)
			var/image/I = entry
			var/mutable_appearance/MA = new(I)
			if(MA.plane == EMISSIVE_PLANE)
				continue
			MA.dir = current_dir
			MA.appearance_flags = I.appearance_flags | force_appearance_flags
			dummy.overlays += MA

		ret.Insert(rendering_client.RenderIcon(dummy), dir = current_dir)

	QDEL_LIST_ASSOC_VAL(dummies)
	return ret
