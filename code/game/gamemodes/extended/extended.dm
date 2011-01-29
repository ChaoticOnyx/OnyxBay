/datum/game_mode/extended
	name = "Extended Role-Playing"
	config_tag = "extended"

/datum/game_mode/extended/announce()
	..()
	world << "<B>Just have fun and role-play!</B>"

/datum/game_mode/extended/process()
	if (blobs.len > 0)
		for (var/i = 1 to 25)
			if (blobs.len == 0)
				break

			var/obj/blob/B = pick(blobs)
			if(B.z != 1)
				continue

			for (var/atom/A in B.loc)
				A.blob_act()

			B.Life()
