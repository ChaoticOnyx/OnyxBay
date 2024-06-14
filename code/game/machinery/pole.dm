/obj/machinery/pole
	name = "pole"
	desc = "A pole fastened to the ceiling and floor."
	icon = 'icons/obj/pole.dmi'
	icon_state = "pole_purle_off"
	base_icon_state = "pole"
	density = TRUE
	anchored = TRUE
	layer = 3
	power_channel = STATIC_EQUIP
	use_power = POWER_USE_OFF
	idle_power_usage = 2 WATTS
	active_power_usage = 100 WATTS
	light_color = COLOR_LIGHT_PINK
	obj_flags = OBJ_FLAG_ANCHORABLE
	component_types = list(/obj/item/circuitboard/pole)
	/// Are the animated lights enabled?
	var/lights_enabled = FALSE
	/// The mob currently using the pole to dance
	var/weakref/dancer = null
	/// The selected pole color
	var/current_pole_color = "purple"
	/// Possible designs for the pole, populating a radial selection menu
	var/static/list/pole_designs
	/// Possible colors for the pole
	var/static/list/pole_lights = list(
		"purple" = COLOR_PINK,
		"cyan" = COLOR_CYAN,
		"red" = COLOR_RED,
		"green" = COLOR_GREEN,
		"white" = COLOR_WHITE,
	)
	/// Is the pole in use currently?
	var/pole_in_use
	var/pseudo_z_axis = 9 //stepping onto the pole makes you raise upwards!
	var/static/image/ea_overlay = image(icon = 'icons/obj/pole.dmi', icon_state = "pole_ea")

/obj/machinery/pole/Initialize(mapload)
	. = ..()
	update_icon()
	if(!length(pole_designs))
		populate_pole_designs()

/obj/machinery/pole/examine(mob/user, infix)
	. = ..()
	. += "The lights are currently <b>[lights_enabled ? "ON" : "OFF"]</b> and could be [lights_enabled ? "dis" : "en"]abled with <b>Alt-Click</b>."

/obj/machinery/pole/attackby(obj/item/attack_item, mob/living/user, params)
	if(default_deconstruction_screwdriver(user, attack_item))
		return

	if(default_deconstruction_crowbar(user, attack_item))
		return

	return ..()

/// The list of possible designs generated for the radial reskinning menu
/obj/machinery/pole/proc/populate_pole_designs()
	pole_designs = list(
		"purple" = image(icon = icon, icon_state = "pole_purple_on"),
		"cyan" = image(icon = icon, icon_state = "pole_cyan_on"),
		"red" = image(icon = icon, icon_state = "pole_red_on"),
		"green" = image(icon = icon, icon_state = "pole_green_on"),
		"white" = image(icon = icon, icon_state = "pole_white_on"),
	)

/obj/machinery/pole/CtrlClick(mob/user)
	. = ..()
	if(. == FALSE)
		return FALSE

	var/choice = show_radial_menu(user, src, pole_designs, radius = 50, require_near = TRUE)
	if(!choice)
		return FALSE

	current_pole_color = choice
	light_color = pole_lights[choice]
	update_icon()
	return TRUE

// Alt-click to turn the lights on or off.
/obj/machinery/pole/AltClick(mob/user)
	lights_enabled = !lights_enabled
	show_splash_text(user, "lights [lights_enabled ? "on" : "off"]")
	playsound(user, pick('sound/machines/switch1.ogg', 'sound/machines/switch2.ogg', 'sound/machines/switch3.ogg', 'sound/machines/switch3.ogg'), 40, TRUE)
	update_icon()

/obj/machinery/pole/on_update_icon()
	CutOverlays(ea_overlay)

	var/should_glow = update_glow()
	if(should_glow)
		AddOverlays(emissive_appearance(ea_overlay))

	if(inoperable(MAINT) || !lights_enabled)
		icon_state = "[base_icon_state]_[current_pole_color]_off"
	else
		icon_state = "[base_icon_state]_[current_pole_color]_on"

/obj/machinery/pole/proc/update_glow()
	set_light(0)
	if(inoperable(MAINT) || !lights_enabled)
		return FALSE

	set_light(1, 1, 2, 3.5, light_color)
	return TRUE

//trigger dance if character uses LBM
/obj/machinery/pole/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(pole_in_use)
		show_splash_text(user, "already in use!")
		return

	pole_in_use = TRUE
	dancer = weakref(user)
	user.set_dir(SOUTH)
	user.Stun(10 SECONDS)
	user.forceMove(loc)
	user.visible_message(pick(SPAN_WARNING("[user] dances on [src]!"), SPAN_WARNING("[user] flexes their hip-moving skills on [src]!")))
	dance_animate(user)
	pole_in_use = FALSE
	user.pixel_y = 0
	user.pixel_z = 0
	dancer = null

/// The proc used to make the user 'dance' on the pole. Basically just consists of pixel shifting them around a bunch and sleeping. Could probably be improved a lot.
/obj/machinery/pole/proc/dance_animate(mob/living/user)
	if(user.loc != src.loc)
		return
	if(!QDELETED(src))
		animate(user, pixel_x = -6, pixel_y = 0, time = 1 SECONDS)
		sleep(2 SECONDS)
		user.dir = 4
	if(!QDELETED(src))
		animate(user, pixel_x = -6, pixel_y = 24, time = 1 SECONDS)
		sleep(1.2 SECONDS)
		layer = ABOVE_HUMAN_LAYER
	if(!QDELETED(src))
		animate(user, pixel_x = 6, pixel_y = 12, time = 0.5 SECONDS)
		user.dir = 8
		sleep(0.6 SECONDS)
	if(!QDELETED(src))
		animate(user, pixel_x = -6, pixel_y = 4, time = 0.5 SECONDS)
		user.dir = 4
		layer = initial(layer)
		sleep(0.6 SECONDS)
	if(!QDELETED(src))
		user.dir = 1
		animate(user, pixel_x = 0, pixel_y = 0, time = 0.3 SECONDS)
		sleep(0.6 SECONDS)
	if(!QDELETED(src))
		var/amplitude = 2
		var/pixel_x_diff = rand(-amplitude, amplitude)
		var/pixel_y_diff = rand(-amplitude / 3, amplitude / 3)
		animate(src, pixel_x = pixel_x_diff, pixel_y = pixel_y_diff , time = 0.2 SECONDS, loop = 6, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
		animate(pixel_x = -pixel_x_diff , pixel_y = -pixel_y_diff , time = 0.2 SECONDS, flags = ANIMATION_RELATIVE)
		sleep(0.6 SECONDS)
		user.dir = 2

/obj/machinery/pole/Destroy()
	. = ..()
	var/mob/living/L = dancer?.resolve()
	if(L)
		L.SetStunned(0)
		L.pixel_y = 0
		L.pixel_x = 0
		L.pixel_z = pseudo_z_axis
	dancer = null
