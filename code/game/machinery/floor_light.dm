var/static/list/floor_light_cache = list()
var/static/list/floor_light_color_cache = list()

/obj/machinery/floor_light
	name = "floor light"
	icon = 'icons/obj/machines/floor_light.dmi'
	icon_state = "base"
	desc = "A backlit floor panel."
	layer = TURF_LAYER
	anchored = FALSE
	use_power = POWER_USE_ACTIVE
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = STATIC_EQUIP
	matter = list(MATERIAL_STEEL = 250, MATERIAL_GLASS = 250)

	#define FLOOR_LIGHT_MAX_HEALTH 60
	#define FLOOR_LIGHT_SHIELD FLOOR_LIGHT_MAX_HEALTH * 0.6	// Hits to broke
	#define FLOOR_LIGHT_CRACK_LAYER DECAL_LAYER
	var/ID
	var/health = FLOOR_LIGHT_MAX_HEALTH	// Hits to destroy
	var/damaged = FALSE
	var/cracks = 0

	#define FLOOR_LIGHT_DEFAULT_LIGHT_MAX_BRIGHT 0.75
	#define FLOOR_LIGHT_DEFAULT_LIGHT_INNER_RANGE 1
	#define FLOOR_LIGHT_DEFAULT_LIGHT_OUTER_RANGE 3
	#define FLOOR_LIGHT_DEFAULT_LIGHT_COLOUR "#69baff"
	#define FLOOR_LIGHT_BROKEN_LIGHT_COLOUR "#FFFFFF"
	#define FLOOR_LIGHT_LIGHT_LAYER DECAL_LAYER
	var/must_work = FALSE
	var/on = FALSE
	var/light_intensity = 1
	var/inverted = FALSE
	var/light_colour = "#69baff"

	var/static/radial_color_input = image(icon = 'icons/mob/radial.dmi', icon_state = "color_input")
	var/static/radial_intensity = image(icon = 'icons/mob/radial.dmi', icon_state = "intensity")
	var/static/radial_intensity_slow = image(icon = 'icons/mob/radial.dmi', icon_state = "intensity_slow")
	var/static/radial_intensity_normal = image(icon = 'icons/mob/radial.dmi', icon_state = "intensity_normal")
	var/static/radial_intensity_fast = image(icon = 'icons/mob/radial.dmi', icon_state = "intensity_fast")
	var/static/radial_invert = image(icon = 'icons/mob/radial.dmi', icon_state = "invert")

	// we show the button even if the proc will not work
	var/static/list/settings_options = list("Color" = radial_color_input, "Intensity" = radial_intensity, "Invert" = radial_invert)
	var/static/list/ai_settings_options = list("Color" = radial_color_input, "Intensity" = radial_intensity, "Invert" = radial_invert)
	var/static/list/intensity_options = list("slow" = radial_intensity_slow, "normal" = radial_intensity_normal, "fast" = radial_intensity_fast)
	var/static/list/ai_intensity_options = list("slow" = radial_intensity_slow, "normal" = radial_intensity_normal, "fast" = radial_intensity_fast)

/obj/machinery/floor_light/prebuilt
	anchored = TRUE
	on = TRUE
	levelupdate()

/obj/machinery/floor_light/Process()
	..()
	if(powered(power_channel) && anchored)
		if(broken())
			if(must_work)
				must_work = FALSE
				update_brightness()
			else if(prob(on ? 30 : 15))
				flicker()
		else if(must_work != on)
			must_work = on
			update_brightness()
	else if(must_work)
		must_work = FALSE
		update_brightness()

/obj/machinery/floor_light/proc/levelupdate()
	layer = anchored ? TURF_LAYER : TURF_DETAIL_LAYER
	return

