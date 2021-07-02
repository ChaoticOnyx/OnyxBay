var/list/floor_light_cache = list()

/obj/machinery/floor_light
	name = "floor light"
	icon = 'icons/obj/machines/floor_light.dmi'
	icon_state = "base"
	desc = "A backlit floor panel."
	layer = STRUCTURE_LAYER
	anchored = 0
	use_power = POWER_USE_ACTIVE
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = EQUIP
	matter = list(MATERIAL_STEEL = 250, MATERIAL_GLASS = 250)

	var/glow
	var/on
	var/damaged
	var/default_light_max_bright = 0.75
	var/default_light_inner_range = 1
	var/default_light_outer_range = 3
	var/default_light_colour = "#CEffff"
	var/broken_light_colour = "#FFFFFF"
	var/light_colour

/obj/machinery/floor_light/prebuilt
	anchored = 1

/obj/machinery/floor_light/attackby(obj/item/W, mob/user)
	var/turf/T = src.loc
	if(isScrewdriver(W))
		if(!T.is_plating())
			to_chat(user, "You can only attach the [name] if the floor plating is removed.")
			return
		else
			anchored = !anchored
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
		damaged = null
	else if(W.force && user.a_intent == "hurt")
		attack_hand(user)
	return

/obj/machinery/floor_light/attack_hand(mob/user)
	if(user.a_intent == I_HURT && !issmall(user))
		if(!isnull(damaged) && !(stat & BROKEN))
			visible_message("<span class='danger'>\The [user] smashes \the [src]!</span>")
			playsound(src, "window_breaking", 70, 1)
			set_broken(TRUE)
		else
			visible_message("<span class='danger'>\The [user] attacks \the [src]!</span>")
			playsound(src.loc, get_sfx("glass_hit"), 75, 1)
			if(isnull(damaged)) damaged = 0
		return
	else
		on = !on
		to_chat(user, "<span class='notice'>You switch \the [src]  [on ? "on" : "off"].</span>")

		if(!anchored)
			to_chat(user, "<span class='warning'>\The [src] must be screwed down first.</span>")
			return
		if(stat & BROKEN)
			to_chat(user, "<span class='warning'>\The [src] is too damaged to be functional.</span>")
			return
		if(on && stat && NOPOWER)
			to_chat(user, "<span class='warning'>\The [src] is unpowered.</span>")
			return

/obj/machinery/floor_light/Process()
	..()
	if(((!anchored || broken()) && (glow)) || (use_power && !on))
		update_brightness(FALSE)
	else if(!glow && !use_power && on)
		update_brightness(TRUE)


/obj/machinery/floor_light/proc/update_brightness(var/mustWork)
	if(mustWork)
		if((light_outer_range != default_light_outer_range || light_max_bright != default_light_max_bright))
			if(broken())
				set_light(default_light_max_bright / (active_power_usage / idle_power_usage), default_light_inner_range, default_light_outer_range, 2, broken_light_colour)
				update_use_power(POWER_USE_IDLE)
			else
				set_light(default_light_max_bright, default_light_inner_range, default_light_outer_range, 2, default_light_colour)
				update_use_power(POWER_USE_ACTIVE)
			glow = 1
	else
		if(light_outer_range || light_max_bright)
			set_light(0)
			update_use_power(POWER_USE_OFF)
			glow = 0

	change_power_consumption((light_outer_range + light_max_bright) * 10, POWER_USE_ACTIVE)
	update_icon()

/obj/machinery/floor_light/update_icon()
	overlays.Cut()
	if(use_power && !broken())
		if(isnull(damaged))
			var/cache_key = "floorlight-[default_light_colour]"
			if(!floor_light_cache[cache_key])
				var/image/I = image("glowing")
				I.color = default_light_colour
				I.plane = plane
				I.layer = layer+0.001
				floor_light_cache[cache_key] = I
			overlays |= floor_light_cache[cache_key]
		else
			if(damaged == 0) //Needs init.
				damaged = rand(1,4)
			var/cache_key = "floorlight-broken[damaged]-[default_light_colour]"
			if(!floor_light_cache[cache_key])
				var/image/I = image("flicker[damaged]")
				I.color = default_light_colour
				I.plane = plane
				I.layer = layer+0.001
				floor_light_cache[cache_key] = I
			overlays |= floor_light_cache[cache_key]

/obj/machinery/floor_light/proc/broken()
	return (stat & (BROKEN|NOPOWER))

/obj/machinery/floor_light/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(50))
				qdel(src)
			else if(prob(20))
				set_broken(TRUE)
			else
				if(isnull(damaged))
					damaged = 0
		if(3)
			if (prob(5))
				qdel(src)
			else if(isnull(damaged))
				damaged = 0
	return

/obj/machinery/floor_light/Destroy()
	var/area/A = get_area(src)
	if(A)
		glow = 0
	. = ..()
