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
	var/hp = 9	// Hits to destroy
	var/shield = 3	// Hits to broke
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

/obj/machinery/floor_light/prebuilt
	anchored = TRUE
	on = TRUE
	levelupdate()

/obj/machinery/floor_light/Process()
	..()
	if(on && !glow && anchored)
		must_work = TRUE
		update_brightness()
	else if((glow && !on) || (glow && (!anchored || broken())))
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
	if(isScrewdriver(W))
		if(!T.is_plating() || anchored)
			to_chat(user, "You can only attach the [name] if the floor plating is removed.")
			return
		else
			anchored = !anchored
			levelupdate()
			visible_message(SPAN("notice", "\The [user] has [anchored ? "attached" : "detached"] \the [src]."))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
	else if(isWelder(W) && (damaged || (stat & BROKEN)))
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
	else if(isMultitool(W))
		if(!on)
			to_chat(user, SPAN("warning", "\The [src] needs to be switched on for the setup."))
			return
		if(damaged)
			to_chat(user, SPAN("warning", "\The [src] needs to be repaired for the setup."))
			return
		switch(alert("What would you like to change?",, "color", "intensity", "invert", "Cancel"))
			if("Color")
				light_colour = input(user, "Choose your floor light's color:") as color
				update_brightness()
				glow = FALSE
				visible_message(SPAN("notice", "\The [user] change \the [src] color."))
				playsound(src.loc, "button", 50, 1)
				return
			if("intensity")
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
				glow = FALSE
				playsound(src.loc, "button", 50, 1)
				return
			if("Invert")
				inverted = !inverted
				update_brightness()
				glow = FALSE
				visible_message(SPAN("notice", "\The [user] inverted \the [src] rhythm."))
				playsound(src.loc, "button", 50, 1)
				return
			if("Cancel")
				return
	else if(W.force && user.a_intent == "hurt")
		attack_hand(user)

/obj/machinery/floor_light/attack_hand(mob/user)
	if(user.a_intent == I_HURT && !issmall(user))
		if(damaged >= shield && !(stat & BROKEN))
			visible_message(SPAN("danger", "\The [user] smashes \the [src]!"))
			playsound(src, "window_breaking", 70, 1)
			set_broken(TRUE)
		else
			visible_message(SPAN("danger", "\The [user] attacks \the [src]!"))
			playsound(src.loc, get_sfx("glass_hit"), 75, 1)
		if(damaged < hp)
			damaged++
		else
			Destroy()
		update_brightness()
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
			set_light(default_light_max_bright / (active_power_usage / idle_power_usage), default_light_inner_range, default_light_outer_range, 2, broken_light_colour)
			update_use_power(POWER_USE_IDLE)
			change_power_consumption((light_outer_range + light_max_bright) * 10, POWER_USE_IDLE)
		else
			set_light(default_light_max_bright, default_light_inner_range, default_light_outer_range, 2, light_color_check(ID))
			update_use_power(POWER_USE_ACTIVE)
			change_power_consumption((light_outer_range + light_max_bright) * 10, POWER_USE_ACTIVE)
		glow = 1
	else
		set_light(0)
		update_use_power(POWER_USE_OFF)
		change_power_consumption(0, POWER_USE_OFF)
		glow = 0
	update_icon(ID)
	light_colour = null
	return

/obj/machinery/floor_light/update_icon(ID)
	if(damaged)
		var/crack
		if(broken())
			while(cracks < damaged)
				crack = rand(1,8)
				var/cache_key = "floorlight[ID]-damaged[crack]"
				var/image/I = image("damaged[crack]")
				update_light_cache(ID, cache_key, I, crack_layer)
				cracks++
	else overlays.Cut()
	if(use_power)
		if(!broken())
			if(!damaged)
				overlays -= floor_light_cache["floorlight[ID]-flickering"]
				overlays -= floor_light_color_cache["floorlight[ID]-flickering"]
				var/cache_key = "floorlight[ID]-glowing"
				var/image/I
				switch(light_intensity)
					if(1)
						I = inverted ? image("glowing_invert") : image("glowing")
					if(0)
						I = inverted ? image("glowing_slow_invert") : image("glowing_slow")
					if(2)
						I = inverted ? image("glowing_fast_invert") : image("glowing_fast")
				update_light_cache(ID, cache_key, I, light_layer)
			else
				overlays -= floor_light_cache["floorlight[ID]-glowing"]
				overlays -= floor_light_color_cache["floorlight[ID]-glowing"]
				var/cache_key = "floorlight[ID]-flickering"
				var/image/I = image("flickering")
				update_light_cache(ID, cache_key, I, light_layer)
	else
		overlays -= floor_light_cache["floorlight[ID]-glowing"]
		overlays -= floor_light_cache["floorlight[ID]-flickering"]
		overlays -= floor_light_color_cache["floorlight[ID]-glowing"]
		overlays -= floor_light_color_cache["floorlight[ID]-flickering"]

/obj/machinery/floor_light/proc/update_light_cache(ID, cache_key, image/I, _layer)
	I.color = broken() ? broken_light_colour : light_color_check(ID)
	I.plane = plane
	I.layer = _layer
	floor_light_cache[cache_key] = I
	floor_light_color_cache[cache_key] = I.color
	overlays |= floor_light_cache[cache_key]
	return

/obj/machinery/floor_light/proc/broken()
	return (stat & (BROKEN|NOPOWER))

/obj/machinery/floor_light/proc/light_color_check(ID)
	if(isnull(light_colour))
		if(floor_light_cache["floorlight[ID]-glowing"] && !damaged)
			return floor_light_color_cache["floorlight[ID]-glowing"]
		if(floor_light_cache["floorlight[ID]-flickering"])
			return floor_light_color_cache["floorlight[ID]-flickering"]
		return default_light_colour
	return light_colour

/obj/machinery/floor_light/proc/layers_check()
	light_layer = layer + 0.001
	crack_layer = layer + 0.002
	return
