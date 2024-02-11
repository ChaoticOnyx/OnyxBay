	// These should all be procs, you can add them to humans/subspecies by
// species.dm's inherent_verbs ~ Z

/mob/living/carbon/human/proc/use_human_ability(atom/A)
	if(!isliving(A))
		return FALSE
	switch(active_ability)
		if(HUMAN_POWER_NONE)
			return FALSE
		if(HUMAN_POWER_SPIT)
			var/mob/living/M = A
			process_spit(M)
		if(HUMAN_POWER_LEAP)
			var/mob/living/M = A
			process_leap(M)
		if(HUMAN_POWER_TACKLE)
			var/mob/living/M = A
			process_tackle(M)
	return TRUE

/mob/living/carbon/human/MiddleClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/special_ability_key) == GLOB.PREF_MIDDLE_CLICK)
		if(use_human_ability(A))
			return
	..()

/mob/living/carbon/human/AltClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/special_ability_key) == GLOB.PREF_ALT_CLICK)
		if(use_human_ability(A))
			return
	..()

/mob/living/carbon/human/CtrlClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/special_ability_key) == GLOB.PREF_CTRL_CLICK)
		if(use_human_ability(A))
			return
	..()

/mob/living/carbon/human/CtrlShiftClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/special_ability_key) == GLOB.PREF_CTRL_SHIFT_CLICK)
		if(use_human_ability(A))
			return
	..()

/mob/living/carbon/human/proc/toggle_powers()
	set category = "Abilities"
	set name = "Disable Abilities"
	set desc = "Disable all active special abilities (Mouse Wheel)."

	if(!src || src.stat) // Who knows right?
		return
	active_ability = HUMAN_POWER_NONE
	to_chat(src, SPAN("notice", "<i>Selected special ability: <b>[active_ability]</b>.</i>"))

/mob/living/carbon/human/proc/toggle_tackle()
	set category = "Abilities"
	set name = "Set Tackle"
	set desc = "Tackle someone down (Mouse Wheel)."

	if(!src || src.stat)
		return
	active_ability = HUMAN_POWER_TACKLE
	to_chat(src, SPAN("notice", "<i>Selected special ability: <b>[active_ability]</b>.</i>"))

/mob/living/carbon/human/proc/tackle()
	set category = "Abilities"
	set name = "Tackle"
	set desc = "Tackle someone down."

	var/mob/living/target
	var/list/mob/living/targets = list()
	for(var/mob/living/M in oview(1, src))
		if(!istype(M, /mob/living/silicon) && Adjacent(M))
			targets += M
	targets -= src
	target = input(src, "Who do you wish to tackle?") as null|anything in targets

	process_tackle(target)

/mob/living/carbon/human/proc/no_self_pain()
	set category = "Abilities"
	set name = "No Pain"
	set desc = "Shut down your pain receptors for some time."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(!B.can_use_abilities(BORER_STATUS_IN_HOST))
		return

	if(B.chemicals >= 100)
		to_chat(src, SPAN("warning", "You do not have enough chemicals stored!"))
		return

	if(!host_pain_disable())
		to_chat(src, SPAN("warning", "Your host's pain receptors are already numb!"))
		return

	B.chemicals -= 100

	addtimer(CALLBACK(src, nameof(.proc/host_pain_disable)), 30 SECONDS)

/mob/living/carbon/human/proc/host_pain_disable()
	if(no_pain)
		return FALSE
	no_pain = TRUE
	to_chat(src, SPAN("danger", "Your whole body feels strangely numb."))
	return TRUE

/mob/living/carbon/human/proc/host_pain_enable()
	no_pain = FALSE

/mob/living/carbon/human/proc/process_tackle(mob/living/T)
	if(!T || !src || src.stat)
		return

	if(last_special > world.time)
		to_chat(src, SPAN("warning", "You cannot tackle so soon!"))
		return

	if(incapacitated(INCAPACITATION_DISABLED) || buckled || pinned.len)
		to_chat(src, SPAN("warning", "You cannot tackle in your current state."))
		return

	if(!isturf(loc))
		to_chat(src, SPAN("danger", "You cannot tackle anyone from here!"))
		return

	if(T == src)
		to_chat(src, SPAN("warning", "You cannot tackle yourself!"))
		return

	if(!Adjacent(T))
		return

	if(istype(T, /mob/living/silicon))
		to_chat(src, SPAN("warning", "[T] is too massive to be tackled down!"))
		return

	last_special = world.time + (5 SECONDS)

	T.Weaken(rand(2, 4))
	if(prob(75))
		visible_message(SPAN("danger", "\The [src] has tackled down [T]!"))
	else
		visible_message(SPAN("danger", "\The [src] has tried to tackle down [T]!"))

