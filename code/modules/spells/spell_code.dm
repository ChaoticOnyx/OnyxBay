/datum/spell
	var/name = "Spell"
	var/desc = "A spell"
	var/feedback = "" //what gets sent if this spell gets chosen by the spellbook.
	var/panel = "Spells"//What panel the proc holder needs to go on.

	var/icon = 'icons/mob/screen_spells.dmi'
	// Name of the icon used in generating the spell hud object
	var/icon_state = "fullblock"

	var/school = "evocation" //not relevant at now, but may be important later if there are changes to how spells work. the ones I used for now will probably be changed... maybe spell presets? lacking flexibility but with some other benefit?
	/*Spell schools as follows:
	Racial - Only tagged to spells gained for being a certain race
	Conjuration - Creating an object or transporting it.
	Transmutation - Modifying an object or transforming it.
	Illusion - Altering perception or thought.
	*/
	var/charge_type = SP_RECHARGE //can be recharge or charges, see charge_max and charge_counter descriptions; can also be based on the holder's vars now, use "holder_var" for that

	var/charge_max = 100 //recharge time in deciseconds if charge_type = SP_RECHARGE or starting charges if charge_type = SP_CHARGES
	var/charge_counter = 0 //can only cast spells if it equals recharge, ++ each decisecond if charge_type = SP_RECHARGE or -- each cast if charge_type = SP_CHARGES
	var/still_recharging_msg = SPAN_NOTICE("The spell is still recharging.")

	var/silenced = 0 //not a binary - the length of time we can't cast this for
	var/processing = FALSE //are we processing already? Mainly used so that silencing a spell doesn't call process() again. (and inadvertedly making it run twice as fast)

	var/holder_var_type = "bruteloss" //only used if charge_type equals to "holder_var"
	var/holder_var_amount = 20 //same. The amount adjusted with the mob's var when the spell is used

	var/spell_flags = NEEDSCLOTHES
	var/invocation = "HURP DURP"	//what is uttered when the wizard casts the spell
	var/invocation_type = SPI_NONE	//can be none, whisper, shout, and emote
	var/range = 7					//the range of the spell; outer radius for aoe spells
	var/message = ""				//whatever it says to the guy affected by it
	var/selection_type = "view"		//can be "range" or "view"
	var/atom/movable/holder			//where the spell is. Normally the user, can be an item
	var/duration = 0 //how long the spell lasts
	var/need_target = TRUE

	var/list/spell_levels = list(SP_SPEED = 0, SP_POWER = 0) //the current spell levels - total spell levels can be obtained by just adding the two values
	var/list/level_max = list(SP_TOTAL = 4, SP_SPEED = 4, SP_POWER = 0) //maximum possible levels in each category. Total does cover both.
	var/cooldown_reduc = 0		//If set, defines how much charge_max drops by every speed upgrade
	var/delay_reduc = 0
	var/cooldown_min = 0 //minimum possible cooldown for a charging spell

	var/overlay = 0
	var/overlay_icon = 'icons/obj/wizard.dmi'
	var/overlay_icon_state = "spell"
	var/overlay_lifespan = 0

	var/sparks_spread = 0
	var/sparks_amt = 0 //cropped at 10
	var/smoke_spread = 0 //1 - harmless, 2 - harmful
	var/smoke_amt = 0 //cropped at 10

	var/critfailchance = 0
	var/time_between_channels = 0 //Delay between casts
	var/number_of_channels = 1 //How many times can we channel?

	var/cast_delay = 1
	var/cast_sound = ""

	var/override_base = ""


	var/mob/living/deity/connected_god //Do we have this spell based off a boon from a god?
	var/obj/screen/connected_button

///////////////////////
///SETUP AND PROCESS///
///////////////////////

/datum/spell/New()
	..()

	//still_recharging_msg = "<span class='notice'>[name] is still recharging.</span>"
	charge_counter = charge_max

