#define REGULAR_HEARTBEAT 85
/obj/item/organ/internal/heart
	name = "heart"
	icon_state = "heart-on"
	organ_tag = "heart"
	parent_organ = BP_CHEST
	dead_icon = "heart-off"
	var/tmp/next_blood_squirt = 0
	relative_size = 15
	max_damage = 45
	var/open
	var/list/pulse_sources = list()
	var/pulse_modificator = PULSE_NORM
	var/heartbeat = REGULAR_HEARTBEAT 
	var/last_heartbeat = REGULAR_HEARTBEAT // for smoothly pulse changing

	var/last_fibrillation = 0
	var/last_asystole = 0

	var/last_pulse_stabilize = 0

/obj/item/organ/internal/heart/proc/blood_circulation_coefficent()
	if(BP_IS_ROBOTIC(src))
		return 1

	if(pulse_modificator == PULSE_FIBRILLATION)
		return 0.45 + rand(-0.1, 0.1)
	if(pulse_modificator == PULSE_NONE)
		return 0

	return heartbeat / 85

/obj/item/organ/internal/heart/proc/update_pulse_modificator()
	if(pulse_modificator == PULSE_FIBRILLATION || pulse_modificator == PULSE_NONE)
		return // asystole cannot get out self, fibrillation so.

	switch(heartbeat)
		if(-INFINITY to 60)
			pulse_modificator = PULSE_SLOW
		if(60 to 100)
			pulse_modificator = PULSE_NORM
		if(100 to 130)
			pulse_modificator = PULSE_FAST
		if(130 to 160)
			pulse_modificator = PULSE_2FAST
		if(160 to INFINITY)
			pulse_modificator = PULSE_THREADY

/obj/item/organ/internal/heart/proc/set_pulse(pulse, source="misc")
	pulse_sources[source] = pulse

// set_pulse with correction
/obj/item/organ/internal/heart/proc/set_pulse_fine(pulse, source="misc")
	set_pulse(pulse * (REGULAR_HEARTBEAT / heartbeat), source)

/obj/item/organ/internal/heart/proc/update_heartbeat()
	switch(pulse_modificator)
		if(PULSE_NONE)
			heartbeat = 0
			last_heartbeat = 0
			return

		if(PULSE_SLOW)
			heartbeat = 55 + rand(-15, 0)
		if(PULSE_NORM)
			heartbeat = 85 + rand(-15, 15)
		if(PULSE_FAST)
			heartbeat = 110 + rand(-10, 15)
		if(PULSE_2FAST)
			heartbeat = 140 + rand(-10, 15)
		if(PULSE_THREADY)
			heartbeat = 170 + rand(-20, 20)
		if(PULSE_FIBRILLATION)
			heartbeat = 210 + rand(-10, 50)

	for(var/source in pulse_sources)
		heartbeat += pulse_sources[source]


	if(heartbeat < 10)
		make_fibrillation()
		owner.reagents.add_reagent(/datum/reagent/adrenaline, 1)

	heartbeat = max(heartbeat, 0)

	heartbeat = Floor((heartbeat + last_heartbeat) / 2)
	last_heartbeat = heartbeat
	update_pulse_modificator()
	pulse_sources = list()

/obj/item/organ/internal/heart/die()
	if(dead_icon)
		icon_state = dead_icon
	..()

/obj/item/organ/internal/heart/robotize()
	. = ..()
	icon_state = "heart-prosthetic"

/obj/item/organ/internal/heart/Process()
	if(owner)
		handle_pulse()
		update_heartbeat()
		if(heartbeat)
			handle_heartbeat()
			var/chance = 0

			switch(pulse_modificator)
				if(PULSE_2FAST)
					chance = 1
				if(PULSE_THREADY)
					chance = 3
				if(PULSE_FIBRILLATION)
					chance = 5
			if(chance && prob(chance))
				take_internal_damage(0.5)

		handle_blood()
		handle_pulse_effects()
	..()

/obj/item/organ/internal/heart/proc/make_asystole()
	if(pulse_modificator == PULSE_NONE)
		return

	to_chat(owner, SPAN_DANGER("Your heart has stopped!"))
	pulse_modificator = PULSE_NONE
	last_asystole = world.time

/obj/item/organ/internal/heart/proc/make_fibrillation()
	if(pulse_modificator == PULSE_FIBRILLATION)
		return

	owner.custom_pain("Your heart burns!", 90, prob(10), owner.internal_organs_by_name[BP_CHEST])
	pulse_modificator = PULSE_FIBRILLATION
	last_fibrillation = world.time

