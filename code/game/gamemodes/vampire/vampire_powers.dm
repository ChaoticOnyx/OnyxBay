// Contains all /mob/procs that relate to vampire.
/mob/living/carbon/human/AltClickOn(atom/A)
	if(mind && mind.vampire && istype(A , /turf/simulated/floor) && (/datum/vampire/proc/vampire_veilstep in verbs))
		mind.vampire.vampire_veilstep(A)
	..()

// Makes vampire's victim not get paralyzed, and remember the suckings
/datum/vampire/proc/vampire_alertness()
	set category = "Vampire"
	set name = "Victim Alertness"
	set desc = "Toggle whether you wish for your victims to forget your deeds."
	var/power_use_cost = 0
	var/mob/living/carbon/human/user = usr
	var/datum/vampire/vampire = user?.vampire_power(power_use_cost, 0)
	vampire.stealth = !vampire.stealth
	if(vampire.stealth)
		to_chat(user, SPAN_NOTICE("Your victims will now forget your interactions."))
	else
		to_chat(user, SPAN_NOTICE("Your victims will now remember your interactions."))

// Drains the target's blood.
/datum/vampire/proc/vampire_drain_blood()
	set category = "Vampire"
	set name = "Drain Blood"
	set desc = "Drain the blood of a humanoid creature."
	var/power_use_cost = 0
	var/mob/living/carbon/human/user = usr
	var/datum/vampire/vampire = user?.vampire_power(power_use_cost, 0)
	if (!vampire)
		return

	var/obj/item/grab/G = user.get_active_hand()
	if (!istype(G))
		to_chat(user, SPAN_WARNING("You must be grabbing a victim in your active hand to drain their blood."))
		return
	if(!G.can_absorb())
		to_chat(user, SPAN_WARNING("You must have a tighter grip on victim to drain their blood."))
		return

	var/mob/living/carbon/human/T = G.affecting
	if (!istype(T) || T.isSynthetic() || T.species.species_flags & SPECIES_FLAG_NO_BLOOD)
		//Added this to prevent vampires draining diona and IPCs
		//Diona have 'blood' but its really green sap and shouldn't help vampires
		//IPCs leak oil
		to_chat(user, SPAN_WARNING("[T] is not a creature you can drain useful blood from."))
		return
	if(T.head && (T.head.item_flags & ITEM_FLAG_AIRTIGHT))
		to_chat(user, SPAN_WARNING("[T]'s headgear is blocking the way to the neck."))
		return
	var/obj/item/blocked = user.check_mouth_coverage()
	if(blocked)
		to_chat(user, SPAN_WARNING("\The [blocked] is in the way of your fangs!"))
		return
	if (vampire.status & VAMP_DRAINING)
		to_chat(user, SPAN_WARNING("Your fangs are already sunk into a victim's neck!"))
		return

	var/datum/vampire/draining_vamp = null
	if (T.mind && T.mind.vampire)
		draining_vamp = T.mind.vampire

	var/target_aware = !!T.client

	var/blood = 0
	var/blood_total = 0
	var/blood_usable = 0
	var/blood_drained = 0

	vampire.status |= VAMP_DRAINING

	user.visible_message(SPAN_DANGER("[user.name] bites [T.name]'s neck!"), SPAN_DANGER("You bite [T.name]'s neck and begin to drain their blood."), SPAN_NOTICE("You hear a soft puncture and a wet sucking noise"))
	var/remembrance
	if(vampire.stealth)
		remembrance = "forgot"
	else
		remembrance = "remembered"
	admin_attack_log(user, T, "drained blood from [key_name(T)], who [remembrance] the encounter.", "had their blood drained by [key_name(user)] and [remembrance] the encounter.", "is draining blood from")

	to_chat(T, SPAN("warning", FONT_LARGE("You feel yourself falling into a pleasant dream, from which even a smile appeared on your face.")))
	T.paralysis = 3400

	playsound(user.loc, 'sound/effects/drain_blood.ogg', 50, 1)


	while (do_mob(user, T, 50))
		if (!user.mind.vampire)
			to_chat(user, SPAN_DANGER("Your fangs have disappeared!"))
			return
		if (blood_drained >= 115)
			to_chat(user, SPAN_DANGER("You can't drink even more blood!"))
			break
		blood_total = vampire.blood_total
		blood_usable = vampire.blood_usable

		if (!T.vessel.get_reagent_amount(/datum/reagent/blood))
			to_chat(user, SPAN_DANGER("[T] has no more blood left to give."))
			break

		if (!T.stunned)
			T.Stun(10)

		var/frenzy_lower_chance = 0

		// Alive and not of empty mind.
		if (T.check_drain_target_state(T))
			blood = min(15, T.vessel.get_reagent_amount(/datum/reagent/blood))
			vampire.blood_total += blood
			vampire.gain_blood(blood)
			blood_drained += blood

			frenzy_lower_chance = 40

			if (draining_vamp)
				vampire.blood_vamp += blood
				// Each point of vampire blood will increase your chance to frenzy.
				vampire.frenzy += blood

				// And drain the vampire as well.
				draining_vamp.use_blood(min(blood, draining_vamp.blood_usable))
				user.mind.vampire.check_frenzy()

				frenzy_lower_chance = 0
		// SSD/protohuman or dead.
		else
			blood = min(5, T.vessel.get_reagent_amount(/datum/reagent/blood))
			vampire.gain_blood(blood)
			blood_drained += blood

			frenzy_lower_chance = 40

		if (prob(frenzy_lower_chance) && vampire.frenzy > 0)
			vampire.frenzy--

		if (blood_total != vampire.blood_total)
			var/update_msg = SPAN_NOTICE("You have accumulated [vampire.blood_total] [vampire.blood_total > 1 ? "units" : "unit"] of blood")
			if (blood_usable != vampire.blood_usable)
				update_msg += SPAN_NOTICE(" and have [vampire.blood_usable] left to use.")
			else
				update_msg += SPAN_NOTICE(".")
			to_chat(user, update_msg)

		if (blood_drained >= 70 && blood_drained < 85)
			to_chat(user, SPAN_WARNING("You have enough amount of drained blood."))


		user.check_vampire_upgrade()
		T.vessel.remove_reagent(/datum/reagent/blood, 15)

	vampire.status &= ~VAMP_DRAINING

	var/endsuckmsg = "You extract your fangs from [T.name]'s neck and stop draining them of blood."
	if(vampire.stealth)
		endsuckmsg += "They will remember nothing of this occurance, provided they survived."
	user.visible_message(SPAN_DANGER("[user.name] stops biting [T.name]'s neck!"), SPAN_NOTICE("[endsuckmsg]"))
	T.paralysis = 0
	if(target_aware)
		if(!T.is_ooc_dead() && vampire.stealth)
			spawn()			//Spawned in the same manner the brain damage alert is, just so the proc keeps running without stops.
				alert(T, "You remember NOTHING about the cause of your blackout. Instead, you remember having a pleasant encounter with [user.name].", "Bitten by a vampire")
		else if(!T.is_ooc_dead())
			spawn()
				alert(T, "You remember everything that happened. Remember how blood was sucked from your neck. It gave you pleasure, like a pleasant dream. You feel great. How you react to [owner.name]'s actions is up to you.", "Bitten by a vampire")
	user.verbs -= /datum/vampire/proc/vampire_drain_blood
	if(blood_drained <= 85)

		ADD_VERB_IN_IF(user, 1800, /datum/vampire/proc/vampire_drain_blood, CALLBACK(user, /mob/living/carbon/human/proc/finish_vamp_timeout))
	else
		ADD_VERB_IN_IF(user, 2400, /datum/vampire/proc/vampire_drain_blood, CALLBACK(user, /mob/living/carbon/human/proc/finish_vamp_timeout))