/datum/spell/proc/process()
	if(processing)
		return
	processing = TRUE
	spawn(0)
		while(charge_counter < charge_max || silenced > 0)
			charge_counter = min(charge_max,charge_counter+1)
			silenced = max(0,silenced-1)
			sleep(1)
		if(connected_button)
			var/obj/screen/ability/spell/S = connected_button
			if(!istype(S))
				return
			S.update_charge(1)
		processing = FALSE
	return

/////////////////
/////CASTING/////
/////////////////

/datum/spell/proc/choose_targets(mob/user = usr) //depends on subtype - see targeted.dm, aoe_turf.dm, dumbfire.dm, or code in general folder
	return

/datum/spell/proc/perform(mob/user = usr, skipcharge = 0) //if recharge is started is important for the trigger spells
	if(!holder)
		holder = user //just in case
	if(!cast_check(skipcharge, user))
		return
	if(cast_delay && !spell_do_after(user, cast_delay))
		return
	var/list/targets = choose_targets(user)
	if(!check_valid_targets(targets) || !cast_check(skipcharge, user))
		return
	var/time = 0
	admin_attacker_log(user, "attempted to cast the spell [name]")
	do
		time++
		if(!check_valid_targets(targets)) //make sure we HAVE something
			break
		if(cast_check(1,user, targets)) //we check again, otherwise you can choose a target and then wait for when you are no longer able to cast (I.E. Incapacitated) to use it.
			invocation(user, targets)
			if(connected_god && !connected_god.take_charge(user, max(1, charge_max/10)))
				break
			take_charge(user, skipcharge)
			before_cast(targets) //applies any overlays and effects
			if(prob(critfailchance))
				critfail(targets, user)
			else
				cast(targets, user, time)
			after_cast(targets) //generates the sparks, smoke, target messages etc.
		else
			break
	while(time != number_of_channels && do_after(user, time_between_channels, incapacitation_flags = INCAPACITATION_KNOCKOUT|INCAPACITATION_FORCELYING|INCAPACITATION_STUNNED, same_direction=1))
	after_spell(targets, user, time) //When we are done with the spell completely.



/datum/spell/proc/cast(list/targets, mob/user, channel_duration) //the actual meat of the spell
	return

/datum/spell/proc/critfail(list/targets, mob/user) //the wizman has fucked up somehow
	return

/datum/spell/proc/after_spell(list/targets, mob/user, channel_duration) //After everything else is done.
	return

/datum/spell/proc/adjust_var(mob/living/target = usr, type, amount) //handles the adjustment of the var when the spell is used. has some hardcoded types
	switch(type)
		if("bruteloss")
			target.adjustBruteLoss(amount)
		if("fireloss")
			target.adjustFireLoss(amount)
		if("toxloss")
			target.adjustToxLoss(amount)
		if("oxyloss")
			target.adjustOxyLoss(amount)
		if("brainloss")
			target.adjustBrainLoss(amount)
		if("stunned")
			target.AdjustStunned(amount)
		if("weakened")
			target.AdjustWeakened(amount)
		if("paralysis")
			target.AdjustParalysis(amount)
		else
			target.vars[type] += amount //I bear no responsibility for the runtimes that'll happen if you try to adjust non-numeric or even non-existant vars
	return

///////////////////////////
/////CASTING WRAPPERS//////
///////////////////////////

/datum/spell/proc/before_cast(list/targets)
	for(var/atom/target in targets)
		if(overlay)
			var/location
			if(istype(target,/mob/living))
				location = target.loc
			else if(istype(target,/turf))
				location = target
			var/obj/effect/overlay/spell = new /obj/effect/overlay(location)
			spell.icon = overlay_icon
			spell.icon_state = overlay_icon_state
			spell.anchored = 1
			spell.set_density(0)
			spawn(overlay_lifespan)
				qdel(spell)

