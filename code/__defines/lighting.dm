
#define LIGHTING_ICON 'icons/effects/lighting_overlay.dmi' // icon used for lighting shading effects
#define LIGHTING_ICON_STATE_DARK "dark" // Change between "soft_dark" and "dark" to swap soft darkvision

#define LIGHTING_ROUND_VALUE (1 / 64) // Value used to round lumcounts, values smaller than 1/69 don't matter (if they do, thanks sinking points), greater values will make lighting less precise, but in turn increase performance, VERY SLIGHTLY.

#define LIGHTING_SOFT_THRESHOLD 0 // If the max of the lighting lumcounts of each spectrum drops below this, disable luminosity on the lighting overlays.  This also should be the transparancy of the "soft_dark" icon state.

#define LIGHTING_MULT_FACTOR 0.9

// If I were you I'd leave this alone.
#define LIGHTING_BASE_MATRIX \
	list                     \
	(                        \
		LIGHTING_SOFT_THRESHOLD, LIGHTING_SOFT_THRESHOLD, LIGHTING_SOFT_THRESHOLD, 0, \
		LIGHTING_SOFT_THRESHOLD, LIGHTING_SOFT_THRESHOLD, LIGHTING_SOFT_THRESHOLD, 0, \
		LIGHTING_SOFT_THRESHOLD, LIGHTING_SOFT_THRESHOLD, LIGHTING_SOFT_THRESHOLD, 0, \
		LIGHTING_SOFT_THRESHOLD, LIGHTING_SOFT_THRESHOLD, LIGHTING_SOFT_THRESHOLD, 0, \
		0, 0, 0, 1           \
	)

#define LIGHTMODE_EMERGENCY "emergency_lighting"
#define LIGHTMODE_EVACUATION "evacuation_lighting"
#define LIGHTMODE_ALARM "alarm"
#define LIGHTMODE_READY "ready"
#define LIGHTMODE_RADSTORM "radiation_storm"

#define ADDITIVE_LIGHTING_PLANE_ALPHA_MAX 255
#define ADDITIVE_LIGHTING_PLANE_ALPHA_NORMAL 128
#define ADDITIVE_LIGHTING_PLANE_ALPHA_INVISIBLE 0

#define GLOW_BRIGHTNESS_BASE_DEF 0.46
#define GLOW_BRIGHTNESS_POWER_DEF -1.6
#define GLOW_CONTRAST_BASE_DEF 1.0
#define GLOW_CONTRAST_POWER_DEF 0.25
#define EXPOSURE_BRIGHTNESS_BASE_DEF 0.2
#define EXPOSURE_BRIGHTNESS_POWER_DEF -0.2
#define EXPOSURE_CONTRAST_BASE_DEF 10
#define EXPOSURE_CONTRAST_POWER_DEF 0

#define LIGHTING_ANIMATE_TIME   1.5
