//Brain slug proc for voluntary removal of control.
/mob/living/carbon/proc/release_control()

	set category = "Abilities"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(B && B.host_brain && B.can_use_abilities("controlling"))
		to_chat(src, SPAN("danger", "You withdraw your probosci, releasing control of [B.host_brain]"))
		B.detatch()
	else
		to_chat(src, SPAN("danger" ,"ERROR NO BORER OR BRAINMOB DETECTED IN THIS MOB, THIS IS A BUG!"))

//Brain slug proc for tormenting the host.
/mob/living/carbon/proc/punish_host()
	set category = "Abilities"
	set name = "Torment host"
	set desc = "Punish your host with agony."

	var/mob/living/simple_animal/borer/B = has_brain_worms()


	if(B && B.host_brain?.ckey && B.can_use_abilities("controlling"))
		to_chat(src, SPAN("danger", "You send a punishing spike of psychic agony lancing into your host's brain."))
		if (!can_feel_pain())
			to_chat(B.host_brain, SPAN("warning", "You feel a strange sensation as a foreign influence prods your mind."))
			to_chat(src, SPAN("danger", "It doesn't seem to be as effective as you hoped."))
		else
			to_chat(B.host_brain, SPAN("danger", "<FONT size=3>Horrific, burning agony lances through you, ripping a soundless scream from your trapped mind!</FONT>"))

/mob/living/carbon/proc/spawn_larvae()
	set category = "Abilities"
	set name = "Reproduce"
	set desc = "Spawn several young."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(B && B.can_use_abilities("controlling") && B.chemicals >= 100)
		to_chat(src, SPAN("danger", "Your host twitches and quivers as you rapidly excrete a larva from your sluglike body."))
		visible_message(SPAN("danger", "\The [src] heaves violently, expelling a rush of vomit and a wriggling, sluglike creature!"))
		B.chemicals -= 100
		B.has_reproduced = TRUE

		new /obj/effect/decal/cleanable/vomit(get_turf(src))
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		new /mob/living/simple_animal/borer(get_turf(src), B.generation + 1)
	else
		to_chat(src, SPAN("warning", "You do not have enough chemicals stored to reproduce."))
		return

/**
 *  Attempt to devour victim
 *
 *  Returns TRUE on success, FALSE on failure
 */
/mob/living/carbon/proc/devour(atom/movable/victim)
	var/can_eat = can_devour(victim)
	if(!can_eat)
		return FALSE
	var/eat_speed = 100
	if(can_eat == DEVOUR_FAST)
		eat_speed = 30
	src.visible_message("<span class='danger'>\The [src] is attempting to devour \the [victim]!</span>")
	var/mob/target = victim
	if(isobj(victim))
		target = src
	if(!do_mob(src,target,eat_speed))
		return FALSE
	src.visible_message("<span class='danger'>\The [src] devours \the [victim]!</span>")
	if(ismob(victim))
		admin_attack_log(src, victim, "Devoured.", "Was devoured by.", "devoured")
	else
		src.drop_from_inventory(victim)
	victim.forceMove(src)
	src.stomach_contents.Add(victim)

	return TRUE