/obj/machinery/floor_light/attackby(obj/item/W, mob/user)
	var/turf/T = src.loc
	if(user.a_intent == I_HURT)
		user.setClickCooldown(W.update_attack_cooldown())
		user.do_attack_animation(src)
		if((W.damtype == BRUTE || W.damtype == BURN) && W.force >= 5)
			visible_message(SPAN("danger", "[src] has been hit by [user] with [W]."))
			hit(W.force, user)
		else
			visible_message(SPAN("danger", "[user] hits [src] with [W], but it bounces off!"))
			playsound(loc, GET_SFX(SFX_GLASS_HIT), 75, 1)
		return

	if(isMultitool(W))
		if(!on)
			to_chat(user, SPAN("warning", "\The [src] needs to be switched on for the setup."))
			return
		if(broken())
			to_chat(user, SPAN("warning", "\The [src] needs to be repaired for the setup."))
			return
		playsound(src.loc, 'sound/effects/using/console/press2.ogg', 50, 1)

		var/settings_choice = show_radial_menu(user, src, isAI(user) ? ai_settings_options : settings_options, require_near = !issilicon(user))
		switch(settings_choice)
			if("Color")
				light_colour = input(user, "Choose your floor light's color:") as color
				visible_message(SPAN("notice", "\The [user] change \the [src] color."))
			if("Intensity")
				playsound(src.loc, 'sound/effects/using/console/press2.ogg', 50, 1)
				var/intensity_choice = show_radial_menu(user, src, isAI(user) ? ai_intensity_options : intensity_options, require_near = !issilicon(user))
				switch(intensity_choice)
					if("slow")
						light_intensity = 0
						visible_message(SPAN("notice", "\The [user] change \the [src] intensity to slow."))
					if("normal")
						light_intensity = 1
						visible_message(SPAN("notice", "\The [user] change \the [src] intensity to normal."))
					if("fast")
						light_intensity = 2
						visible_message(SPAN("notice", "\The [user] change \the [src] intensity to fast."))
					else
						return
			if("Invert")
				inverted = !inverted
				visible_message(SPAN("notice", "\The [user] inverted \the [src] rhythm."))
			else
				return
		playsound(src.loc, 'sound/effects/using/console/press2.ogg', 50, 1)
		update_brightness()

	if(isWelder(W) && damaged)
		var/obj/item/weldingtool/WT = W
		if(!WT.remove_fuel(cracks, user))
			to_chat(user, SPAN("warning", "\The [WT.name] must be on and have at least [cracks] units of fuel to complete this task."))
			return
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
		if(!do_after(user, 20, src))
			return
		if(!src || !WT.isOn())
			return
		visible_message(SPAN("notice", "\The [user] has repaired \the [src]."))
		set_broken(FALSE)
		damaged = FALSE
		health = FLOOR_LIGHT_MAX_HEALTH
		update_brightness()
		return

	if(isScrewdriver(W))
		if(!T.is_plating() && !anchored)
			to_chat(user, "You can only attach the [name] if the floor plating is removed.")
		else
			anchored = !anchored
			levelupdate()
			visible_message(SPAN("notice", "\The [user] has [anchored ? "attached" : "detached"] \the [src]."))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)

/obj/machinery/floor_light/proc/hit(damage, mob/user)
	user.visible_message("[user.name] hits the [src.name].", "You hit the [src.name].", "You hear the sound of hitting the [src.name].")
	playsound(loc, GET_SFX(SFX_GLASS_HIT), 100, 1)
	if(broken())
		visible_message("[src] looks seriously damaged!")

	damaged++
	if((health - damage) <= 0)
		return
	health -= damage
	update_brightness()

/obj/machinery/floor_light/attack_hand(mob/user)
	if(user.a_intent == I_HURT && !issmall(user))
		playsound(src.loc, GET_SFX(SFX_GLASS_KNOCK), 80, 1)
		user.visible_message("[user.name] knocks on the [src.name].", "You knock on the [src.name].", "You hear a knocking sound.")
		return
	else
		on = !on
		playsound(src, GET_SFX(SFX_USE_SMALL_SWITCH), 75, 1)
		to_chat(user, SPAN("notice", "You switch \the [src]  [on ? "on" : "off"]."))
		if(on)
			if(broken())
				to_chat(user, SPAN("warning", "\The [src] is too damaged to glow."))
			if(!anchored)
				to_chat(user, SPAN("warning", "\The [src] must be screwed down to glow."))
			if(stat == 2)
				to_chat(user, SPAN("warning", "\The [src] is unpowered."))

