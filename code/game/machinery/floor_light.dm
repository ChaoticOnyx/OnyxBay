var/list/floor_light_cache = list()

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

	var/glow = FALSE
	var/on = FALSE
	var/damaged = FALSE
	var/cracks = 0
	var/light_intensity = 1
	var/inverted = FALSE
	var/default_light_max_bright = 0.75
	var/default_light_inner_range = 1
	var/default_light_outer_range = 3
	var/default_light_colour = "#69baff"
	var/broken_light_colour = "#FFFFFF"
	var/light_colour = "#69baff"	// TODO: Add color input through multitool

/obj/machinery/floor_light/prebuilt
	anchored = TRUE
	on = TRUE

/obj/machinery/floor_light/Process()
	..()
	if(on && !glow && anchored)
		update_brightness(TRUE)
	else if((glow && !on) || (glow && (!anchored || broken())))
		update_brightness(FALSE)


/obj/machinery/floor_light/proc/levelupdate()
	for(var/obj/O in src)
		O.hide(O.hides_under_flooring() && src.anchored)
	if(anchored)
		layer = TURF_LAYER
	else
		layer = ABOVE_TILE_LAYER

/obj/machinery/floor_light/Destroy()
	var/area/A = get_area(src)
	if(A)
		glow = 0
	playsound(src, "electric_explosion", 70, 1)
	. = ..()

/obj/machinery/floor_light/attackby(obj/item/W, mob/user)
	var/turf/T = src.loc
	if(isScrewdriver(W))
		if(!T.is_plating())
			to_chat(user, "You can only attach the [name] if the floor plating is removed.")
			return
		else
			anchored = !anchored
			levelupdate()
			visible_message("<span class='notice'>\The [user] has [anchored ? "attached" : "detached"] \the [src].</span>")
	else if(isWelder(W) && (damaged || (stat & BROKEN)))
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.remove_fuel(0, user))
			to_chat(user, "<span class='warning'>\The [src] must be on to complete this task.</span>")
			return
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
		if(!do_after(user, 20, src))
			return
		if(!src || !WT.isOn())
			return
		visible_message("<span class='notice'>\The [user] has repaired \the [src].</span>")
		set_broken(FALSE)
		damaged = FALSE
		cracks = 0
	else if(isMultitool(W))
		switch(alert("What would you like to change?",, "Color", "intensity", "Invert", "Cancel"))
			if("Color")
				light_colour = input(user, "Choose your floor light's colour:") as color
				update_icon()
				glow = FALSE
				visible_message("<span class='notice'>\The [user] change \the [src] color.</span>")
				playsound(src.loc, "button", 50, 1)
				return
			if("intensity")
				switch(alert("Choose your floor light's intensity",, "slow", "normal", "fast"))
					if("slow")
						light_intensity = 0
						visible_message("<span class='notice'>\The [user] change \the [src] intensity to slow.</span>")
					if("normal")
						light_intensity = 1
						visible_message("<span class='notice'>\The [user] change \the [src] intensity to normal.</span>")
					if("fast")
						light_intensity = 2
						visible_message("<span class='notice'>\The [user] change \the [src] intensity to fast.</span>")
					else return
				update_icon()
				glow = FALSE
				playsound(src.loc, "button", 50, 1)
				return
			if("Invert")
				inverted = !inverted
				update_icon()
				glow = FALSE
				visible_message("<span class='notice'>\The [user] inverted \the [src] rhythm.</span>")
				playsound(src.loc, "button", 50, 1)
				return
			if("Cancel")
				return
	else if(W.force && user.a_intent == "hurt")
		attack_hand(user)
	return

/obj/machinery/floor_light/attack_hand(mob/user)
	if(user.a_intent == I_HURT && !issmall(user))
		if(damaged && !(stat & BROKEN))
			visible_message("<span class='danger'>\The [user] smashes \the [src]!</span>")
			playsound(src, "window_breaking", 70, 1)
			set_broken(TRUE)
		else
			visible_message("<span class='danger'>\The [user] attacks \the [src]!</span>")
			playsound(src.loc, get_sfx("glass_hit"), 75, 1)
		if(damaged < 3)
			damaged++
		else
			Destroy()
		update_icon()
		return
	else
		on = !on
		playsound(src, "switch_small", 75, 1)
		to_chat(user, "<span class='notice'>You switch \the [src]  [on ? "on" : "off"].</span>")
		if(on)
			if(stat && BROKEN)
				to_chat(user, "<span class='warning'>\The [src] is too damaged to glow.</span>")
				return
			if(!anchored)
				to_chat(user, "<span class='warning'>\The [src] must be screwed down to glow.</span>")
				return
			if(stat && NOPOWER)
				to_chat(user, "<span class='warning'>\The [src] is unpowered.</span>")
				return

/obj/machinery/floor_light/proc/update_brightness(var/mustWork)
	if(mustWork)
		if(broken())
			set_light(default_light_max_bright / (active_power_usage / idle_power_usage), default_light_inner_range, default_light_outer_range, 2, broken_light_colour)
			update_use_power(POWER_USE_IDLE)
		else
			set_light(default_light_max_bright, default_light_inner_range, default_light_outer_range, 2, light_colour)
			update_use_power(POWER_USE_ACTIVE)
		glow = 1
	else
		set_light(0)
		update_use_power(POWER_USE_OFF)
		glow = 0
	change_power_consumption((light_outer_range + light_max_bright) * 10, POWER_USE_ACTIVE)
	update_icon()

/obj/machinery/floor_light/update_icon()
	var/crack_layer = layer + 0.002
	if(damaged)
		var/i
		var/crack
		if(broken())
			while(cracks < damaged)
				crack = rand(1,8)
				var/cache_key = "floorlight-damaged[i]-crack[crack]"
				if(!floor_light_cache[cache_key])
					var/image/I = image("damaged[crack]")
					I.color = broken_light_colour
					I.plane = plane
					I.layer = crack_layer + 0.001
					crack_layer = I.layer
					floor_light_cache[cache_key] = I
				overlays |= floor_light_cache[cache_key]
				cracks++
	else overlays.Cut()
	if(use_power)
		if(!broken())
			if(!damaged)
				overlays -= floor_light_cache["floorlight-flickering"]
				overlays -= floor_light_cache["floorlight-glowing[light_intensity]"]
				var/cache_key = "floorlight-glowing[light_intensity]"
				//if(!floor_light_cache[cache_key])
				var/image/I
				switch(light_intensity)
					if(1)
						I = inverted ? image("glowing_invert") : image("glowing")
					if(0)
						I = inverted ? image("glowing_slow_invert") : image("glowing_slow")
					if(2)
						I = inverted ? image("glowing_fast_invert") : image("glowing_fast")
				I.color = light_colour
				I.plane = plane
				I.layer = layer + 0.001
				floor_light_cache[cache_key] = I
				overlays |= floor_light_cache[cache_key]
			else
				overlays -= floor_light_cache["floorlight-glowing[light_intensity]"]
				var/cache_key = "floorlight-flickering"
				if(!floor_light_cache[cache_key])
					var/image/I = image("flickering")
					I.color = light_colour
					I.plane = plane
					I.layer = layer + 0.001
					floor_light_cache[cache_key] = I
				overlays |= floor_light_cache[cache_key]
	else
		overlays -= floor_light_cache["floorlight-glowing[light_intensity]"]
		overlays -= floor_light_cache["floorlight-flickering"]

/obj/machinery/floor_light/proc/broken()
	return (stat & (BROKEN|NOPOWER))
