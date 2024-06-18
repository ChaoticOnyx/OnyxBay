/obj/item/fighter_component/primary
	name = "Fuck you"
	slot = HARDPOINT_SLOT_PRIMARY
	var/overmap_select_sound = 'sound/effects/ship/pdc_start.ogg'
	var/overmap_firing_sounds = list('sound/effects/fighters/autocannon.ogg')
	var/accepted_ammo = /obj/item/ammo_magazine
	var/obj/item/ammo_magazine/magazine = null
	var/list/ammo = list()
	var/burst_size = 1
	var/fire_delay = 0
	var/bypass_safety = FALSE
	active = TRUE

/obj/item/fighter_component/primary/Initialize()
	. = ..()
	var/mag = new /obj/item/ammo_magazine/box/a556(src)
	load(src, mag)

/obj/item/fighter_component/primary/dump_contents()
	. = ..()
	for(var/atom/movable/AM as() in .)
		if(AM == magazine)
			magazine = null
			ammo = list()
			playsound(loc, 'sound/effects/ship/mac_load.ogg', 100, 1)

/obj/item/fighter_component/primary/get_ammo()
	return length(ammo)

/obj/item/fighter_component/primary/get_max_ammo()
	return magazine ? magazine.max_ammo : 500 //Default.

/obj/item/fighter_component/primary/load(obj/structure/overmap/target, atom/movable/AM)
	if(!istype(AM, accepted_ammo))
		return FALSE

	if(magazine)
		if(magazine.stored_ammo?.len >= magazine?.max_ammo)
			return FALSE

		else
			magazine.forceMove(get_turf(target))
	AM.forceMove(src)
	magazine = AM
	ammo = magazine.stored_ammo
	playsound(target, 'sound/effects/ship/mac_load.ogg', 100, 1)
	return TRUE

/obj/item/fighter_component/primary/fire(obj/target)
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return FALSE

	if(!ammo.len)
		//F.relay('sound/weapons/gun_dry_fire.ogg')
		return FALSE

	var/obj/item/ammo_casing/chambered = ammo[ammo.len]
	//var/datum/ship_weapon/SW = F.weapon_types[fire_mode]
	//SW.fire_fx_only(target, chambered.projectile_type)
	ammo -= chambered
	qdel(chambered)
	return TRUE

/obj/item/fighter_component/primary/on_install(obj/structure/overmap/target)
	. = ..()
	if(!fire_mode)
		return FALSE

/obj/item/fighter_component/primary/remove_from(obj/structure/overmap/target)
	. = ..()
	magazine = null
	ammo = list()

/obj/structure/overmap/proc/fire_projectile(proj_type, obj/structure/overmap/target, speed=null, user_override=null, lateral=FALSE, ai_aim = FALSE, miss_chance=5, max_miss_distance=5, broadside=FALSE) //Fire one shot. Used for big, hyper accelerated shots rather than PDCs
	if(!z || QDELETED(src))
		return FALSE

	var/turf/T = get_center()
	var/obj/item/projectile/proj = new proj_type(T)
	if(ai_aim && !proj.hitscan)
		target = calculate_intercept(target, proj, miss_chance=miss_chance, max_miss_distance=max_miss_distance)
	proj.starting = T
	if(user_override)
		proj.firer = user_override
	else if(gunner)
		proj.firer = gunner
	else
		proj.firer = src

	proj.original = target
	proj.previous = get_turf(loc)
	proj.def_zone = ran_zone()
	proj.firer = src
	var/direct_target
	if(get_turf(target) == get_turf(src))
		direct_target = target

	proj.preparePixelProjectileOvermap(target, src, null, 0, lateral)

	proj.fire(null, direct_target)

/**
* Given target ship and projectile speed, calculate aim point for intercept
* See: https://stackoverflow.com/a/3487761
* If they're literally moving faster than a bullet just aim right at them
*/

/obj/structure/overmap/proc/calculate_intercept(obj/structure/overmap/target, obj/item/projectile/P, miss_chance=5, max_miss_distance=5)
	if(!target || !istype(target) || !target.velocity || !P || !istype(P))
		return target
	var/turf/my_center = get_center()
	var/turf/their_center = target.get_center()
	if(!my_center || !their_center)
		return target

	var/dx = their_center.x - my_center.x
	var/dy = their_center.y - my_center.y
	var/tvx = target.velocity.a
	var/tvy = target.velocity.e
	var/projectilespeed = 32 / P.speed

	var/a = tvx * tvx + tvy * tvy - (projectilespeed * projectilespeed)
	var/b = 2 * (tvx * dx + tvy * dy)
	var/c = dx * dx + dy * dy
	var/list/solutions = SolveQuadratic(a, b, c)
	if(!solutions.len)
		return their_center

	var/time = 0
	if(solutions.len > 1)
		// If both are valid take the smaller time
		if((solutions[1] > 0) && (solutions[2] > 0))
			time = min(solutions[1], solutions[2])
		else if(solutions[1] > 0)
			time = solutions[1]
		else if(solutions[2] > 0)
			time = solutions[2]
		else
			return their_center

	var/targetx = their_center.x + target.velocity.a * time
	var/targety = their_center.y + target.velocity.e * time
	var/turf/newtarget = locate(targetx, targety, target.z)

	return newtarget
