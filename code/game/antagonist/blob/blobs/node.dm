/obj/effect/blob/node
	name = "blob node"
	icon_state = "node"
	desc = "A part of a blob."
	density = FALSE
	opacity = FALSE
	health = 100
	maxhealth = 100
	fire_resist = 2
	custom_process=1
	layer = BLOB_NODE_LAYER
	spawning = 0
	destroy_sound = "sound/effects/blobsplatspecial.ogg"

/obj/effect/blob/node/New(loc, no_morph = 0)
	blob_nodes += src
	flick("morph_node",src)

	..(loc)

/obj/effect/blob/node/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/node/Destroy()
	blob_nodes -= src

	if (!manual_remove && overmind)
		to_chat(overmind, "<span class='warning'>A node blob that you had created has been destroyed.</span> <b><a href='?src=\ref[overmind];blobjump=\ref[loc]'>(JUMP)</a></b>")
		overmind.special_blobs -= src
		overmind.update_specialblobs()

	if (overmind)
		overmind.max_blob_points -= BLOBNDPOINTINC

	..()

/obj/effect/blob/node/Life()
	..()

	for(var/i = 1; i < 8; i += i)
		Pulse(5, i, overmind)

	if(health < maxhealth)
		health = min(maxhealth, health + 1)

/obj/effect/blob/node/run_action()
	return 0

/obj/effect/blob/node/update_icon(spawnend = 0)
	spawn(1)
		overlays.len = 0
		underlays.len = 0

		underlays += image(icon,"roots")

		if(!spawning)
			for(var/obj/effect/blob/B in orange(src,1))
				overlays += image(icon,"nodeconnect",dir = get_dir(src,B))
		if(spawnend)
			spawn(10)
				update_icon()

		..()

