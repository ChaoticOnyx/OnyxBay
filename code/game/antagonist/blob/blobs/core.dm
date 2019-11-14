/obj/effect/blob/core
	name = "blob core"
	icon_state = "blob_core"
	desc = "A part of a blob. It is large and pulsating."
	health = 200
	maxhealth = 200
	fire_resist = 2
	custom_process=1
	destroy_sound = "sound/effects/blob/blobkill.ogg"

	var/overmind_get_delay = 0 // we don't want to constantly try to find an overmind, do it every 30 seconds
	var/last_resource_collection
	var/point_rate = 1
	var/mob/blob/creator = null
	layer = BLOB_CORE_LAYER
	var/core_warning_delay = 0
	var/previous_health = 200

/obj/effect/blob/core/New(loc, h = 200, client/new_overmind = null, new_rate = 2, mob/blob/C = null, no_morph = 0)
	blob_cores += src

	creator = C

	playsound(src, "gib", 75, 1)

	if (!overmind && new_overmind)
		create_overmind(new_overmind)

	point_rate = new_rate
	last_resource_collection = world.time

	..(loc)

/obj/effect/blob/core/Destroy()
	blob_cores -= src

	for(var/mob/blob/O in blob_overminds)
		if(overmind && (O != overmind))
			to_chat(O,"<span class='danger'>A blob core has been destroyed! [overmind] lost his life!</span> <b><a href='?src=\ref[O];blobjump=\ref[loc]'>(JUMP)</a></b>")
		else
			to_chat(O,"<span class='warning'>A blob core has been destroyed. It had no overmind in control.</span> <b><a href='?src=\ref[O];blobjump=\ref[loc]'>(JUMP)</a></b>")
			O.stat = DEAD

	..()

/obj/effect/blob/core/Life()
	..()

	if (overmind)
		var/points_to_collect = Clamp(point_rate*round((world.time-last_resource_collection)/10), 0, 10)
		overmind.add_points(points_to_collect)
		last_resource_collection = world.time

	if (health < maxhealth)
		health = min(maxhealth, health + 1)
		update_icon()

	if (!spawning) //no expanding on the first Life() tick
		for(var/mob/M in viewers(src))
			M.playsound_local(loc, 'sound/effects/blob/blob_pulse.ogg', 50, 0, null, FALLOFF_SOUNDS, 0)

		var/turf/T = get_turf(overmind) //The overmind's mind can expand the blob
		var/obj/effect/blob/O = locate() in T //As long as it is 'thinking' about a blob already
		for(var/i = 1; i < 8; i += i)
			Pulse(0, i, overmind)
			if(istype(O))
				O.Pulse(5, i, overmind) //Pulse starting at 5 instead of 0 like a node
		for(var/b_dir in list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
			if(!prob(5))
				continue
			var/obj/effect/blob/normal/B = locate() in get_step(src, b_dir)
			if(B)
				B.change_to(/obj/effect/blob/shield)
	else
		spawning = 0

/obj/effect/blob/core/proc/create_overmind(client/new_overmind)
	if(!new_overmind)
		CRASH("new_overmind is null")

	if (!GLOB.blobs.can_become_antag(new_overmind.mob.mind))
		to_chat(usr, "<span class='warning'>You are banned from this role.</span>")
		return 0

	if(overmind)
		qdel(overmind)
		overmind = null

	var/mob/living/old = new_overmind.mob
	var/mob/blob/B = new(src.loc)
	B.mind = old.mind
	old.mind = null
	B.mind.current = B
	B.key = new_overmind.key
	B.blob_core = src
	src.overmind = B

	if (icon_state == "cerebrate")
		icon_state = "blob_core"

	B.special_blobs += src
	B.update_specialblobs()

	if(!B.blob_core.creator)//If this core is the first of its lineage (created by game mode/event/admins, instead of another overmind) it gets to choose its looks.
		var/new_name = "Blob Overmind ([rand(1, 999)])"
		B.name = new_name
		B.real_name = new_name
		B.mind.name = new_name
		for(var/mob/blob/O in blob_overminds)
			if(O != B)
				to_chat(O,"<span class='notice'>[B] has appeared and just started a new blob! <a href='?src=\ref[O];blobjump=\ref[loc]'>(JUMP)</a></span>")

		//B.verbs += /mob/blob/proc/create_core
	else
		var/new_name = "Blob Cerebrate ([rand(1, 999)])"
		B.name = new_name
		B.real_name = new_name
		B.mind.name = new_name

		for(var/mob/blob/O in blob_overminds)
			if(O != B)
				to_chat(O, "<span class='notice'>A new blob cerebrate has started thinking inside a blob core! [B] joins the blob! <a href='?src=\ref[O];blobjump=\ref[loc]'>(JUMP)</a></span>")

	return 1
