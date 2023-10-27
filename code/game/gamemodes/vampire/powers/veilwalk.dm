
// Enables the vampire to be untouchable and walk through walls and other solid things.
/datum/vampire_power/toggled/veilwalk
	name = "Toggle Veil Walking"
	desc = "You enter the veil, leaving only an incorporeal manifestation of you visible to the others."
	icon_state = "vamp_veil"
	blood_cost = 60
	blood_drain = 5

/datum/vampire_power/toggled/veilwalk/activate()
	if(!..())
		return

	var/obj/effect/dummy/veil_walk/holder = new /obj/effect/dummy/veil_walk(get_turf(my_mob))
	holder.activate(vampire, src)
	use_blood()

	log_and_message_admins("activated veil walk.")

/datum/vampire_power/toggled/veilwalk/deactivate(no_message = TRUE)
	if(!..())
		return
	vampire.holder?.deactivate()


// Veilwalk's dummy holder
/obj/effect/dummy/veil_walk
	name = "a red ghost"
	desc = "A red, shimmering presence."
	icon = 'icons/mob/mob.dmi'
	icon_state = "blank"
	density = FALSE

	var/last_valid_turf = null
	var/can_move = TRUE
	var/datum/vampire/vampire = null
	var/datum/vampire_power/toggled/veilwalk/my_power = null
	var/warning_level = 0

/obj/effect/dummy/veil_walk/Destroy()
	vampire = null
	my_power = null
	eject_all()
	return ..()

/obj/effect/dummy/veil_walk/proc/eject_all()
	for(var/atom/movable/A in src)
		A.forceMove(loc)
		if(ismob(A))
			var/mob/M = A
			M.reset_view(null)

/obj/effect/dummy/veil_walk/relaymove(mob/user, direction)
	if (!can_move)
		return

	var/turf/new_loc = get_step(src, direction)
	if(new_loc.turf_flags & TURF_FLAG_NOJAUNT || istype(new_loc.loc, /area/chapel))
		to_chat(user, SPAN("warning", "Some strange aura is blocking the way!"))
		return

	forceMove(new_loc)
	var/turf/T = get_turf(loc)
	if(!T.contains_dense_objects())
		last_valid_turf = T

	can_move = FALSE
	addtimer(CALLBACK(src, .proc/_unlock_move), 2, TIMER_UNIQUE)

/obj/effect/dummy/veil_walk/think()
	if(vampire.my_mob.stat)
		if(vampire.my_mob.stat == 1)
			to_chat(vampire.my_mob, SPAN("warning", "You cannot maintain this form while unconcious."))
			addtimer(CALLBACK(src, .proc/_kick_unconscious), 1 SECOND, TIMER_UNIQUE)
		else
			deactivate()
			return

	if(vampire.blood_usable >= 5)
		vampire.use_blood(my_power.blood_drain)

		switch(warning_level)
			if(0)
				if(vampire.blood_usable <= 5 * 20)
					to_chat(vampire.my_mob, SPAN("notice", "Your pool of blood is diminishing. You cannot stay in the veil for too long."))
					warning_level = 1
			if(1)
				if(vampire.blood_usable <= 5 * 10)
					to_chat(vampire.my_mob, SPAN("warning", "You will be ejected from the veil soon, as your pool of blood is running dry."))
					warning_level = 2
			if(2)
				if(vampire.blood_usable <= 5 * 5)
					to_chat(vampire.my_mob, SPAN("danger", "You cannot sustain this form for any longer!"))
					warning_level = 3
	else
		deactivate()
		return

	set_next_think(world.time + 1 SECOND)

/obj/effect/dummy/veil_walk/proc/activate(datum/vampire/owner, datum/vampire_power/toggled/veilwalk/VW)
	if(!owner)
		qdel(src)
		return

	my_power = VW
	vampire = owner
	vampire.holder = src
	vampire.phase_out(get_turf(owner))

	icon_state = "shade"

	last_valid_turf = get_turf(owner)
	vampire.my_mob.forceMove(src)

	desc += " Its features look faintly alike [vampire.my_mob]'s."

	set_next_think(world.time)

/obj/effect/dummy/veil_walk/proc/deactivate()
	set_next_think(0)
	can_move = FALSE

	icon_state = "blank"

	vampire.phase_in(get_turf(loc))

	eject_all()

	vampire.holder = null
	my_power.deactivate() // Won't cause recursive loop since there's a check for holder
	vampire = null

	qdel(src)

/obj/effect/dummy/veil_walk/proc/_unlock_move()
	can_move = TRUE

/obj/effect/dummy/veil_walk/proc/_kick_unconscious()
	if(vampire.my_mob?.stat == 1)
		to_chat(vampire.my_mob, SPAN("danger", "You are ejected from the Veil."))
		deactivate()
		return

/obj/effect/dummy/veil_walk/ex_act(vars)
	return

/obj/effect/dummy/veil_walk/bullet_act(vars)
	return