// Check that our target is alive, logged in, and any other special cases
/mob/living/carbon/human/proc/check_drain_target_state(mob/living/carbon/human/T)
	if(T.stat < DEAD && T.client)
		return TRUE

// Small area of effect stun.
/datum/vampire/proc/vampire_glare()
	set category = "Vampire"
	set name = "Glare"
	set desc = "Your eyes flash a bright light, stunning any who are watching."
	var/power_use_cost = 0
	var/mob/living/carbon/human/user = usr
	if (!user.vampire_power(power_use_cost, 1))
		return
	if (user.eyecheck() > FLASH_PROTECTION_NONE)
		to_chat(owner, SPAN_WARNING("You can't do that, because no one will see the light of your eyes!"))
		return

	user.visible_message(SPAN_DANGER("[user.name]'s eyes emit a blinding flash"))
	var/list/victims = list()
	for (var/mob/living/carbon/human/H in view(2))
		if(H == user)
			continue
		if(!can_affect_target(H, FALSE))
			continue
		if(H.eyecheck() > FLASH_PROTECTION_NONE)
			continue
		H.Weaken(8)
		H.Stun(6)
		H.stuttering = 20
		H.confused = 10
		to_chat(H, SPAN_DANGER("You are blinded by [user]'s glare!"))
		H.flash_eyes()
		victims += H

	admin_attacker_log_many_victims(user, victims, "used glare to stun", "was stunned by [key_name(user)] using glare", "used glare to stun")

	user.verbs -= /datum/vampire/proc/vampire_glare
	ADD_VERB_IN_IF(user, 800, /datum/vampire/proc/vampire_glare, CALLBACK(user, /mob/living/carbon/human/proc/finish_vamp_timeout))

// Targeted stun ability, moderate duration.
/datum/vampire/proc/vampire_hypnotise()
	set category = "Vampire"
	set name = "Hypnotise (10)"
	set desc = "Through blood magic, you dominate the victim's mind and force them into a hypnotic transe."
	var/power_use_cost = 10
	var/mob/living/carbon/human/user = usr
	var/datum/vampire/vampire = user.vampire_power(power_use_cost, 1)
	if (!vampire)
		return

	if (user.eyecheck() > FLASH_PROTECTION_NONE)
		to_chat(user, SPAN_WARNING("You can't do that, because no one will see your eyes!"))
		return

	var/list/victims = list()
	for (var/mob/living/carbon/human/H in view(3))
		if (H == user)
			continue
		if(H.eyecheck() > FLASH_PROTECTION_NONE)
			continue
		victims += H
	if (!victims.len)
		to_chat(user, SPAN_WARNING("No suitable targets."))
		return

	var/mob/living/carbon/human/T = input(user, "Select Victim") as null|mob in victims

	if(!can_affect_target(T))
		return

	to_chat(user, SPAN_NOTICE("You begin peering into [T.name]'s mind, looking for a way to render them useless."))

	if (do_mob(user, T, 50, incapacitation_flags = INCAPACITATION_DISABLED))
		to_chat(user, SPAN_DANGER("You dominate [T.name]'s mind and render them temporarily powerless to resist"))
		to_chat(T, SPAN_DANGER("You are captivated by [user.name]'s gaze, and find yourself unable to move or even speak."))
		T.Weaken(25)
		T.Stun(25)
		T.silent += 30

		vampire.use_blood(power_use_cost)
		admin_attack_log(user, T, "used hypnotise to stun [key_name(T)]", "was stunned by [key_name(user)] using hypnotise", "used hypnotise on")

		user.verbs -= /datum/vampire/proc/vampire_hypnotise
		ADD_VERB_IN_IF(user, 1200, /datum/vampire/proc/vampire_hypnotise, CALLBACK(user, /mob/living/carbon/human/proc/finish_vamp_timeout))
	else
		to_chat(user, SPAN_WARNING("You broke your gaze."))