/mob/living/carbon/human/proc/toggle_leap()
	set category = "Abilities"
	set name = "Set Leap"
	set desc = "Leap at a target and grab them aggressively (Mouse Wheel)."

	if(!src || src.stat)
		return
	active_ability = HUMAN_POWER_LEAP
	to_chat(src, SPAN("notice", "<i>Selected special ability: <b>[active_ability]</b>.</i>"))

/mob/living/carbon/human/proc/leap()
	set category = "Abilities"
	set name = "Leap"
	set desc = "Leap at a target and grab them aggressively."

	var/mob/living/target
	var/list/mob/living/targets = list()
	for(var/mob/living/M in oview(4, src))
		if(!istype(M,/mob/living/silicon))
			targets += M

	if(!length(targets))
		return

	target = input(src, "Who do you wish to leap at?") as null|anything in targets

	process_leap(target)

/mob/living/carbon/human/proc/process_leap(mob/living/T)
	if(!T || !isturf(T.loc) || !src)
		return

	if(last_special > world.time)
		to_chat(src, SPAN("warning", "You cannot leap so soon!"))
		return FALSE

	if(incapacitated(INCAPACITATION_DISABLED) || buckled || pinned.len || stance_damage >= 4)
		to_chat(src, SPAN("warning", "You cannot leap in your current state."))
		return FALSE

	if(!isturf(loc))
		to_chat(src, SPAN("danger", "You cannot leap from here!"))
		return

	if(T == src)
		to_chat(src, SPAN("warning", "You cannot leap on yourself!"))
		return

	if(istype(T,/mob/living/silicon))
		return

	if(get_dist(get_turf(T), get_turf(src)) > 4)
		to_chat(src, SPAN("warning", "You must be closer to the target for leaping!"))
		return

	playsound(src.loc, 'sound/voice/shriek1.ogg', 50, 1)

	last_special = world.time + (17.5 SECONDS)
	status_flags |= LEAPING

	visible_message("<b>\The [src]</b> leaps at <b>[T]</b>!")
	throw_at(get_step(get_turf(T),get_turf(src)), 4, 1, src)

	sleep(5)

	if(status_flags & LEAPING)
		status_flags &= ~LEAPING

	if(!Adjacent(T))
		to_chat(src, SPAN("warning", "You miss!"))
		return

	T.Weaken(3)

	if(ishuman(T) && make_grab(src, T))
		visible_message(SPAN("danger", "<b>\The [src]</b> seizes [T]!"))

/mob/living/carbon/human/proc/commune()
	set category = "Abilities"
	set name = "Commune with creature"
	set desc = "Send a telepathic message to an unlucky recipient."

	var/list/targets = list()
	var/target = null
	var/text = null

	targets += getmobs() //Fill list, prompt user with list
	target = input("Select a creature!", "Speak to creature", null, null) as null|anything in targets

	if(!target) return

	text = input("What would you like to say?", "Speak to creature", null, null)

	text = sanitize(text)

	if(!text) return

	var/mob/M = targets[target]

	if(isghost(M) || M.is_ic_dead())
		to_chat(src, "<span class='warning'>Not even a [src.species.name] can speak to the dead.</span>")
		return

	log_say("[key_name(src)] communed to [key_name(M)]: [text]")

	to_chat(M, "<span class='notice'>Like lead slabs crashing into the ocean, alien thoughts drop into your mind: <i>[text]</i></span>")
	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(H.species.name == src.species.name)
			return
		if(prob(75))
			to_chat(H, "<span class='warning'>Your nose begins to bleed...</span>")
			H.drip(1)

/mob/living/carbon/human/proc/regurgitate()
	set name = "Regurgitate"
	set desc = "Empties the contents of your stomach"
	set category = "Abilities"

	if(stomach_contents.len)
		for(var/mob/M in src)
			if(M in stomach_contents)
				stomach_contents.Remove(M)
				M.forceMove(loc)
		src.visible_message("<span class='danger'>[src] hurls out the contents of their stomach!</span>")
	return

/mob/living/carbon/human/proc/psychic_whisper(mob/M in oview())
	set name = "Psychic Whisper"
	set desc = "Whisper silently to someone over a distance."
	set category = "Abilities"

	var/msg = sanitize(input("Message:", "Psychic Whisper") as text|null)
	if(msg)
		log_say("PsychicWhisper: [key_name(src)]->[M.key]: [msg]")
		to_chat(M, "<span class='alium'>You hear a strange, alien voice in your head... <i>[msg]</i></span>")
		to_chat(src, "<span class='alium'>You channel a message: \"[msg]\" to [M]</span>")
	return

/***********
 diona verbs
***********/
/mob/living/carbon/human/proc/diona_split_nymph()
	set name = "Split"
	set desc = "Split your humanoid form into its constituent nymphs."
	set category = "Abilities"
	diona_split_into_nymphs(5)	// Separate proc to void argments being supplied when used as a verb

