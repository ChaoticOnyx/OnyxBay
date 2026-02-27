/datum/mob_ai
	var/mob/living/simple_animal/holder // contains the connected mob
	var/area/safe_area

/datum/mob_ai/Destroy()
	holder = null
	safe_area = null
	return ..()

/datum/mob_ai/proc/attempt_escape()
	if(holder.buckled && holder.can_escape)
		if(istype(holder.buckled, /obj/effect/energy_net))
			var/obj/effect/energy_net/Net = holder.buckled
			Net.escape_net(holder)
		else if(prob(50))
			holder.escape(holder, holder.buckled)
		else if(prob(50))
			holder.visible_message(SPAN("warning", "\The [holder] struggles against \the [holder.buckled]!"))

/datum/mob_ai/proc/process_moving()
	//Movement
	if(!holder.client && !holder.stop_automated_movement && holder.wander && !holder.anchored)
		if(isturf(holder.loc) && !holder.resting && !holder.buckled)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			holder.turns_since_move++
			if(holder.turns_since_move >= holder.turns_per_move)
				if(!(holder.stop_automated_movement_when_pulled && holder.pulledby)) //Some animals don't move when pulled
					do_move()

/datum/mob_ai/proc/do_move()
	var/d = pick_wander_dir()
	if(d)
		holder.SelfMove(d)

/datum/mob_ai/proc/pick_wander_dir()
	var/list/dirs_to_go = GLOB.alldirs.Copy()
	while(length(dirs_to_go))
		. = pick(dirs_to_go)
		dirs_to_go.Remove(.)
		if(!safe_area) // we don't have safe_area, free moving allowed.
			break
		var/turf/T = get_step(holder, .)
		if(T?.loc == safe_area)
			break
		. = null

/datum/mob_ai/proc/process_speaking()
	//Speaking
	if(!holder.client && holder.speak_chance)
		if(rand(0,200) < holder.speak_chance)
			var/action = pick(
				holder.speak.len;      "speak",
				holder.emote_hear.len; "emote_hear",
				holder.emote_see.len;  "emote_see"
				)

			switch(action)
				if("speak")
					holder.say(util_pick_weight(holder.speak))
				if("emote_hear")
					holder.audible_emote("[util_pick_weight(holder.emote_hear)].")
				if("emote_see")
					holder.visible_emote("[util_pick_weight(holder.emote_see)].")

/datum/mob_ai/proc/process_special_actions()
	return

/datum/mob_ai/proc/listen(mob/speaker, text)
	return


/datum/mob_ai/proc/return_mob_friendness(mob/M)
	return M.faction == holder.faction