// Targeted teleportation, must be to a low-light tile.
/datum/vampire/proc/vampire_veilstep(turf/simulated/floor/T in view(7))
	set category = null
	set name = "Veil Step (20)"
	set desc = "For a moment, move through the Veil and emerge at a shadow of your choice."
	var/power_use_cost = 20
	var/mob/living/carbon/human/user = usr
	if (!T || T.density || T.contains_dense_objects())
		to_chat(user, SPAN_WARNING("You cannot do that."))
		return

	var/datum/vampire/vampire = user.vampire_power(power_use_cost, 1)
	if (!vampire)
		return
	if (!istype(user.loc, /turf))
		to_chat(user, SPAN_WARNING("You cannot teleport out of your current location."))
		return
	if (T.z != user.z || get_dist(T, get_turf(user)) > world.view)
		to_chat(user, SPAN_WARNING("Your powers are not capable of taking you that far."))
		return
	if (T.get_lumcount() > 0.1)
		// Too bright, cannot jump into.
		to_chat(user, SPAN_WARNING("The destination is too bright."))
		return

	user.vampire_phase_out(get_turf(user.loc))
	user.vampire_phase_in(T)
	user.forceMove(T)

	for (var/obj/item/grab/G in user.contents)
		if (G.affecting && (vampire.status & VAMP_FULLPOWER))
			G.affecting.vampire_phase_out(get_turf(G.affecting.loc))
			G.affecting.vampire_phase_in(get_turf(G.affecting.loc))
			G.affecting.forceMove(locate(T.x + rand(-1,1), T.y + rand(-1,1), T.z))
		else
			qdel(G)

	log_and_message_admins("activated veil step.")

	vampire.use_blood(power_use_cost)
	user.verbs -= /datum/vampire/proc/vampire_veilstep
	ADD_VERB_IN_IF(user, 300, /datum/vampire/proc/vampire_veilstep, CALLBACK(user, /mob/living/carbon/human/proc/finish_vamp_timeout))

// Summons bats.
/datum/vampire/proc/vampire_bats()
	set category = "Vampire"
	set name = "Summon Bats (60)"
	set desc = "You tear open the Veil for just a moment, in order to summon a pair of bats to assist you in combat."
	var/power_use_cost = 60
	var/mob/living/carbon/human/user = usr
	var/datum/vampire/vampire = user.vampire_power(power_use_cost, 0)
	if (!vampire)
		return

	var/list/locs = list()

	for (var/direction in GLOB.alldirs)
		if (locs.len == 2)
			break

		var/turf/T = get_step(user, direction)
		if (AStar(user.loc, T, /turf/proc/AdjacentTurfs, /turf/proc/Distance, 1))
			locs += T

	var/list/spawned = list()
	if (locs.len)
		for (var/turf/to_spawn in locs)
			spawned += new /mob/living/simple_animal/hostile/scarybat(to_spawn, user)

		if (spawned.len != 2)
			spawned += new /mob/living/simple_animal/hostile/scarybat(user.loc, user)
	else
		spawned += new /mob/living/simple_animal/hostile/scarybat(user.loc, user)
		spawned += new /mob/living/simple_animal/hostile/scarybat(user.loc, user)

	if (!spawned.len)
		return

	for (var/mob/living/simple_animal/hostile/scarybat/bat in spawned)
		LAZYADD(bat.friends, weakref(user))

		if (vampire.thralls.len)
			LAZYADD(bat.friends, vampire.thralls)

	log_and_message_admins("summoned bats.")

	vampire.use_blood(power_use_cost)
	user.verbs -= /datum/vampire/proc/vampire_bats
	ADD_VERB_IN_IF(user, 1200, /datum/vampire/proc/vampire_bats, CALLBACK(user, /mob/living/carbon/human/proc/finish_vamp_timeout))

// Chiropteran Screech
/datum/vampire/proc/vampire_screech()
	set category = "Vampire"
	set name = "Chiropteran Screech (70)"
	set desc = "Emit a powerful screech which shatters glass within a seven-tile radius, and stuns hearers in a four-tile radius."
	var/power_use_cost = 70
	var/mob/living/carbon/human/user = usr
	var/datum/vampire/vampire = user.vampire_power(power_use_cost, 0)
	if (!vampire)
		return

	user.visible_message(SPAN_DANGER("[user.name] lets out an ear piercin shriek!"), SPAN_DANGER("You let out an ear-shattering shriek!"), SPAN_DANGER("You hear a painfully loud shriek!"))

	var/list/victims = list()

	for (var/mob/living/carbon/human/T in hearers(4, user))
		if(T == user)
			continue
		if(T.get_ear_protection() > 2)
			continue
		if(!can_affect_target(T, FALSE))
			continue

		to_chat(T, SPAN_DANGER("You hear an ear piercing shriek and feel your senses go dull!"))
		T.Weaken(5)
		T.ear_deaf = 20
		T.stuttering = 20
		T.Stun(5)

		victims += T

	for (var/obj/structure/window_frame/W in view(7))
		W.ex_act(2)

	for (var/obj/machinery/light/L in view(7))
		L.broken()

	playsound(user.loc, 'sound/effects/creepyshriek.ogg', 100, 1)
	vampire.use_blood(power_use_cost)

	if (victims.len)
		admin_attacker_log_many_victims(user, victims, "used chriopteran screech to stun", "was stunned by [key_name(user)] using chriopteran screech", "used chiropteran screech to stun")
	else
		log_and_message_admins("used chiropteran screech.")

	user.verbs -= /datum/vampire/proc/vampire_screech
	ADD_VERB_IN_IF(user, 3600, /datum/vampire/proc/vampire_screech, CALLBACK(user, /mob/living/carbon/human/proc/finish_vamp_timeout))

// Enables the vampire to be untouchable and walk through walls and other solid things.
/datum/vampire/proc/vampire_veilwalk()
	set category = "Vampire"
	set name = "Toggle Veil Walking (80)"
	set desc = "You enter the veil, leaving only an incorporeal manifestation of you visible to the others."
	var/power_use_cost = 80
	var/mob/living/carbon/human/user = usr

	var/datum/vampire/vampire = user.vampire_power(0, 0, 1)
	if (!vampire)
		return

	if (vampire.holder)
		vampire.holder.deactivate()
	else
		vampire = user.vampire_power(power_use_cost, 0, 1)
		if (!vampire)
			return

		var/obj/effect/dummy/veil_walk/holder = new /obj/effect/dummy/veil_walk(get_turf(user.loc))
		holder.activate(user)

		log_and_message_admins("activated veil walk.")

		vampire.use_blood(power_use_cost)

// Veilwalk's dummy holder
/obj/effect/dummy/veil_walk
	name = "a red ghost"
	desc = "A red, shimmering presence."
	icon = 'icons/mob/mob.dmi'
	icon_state = "blank"
	density = FALSE
	var/power_use_cost = 5

	var/last_valid_turf = null
	var/can_move = TRUE
	var/mob/owner_mob = null
	var/datum/vampire/owner_vampire = null
	var/warning_level = 0