/mob/living/carbon/human/proc/diona_heal_toggle()
	set name = "Toggle Heal"
	set desc = "Turn your inate healing on or off."
	set category = "Abilities"
	innate_heal = !innate_heal
	if(innate_heal)
		to_chat(src, "<span class='alium'>You are now using nutrients to regenerate.</span>")
	else
		to_chat(src, "<span class='alium'>You are no longer using nutrients to regenerate.</span>")

/mob/living/carbon/human/proc/diona_split_into_nymphs(number_of_resulting_nymphs)
	var/turf/T = get_turf(src)

	var/mob/living/carbon/alien/diona/S = new(T)
	S.set_dir(dir)
	transfer_languages(src, S)

	var/nymphs = 1
	var/mob/living/carbon/alien/diona/L = S

	for(var/mob/living/carbon/alien/diona/D in src)
		nymphs++
		D.forceMove(T)
		transfer_languages(src, D, WHITELISTED|RESTRICTED)
		D.set_dir(pick(NORTH, SOUTH, EAST, WEST))
		L.set_next_nymph(D)
		D.set_last_nymph(L)
		L = D

	if(nymphs < number_of_resulting_nymphs)
		for(var/i in nymphs to (number_of_resulting_nymphs - 1))
			var/mob/living/carbon/alien/diona/M = new(T)
			transfer_languages(src, M, WHITELISTED|RESTRICTED)
			M.set_dir(pick(NORTH, SOUTH, EAST, WEST))
			L.set_next_nymph(M)
			M.set_last_nymph(L)
			L = M

	L.set_next_nymph(S)
	S.set_last_nymph(L)

	for(var/obj/item/I in src)
		drop(I, force = TRUE)

	visible_message("<span class='warning'>\The [src] quivers slightly, then splits apart with a wet slithering noise.</span>")

	if(!mind)
		qdel(src)
		return

	mind.transfer_to(S)
	message_admins("\The [src] has split into nymphs; player now controls [key_name_admin(S)]")
	log_admin("\The [src] has split into nymphs; player now controls [key_name(S)]")
	qdel(src)

	var/newname = sanitize(input(S, "You are now a nymph. Choose a name for yourself.", "Nymph Name") as null|text, MAX_NAME_LEN)
	if(newname)
		S.fully_replace_character_name(newname)

/mob/living/carbon/human/proc/breath_death()
	set name = "Breath Death"
	set desc = "Infect others with your very breath."
	set category = "Abilities"

	if (last_special > world.time)
		to_chat(src, SPAN("warning", "You aren't ready to do that! Wait [round(last_special - world.time) / 10] seconds."))
		return

	if (incapacitated(INCAPACITATION_DISABLED))
		to_chat(src, SPAN("warning", "You can't do that while you're incapacitated!"))
		return
	if (nutrition < 150)
		to_chat(src, SPAN("warning", "You are too hungry to spread toxins!"))
		return

	last_special = world.time + 10 SECONDS
	remove_nutrition(50)

	var/turf/T = get_turf(src)
	var/obj/effect/effect/water/chempuff/chem = new(T)
	chem.create_reagents(10)
	chem.reagents.add_reagent(/datum/reagent/toxin/zombie, 2)
	chem.set_up(get_step(T, dir), 2, 10)
	playsound(T, 'sound/hallucinations/wail.ogg', 20, 1)

/mob/living/carbon/human/proc/consume()
	set name = "Consume"
	set desc = "Regain life by consuming it from others."
	set category = "Abilities"

	if (last_special > world.time)
		to_chat(src, SPAN("warning", "You aren't ready to do that! Wait [round(last_special - world.time) / 10] seconds."))
		return

	if (incapacitated())
		to_chat(src, SPAN("warning", "You can't do that while you're incapacitated!"))
		return

	var/mob/living/target
	for (var/mob/living/L in get_turf(src))
		if (L != src && (L.lying || L.is_ic_dead()))
			target = L
			break
	if (!target)
		to_chat(src, SPAN("warning", "You aren't on top of a victim!"))
		return

	last_special = world.time + 5 SECONDS

	visible_message(SPAN("danger", "\The [src] hunkers down over \the [target], tearing into their flesh."))
	if(do_mob(src, target, 5 SECONDS))
		to_chat(target, SPAN("danger", "\The [src] scrapes your flesh from your bones!"))
		to_chat(src, SPAN("danger", "You feed hungrily off \the [target]'s flesh."))
		target.adjustBruteLoss(25)
		if(ishuman(target))
			for(var/ID in src.virus2)
				var/datum/disease2/disease/D = src.virus2[ID]
				infect_virus2(target, D)
		if(target.getBruteLoss() > target.maxHealth)
			target.gib()
		adjustBruteLoss(-25)
		add_nutrition(20)
