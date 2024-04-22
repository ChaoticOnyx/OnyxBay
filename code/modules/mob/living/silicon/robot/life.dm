/mob/living/silicon/robot/Life()
	set invisibility = 0
	set background = 1

	if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return

	blinded = null

	//Status updates, death etc.
	clamp_values()
	handle_regular_status_updates()
	handle_actions()

	if(client)
		handle_regular_hud_updates()
		update_items()
	if(!is_ooc_dead()) //still using power
		use_power()
		process_killswitch()
		process_locks()
		process_queued_alarms()
	else
		if(connected_ai && !dead)
			notify_ai(ROBOT_NOTIFICATION_SIGNAL_LOST)
			dead = TRUE
	update_canmove()

/mob/living/silicon/robot/proc/clamp_values()
//	SetStunned(min(stunned, 30))
	SetParalysis(min(paralysis, 30))
//	SetWeakened(min(weakened, 20))
	sleeping = 0
	adjustBruteLoss(0)
	adjustToxLoss(0)
	adjustOxyLoss(0)
	adjustFireLoss(0)

/mob/living/silicon/robot/proc/use_power()
	used_power_this_tick = 0
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		C.update_power_state()

	if(cell && is_component_functioning("power cell") && cell.charge > 0)
		if(module_state_1)
			cell_use_power(50) // 50W load for every enabled tool TODO: tool-specific loads
		if(module_state_2)
			cell_use_power(50)
		if(module_state_3)
			cell_use_power(50)
		if(hud_used)
			hud_used.update_robot_modules_display()
		if(lights_on)
			if(intenselight)
				cell_use_power(100)	// Upgraded light. Double intensity, much larger power usage.
			else
				cell_use_power(30) 	// 30W light. Normal lights would use ~15W, but increased for balance reasons.

		has_power = TRUE
	else
		if(has_power)
			to_chat(src, "<span class='warning'>You are now running on emergency backup power.</span>")
		has_power = FALSE
		if(lights_on) // Light is on but there is no power!
			lights_on = FALSE
			set_light(0)

/mob/living/silicon/robot/handle_regular_status_updates()

	if(camera && !scrambledcodes)
		if(is_ic_dead() || wires.IsIndexCut(BORG_WIRE_CAMERA))
			camera.set_status(0)
		else
			camera.set_status(1)

	updatehealth()

	if(sleeping)
		Paralyse(3)
		sleeping--

	if(resting)
		Weaken(5)

	if(health < config.health.health_threshold_dead && !is_ooc_dead()) // die only once
		death()

	if(!is_ooc_dead()) // Alive.
		if(paralysis || stunned || weakened || !has_power) // Stunned etc.
			set_stat(UNCONSCIOUS)

			if(stunned > 0)
				AdjustStunned(-1)
			if(weakened > 0)
				AdjustWeakened(-1)
			if(paralysis > 0)
				AdjustParalysis(-1)
				blinded = TRUE
			else
				blinded = FALSE

		else // Not stunned.
			set_stat(CONSCIOUS)

		confused = max(0, confused - 1)

	else // Dead.
		blinded = TRUE
		set_stat(DEAD)

	if(stuttering)
		stuttering--

	if(eye_blind)
		eye_blind--
		blinded = TRUE

	if(ear_deaf > 0)
		ear_deaf--

	if(ear_damage < 25)
		ear_damage -= 0.05
		ear_damage = max(ear_damage, 0)

	set_density(!lying)

	if((sdisabilities & BLIND))
		blinded = TRUE
	if((sdisabilities & DEAF))
		ear_deaf = TRUE

	if(eye_blurry > 0)
		eye_blurry--
		eye_blurry = max(0, eye_blurry)

	if(druggy > 0)
		druggy--
		druggy = max(0, druggy)

	// update the state of modules and components here
	if(stat != 0)
		uneq_all()

	if(silicon_radio)
		silicon_radio.on = is_component_functioning("radio")

	blinded = !is_component_functioning("camera")

	return TRUE