/datum/spell/proc/after_cast(list/targets)
	if(cast_sound)
		playsound(holder, cast_sound, 50, 1)
	for(var/atom/target in targets)
		var/location = get_turf(target)
		if(istype(target,/mob/living) && message)
			to_chat(target, text("[message]"))
		if(sparks_spread)
			var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
			sparks.set_up(sparks_amt, 0, location) //no idea what the 0 is
			sparks.start()
		if(smoke_spread)
			if(smoke_spread == 1)
				var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
				smoke.set_up(smoke_amt, 0, location) //no idea what the 0 is
				smoke.start()
			else if(smoke_spread == 2)
				var/datum/effect/effect/system/smoke_spread/bad/smoke = new /datum/effect/effect/system/smoke_spread/bad()
				smoke.set_up(smoke_amt, 0, location) //no idea what the 0 is
				smoke.start()

/////////////////////
////CASTING TOOLS////
/////////////////////
/*Checkers, cost takers, message makers, etc*/

/datum/spell/proc/cast_check(skipcharge = 0,mob/user = usr, list/targets) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	if(silenced > 0)
		return FALSE

	if(!(src in user.mind.learned_spells) && holder == user && !(isanimal(user)))
		error("[user] utilized the spell '[src]' without having it.")
		to_chat(user, SPAN_WARNING("You shouldn't have this spell! Something's wrong."))
		return FALSE

	var/turf/user_turf = get_turf(user)
	if(!user_turf)
		to_chat(user, SPAN_WARNING("You cannot cast spells in null space!"))

	if((spell_flags & Z2NOCAST) && (user_turf.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_CENTCOM))) //Certain spells are not allowed on the centcomm zlevel
		return FALSE

	if(spell_flags & CONSTRUCT_CHECK)
		for(var/turf/T in range(holder, 1))
			if(findNullRod(T))
				return FALSE

	if(istype(user, /mob/living/simple_animal) && holder == user)
		var/mob/living/simple_animal/SA = user
		if(SA.purge)
			to_chat(SA, SPAN_WARNING("The nullrod's power interferes with your own!"))
			return FALSE

	if(!src.check_charge(skipcharge, user)) //sees if we can cast based on charges alone
		return FALSE

	if(!(spell_flags & GHOSTCAST) && holder == user)
		if(user.stat && !(spell_flags & STATALLOWED))
			to_chat(usr, "Not when you're incapacitated.")
			return FALSE

		if(ishuman(user) && !(invocation_type in list(SPI_EMOTE, SPI_NONE)))
			if(user.is_muzzled())
				to_chat(user, "Mmmf mrrfff!")
				return FALSE

	var/datum/spell/noclothes/spell = locate() in user.mind.learned_spells
	if((spell_flags & NEEDSCLOTHES) && !(spell && istype(spell)) && holder == user)//clothes check
		if(!user.wearing_wiz_garb())
			return FALSE

	if(istype(user.loc, /obj/effect/dummy/spell_jaunt))
		if(!istype(src, /datum/spell/targeted/ethereal_jaunt))
			to_chat(user, SPAN_WARNING("You cannot cast spells in this form"))
			return FALSE

	return TRUE

/datum/spell/proc/check_charge(skipcharge, mob/user)
	if(!skipcharge)
		switch(charge_type)
			if(SP_RECHARGE)
				if(charge_counter < charge_max)
					to_chat(user, still_recharging_msg)
					return FALSE
			if(SP_CHARGES)
				if(!charge_counter)
					to_chat(user, SPAN_NOTICE("[name] has no charges left."))
					return FALSE
	return TRUE

/datum/spell/proc/take_charge(mob/user = user, skipcharge)
	if(!skipcharge)
		switch(charge_type)
			if(SP_RECHARGE)
				charge_counter = 0 //doesn't start recharging until the targets selecting ends
				src.process()
				return TRUE
			if(SP_CHARGES)
				charge_counter-- //returns the charge if the targets selecting fails
				return TRUE
			if(SP_HOLDVAR)
				adjust_var(user, holder_var_type, holder_var_amount)
				return TRUE
		return FALSE
	return TRUE

/datum/spell/proc/check_valid_targets(list/targets)
	if(!need_target)
		return TRUE
	if(!targets)
		return FALSE
	if(!islist(targets))
		targets = list(targets)
	else if(!targets.len)
		return FALSE

	var/list/valid_targets = view_or_range(range, holder, selection_type)
	for(var/target in targets)
		if(!(target in valid_targets))
			return FALSE
	return TRUE

