/mob/living/simple_animal/hostile/psychic_glitch
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

///////////////

/decl/simple_animal_bodyparts/psychic_glitch
	hit_zones = list("???", "absence of body", "nonexistent limb", "whatever", "somewhere")

///////////////

/obj/effect/effect/psychic_glitch
	name = "???"
	icon = 'icons/mob/psychic_glitch.dmi'
	icon_state = "psychic_glitch_death"
	mouse_opacity = 0
	density = FALSE
	anchored = TRUE
	layer = ABOVE_HUMAN_LAYER

/obj/effect/effect/psychic_glitch/Initialize()
	. = ..()
	if(prob(50))
		playsound(loc, 'sound/effects/phasein.ogg', 80, 1)
	else
		playsound(loc, 'sound/effects/creepyshriek.ogg', 80, 1)

	QDEL_IN(src, 1 SECOND)

///////////////

#define TICKS_TO_RESTORE_GLITCH 3

/obj/structure/psychic_rift
	name = "wounded reality"
	desc = "A crack in... Reality? <span class='danger'>You feel your sanity slipping away just by looking at it.</span>"
	mouse_opacity = 1
	alpha = 200
	icon = 'icons/mob/psychic_glitch.dmi'
	icon_state = "rift1"
	density = FALSE
	var/max_glitches_at_time = 10 // Max psychic_glitch'es to exist at once
	var/max_glitches = 40 // How many glitches must be killed to close the rift
	var/glitches_active = 0 // Currently existing psychic_glitch'es
	var/glitches_destroyed = 0 // How many glitches have been killed so far
	var/rift_active = FALSE // Fancy shattering effect
	var/restoration_ticks = TICKS_TO_RESTORE_GLITCH // Decreasing glitches_destroyed count once in a while

/obj/structure/psychic_rift/Initialize()
	. = ..()
	visible_message(SPAN("danger", "Something feels very wrong..."))
	icon_state = "rift0"
	set_next_think(world.time + 15 SECONDS)

/obj/structure/psychic_rift/proc/check_rift_state()
	if(glitches_destroyed >= max_glitches)
		visible_message(SPAN("danger", "The reality's wounds seems to be mended for now. All you can do is to hope it wasn't scarred too deep."))
		qdel(src)
		return FALSE

	if(glitches_destroyed < max_glitches * 0.4)
		icon_state = "rift1"
	else if(glitches_destroyed < max_glitches * 0.6)
		icon_state = "rift2"
	else if(glitches_destroyed < max_glitches * 0.85)
		icon_state = "rift3"
	else if(glitches_destroyed < max_glitches * 0.95)
		icon_state = "rift4"
	else
		icon_state = "rift5"

	return TRUE

/obj/structure/psychic_rift/proc/spawn_glitch()
	if(glitches_active + glitches_destroyed > max_glitches_at_time)
		return
	glitches_active++
	var/mob/living/simple_animal/hostile/psychic_glitch/PG = new(loc)
	PG.my_rift = weakref(src)

/obj/structure/psychic_rift/think()
	if(!rift_active)
		playsound(loc, 'sound/effects/breaking/window/break4.ogg', 100, 1)
		visible_message(SPAN("danger", "Something pierces through the space-time, wounding the reality itself!"))
		rift_active = TRUE

	if(!check_rift_state())
		return

	spawn_glitch()
	restoration_ticks--
	if(restoration_ticks < 0 && glitches_destroyed > 0)
		glitches_destroyed--
		restoration_ticks = TICKS_TO_RESTORE_GLITCH

	set_next_think(world.time + 3 SECOND)

#undef TICKS_TO_RESTORE_GLITCH