/obj/item/organ/internal/heart/proc/handle_pulse()
	pulse_sources = list()

	if(owner.is_dead() || owner.status_flags & FAKEDEATH || owner.chem_effects[CE_NOPULSE] || BP_IS_ROBOTIC(src))
		pulse_modificator = PULSE_NONE
		return

	//If heart is stopped, it isn't going to restart itself randomly.
	if(pulse_modificator == PULSE_NONE)
		return

	var/should_fibrillation = prob(40) && owner.get_blood_circulation() <= BLOOD_VOLUME_SURVIVE
	should_fibrillation = should_fibrillation || (owner.shock_stage >= 120)
	should_fibrillation = should_fibrillation || ((heartbeat > 300) && !owner.chem_effects[CE_STABLE])
	should_fibrillation = should_fibrillation || owner.nervous_system_failure()

	var/should_stop = (pulse_modificator >= PULSE_FIBRILLATION && world.time - last_fibrillation > 30*TICKS_IN_SECOND)

	if(should_stop && (world.time - last_asystole > 50*TICKS_IN_SECOND))
		make_asystole()
		return

	if(should_fibrillation && (world.time - last_fibrillation > 25*TICKS_IN_SECOND) && pulse_modificator != PULSE_NONE)
		make_fibrillation()
		return

	set_pulse_fine(owner.chem_effects[CE_PULSE] * 25, "chem_effect")

	set_pulse_fine((owner.shock_stage / 30.0) * 20.0, "pain")

	switch(owner.get_blood_oxygenation())
		if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
			set_pulse_fine(20, "blood_volume")
			return
		if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
			set_pulse_fine(40, "blood_volume")
			return
		if(-INFINITY to BLOOD_VOLUME_SURVIVE)
			if(!owner.chem_effects[CE_STABLE])
				set_pulse_fine(80, "blood_volume")
			else
				set_pulse_fine(60, "blood_volume")
			return

	if(pulse_modificator == PULSE_FIBRILLATION || pulse_modificator == PULSE_NONE)
		return

	if(last_asystole || last_fibrillation)
		var/fibrillation_period = (world.time - last_fibrillation) / TICKS_IN_SECOND
		var/asystole_period = (world.time - last_asystole) / TICKS_IN_SECOND
		if(fibrillation_period > 300 || (asystole_period || fibrillation_period))
			last_fibrillation = 0
			fibrillation_period = 0

		if(asystole_period > 500)
			last_asystole = 0
			asystole_period = 0

		switch(fibrillation_period)
			if(1 to 150)
				set_pulse_fine(-40, "fibrillation_period")

			if(150 to INFINITY)
				set_pulse_fine(-30, "fibrillation_period")

		switch(asystole_period)
			if(1 to 150)
				set_pulse_fine(-55, "asystole_period")

			if(150 to 300)
				set_pulse_fine(-40, "asystole_period")

			if(300 to INFINITY)
				set_pulse_fine(-35, "asystole_period")

	if(is_damaged())
		set_pulse(-40, "damage_damaged")
	if(is_bruised())
		set_pulse(-40, "damage_bruised")
	if(is_broken())
		make_asystole()

	var/period = min(25 * TICKS_IN_SECOND - 5 * TICKS_IN_SECOND * owner.chem_effects[CE_STABLE], 5)
	if(pulse_modificator != PULSE_NORM && world.time - last_pulse_stabilize > period)
		last_pulse_stabilize = world.time
		if(pulse_modificator > PULSE_NORM)
			--pulse_modificator
		else
			++pulse_modificator

/obj/item/organ/internal/heart/proc/handle_pulse_effects()
	switch(pulse_modificator)
		if(PULSE_SLOW)
			owner.drowsyness = max(owner.drowsyness, 20)
		if(PULSE_2FAST)
			if(prob(12))
				to_chat(owner, SPAN("warning", "You feel [pick("dizzy","woozy","faint")]..."))
		if(PULSE_FIBRILLATION)
			owner.drowsyness = max(owner.drowsyness, 30)
			if(prob(7))
				owner.custom_pain("Your heart is hurting terribly!", 50, prob(10), owner.organs_by_name[BP_CHEST])



/obj/item/organ/internal/heart/proc/handle_heartbeat()
	switch(pulse_modificator)
		if(PULSE_2FAST)
			sound_to(owner, sound('sound/effects/heartbeat_2fast.ogg'))
		if(PULSE_THREADY)
			sound_to(owner, sound('sound/effects/heartbeat_thready.ogg'))
		if(PULSE_FIBRILLATION)
			sound_to(owner, sound('sound/effects/heartbeat_fibrillation.ogg'))