/mob/living/silicon/robot/handle_regular_hud_updates()
	..()
	if(client)
		switch(sensor_mode)
			if(SEC_VISION)
				process_sec_hud(src, 1)
			if(MED_VISION)
				process_med_hud(src, 1)

	if(syndicate && client)
		for(var/datum/mind/traitor_mind in GLOB.traitors.current_antagonists)
			if(traitor_mind.current)
				// TODO: Update to new antagonist system.
				var/I = image('icons/mob/mob.dmi', loc = traitor_mind.current, icon_state = "traitor")
				client.images += I
		disconnect_from_ai()
		if(mind)
			// TODO: Update to new antagonist system.
			if(!mind.special_role)
				mind.special_role = "Traitor"
				GLOB.traitors.current_antagonists |= mind

	if(cells)
		if(cell)
			var/chargeNum = Clamp(ceil(CELL_PERCENT(cell) / 25), 0, 4)	//0-100 maps to 0-4, but give it a paranoid clamp just in case.
			cells.icon_state = "charge[chargeNum]"
		else
			cells.icon_state = "charge-empty"

	//Handle temperature/pressure differences between body and environment
	var/datum/gas_mixture/environment = loc.return_air()

	if(bodytemp)
		var/turf/T = get_turf(src)
		if(!environment || !T.air) // return_air() gives us something even in space so this
			bodytemp.icon_state = "temp?" // We are in space or something
		else
			switch(environment.temperature) // Showing environmental tempterature, not ours
				if(345 to INFINITY) // From russian banya to burning hell
					bodytemp.icon_state = "temp2"
				if(320 to 345)      // From normal to russian banya
					bodytemp.icon_state = "temp1"
				if(285 to 320)      // Normal
					bodytemp.icon_state = "temp0"
				if(270 to 285)      // From normal to approx. 0C
					bodytemp.icon_state = "temp-1"
				else                // From approx. 0C to frozen hell
					bodytemp.icon_state = "temp-2"

	if(oxygen)
		var/oxygen_alarm = 0
		if(!environment)
			oxygen_alarm = 1
		else
			var/env_pressure = environment.return_pressure()
			if(env_pressure < HAZARD_LOW_PRESSURE || env_pressure > HAZARD_HIGH_PRESSURE)
				oxygen_alarm = 1
			else
				var/breath_pressure = environment.total_moles * R_IDEAL_GAS_EQUATION * environment.temperature / BREATH_VOLUME
				var/human_inhale_efficiency = ((environment.gas["oxygen"] / environment.total_moles) * breath_pressure) / 16
				if(human_inhale_efficiency < 1) // Not enough for a meatbag to breathe
					oxygen_alarm = 1
				else if(((environment.gas["plasma"] / environment.total_moles) * breath_pressure) > 0.2) // Plasma in the air
					oxygen_alarm = 1

		oxygen.icon_state = "oxy[oxygen_alarm]"

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

	return TRUE

/mob/living/silicon/robot/handle_vision()
	..()

	if(client)
		clear_fullscreen("flash_protection")
		client.screen.Remove(GLOB.global_hud.nvg, GLOB.global_hud.thermal, GLOB.global_hud.meson, GLOB.global_hud.science, GLOB.global_hud.material)
		if(is_ooc_dead() || (MUTATION_XRAY in mutations) || (sensor_mode == XRAY_VISION))
			set_sight(sight|SEE_TURFS|SEE_MOBS|SEE_OBJS)
			set_see_in_dark(8)
			set_see_invisible(SEE_INVISIBLE_LEVEL_TWO)
		else switch(sensor_mode)
			if(THERMAL_VISION)
				set_sight(sight|SEE_MOBS)
				set_see_in_dark(8)
				set_see_invisible(SEE_INVISIBLE_NOLIGHTING)
				src.client.screen |= GLOB.global_hud.thermal
			if(MESON_VISION)
				set_sight(sight|SEE_TURFS)
				set_see_in_dark(8)
				set_see_invisible(SEE_INVISIBLE_NOLIGHTING)
				src.client.screen |= GLOB.global_hud.meson
			if(SCIENCE_VISION)
				src.client.screen |= GLOB.global_hud.science
			if(MATERIAL_VISION)
				set_sight(sight|SEE_OBJS)
				set_see_in_dark(8)
				src.client.screen |= GLOB.global_hud.material
			if(NVG_VISION)
				set_see_in_dark(7)
				set_see_invisible(SEE_INVISIBLE_NOLIGHTING)
				src.client.screen |= GLOB.global_hud.nvg
			if(FLASH_PROTECTION_VISION)
				overlay_fullscreen("flash_protection", /atom/movable/screen/fullscreen/impaired, TINT_MODERATE)
			else
				if(!is_ooc_dead())
					set_sight(sight&(~SEE_TURFS)&(~SEE_MOBS)&(~SEE_OBJS))
					set_see_in_dark(8)                      // see_in_dark means you can FAINTLY see in the dark, humans have a range of 3 or so, tajaran have it at 8
					set_see_invisible(SEE_INVISIBLE_LIVING) // This is normal vision (25), setting it lower for normal vision means you don't "see" things like darkness since darkness
															// has a "invisible" value of 15

/mob/living/silicon/robot/proc/update_items()
	if(client)
		client.screen -= contents
		for(var/obj/I in contents)
			if(I && !(istype(I, /obj/item/cell) || istype(I, /obj/item/device/radio)  || istype(I, /obj/machinery/camera) || istype(I, /obj/item/organ/internal/cerebrum/mmi)))
				client.screen += I
	if(module_state_1)
		module_state_1:screen_loc = ui_inv1
	if(module_state_2)
		module_state_2:screen_loc = ui_inv2
	if(module_state_3)
		module_state_3:screen_loc = ui_inv3

/mob/living/silicon/robot/proc/process_killswitch()
	if(killswitch)
		killswitch_time --
		if(killswitch_time <= 0)
			if(client)
				to_chat(src, SPAN("danger", "Killswitch Activated!"))
			killswitch = 0
			spawn(5)
				gib()

/mob/living/silicon/robot/proc/process_locks()
	if(weapon_lock)
		uneq_all()
		weaponlock_time --
		if(weaponlock_time <= 0)
			if(client)
				to_chat(src, SPAN("danger", "Weapon Lock Timed Out!"))
			weapon_lock = 0
			weaponlock_time = 120

/mob/living/silicon/robot/update_fire()
	CutOverlays(image("icon"='icons/mob/onfire.dmi', "icon_state" = "Standing"))
	if(on_fire)
		AddOverlays(image("icon"='icons/mob/onfire.dmi', "icon_state" = "Standing"))

/mob/living/silicon/robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()