/obj/effect/dummy/veil_walk/Destroy()
	eject_all()

	return ..()

/obj/effect/dummy/veil_walk/proc/eject_all()
	for (var/atom/movable/A in src)
		A.forceMove(loc)
		if (ismob(A))
			var/mob/M = A
			M.reset_view(null)

/obj/effect/dummy/veil_walk/relaymove(mob/user, direction)
	if (!can_move)
		return

	var/turf/new_loc = get_step(src, direction)
	if (new_loc.turf_flags & TURF_FLAG_NOJAUNT || istype(new_loc.loc, /area/chapel))
		to_chat(usr, SPAN_WARNING("Some strange aura is blocking the way!"))
		return

	forceMove(new_loc)
	var/turf/T = get_turf(loc)
	if (!T.contains_dense_objects())
		last_valid_turf = T

	can_move = 0
	addtimer(CALLBACK(src, .proc/unlock_move), 2, TIMER_UNIQUE)

/obj/effect/dummy/veil_walk/think()
	if (owner_mob.stat)
		if (owner_mob.stat == 1)
			to_chat(owner_mob, SPAN_WARNING("You cannot maintain this form while unconcious."))
			addtimer(CALLBACK(src, .proc/kick_unconcious), 10, TIMER_UNIQUE)
		else
			deactivate()
			return

	if (owner_vampire.blood_usable >= 5)
		owner_vampire.use_blood(power_use_cost)

		switch (warning_level)
			if (0)
				if (owner_vampire.blood_usable <= 5 * 20)
					to_chat(owner_mob, SPAN_NOTICE("Your pool of blood is diminishing. You cannot stay in the veil for too long."))
					warning_level = 1
			if (1)
				if (owner_vampire.blood_usable <= 5 * 10)
					to_chat(owner_mob, SPAN_WARNING("You will be ejected from the veil soon, as your pool of blood is running dry."))
					warning_level = 2
			if (2)
				if (owner_vampire.blood_usable <= 5 * 5)
					to_chat(owner_mob, SPAN_DANGER("You cannot sustain this form for any longer!"))
					warning_level = 3
	else
		deactivate()
		return

	set_next_think(world.time + 1 SECOND)

/obj/effect/dummy/veil_walk/proc/activate(mob/owner)
	if (!owner)
		qdel(src)
		return

	owner_mob = owner
	owner_vampire = owner.vampire_power()
	if (!owner_vampire)
		qdel(src)
		return

	owner_vampire.holder = src

	owner.vampire_phase_out(get_turf(owner.loc))

	icon_state = "shade"

	last_valid_turf = get_turf(owner.loc)
	owner.forceMove(src)

	desc += " Its features look faintly alike [owner.name]'s."

	set_next_think(world.time)

/obj/effect/dummy/veil_walk/proc/deactivate()
	set_next_think(0)
	can_move = 0

	icon_state = "blank"

	owner_mob.vampire_phase_in(get_turf(loc))

	eject_all()

	owner_mob = null

	owner_vampire.holder = null
	owner_vampire = null

	qdel(src)

/obj/effect/dummy/veil_walk/proc/unlock_move()
	can_move = 1

/obj/effect/dummy/veil_walk/proc/kick_unconcious()
	if (owner_mob && owner_mob.stat == 1)
		to_chat(owner_mob, SPAN_DANGER("You are ejected from the Veil."))
		deactivate()
		return

/obj/effect/dummy/veil_walk/ex_act(vars)
	return

/obj/effect/dummy/veil_walk/bullet_act(vars)
	return

/datum/vampire/proc/check_healing_continue(amount, mob/user)
	var/datum/vampire/vampire = user.vampire_power(0, 0)
	if(vampire.blood_usable < amount)
		to_chat(user, SPAN_WARNING("You ran out of blood, and are unable to continue!"))
		return FALSE
	return TRUE

