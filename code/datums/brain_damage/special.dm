//Brain traumas that are rare and/or somewhat beneficial;
//they are the easiest to cure, which means that if you want
//to keep them, you can't cure your other traumas
/datum/brain_trauma/special
	abstract_type = /datum/brain_trauma/special

/datum/brain_trauma/special/godwoken
	name = "Godwoken Syndrome"
	desc = "Patient occasionally and uncontrollably channels an eldritch god when speaking."
	scan_desc = "god delusion"
	gain_text = SPAN_NOTICE("You feel a higher power inside your mind...")
	lose_text = SPAN_WARNING("The divine presence leaves your head, no longer interested.")

/datum/brain_trauma/special/godwoken/on_life(seconds_per_tick, times_fired)
	..()
	if(SPT_PROB(2, seconds_per_tick))
		if(prob(33) && (owner.IsStun() || owner.IsParalyzed() || owner.IsUnconscious()))
			speak("unstun", TRUE)
		else if(prob(60) && owner.health <= owner.crit_threshold)
			speak("heal", TRUE)
		else if(prob(30) && owner.combat_mode)
			speak("aggressive")
		else
			speak("neutral", prob(25))

/datum/brain_trauma/special/godwoken/on_gain()
	ADD_TRAIT(owner, TRAIT_HOLY)
	..()

/datum/brain_trauma/special/godwoken/on_lose()
	REMOVE_TRAIT(owner, TRAIT_HOLY)
	..()

/datum/brain_trauma/special/godwoken/proc/speak(type, include_owner = FALSE)
	var/message
	switch(type)
		if("unstun")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_unstun")
		if("heal")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_heal")
		if("neutral")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_neutral")
		if("aggressive")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_aggressive")
		else
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_neutral")

	playsound(get_turf(owner), 'sound/magic/clockwork/invoke_general.ogg', 200, TRUE, 5)
	voice_of_god(message, owner, list("colossus","yell"), 2.5, include_owner, name, TRUE)

/datum/brain_trauma/special/bluespace_prophet
	name = "Bluespace Prophecy"
	desc = "Patient can sense the bob and weave of bluespace around them, showing them passageways no one else can see."
	scan_desc = "bluespace attunement"
	gain_text = SPAN_NOTICE("You feel the bluespace pulsing around you...")
	lose_text = SPAN_WARNING("The faint pulsing of bluespace fades into silence.")
	/// Cooldown so we can't teleport literally everywhere on a whim
	COOLDOWN_DECLARE(portal_cooldown)

/datum/brain_trauma/special/bluespace_prophet/on_life(seconds_per_tick, times_fired)
	if(!COOLDOWN_FINISHED(src, portal_cooldown))
		return

	COOLDOWN_START(src, portal_cooldown, 10 SECONDS)
	var/list/turf/possible_turfs = list()
	for(var/turf/T as anything in RANGE_TURFS(8, owner))
		if(T.density)
			continue

		var/clear = TRUE
		for(var/obj/O in T)
			if(O.density)
				clear = FALSE
				break
		if(clear)
			possible_turfs += T

	if(!LAZYLEN(possible_turfs))
		return

	var/turf/first_turf = pick(possible_turfs)
	if(!first_turf)
		return

	possible_turfs -= (possible_turfs & range(first_turf, 3))

	var/turf/second_turf = pick(possible_turfs)
	if(!second_turf)
		return

	var/obj/effect/client_image_holder/bluespace_stream/first = new(first_turf, owner)
	var/obj/effect/client_image_holder/bluespace_stream/second = new(second_turf, owner)

	first.linked_to = second
	second.linked_to = first

/obj/effect/client_image_holder/bluespace_stream
	name = "bluespace stream"
	desc = "You see a hidden pathway through bluespace..."
	image_icon = 'icons/effects/effects.dmi'
	image_state = "bluestream"
	image_layer = ABOVE_MOB_LAYER
	image_plane = GAME_PLANE_UPPER
	var/obj/effect/client_image_holder/bluespace_stream/linked_to

/obj/effect/client_image_holder/bluespace_stream/Initialize(mapload, list/mobs_which_see_us)
	. = ..()
	QDEL_IN(src, 30 SECONDS)

/obj/effect/client_image_holder/bluespace_stream/Destroy()
	if(!QDELETED(linked_to))
		qdel(linked_to)
	linked_to = null
	return ..()

