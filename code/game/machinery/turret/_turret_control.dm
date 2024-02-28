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

	var/check_arrest = TRUE	//checks if the perp is set to arrest
	var/check_records = TRUE	//checks if a security record exists at all
	var/check_weapons = FALSE	//checks if it can shoot people that have a weapon they aren't authorized to have
	var/check_access = TRUE	//if this is active, the turret shoots everything that does not meet the access requirements
	var/check_anomalies = TRUE	//checks if it can shoot at unidentified lifeforms (ie xenos)
	var/check_synth = FALSE 	//if active, will shoot at anything not an AI or cyborg
	var/ailock = FALSE 	//Silicons cannot use this

	req_access = list(access_ai_upload)

/obj/machinery/turret_control_panel/Initialize(mapload)
	. = ..()
	signaler = new signaler()
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

	else
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
		ui = new(user, src, "TurretControlPanel", "Turret Control Panel")
		ui.open()

/obj/machinery/turret_control_panel/tgui_data(mob/user)
	var/list/data = list(
		"enabled" = enabled,
	)

	var/list/targeting_data = list(
		"lethalMode" = lethal,
		"checkSynth" = check_synth,
		"checkWeapon" = check_weapons,
		"checkRecords" = check_records,
		"checkArrests" = check_arrest,
		"checkAccess" = check_access,
		"checkAnomalies" = check_anomalies,
	)

	data["targetingData"] += targeting_data

	data["turrets"] = list()
	var/list/connected_turrets = get_connected_turrets()
	for(var/obj/machinery/turret/network/T in connected_turrets)
		var/list/turret_data = list()
		turret_data["turretSettings"] += T.get_gun_data()
		turret_data["turretSettings"] += T.get_turret_data()
		data["turrets"] += list(turret_data)

	return data

/obj/machinery/turret_control_panel/tgui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle")
			enabled = !enabled
			update_turrets()
			return TRUE

		if("lethal_mode")
			lethal = !lethal
			update_turrets()
			return TRUE

		if("check_synth")
			check_synth = !check_synth
			update_turrets()
			return TRUE

		if("check_weapon")
			check_weapons = !check_weapons
			update_turrets()
			return TRUE

		if("check_records")
			check_records = !check_records
			update_turrets()
			return TRUE

		if("check_arrest")
			check_arrest = !check_arrest
			update_turrets()
			return TRUE

		if("check_access")
			check_access = !check_access
			update_turrets()
			return TRUE

		if("check_anomalies")
			check_anomalies = !check_anomalies
			update_turrets()
			return TRUE

/obj/machinery/turret_control_panel/proc/update_turrets()
	var/list/turrets = get_connected_turrets()
	for(var/obj/machinery/turret/network/T in turrets)
		T.check_access = check_access
		T.check_weapons = check_weapons
		T.check_records = check_records
		T.check_arrest = check_arrest
		T.check_anomalies = check_anomalies
		T.check_synth = check_synth
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