/obj/item/organ/internal/heart/proc/handle_blood()
	if(!owner)
		return

	//Dead or cryosleep people do not pump the blood.
	if(!owner || owner.InStasis() || owner.bodytemperature < 170)
		return

	if(pulse_modificator != PULSE_NONE || BP_IS_ROBOTIC(src))
		//Bleeding out
		var/blood_max = 0
		var/list/do_spray = list()
		for(var/obj/item/organ/external/temp in owner.organs)

			if(BP_IS_ROBOTIC(temp))
				continue

			var/open_wound
			if(temp.status & ORGAN_BLEEDING)

				for(var/datum/wound/W in temp.wounds)

					if(!open_wound && (W.damage_type == CUT || W.damage_type == PIERCE) && W.damage && !W.is_treated())
						open_wound = TRUE

					if(W.bleeding())
						if(temp.applied_pressure)
							if(ishuman(temp.applied_pressure))
								var/mob/living/carbon/human/H = temp.applied_pressure
								H.bloody_hands(src, 0)
							//somehow you can apply pressure to every wound on the organ at the same time
							//you're basically forced to do nothing at all, so let's make it pretty effective
							var/min_eff_damage = max(0, W.damage - 10) / 6 //still want a little bit to drip out, for effect
							blood_max += max(min_eff_damage, W.damage - 30) / 40
						else
							blood_max += W.damage / 40

			if(temp.status & ORGAN_ARTERY_CUT)
				var/bleed_amount = Floor((owner.vessel.total_volume / (temp.applied_pressure || !open_wound ? 400 : 250))*temp.arterial_bleed_severity)
				if(bleed_amount)
					if(open_wound)
						blood_max += bleed_amount
						do_spray += "the [temp.artery_name] in \the [owner]'s [temp.name]"
					else
						owner.vessel.remove_reagent(/datum/reagent/blood, bleed_amount)

		blood_max *= blood_circulation_coefficent()

		if(CE_STABLE in owner.chem_effects)
			blood_max *= 0.8

		if(world.time >= next_blood_squirt && istype(owner.loc, /turf) && do_spray.len)
			owner.visible_message("<span class='danger'>Blood squirts from [pick(do_spray)]!</span>")
			// It becomes very spammy otherwise. Arterial bleeding will still happen outside of this block, just not the squirt effect.
			next_blood_squirt = world.time + 100
			var/turf/sprayloc = get_turf(owner)
			blood_max -= owner.drip(ceil(blood_max/3), sprayloc)
			if(blood_max > 0)
				blood_max -= owner.blood_squirt(blood_max, sprayloc)
				if(blood_max > 0)
					owner.drip(blood_max, get_turf(owner))
		else
			owner.drip(blood_max)

/obj/item/organ/internal/heart/proc/is_working()
	if(!is_usable())
		return FALSE
	return pulse_modificator > PULSE_NONE || BP_IS_ROBOTIC(src) || (owner.status_flags & FAKEDEATH)

/obj/item/organ/internal/heart/listen()
	if(BP_IS_ROBOTIC(src) && is_working())
		if(is_bruised())
			return "sputtering pump"
		else
			return "steady whirr of the pump"


	if(owner.is_asystole() || (owner.status_flags & FAKEDEATH))
		return "no pulse"

	var/pulse_sound = "normal"
	if(is_damaged())
		pulse_sound = "erratic"
	else if(is_bruised())
		pulse_sound = "arrhythmic"

	pulse_sound += " "

	switch(pulse_modificator)
		if(PULSE_SLOW)
			pulse_sound += "slow"
		if(PULSE_FAST)
			pulse_sound += "accelerated"
		if(PULSE_2FAST)
			pulse_sound += "fast"
		if(PULSE_THREADY)
			pulse_sound += "very fast"
		if(PULSE_FIBRILLATION)
			pulse_sound += "almost inaudiable"

	var/noise_sound
	if(last_fibrillation || last_asystole)
		var/fibrillation_period = (world.time - last_fibrillation) / TICKS_IN_SECOND
		var/asystole_period = (world.time - last_asystole) / TICKS_IN_SECOND

		switch(fibrillation_period)
			if(1 to 150)
				noise_sound = "noise"

			if(150 to INFINITY)
				noise_sound = "faint noise"

		switch(asystole_period)
			if(1 to 150)
				noise_sound = "loud noise"

			if(150 to 300)
				noise_sound = "erratic noise"

			if(300 to 400)
				noise_sound = "noise"

			if(400 to INFINITY)
				noise_sound = "faint noise"

	. = "[pulse_sound] pulse"

	if(noise_sound)
		. += " with a [noise_sound]"