/obj/effect/client_image_holder/bluespace_stream/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!(user in who_sees_us) || !linked_to)
		return

	var/slip_in_message = pick("slides sideways in an odd way, and disappears", "jumps into an unseen dimension",\
		"sticks one leg straight out, wiggles [user.p_their()] foot, and is suddenly gone", "stops, then blinks out of reality", \
		"is pulled into an invisible vortex, vanishing from sight")
	var/slip_out_message = pick("silently fades in", "leaps out of thin air","appears", "walks out of an invisible doorway",\
		"slides out of a fold in spacetime")

	to_chat(user, SPAN_NOTICE("You try to align with the bluespace stream..."))
	if(!do_after(user, 2 SECONDS, target = src))
		return

	var/turf/source_turf = get_turf(src)
	var/turf/destination_turf = get_turf(linked_to)

	new /obj/effect/temp_visual/bluespace_fissure(source_turf)
	new /obj/effect/temp_visual/bluespace_fissure(destination_turf)

	user.visible_message(SPAN_WARNING("[user] [slip_in_message]."), ignored_mobs = user)

	if(do_teleport(user, destination_turf, no_effects = TRUE))
		user.visible_message(SPAN_WARNING("[user] [slip_out_message]."), SPAN_NOTICE("...and find your way to the other side."))
	else
		user.visible_message(SPAN_WARNING("[user] [slip_out_message], ending up exactly where they left."), SPAN_NOTICE("...and find yourself where you started?"))


/obj/effect/client_image_holder/bluespace_stream/attack_tk(mob/user)
	to_chat(user, SPAN_WARNING("\The [src] actively rejects your mind, and the bluespace energies surrounding it disrupt your telekinesis!"))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/brain_trauma/special/quantum_alignment
	name = "Quantum Alignment"
	desc = "Patient is prone to frequent spontaneous quantum entanglement, against all odds, causing spatial anomalies."
	scan_desc = "quantum alignment"
	gain_text = SPAN_NOTICE("You feel faintly connected to everything around you...")
	lose_text = SPAN_WARNING("You no longer feel connected to your surroundings.")
	var/atom/linked_target = null
	var/linked = FALSE
	var/returning = FALSE
	/// Cooldown for snapbacks
	COOLDOWN_DECLARE(snapback_cooldown)

/datum/brain_trauma/special/quantum_alignment/on_life(seconds_per_tick, times_fired)
	if(linked)
		if(QDELETED(linked_target))
			linked_target = null
			linked = FALSE
			return
		if(!returning && COOLDOWN_FINISHED(src, snapback_cooldown))
			start_snapback()
		return
	if(SPT_PROB(2, seconds_per_tick))
		try_entangle()

/datum/brain_trauma/special/quantum_alignment/proc/try_entangle()
	//Check for pulled mobs
	if(ismob(owner.pulling))
		entangle(owner.pulling)
		return
	//Check for adjacent mobs
	for(var/mob/living/L in oview(1, owner))
		if(owner.Adjacent(L))
			entangle(L)
			return
	//Check for pulled objects
	if(isobj(owner.pulling))
		entangle(owner.pulling)
		return

	//Check main hand
	var/obj/item/held_item = owner.get_active_held_item()
	if(held_item && !(HAS_TRAIT(held_item, TRAIT_NODROP)))
		entangle(held_item)
		return

	//Check off hand
	held_item = owner.get_inactive_held_item()
	if(held_item && !(HAS_TRAIT(held_item, TRAIT_NODROP)))
		entangle(held_item)
		return

	//Just entangle with the turf
	entangle(get_turf(owner))

/datum/brain_trauma/special/quantum_alignment/proc/entangle(atom/target)
	to_chat(owner, SPAN_NOTICE("You start feeling a strong sense of connection to [target]."))
	linked_target = target
	linked = TRUE
	COOLDOWN_START(src, snapback_cooldown, rand(45 SECONDS, 10 MINUTES))

/datum/brain_trauma/special/quantum_alignment/proc/start_snapback()
	if(QDELETED(linked_target))
		linked_target = null
		linked = FALSE
		return
	to_chat(owner, SPAN_WARNING("Your connection to [linked_target] suddenly feels extremely strong... you can feel it pulling you!"))
	owner.playsound_local(owner, 'sound/magic/lightning_chargeup.ogg', 75, FALSE)
	returning = TRUE
	addtimer(CALLBACK(src, .proc/snapback), 100)

