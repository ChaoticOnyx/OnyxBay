/decl/teleport
	var/static/list/teleport_blacklist = list(/obj/item/disk/nuclear, /obj/item/storage/backpack/holding, /obj/effect/sparks) //Items that cannot be teleported, or be in the contents of someone who is teleporting.

/decl/teleport/proc/teleport(atom/target, atom/destination, precision = 0)
	if(!can_teleport(target,destination))
		target.visible_message("<span class='warning'>\The [target] bounces off the teleporter!</span>")
		return

	teleport_target(target, destination, precision)

/decl/teleport/proc/teleport_target(atom/movable/target, atom/destination, precision)
	var/list/possible_turfs = get_turfs(target, destination, precision)
	destination = safepick(possible_turfs)
	if(!destination)
		target.visible_message(SPAN("warning", "\The [target] bounces off the teleporter!"))
		return

	playsound(target, pick(
		'sound/effects/teleport1.ogg',
		'sound/effects/teleport2.ogg',
		'sound/effects/teleport3.ogg',
	), 75, FALSE)

	target.forceMove(destination)
	if(isliving(target))
		var/mob/living/L = target
		if(L.buckled)
			var/atom/movable/buckled = L.buckled
			buckled.forceMove(destination)

/decl/teleport/proc/get_turfs(atom/movable/target, atom/destination, precision)
	return circlerangeturfs(destination, precision)

/decl/teleport/proc/can_teleport(atom/movable/target, atom/destination)
	if(!destination || !target || !target.loc)
		return 0

	if(istype(target, /obj/mecha))
		if(destination.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_CENTCOM))
			var/obj/mecha/mech = target
			to_chat(mech.occupant, "<span class='danger'>\The [target] would not survive the jump to a location so far away!</span>")
			return 0

	if(is_type_in_list(target, teleport_blacklist))
		return 0

	for(var/type in teleport_blacklist)
		if(!isemptylist(target.search_contents_for(type)))
			return 0
	return 1

/decl/teleport/sparks
	var/datum/effect/effect/system/spark_spread/spark = new

/decl/teleport/sparks/proc/do_spark(atom/target)
	if(!target.simulated)
		return
	var/turf/T = get_turf(target)
	if (!(locate(/obj/effect/sparks) in T))
		spark.set_up(1,1,target)
		spark.attach(T)
		spark.start()

/decl/teleport/sparks/teleport_target(atom/target, atom/destination, precision)
	do_spark(target)
	..()
	do_spark(target)

// circlerangeturfs is shit proc created by imbécile (by fr: idiot)
/decl/teleport/sparks/precision/get_turfs(atom/movable/target, atom/destination, precision)
	var/turf/T = get_step(destination, target.dir)
	if(!T || T.density)
		return ..()
	return list(T)

/proc/do_teleport(atom/movable/target, atom/destination, precision = 0, type = /decl/teleport/sparks)
	var/decl/teleport/tele = decls_repository.get_decl(type)
	tele.teleport(target, destination, precision)
