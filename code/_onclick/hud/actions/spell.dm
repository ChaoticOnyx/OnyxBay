/datum/action/cooldown/spell
	name = "Spell"
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_spell"
	button_icon_state = "spell_default"
	overlay_icon_state = "bg_spell_border"
	active_overlay_icon_state = "bg_spell_border_active_blue"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	action_type = AB_SPELL

	/// The sound played on cast.
	var/sound = null
	/// Determines cooldown reduction per rank of the spell if it uses spell rank system
	var/cooldown_reduction_per_rank = 0 SECONDS
	/// What is uttered when the user casts the spell
	var/invocation_third_person
	/// What is shown in chat when the user casts the spell, only matters for INVOCATION_EMOTE
	var/invocation_first_person
	/// What type of invocation the spell is.
	/// Can be "none", "whisper", "shout", "emote"
	var/invocation_type = SPI_NONE
	/// The current spell level, if taken multiple times by a wizard
	var/spell_level = 1
	/// The max possible spell level
	var/spell_max_level = 1
	/// If set to a positive number, the spell will produce sparks when casted.
	var/sparks_amt = 0
	/// The typepath of the smoke to create on cast.
	var/smoke_type
	/// The amount of smoke to create on cast. This is a range, so a value of 5 will create enough smoke to cover everything within 5 steps.
	var/smoke_amt = 0
	/// The typepath of particles to create on cast
	var/particles_path
	/// How far can you cast this
	var/cast_range = 7

/// Actual cast chain of the spell, do not override or your ballsack will fall off.
/datum/action/cooldown/spell/Activate(atom/cast_on)
	SHOULD_NOT_OVERRIDE(TRUE)

	// Pre-casting of the spell
	// Pre-cast is the very last chance for a spell to cancel
	// Stuff like target input can go here.
	var/precast_result = before_cast(cast_on)
	if(!precast_result)
		return FALSE

	// Invoccations, sounds and effects are implemented before actual cast.
	spell_feedback()

	// Now we actually cast our spell.
	cast(cast_on)

	// The entire spell is done, start the actual cooldown at its set duration
	StartCooldown()

	// For post-cast effects, sounds e.t.c.
	after_cast(cast_on)
	return TRUE

/// Actions done before spell is called.
/datum/action/cooldown/spell/proc/before_cast(atom/cast_on)
	if(!is_valid_target(cast_on))
		return FALSE

	if(owner && get_dist(get_turf(owner), get_turf(cast_on)) > cast_range)
		cast_on.show_splash_text(owner, "too far away!", SPAN_DANGER("Out of \the [src] range!"))
		return FALSE

	return TRUE

/// Checks if the target is valid. Returns TRUE or FALSE.
/datum/action/cooldown/spell/proc/is_valid_target(atom/cast_on)
	return TRUE

/// Provides feedback after a spell cast occurs, in the form of a cast sound and/or invocation
/datum/action/cooldown/spell/proc/spell_feedback()
	if(!owner)
		return

	if(invocation_type != SPI_NONE)
		invocation()

	if(sound)
		playsound(get_turf(owner), sound, 50, TRUE)

/// The invocation that accompanies the spell, called from spell_feedback() before cast().
/datum/action/cooldown/spell/proc/invocation()
	switch(invocation_type)
		if(SPI_SHOUT)
			if(prob(50))
				owner.say(invocation_third_person)
			else
				owner.say(replacetext(invocation_third_person," ","`"))

		if(SPI_WHISPER)
			if(prob(50))
				owner.whisper(invocation_third_person)
			else
				owner.whisper(replacetext(invocation_third_person," ","`"))

		if(SPI_EMOTE)
			owner.visible_message(invocation_third_person, invocation_first_person)

/// Main effect of the spell.
/datum/action/cooldown/spell/proc/cast(atom/cast_on)
	pass()

/// Actions done after cast() is finished.
/datum/action/cooldown/spell/proc/after_cast(atom/cast_on)
	SHOULD_CALL_PARENT(TRUE)
	if(!owner)
		return

	if(sparks_amt)
		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(sparks_amt, 0, get_turf(cast_on)) //no idea what the 0 is
		sparks.start()

	if(ispath(smoke_type))
		var/datum/effect/effect/system/smoke_spread/smoke = new smoke_type()
		smoke.set_up(smoke_amt, 0, cast_on)
		smoke.start()
