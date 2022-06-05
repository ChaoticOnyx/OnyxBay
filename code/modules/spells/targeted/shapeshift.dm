//basic transformation spell. Should work for most simple_animals

/datum/spell/targeted/shapeshift
	name = "Shapeshift"
	desc = "This spell transforms the target into something else for a short while."

	school = "transmutation"

	charge_type = SP_RECHARGE
	charge_max = 600

	duration = 0 //set to 0 for permanent.

	var/list/possible_transformations = list()
	var/list/newVars = list() //what the variables of the new created thing will be.

	cast_sound = 'sound/effects/weapons/energy/emitter2.ogg'
	var/revert_sound = 'sound/effects/weapons/energy/emitter.ogg' //the sound that plays when something gets turned back.
	var/share_damage = 1 //do we want the damage we take from our new form to move onto our real one? (Only counts for finite duration)
	var/drop_items = 1 //do we want to drop all our items when we transform?
	var/list/transformed_dudes = list() //Who we transformed. Transformed = Transformation. Both mobs.

/datum/spell/targeted/shapeshift/cast(list/targets, mob/user)
	for(var/mob/living/M in targets)
		if(M.stat == DEAD)
			to_chat(user, "[name] can only transform living targets.")
			continue
		if(M.buckled)
			M.buckled.unbuckle_mob()
		var/new_mob = pick(possible_transformations)

		var/mob/living/trans = new new_mob(get_turf(M))
		for(var/varName in newVars) //stolen shamelessly from Conjure
			if(varName in trans.vars)
				trans.vars[varName] = newVars[varName]

		trans.SetName("[trans.name] ([M])")
		if(istype(M,/mob/living/carbon/human) && drop_items)
			for(var/obj/item/I in M.contents)
				if(istype(I,/obj/item/organ))
					continue
				M.drop_from_inventory(I)
		if(M.mind)
			M.mind.transfer_to(trans)
		else
			trans.key = M.key
		var/atom/movable/overlay/effect = new /atom/movable/overlay(get_turf(M))
		effect.set_density(0)
		effect.anchored = 1
		effect.icon = 'icons/effects/effects.dmi'
		effect.layer = 3
		flick("summoning",effect)
		spawn(10)
			qdel(effect)
		M.forceMove(trans) //move inside the new dude to hide him.
		M.status_flags |= GODMODE //dont want him to die or breathe or do ANYTHING
		transformed_dudes[trans] = M
		register_signal(trans, SIGNAL_MOB_DEATH, /datum/spell/targeted/shapeshift/proc/stop_transformation)
		register_signal(trans, SIGNAL_QDELETING, /datum/spell/targeted/shapeshift/proc/stop_transformation)
		register_signal(M, SIGNAL_QDELETING, /datum/spell/targeted/shapeshift/proc/destroyed_transformer)
		if(duration)
			spawn(duration)
				stop_transformation(trans)

/datum/spell/targeted/shapeshift/proc/destroyed_transformer(mob/target) //Juuuuust in case
	var/mob/current = transformed_dudes[target]
	to_chat(current, "<span class='danger'>You suddenly feel as if this transformation has become permanent...</span>")
	remove_target(target)

/datum/spell/targeted/shapeshift/proc/stop_transformation(mob/living/target)
	var/mob/living/transformer = transformed_dudes[target]
	if(!transformer)
		return
	transformer.status_flags &= ~GODMODE
	if(share_damage)
		var/ratio = target.health/target.maxHealth
		var/damage = transformer.maxHealth - round(transformer.maxHealth*(ratio))
		for(var/i in 1 to ceil(damage/10))
			transformer.adjustBruteLoss(10)
	if(target.mind)
		target.mind.transfer_to(transformer)
	else
		transformer.key = target.key
	playsound(target, revert_sound, 50, 1)
	transformer.forceMove(get_turf(target))
	remove_target(target)
	qdel(target)

