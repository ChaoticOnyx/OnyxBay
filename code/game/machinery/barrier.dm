#define BARRIER_DAMAGE_THRESHOLD 100

/obj/structure/barrier
	name = "deployable barrier"
	desc = "A deployable barrier. Swipe your ID card to lock/unlock it."

	icon = 'icons/obj/objects.dmi'
	icon_state = "barrier0"

	obj_flags = OBJ_FLAG_ANCHORABLE
	anchored = FALSE
	density = TRUE

	pull_sound = SFX_PULL_MACHINE
	pull_slowdown = PULL_SLOWDOWN_LIGHT

	req_access = list(access_security)

	var/damage = 0

	var/emagged = FALSE
	var/locked = FALSE


/obj/structure/barrier/on_update_icon()
	icon_state = "barrier[locked]"


/obj/structure/barrier/Initialize()
	. = ..()
	register_signal(src, SIGNAL_MOVED, nameof(.proc/on_barrier_move))


/obj/structure/barrier/Destroy()
	unregister_signal(src, SIGNAL_MOVED)
	return ..()


/obj/structure/barrier/proc/on_barrier_move(atom/movable/target, atom/old_loc, atom/new_loc)
	if(emagged)
		_dismantle_floor(old_loc)


/obj/structure/barrier/attackby(obj/item/W, mob/user)
	if(W.force && user.a_intent == I_HURT)
		_attack(user)
		return

	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/device/pda) || istype(W, /obj/item/card/robot_sec))
		_toggle(user)
		return

	if(isWelder(W))
		_repair_damage(user, W)
		return

	return ..()


/obj/structure/barrier/proc/_attack(obj/item/W, mob/user)
	// Some cringy boilerplate lies here, we should probably create unified damage system.
	obj_attack_sound(W)
	user.do_attack_animation(src)
	user.setClickCooldown(W.update_attack_cooldown())

	take_damage(user, W.force)


/obj/structure/barrier/proc/_toggle(mob/user)
	if(!allowed(user))
		return

	locked = !locked

	update_icon()
	show_splash_text(user, "bolts [locked ? "dropped" : "lifted"]")


/obj/structure/barrier/proc/_repair_damage(mob/user, obj/item/weldingtool/WT)
	if(istype(WT))
		return

	if(!WT.remove_fuel(0, user))
		to_chat(user, "\The [WT] must be on to complete this task.")
		return

	playsound(loc, 'sound/items/Welder.ogg', 50, 1)
	if(do_after(user, 20, src))
		if(!WT.isOn())
			return

		visible_message(SPAN("notice", "\The [user] has repaired \the [src]"))
		damage = 0
		update_icon()


/obj/structure/barrier/wrench_floor_bolts(mob/user, delay)
	if(locked)
		show_splash_text(user, "bolts prevent wrenching!")
		return

	return ..()


/obj/structure/barrier/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			take_damage(null, BARRIER_DAMAGE_THRESHOLD * 0.7)
		if(EXPLODE_LIGHT)
			take_damage(null, BARRIER_DAMAGE_THRESHOLD * 0.4)


/obj/structure/barrier/emp_act(severity)
	if(!prob(50 / severity))
		return

	locked = !locked
	anchored = !anchored
	update_icon()


/obj/structure/barrier/CanPass(atom/movable/mover, turf/target)
	// Extra check that allows bullets to pass through.
	if(mover?.pass_flags & PASS_FLAG_TABLE)
		return TRUE

	return FALSE


/obj/structure/barrier/emag_act(remaining_charges, mob/user)
	if(emagged)
		return FALSE

	atom_flags |= ATOM_FLAG_UNPUSHABLE
	pull_slowdown = PULL_SLOWDOWN_EXTREME
	emagged = TRUE

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(2, 1, src)
	s.start()

	playsound(src.loc, 'sound/effects/computer_emag.ogg', 25)
	show_splash_text(user, "authentication lock broken!")

	return TRUE


/obj/structure/barrier/proc/take_damage(mob/user, amount)
	damage = clamp(damage + amount * 0.75, 0, BARRIER_DAMAGE_THRESHOLD)

	if(damage == BARRIER_DAMAGE_THRESHOLD)
		if(user)
			visible_message(SPAN("danger", "\The [user] smashes \the [src]!"))
		explode()
	else
		if(user)
			visible_message(SPAN("danger", "\The [user] attacks \the [src]!"))


/obj/structure/barrier/proc/explode()
	visible_message(SPAN("danger", "\the [src] blows apart!"))

	new /obj/item/stack/rods(get_turf(src))

	var/datum/effect/effect/system/spark_spread/S = new /datum/effect/effect/system/spark_spread
	S.set_up(3, 1, src)
	S.start()

	qdel(src)


/obj/structure/barrier/proc/_dismantle_floor(turf/simulated/floor/F)
	if(!istype(F))
		return

	if(!F.is_plating())
		F.make_plating(!(F.broken || F.burnt))
		playsound(src, 'sound/items/jaws_pry.ogg', 50, TRUE)


#undef BARRIER_DAMAGE_THRESHOLD
