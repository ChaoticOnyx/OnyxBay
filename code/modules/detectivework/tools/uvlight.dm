/obj/item/device/uv_light
	name = "\improper UV light"
	desc = "A small handheld black light."
	icon_state = "uv_off"
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL
	item_state = "electronic"
	action_button_name = "Toggle UV light"
	matter = list(MATERIAL_STEEL = 150)
	origin_tech = list(TECH_MAGNET = 1, TECH_ENGINEERING = 1)

	var/list/scanned = list()
	var/list/stored_alpha = list()
	var/list/reset_objects = list()

	var/range = 3
	var/on = 0
	var/step_alpha = 50

/obj/item/device/uv_light/attack_self(mob/user)
	on = !on
	if(on)
		set_light(0.5, 0.1, range, 2, "#007fff")
		set_next_think(world.time)
		icon_state = "uv_on"
	else
		set_light(0)
		clear_last_scan()
		set_next_think(0)
		icon_state = "uv_off"

/obj/item/device/uv_light/proc/clear_last_scan()
	if(scanned.len)
		for(var/atom/O in scanned)
			O.set_invisibility(scanned[O])
			if(O.fluorescent == 2)
				O.fluorescent = 1
		scanned.Cut()
	if(stored_alpha.len)
		for(var/atom/O in stored_alpha)
			O.alpha = stored_alpha[O]
			if(O.fluorescent == 2)
				O.fluorescent = 1
		stored_alpha.Cut()
	if(reset_objects.len)
		for(var/obj/item/I in reset_objects)
			var/saved_fluorescent = I.fluorescent
			if(I.blood_color == COLOR_LUMINOL)
				I.clean_blood()
			if(saved_fluorescent == 2)
				I.fluorescent = 1
		reset_objects.Cut()

/obj/item/device/uv_light/think()
	clear_last_scan()
	step_alpha = round(255/range)
	var/turf/origin = get_turf(src)
	if(!origin)
		return
	for(var/turf/T in range(range, origin))
		var/use_alpha = 255 - (step_alpha * get_dist(origin, T))
		for(var/atom/A in T.contents)
			if(A.fluorescent == 1)
				A.fluorescent = 2 //To prevent light crosstalk.
				if(A.invisibility)
					scanned[A] = A.invisibility
					A.set_invisibility(0)
					stored_alpha[A] = A.alpha
					A.alpha = use_alpha
				if(istype(A, /obj/item))
					var/obj/item/O = A
					if(O.was_bloodied && !O.is_bloodied)
						O.add_blood(COLOR_LUMINOL)
						reset_objects |= O

	set_next_think(world.time + 1 SECOND)
