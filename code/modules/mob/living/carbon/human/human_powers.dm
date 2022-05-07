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

	if(isghost(M) || M.stat == DEAD)
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
		drop_from_inventory(I)

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


/mob/living/carbon/human/proc/can_nab(mob/living/target)
	if(QDELETED(src))
		return FALSE

	if(last_special > world.time)
		to_chat(src, "<span class='warning'>It is too soon to make another nab attempt.</span>")
		return FALSE

	if(incapacitated())
		to_chat(src, "<span class='warning'>You cannot nab in your current state.</span>")
		return FALSE

	if(!is_cloaked() || pulling_punches)
		to_chat(src, "<span class='warning'>You can only nab people when you are well hidden and ready to hunt.</span>")
		return FALSE

	if(target)
		if(!istype(target) || issilicon(target))
			return FALSE
		if(!Adjacent(target))
			to_chat(src, "<span class='warning'>\The [target] has to be adjacent to you.</span>")
			return FALSE

	return TRUE

/mob/living/carbon/human/proc/nab()
	set category = "Abilities"
	set name = "Nab"
	set desc = "Nab someone."

	if(!can_nab())
		return

	var/list/choices = list()
	for(var/mob/living/M in view(1,src))
		if(!istype(M,/mob/living/silicon) && Adjacent(M))
			choices += M
	choices -= src

	var/mob/living/T = input(src, "Who do you wish to nab?") as null|anything in choices
	if(!T || !can_nab(T))
		return

	last_special = world.time + 50

	if(l_hand) unEquip(l_hand)
	if(r_hand) unEquip(r_hand)
	to_chat(src, "<span class='warning'>You drop everything as you spring out to nab someone!.</span>")

	playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
	remove_cloaking_source(species)

	if(prob(90) && src.make_grab(src, T, GRAB_NAB_SPECIAL))
		T.Weaken(rand(1,3))
		visible_message("<span class='danger'>\The [src] suddenly lunges out and grabs \the [T]!</span>")
		LAssailant = weakref(src)

		src.do_attack_animation(T)
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		return 1

	else
		visible_message("<span class='danger'>\The [src] suddenly lunges out, almost grabbing \the [T]!</span>")

/mob/living/carbon/human/proc/active_camo()
	set category = "Abilities"
	set name = "Active Camo"
	set desc = "Camouflage yourself"

	if(is_cloaked_by(species))
		remove_cloaking_source(species)
	else
		add_cloaking_source(species)
		apply_effect(2, STUN, 0)

/mob/living/carbon/human/proc/switch_stance()
	set category = "Abilities"
	set name = "Switch Stance"
	set desc = "Toggle between your hunting and manipulation stance"

	if(stat) return

	to_chat(src, "<span class='notice'>You begin to adjust the fluids in your arms, dropping everything and getting ready to swap which set you're using.</span>")
	var/hidden = is_cloaked()
	if(!hidden)
		visible_message("[src] shifts \his arms.")

	if(l_hand) unEquip(l_hand)
	if(r_hand) unEquip(r_hand)

	if(do_after(src, 30))
		hidden = is_cloaked()
		pulling_punches = !pulling_punches
		nabbing = !pulling_punches

		if(pulling_punches)
			current_grab_type = all_grabobjects[GRAB_NORMAL]
			to_chat(src, "<span class='notice'>You relax your hunting arms, lowering the pressure and folding them tight to your thorax.\
			You reach out with your manipulation arms, ready to use complex items.</span>")
			if(!hidden)
				visible_message("<span class='notice'>[src] seems to relax as \he folds \his massive curved arms to \his thorax and reaches out \
				with \his small handlike limbs.</span>")
		else
			current_grab_type = all_grabobjects[GRAB_NAB]
			to_chat(src, "<span class='notice'>You pull in your manipulation arms, dropping any items and unfolding your massive hunting arms in preparation of grabbing prey.</span>")
			if(!hidden)
				visible_message("<span class='warning'>[src] tenses as \he brings \his smaller arms in close to \his body. \His two massive spiked arms reach \
				out. \He looks ready to attack.</span>")
	else
		to_chat(src, "<span class='notice'>You stop adjusting your arms and don't switch between them.</span>")

/mob/living/carbon/human/proc/change_colour()
	set category = "Abilities"
	set name = "Change Colour"
	set desc = "Choose the colour of your skin."

	var/new_skin = input(usr, "Choose your new skin colour: ", "Change Colour", rgb(r_skin, g_skin, b_skin)) as color|null
	change_skin_color(hex2num(copytext(new_skin, 2, 4)), hex2num(copytext(new_skin, 4, 6)), hex2num(copytext(new_skin, 6, 8)))

/mob/living/carbon/human/proc/threat_display()
	set category = "Abilities"
	set name = "Threat Display"
	set desc = "Toggle between scary or not."

	if(stat)
		to_chat(src, "<span class='warning'>You can't do a threat display in your current state.</span>")
		return

	switch(skin_state)
		if(SKIN_NORMAL)
			if(pulling_punches)
				to_chat(src, "<span class='warning'>You must be in your hunting stance to do a threat display.</span>")
				return
			var/message = alert("Would you like to show a scary message?",,"Cancel","Yes", "No")
			switch(message)
				if("Yes")
					visible_message("<span class='warning'>[src]'s skin shifts to a deep red colour with dark chevrons running down in an almost hypnotic \
						pattern. Standing tall, \he strikes, sharp spikes aimed at those threatening \him, claws whooshing through the air past them.</span>")
				if("Cancel")
					return
			playsound(src, 'sound/effects/angrybug.ogg', 60, 0)
			skin_state = SKIN_THREAT
			spawn(100)
				if(skin_state == SKIN_THREAT)
					skin_state = SKIN_NORMAL
					update_skin(1)
		if(SKIN_THREAT)
			skin_state = SKIN_NORMAL
	update_skin(1)

