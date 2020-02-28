/obj/effect/blob/resource
	name = "resource blob"
	icon_state = "resource"
	desc = "A part of a blob. It makes a slow, deep breathing sound."
	health = 30
	maxhealth = 30
	fire_resist = 2
	var/resource_delay = 0
	spawning = 0
	layer = BLOB_RESOURCE_LAYER
	destroy_sound = "sound/effects/blobsplatspecial.ogg"

/obj/effect/blob/resource/New(loc)
	..()

	blob_resources += src
	flick("morph_resource",src)

/obj/effect/blob/resource/Destroy()
	blob_resources -= src

	if (!manual_remove && overmind)
		to_chat(overmind,"<span class='warning'>You lost a resource blob.</span> <b><a href='?src=\ref[overmind];blobjump=\ref[loc]'>(JUMP)</a></b>")
		overmind.special_blobs -= src
		overmind.update_specialblobs()

	..()

/obj/effect/blob/resource/Pulse(pulse = 0, origin_dir = 0)
	if (!overmind)
		var/mob/blob/B = (locate() in range(src,1))

		if (B)
			to_chat(B,"<span class='notice'>You take control of the resource blob.</span>")
			overmind = B
			B.special_blobs += src
			B.update_specialblobs()

	..()

/obj/effect/blob/resource/run_action()
	if(resource_delay > world.time)
		return 0

	resource_delay = world.time + (8 SECONDS)

	if(overmind)
		overmind.add_points(1)

	return 1

/obj/effect/blob/resource/update_icon(spawnend = 0)
	spawn(1)
		if(overmind)
			color = null
		else
			color = "#888888"

	spawn(1)
		overlays.len = 0
		underlays.len = 0
		underlays += image(icon,"roots")

		if(!spawning)
			for(var/obj/effect/blob/B in orange(src,1))
				overlays += image(icon,"resourceconnect",dir = get_dir(src,B))
		if(spawnend)
			spawn(10)
				update_icon()

		..()
