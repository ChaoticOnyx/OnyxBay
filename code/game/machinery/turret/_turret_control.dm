/obj/machinery/turret_control_panel
	name = "turret control panel"
	desc = "Used to control a room's automated defenses."
	icon = 'icons/obj/machines/turret_control.dmi'
	icon_state = "control_standby"
	anchored = TRUE
	density = FALSE
	var/enabled = FALSE
	var/lethal = FALSE
	var/locked = TRUE

	var/list/area/control_area //can be area name, path or nothing.
	var/mob/living/silicon/ai/master_ai

	/// Signaller
	var/obj/item/device/assembly/signaler/signaler = /obj/item/device/assembly/signaler

	var/datum/targeting_settings/targeting_settings = /datum/targeting_settings
	var/ailock = FALSE 	//Silicons cannot use this

	req_access = list(access_ai_upload)

/obj/machinery/turret_control_panel/Initialize(mapload, _signaler)
	. = ..()
	if(!_signaler && mapload)
		signaler = new signaler()
	if(_signaler)
		signaler = _signaler
		signaler.forceMove(src)

	targeting_settings = new (targeting_settings)

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/turret_control_panel/LateInitialize()
	. = ..()
	signaler.frequency = rand(RADIO_LOW_FREQ, RADIO_HIGH_FREQ)

	signaler.code = rand(1, 100)

	for(var/obj/machinery/turret/T in GLOB.all_turrets)
		var/area/turret_area = get_area(T)
		if(!is_type_in_list(turret_area, control_area))
			continue

		T.signaler?.frequency = signaler.frequency
		T.signaler?.code = signaler.code
		T.master_controller = weakref(src)

/obj/machinery/turret_control_panel/Destroy()
	QDEL_NULL(signaler)
	QDEL_NULL(targeting_settings)
	master_ai = null
	return ..()

/obj/machinery/turret_control_panel/proc/get_connected_turrets()
	. = list()
	for(var/obj/machinery/turret/T in GLOB.all_turrets)
		if(T.signaler?.frequency != signaler?.frequency)
			continue

		if(T.signaler?.code != signaler?.code)
			continue

		if(T.master_controller?.resolve() != src)
			T.master_controller = weakref(src)

		. += T

/obj/machinery/turret_control_panel/proc/isLocked(mob/user)
	if(ailock && issilicon(user))
		show_splash_text(user, "Blocked by firewall!")
		return TRUE

	if(malf_upgraded && master_ai)
		if((user == master_ai) || (user in master_ai.connected_robots))
			return FALSE
		return TRUE

	if(locked && !issilicon(user))
		show_splash_text(user, "Access denied!")
		return TRUE

	return FALSE

/obj/machinery/turret_control_panel/attackby(obj/item/W, mob/user)
	if(inoperable(MAINT))
		return ..()

	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/device/pda))
		if(allowed(usr))
			if(emagged)
				show_splash_text(user, "Control panel is unresponsive")
			else
				locked = !locked
				show_splash_text(user, "Panel [locked ? "locked" : "unlocked"]")
		return

	if(isWelder(W))
		var/obj/item/weldingtool/WT = W
		if(!WT.isOn())
			return

		if(WT.get_fuel() < 5)
			show_splash_text(user, "Not enough fuel!")

		playsound(loc, pick('sound/items/Welder.ogg', 'sound/items/Welder2.ogg'), 50, 1)
		if(do_after(user, 30 SECONDS, src))
			if(QDELETED(src) || !WT.remove_fuel(5, user))
				return

		show_splash_text(user, "External armor removed!")

		new /obj/structure/turret_control_frame(get_turf(src), istype(signaler) ? signaler : null, 5) //5 == BUILSTAGE_ARMOR_WELD

		qdel_self()
		return

	return ..()

/obj/machinery/turret_control_panel/emag_act(remaining_charges, mob/user)
	if(emagged)
		return FALSE

	playsound(src.loc, 'sound/effects/computer_emag.ogg', 25)
	show_splash_text(user, "Panel short circuted!")
	emagged = TRUE
	locked = FALSE
	ailock = FALSE
	return TRUE

/obj/machinery/turret_control_panel/attack_ai(mob/user)
	if(isLocked(user))
		return

	tgui_interact(user)

/obj/machinery/turret_control_panel/attack_hand(mob/user)
	if(isLocked(user))
		return

	tgui_interact(user)

/obj/machinery/turret_control_panel/tgui_interact(mob/user, datum/tgui/ui)
	. = ..()

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "TurretControl", "Turret Control Panel")
		ui.open()

/obj/machinery/turret_control_panel/tgui_data(mob/user)
	var/list/data = list()

	data["isEnabled"] = enabled

	data["turrets"] = list()
	for(var/obj/machinery/turret/network/T as anything in get_connected_turrets())
		data["turrets"] += list(list(
			"ref" = ref(T),
			"gunData" = T.get_gun_data(),
			"settingsData" = T.get_turret_data(),
		))

	data["targetingData"] = targeting_settings.tgui_data()

	return data

/obj/machinery/turret_control_panel/tgui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle")
			switch(params["check"])
				if("power")
					enabled = !enabled
					update_turrets()
					return TRUE

				if("mode")
					lethal = !lethal
					update_turrets()
					return TRUE

				if("synth")
					targeting_settings.check_synth = !targeting_settings.check_synth
					update_turrets()
					return TRUE

				if("weapon")
					targeting_settings.check_weapons = !targeting_settings.check_weapons
					update_turrets()
					return TRUE

				if("records")
					targeting_settings.check_records = !targeting_settings.check_records
					update_turrets()
					return TRUE

				if("arrest")
					targeting_settings.check_arrest = !targeting_settings.check_arrest
					update_turrets()
					return TRUE

				if("access")
					targeting_settings.check_access = !targeting_settings.check_access
					update_turrets()
					return TRUE

				if("anomalies")
					targeting_settings.check_anomalies = !targeting_settings.check_anomalies
					update_turrets()
					return TRUE

		if("changeBearing")
			var/turret_ref = params["ref"]
			if(isnull(turret_ref))
				return

			var/obj/machinery/turret/network/target_turret = locate(turret_ref)
			if(!istype(target_turret))
				return

			if(!(target_turret in get_connected_turrets()))
				return

			target_turret.change_bearing(usr)
			return TRUE

/obj/machinery/turret_control_panel/proc/update_turrets()
	var/list/turrets = get_connected_turrets()
	for(var/obj/machinery/turret/network/T in turrets)
		var/datum/targeting_settings/targ = T.targeting_settings
		targ.check_access = targeting_settings.check_access
		targ.check_weapons = targeting_settings.check_weapons
		targ.check_records = targeting_settings.check_records
		targ.check_arrest = targeting_settings.check_arrest
		targ.check_anomalies = targeting_settings.check_anomalies
		targ.check_synth = targeting_settings.check_synth
		T.toggle_enabled(override = enabled)
		T.lethal_nonlethal_switch()

/obj/machinery/turret_control_panel/on_update_icon()
	..()
	if(stat & NOPOWER)
		icon_state = "control_off"
		set_light(0)
	else if (enabled)
		if (lethal)
			icon_state = "control_kill"
			set_light(0.5, 0.5, 2, 2, "#990000")
		else
			icon_state = "control_stun"
			set_light(0.5, 0.5, 2, 2, "#ff9900")
	else
		icon_state = "control_standby"
		set_light(0.5, 0.5, 2, 2, "#003300")