/datum/spell/targeted/shapeshift/proc/remove_target(mob/living/target)
	var/mob/current = transformed_dudes[target]
	unregister_signal(target, SIGNAL_QDELETING)
	unregister_signal(current, SIGNAL_MOB_DEATH)
	unregister_signal(current, SIGNAL_QDELETING)
	transformed_dudes[target] = null
	transformed_dudes -= target

/datum/spell/targeted/shapeshift/baleful_polymorph
	name = "Baleful Polymorth"
	desc = "This spell transforms its target into a small, furry animal."
	feedback = "BP"
	critfailchance = 10
	possible_transformations = list(
	/mob/living/simple_animal/lizard,
	/mob/living/simple_animal/mouse,
	/mob/living/simple_animal/corgi,
	/mob/living/simple_animal/parrot,
	)

	var/list/basic_transformations =  list(
	/mob/living/simple_animal/lizard,
	/mob/living/simple_animal/mouse,
	/mob/living/simple_animal/corgi,
	/mob/living/simple_animal/parrot,
	)

	share_damage = 0
	invocation = "Yo'balada!"
	invocation_type = SPI_SHOUT
	spell_flags = NEEDSCLOTHES | SELECTABLE
	range = 3
	duration = 150 //15 seconds.
	cooldown_min = 200 //20 seconds

	level_max = list(SP_TOTAL = 2, SP_SPEED = 2, SP_POWER = 2)

	newVars = list("health" = 50, "maxHealth" = 50)

	icon_state = "wiz_poly"

/datum/spell/targeted/shapeshift/baleful_polymorph/critfail(list/targets, mob/user)
	possible_transformations = list(
	/mob/living/simple_animal/hostile/giant_spider,
	/mob/living/simple_animal/hostile/asteroid/goliath/alpha
	)
	cast(targets, user)
	possible_transformations = basic_transformations

/datum/spell/targeted/shapeshift/baleful_polymorph/empower_spell()
	if(!..())
		return 0

	duration += 100

	return "Your target will now stay in their polymorphed form for [duration/10] seconds."

/datum/spell/targeted/shapeshift/avian
	name = "Polymorph"
	desc = "This spell transforms the wizard into the common parrot."
	feedback = "AV"
	possible_transformations = list(/mob/living/simple_animal/parrot)

	drop_items = 0
	share_damage = 0
	invocation = "Poli'crakata!"
	invocation_type = SPI_SHOUT
	spell_flags = INCLUDEUSER
	range = 0
	duration = 150
	charge_max = 600
	cooldown_min = 300
	level_max = list(SP_TOTAL = 1, SP_SPEED = 1, SP_POWER = 0)
	icon_state = "wiz_parrot"

/datum/spell/targeted/shapeshift/corrupt_form
	name = "Corrupt Form"
	desc = "This spell shapes the wizard into a terrible, terrible beast."
	feedback = "CF"
	possible_transformations = list(/mob/living/simple_animal/hostile/faithless)

	invocation = "mutters something dark and twisted as their form begins to twist..."
	invocation_type = SPI_EMOTE
	spell_flags = INCLUDEUSER
	range = 0
	duration = 150
	charge_max = 1200
	cooldown_min = 600

	drop_items = 0
	share_damage = 0
	level_max = list(SP_TOTAL = 3, SP_SPEED = 1, SP_POWER = 2)

	newVars = list("name" = "corrupted soul")

	icon_state = "wiz_corrupt"

/datum/spell/targeted/shapeshift/corrupt_form/empower_spell()
	if(!..())
		return 0

	switch(spell_levels[SP_POWER])
		if(1)
			duration *= 2
			return "You will now stay corrupted for [duration/10] seconds."
		if(2)
			newVars = list("name" = "\proper corruption incarnate",
						"melee_damage_upper" = 80,
						"resistance" = 15,
						"health" = 200,
						"maxHealth" = 200)
			duration = 0
			return "You revel in the corruption. There is no turning back."
