/datum/rcd_work_mode
	var/name = "RCD WORK MODE"
	var/cost = 0
	var/delay = 2 SECONDS

	var/image/preview

/datum/rcd_work_mode/proc/do_work(obj/item/rcd/rcd, atom/target, user)
	if(!_can_do_handle_work(rcd, target))
		return FALSE

	var/cost = _calculate_cost(target) || 0

	if(!rcd.use_resource(cost, user))
		to_chat(user, SPAN("warning", "Insufficient resources."))
		return FALSE

	playsound(user, 'sound/machines/click.ogg', 50, 1)
	_work_message(target, user, rcd)

	var/delay = _calculate_delay(target) || 0
	if(delay)
		if(!(do_after(user, delay, target)))
			return FALSE

	_do_handle_work(rcd, target)
	playsound(user, 'sound/items/Deconstruct.ogg', 50, 1)

	return TRUE

/datum/rcd_work_mode/proc/_calculate_delay(atom/target)
	return 2 SECONDS

/datum/rcd_work_mode/proc/_can_do_handle_work(obj/item/rcd/rcd, atom/target)
	return FALSE

/datum/rcd_work_mode/proc/_calculate_cost(atom/target)
	return 0

/datum/rcd_work_mode/proc/_do_handle_work(atom/target)
	CRASH("Override this")

/datum/rcd_work_mode/proc/_work_message(atom/target, mob/user, obj/item/rcd/rcd)
	CRASH("Override this")

/// Airlock construction
/datum/rcd_work_mode/construction_airlock
	name = "Airlock Construction"

/datum/rcd_work_mode/construction_airlock/New()
	preview = image('icons/mob/radial.dmi', "airlock")

/datum/rcd_work_mode/construction_airlock/_work_message(atom/target, mob/user, obj/item/rcd/rcd)
	user.visible_message(SPAN("notice", "\The [user] uses \a [rcd] to construct airlock."), SPAN("notice", "You begin construction."))

/datum/rcd_work_mode/construction_airlock/_calculate_delay(atom/target)
	return 5 SECONDS

/datum/rcd_work_mode/construction_airlock/_calculate_cost()
	return 10

/datum/rcd_work_mode/construction_airlock/_can_do_handle_work(obj/item/rcd/rcd, atom/target)
	var/turf/T = get_turf(target)

	if(T.contains_dense_objects() && locate(/obj/machinery/door/airlock) in T)
		return FALSE

	return TRUE

/datum/rcd_work_mode/construction_airlock/_do_handle_work(obj/item/rcd/rcd, atom/target)
	if(!_can_do_handle_work(rcd, target))
		return

	var/turf/T = get_turf(target)

	new /obj/machinery/door/airlock(get_turf(T))

/// Floor construction
/datum/rcd_work_mode/construction_floor
	name = "Floor Construction"

/datum/rcd_work_mode/construction_floor/New()
	preview = image('icons/turf/floors.dmi', "steel")
	preview.SetTransform(scale = 0.6)

/datum/rcd_work_mode/construction_floor/_work_message(atom/target, mob/user, obj/item/rcd/rcd)
	user.visible_message(SPAN("notice", "\The [user] uses \a [rcd] to construct floor."), SPAN("notice", "You begin construction."))

/datum/rcd_work_mode/construction_floor/_calculate_delay(atom/target)
	return 2 SECONDS

/datum/rcd_work_mode/construction_floor/_calculate_cost()
	return 1

/datum/rcd_work_mode/construction_floor/_can_do_handle_work(obj/item/rcd/rcd, atom/target)
	var/turf/T = get_turf(target)

	if(T.contains_dense_objects())
		return FALSE

	if(!isspaceturf(T) && !ispath(/turf/simulated/floor/tiled, get_base_turf_by_area(T)) && !isopenspace(T))
		return FALSE

	return TRUE

/datum/rcd_work_mode/construction_floor/_do_handle_work(obj/item/rcd/rcd, atom/target)
	if(!_can_do_handle_work(rcd, target))
		return

	var/turf/T = get_turf(target)

	T.ChangeTurf(/turf/simulated/floor/tiled)

/// Wall construction
/datum/rcd_work_mode/construction_wall
	name = "Wall Construction"

/datum/rcd_work_mode/construction_wall/New()
	preview = image('icons/turf/walls.dmi', "0")
	preview.SetTransform(scale = 0.6)

/datum/rcd_work_mode/construction_wall/_work_message(atom/target, mob/user, obj/item/rcd/rcd)
	user.visible_message(SPAN("notice", "\The [user] uses \a [rcd] to construct wall."), SPAN("notice", "You begin construction."))

/datum/rcd_work_mode/construction_wall/_calculate_delay(atom/target)
	return 2 SECONDS

/datum/rcd_work_mode/construction_wall/_calculate_cost()
	return 3

/datum/rcd_work_mode/construction_wall/_can_do_handle_work(rcd, atom/target)
	var/turf/T = get_turf(target)

	if(!istype(T, /turf/simulated/floor) || T.contains_dense_objects() || locate(/obj/machinery/door) in T)
		return FALSE

	return TRUE

/datum/rcd_work_mode/construction_wall/_do_handle_work(rcd, atom/target)
	if(!_can_do_handle_work(rcd, target))
		return

	var/turf/T = get_turf(target)

	T.ChangeTurf(/turf/simulated/wall)

///	Deconstruction
/datum/rcd_work_mode/deconstruction
	name = "Deconstruction"

/datum/rcd_work_mode/deconstruction/New()
	preview = image('icons/mob/radial.dmi', "delete")

/datum/rcd_work_mode/deconstruction/_calculate_delay(atom/target)
	if(istype(target, /obj/machinery/door/airlock))
		return 5 SECONDS

	return 2 SECONDS

/datum/rcd_work_mode/deconstruction/_calculate_cost(atom/target)
	if(istype(target, /obj/machinery/door/airlock))
		return 10

	return 3

/datum/rcd_work_mode/deconstruction/_work_message(atom/target, mob/user, obj/item/rcd/rcd)
	user.visible_message(SPAN("notice", "\The [user] is using \a [rcd] to deconstruct \the [target]!"), SPAN("notice", "You are deconstructing \the [target]!"))

/datum/rcd_work_mode/deconstruction/_can_do_handle_work(obj/item/rcd/rcd, atom/target)
	if(!istype(target, /obj/machinery/door/airlock) && !istype(target, /turf/simulated/wall) && !istype(target, /turf/simulated/floor))
		return FALSE

	return TRUE

/datum/rcd_work_mode/deconstruction/_do_handle_work(obj/item/rcd/rcd, atom/target)
	if(istype(target, /obj/machinery/door/airlock))
		qdel(target)
		return

	var/turf/simulated/wall/W = target
	if(istype(W) && (!W.reinf_material || rcd.can_rwall))
		W.dismantle_wall()
		return

	var/turf/simulated/floor/F = target
	if(istype(F))
		F.dismantle_floor()
		return
