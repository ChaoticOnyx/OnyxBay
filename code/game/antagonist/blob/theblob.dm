//Few global vars to track the blob

GLOBAL_VAR_INIT(blob_tiles_grown_total, 0)
var/list/blobs = list()
var/list/blob_cores = list()
var/list/blob_nodes = list()
var/list/blob_resources = list()
var/list/blob_overminds = list()

/obj/effect/blob
	name = "blob"
	icon = 'icons/mob/blob/blob_64x64.dmi'
	icon_state = "center"
	luminosity = 2
	desc = "A part of a blob."
	density = TRUE
	opacity = TRUE
	anchored = TRUE

	var/health = 20
	var/maxhealth = 20
	var/healt_timestamp = 0
	var/brute_resist = 1
	var/fire_resist = 1

	pixel_x = -WORLD_ICON_SIZE/2
	pixel_y = -WORLD_ICON_SIZE/2
	layer = BLOB_BASE_LAYER

	var/spawning = 2
	var/dying = 0
	var/mob/blob/overmind = null
	var/destroy_sound = 'sound/effects/blob/blobsplat.ogg'
	var/custom_process=0
	var/time_since_last_pulse
	var/manual_remove = 0

/obj/effect/blob/attackby(obj/item/I, mob/user)
	. = ..()

	var/damage = 0

	if (istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I

		if (W.welding)
			damage += (15 / fire_resist)
			playsound(I, 'sound/items/welder.ogg', 60, TRUE)

	if (I.sharp)
		damage += (4 / brute_resist)

	if (I.edge)
		damage += (10 / brute_resist)

	if (!I.sharp && !I.edge)
		damage += (2 / brute_resist)

	health -= damage

/obj/effect/blob/blob_act()
	return

/obj/effect/blob/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	var/damage = min(0.01 * exposed_temperature / fire_resist, 0)

	if (damage)
		health -= damage
		update_icon()

/obj/effect/blob/ex_act(severity)
	var/damage = 150
	health -= ((damage/brute_resist) - (severity * 5))
	update_icon()
	return

/obj/effect/blob/bullet_act(obj/item/projectile/Proj)
	..()

	switch(Proj.damage_type)
		if (BRUTE)
			health -= (Proj.damage/brute_resist)
		if (BURN)
			health -= (Proj.damage/fire_resist)

	update_icon()

/obj/effect/blob/New(turf/loc, no_morph = 0)
	blobs += src
	src.dir = pick(NORTH, SOUTH, EAST, WEST)
	time_since_last_pulse = world.time

	if(spawning && !no_morph)
		icon_state = initial(icon_state) + "_spawn"
		spawn(10)
			spawning = 0//for sprites
			icon_state = initial(icon_state)
			src.update_icon(1)
	else
		spawning = 0
		update_icon()
		for(var/obj/effect/blob/B in orange(src,1))
			B.update_icon()

	..(loc)
	for(var/atom/A in loc)
		A.blob_act(0,src)

	GLOB.blob_tiles_grown_total++

	if (!(src in SSobj.processing))
		START_PROCESSING(SSobj, src)

	return

/obj/effect/blob/Destroy()
	GLOB.blob_tiles_grown_total--
	blobs -= src

	for(var/obj/effect/blob/B in orange(loc,1))
		B.update_icon()

		if(!spawning)
			anim(target = B.loc, a_icon = icon, flick_anim = "connect_die", sleeptime = 50, direction = get_dir(B,src))

	..()

/obj/effect/blob/proc/Life()
	if (health <= 0)
		qdel(src)

/obj/effect/blob/Process()
	Life()

/obj/effect/blob/proc/Pulse(pulse = 0, origin_dir = 0, mob/blob/source = null)
	time_since_last_pulse = world.time

	for (var/mob/M in loc)
		M.blob_act(0,src)
	for (var/obj/O in loc)
		for (var/i in 1 to max(1,(4-pulse)))
			O.blob_act(TRUE) //Hits up to 4 times if adjacent to a core
	if (run_action())//If we can do something here then we dont need to pulse more
		return

	if (pulse > 30)
		return//Inf loop check

	//Looking for another blob to pulse
	var/list/dirs = list(NORTH, SOUTH, EAST, WEST)
	dirs.Remove(origin_dir)//Dont pulse the guy who pulsed us
	for (var/i in 1 to 4)
		if (!dirs.len)
			break
		var/dirn = pick_n_take(dirs)
		var/turf/T = get_step(src, dirn)
		var/obj/effect/blob/B = locate() in T
		if (!B)
			if (prob(70))
				expand(T, TRUE, source)//No blob here so try and expand
			return
		spawn(2)
			B.Pulse((pulse+1), get_dir(src.loc, T), source)
		return
	return

/obj/effect/blob/proc/run_action()
	return

/obj/effect/blob/proc/expand(turf/T = null, prob = 1, mob/blob/source)
	if (istype(T, /turf/space))
		return
	if (prob && !prob(health))
		return
	if (!T)
		var/list/dirs = list(NORTH, SOUTH, EAST, WEST)
		for (var/i in 1 to 4)
			var/dirn = pick_n_take(dirs)
			T = get_step(src, dirn)
			if (!(locate(/obj/effect/blob) in T))
				break
			else
				T = null

	if (!T)
		return 0
	var/obj/effect/blob/normal/B = new(src.loc)

	if(istype(src,/obj/effect/blob/normal))
		var/num = rand(1,100)
		num /= 10000
		B.layer = layer - num

	if (T.Enter(B,src))//Attempt to move into the tile
		B.forceMove(T)

		if (istype(T,/turf/simulated/floor))
			var/turf/simulated/floor/F = T
			F.burn_tile()
	else //If we cant move in hit the turf
		if (!source || !source.restrain_blob)
			T.blob_act(0,src) //Don't attack the turf if our source mind has that turned off.
		B.manual_remove = 1
		qdel(B)

	for (var/atom/A in T)//Hit everything in the turf
		A.blob_act(0,src)
	return 1

/obj/effect/blob/update_icon(spawnend = 0)
	if (health < maxhealth)
		var/hurt_percentage = round((health * 100) / maxhealth)
		var/hurt_icon

		switch(hurt_percentage)
			if (0 to 25)
				hurt_icon = "hurt_100"
			if (26 to 50)
				hurt_icon = "hurt_75"
			if (51 to 75)
				hurt_icon = "hurt_50"
			else
				hurt_icon = "hurt_25"

		overlays += image(icon,hurt_icon)

/obj/effect/blob/proc/change_to(type, mob/blob/M = null, special = FALSE)
	if (!ispath(type))
		error("[type] is an invalid type for the blob.")
	if (special) //Send additional information to the New()
		new type(src.loc, 200, null, 1, M)
	else
		var/obj/effect/blob/B = new type(src.loc)
		B.dir = dir
	spawning = 1//so we don't show red severed connections
	manual_remove = 1
	qdel(src)
	return

//////////////////NORMAL BLOBS/////////////////////////////////
/obj/effect/blob/normal
	luminosity = 2
	health = 21
	layer = BLOB_BASE_LAYER

/obj/effect/blob/normal/update_icon(spawnend = 0)
	spawn(1)
		overlays.len = 0
		underlays.len = 0

		underlays += image(icon,"roots")

		if(!spawning)
			for(var/obj/effect/blob/B in orange(src,1))
				if(B.spawning == 1)
					anim(target = loc, a_icon = icon, flick_anim = "connect_spawn", sleeptime = 15, direction = get_dir(src,B))
					spawn(8)
						update_icon()
				else if(!B.dying && !B.spawning)
					if(spawnend)
						anim(target = loc, a_icon = icon, flick_anim = "connect_spawn", sleeptime = 15, direction = get_dir(src,B))
					else
						if(istype(B,/obj/effect/blob/core))
							overlays += image(icon,"connect",dir = get_dir(src,B))
						else
							overlays += image(icon,"connect",dir = get_dir(src,B))

		if(spawnend)
			spawn(10)
				update_icon()

		..()
