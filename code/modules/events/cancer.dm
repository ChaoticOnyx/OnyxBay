datum/event/cancer/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return


	var/victims = min(rand(1,3), candidates.len)
	while(victims)
		new /obj/item/organ/internal/cancer(pick_n_take(candidates))
		victims--
