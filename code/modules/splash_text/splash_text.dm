#define SPLASH_TEXT_WIDTH 200
#define SPLASH_TEXT_SPAWN_TIME (0.2 SECONDS)
#define SPLASH_TEXT_VISIBILITY_TIME (0.7 SECONDS)
#define SPLASH_TEXT_TOTAL_LIFETIME(mult) (SPLASH_TEXT_SPAWN_TIME + SPLASH_TEXT_VISIBILITY_TIME * mult)
/// The increase in duration per character in seconds.
#define SPLASH_TEXT_LIFETIME_PER_CHAR_MULT (0.05)
/// The amount of characters needed before this increase takes place.
#define SPLASH_TEXT_LIFETIME_INCREASE_MIN (10)

/// Creates text that will float from the atom upwards to the viewer.
/atom/proc/show_splash_text(mob/viewer, text, chat_text, force_skip_chat = FALSE)
	INVOKE_ASYNC(src, nameof(.proc/animate_splash_text), viewer, text, chat_text)

/// Creates text that will float from the atom upwards to the viewers in range.
/atom/proc/show_splash_text_to_viewers(message, self_message, vision_distance = 7, list/mob/ignored_mobs)
	var/list/hearers = get_hearers_in_view(vision_distance, src)

/atom/proc/show_splash_text_to_viewers(message, self_message, vision_distance = 7, list/mob/ignored_mobs, force_skip_chat = FALSE)
	var/list/hearers = list()
	var/list/garbage_obj = list() // TO-DO: add more helpers to exclude searching objects.
	get_mobs_and_objs_in_view_fast(get_turf(src), vision_distance, hearers, garbage_obj)
	hearers -= ignored_mobs

	for(var/hearer in hearers)
		if(is_blind(hearer))
			continue
		var/res_message = message
		if(hearer == src && self_message)
			res_message = self_message
		show_splash_text(hearer, res_message, res_message, force_skip_chat)

/// Private proc, use 'show_splash_text' or 'show_splash_text_to_viewers' instead.
/atom/proc/animate_splash_text(mob/viewer, text, chat_text, force_skip_chat)
	var/client/viewer_client = viewer?.client
	if(!viewer_client)
		return

	var/pref_value = viewer_client.get_preference_value(/datum/client_preference/splashes)

	if(pref_value != GLOB.PREF_SPLASH_MAPTEXT && !force_skip_chat)
		if(!chat_text)
			// Ugly, but still better than skipping the message completely
			chat_text = "\icon[src] [text]"
		to_chat(viewer, chat_text)

	// Chat only, no need to draw maptexties
	if(pref_value == GLOB.PREF_SPLASH_CHAT)
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

	var/lifetime_mult = 1 + max(0, length(strip_html_properly(text)) - SPLASH_TEXT_LIFETIME_INCREASE_MIN) * SPLASH_TEXT_LIFETIME_PER_CHAR_MULT

	flick_overlay(splash_image, viewer_client, SPLASH_TEXT_TOTAL_LIFETIME(lifetime_mult))

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

#undef SPLASH_TEXT_WIDTH
#undef SPLASH_TEXT_SPAWN_TIME
#undef SPLASH_TEXT_VISIBILITY_TIME
#undef SPLASH_TEXT_TOTAL_LIFETIME
#undef SPLASH_TEXT_LIFETIME_PER_CHAR_MULT
#undef SPLASH_TEXT_LIFETIME_INCREASE_MIN
