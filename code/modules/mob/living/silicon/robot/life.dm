/mob/living/silicon/robot/Life()

	if (stat)
		camera.status = 0.0
		if(stat == 2)
			return
	else

		updatehealth()

		if (health <= -100.0)
			death()
			return
		else if (health < 0)
			oxyloss++
	updateicon()

	//stage = 0
	if (client)

		var/isblind = 0

		if (cell)

			if(cell.charge <= 0)
				isblind = 1
				stat = 1
			else if (cell.charge <= 100)
				module_state_1 = null
				module_state_2 = null
				module_state_3 = null
				cell.use(1)
			else
				if(module_state_1)
					cell.use(5)
				if(module_state_2)
					cell.use(5)
				if(module_state_3)
					cell.use(5)
				cell.use(1)
				isblind = 0
				stat = 0
		else
			isblind = 1
			stat = 1

		if (!isblind)

			if (blind.layer!=0)
				blind.layer = 0
			see_in_dark = 8
			see_invisible = 2

		else
			blind.screen_loc = "1,1 to 15,15"
			if (blind.layer!=18)
				blind.layer = 18
			see_in_dark = 0
			see_invisible = 0

	handle_environment()

	handle_regular_hud_updates()

/mob/living/silicon/robot/var/oxygen_alert = 0
/mob/living/silicon/robot/var/fire_alert = 0
/mob/living/silicon/robot/var/temperature_alert = 0
/mob/living/silicon/robot/var/toxin_alert = 0

/mob/living/silicon/robot/proc/handle_environment()
	var/turf/simulated/T
	if (istype(loc, /turf/simulated))
		T = loc
	if (T)
		if (T.air)
			if(T.air.temperature > (T0C+66))
				fire_alert = 1
			else
				fire_alert = 0

			var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
			//var/safe_oxygen_max = 140 // Maximum safe partial pressure of O2, in kPa (Not used for now)
			var/safe_co2_max = 10
			var/safe_toxins_max = 0.5
			var/breath_pressure = (T.air.total_moles()*R_IDEAL_GAS_EQUATION*T.air.temperature)/BREATH_VOLUME

			var/O2_pp = (T.air.oxygen/T.air.total_moles())*breath_pressure
			var/Toxins_pp = (T.air.toxins/T.air.total_moles())*breath_pressure
			var/CO2_pp = (T.air.carbon_dioxide/T.air.total_moles())*breath_pressure

			if(O2_pp < safe_oxygen_min || CO2_pp > safe_co2_max)
				oxygen_alert = 1
			else
				oxygen_alert = 0
			if (Toxins_pp > safe_toxins_max)
				toxin_alert = 1
			else
				toxin_alert = 0
		else
			oxygen_alert = 1
	else
		oxygen_alert = 1
	var/turf/O = null

	if (isturf(loc))
		O = loc

	if (O)
		switch(O.temperature)	//Numbers are a bit arbitrary at the moment. Need to figure out a better way to do this.
			if(310 to INFINITY)
				temperature_alert = 2
			if(300 to 310)
				temperature_alert = 1
			if(287 to 300)
				temperature_alert = 0
			if(T0C to 287)
				temperature_alert = -1
			else
				temperature_alert = -2

/mob/living/silicon/robot/proc/handle_regular_hud_updates()
	if (healths)
		if (stat != 2)
			switch(health)
				if(30 to INFINITY)
					healths.icon_state = "health0"
				if(24 to 30)
					healths.icon_state = "health1"
				if(18 to 24)
					healths.icon_state = "health2"
				if(12 to 18)
					healths.icon_state = "health3"
				if(5 to 12)
					healths.icon_state = "health4"
				if (0 to 5)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

	if(pullin)	pullin.icon_state = "pull[pulling ? 1 : 0]"

	if (cell)
		if (cell_icon)
			if ((cell.charge / cell.maxcharge) > 0.75)
				cell_icon.icon_state = "charge4"
			else if ((cell.charge / cell.maxcharge) > 0.50)
				cell_icon.icon_state = "charge3"
			else if ((cell.charge / cell.maxcharge) > 0.25)
				cell_icon.icon_state = "charge2"
			else if ((cell.charge / cell.maxcharge) > 0)
				cell_icon.icon_state = "charge1"
			else
				cell_icon.icon_state = "charge0"
	else
		if (cell_icon)
			cell_icon.icon_state = "charge-empty"

	if (toxin) toxin.icon_state = "tox[toxin_alert ? 1 : 0]"
	if (oxygen) oxygen.icon_state = "oxy[oxygen_alert ? 1 : 0]"
	if (fire) fire.icon_state = "fire[fire_alert ? 1 : 0]"
	if (exttemp) exttemp.icon_state = "temp[temperature_alert]"

	return 1