// Point controlling procs

/mob/blob/proc/can_buy(cost = 15)
	if (blob_points < cost)
		to_chat(src, "<span class='warning'>You cannot afford this.</span>")
		return 0

	add_points(-cost)
	return 1

/mob/blob/proc/can_use_power(cooldown, silent=FALSE)
	if (!last_power || world.time > last_power + cooldown)
		return TRUE

	if (!silent)
		to_chat(src, "The power is on cooldown.")

	return FALSE

// Power verbs

/mob/blob/verb/transport_core()
	set category = "Blob"
	set name = "Jump to Core"
	set desc = "Transport back to your core."

	if (blob_core)
		src.forceMove(blob_core.loc)

/mob/blob/verb/jump_to_node()
	set category = "Blob"
	set name = "Jump to Node"
	set desc = "Transport back to a selected node."

	if (blob_nodes.len)
		var/list/nodes = list()
		for(var/i = 1; i <= blob_nodes.len; i++)
			var/obj/effect/blob/node/B = blob_nodes[i]
			nodes["Blob Node #[i] ([get_area_name(B)])"] = B
		var/node_name = input(src, "Choose a node to jump to.", "Node Jump") in nodes
		var/obj/effect/blob/node/chosen_node = nodes[node_name]

		if (chosen_node)
			src.forceMove(chosen_node.loc)

/mob/blob/verb/create_shield_power()
	set category = "Blob"
	set name = "Create Shield Blob"
	set desc = "Create a shield blob."

	var/turf/T = get_turf(src)
	create_shield(T)

/mob/blob/verb/telepathy_power()
	set category = "Blob"
	set name = "Psionic Message"
	set desc = "Give a psionic message to all creatures on and around your 'local' vicinity."

	var/text = input(src, "What message should we send?", "Message") as null|text

	if (text)
		telepathy(text)

/mob/blob/proc/telepathy(message as text)
	if (!can_use_power(BLOBTAUNTCD) || !can_buy(BLOBTAUNTCOST))
		return

	last_power = world.time

	for (var/mob/living/M in GLOB.living_mob_list_)
		if (!M.client || M.loc.z != usr.loc.z)
			continue

		to_chat(M, "<span class='warning'>Your vision becomes cloudy, and your mind becomes clear.</span>")

		spawn(5)
			to_chat(M, "<span class='blob'>[message]</span>") //Only sends messages to things on its own z level
			log_say(src, "used blob telepathy to convey \"[message]\"")