/datum/spell/proc/invocation(mob/user = usr, list/targets) // spelling the spell out and setting it on recharge/reducing charges amount

	switch(invocation_type)
		if(SPI_SHOUT)
			if(prob(50))//Auto-mute? Fuck that noise
				user.say(invocation)
			else
				user.say(replacetext(invocation," ","`"))
		if(SPI_WHISPER)
			if(prob(50))
				user.whisper(invocation)
			else
				user.whisper(replacetext(invocation," ","`"))
		if(SPI_EMOTE)
			user.custom_emote(VISIBLE_MESSAGE, invocation)

/////////////////////
///UPGRADING PROCS///
/////////////////////

/datum/spell/proc/can_improve(upgrade_type)
	if(level_max[SP_TOTAL] <= ( spell_levels[SP_SPEED] + spell_levels[SP_POWER] )) //too many levels, can't do it
		return FALSE

	if(upgrade_type && spell_levels[upgrade_type] >= level_max[upgrade_type])
		return FALSE

	return TRUE

/datum/spell/proc/empower_spell()
	if(!can_improve(SP_POWER))
		return FALSE

	spell_levels[SP_POWER]++

	return TRUE

/datum/spell/proc/quicken_spell()
	if(!can_improve(SP_SPEED))
		return FALSE

	spell_levels[SP_SPEED]++

	if(delay_reduc && cast_delay)
		cast_delay = max(0, cast_delay - delay_reduc)
	else if(cast_delay)
		cast_delay = round( max(0, initial(cast_delay) * ((level_max[SP_SPEED] - spell_levels[SP_SPEED]) / level_max[SP_SPEED] ) ) )

	if(charge_type == SP_RECHARGE)
		if(cooldown_reduc)
			charge_max = max(cooldown_min, charge_max - cooldown_reduc)
		else
			charge_max = round( max(cooldown_min, initial(charge_max) * ((level_max[SP_SPEED] - spell_levels[SP_SPEED]) / level_max[SP_SPEED] ) ) ) //the fraction of the way you are to max speed levels is the fraction you lose
	if(charge_max < charge_counter)
		charge_counter = charge_max

	var/temp = ""
	name = initial(name)
	switch(level_max[SP_SPEED] - spell_levels[SP_SPEED])
		if(3)
			temp = "You have improved [name] into Efficient [name]."
			name = "Efficient [name]"
		if(2)
			temp = "You have improved [name] into Quickened [name]."
			name = "Quickened [name]"
		if(1)
			temp = "You have improved [name] into Free [name]."
			name = "Free [name]"
		if(0)
			temp = "You have improved [name] into Instant [name]."
			name = "Instant [name]"

	return temp

/datum/spell/proc/spell_do_after(mob/user as mob, delay as num, numticks = 5)
	if(!user || isnull(user))
		return FALSE

	var/incap_flags = INCAPACITATION_STUNNED
	if(!(spell_flags & (STATALLOWED|GHOSTCAST)))
		incap_flags |= INCAPACITATION_KNOCKOUT

	return do_after(user,delay, incapacitation_flags = incap_flags)

/datum/spell/proc/set_connected_god(mob/living/deity/god)
	connected_god = god
	return

/datum/spell/proc/to_list()
	var/list/data = list(
		"name"        = name,
		"description" = desc,
		"school"      = school,
		"charge_type" = charge_type,
		"charge_max"  = charge_max,
		"flags"       = list(
			"needs_clothes" = spell_flags & NEEDSCLOTHES,
			"needs_human"   = spell_flags & NEEDSHUMAN,
			"include_user"  = spell_flags & INCLUDEUSER,
			"selectable"    = spell_flags & SELECTABLE,
			"no_button"     = spell_flags & NO_BUTTON
		),
		"range"      = range,
		"duration"   = duration,
		"max_levels" = list(
			"total" = level_max["total"],
			"power" = level_max["power"],
			"speed" = level_max["speed"]
		)
	)

	return data
