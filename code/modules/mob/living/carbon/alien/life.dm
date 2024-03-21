// Alien larva are quite simple.
/mob/living/carbon/alien/Life()
	set invisibility = 0
	set background = 1

	if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return
	if(!loc)
		return
	..()

	if(!is_ic_dead() && can_progress())
		update_progression()
	blinded = null
	//Status updates, death etc.
	update_icons()

/mob/living/carbon/alien/proc/can_progress()
	return 1

/mob/living/carbon/alien/updatehealth()
	if(is_ooc_dead())
		return FALSE

	if(status_flags & GODMODE)
		health = maxHealth
		set_stat(CONSCIOUS)
	else
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()
		if(health <= 0)
			death()
			return FALSE

	update_health_slowdown()

	return TRUE


// Currently both Dionaea and larvae like to eat radiation, so I'm defining the
// rad absorbtion here. This will need to be changed if other baby aliens are added.
/mob/living/carbon/alien/handle_mutations_and_radiation()
	if(radiation <= SAFE_RADIATION_DOSE)
		return
	var/rads = radiation / (0.05 SIEVERT)
	radiation = max(SPACE_RADIATION, radiation - rads)
	add_nutrition(rads)
	heal_overall_damage(rads, rads)
	adjustOxyLoss(-rads)
	adjustToxLoss(-rads)
	return

/mob/living/carbon/alien/handle_regular_status_updates()
	if(is_ooc_dead())
		blinded = 1
		silent = 0
		return 1 // We are dead for good

	updatehealth()

	if(paralysis && paralysis > 0)
		blinded = 1
		set_stat(UNCONSCIOUS)
		if(getHalLoss() > 0)
			adjustHalLoss(-3)

	if(sleeping)
		adjustHalLoss(-3)
		if(mind)
			if(mind.active && client != null)
				sleeping = max(sleeping - 1, 0)
		blinded = 1
		set_stat(UNCONSCIOUS)
	else if(resting)
		if(getHalLoss() > 0)
			adjustHalLoss(-3)
	else
		set_stat(CONSCIOUS)
		if(getHalLoss() > 0)
			adjustHalLoss(-1)

	// Eyes and blindness.
	if(!has_eyes())
		eye_blind = 1
		blinded = 1
		eye_blurry = 1
	else if(eye_blind)
		eye_blind = max(eye_blind - 1, 0)
		blinded = 1
	else if(eye_blurry)
		eye_blurry = max(eye_blurry - 1, 0)

	update_icons()

	return 1

/mob/living/carbon/alien/handle_regular_hud_updates()
	update_sight()

	if(!is_ooc_dead())
		if(blinded)
			overlay_fullscreen("blind", /atom/movable/screen/fullscreen/blind)
		else
			clear_fullscreen("blind")
			set_fullscreen(disabilities & NEARSIGHTED, "impaired", /atom/movable/screen/fullscreen/impaired, 1)
			set_renderer_filter(eye_blurry, SCENE_GROUP_RENDERER, EYE_BLURRY_FILTER_NAME, 0, EYE_BLURRY_FILTER(eye_blurry))
			set_fullscreen(druggy, "high", /atom/movable/screen/fullscreen/high)
		if(machine)
			if(machine.check_eye(src) < 0)
				reset_view(null)
		else
			if(client && !client.adminobs)
				reset_view(null)

	return 1

// Both alien subtypes survive in vaccum and suffer in high temperatures,
// so I'll just define this once, for both (see radiation comment above)
/mob/living/carbon/alien/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	if(environment.temperature > (66 CELSIUS))
		adjustFireLoss((environment.temperature - (66 CELSIUS))/5) // Might be too high, check in testing.
		if(fire)
			fire.icon_state = "fire2"
		if(prob(20))
			to_chat(src, "<span class='danger'>You feel a searing heat!</span>")
	else
		if(fire)
			fire.icon_state = "fire0"

/mob/living/carbon/alien/handle_fire()
	if(..())
		return
	bodytemperature += BODYTEMP_HEATING_MAX //If you're on fire, you heat up!
	return