/mob/blob/proc/create_shield(turf/T)
	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if (!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if (istype(B, /obj/effect/blob/core))
		if(B.overmind == src)
			restrain_blob()
			return

	if (!istype(B, /obj/effect/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	if (!can_use_power(BLOBSHICD) || !can_buy(BLOBSHICOST))
		return

	last_power = world.time

	B.change_to(/obj/effect/blob/shield)

/mob/blob/verb/create_resource()
	set category = "Blob"
	set name = "Create Resource Blob"
	set desc = "Create a resource tower which will generate points for you."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if(!istype(B, /obj/effect/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/effect/blob/resource/blob in orange(4, T))
		to_chat(src, "There is a resource blob nearby, move more than 4 tiles away from it!")
		return

	if(!can_use_power(BLOBRESCD) || !can_buy(BLOBRESCOST))
		return

	last_power = world.time

	B.change_to(/obj/effect/blob/resource)
	var/obj/effect/blob/resource/R = locate() in T

	if (R)
		R.overmind = src
		special_blobs += R
		update_specialblobs()

/mob/blob/proc/create_core()
	set category = "Blob"
	set name = "Create Core Blob"
	set desc = "Create another Core Blob to aid in the station takeover"

	var/turf/T = get_turf(src)

	if (!T)
		return

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if (!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if (!istype(B, /obj/effect/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/effect/blob/core/blob in orange(15))
		to_chat(src, "There is another core blob nearby, move more than 15 tiles away from it!")
		return

	var/number_of_cores = blob_cores.len
	var/cost = BLOBCOREBASECOST+(BLOBCORECOSTINC*(number_of_cores-1))

	if (!can_use_power(BLOBCORECD))
		return

	if (!can_buy(cost))
		to_chat(src, "Current cost of a blob core is [cost]!")
		return

	last_power = world.time
	B.change_to(/obj/effect/blob/core, src, TRUE)

/mob/blob/verb/create_node()
	set category = "Blob"
	set name = "Create Node Blob"
	set desc = "Create a Node."


	var/turf/T = get_turf(src)

	if (!T)
		return

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if (!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if (!istype(B, /obj/effect/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for (var/obj/effect/blob/node/blob in orange(5, T))
		to_chat(src, "There is another node nearby, move more than 5 tiles away from it!")
		return

	if(!can_use_power(BLOBNODCD) || !can_buy(BLOBNODCOST))
		return

	last_power = world.time
	B.change_to(/obj/effect/blob/node)
	var/obj/effect/blob/node/N = locate() in T

	if (N)
		N.overmind = src
		special_blobs += N
		update_specialblobs()
		max_blob_points += BLOBNDPOINTINC

/mob/blob/verb/create_factory()
	set category = "Blob"
	set name = "Create Factory Blob"
	set desc = "Create a Spore producing blob."

	var/turf/T = get_turf(src)

	if (!T)
		return

	var/obj/effect/blob/B = locate(/obj/effect/blob) in T
	if (!B)
		to_chat(src, "You must be on a blob!")
		return

	if (!istype(B, /obj/effect/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for (var/obj/effect/blob/factory/blob in orange(4, T))
		to_chat(src, "There is a factory blob nearby, move more than 7 tiles away from it!")
		return

	if (!can_use_power(BLOBFACCOST) || !can_buy(BLOBFACCOST))
		return

	last_power = world.time
	B.change_to(/obj/effect/blob/factory)
	var/obj/effect/blob/factory/F = locate() in T

	if (F)
		F.overmind = src
		special_blobs += F
		update_specialblobs()

/mob/blob/verb/revert()
	set category = "Blob"
	set name = "Remove Blob"
	set desc = "Removes a blob."

	var/turf/T = get_turf(src)

	if (!T)
		return

	var/obj/effect/blob/B = locate(/obj/effect/blob) in T

	if (!B)
		to_chat(src, "You must be on a blob!")
		return

	if (istype(B, /obj/effect/blob/core))
		to_chat(src, "Unable to remove this blob.")
		return

	B.manual_remove = 1
	qdel(B)

/mob/blob/verb/callblobs()
	set category = "Blob"
	set name = "Call Overminds"
	set desc = "Prompts your fellow overminds to come at your location."

	var/turf/T = get_turf(src)

	if (!T)
		return

	to_chat(src,"<span class='notice'>You sent a call to the other overminds...</span>")

	var/they_exist = 0

	for (var/mob/blob/O in blob_overminds)
		if (O != src)
			they_exist++
			to_chat(O,"<span class='notice'>[src] is calling for your attention!</span> <b><a href='?src=\ref[O];blobjump=\ref[loc]'>(JUMP)</a></b>")

	if (they_exist)
		to_chat(src,"<span class='notice'>...[they_exist] overmind\s heard your call!</span>")
	else
		to_chat(src,"<span class='notice'>...but no one heard you!</span>")

/mob/blob/verb/expand_blob_power()
	set category = "Blob"
	set name = "Expand/Attack Blob"
	set desc = "Attempts to create a new blob in this tile. If the tile isn't clear we will attack it, which might clear it."

	var/turf/T = get_turf(src)
	expand_blob(T)

/mob/blob/proc/expand_blob(turf/T)
	if (!T)
		return

	var/obj/effect/blob/B = locate() in T

	if (B)
		to_chat(src, "There is a blob here!")
		return

	var/obj/effect/blob/OB = locate() in circlerange(T, 1)

	if (!OB)
		to_chat(src, "There is no blob adjacent to you.")
		return

	if (!can_use_power(BLOBATTCD))
		return

	if (!can_buy(BLOBATTCOST))
		to_chat(src, "Current cost of a blob is [BLOBATTCOST]!")
		return

	last_power = world.time
	OB.expand(T, 0) //Doesn't give source because we don't care about passive restraint

/mob/blob/verb/rally_spores_power()
	set category = "Blob"
	set name = "Rally Spores"
	set desc = "Rally the spores to move to your location."

	var/turf/T = get_turf(src)
	rally_spores(T)

/mob/blob/proc/rally_spores(turf/T)
	if(!can_buy(BLOBRALCOST))
		return

	last_power = world.time
	to_chat(src, "You rally your spores.")

	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))

	if (!surrounding_turfs.len)
		return

	for(var/mob/living/simple_animal/hostile/blobspore/BS in GLOB.living_mob_list_)
		if(isturf(BS.loc) && get_dist(BS, T) <= 35)
			BS.LoseTarget()
			BS.Goto(pick(surrounding_turfs), BS.move_to_delay)

/mob/blob/proc/restrain_blob()
	restrain_blob = !restrain_blob
	to_chat(src,"<span class='notice'>You will [restrain_blob ? "now" : "not"] restrain your blobs from passively spreading into walls.</span>")