// Heals the vampire at the cost of blood.
/datum/vampire/proc/vampire_bloodheal()
	set category = "Vampire"
	set name = "Blood Heal"
	set desc = "At the cost of blood and time, heal any injuries you have sustained."
	var/mob/living/carbon/human/user = usr
	var/datum/vampire/vampire = user.vampire_power(0, 0)
	if (!vampire)
		return

	// Kick out of the already running loop.
	if (vampire.status & VAMP_HEALING)
		vampire.status &= ~VAMP_HEALING
		return
	else if (vampire.blood_usable < 15)
		to_chat(user, SPAN_WARNING("You do not have enough usable blood. 15 needed."))
		return

	vampire.status |= VAMP_HEALING
	to_chat(user, SPAN_NOTICE("You begin the process of blood healing. Do not move, and ensure that you are not interrupted."))

	log_and_message_admins("activated blood heal.")

	while (do_after(user, 20, 0, incapacitation_flags = INCAPACITATION_DISABLED))
		if (!(vampire.status & VAMP_HEALING))
			to_chat(user, SPAN_WARNING("Your concentration is broken! You are no longer regenerating!"))
			break

		var/tox_loss = user.getToxLoss()
		var/oxy_loss = user.getOxyLoss()
		var/ext_loss = user.getBruteLoss() + user.getFireLoss()
		var/clone_loss = user.getCloneLoss()

		var/blood_used = 0
		var/to_heal = 0

		if (tox_loss)
			to_heal = min(10, tox_loss)
			user.adjustToxLoss(0 - to_heal)
			blood_used += round(to_heal * 1.2)
		if (oxy_loss)
			to_heal = min(10, oxy_loss)
			user.adjustOxyLoss(0 - to_heal)
			blood_used += round(to_heal * 1.2)
		if (ext_loss)
			to_heal = min(20, ext_loss)
			user.heal_overall_damage(min(10, user.getBruteLoss()), min(10, user.getFireLoss()))
			blood_used += round(to_heal * 1.2)
		if (clone_loss)
			to_heal = min(10, clone_loss)
			user.adjustCloneLoss(0 - to_heal)
			blood_used += round(to_heal * 1.2)

		var/temp_blood_used = blood_used
		vampire.use_blood(temp_blood_used)
		if (!vampire.check_healing_continue(15, user))
			break

		var/list/organs = user.get_damaged_organs(1, 1)
		if (organs.len)
			// Heal an absurd amount, basically regenerate one organ.
			user.heal_organ_damage(50, 50)
			blood_used += 12
			vampire.use_blood(blood_used - temp_blood_used)
			temp_blood_used = blood_used

		if (!vampire.check_healing_continue(15, user))
			break

		for(var/obj/item/organ/external/current_organ in organs)
			for(var/datum/wound/wound in current_organ.wounds)
				wound.embedded_objects.Cut()

			// remove embedded objects and drop them on the floor
			for(var/obj/implanted_object in current_organ.implants)
				if(!istype(implanted_object,/obj/item/implant))	// We don't want to remove REAL implants. Just shrapnel etc.
					implanted_object.loc = get_turf(user)
					current_organ.implants -= implanted_object

		for (var/A in organs)
			var/healed = FALSE
			var/obj/item/organ/external/E = A
			if(E.status & ORGAN_ARTERY_CUT)
				E.status &= ~ORGAN_ARTERY_CUT
				blood_used += 12
			if(E.status & ORGAN_TENDON_CUT)
				E.status &= ~ORGAN_TENDON_CUT
				blood_used += 12
			if(E.status & ORGAN_BROKEN)
				E.mend_fracture()
				E.stage = 0
				blood_used += 12
				healed = TRUE

			if (healed)
				vampire.use_blood(blood_used - temp_blood_used)
				temp_blood_used = blood_used
				break

		if (!vampire.check_healing_continue(15, user))
			break

		for(var/ID in user.virus2)
			var/datum/disease2/disease/V = user.virus2[ID]
			V.cure(user)

		var/mob/living/carbon/human/H = user
		for(var/limb_type in H.species.has_limbs)
			var/obj/item/organ/external/E = H.organs_by_name[limb_type]
			if(E && E.organ_tag != BP_HEAD && !E.vital && !E.is_usable())	//Skips heads and vital bits...
				E.removed()			//...because no one wants their head to explode to make way for a new one.
				qdel(E)
				E = null
			if(!E)
				var/list/organ_data = H.species.has_limbs[limb_type]
				var/limb_path = organ_data["path"]
				var/obj/item/organ/external/O = new limb_path(H)
				organ_data["descriptor"] = O.name
				to_chat(H, SPAN_DANGER("With a shower of dark blood, a new [O.name] forms."))
				H.visible_message(SPAN_DANGER("With a shower of dark blood, a length of biomass shoots from [H]'s [O.amputation_point], forming a new [O.name]!"))
				blood_used += 12
				vampire.use_blood(blood_used - temp_blood_used)
				temp_blood_used = blood_used
				var/datum/reagent/blood/B = new /datum/reagent/blood
				blood_splatter(H,B,1)
				O.set_dna(H.dna)
				H.update_body()
				break

		if (!vampire.check_healing_continue(15, user))
			break

		var/list/emotes_lookers = list("[user]'s skin appears to liquefy for a moment, sealing up their wounds.",
									"[user]'s veins turn black as their damaged flesh regenerates before your eyes!",
									"[user]'s skin begins to split open. It turns to ash and falls away, revealing the wound to be fully healed.",
									"Whispering arcane things, [user]'s damaged flesh appears to regenerate.",
									"Thick globs of blood cover a wound on [user]'s body, eventually melding to be one with \his flesh.",
									"[user]'s body crackles, skin and bone shifting back into place.")
		var/list/emotes_self = list("Your skin appears to liquefy for a moment, sealing up your wounds.",
									"Your veins turn black as their damaged flesh regenerates before your eyes!",
									"Your skin begins to split open. It turns to ash and falls away, revealing the wound to be fully healed.",
									"Whispering arcane things, your damaged flesh appears to regenerate.",
									"Thick globs of blood cover a wound on your body, eventually melding to be one with your flesh.",
									"Your body crackles, skin and bone shifting back into place.")

		if (prob(20))
			user.visible_message(SPAN_DANGER("[pick(emotes_lookers)]"), SPAN_NOTICE("[pick(emotes_self)]"))

		if (!blood_used)
			vampire.status &= ~VAMP_HEALING
			to_chat(user, SPAN_NOTICE("Your body has finished healing. You are ready to continue."))
			break

	// We broke out of the loop naturally. Gotta catch that.
	if (vampire.status & VAMP_HEALING)
		vampire.status &= ~VAMP_HEALING
		to_chat(user, SPAN_WARNING("Your concentration is broken! You are no longer regenerating!"))

	return

// Dominate a victim, using single word.
/datum/vampire/proc/vampire_order()
	set category = "Vampire"
	set name = "Order (20)"
	set desc = "Order the mind of a victim, make them obey your will."
	var/power_use_cost = 20
	var/mob/living/carbon/human/user = usr
	var/datum/vampire/vampire = user.vampire_power(power_use_cost, 0)
	if (!vampire)
		return
	vampire.vampire_dominate_handler(user, ability = "order")
	vampire.use_blood(power_use_cost)
	user.verbs -= /datum/vampire/proc/vampire_order
	ADD_VERB_IN_IF(user, 900, /datum/vampire/proc/vampire_order, CALLBACK(user, /mob/living/carbon/human/proc/finish_vamp_timeout))

// Dominate a victim, imbed a thought into their mind.
/datum/vampire/proc/vampire_suggestion()
	set category = "Vampire"
	set name = "Suggestion (50)"
	set desc = "Dominate the mind of a victim, make them obey your will."
	var/power_use_cost = 50
	var/mob/living/carbon/human/user = usr
	var/datum/vampire/vampire = user.vampire_power(power_use_cost, 0)
	if (!vampire)
		return
	vampire.vampire_dominate_handler(user, ability = "suggestion")
	vampire.use_blood(power_use_cost)
	user.verbs -= /datum/vampire/proc/vampire_suggestion
	ADD_VERB_IN_IF(user, 1800, /datum/vampire/proc/vampire_suggestion, CALLBACK(user, /mob/living/carbon/human/proc/finish_vamp_timeout))

