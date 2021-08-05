var/floor_light_cache = list()
var/floor_light_color_cache = list()

/obj/machinery/floor_light
	name = "floor light"
	icon = 'icons/obj/machines/floor_light.dmi'
	icon_state = "base"
	desc = "A backlit floor panel."
	layer = ABOVE_TILE_LAYER
	anchored = FALSE
	use_power = POWER_USE_ACTIVE
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = EQUIP
	matter = list(MATERIAL_STEEL = 250, MATERIAL_GLASS = 250)

	var/ID
	var/max_health = 40
	var/health	// Hits to destroy
	var/shield	// Hits to broke
	var/damaged = FALSE
	var/cracks = 0
	var/crack_layer

	var/light_layer
	var/glow = FALSE
	var/must_work
	var/on = FALSE
	var/light_intensity = 1
	var/inverted = FALSE
	var/default_light_max_bright = 0.75
	var/default_light_inner_range = 1
	var/default_light_outer_range = 3
	var/default_light_colour = "#69baff"
	var/broken_light_colour = "#FFFFFF"
	var/light_colour = "#69baff"

/obj/machinery/floor_light/New()
	health = max_health
	shield = max_health * 0.5
	. = ..()

/obj/machinery/floor_light/prebuilt
	anchored = TRUE
	on = TRUE
	levelupdate()

/obj/machinery/floor_light/Process()
	..()
	if(!glow && on && powered(power_channel) && anchored)	//Yes, the floor should blink when it is broken.
		must_work = TRUE
		update_brightness()
	else if((!powered(power_channel) || ((glow && !on) || (glow && (broken() || !anchored)))))
		must_work = FALSE
		update_brightness()

/obj/machinery/floor_light/proc/levelupdate()
	for(var/obj/O in src)
		O.hide(O.hides_under_flooring() && src.anchored)
	if(anchored)
		layer = TURF_LAYER
	else
		layer = ABOVE_TILE_LAYER
	return

/obj/machinery/floor_light/Destroy()
	var/area/A = get_area(src)
	if(A)
		glow = 0

	overlays -= floor_light_cache["floorlight[ID]-glowing"]
	overlays -= floor_light_cache["floorlight[ID]-flickering"]
	for(var/i = 1, i <= 8, i++)
		overlays -= floor_light_cache["floorlight[ID]-damaged[i]"]

	playsound(src, "electric_explosion", 70, 1)
	. = ..()

/obj/machinery/floor_light/attackby(obj/item/W, mob/user)
	var/turf/T = src.loc
	if(user.a_intent == I_HURT)
		user.setClickCooldown(W.update_attack_cooldown())
		user.do_attack_animation(src)
		if((W.damtype == BRUTE || W.damtype == BURN) && W.force >= 3)
			visible_message(SPAN("danger", "[src] has been hit by [user] with [W]. [W.force] damage"))
			hit(W.force, user)
		else
			visible_message(SPAN("danger", "[user] hits [src] with [W], but it bounces off!"))
			playsound(loc, get_sfx("glass_hit"), 75, 1)
		return

	if(isMultitool(W))
		if(!on)
			to_chat(user, SPAN("warning", "\The [src] needs to be switched on for the setup."))
			return
		if(broken())
			to_chat(user, SPAN("warning", "\The [src] needs to be repaired for the setup."))
			return
		switch(alert("What would you like to change?",, "Color", "Intensity", "Invert", "Cancel"))
			if("Color")
				light_colour = input(user, "Choose your floor light's color:") as color
				update_brightness()
				visible_message(SPAN("notice", "\The [user] change \the [src] color."))
				playsound(src.loc, "button", 50, 1)
				return
			if("Intensity")
				switch(alert("Choose your floor light's intensity",, "slow", "normal", "fast"))
					if("slow")
						light_intensity = 0
						visible_message(SPAN("notice", "\The [user] change \the [src] intensity to slow."))
					if("normal")
						light_intensity = 1
						visible_message(SPAN("notice", "\The [user] change \the [src] intensity to normal."))
					if("fast")
						light_intensity = 2
						visible_message(SPAN("notice", "\The [user] change \the [src] intensity to fast."))
					else return
				update_brightness()
				playsound(src.loc, "button", 50, 1)
				return
			if("Invert")
				inverted = !inverted
				update_brightness()
				visible_message(SPAN("notice", "\The [user] inverted \the [src] rhythm."))
				playsound(src.loc, "button", 50, 1)
				return
			if("Cancel")
				return
		return

	if(isWelder(W) && (damaged || (stat & BROKEN)))
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.remove_fuel(0, user))
			to_chat(user, SPAN("warning", "\The [src] must be on to complete this task."))
			return
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
		if(!do_after(user, 20, src))
			return
		if(!src || !WT.isOn())
			return
		visible_message(SPAN("notice", "\The [user] has repaired \the [src]."))
		set_broken(FALSE)
		damaged = FALSE
		health = max_health
		update_brightness()
		return

	if(isScrewdriver(W))
		if(!T.is_plating() || anchored)
			to_chat(user, "You can only attach the [name] if the floor plating is removed.")
			return
		else
			anchored = !anchored
			levelupdate()
			visible_message(SPAN("notice", "\The [user] has [anchored ? "attached" : "detached"] \the [src]."))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		return

