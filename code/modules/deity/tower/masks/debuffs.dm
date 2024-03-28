
#define TICK_INTERVAL 20 SECONDS

/datum/modifier/deitymask_debuff
	hidden = TRUE
	// Since modifiers tick() every Life() proc when attached to a mob,
	// There is no need to add thinking.
	/// world.time when this ticked with effects
	var/last_ticked
	/// Interval between tick()
	var/tick_interval = TICK_INTERVAL

/datum/modifier/deitymask_debuff/tick()
	if(last_ticked + tick_interval <= world.time)
		return FALSE

	last_ticked = world.time
	return TRUE

/datum/modifier/deitymask_debuff/terror/tick()
	. = ..()
	if(!.)
		return

	if(prob(50))
		holder.Stun(2)

	if(prob(50) && iscarbon(holder))
		var/mob/living/carbon/user = holder
		user.adjust_hallucination(30, 100)

/datum/modifier/deitymask_debuff/vengeance/tick()
	. = ..()
	if(!.)
		return

	for(var/mob/living/M in view(src, 1))
		holder.a_intent_change(I_HURT)
		holder.ClickOn(M)
		break

	if(iscarbon(holder))
		var/mob/living/carbon/user = holder
		user.adjust_hallucination(30, 100)

/datum/modifier/deitymask_debuff/regret/tick()
	. = ..()
	if(!.)
		return

	if(prob(80))
		holder.emote("cry")

	holder.a_intent_change(I_DISARM)
	holder.Weaken(3)

#undef TICK_INTERVAL
