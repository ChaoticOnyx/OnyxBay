/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	icon_dead = "shade_dead"
	maxHealth = 50
	health = 50
	universal_speak = 1
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches"
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "drained the life from"
	minbodytemp = 0
	maxbodytemp = 4000
	min_gas = null
	max_gas = null
	speed = -1
	stop_automated_movement = 1
	status_flags = 0
	faction = "cult"
	supernatural = 1
	status_flags = CANPUSH
	bodyparts = /decl/simple_animal_bodyparts/shade

/mob/living/simple_animal/shade/cultify()
	return

/mob/living/simple_animal/shade/Life()
	..()
	OnDeathInLife()

/mob/living/simple_animal/shade/proc/OnDeathInLife()
	if(stat == DEAD)
		new /obj/item/ectoplasm(loc)
		for(var/mob/M in viewers(src, null))
			if((M.client && !( M.blinded )))
				M.show_message(SPAN("warning", "[src] lets out a contented sigh as their form unwinds."))
		ghostize()
		qdel(src)
		return

/decl/simple_animal_bodyparts/shade
	hit_zones = list("spectral robe", "featureless visage", "haunting glow")
