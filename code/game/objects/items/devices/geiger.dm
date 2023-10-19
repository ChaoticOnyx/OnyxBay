/obj/item/device/geiger
	name = "geiger counter"
	desc = "A handheld device used for detecting and measuring radiation in an area."
	description_info = "By using this item, you may toggle its scanning mode on and off. Examine it while it's on to check for ambient radiation."
	description_fluff = "For centuries geiger counters have been saving the lives of unsuspecting laborers and technicians. You can never be too careful around radiation."
	icon_state = "geiger_off"
	item_state = "multitool"
	w_class = ITEM_SIZE_SMALL
	action_button_name = "Toggle geiger counter"
	var/scanning = 0
	var/radiation_dose = 0
	var/radiation_activity = 0
	var/list/rays = list()

/obj/item/device/geiger/think()
	if(!scanning)
		return

	radiation_dose = 0
	radiation_activity = 0
	rays = list()
	var/sources = SSradiation.get_sources_in_range(src)
	for(var/datum/radiation_source/source in sources)
		var/dose = source.calc_absorbed_dose_rt(src, AVERAGE_HUMAN_WEIGHT)

		if(dose > 0)
			radiation_dose += dose
			rays += source.info.ray_type
			radiation_activity += source.info.activity

	update_icon()

	play_sound()
	set_next_think(world.time + 1 SECOND)

/obj/item/device/geiger/_examine_text(mob/user)
	. = ..()
	var/msg = "[scanning ? "Ambient" : "Stored"] Radiation: [fmt_siunit(radiation_dose, "Gy", 3)].<br>"

	msg += "Detected rays: [length(rays) ? "<br>" : "none"]"
	var/list/printed_rays = list()
	for(var/ray in rays)
		if(ray in printed_rays)
			continue

		switch(ray)
			if(RADIATION_ALPHA_RAY)
				msg += "α-rays<br>"
			if(RADIATION_BETA_RAY)
				msg += "β-rays<br>"
			if(RADIATION_GAMMA_RAY)
				msg += "γ-rays<br>"
			if(RADIATION_HAWKING_RAY)
				msg += "Hawking rays<br>"
		
		printed_rays += ray

	if(radiation_dose > 0)
		. += "\n<span class='warning'>[msg]</span>"
	else
		. += "\n<span class='notice'>[msg]</span>"

/obj/item/device/geiger/attack_self(mob/user)
	scanning = !scanning

	if(scanning)
		set_next_think(world.time)
	else
		set_next_think(0)

	update_icon()
	to_chat(user, "<span class='notice'>\icon[src] You switch [scanning ? "on" : "off"] [src].</span>")

/obj/item/device/geiger/update_icon()
	if(!scanning)
		icon_state = "geiger_off"
		return 1

	switch(radiation_dose)
		if(null)
			icon_state = "geiger_on_0"
			return
		if(-INFINITY to SPACE_RADIATION)
			icon_state = "geiger_on_0"
			return
		if(SPACE_RADIATION to SAFE_RADIATION_DOSE)
			icon_state = "geiger_on_1"
			return
		if(SAFE_RADIATION_DOSE to (0.05 SIEVERT))
			icon_state = "geiger_on_2"
			return
		if((0.05 SIEVERT) to (0.25 SIEVERT))
			icon_state = "geiger_on_3"
			return
		if((0.25 SIEVERT) to (1 SIEVERT))
			icon_state = "geiger_on_4"
			return
		if((1 SIEVERT) to INFINITY)
			icon_state = "geiger_on_5"
			return

/obj/item/device/geiger/proc/play_sound()
	switch(radiation_activity)
		if((1 CURIE) to (100 CURIE))
			playsound(src, GET_SFX(SFX_GEIGER_LOW), 25, FALSE)
		if((1 KILO CURIE) to (50 KILO CURIE))
			playsound(src, GET_SFX(SFX_GEIGER_MODERATE), 25, FALSE)
		if((50 KILO CURIE) to (100 KILO CURIE))
			playsound(src, GET_SFX(SFX_GEIGER_HIGH), 25, FALSE)
		if((100 KILO CURIE) to INFINITY)
			playsound(src, GET_SFX(SFX_GEIGER_VERY_HIGH), 25, FALSE)
