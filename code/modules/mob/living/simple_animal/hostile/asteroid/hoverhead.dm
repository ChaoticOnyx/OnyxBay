////////////////Hoverhead////////////////

/mob/living/simple_animal/hostile/asteroid/hoverhead
	name = "hoverhead"
	desc = "Strange hovering humanoid with exaggerated head and degenerated limbs. His gigantic head constantly emits forcefield of unknown origins."
	icon = 'icons/mob/asteroid/psychekinetic.dmi'
	icon_state = "Psychekinetic"
	icon_living = "Psychekinetic"
	icon_aggro = "Psychekinetic_alert"
	icon_dead = "Psychekinetic_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = 2
	move_to_delay = 14
	ranged = 1
	vision_range = 5
	aggro_vision_range = 9
	idle_vision_range = 5
	speed = 3
	maxHealth = 75
	health = 75
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "lashes out at"
	throw_message = "falls right through the strange body of the"
	ranged_cooldown = 0
	ranged_cooldown_cap = 0
	environment_smash = 0
	retreat_distance = 3
	minimum_distance = 3
	pass_flags = PASS_FLAG_TABLE

/mob/living/simple_animal/hostile/asteroid/hoverhead/OpenFire(the_target)
	var/mob/living/simple_animal/hostile/asteroid/p_anomaly/A = new /mob/living/simple_animal/hostile/asteroid/p_anomaly(src.loc)
	A.GiveTarget(target_mob)
	A.friends = friends
	A.faction = faction
	return

/mob/living/simple_animal/hostile/asteroid/hoverhead/AttackingTarget()
	OpenFire()

/mob/living/simple_animal/hostile/asteroid/hoverhead/death(gibbed, deathmessage, show_dead_message)
	. = ..()
	if(.)
		new /obj/item/asteroid/anomalous_core(src.loc)



////////////////Psychokinetic anomaly////////////////

/mob/living/simple_animal/hostile/asteroid/p_anomaly
	name = "psychokinetic anomaly"
	desc = "A strange space-time anomaly that boils and compresses all matter around it."
	icon = 'icons/mob/asteroid/psychekinetic.dmi'
	icon_state = "Psychekinetic_anomaly"
	icon_living = "Psychekinetic_anomaly"
	icon_aggro = "Psychekinetic_anomaly"
	icon_dead = "Psychekinetic_anomaly"
	icon_gib = "syndicate_gib"
	mouse_opacity = 2
	move_to_delay = 0
	friendly = "buzzes near"
	vision_range = 10
	speed = 3
	maxHealth = 1
	health = 1
	harm_intent_damage = 5
	melee_damage_lower = 2
	melee_damage_upper = 2
	attacktext = "burns"
	throw_message = "falls right through the strange body of the"
	environment_smash = 0
	damtype = BURN
	pass_flags = PASS_FLAG_TABLE
	var/lifetime = 5

/mob/living/simple_animal/hostile/asteroid/p_anomaly/Life()
	..()
	if(lifetime)
		lifetime--
	else death()

/mob/living/simple_animal/hostile/asteroid/p_anomaly/death()
	qdel(src)



////////////////Anomalous core////////////////

/obj/item/asteroid/anomalous_core
	name = "anomalous core"
	desc = "Strange biostructure that constantly emits bursts of energy. It has two flaps and a juicy core that looks squeezable."
	icon = 'icons/mob/asteroid/psychekinetic.dmi'
	icon_state = "psychecore"
	var/inert = 0
	var/preserved = 0
	w_class = 2

/obj/item/asteroid/anomalous_core/New()
	. = ..()
	addtimer(CALLBACK(src, .proc/inert_check), 1200)

/obj/item/asteroid/anomalous_core/proc/inert_check()
	if(preserved != 1)
		make_inert()

/obj/item/asteroid/anomalous_core/proc/make_inert()
	inert = 1
	icon_state = "psychecore_used"
	desc = "Strange biostructure that looks as if it possesed some energy but then was drained out. It has two flaps and a husked core."

/obj/item/asteroid/anomalous_core/proc/preserved()
	inert = 0
	preserved = 1
	icon_state = "psychecore"
	desc = "Strange biostructure that constantly emits bursts of energy. It has two flaps and a juicy core that looks squeezable. It is preserved, allowing you to use it to heal completely without danger of decay."

/obj/item/asteroid/anomalous_core/attack(mob/living/M, mob/living/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(inert)
			to_chat(user, "<span class='notice'>[src] has become inert, its healing properties are no more.</span>")
			return
		else
			if(H.stat == DEAD)
				to_chat(user, "<span class='notice'>[src] are useless on the dead.</span>")
				return
			if(H != user)
				H.visible_message("[user] forces [H] to apply [src]... They quickly regenerate all the injuries!")
			else
				to_chat(user, "<span class='notice'>You start to smear [src] on yourself. You feel burst of energy coming through your whole body. At first it feels like torture, but then it feels good.</span>")
			H.revive()
			make_inert(src)
			qdel(src)
	..()

/obj/item/hoverheadstabilizer
	name = "stabilizing serum"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	desc = "Inject hoverhead's cores with this stabilizer to preserve their healing powers indefinitely."
	w_class = 2

/obj/item/hoverheadstabilizer/afterattack(obj/item/M, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	var/obj/item/asteroid/anomalous_core/C = M
	if(!istype(C, /obj/item/asteroid/anomalous_core))
		to_chat(user, "<span class='warning'>The stabilizer only works on certain types of artifacts, generally regenerative in nature.</span>")
		return

	C.preserved()
	to_chat(user, "<span class='notice'>You inject the [M] with the stabilizer. It will no longer go inert.</span>")
	qdel(src)