/datum/brain_trauma/special/quantum_alignment/proc/snapback()
	returning = FALSE
	if(QDELETED(linked_target))
		to_chat(owner, SPAN_NOTICE("The connection fades abruptly, and the pull with it."))
		linked_target = null
		linked = FALSE
		return
	to_chat(owner, SPAN_WARNING("You're pulled through spacetime!"))
	do_teleport(owner, get_turf(linked_target), null, channel = TELEPORT_CHANNEL_QUANTUM)
	owner.playsound_local(owner, 'sound/magic/repulse.ogg', 100, FALSE)
	linked_target = null
	linked = FALSE

/datum/brain_trauma/special/psychotic_brawling
	name = "Violent Psychosis"
	desc = "Patient fights in unpredictable ways, ranging from helping his target to hitting them with brutal strength."
	scan_desc = "violent psychosis"
	gain_text = SPAN_WARNING("You feel unhinged...")
	lose_text = SPAN_NOTICE("You feel more balanced.")
	var/datum/martial_art/psychotic_brawling/psychotic_brawling

/datum/brain_trauma/special/psychotic_brawling/on_gain()
	..()
	psychotic_brawling = new(null)
	if(!psychotic_brawling.teach(owner, TRUE))
		to_chat(owner, SPAN_NOTICE("But your martial knowledge keeps you grounded."))
		qdel(src)

/datum/brain_trauma/special/psychotic_brawling/on_lose()
	..()
	psychotic_brawling.remove(owner)
	QDEL_NULL(psychotic_brawling)

/datum/brain_trauma/special/psychotic_brawling/bath_salts
	name = "Chemical Violent Psychosis"

/datum/brain_trauma/special/tenacity
	name = "Tenacity"
	desc = "Patient is psychologically unaffected by pain and injuries, and can remain standing far longer than a normal person."
	scan_desc = "traumatic neuropathy"
	gain_text = SPAN_WARNING("You suddenly stop feeling pain.")
	lose_text = SPAN_WARNING("You realize you can feel pain again.")

/datum/brain_trauma/special/tenacity/on_gain()
	ADD_TRAIT(owner,TRAIT_NOSOFTCRIT)
	ADD_TRAIT(owner,TRAIT_NOHARDCRIT)
	..()

/datum/brain_trauma/special/tenacity/on_lose()
	REMOVE_TRAIT(owner,TRAIT_NOSOFTCRIT)
	REMOVE_TRAIT(owner,TRAIT_NOHARDCRIT)
	..()

/datum/brain_trauma/special/death_whispers
	name = "Functional Cerebral Necrosis"
	desc = "Patient's brain is stuck in a functional near-death state, causing occasional moments of lucid hallucinations, which are often interpreted as the voices of the dead."
	scan_desc = "chronic functional necrosis"
	gain_text = SPAN_WARNING("You feel dead inside.")
	lose_text = SPAN_NOTICE("You feel alive again.")
	var/active = FALSE

/datum/brain_trauma/special/death_whispers/on_life()
	..()
	if(!active && prob(2))
		whispering()

/datum/brain_trauma/special/death_whispers/on_lose()
	if(active)
		cease_whispering()
	..()

/datum/brain_trauma/special/death_whispers/proc/whispering()
	ADD_TRAIT(owner, TRAIT_SIXTHSENSE)
	active = TRUE
	addtimer(CALLBACK(src, .proc/cease_whispering), rand(50, 300))

/datum/brain_trauma/special/death_whispers/proc/cease_whispering()
	REMOVE_TRAIT(owner, TRAIT_SIXTHSENSE)
	active = FALSE

/datum/brain_trauma/special/existential_crisis
	name = "Existential Crisis"
	desc = "Patient's hold on reality becomes faint, causing occasional bouts of non-existence."
	scan_desc = "existential crisis"
	gain_text = SPAN_WARNING("You feel less real.")
	lose_text = SPAN_NOTICE("You feel more substantial again.")
	var/obj/effect/abstract/sync_holder/veil/veil
	/// A cooldown to prevent constantly erratic dolphining through the fabric of reality
	COOLDOWN_DECLARE(crisis_cooldown)

/datum/brain_trauma/special/existential_crisis/on_life(seconds_per_tick, times_fired)
	..()
	if(!veil && COOLDOWN_FINISHED(src, crisis_cooldown) && SPT_PROB(1.5, seconds_per_tick))
		if(isturf(owner.loc))
			fade_out()

