#define GLOW_NORMAL 0
#define GLOW_SLOW   1
#define GLOW_FAST   2

#define FLOORLIGHT_DAMAGE_THRESHOLD 100

#define FLOORLIGHT_SETTINGS list("rgb", "paste", "copy", "invert", "slow", "normal", "fast")
#define FLOORLIGHT_SETTINGS_COLORS list(PIPE_COLOR_GREY, PIPE_COLOR_GREY, PIPE_COLOR_RED, PIPE_COLOR_BLUE, PIPE_COLOR_CYAN, PIPE_COLOR_GREEN, PIPE_COLOR_YELLOW, PIPE_COLOR_BLACK, PIPE_COLOR_ORANGE)


/obj/machinery/floor_light
	name = "floor light"
	desc = "A backlit floor panel."

	icon = 'icons/obj/machines/floor_light.dmi'
	icon_state = "floorlight"

	layer = ABOVE_TILE_LAYER
	anchored = FALSE

	obj_flags = OBJ_FLAG_ANCHORABLE

	use_power = POWER_USE_ACTIVE
	idle_power_usage = 2 WATTS
	active_power_usage = 20 WATTS
	power_channel = STATIC_LIGHT

	matter = list(MATERIAL_STEEL = 250, MATERIAL_GLASS = 250)

	/// Whether object is turned on.
	var/on = FALSE
	/// Whether floor light's animation is inverted.
	var/inverted = FALSE
	/// Currently selected floor light mode, can be `GLOW_NORMAL`, `GLOW_SLOW`, `GLOW_FAST`.
	var/glow_mode = GLOW_NORMAL

	/// Amount of damage taken by the object. Varies between `0` and `FLOORLIGHT_DAMAGE_THRESHOLD`.
	var/damage = 0
	/// Damage icon key between `1` and `8`, `0` means no damage icon is chosen.
	var/damagekey = 0
	/// Object's light and panel color.
	var/colour = "#ffffff"

	/// Associative list of name -> image, where name contaied in `FLOORLIGHT_SETTINGS`.
	var/static/list/settings
	/// Associative list of color -> image, where color contained in `FLOORLIGHT_SETTINGS_COLORS`.
	var/static/list/colors


/obj/machinery/floor_light/prebuilt
	anchored = TRUE


/obj/machinery/floor_light/on_update_icon()
	ClearOverlays()

	if(damage > (FLOORLIGHT_DAMAGE_THRESHOLD * 0.2))
		AddOverlays(OVERLAY(icon, "floorlight_damage-[damagekey]"))

	var/should_glow = update_glow()
	if(should_glow)
		AddOverlays(OVERLAY(icon, "floorlight_over-[inverted][glow_mode]", color = colour))
		AddOverlays(emissive_appearance(icon, "floorlight_ea"))


/obj/machinery/floor_light/proc/update_glow()
	if(!on || stat & (BROKEN | NOPOWER))
		set_light(0)
		return FALSE

	set_light(0.75, 1, 3, 2, colour)
	return TRUE


/obj/machinery/floor_light/attackby(obj/item/W, mob/user)
	if(W.force && user.a_intent == I_HURT)
		take_damage(user, W.force)
		return
	else if(damage && isWelder(W))
		_repair_damage(user, W)
		return
	else if(isMultitool(W))
		_open_settings(user)
		return
	return ..()


/obj/machinery/floor_light/proc/_repair_damage(mob/user, obj/item/weldingtool/WT)
	if(istype(WT))
		return

	if(!WT.remove_fuel(0, user))
		to_chat(user, "\The [WT] must be on to complete this task.")
		return

	playsound(loc, 'sound/items/Welder.ogg', 50, 1)
	if(do_after(user, 20, src))
		if(!WT.isOn())
			return

		visible_message(SPAN("notice", "\The [user] has repaired \the [src]"))
		set_broken(FALSE)
		damagekey = 0
		damage = 0
		update_icon()


