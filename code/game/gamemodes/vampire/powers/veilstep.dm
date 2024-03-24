
/mob/living/carbon/human/AltClickOn(atom/A)
	if(mind?.vampire && istype(A , /turf/simulated/floor) && (/datum/vampire/proc/vampire_veilstep in verbs))
		mind.vampire.vampire_veilstep(A)
	..()

// Plays the vampire phase in animation.
/datum/vampire/proc/phase_in(turf/T, mob/M = null)
	if(!T)
		return
	if(isnull(M))
		M = my_mob
	anim(T, M, 'icons/mob/mob.dmi', null, "bloodify_in", null, M.dir)

// Plays the vampire phase out animation.
/datum/vampire/proc/phase_out(turf/T, mob/M = null)
	if(!T)
		return
	if(isnull(M))
		M = my_mob
	anim(T, M, 'icons/mob/mob.dmi', null, "bloodify_out", null, M.dir)

// This one is different from other vampire powers, as it neither an actual "clickable" verb nor an onscreen ability, rather being used via alt+click on a tile
// It's pretty much preferable to rewrite it from scratch, but I'm feeling too lazy now
/datum/vampire/proc/vampire_veilstep(turf/simulated/floor/T in view(7))
	set category = null
	set name = "Veil Step (20)"
	set desc = "For a moment, move through the Veil and emerge at a shadow of your choice."
	if(ishuman(src)) // When used via the context menu the proc reparents to the mob, thank you lummox
		var/mob/living/carbon/human/H = src
		H.mind?.vampire?._vampire_veilstep(T)
	else
		_vampire_veilstep(T)
	log_and_message_admins("activated veil step.")

/datum/vampire/proc/_vampire_veilstep(turf/T)
	var/blood_cost = 20

	if (!T || T.density || T.contains_dense_objects())
		to_chat(my_mob, SPAN("warning", "You cannot do that."))
		return

	if(my_mob.stat)
		to_chat(my_mob, SPAN("warning", "You are incapacitated."))
		return

	if(blood_usable < blood_cost)
		to_chat(my_mob, SPAN("warning", "You do not have enough usable blood. [blood_cost] needed."))
		return

	if(holder)
		to_chat(my_mob, SPAN("warning", "You cannot use this power while walking through the Veil."))
		return

	if(!istype(my_mob.loc, /turf))
		to_chat(my_mob, SPAN("warning", "You cannot teleport out of your current location."))
		return

	if(T.z != my_mob.z || get_dist(T, get_turf(my_mob)) > world.view)
		to_chat(my_mob, SPAN("warning", "Your powers are not capable of taking you that far."))
		return

	if (T.get_lumcount() > 0.1)
		// Too bright, cannot jump into.
		to_chat(my_mob, SPAN("warning", "The destination is too bright."))
		return

	phase_out(get_turf(my_mob))
	phase_in(T)
	my_mob.forceMove(T)

	for(var/obj/item/grab/G in my_mob.contents)
		if(G.affecting && (vamp_status & VAMP_FULLPOWER))
			phase_out(get_turf(G.affecting), G.affecting)
			phase_in(get_turf(G.affecting), G.affecting)
			G.affecting.forceMove(locate(T.x + rand(-1,1), T.y + rand(-1,1), T.z))
		else
			qdel(G)

	use_blood(blood_cost)