/obj/machinery/floor_light/proc/update_brightness()
	ID = "\ref[src]"
	if(must_work)
		if(broken())
			set_light(FLOOR_LIGHT_DEFAULT_LIGHT_MAX_BRIGHT / 2, FLOOR_LIGHT_DEFAULT_LIGHT_INNER_RANGE / 2, FLOOR_LIGHT_DEFAULT_LIGHT_OUTER_RANGE / 2, 2, FLOOR_LIGHT_BROKEN_LIGHT_COLOUR)
			update_use_power(POWER_USE_IDLE)
			change_power_consumption((light_outer_range + light_max_bright) * 10, POWER_USE_IDLE)
		else
			set_light(FLOOR_LIGHT_DEFAULT_LIGHT_MAX_BRIGHT, FLOOR_LIGHT_DEFAULT_LIGHT_INNER_RANGE, FLOOR_LIGHT_DEFAULT_LIGHT_OUTER_RANGE, 2, light_color_check(ID))
			update_use_power(POWER_USE_ACTIVE)
			change_power_consumption((light_outer_range + light_max_bright) * 10, POWER_USE_ACTIVE)
	else
		set_light(0)
		update_use_power(POWER_USE_OFF)
		change_power_consumption(0, POWER_USE_OFF)
	update_icon(ID)
	light_colour = null

/obj/machinery/floor_light/update_icon(ID)
	if(broken())
		var/crack
		while(cracks < damaged)
			crack = rand(1,8)
			var/cache_key = "floorlight[ID]-damaged[crack]"
			var/image/I = image("damaged[crack]")
			playsound(loc, "sound/effects/glass_step.ogg", 100, 1)
			update_light_cache(ID, cache_key, I, FLOOR_LIGHT_CRACK_LAYER)
			cracks++
	else overlays.Cut()
	if(must_work)
		overlays -= floor_light_cache["floorlight[ID]-glowing"]
		overlays -= floor_light_color_cache["floorlight[ID]-glowing"]
		if(!broken())
			var/image/I
			var/cache_key = "floorlight[ID]-glowing"
			switch(light_intensity)
				if(1)
					I = inverted ? image("glowing_invert") : image("glowing")
				if(0)
					I = inverted ? image("glowing_slow_invert") : image("glowing_slow")
				if(2)
					I = inverted ? image("glowing_fast_invert") : image("glowing_fast")
			update_light_cache(ID, cache_key, I, FLOOR_LIGHT_LIGHT_LAYER)

/obj/machinery/floor_light/proc/update_light_cache(ID, cache_key, image/I, _layer)
	I.color = broken() ? FLOOR_LIGHT_BROKEN_LIGHT_COLOUR : light_color_check(ID)
	I.plane = plane
	I.layer = _layer
	floor_light_cache[cache_key] = I
	floor_light_color_cache[cache_key] = I.color
	overlays |= floor_light_cache[cache_key]

/obj/machinery/floor_light/proc/flicker()
	do
		must_work = TRUE
		update_brightness()
		sleep(rand(1, 10))
		must_work = FALSE
		update_brightness()
		sleep(rand(1, 5))
	while(prob(50))

/obj/machinery/floor_light/proc/broken()
	return health < FLOOR_LIGHT_SHIELD

/obj/machinery/floor_light/proc/light_color_check(ID)
	if(isnull(light_colour))
		if(floor_light_cache["floorlight[ID]-glowing"] && !broken())
			return floor_light_color_cache["floorlight[ID]-glowing"]
		if(floor_light_cache["floorlight[ID]-flickering"])
			return floor_light_color_cache["floorlight[ID]-flickering"]
		return FLOOR_LIGHT_DEFAULT_LIGHT_COLOUR
	return light_colour