/obj/machinery/floor_light/proc/_open_settings(mob/user)
	if(!length(settings))
		_generate_buttons()

	var/choice = show_radial_menu(user, src, settings, require_near = TRUE)
	switch(choice)
		if("rgb")
			var/new_color = show_radial_menu(user, src, colors, require_near = TRUE)
			if(new_color)
				colour = new_color
				show_splash_text_to_viewers("color changed")
				update_icon()
		if("paste")
			var/obj/item/I = user.get_active_item()
			_paste_settigs(I)
			update_icon()
		if("copy")
			var/obj/item/device/multitool/MT = user.get_active_item()
			if(istype(MT))
				MT.set_buffer(src)
				show_splash_text(user, "settings copied")
		if("invert")
			inverted = !inverted
			show_splash_text_to_viewers("lights inverted")
			update_icon()
		if("slow")
			glow_mode = GLOW_SLOW
			update_icon()
		if("normal")
			glow_mode = GLOW_NORMAL
			update_icon()
		if("fast")
			glow_mode = GLOW_FAST
			update_icon()


/obj/machinery/floor_light/proc/_generate_buttons()
	LAZYINITLIST(colors)
	for(var/color as anything in FLOORLIGHT_SETTINGS_COLORS)
		var/image/I = image('icons/hud/radial.dmi', "radial_color")
		I.color = color
		colors[color] = I

	LAZYINITLIST(settings)
	for(var/option as anything in FLOORLIGHT_SETTINGS)
		settings[option] = image('icons/hud/radial.dmi', "radial_[option]")


/obj/machinery/floor_light/proc/_paste_settigs(obj/item/device/multitool/MT)
	if(!istype(MT))
		return

	var/obj/machinery/floor_light/FL = MT.get_buffer(/obj/machinery/floor_light)
	if(!FL)
		return

	colour = FL.colour
	inverted = FL.inverted
	glow_mode = FL.glow_mode
	show_splash_text_to_viewers("new settings applied.")


/obj/machinery/floor_light/attack_hand(mob/user)
	if(user.a_intent == I_HURT)
		take_damage(user, 0) // Good luck, bozo!
		return
	else
		toggle(user)
	return ..()


/obj/machinery/floor_light/proc/toggle(mob/user)
	if(!anchored)
		show_splash_text(user, "must be screwed down first!")
		return

	if(stat & BROKEN)
		show_splash_text(user, "too damaged to be used!")
		return

	on = !on
	update_icon()
	update_use_power(on ? POWER_USE_ACTIVE : POWER_USE_OFF)
	show_splash_text_to_viewers("turned [on ? "on" : "off"]")


/obj/machinery/floor_light/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(50))
				qdel(src)
			else
				take_damage(null, FLOORLIGHT_DAMAGE_THRESHOLD * 0.7)
		if(EXPLODE_LIGHT)
			if(prob(5))
				qdel(src)
			else
				take_damage(null, rand(0, FLOORLIGHT_DAMAGE_THRESHOLD * 0.4))


/obj/machinery/floor_light/proc/take_damage(mob/user, amount)
	damage = clamp(damage + amount, 0, FLOORLIGHT_DAMAGE_THRESHOLD)

	if(!damagekey)
		damagekey = rand(1, 8) // Pick a random damage overlay...
		update_icon()

	if(damage == FLOORLIGHT_DAMAGE_THRESHOLD)
		if(user)
			visible_message(SPAN("danger", "\The [user] smashes \the [src]!"))
		playsound(src, SFX_BREAK_WINDOW, 70, 1)
		set_broken(TRUE)
	else
		if(user)
			visible_message(SPAN("danger", "\The [user] attacks \the [src]!"))
		playsound(loc, GET_SFX(SFX_GLASS_HIT), 80, 1)


#undef FLOORLIGHT_SETTINGS
#undef FLOORLIGHT_SETTINGS_COLORS

#undef FLOORLIGHT_DAMAGE_THRESHOLD

#undef GLOW_FAST
#undef GLOW_SLOW
#undef GLOW_NORMAL
