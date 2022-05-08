//kobold
/mob/living/simple_animal/kobold
	name = "kobold"
	desc = "A small, rat-like creature."
	icon = 'icons/mob/kobold.dmi'
	icon_state = "kobold_idle"
	icon_living = "kobold_idle"
	icon_dead = "kobold_dead"
	speak = list("You no take candle!","Identify yourself!","Ooh, pretty shiny.","Me take?","Where gold here...","Me likey.")
	speak_emote = list("mutters","hisses","grumbles")
	emote_hear = list("mutters under it's breath.","grumbles.", "yips!")
	emote_see = list("looks around suspiciously.", "scratches it's arm.","putters around a bit.")
	speak_chance = 15
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 75
	health = 75
	meat_type = /obj/item/reagent_containers/food/meat/monkey
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	minbodytemp = 223	//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	universal_speak = 1
	universal_understand = 1
	possession_candidate = 1
	bodyparts = /decl/simple_animal_bodyparts/humanoid

/mob/living/simple_animal/kobold/Life()
	..()
	if(prob(15) && turns_since_move && !stat)
		flick("kobold_act",src)

/mob/living/simple_animal/kobold/Move(dir)
	..()
	if(!stat)
		flick("kobold_walk",src)
