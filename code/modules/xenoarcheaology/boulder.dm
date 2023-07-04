/obj/structure/boulder
	name = "rocky debris"
	desc = "Leftover rock from an excavation, it's been partially dug out already but there's still a lot to go."
	icon = 'icons/obj/mining.dmi'
	icon_state = "boulder1"
	density = 1
	opacity = 1
	anchored = 1
	var/excavation_level = 0
	var/datum/geosample/geological_data
	var/datum/artifact_find/artifact_find
	var/last_act = 0

/obj/structure/boulder/New()
	..()
	icon_state = "boulder[rand(1,4)]"
	excavation_level = rand(5, 50)

/obj/structure/boulder/Destroy()
	qdel(geological_data)
	qdel(artifact_find)

	return ..()

/obj/structure/boulder/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/core_sampler))
		src.geological_data.artifact_distance = rand(-100,100) / 100
		src.geological_data.artifact_id = artifact_find.artifact_id

		var/obj/item/device/core_sampler/C = I
		C.sample_item(src, user)
		return

	if(istype(I, /obj/item/device/depth_scanner))
		var/obj/item/device/depth_scanner/C = I
		C.scan_atom(user, src)
		return

	if(istype(I, /obj/item/device/measuring_tape))
		var/obj/item/device/measuring_tape/P = I
		user.visible_message(SPAN_NOTICE("\The [user] extends \the [P] towards \the [src]."), SPAN_NOTICE("You extend \the [P] towards \the [src]."))
		if(do_after(user, 15))
			to_chat(user, SPAN_NOTICE("\The [src] has been excavated to a depth of [src.excavation_level]cm."))
		return

	if(istype(I, /obj/item/pickaxe))
		var/obj/item/pickaxe/P = I

		if(!istype(P, /obj/item/pickaxe/drill))
			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		else
			var/obj/item/pickaxe/drill/D = P
			if(last_act + D.digspeed > world.time) //Prevents message spam
				return
			last_act = world.time
			if(!do_after(user, D.digspeed))
				return

		to_chat(user, SPAN_WARNING("You start [P.drill_verb] [src]."))

		to_chat(user, SPAN_NOTICE("You finish [P.drill_verb] [src]."))
		excavation_level += P.excavation_amount

		if(excavation_level > 200)
			//failure
			user.visible_message(SPAN_WARNING("\The [src] suddenly crumbles away."), SPAN_WARNING("\The [src] has disintegrated under your onslaught, any secrets it was holding are long gone."))
			qdel(src)
			return

		if(prob(excavation_level))
			//success
			if(artifact_find)
				var/spawn_type = artifact_find.artifact_find_type
				var/obj/O = new spawn_type(get_turf(src))
				if(istype(O, /obj/machinery/artifact))
					var/obj/machinery/artifact/X = O
					if(X.main_effect)
						X.main_effect.artifact_id = artifact_find.artifact_id
				src.visible_message(SPAN_WARNING("\The [src] suddenly crumbles away."))
			else
				user.visible_message(SPAN_WARNING("\The [src] suddenly crumbles away."), SPAN_NOTICE("\The [src] has been whittled away under your careful excavation, but there was nothing of interest inside."))
			qdel(src)

/obj/structure/boulder/Bumped(AM)
	. = ..()
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		var/obj/item/pickaxe/P = H.get_inactive_hand()
		if(istype(P))
			src.attackby(P, H)

	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/pickaxe))
			attackby(R.module_active,R)

	else if(istype(AM,/obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/tool/drill))
			M.selected.action(src)
