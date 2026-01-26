#define HOLD_CASINGS	0 //do not do anything after firing. Manual action, like pump shotguns, or guns that want to define custom behaviour
#define CLEAR_CASINGS	1 //clear chambered so that the next round will be automatically loaded and fired, but don't drop anything on the floor
#define EJECT_CASINGS	2 //drop spent casings on the ground after firing
#define CYCLE_CASINGS	3 //cycle casings, like a revolver. Also works for multibarrelled guns
#define AMMO_NO_DISPLAY -1

/obj/item/gun/projectile
	name = "gun"
	desc = "A gun that fires bullets."
	icon_state = "revolver"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	w_class = ITEM_SIZE_NORMAL
	matter = list(MATERIAL_STEEL = 1000)
	screen_shake = TRUE
	combustion = TRUE
	has_smoke_particles = TRUE

	var/caliber = "357"		//determines which casings will fit
	var/handle_casings = EJECT_CASINGS	//determines how spent casings should be handled
	var/load_method = SINGLE_CASING | SPEEDLOADER //1 = Single shells, 2 = box or quick loader, 3 = magazine
	var/obj/item/ammo_casing/chambered = null

	//For SINGLE_CASING or SPEEDLOADER guns
	var/max_shells = 0			//the number of casings that will fit inside
	var/ammo_type = null		//the type of ammo that the gun comes preloaded with
	var/list/loaded = list()	//stored ammo
	var/starts_loaded = 1		//whether the gun starts loaded or not, can be overridden for guns crafted in-game

	//For MAGAZINE guns
	var/magazine_type = null	//the type of magazine that the gun comes preloaded with
	var/obj/item/ammo_magazine/ammo_magazine = null //stored magazine
	var/allowed_magazines		//magazine types that may be loaded. Can be a list or single path
	var/auto_eject = 0			//if the magazine should automatically eject itself when empty.
	var/auto_eject_sound = null
	var/mag_insert_sound = SFX_MAGAZINE_INSERT
	var/mag_eject_sound = 'sound/weapons/empty.ogg'

	far_fire_sound = SFX_FAR_FIRE

	var/is_jammed = 0           //Whether this gun is jammed
	var/jam_chance = 0          //Chance it jams on fire
	//TODO generalize ammo icon states for guns
	//var/magazine_states = 0
	//var/list/icon_keys = list()		//keys
	//var/list/ammo_states = list()	//values

/obj/item/gun/projectile/Initialize()
	. = ..()
	if (starts_loaded)
		if(ispath(ammo_type) && (load_method & (SINGLE_CASING|SPEEDLOADER)))
			for(var/i in 1 to max_shells)
				loaded += new ammo_type(src)
		if(ispath(magazine_type) && (load_method & MAGAZINE))
			ammo_magazine = new magazine_type(src)
	update_icon()

/obj/item/gun/projectile/Destroy()
	QDEL_NULL_LIST(ammo_magazine)
	QDEL_NULL_LIST(loaded)
	QDEL_NULL(chambered)
	return ..()

/obj/item/gun/projectile/consume_next_projectile()
	if(!is_jammed && prob(jam_chance))
		src.visible_message("<span class='danger'>\The [src] jams!</span>")
		is_jammed = 1
	if(is_jammed)
		return null
	//get the next casing
	if(loaded.len)
		chambered = loaded[1] //load next casing.
		if(handle_casings != HOLD_CASINGS)
			loaded -= chambered
	else if(ammo_magazine && ammo_magazine.stored_ammo.len)
		chambered = ammo_magazine.stored_ammo[ammo_magazine.stored_ammo.len]
		if(handle_casings != HOLD_CASINGS)
			ammo_magazine.stored_ammo -= chambered

	if (chambered)
		return chambered.expend()
	return null

/obj/item/gun/projectile/handle_post_fire()
	..()
	if(chambered)
		chambered.expend()
		process_chambered()

/obj/item/gun/projectile/handle_click_empty()
	..()
	process_chambered()

/obj/item/gun/projectile/proc/process_chambered()
	if (!chambered) return

	switch(handle_casings)
		if(EJECT_CASINGS) //eject casing onto ground.
			ejectCasing()
		if(CYCLE_CASINGS) //cycle the casing back to the end.
			if(ammo_magazine)
				ammo_magazine.stored_ammo += chambered
			else
				loaded += chambered

	if(handle_casings != HOLD_CASINGS)
		chambered = null


