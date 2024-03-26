/mob/living/simple_animal/hostile/lymphocyte
	name = "???"
	desc = "You can't be completely sure what this is and whether it's a real thing. <span class='danger'>You feel your sanity slipping away just by looking at it.</span>"
	icon = 'icons/obj/thalamus.dmi'
	icon_state = "lymphocyte"
	icon_living = "lymphocyte"
	speak_chance = 0
	health = 25
	maxHealth = 25
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "disturbed"
	faction = "thalamus"
	speed = 4
	supernatural = TRUE
	bodyparts = /decl/simple_animal_bodyparts/psychic_glitch
	var/weakref/thalamus

/mob/living/simple_animal/hostile/lymphocyte/Initialize(mapload, mob/living/deity/thalamus)
	. = ..()

	if(istype(thalamus))
		src.thalamus = weakref(thalamus)

	QDEL_IN(src, 30 SECONDS)

/mob/living/simple_animal/hostile/lymphocyte/Destroy()
	thalamus = null
	return ..()

/mob/living/simple_animal/hostile/lymphocyte/find_target()
	. = ..()
	if(.)
		audible_emote("twitches as it glides towards [.]")
