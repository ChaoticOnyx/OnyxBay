/obj/structure/barricade/security
	name = "deployable barrier"
	desc = "A deployable steel barrier with toggleable bolts. Frequently used by security stuff for crowd control and riot supression."

	icon = 'icons/obj/structures.dmi'
	icon_state = "barrier0"

	obj_flags = OBJ_FLAG_ANCHORABLE
	anchored = FALSE

	pull_sound = SFX_PULL_MACHINE
	pull_slowdown = PULL_SLOWDOWN_LIGHT

	req_access = list(access_security)

	damage = 0
	maxdamage = 200

	var/emagged = FALSE
	var/locked = FALSE


/obj/structure/barricade/security/on_update_icon()
	icon_state = "barrier[locked]"

	if(locked)
		AddOverlays(emissive_appearance(icon, "barrier-ea"))


/obj/structure/barricade/security/Initialize()
	. = ..()
	register_signal(src, SIGNAL_MOVED, nameof(.proc/on_barrier_move))


/obj/structure/barricade/security/Destroy()
	unregister_signal(src, SIGNAL_MOVED)
	return ..()


/obj/structure/barricade/security/proc/on_barrier_move(atom/movable/target, atom/old_loc, atom/new_loc)
	if(emagged)
		_dismantle_floor(old_loc)


/obj/structure/barricade/security/proc/_dismantle_floor(turf/simulated/floor/F)
	if(!istype(F))
		return

	if(!F.is_plating())
		F.make_plating(!(F.broken || F.burnt))
		playsound(src, 'sound/items/jaws_pry.ogg', 50, TRUE)


/obj/structure/barricade/security/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/device/pda) || istype(W, /obj/item/card/robot_sec))
		_toggle(user)
		return

	if(isWelder(W))
		_repair_damage(user, W)
		return

	return ..()


/obj/structure/barricade/security/proc/_toggle(mob/user)
	if(!allowed(user))
		return

	locked = !locked
	anchored = locked

	update_icon()
	show_splash_text(user, "bolts [locked ? "dropped" : "lifted"].")


/obj/structure/barricade/security/proc/_repair_damage(mob/user, obj/item/weldingtool/WT)
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


/obj/structure/barricade/security/wrench_floor_bolts(mob/user, delay)
	if(locked)
		show_splash_text(user, "bolts prevent wrenching!")
		return

	return ..()


/obj/structure/barricade/security/emp_act(severity)
	if(!prob(50 / severity))
		return

	locked = !locked
	anchored = !anchored
	update_icon()


/obj/structure/barricade/security/emag_act(remaining_charges, mob/user)
	if(emagged)
		return FALSE

	atom_flags |= ATOM_FLAG_UNPUSHABLE
	change_pull_slowdown(PULL_SLOWDOWN_EXTREME)
	emagged = TRUE

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(2, 1, src)
	s.start()

	playsound(src.loc, 'sound/effects/computer_emag.ogg', 25)
	show_splash_text(user, "bolt locks broken!")

	return TRUE


/obj/structure/barricade/security/Break()
	visible_message(SPAN("danger", "\the [src] blows apart!"))

	new /obj/item/stack/rods(get_turf(src))

	var/datum/effect/effect/system/spark_spread/S = new /datum/effect/effect/system/spark_spread
	S.set_up(3, 1, src)
	S.start()
