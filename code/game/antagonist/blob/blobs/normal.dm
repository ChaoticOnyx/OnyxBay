/obj/effect/blob/normal
	luminosity = 2
	health = 21
	layer = BLOB_BASE_LAYER

/obj/effect/blob/normal/update_icon(var/spawnend = 0)
	if(health <= 15)
		icon_state = "blob_damaged"