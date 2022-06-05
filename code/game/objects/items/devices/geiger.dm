//Geiger counter
//Rewritten version of TG's geiger counter
//I opted to show exact radiation levels

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
	var/radiation_count = 0

/obj/item/device/geiger/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/device/geiger/Process()
	if(!scanning)
		return
	radiation_count = SSradiation.get_rads_at_turf(get_turf(src))
	update_icon()

	THROTTLE(sound_cooldown, 1 SECOND)
	if(sound_cooldown)
		play_sound()

/obj/item/device/geiger/_examine_text(mob/user)
	. = ..()
	var/msg = "[scanning ? "ambient" : "stored"] Radiation level: [radiation_count ? radiation_count : "0"] Bq."
	if(radiation_count > RAD_LEVEL_LOW)
		. += "\n<span class='warning'>[msg]</span>"
	else
		. += "\n<span class='notice'>[msg]</span>"

/obj/item/device/geiger/attack_self(mob/user)
	scanning = !scanning
	if(scanning)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	update_icon()
	to_chat(user, "<span class='notice'>\icon[src] You switch [scanning ? "on" : "off"] [src].</span>")

/obj/item/device/geiger/update_icon()
	if(!scanning)
		icon_state = "geiger_off"
		return 1

	switch(radiation_count)
		if(null)
			icon_state = "geiger_on_0"
			return
		if(-INFINITY to 0)
			icon_state = "geiger_on_0"
			return
		if(0 to RAD_LEVEL_LOW)
			icon_state = "geiger_on_1"
			return
		if(RAD_LEVEL_LOW to RAD_LEVEL_MODERATE)
			icon_state = "geiger_on_2"
			return
		if(RAD_LEVEL_MODERATE to RAD_LEVEL_HIGH)
			icon_state = "geiger_on_3"
			return
		if(RAD_LEVEL_HIGH to RAD_LEVEL_VERY_HIGH)
			icon_state = "geiger_on_4"
			return
		if(RAD_LEVEL_VERY_HIGH to INFINITY)
			icon_state = "geiger_on_5"
			return

/obj/item/device/geiger/proc/play_sound()
	switch(radiation_count)
		if(0.1 to RAD_LEVEL_LOW)
			playsound(src, GET_SFX(SFX_GEIGER_LOW), 25, FALSE)
		if(RAD_LEVEL_LOW to RAD_LEVEL_MODERATE)
			playsound(src, GET_SFX(SFX_GEIGER_MODERATE), 25, FALSE)
		if(RAD_LEVEL_MODERATE to RAD_LEVEL_HIGH)
			playsound(src, GET_SFX(SFX_GEIGER_HIGH), 25, FALSE)
		if(RAD_LEVEL_HIGH to INFINITY)
			playsound(src, GET_SFX(SFX_GEIGER_VERY_HIGH), 25, FALSE)