/datum/vampire/proc/vampire_dominate_handler(caster, ability = "suggestion")
	var/datum/vampire/vampire = src
	var/mob/living/carbon/human/user = caster
	var/list/victims = list()
	for (var/mob/living/carbon/human/H in view(7))
		if (H == user)
			continue
		victims += H

	if (!victims.len)
		to_chat(user, SPAN_WARNING("No suitable targets."))
		return

	var/mob/living/carbon/human/T = input(user, "Select Victim") as null|mob in victims

	if(!can_affect_target(T, TRUE, TRUE))
		return

	if (!(vampire.status & VAMP_FULLPOWER))
		to_chat(user, SPAN_NOTICE("You begin peering into [T]'s mind, looking for a way to gain control."))

		if (!do_mob(user, T, 50, incapacitation_flags = INCAPACITATION_DISABLED))
			to_chat(user, SPAN_WARNING("Your concentration is broken!"))
			return

		to_chat(user, SPAN_NOTICE("You succeed in dominating [T]'s mind. They are yours to command."))
	else
		to_chat(user, SPAN_NOTICE("You instantly dominate [T]'s mind, forcing them to obey your command."))

	var/command
	if(ability == "suggestion")
		command = input(user, "Command your victim.", "Your command.") as text|null
	else if(ability == "order")
		command = input(user, "Command your victim with single word.", "Your command.") as text|null

	if (!command)
		to_chat(user, "<span class='alert'>Cancelled.</span>")
		return

	if(ability == "suggestion")
		command = sanitizeSafe(command, extra = 0)
	else if(ability == "order")
		command = sanitizeSafe(command)
		var/spaceposition = findtext_char(command, " ")
		if(spaceposition)
			command = copytext_char(command, 1, spaceposition+1)

	user.say(command)

	if (T.is_deaf() || !T.say_understands(user,user.get_default_language()))
		to_chat(user, SPAN("warning", "Target does not understand you!"))
		return

	admin_attack_log(user, T, "used dominate on [key_name(T)]", "was dominated by [key_name(user)]", "used dominate and issued the command of '[command]' to")

	show_browser(T, "<HTML><meta charset=\"utf-8\"><center>You feel a strong presence enter your mind. For a moment, you hear nothing but what it says, <b>and are compelled to follow its direction without question or hesitation:</b><br>[command]</center></BODY></HTML>", "window=vampiredominate")
	to_chat(T, SPAN_NOTICE("You feel a strong presence enter your mind. For a moment, you hear nothing but what it says, and are compelled to follow its direction without question or hesitation:"))
	to_chat(T, "<span style='color: green;'><i><em>[command]</em></i></span>")
	to_chat(user, SPAN_NOTICE("You command [T], and they will obey."))

	return

// Enthralls a person, giving the vampire a mortal slave.
/datum/vampire/proc/vampire_enthrall()
	set category = "Vampire"
	set name = "Enthrall (120)"
	set desc = "Bind a mortal soul with a bloodbond to obey your every command."
	var/power_use_cost = 120
	var/mob/living/carbon/human/user = usr
	var/datum/vampire/vampire = user.vampire_power(power_use_cost, 0)
	if (!vampire)
		return

	var/obj/item/grab/G = user.get_active_hand()
	if (!istype(G))
		to_chat(user, SPAN_WARNING("You must be grabbing a victim in your active hand to enthrall them."))
		return
	if(!G.can_absorb())
		to_chat(user, SPAN_WARNING("You must have a tighter grip on victim to enthrall them."))
		return

	var/mob/living/carbon/human/T = G.affecting
	if(!istype(T) || T.isSynthetic())
		to_chat(user, SPAN_WARNING("[T] is not a creature you can enthrall."))
		return
	if(!can_affect_target(T, TRUE, TRUE))
		return
	if (!T.client || !T.mind)
		to_chat(user, SPAN_WARNING("[T]'s mind is empty and useless. They cannot be forced into a blood bond."))
		return
	if (vampire.status & VAMP_DRAINING)
		to_chat(user, SPAN_WARNING("Your fangs are already sunk into a victim's neck!"))
		return

	user.visible_message(SPAN_DANGER("[user] tears the flesh on their wrist, and holds it up to [T]. In a gruesome display, [T] starts lapping up the blood that's oozing from the fresh wound."), SPAN_WARNING("You inflict a wound upon yourself, and force them to drink your blood, thus starting the conversion process"))
	to_chat(T, SPAN_WARNING("You feel an irresistable desire to drink the blood pooling out of [user]'s wound. Against your better judgement, you give in and start doing so."))

	if (!do_mob(user, T, 50))
		user.visible_message(SPAN_WARNING("[user] yanks away their hand from [T]'s mouth as they're interrupted, the wound quickly sealing itself!"), SPAN_DANGER("You are interrupted!"))
		return

	to_chat(T, SPAN_DANGER("Your mind blanks as you finish feeding from [user]'s wrist."))
	GLOB.thralls.add_antagonist(T.mind, 1, 1, 0, 1, 1)

	T.mind.vampire.master = user
	vampire.thralls += T
	to_chat(T, SPAN_NOTICE("You have been forced into a blood bond by [T.mind.vampire.master], and are thus their thrall. While a thrall may feel a myriad of emotions towards their master, ranging from fear, to hate, to love; the supernatural bond between them still forces the thrall to obey their master, and to listen to the master's commands.<br><br>You must obey your master's orders, you must protect them, you cannot harm them."))
	to_chat(user, SPAN_NOTICE("You have completed the thralling process. They are now your slave and will obey your commands."))
	admin_attack_log(user, T, "enthralled [key_name(T)]", "was enthralled by [key_name(user)]", "successfully enthralled")

	vampire.use_blood(power_use_cost)
	user.verbs -= /datum/vampire/proc/vampire_enthrall
	ADD_VERB_IN_IF(user, 2800, /datum/vampire/proc/vampire_enthrall, CALLBACK(user, /mob/living/carbon/human/proc/finish_vamp_timeout))

