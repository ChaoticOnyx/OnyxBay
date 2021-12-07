/mob/living/simple_animal/metroid
	name = "pet metroid"
	desc = "A lovable, domesticated metroid."
	icon = 'icons/mob/metroids.dmi'
	icon_state = "grey baby metroid"
	icon_living = "grey baby metroid"
	icon_dead = "grey baby metroid dead"
	speak_emote = list("chirps")
	health = 100
	maxHealth = 100
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	emote_see = list("jiggles", "bounces in place")
	bodyparts = /decl/simple_animal_bodyparts/metroid
	var/colour = "grey"

/mob/living/simple_animal/metroid/can_force_feed(feeder, food, feedback)
	if(feedback)
		to_chat(feeder, "Where do you intend to put \the [food]? \The [src] doesn't have a mouth!")
	return 0

/mob/living/simple_animal/adultmetroid
	name = "pet metroid"
	desc = "A lovable, domesticated metroid."
	icon = 'icons/mob/metroids.dmi'
	health = 200
	maxHealth = 200
	icon_state = "grey adult metroid"
	icon_living = "grey adult metroid"
	icon_dead = "grey baby metroid dead"
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	emote_see = list("jiggles", "bounces in place")
	bodyparts = /decl/simple_animal_bodyparts/metroid
	var/colour = "grey"

/mob/living/simple_animal/adultmetroid/New()
	..()
	overlays += "ametroid-:33"


/mob/living/simple_animal/metroid/adult/death()
	var/mob/living/simple_animal/metroid/S1 = new /mob/living/simple_animal/metroid (src.loc)
	S1.icon_state = "[src.colour] baby metroid"
	S1.icon_living = "[src.colour] baby metroid"
	S1.icon_dead = "[src.colour] baby metroid dead"
	S1.colour = "[src.colour]"
	var/mob/living/simple_animal/metroid/S2 = new /mob/living/simple_animal/metroid (src.loc)
	S2.icon_state = "[src.colour] baby metroid"
	S2.icon_living = "[src.colour] baby metroid"
	S2.icon_dead = "[src.colour] baby metroid dead"
	S2.colour = "[src.colour]"
	qdel(src)

/decl/simple_animal_bodyparts/metroid
	hit_zones = list("cytoplasmic membrane", "core", "slimy body")
