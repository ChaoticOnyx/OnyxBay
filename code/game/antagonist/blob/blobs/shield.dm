/obj/effect/blob/shield
	name = "strong blob"
	icon_state = "strong"
	desc = "A dense part of a blob."
	health = 20
	maxhealth = 20
	brute_resist = 2
	fire_resist = 2
	layer = BLOB_SHIELD_LAYER
	spawning = 0
	destroy_sound = "sound/effects/blobsplat.ogg"

/obj/effect/blob/shield/New(loc,newlook = null)
	..()
	flick("morph_strong",src)

/obj/effect/blob/shield/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if (istype(mover) && mover.pass_flags & PASS_FLAG_BLOB)
		return 1
	if (mover)
		mover.Bump(src) //Only automatic for dense objects
	return 0

/obj/effect/blob/shield/run_action()
	if (health >= 50)
		return 0

	health += 10
	return 1

/obj/effect/blob/shield/update_icon(spawnend = 0)
	spawn(1)
		overlays.len = 0
		underlays.len = 0

		underlays += image(icon,"roots")

		if(!spawning)
			for(var/obj/effect/blob/B in orange(src,1))
				overlays += image(icon,"strongconnect",dir = get_dir(src,B))
		if(spawnend)
			spawn(10)
				update_icon()

		..()
