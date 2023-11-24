#define MANA_PER_EMPOWER 40

/datum/spell/toggled/immaterial_form
	name = "Immaterial form"
	desc = "" // TODO think
	feedback = "" // TODO think
	school = "necromancy"
	spell_flags = Z2NOCAST | NEEDSCLOTHES | INCLUDEUSER
	invocation = "none"
	invocation_type = SPI_NONE

	level_max = list(SP_TOTAL = 4, SP_SPEED = 2, SP_POWER = 2)
	cooldown_min = 10 SECONDS
	duration = 5 SECONDS
	need_target = FALSE
	var/obj/effect/dummy/immaterial_form/jaunt_holder = null
	icon_state = "wiz_immaterial_fast"
	override_base = "const"

	text_activate = "You slip into the immaterium."
	text_deactivate = "Once again you enter the mortal realm."

	mana_current = 60
	mana_max = 60
	mana_drain_per_tick = 5
	mana_regen_per_tick = 1

/datum/spell/toggled/immaterial_form/activate()
	. = ..()
	if(!.)
		return

	jaunt_holder = new /obj/effect/dummy/immaterial_form(holder.loc, holder)
	if(jaunt_holder.buckle_mob(holder))
		holder.set_dir(pick(GLOB.cardinal))
		holder.alpha = 127
	else
		toggled = FALSE
		deactivate()

/datum/spell/toggled/immaterial_form/deactivate()
	. = ..()
	if(!.)
		return

	QDEL_NULL(jaunt_holder)

	holder.alpha = 255

/datum/spell/toggled/immaterial_form/think()
	if(toggled)
		if(!jaunt_holder)
			toggled = FALSE
			deactivate()
			return

		if(!jaunt_holder.buckled_mob)
			toggled = FALSE
			deactivate()
			return

	return ..()


/datum/spell/toggled/immaterial_form/quicken_spell()
	if(!can_improve(SP_SPEED))
		return FALSE

	spell_levels[SP_SPEED]++

	mana_regen_per_tick++

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

/datum/spell/toggled/immaterial_form/empower_spell()
	. = ..()
	if(!.)
		return FALSE

	mana_max += MANA_PER_EMPOWER

	return "You've increased the max mana pool of [src]."


/obj/effect/dummy/immaterial_form
	name = "you should not see this xd"
	invisibility = INVISIBILITY_SYSTEM
	var/canmove = TRUE
	var/reappearing = FALSE
	buckle_relaymove = TRUE
	density = FALSE
	anchored = TRUE
	var/turf/last_valid_turf
	var/mob/living/immaterial_user = null

/obj/effect/dummy/immaterial_form/New(location, mob/living/user)
	..()
	last_valid_turf = get_turf(location)
	user.alpha = 127
	immaterial_user = user

/obj/effect/dummy/immaterial_form/relaymove(mob/user, direction)
	if(!canmove)
		return

	var/turf/newLoc = get_step(src, direction)
	if(!newLoc)
		to_chat(user, SPAN_WARNING("You cannot go that way."))
	else if(!(newLoc.turf_flags & TURF_FLAG_NOJAUNT))
		var/turf/T = get_turf(newLoc)
		if(!T.contains_dense_objects())
			last_valid_turf = T
		forceMove(newLoc)
		immaterial_user.buckled = null
		immaterial_user.forceMove(newLoc)
		immaterial_user.buckled = src
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
	if(buckled_mob)
		return buckled_mob.bullet_act(Proj, def_zone)

/obj/effect/dummy/immaterial_form/Destroy()
	if(!immaterial_user)
		return ..()

	immaterial_user.forceMove(last_valid_turf, TRUE)
	return ..()

#undef MANA_PER_EMPOWER
