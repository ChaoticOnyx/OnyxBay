#define SPLASH_TEXT_WIDTH 200
#define SPLASH_TEXT_SPAWN_TIME (0.2 SECONDS)
#define SPLASH_TEXT_VISIBILITY_TIME (0.7 SECONDS)
#define SPLASH_TEXT_TOTAL_LIFETIME(mult) (SPLASH_TEXT_SPAWN_TIME + SPLASH_TEXT_VISIBILITY_TIME * mult)
/// The increase in duration per character in seconds.
#define SPLASH_TEXT_LIFETIME_PER_CHAR_MULT (0.05)
/// The amount of characters needed before this increase takes place.
#define SPLASH_TEXT_LIFETIME_INCREASE_MIN (10)

/// Creates text that will float from the atom upwards to the viewer.
/atom/proc/show_splash_text(mob/viewer, text)
	INVOKE_ASYNC(src, nameof(.proc/animate_splash_text), viewer, text)

/// Creates text that will float from the atom upwards to the viewers in range.
/atom/proc/show_splash_text_to_viewers(message, self_message, vision_distance = 7, list/mob/ignored_mobs)
	var/list/hearers = list()
	var/list/garbage_obj = list() // TO-DO: add more helpers to exclude searching objects.
	get_mobs_and_objs_in_view_fast(get_turf(src), vision_distance, hearers, garbage_obj)
	hearers -= ignored_mobs

	for(var/hearer in hearers)
		if(is_blind(hearer))
			continue
		show_splash_text(hearer, (hearer == src && self_message) || message)

/// Private proc, use 'show_splash_text' or 'show_splash_text_to_viewers' instead.
/atom/proc/animate_splash_text(mob/viewer, text)
	var/client/viewer_client = viewer?.client
	if(!viewer_client)
		return

	if(viewer_client.get_preference_value(/datum/client_preference/splashes) != GLOB.PREF_YES)
		return

	var/bounds_width = world.icon_size
	if(ismovable(src))
		var/atom/movable/M = src
		bounds_width = M.bound_width

	var/image/splash_image = image(loc = isturf(src) ? src : get_atom_on_turf(src), layer = SPLASH_TEXT_LAYER)
	splash_image.plane = EFFECTS_ABOVE_LIGHTING_PLANE
	splash_image.alpha = 0
	splash_image.appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM
	splash_image.maptext = MAPTEXT("<span style='text-align: center; -dm-text-outline: 1px #0005'>[text]</span>")
	splash_image.maptext_x = (SPLASH_TEXT_WIDTH - bounds_width) * (-0.5)
	splash_image.maptext_width = SPLASH_TEXT_WIDTH
	splash_image.maptext_height = WXH_TO_HEIGHT(viewer_client.MeasureText(text, null, SPLASH_TEXT_WIDTH))

	add_image_to_client(splash_image, viewer_client)

	var/lifetime_mult = 1 + max(0, length(strip_html_properly(text)) - SPLASH_TEXT_LIFETIME_INCREASE_MIN) * SPLASH_TEXT_LIFETIME_PER_CHAR_MULT

	animate(
		splash_image,
		pixel_y = world.icon_size * 1.2,
		time = SPLASH_TEXT_TOTAL_LIFETIME(lifetime_mult),
		easing = SINE_EASING
	)

	animate(
		alpha = 255,
		time = SPLASH_TEXT_SPAWN_TIME,
		easing = CUBIC_EASING | EASE_OUT,
		flags = ANIMATION_PARALLEL
	)

	animate(
		alpha = 0,
		time = SPLASH_TEXT_VISIBILITY_TIME * lifetime_mult,
		easing = CUBIC_EASING | EASE_IN
	)

	addtimer(CALLBACK(GLOBAL_PROC, /proc/remove_image_from_client, splash_image, viewer_client), SPLASH_TEXT_TOTAL_LIFETIME(lifetime_mult), TIMER_DELETE_ME)

#undef SPLASH_TEXT_WIDTH
#undef SPLASH_TEXT_SPAWN_TIME
#undef SPLASH_TEXT_VISIBILITY_TIME
#undef SPLASH_TEXT_TOTAL_LIFETIME
#undef SPLASH_TEXT_LIFETIME_PER_CHAR_MULT
#undef SPLASH_TEXT_LIFETIME_INCREASE_MIN
