/datum/spell/targeted/ethereal_jaunt
	name = "Ethereal Jaunt"
	desc = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."
	feedback = "EJ"
	school = "transmutation"
	charge_max = 300
	spell_flags = Z2NOCAST | NEEDSCLOTHES | INCLUDEUSER
	invocation = "none"
	invocation_type = SPI_NONE
	range = 0
	max_targets = 1
	level_max = list(SP_TOTAL = 4, SP_SPEED = 3, SP_POWER = 3)
	cooldown_min = 10 SECONDS
	duration = 5 SECONDS
	need_target = FALSE
	icon_state = "wiz_jaunt"
	var/reappear_duration = 5 //equal to number of animation frames
	var/obj/effect/dummy/spell_jaunt/jaunt_holder
	var/atom/movable/fake_overlay/animation
	var/start_reappear_timer

/datum/spell/targeted/ethereal_jaunt/cast(list/targets, mob/user) //magnets, so mostly hardcoded
	for(var/mob/living/target in targets)
		if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(target))
			continue
		if(target in jaunt_holder?.contents)
			if(start_reappear_timer)
				deltimer(start_reappear_timer)
			start_reappear_timer = addtimer(CALLBACK(src, nameof(.proc/start_reappear), target), duration, TIMER_STOPPABLE)
			break
		if(target.buckled)
			target.buckled.unbuckle_mob()
		if(istype(user.loc, /obj/machinery/atmospherics/unary/cryo_cell))
			var/obj/machinery/atmospherics/unary/cryo_cell/cell = user.loc
			cell.go_out()
		spawn(0)
			var/mobloc = get_turf(target.loc)
			jaunt_holder = new /obj/effect/dummy/spell_jaunt(mobloc)
			animation = new /atom/movable/fake_overlay(mobloc)
			animation.SetName("water")
			animation.set_density(FALSE)
			animation.anchored = TRUE
			animation.icon = 'icons/mob/mob.dmi'
			animation.layer = FLY_LAYER
			target.ExtinguishMob()
			if(target.buckled)
				target.buckled.unbuckle_mob()
			jaunt_disappear(animation, target)
			target.can_use_hands = FALSE
			jaunt_steam(mobloc)
			target.forceMove(jaunt_holder)
			start_reappear_timer = addtimer(CALLBACK(src, nameof(.proc/start_reappear), target), duration, TIMER_STOPPABLE)

/datum/spell/targeted/ethereal_jaunt/proc/start_reappear(mob/living/target)
	var/mob_loc = jaunt_holder.last_valid_turf
	jaunt_holder.reappearing = TRUE
	jaunt_steam(mob_loc)
	jaunt_reappear(animation, target)
	animation.forceMove(mob_loc)
	addtimer(CALLBACK(src, nameof(.proc/reappear), mob_loc, target), reappear_duration)

/datum/spell/targeted/ethereal_jaunt/proc/reappear(mob_loc, mob/living/target)
	if(!target.forceMove(mob_loc))
		for(var/direction in list(1,2,4,8,5,6,9,10))
			var/turf/T = get_step(mob_loc, direction)
			if(T && target.forceMove(T))
				break
	target.client.eye = target
	target.can_use_hands = TRUE
	QDEL_NULL(animation)
	QDEL_NULL(jaunt_holder)

/datum/spell/targeted/ethereal_jaunt/empower_spell()
	if(!..())
		return FALSE
	duration += 2 SECONDS

	return "[src] now lasts longer."

/datum/spell/targeted/ethereal_jaunt/proc/jaunt_disappear(atom/movable/fake_overlay/animation, mob/living/target)
	animation.icon_state = "liquify"
	flick("liquify", animation)

/datum/spell/targeted/ethereal_jaunt/proc/jaunt_reappear(atom/movable/fake_overlay/animation, mob/living/target)
	flick("reappear", animation)

/datum/spell/targeted/ethereal_jaunt/proc/jaunt_steam(mobloc)
	var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
	steam.set_up(10, 0, mobloc)
	steam.start()

/datum/spell/targeted/ethereal_jaunt/Destroy()
	if(jaunt_holder)
		var/turf/T = get_turf(jaunt_holder)
		for(var/mob/living/L in jaunt_holder)
			L.forceMove(T)
	QDEL_NULL(jaunt_holder)
	QDEL_NULL(animation)
	return ..()

/obj/effect/dummy/spell_jaunt
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = TRUE
	var/reappearing = FALSE
	density = FALSE
	anchored = TRUE
	var/turf/last_valid_turf

/obj/effect/dummy/spell_jaunt/New(location)
	..()
	last_valid_turf = get_turf(location)

/obj/effect/dummy/spell_jaunt/Destroy()
	for(var/atom/movable/AM in src)
		AM.dropInto(loc)
	return ..()

/obj/effect/dummy/spell_jaunt/relaymove(mob/user, direction)
	if(!canmove || reappearing)
		return
	var/turf/newLoc = get_step(src, direction)
	if(!newLoc)
		to_chat(user, SPAN_WARNING("You cannot go that way."))
	else if(!(newLoc.turf_flags & TURF_FLAG_NOJAUNT))
		forceMove(newLoc)
		var/turf/T = get_turf(loc)
		if(!T.contains_dense_objects())
			last_valid_turf = T
	else
		to_chat(user, SPAN_WARNING("Some strange aura is blocking the way!"))
	canmove = FALSE
	addtimer(CALLBACK(src, nameof(.proc/allow_move)), 2)

/obj/effect/dummy/spell_jaunt/proc/allow_move()
	canmove = TRUE

/obj/effect/dummy/spell_jaunt/ex_act(blah)
	return
/obj/effect/dummy/spell_jaunt/bullet_act(blah)
	return
