/mob/living/simple_animal/hostile/lymphocyte
	name = "Lymphocyte"
	desc = "Lymphocyte"
	icon = 'icons/obj/thalamus.dmi'
	icon_state = "blob_head"
	icon_living = "blob_head"
	icon_dead = "blob_head_death"
	speak_chance = 0
	health = 25
	maxHealth = 25
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "disturbed"
	attack_sound = 'sound/effects/screech.ogg'
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
