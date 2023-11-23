/datum/spell/immaterial_form
	name = "Immaterial form"
	desc = "" // TODO think
	feedback = "" // TODO think
	school = "necromancy"
	spell_flags = Z2NOCAST | NEEDSCLOTHES | INCLUDEUSER
	invocation = "none"
	invocation_type = SPI_NONE
	range = 0
	level_max = list(SP_TOTAL = 0, SP_SPEED = 0, SP_POWER = 0)
	cooldown_min = 10 SECONDS
	duration = 5 SECONDS
	need_target = FALSE
	var/enabled = FALSE
	var/obj/effect/dummy/immaterial_form/jaunt_holder = null
	icon_state = "wiz_immaterial_fast"
	override_base = "const"

/datum/spell/immaterial_form/cast(list/targets, mob/user) //magnets, so mostly hardcoded
	enabled = !enabled
	if(enabled)
		jaunt_holder = new /obj/effect/dummy/immaterial_form(usr.loc, usr)
		if(jaunt_holder.buckle_mob(user))
			user.set_dir(pick(GLOB.cardinal))
	else if(!usr.forceMove(usr.loc))
		for(var/direction in list(1,2,4,8,5,6,9,10))
			var/turf/T = get_step(usr.loc, direction)
			if(T && usr.forceMove(T))
				break

/obj/effect/dummy/immaterial_form
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = TRUE
	var/reappearing = FALSE
	density = FALSE
	anchored = TRUE
	var/turf/last_valid_turf
	var/mob/living/immaterial_user = null

/obj/effect/dummy/immaterial_form/New(location, mob/living/user)
	..()
	last_valid_turf = get_turf(location)
	immaterial_user = user

/obj/effect/dummy/immaterial_form/relaymove(mob/user, direction)
	if(!canmove || reappearing)
		return

	var/turf/newLoc = get_step(src, direction)
	if(!newLoc)
		to_chat(user, SPAN_WARNING("You cannot go that way."))
	else if(!(newLoc.turf_flags & TURF_FLAG_NOJAUNT))
		forceMove(newLoc)
		immaterial_user.buckled = null
		immaterial_user.forceMove(newLoc)
		immaterial_user.buckled = src
		var/turf/T = get_turf(loc)
		if(!T.contains_dense_objects())
			last_valid_turf = T
		set_dir(direction)
		if(buckled_mob)
			immaterial_user.set_dir(dir)
	else
		to_chat(user, SPAN_WARNING("Some strange aura is blocking the way!"))

	canmove = FALSE
	addtimer(CALLBACK(src, .proc/allow_move), 2)

/obj/effect/dummy/immaterial_form/proc/allow_move()
	canmove = TRUE

/obj/effect/dummy/immaterial_form/bullet_act(obj/item/projectile/Proj, def_zone)
	for(var/mob/living/M in contents)
		return buckled_mob.bullet_act(Proj, def_zone)
