/mob/living/simple_animal/hostile/commanded/goat
	name = "goat"
	desc = "Not known for their pleasant disposition."

	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"

	speak = list("Be-e-e...", "Me-e-e...", "A-a-ah...", "ME-E-E!", "BE-E-E!",
				 "A-A-AH!", "Be-e?", "Me-e?", "A-ah?", "M-e-e-e-e-e-e!")

	var/rare_speaks = list("Be-e-da-a-un" = 0.0001, "Ahme-e-d" = 0.001) //fucken rare rjombas (chance in percents)

	density = 1
	see_in_dark = 6
	speak_chance = 5
	health = 75
	maxHealth = 75

	melee_damage_lower = 1
	melee_damage_upper = 5

	attacktext = "kicked"
	can_escape = 1
	max_gas = list("phoron" = 2, "carbon_dioxide" = 5)

	response_help = "pets"
	response_harm = "hits"
	response_disarm = "pushes"

	known_commands = list("stay", "stop", "attack", "follow")

/mob/living/simple_animal/hostile/commanded/goat/hit_with_weapon(obj/item/O, mob/living/user, effective_force, hit_zone)
	. = ..()
	if(!.)
		emote("brays in rage!")

/mob/living/simple_animal/hostile/commanded/goat/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(M.a_intent == I_HURT)
		emote("brays in rage!")

/mob/living/simple_animal/hostile/commanded/goat/speaking()
	for(var/message in rare_speaks)
		if(prob(rare_speaks[message]))
			say(message)
			return

	var/action = pick(
		speak.len;      "speak",
		emote_hear.len; "emote_hear",
		emote_see.len;  "emote_see"
		)

	switch(action)
		if("speak")
			var/message = pick(speak)
			say(message)
			if(prob(10))
				if(message == "ME-E-E!")
					playsound_local(loc, 'sound/voice/goat3.ogg', 40)
				if(message == "Me-e-e..." || message == "M-e-e-e-e-e-e!")
					playsound_local(loc, 'sound/voice/goat4.ogg', 40)
				if(message == "A-a-ah...")
					playsound_local(loc, 'sound/voice/goat2.ogg', 25)
				if(message == "A-A-AH!")
					playsound_local(loc, 'sound/voice/goat1.ogg', 15)

		if("emote_hear")
			audible_emote("[pick(emote_hear)].")
		if("emote_see")
			visible_emote("[pick(emote_see)].")