// Makes the vampire appear 'friendlier' to others.
/datum/vampire/proc/vampire_presence()
	set category = "Vampire"
	set name = "Presence (5)"
	set desc = "Influences those weak of mind to look at you in a friendlier light."
	var/power_use_cost = 5
	var/mob/living/carbon/human/user = usr
	var/datum/vampire/vampire = user.vampire_power(power_use_cost, 0)
	if (!vampire)
		return

	if (vampire.status & VAMP_PRESENCE)
		vampire.status &= ~VAMP_PRESENCE
		to_chat(user, SPAN_WARNING("You are no longer influencing those weak of mind."))
		return
	else if (vampire.blood_usable < 10)
		to_chat(user, SPAN_WARNING("You do not have enough usable blood. 10 needed."))
		return

	to_chat(user, SPAN_NOTICE("You begin passively influencing the weak minded."))
	vampire.status |= VAMP_PRESENCE

	var/list/mob/living/carbon/human/affected = list()
	var/list/emotes = list("[user] looks trusthworthy.",
							"You feel as if [user] is a relatively friendly individual.",
							"You feel yourself paying more attention to what [user] is saying.",
							"[user] has your best interests at heart, you can feel it.")

	vampire.use_blood(power_use_cost)

	log_and_message_admins("activated presence.")

	while (vampire.status & VAMP_PRESENCE)
		// Run every 20 seconds
		sleep(200)

		if (user.stat)
			to_chat(user, SPAN_WARNING("You cannot influence people around you while [user.stat == 1 ? "unconcious" : "dead"]."))
			vampire.status &= ~VAMP_PRESENCE
			break

		for (var/mob/living/carbon/human/T in view(5))
			if (T == user)
				continue
			if(!can_affect_target(T, FALSE, TRUE))
				continue
			if (!T.client)
				continue

			var/probability = 50
			if (!(T in affected))
				affected += T
				probability = 80

			if (prob(probability))
				to_chat(T, "<font color='green'><i>[pick(emotes)]</i></font>")

		vampire.use_blood(power_use_cost)

		if (vampire.blood_usable < 5)
			vampire.status &= ~VAMP_PRESENCE
			to_chat(user, SPAN_WARNING("You are no longer influencing those weak of mind."))
			break

// Makes the vampire appear alive.
/datum/vampire/proc/vampire_revitalise()
	set category = "Vampire"
	set name = "Revitalise (1)"
	set desc = "Allows you to hide among your prey."
	var/power_use_cost = 1
	var/mob/living/carbon/human/user = usr
	var/datum/vampire/vampire = user.vampire_power(power_use_cost, 0)
	if (!vampire)
		return

	if (isfakeliving(user))
		user.status_flags &= ~FAKELIVING
		to_chat(user, SPAN_WARNING("You no longer pretend to be prey."))
		return
	else if (vampire.blood_usable < 2)
		to_chat(user, SPAN_WARNING("You do not have enough usable blood. 2 needed."))
		return

	to_chat(user, SPAN_NOTICE("You begin hiding your true self."))
	user.status_flags |= FAKELIVING
	vampire.use_blood(power_use_cost)
	log_and_message_admins("activated revitalise.")
	addtimer(CALLBACK(vampire, /datum/vampire/proc/handle_revitalise), 20 SECONDS)
	return

/datum/vampire/proc/handle_revitalise()
	var/power_use_cost = 1
	var/mob/living/carbon/human/user = src.owner
	var/datum/vampire/vampire = user.vampire_power(power_use_cost, 0)
	if (!vampire)
		return

	if (isfakeliving(user))
		if (user.is_ooc_dead())
			to_chat(user, SPAN_WARNING("You cannot appear alive while dead"))
			user.status_flags &= ~FAKELIVING

		vampire.use_blood(power_use_cost)
		if (vampire.blood_usable < 5)
			user.status_flags &= ~FAKELIVING
			to_chat(user, SPAN_WARNING("You no longer pretend to be prey."))
			return
		addtimer(CALLBACK(vampire, /datum/vampire/proc/handle_revitalise), 20 SECONDS)
	return

/datum/vampire/proc/vampire_touch_of_life()
	set category = "Vampire"
	set name = "Touch of Life (30)"
	set desc = "You lay your hands on the target, transferring healing chemicals to them."
	var/power_use_cost = 30
	var/mob/living/carbon/human/user = usr
	var/datum/vampire/vampire = user.vampire_power(power_use_cost, 0)
	if (!vampire)
		return

	var/obj/item/grab/G = user.get_active_hand()
	if (!istype(G))
		to_chat(user, SPAN_WARNING("You must be grabbing a victim in your active hand to touch them."))
		return

	var/mob/living/carbon/human/T = G.affecting
	if (T.isSynthetic() || T.species.species_flags & SPECIES_FLAG_NO_BLOOD)
		to_chat(user, SPAN_WARNING("[T] has no blood and can not be affected by your powers!"))
		return

	user.visible_message("<b>[user]</b> gently touches [T].")
	to_chat(T, SPAN_NOTICE("You feel pure bliss as [user] touches you."))
	vampire.use_blood(power_use_cost)

	T.reagents.add_reagent(/datum/reagent/rezadone, 2)
	T.reagents.add_reagent(/datum/reagent/painkiller, 1.0) //enough to get back onto their feet

