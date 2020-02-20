/mob/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	icon = 'icons/mob/blob/blob.dmi'
	icon_state = "marker"

	see_in_dark = 8
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS|SEE_SELF
	see_invisible = SEE_INVISIBLE_MINIMUM
	invisibility = INVISIBILITY_OBSERVER

	pass_flags = PASS_FLAG_BLOB
	faction = "blob"

	plane = EFFECTS_ABOVE_LIGHTING_PLANE

	hud_type = /datum/hud/blob
	var/obj/effect/blob/core/blob_core = null // The blob overmind's core
	var/blob_points = 0
	var/max_blob_points = 100
	var/maxjumprange = 20 //how far you can go in terms of non-blob tiles in a jump attempt
	var/restrain_blob = TRUE
	var/last_power = 0

	var/blob_warning = 0

	var/list/special_blobs = list()

/mob/blob/New(loc, ...)
	. = ..()

	if (!stat)
		GLOB.living_mob_list_ |= list(src)

/mob/blob/Login()
	. = ..()

	to_chat(src, "<span class='blob'>You are the blob!</span>")
	to_chat(src, "The location of your thoughts (eye), nodes, and core power your spore factories, resources, and passive expansion.")
	to_chat(src, "<b>CTRL Click:</b> Active expand/attack. Expensive, use sparingly.")
	to_chat(src, "<b>ALT Click:</b> (On Blob) Upgrade to healthier, fire immune Strong Blob. (On Core) Toggle passive wall smashing - stealthier and leaves cover up!")
	to_chat(src, "<b>MIDDLE Click:</b> Rally (factory) spores. <b>DOUBLE Click:<B> Move eye (to blob).")
	to_chat(src, "<b><span class='bad'>Always place factories and resources within 2 tiles of a node or core!</span></b>")

	if (restrain_blob)
		to_chat(src, "<b><span class='bad'>You are stealthily restraining your blob from smashing walls! Don't forget to toggle it off when you are ready!</span></b>")

/mob/blob/AltClickOn(atom/A) // Create a shield
	var/turf/T = get_turf(A)

	if (T)
		create_shield(T)

/mob/blob/CtrlClickOn(atom/A) // Expand blob
	var/turf/T = get_turf(A)

	if (T)
		expand_blob(T)

/mob/blob/MiddleClickOn(atom/A) // Rally spores
	var/turf/T = get_turf(A)

	if (T)
		rally_spores(T)

mob/blob/DblClickOn(atom/A) //Teleport view to another blob
	var/turf/T = get_turf(A)

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if (!B)
		return
	else
		usr.forceMove(T)

/mob/blob/Weaken(amount)
	return FALSE

/mob/blob/airflow_stun()
	return FALSE

/mob/blob/CanPass(atom/movable/mover, turf/target, height, air_group)
	return TRUE

/mob/blob/check_airflow_movable(n)
	return FALSE

/mob/blob/ex_act()
	return

/mob/blob/singularity_act()
	return

/mob/blob/cultify()
	return

/mob/blob/singularity_pull()
	return

/mob/blob/blob_act()
	return

/mob/blob/Life()
	if (is_dead())
		ghostize(FALSE)
		qdel(src)

	update_hud()

/mob/blob/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	var/obj/effect/blob/B = locate() in range("3x3", NewLoc)
	if(B)
		src.forceMove(B.loc)
	else
		B = locate() in range("3x3", src.loc)

/mob/blob/say_wrapper()
	say(input("","say (text)"))

/mob/blob/say(message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return

	if (stat)
		return

	blob_talk(message)

/mob/blob/proc/blob_talk(message)
	var/turf/T = get_turf(src)

	log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) Blob Hivemind: [message]")

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	var/msg_verb = say_quote(message)
	var/rendered = "<font color=\"#EE4000\"><i><span class='game say'>Blob Telepathy, <span class='name'>[name]</span> [msg_verb] \"<span class='message'>[message]</span>\"</span></i></font>"

	for (var/mob/blob/S in GLOB.living_mob_list_)
		if(istype(S))
			S.show_message(rendered, 2)