/datum/brain_trauma/special/existential_crisis/on_lose()
	if(veil)
		fade_in()
	..()

/datum/brain_trauma/special/existential_crisis/proc/fade_out()
	if(veil)
		return
	var/duration = rand(5 SECONDS, 45 SECONDS)
	veil = new(owner.drop_location())
	to_chat(owner, SPAN_WARNING("[pick(list(
			"Do you even exist?",
			"To be or not to be...",
			"Why exist?",
			"You simply fade away.",
			"You stop keeping it real.",
			"You stop thinking for a moment. Therefore you are not.",
		))]"))
	owner.forceMove(veil)
	COOLDOWN_START(src, crisis_cooldown, 1 MINUTES)
	addtimer(CALLBACK(src, .proc/fade_in), duration)

/datum/brain_trauma/special/existential_crisis/proc/fade_in()
	QDEL_NULL(veil)
	to_chat(owner, SPAN_NOTICE("You fade back into reality."))
	COOLDOWN_START(src, crisis_cooldown, 1 MINUTES)

//base sync holder is in desynchronizer.dm
/obj/effect/abstract/sync_holder/veil
	name = "non-existence"
	desc = "Existence is just a state of mind."

/datum/brain_trauma/special/beepsky
	name = "Criminal"
	desc = "Patient seems to be a criminal."
	scan_desc = "criminal mind"
	gain_text = SPAN_WARNING("Justice is coming for you.")
	lose_text = SPAN_NOTICE("You were absolved for your crimes.")
	random_gain = FALSE
	/// A ref to our fake beepsky image that we chase the owner with
	var/obj/effect/client_image_holder/securitron/beepsky

/datum/brain_trauma/special/beepsky/Destroy()
	QDEL_NULL(beepsky)
	return ..()

/datum/brain_trauma/special/beepsky/on_gain()
	create_securitron()
	return ..()

/datum/brain_trauma/special/beepsky/proc/create_securitron()
	QDEL_NULL(beepsky)
	var/turf/where = locate(owner.x + pick(-12, 12), owner.y + pick(-12, 12), owner.z)
	beepsky = new(where, owner)

/datum/brain_trauma/special/beepsky/on_lose()
	QDEL_NULL(beepsky)
	return ..()

/datum/brain_trauma/special/beepsky/on_life()
	if(QDELETED(beepsky) || !beepsky.loc || beepsky.z != owner.z)
		if(prob(30))
			create_securitron()
		else
			return

	if(get_dist(owner, beepsky) >= 10 && prob(20))
		create_securitron()

	if(owner.stat != CONSCIOUS)
		if(prob(20))
			owner.playsound_local(beepsky, 'sound/voice/beepsky/iamthelaw.ogg', 50)
		return

	if(get_dist(owner, beepsky) <= 1)
		owner.playsound_local(owner, 'sound/weapons/egloves.ogg', 50)
		owner.visible_message(SPAN_WARNING("[owner]'s body jerks as if it was shocked."), span_userdanger("You feel the fist of the LAW."))
		owner.adjustStaminaLoss(rand(40, 70))
		QDEL_NULL(beepsky)

	if(prob(20) && get_dist(owner, beepsky) <= 8)
		owner.playsound_local(beepsky, 'sound/voice/beepsky/criminal.ogg', 40)

/obj/effect/client_image_holder/securitron
	name = "Securitron"
	desc = "The LAW is coming."
	image_icon = 'icons/mob/silicon/aibots.dmi'
	image_state = "secbot-c"

/obj/effect/client_image_holder/securitron/Initialize(mapload)
	. = ..()
	name = pick("Officer Beepsky", "Officer Johnson", "Officer Pingsky")
	START_PROCESSING(SSfastprocess, src)

/obj/effect/client_image_holder/securitron/Destroy()
	STOP_PROCESSING(SSfastprocess,src)
	return ..()

/obj/effect/client_image_holder/securitron/process()
	if(prob(40))
		return

	var/mob/victim = pick(who_sees_us)
	forceMove(get_step_towards(src, victim))
	if(prob(5))
		var/beepskys_cry = "Level 10 infraction alert!"
		to_chat(victim, "[span_name("[name]")] exclaims, \"[span_robot("[beepskys_cry]")]")
		if(victim.client?.prefs.read_preference(/datum/preference/toggle/enable_runechat))
			victim.create_chat_message(src, raw_message = beepskys_cry, spans = list("robotic"))