/obj/machinery/floor_light/proc/hit(damage, mob/user)
	if((health - damage) <= 0)
		Destroy()
		return
	else
		user.visible_message("[user.name] hits the [src.name].", "You hit the [src.name].", "You hear the sound of hitting the [src.name].")
		playsound(loc, get_sfx("glass_hit"), 100, 1)
		if(health <= shield / 2)
			visible_message("[src] looks like it's about to shatter!")
			playsound(loc, get_sfx("sound/effects/glass_step.ogg"), 100, 1)
		else if(broken())
			visible_message("[src] looks seriously damaged!")
			playsound(loc, get_sfx("sound/effects/glass_step.ogg"), 50, 1)
		damaged++
		health -= damage
		update_brightness()

/obj/machinery/floor_light/attack_hand(mob/user)
	if(user.a_intent == I_HURT && !issmall(user))
		playsound(src.loc, get_sfx("glass_knock"), 80, 1)
		user.visible_message("[user.name] knocks on the [src.name].", "You knock on the [src.name].", "You hear a knocking sound.")
		return
	else
		on = !on
		playsound(src, "switch_small", 75, 1)
		to_chat(user, SPAN("notice", "You switch \the [src]  [on ? "on" : "off"]."))
		if(on)
			if(stat && BROKEN)
				to_chat(user, SPAN("warning", "\The [src] is too damaged to glow."))
				return
			if(!anchored)
				to_chat(user, SPAN("warning", "\The [src] must be screwed down to glow."))
				return
			if(stat && NOPOWER)
				to_chat(user, SPAN("warning", "\The [src] is unpowered."))
				return

/obj/machinery/floor_light/proc/update_brightness()
	ID = "\ref[src]"
	layers_check()
	if(must_work)
		if(broken())
			set_light(default_light_max_bright / 2, default_light_inner_range / 2, default_light_outer_range / 2, 2, broken_light_colour)
			update_use_power(POWER_USE_IDLE)
			change_power_consumption((light_outer_range + light_max_bright) * 10, POWER_USE_IDLE)
		else
			set_light(default_light_max_bright, default_light_inner_range, default_light_outer_range, 2, light_color_check(ID))
			update_use_power(POWER_USE_ACTIVE)
			change_power_consumption((light_outer_range + light_max_bright) * 10, POWER_USE_ACTIVE)
		glow = TRUE
	else
		set_light(0)
		update_use_power(POWER_USE_OFF)
		change_power_consumption(0, POWER_USE_OFF)
		glow = FALSE
	update_icon(ID)
	light_colour = null
	return

/obj/machinery/floor_light/update_icon(ID)
	if(broken())
		var/crack
		while(cracks < damaged)
			crack = rand(1,8)
			var/cache_key = "floorlight[ID]-damaged[crack]"
			var/image/I = image("damaged[crack]")
			update_light_cache(ID, cache_key, I, crack_layer)
			cracks++
	else overlays.Cut()
	if(glow)
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
			update_light_cache(ID, cache_key, I, light_layer)

/obj/machinery/floor_light/proc/update_light_cache(ID, cache_key, image/I, _layer)
	I.color = broken() ? broken_light_colour : light_color_check(ID)
	I.plane = plane
	I.layer = _layer
	floor_light_cache[cache_key] = I
	floor_light_color_cache[cache_key] = I.color
	overlays |= floor_light_cache[cache_key]
	return

/obj/machinery/floor_light/proc/broken()
	if(health <= shield)
		return TRUE
	return FALSE

/obj/machinery/floor_light/proc/light_color_check(ID)
	if(isnull(light_colour))
		if(floor_light_cache["floorlight[ID]-glowing"] && !broken())
			return floor_light_color_cache["floorlight[ID]-glowing"]
		if(floor_light_cache["floorlight[ID]-flickering"])
			return floor_light_color_cache["floorlight[ID]-flickering"]
		return default_light_colour
	return light_colour

/obj/machinery/floor_light/proc/layers_check()
	light_layer = layer + 0.001
	crack_layer = layer + 0.002
	return