/mob/blob/update_hud()
	if (is_dead())
		return

	var/datum/hud/blob/H = hud_used

	if (!H)
		InitializeHud()

	var/number_of_cores = blob_cores.len
	var/matrix/M = matrix()

	M.Scale(1,blob_points/max_blob_points)

	var/total_offset = (60 + (100*(blob_points/max_blob_points))) * PIXEL_MULTIPLIER

	H.blob_powerbar.transform = M
	H.blob_powerbar.screen_loc = "WEST,CENTER-[8-round(total_offset/WORLD_ICON_SIZE)]:[total_offset%WORLD_ICON_SIZE]"
	H.blob_coverLEFT.maptext = "[blob_points]"
	H.blob_coverLEFT.maptext_x = 4*PIXEL_MULTIPLIER

	if (blob_points >= 100)
		H.blob_coverLEFT.maptext_x = 1

	H.blob_spawnblob.color = GRAYSCALE
	H.blob_spawnstrong.color = GRAYSCALE
	H.blob_spawnresource.color = GRAYSCALE
	H.blob_spawnfactory.color = GRAYSCALE
	H.blob_spawnnode.color = GRAYSCALE
	H.blob_spawncore.color = GRAYSCALE
	H.blob_rally.color = GRAYSCALE
	H.blob_taunt.color = GRAYSCALE

	if (blob_points >= BLOBATTCOST)
		H.blob_spawnblob.color = null
		H.blob_rally.color = null
	if (blob_points >= BLOBSHICOST)
		H.blob_spawnstrong.color = null
	if (blob_points >= BLOBTAUNTCOST)
		H.blob_taunt.color = null
	if (blob_points >= BLOBNODCOST)
		H.blob_spawnnode.color = null
	if (blob_points >= BLOBRESCOST)
		H.blob_spawnresource.color = null
	if (blob_points >= BLOBFACCOST)
		H.blob_spawnfactory.color = null

	if (blob_points >= BLOBCOREBASECOST+(BLOBCORECOSTINC*(number_of_cores-1)))
		H.blob_spawncore.color = null

	M = matrix()

	M.Scale(1,blob_core.health/blob_core.maxhealth)

	total_offset = (60 + (100*(blob_core.health/blob_core.maxhealth))) * PIXEL_MULTIPLIER

	H.blob_healthbar.transform = M
	H.blob_healthbar.screen_loc = "EAST:[14*PIXEL_MULTIPLIER],CENTER-[8-round(total_offset/WORLD_ICON_SIZE)]:[total_offset%WORLD_ICON_SIZE]"
	H.blob_coverRIGHT.maptext = "[blob_core.health]"

/mob/blob/proc/add_points(points)
	if(points != 0)
		blob_points = Clamp(blob_points + points, 0, max_blob_points)

	update_hud()

/mob/blob/proc/update_specialblobs()
	var/datum/hud/blob/blob_hud = hud_used

	if (client && blob_hud)
		client.screen ^= blob_hud.spec_blobs
		QDEL_NULL_LIST(blob_hud.spec_blobs)
		blob_hud.spec_blobs = list()

		for (var/i=1;i<=24;i++)
			var/obj/effect/blob/B = null

			if (i<=special_blobs.len)
				B = special_blobs[i]

			if (!B)
				continue

			var/obj/screen/specialblob/S = new()

			switch(B.type)
				if(/obj/effect/blob/core)
					S.icon_state = "smallcore"
				if(/obj/effect/blob/resource)
					S.icon_state = "smallresource"
				if(/obj/effect/blob/factory)
					S.icon_state = "smallfactory"
				if(/obj/effect/blob/node)
					S.icon_state = "smallnode"

			S.icon = 'icons/mob/screen1_blob.dmi'
			S.name = "Jump to Blob"
			S.linked_blob = B
			S.screen_loc = "NORTH,WEST+[i * 0.5]"

			blob_hud.spec_blobs += S
			client.screen |= blob_hud.spec_blobs

/mob/blob/is_dead()
	if (!blob_core || (blob_core && blob_core.health <= 0))
		stat = DEAD
		return TRUE

	return FALSE

/mob/blob/Stat()
	..()
	if (statpanel("Blob Status"))
		if(blob_core)
			stat(null, "Core Health: [blob_core.health]")
		stat(null, "Power Stored: [blob_points]/[max_blob_points]")
		stat(null, "Blob Total Size: [blobs.len]")
		stat(null, "Total Nodes: [blob_nodes.len]")
		stat(null, "Total Overminds: [blob_cores.len]")
	return