// Convert a human into a vampire.
/datum/vampire/proc/vampire_embrace()
	set category = "Vampire"
	set name = "The Embrace"
	set desc = "Spread your corruption to an innocent soul, turning them into a spawn of the Veil, much akin to yourself."
	var/power_use_cost = 0
	var/mob/living/carbon/human/user = usr
	var/datum/vampire/vampire = user.vampire_power(power_use_cost, 0)
	if (!vampire)
		return

	// Re-using blood drain code.
	var/obj/item/grab/G = user.get_active_hand()
	if (!istype(G))
		to_chat(user, SPAN_WARNING("You must be grabbing a victim in your active hand to drain their blood"))
		return
	if(!G.can_absorb())
		to_chat(user, SPAN_WARNING("You must have a tighter grip on victim to drain their blood."))
		return

	var/mob/living/carbon/human/T = G.affecting
	if(!can_affect_target(T, check_thrall = FALSE))
		return
	if (!T.client)
		to_chat(user, SPAN_WARNING("[T] is a mindless husk. The Veil has no purpose for them."))
		return
	if (T.stat == 2)
		to_chat(user, SPAN_WARNING("[T]'s body is broken and damaged beyond salvation. You have no use for them."))
		return
	if (T.isSynthetic() || T.species.species_flags & SPECIES_FLAG_NO_BLOOD)
		to_chat(user, SPAN_WARNING("[T] has no blood and can not be affected by your powers!"))
		return
	if (vampire.status & VAMP_DRAINING)
		to_chat(user, SPAN_WARNING("Your fangs are already sunk into a victim's neck!"))
		return

	if (T.mind.vampire)
		var/datum/vampire/draining_vamp = T.mind.vampire

		if (draining_vamp.status & VAMP_ISTHRALL)
			var/choice_text = ""
			var/denial_response = ""
			if (draining_vamp.master == user)
				choice_text = "[T] is your thrall. Do you wish to release them from the blood bond and give them the chance to become your equal?"
				denial_response = "You opt against giving [T] a chance to ascend, and choose to keep them as a servant."
			else
				choice_text = "You can feel the taint of another master running in the veins of [T]. Do you wish to release them of their blood bond, and convert them into a vampire, in spite of their master?"
				denial_response = "You choose not to continue with the Embrace, and permit [T] to keep serving their master."

			if (alert(user, choice_text, "Choices", "Yes", "No") == "No")
				to_chat(user, SPAN_NOTICE("[denial_response]"))
				return

			GLOB.thralls.remove_antagonist(T.mind, 0, 0)
			draining_vamp.status &= ~VAMP_ISTHRALL
		else
			to_chat(user, SPAN_WARNING("You feel corruption running in [T]'s blood. Much like yourself, \he[T] is already a spawn of the Veil, and cannot be Embraced."))
			return

	vampire.status |= VAMP_DRAINING

	user.visible_message(SPAN_DANGER("[user] bites [T]'s neck!"), SPAN_DANGER("You bite [T]'s neck and begin to drain their blood, as the first step of introducing the corruption of the Veil to them."), SPAN_NOTICE("You hear a soft puncture and a wet sucking noise."))

	to_chat(T, SPAN_NOTICE("You are currently being turned into a vampire. You will die in the course of this, but you will be revived by the end. Please do not ghost out of your body until the process is complete."))

	while (do_mob(user, T, 50))
		if (!user.mind.vampire)
			to_chat(user, "<span class='alert'>Your fangs have disappeared!</span>")
			return
		if (!T.vessel.get_reagent_amount(/datum/reagent/blood))
			to_chat(user, "<span class='alert'>[T] is now drained of blood. You begin forcing your own blood into their body, spreading the corruption of the Veil to their body.</span>")
			break

		T.vessel.remove_reagent(/datum/reagent/blood, 50)

	T.revive()

	// You ain't goin' anywhere, bud.
	if (!T.client && T.mind)
		for (var/mob/observer/ghost/ghost in GLOB.ghost_mob_list)
			if (ghost.mind == T.mind)
				ghost.can_reenter_corpse = 1
				ghost.reenter_corpse()

				to_chat(T, SPAN_DANGER("A dark force pushes you back into your body. You find yourself somehow still clinging to life."))

	T.Weaken(15)
	T.Stun(15)
	var/datum/antagonist/vampire/VAMP = GLOB.all_antag_types_[MODE_VAMPIRE]
	VAMP.add_antagonist(T.mind, 1, 1, 0, 0, 1)

	admin_attack_log(user, T, "successfully embraced [key_name(T)]", "was successfully embraced by [key_name(user)]", "successfully embraced and turned into a vampire")

	to_chat(T, SPAN_DANGER("You awaken. Moments ago, you were dead, your conciousness still forced stuck inside your body. Now you live. You feel different, a strange, dark force now present within you. You have an insatiable desire to drain the blood of mortals, and to grow in power."))
	to_chat(user, SPAN_WARNING("You have corrupted another mortal with the taint of the Veil. Beware: they will awaken hungry and maddened; not bound to any master."))

	T.mind.vampire.use_blood(T.mind.vampire.blood_usable)
	T.mind.vampire.frenzy = 50
	T.mind.vampire.check_frenzy()

	vampire.status &= ~VAMP_DRAINING

// Grapple a victim by leaping onto them.
/datum/vampire/proc/grapple()
	set category = "Vampire"
	set name = "Grapple"
	set desc = "Lunge towards a target like an animal, and grapple them."
	var/mob/living/carbon/human/user = usr
	if (user.status_flags & LEAPING)
		return
	if (user.incapacitated())
		to_chat(user, SPAN_WARNING("You cannot lean in your current state."))
		return

	var/list/targets = list()
	for (var/mob/living/carbon/human/H in view(4, user))
		targets += H

	targets -= user

	if (!targets.len)
		to_chat(user, SPAN_WARNING("No valid targets visible or in range."))
		return

	var/mob/living/carbon/human/T = pick(targets)

	user.visible_message(SPAN_DANGER("[user] leaps at [T]!"))
	user.drop_active_hand()
	user.throw_at(get_step(get_turf(T), get_turf(user)), 4, 1, user)
	user.status_flags |= LEAPING

	sleep(5)

	if (user.status_flags & LEAPING)
		user.status_flags &= ~LEAPING
	if (!user.Adjacent(T))
		to_chat(user, SPAN_WARNING("You miss!"))
		return

	T.Weaken(3)

	admin_attack_log(user, T, "lept at and grappled [key_name(T)]", "was lept at and grappled by [key_name(user)]", "lept at and grappled")


	user.visible_message(SPAN_WARNING("[user] seizes [T] aggressively!"))
	user.a_intent_change(I_GRAB)
	var/obj/item/grab/normal/G = new(user, T)
	user.put_in_active_hand(G)
	G.upgrade(TRUE)

	user.verbs -= /datum/vampire/proc/grapple
	ADD_VERB_IN_IF(user, 800, /datum/vampire/proc/grapple, CALLBACK(user, /mob/living/carbon/human/proc/finish_vamp_timeout, VAMP_FRENZIED))

/datum/vampire/proc/night_vision()
	set category = "Vampire"
	set name = "Toggle Darkvision"
	set desc = "You're are able to see in the dark."
	var/power_use_cost = 0
	var/mob/living/carbon/human/user = usr
	var/datum/vampire/vampire = user.vampire_power(power_use_cost, 0)
	if (!vampire)
		return

	var/mob/living/carbon/C = user
	C.seeDarkness = !C.seeDarkness
	if(C.seeDarkness)
		to_chat(C, SPAN("notice", "You're no longer need light to see."))
	else
		to_chat(C, SPAN("notice", "You're allow the shadows to return."))
	return TRUE
