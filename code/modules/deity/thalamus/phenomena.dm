/datum/deity_power/phenomena/release_lymphocytes
	name = "Phenomena: Warp Body"
	desc = "Gain the ability to warp the very structure of a target's body, wracking pain and weakness."
	expected_type = /turf

/datum/deity_power/phenomena/release_lymphocytes/manifest(atom/target, mob/living/deity/D)
	if(!..())
		return FALSE

	for(var/i = 0 to rand(2, 4))
		new /mob/living/simple_animal/hostile/lymphocyte(target, D)

/mob/living/simple_animal/hostile/lymphocyte
	name = "???"
	desc = "You can't be completely sure what this is and whether it's a real thing. <span class='danger'>You feel your sanity slipping away just by looking at it.</span>"
	icon = 'icons/mob/psychic_glitch.dmi'
	icon_state = "psychic_glitch"
	icon_living = "psychic_glitch"
	icon_dead = "psychic_glitch_death"
	speak_chance = 0
	health = 25
	maxHealth = 25
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "disturbed"
	attack_sound = 'sound/effects/screech.ogg'
	faction = "bluespace"
	speed = 4
	supernatural = 1
	bodyparts = /decl/simple_animal_bodyparts/psychic_glitch

	var/weakref/my_rift = null

/mob/living/simple_animal/hostile/psychic_glitch/find_target()
	. = ..()
	if(.)
		audible_emote("twitches as it glides towards [.]")

/mob/living/simple_animal/hostile/psychic_glitch/AttackingTarget()
	. = ..()
	if(ishuman(.))
		var/mob/living/carbon/human/H = .
		H.adjust_hallucination(30, 100)

/mob/living/simple_animal/hostile/psychic_glitch/death(gibbed, deathmessage, show_dead_message)
	..(null,"is fading!", show_dead_message)
	var/obj/structure/psychic_rift/psychic_rift = my_rift?.resolve()
	if(psychic_rift)
		psychic_rift.glitches_destroyed++
		psychic_rift.glitches_active--
		psychic_rift.check_rift_state()
		my_rift = null
	for(var/a in hearers(src, 4))
		if(istype(a,/mob/living/carbon/human))
			if(prob(50))
				continue

			var/mob/living/carbon/human/H = a
			to_chat(H, SPAN("warning", "As \the [src] is fading, you can feel some of your sanity fading as well."))
			H.adjust_hallucination(15, rand(35, 85))
	new /obj/effect/effect/psychic_glitch(loc)
	qdel(src)
