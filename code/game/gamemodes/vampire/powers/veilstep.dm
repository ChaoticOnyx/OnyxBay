
/mob/living/carbon/human/AltClickOn(atom/A)
	if(mind && mind.vampire && istype(A , /turf/simulated/floor) && (/datum/vampire/proc/vampire_veilstep in verbs))
		mind.vampire.vampire_veilstep(A)
	..()

// Plays the vampire phase in animation.
/datum/vampire/proc/phase_in(turf/T)
	if(!T)
		return
	anim(T, my_mob, 'icons/mob/mob.dmi', null, "bloodify_in", null, my_mob.dir)

// Plays the vampire phase out animation.
/datum/vampire/proc/phase_out(turf/T)
	if(!T)
		return
	anim(T, my_mob, 'icons/mob/mob.dmi', null, "bloodify_out", null, my_mob.dir)

// This one is different from other vampire powers, as it neither an actual "clickable" verb nor an onscreen ability, rather being used via alt+click on a tile
// It's pretty much preferable to rewrite it from scratch, but I'm feeling too lazy now
/datum/vampire/proc/vampire_veilstep(turf/simulated/floor/T in view(7))
	set category = null
	set name = "Veil Step (20)"
	set desc = "For a moment, move through the Veil and emerge at a shadow of your choice."
	var/blood_cost = 20

	if (!T || T.density || T.contains_dense_objects())
		to_chat(my_mob, SPAN("warning", "You cannot do that."))
		return

	if(my_mob.stat)
		to_chat(my_mob, SPAN("warning", "You are incapacitated."))
		return

	if(usable_blood < blood_cost)
		to_chat(my_mob, SPAN("warning", "You do not have enough usable blood. [blood_cost] needed."))
		return

	if(holder && !ignore_veil)
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

	vampire.phase_out(get_turf(my_mob))
	vampire.phase_in(T)
	my_mob.forceMove(T)

	for(var/obj/item/grab/G in my_mob.contents)
		if(G.affecting && (status & VAMP_FULLPOWER))
			G.affecting.vampire_phase_out(get_turf(G.affecting.loc))
			G.affecting.vampire_phase_in(get_turf(G.affecting.loc))
			G.affecting.forceMove(locate(T.x + rand(-1,1), T.y + rand(-1,1), T.z))
		else
			qdel(G)

	log_and_message_admins("activated veil step.")

	use_blood(blood_cost)
