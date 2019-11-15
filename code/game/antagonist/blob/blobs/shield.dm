/obj/effect/blob/shield
	name = "strong blob"
	icon_state = "blob_idle"
	desc = "A dense part of a blob."
	health = 75
	maxhealth = 75
	brute_resist = 4
	fire_resist = 2
	layer = BLOB_SHIELD_LAYER
	spawning = 0
	destroy_sound = "sound/effects/blobsplat.ogg"

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