//Attempts to load A into src, depending on the type of thing being loaded and the load_method
//Maybe this should be broken up into separate procs for each load method?
/obj/item/gun/projectile/proc/load_ammo(obj/item/A, atom/movable/loader)
	if(istype(A, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/AM = A
		if(!(load_method & AM.mag_type) || caliber != AM.caliber)
			return //incompatible

		switch(AM.mag_type)
			if(MAGAZINE)
				if((ispath(allowed_magazines) && !istype(A, allowed_magazines)) || (islist(allowed_magazines) && !is_type_in_list(A, allowed_magazines)))
					to_chat(loader, "<span class='warning'>\The [A] won't fit into [src].</span>")
					return

				if(ammo_magazine)
					to_chat(loader, "<span class='warning'>[src] already has a magazine loaded.</span>")//already a magazine here
					return

				if(ismob(loader))
					var/mob/user = loader
					user.drop(AM, src)
				else
					AM.forceMove(src)

				ammo_magazine = AM
				loader.visible_message("[loader] inserts [AM] into [src].", "<span class='notice'>You insert [AM] into [src].</span>")
				playsound(src.loc, mag_insert_sound, rand(45, 60), FALSE)

			if(SPEEDLOADER)
				if(loaded.len >= max_shells)
					to_chat(loader, "<span class='warning'>[src] is full!</span>")
					return

				var/count = 0
				for(var/obj/item/ammo_casing/C in AM.stored_ammo)
					if(loaded.len >= max_shells)
						break

					if(C.caliber == caliber)
						C.forceMove(src)
						loaded += C
						AM.stored_ammo -= C //should probably go inside an ammo_magazine proc, but I guess less proc calls this way...
						count++

				if(count)
					loader.visible_message("[loader] reloads [src].", "<span class='notice'>You load [count] round\s into [src].</span>")
					playsound(src, mag_insert_sound, rand(50, 75), FALSE)

		AM.update_icon()

	else if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/C = A
		if(!(load_method & SINGLE_CASING) || caliber != C.caliber)
			return //incompatible

		if(loaded.len >= max_shells)
			to_chat(loader, "<span class='warning'>[src] is full.</span>")
			return

		if(ismob(loader))
			var/mob/user = loader
			user.drop(C, src)
		else
			C.forceMove(src)

		loaded.Insert(1, C) //add to the head of the list
		loader.visible_message("[loader] inserts \a [C] into [src].", "<span class='notice'>You insert \a [C] into [src].</span>")

		if (istype(C, /obj/item/ammo_casing/shotgun))
			playsound(loader, SFX_SHELL_INSERT, rand(45, 60), FALSE)
		else
			playsound(loader, SFX_BULLET_INSERT, rand(45, 60), FALSE)
	update_icon()

//attempts to unload src. If allow_dump is set to 0, the speedloader unloading method will be disabled
/obj/item/gun/projectile/proc/unload_ammo(atom/movable/unloader, allow_dump = TRUE, dump_loc = null)
	if(is_jammed)
		unloader.visible_message("<b>[unloader]</b> begins to unjam [src].", "You clear the jam and unload [src]")
		if(!do_after(unloader, 4, src, luck_check_type = LUCK_CHECK_COMBAT))
			return

		is_jammed = 0
		playsound(src.loc, 'sound/weapons/flipblade.ogg', rand(50, 75), FALSE)

	if(ammo_magazine)
		if(allow_dump)
			ammo_magazine.dropInto(isnull(dump_loc) ? unloader.loc : dump_loc)
			unloader.visible_message("[unloader] ejects [ammo_magazine] from [src].", SPAN_NOTICE("You eject [ammo_magazine] from [src]."))
		else if(ismob(unloader))
			var/mob/user = unloader
			user.pick_or_drop(ammo_magazine)
			unloader.visible_message("[user] removes [ammo_magazine] from [src].", SPAN_NOTICE("You remove [ammo_magazine] from [src]."))
		else if(Adjacent(src, unloader))
			ammo_magazine.forceMove(get_turf(unloader))

		playsound(src.loc, mag_eject_sound, 50, 1)
		ammo_magazine.update_icon()
		ammo_magazine = null

	else if(loaded.len)
		//presumably, if it can be speed-loaded, it can be speed-unloaded.
		if(allow_dump && (load_method & SPEEDLOADER))
			var/count = 0
			var/turf/T = get_turf(unloader)
			if(T)
				for(var/obj/item/ammo_casing/C in loaded)
					C.forceMove(T)
					C.SpinAnimation(4, 1)
					playsound(C, C.fall_sounds, rand(45, 60), TRUE)
					count++
				loaded.Cut()
			if(count)
				unloader.visible_message("<b>[unloader]</b> unloads [src].", SPAN("notice", "You unload [count] round\s from [src]."))
		else if(load_method & SINGLE_CASING)
			var/obj/item/ammo_casing/C = loaded[loaded.len]
			loaded.len--
			if(ismob(unloader))
				var/mob/user = unloader
				user.pick_or_drop(C)
			else if(Adjacent(src, unloader))
				C.forceMove(get_turf(unloader))

			unloader.visible_message("<b>[unloader]</b> removes \a [C] from [src].", SPAN("notice", "You remove \a [C] from [src]."))
			playsound(src.loc, "bullet_insert", 50, 1)
	else
		to_chat(unloader, SPAN("warning", "[src] is empty."))

	update_icon()

/obj/item/gun/projectile/attackby(obj/item/A as obj, mob/user as mob)
	load_ammo(A, user)

/obj/item/gun/projectile/attack_self(mob/user as mob)
	if(firemodes.len > 1)
		..()
	else
		unload_ammo(user)

/obj/item/gun/projectile/attack_hand(mob/user as mob)
	if(user.get_inactive_hand() == src)
		unload_ammo(user, allow_dump=0)
	else
		return ..()

/obj/item/gun/projectile/afterattack(atom/A, mob/living/user)
	..()
	if(auto_eject && ammo_magazine && ammo_magazine.stored_ammo && !ammo_magazine.stored_ammo.len)
		ammo_magazine.dropInto(user.loc)
		user.visible_message(
			"[ammo_magazine] falls out and clatters on the floor!",
			"<span class='notice'>[ammo_magazine] falls out and clatters on the floor!</span>"
			)
		if(auto_eject_sound)
			playsound(user, auto_eject_sound, 40, 1)
		ammo_magazine.update_icon()
		ammo_magazine = null
		update_icon() //make sure to do this after unsetting ammo_magazine

/obj/item/gun/projectile/examine(mob/user, infix)
	. = ..()

	if(is_jammed)
		. += SPAN_WARNING("It looks jammed.")

	if(ammo_magazine)
		. += "It has \a [ammo_magazine] loaded."

	if(getAmmo() != AMMO_NO_DISPLAY)
		. += "Has [getAmmo()] round\s remaining."

/obj/item/gun/projectile/proc/getAmmo()
	var/bullets = 0
	if(loaded)
		bullets += loaded.len
	if(ammo_magazine)
		if(!ammo_magazine.display_default_ammo_left)
			return AMMO_NO_DISPLAY
		if(ammo_magazine.stored_ammo)
			bullets += ammo_magazine.stored_ammo.len
	if(chambered)
		bullets += 1
	return bullets

/obj/item/gun/projectile/proc/ejectCasing()
	if(istype(chambered, /obj/item/ammo_casing/shotgun))
		chambered.forceMove(get_turf(src))
		chambered.SpinAnimation(4, 1)
		playsound(chambered, 'sound/effects/weapons/gun/shell_fall.ogg', rand(45, 60), TRUE)
	else
		pixel_z = 8
		chambered.SpinAnimation(4, 1)
		var/angle_of_movement = ismob(loc) ? (rand(-30, 30)) + dir2angle(turn(loc.dir, -90)) : rand(-30, 30)
		chambered.AddComponent(/datum/component/movable_physics, _horizontal_velocity = rand(45, 55) / 10, \
		 _vertical_velocity = rand(40, 45) / 10, _horizontal_friction = rand(20, 24) / 100, _z_gravity = 9.8, \
		 _z_floor = 0, _angle_of_movement = angle_of_movement, _physic_flags = QDEL_WHEN_NO_MOVEMENT, \
		 _bounce_sounds = chambered.fall_sounds)
		if(LAZYLEN(chambered.fall_sounds))
			playsound(loc, pick(chambered.fall_sounds), rand(45, 60), 1)

/* Unneeded -- so far.
//in case the weapon has firemodes and can't unload using attack_hand()
/obj/item/gun/projectile/verb/unload_gun()
	set name = "Unload Ammo"
	set category = "Object"
	set src in usr

	if(usr.stat || usr.restrained()) return

	unload_ammo(usr)
*/
#undef AMMO_NO_DISPLAY
