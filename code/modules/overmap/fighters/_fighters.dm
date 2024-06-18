/obj/structure/overmap/small_craft
	name = "Space Fighter"
	icon = 'icons/overmap/nanotrasen/fighter.dmi'
	icon_state = "fighter"
	anchored = TRUE
	brakes = TRUE
	bound_width = 64 //Change this on a per ship basis
	bound_height = 64
	mass = MASS_TINY
	overmap_deletion_traits = DAMAGE_ALWAYS_DELETES
	deletion_teleports_occupants = TRUE
	sprite_size = 32
	damage_states = TRUE
	max_integrity = 250 //Really really squishy!
	forward_maxthrust = 3.5
	backward_maxthrust = 3.5
	side_maxthrust = 4
	max_angular_acceleration = 180
	speed_limit = 7 //We want fighters to be way more maneuverable
	weapon_safety = TRUE //This happens wayy too much for my liking. Starts ON.
	pixel_w = -16
	pixel_z = -20
	var/flight_pixel_w = -30
	var/flight_pixel_z = -32
	pixel_collision_size_x = 32
	pixel_collision_size_y = 32 //Avoid center tile viewport jank
	req_one_access = list(access_sec_doors)
	var/start_emagged = FALSE
	var/max_passengers = 0 //Change this per fighter.
	//Component to handle the fighter's loadout, weapons, parts, the works.
	var/loadout_type = LOADOUT_DEFAULT_FIGHTER
	var/datum/component/ship_loadout/loadout = null
	var/obj/structure/fighter_launcher/mag_lock = null //Mag locked by a launch pad. Cheaper to use than locate()
	var/canopy_open = TRUE
	var/master_caution = FALSE //The big funny warning light on the dash.
	var/list/components = list() //What does this fighter start off with? Use this to set what engine tiers and whatever it gets.
	var/maintenance_mode = FALSE //Munitions level IDs can change this.
	var/obj/machinery/computer/ship/navigation/starmap = null
	var/resize_factor = 1 //How far down should we scale when we fly onto the overmap?
	//var/escape_pod_type = /obj/structure/overmap/small_craft/escapepod
	var/mutable_appearance/canopy
	var/random_name = TRUE
	overmap_verbs = list(.verb/toggle_brakes, .verb/toggle_inertia, .verb/toggle_safety, .verb/show_dradis, .verb/cycle_firemode, .verb/show_control_panel, .verb/change_name, .verb/countermeasure)
	var/busy = FALSE
	var/dradis_type = /obj/machinery/computer/ship/dradis/internal

/obj/structure/overmap/small_craft/Initialize(mapload, list/build_components=components)
	. = ..()
	if(random_name)
		name = "Redit Penis"
	apply_weapons()
	loadout = AddComponent(loadout_type)
	if(dradis_type)
		dradis = new dradis_type(src)
		dradis.linked = src
	set_light(4)
	integrity = max_integrity
	register_signal(src, SIGNAL_MOVED, nameof(.proc/handle_moved)) //Used to smoothly transition from ship to overmap
	var/obj/item/fighter_component/engine/engineGoesLast = null
	if(build_components.len)
		for(var/Ctype in build_components)
			var/obj/item/fighter_component/FC = new Ctype(get_turf(src), mapload)
			if(istype(FC, /obj/item/fighter_component/engine))
				engineGoesLast = FC
				continue

			loadout.install_hardpoint(FC)
	//Engines need to be the last thing that gets installed on init, or it'll cause bugs with drag.
	if(engineGoesLast)
		loadout.install_hardpoint(engineGoesLast)
	integrity = max_integrity //Update our health to reflect how much armour we've been given.
	set_fuel(rand(500, 1000))
	canopy = mutable_appearance(icon = icon, icon_state = "canopy_open")
	AddOverlays(canopy)
	update_icon()

/obj/structure/overmap/small_craft/Destroy()
	for(var/mob/M in operators)
		stop_piloting(M, eject_mob=FALSE) // We'll handle kicking them out ourselves

	if(length(mobs_in_ship))
		var/obj/structure/overmap/small_craft/escapepod = null
		if(!escapepod && deletion_teleports_occupants)
			var/list/copy_of_mobs_in_ship = mobs_in_ship.Copy()
			for(var/mob/living/M in copy_of_mobs_in_ship)
				to_chat(M, "<span class='warning'>This ship is not equipped with an escape pod! Unable to eject.</span>")
				M.apply_damage(200)
				eject(M, force=TRUE)

	last_overmap?.overmaps_in_ship -= src
	return ..()

/obj/structure/overmap/small_craft/start_piloting(mob/living/carbon/user, position)
	. = ..()
	if(.)
		register_signal(src, COMSIG_MOB_OVERMAP_CHANGE, nameof(.proc/pilot_overmap_change))

/obj/structure/overmap/small_craft/tgui_state(mob/user)
	return GLOB.contained_state

/obj/structure/overmap/small_craft/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FighterControls")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/structure/overmap/small_craft/tgui_data(mob/user)
	var/list/data = list()
	data["integrity"] = integrity
	data["max_integrity"] = max_integrity
	var/obj/item/fighter_component/armour_plating/A = loadout.get_slot(HARDPOINT_SLOT_ARMOUR)
	data["armour_integrity"] = (A) ? A.integrity : 0
	data["max_armour_integrity"] = (A) ? A.max_integrity : 100

	var/obj/item/fighter_component/battery/B = loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	data["battery_charge"] = B ? B.charge : 0
	data["battery_max_charge"] = B ? B.maxcharge : 0
	data["brakes"] = brakes
	data["inertial_dampeners"] = inertial_dampeners
	data["canopy_lock"] = canopy_open
	data["weapon_safety"] = weapon_safety
	data["master_caution"] = master_caution
	data["fuel_warning"] = get_fuel() <= get_max_fuel() * 0.4
	data["fuel"] = get_fuel()
	data["max_fuel"] = get_max_fuel()
	data["hardpoints"] = list()
	data["maintenance_mode"] = maintenance_mode
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	data["docking_mode"] = DC && DC.docking_mode

	var/obj/item/fighter_component/apu/APU = loadout.get_slot(HARDPOINT_SLOT_APU)
	data["fuel_pump"] = APU ? APU.fuel_line : FALSE

	var/obj/item/fighter_component/battery/battery = loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	data["battery"] = battery? battery.active : battery

	data["apu"] = APU.active
	var/obj/item/fighter_component/engine/engine = loadout.get_slot(HARDPOINT_SLOT_ENGINE)
	data["ignition"] = engine ? engine.active() : FALSE
	data["rpm"] = engine? engine.rpm : 0

	var/obj/item/fighter_component/ftl/ftl = loadout.get_slot(HARDPOINT_SLOT_FTL)
	if(ftl)
		data["ftl_capable"] = TRUE
		data["ftl_spool_progress"] = ftl.progress
		data["ftl_spool_time"] = ftl.spoolup_time
		data["jump_ready"] = ftl.progress >= ftl.spoolup_time
		data["ftl_active"] = ftl.active
		data["ftl_target"] = ftl.anchored_to?.name
	else
		data["ftl_capable"] = FALSE
		data["ftl_spool_progress"] = 0
		data["ftl_spool_time"] = 0
		data["jump_ready"] = FALSE
		data["ftl_active"] = FALSE
		data["ftl_target"] = FALSE

	var/list/hardpoints_info = list()
	var/list/occupants_info = list()
	for(var/obj/item/fighter_component/FC in contents)
		if(isliving(FC))
			var/mob/living/L = FC
			var/list/occupant_info = list()
			occupant_info["name"] = L.name
			occupant_info["id"] = "\ref[L]"
			occupant_info["afk"] = (L.mind) ? "Active" : "Inactive (SSD)"
			occupants_info[++occupants_info.len] = occupant_info
			continue

		if(!istype(FC))
			continue

		var/list/hardpoint_info = list()
		hardpoint_info["name"] = FC.name
		hardpoint_info["desc"] = FC.desc
		hardpoint_info["id"] = "\ref[FC]"
		hardpoints_info[++hardpoints_info.len] = hardpoint_info
	data["hardpoints"] = hardpoints_info
	data["occupants_info"] = occupants_info
	return data

/obj/structure/overmap/small_craft/tgui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	if(usr != pilot)
		return

	if(disruption && prob(min(95, disruption)))
		to_chat(src, "The controls buzz angrily.")
		relay('sound/machines/buzz-sigh.ogg')
		return

	var/atom/movable/target = locate(params["id"])
	switch(action)
		if("examine")
			if(!target)
				return

			to_chat(usr, SPAN_WARNING("[target.desc]"))

		if("eject_hardpoint")
			if(!target)
				return

			var/obj/item/fighter_component/FC = target
			if(!istype(FC))
				return

			to_chat(usr, SPAN_WARNING("You start uninstalling [target.name] from [src]."))
			if(!do_after(usr, 5 SECONDS, target = src))
				return

			to_chat(usr, SPAN_WARNING("You uninstall [target.name] from [src]."))
			loadout.remove_hardpoint(FC, FALSE)

		if("dump_hardpoint")
			if(!target)
				return

			var/obj/item/fighter_component/FC = target
			if(!istype(FC) || !FC.contents?.len)
				return

			to_chat(usr, SPAN_WARNING("You start to unload [target.name]'s stored contents..."))
			if(!do_after(usr, 5 SECONDS, target = src))
				return

			to_chat(usr, SPAN_WARNING("You dump [target.name]'s contents."))
			loadout.dump_contents(FC)

		if("kick")
			if(!target)
				return

			if(!allowed(usr) || usr != pilot)
				return

			var/mob/living/L = target
			to_chat(L, SPAN_WARNING("You have been kicked out of [src] by the pilot."))
			canopy_open = FALSE
			toggle_canopy()
			stop_piloting(L)

		if("fuel_pump")
			var/obj/item/fighter_component/apu/APU = loadout.get_slot(HARDPOINT_SLOT_APU)
			if(!APU)
				to_chat(usr, SPAN_WARNING("You can't send fuel to an APU that isn't installed."))
				return

			var/obj/item/fighter_component/engine/engine = loadout.get_slot(HARDPOINT_SLOT_ENGINE)
			if(!engine)
				to_chat(usr, SPAN_WARNING("You can't send fuel to an APU that isn't installed."))
			APU.toggle_fuel_line()

		if("battery")
			var/obj/item/fighter_component/battery/battery = loadout.get_slot(HARDPOINT_SLOT_BATTERY)
			if(!battery)
				to_chat(usr, SPAN_WARNING("[src] does not have a battery installed!"))
				return

			battery.toggle()
			to_chat(usr, "You flip the battery switch.</span>")

		if("apu")
			var/obj/item/fighter_component/apu/APU = loadout.get_slot(HARDPOINT_SLOT_APU)
			if(!APU)
				to_chat(usr, SPAN_WARNING("[src] does not have an APU installed!"))
				return

			APU.toggle()
			playsound(src, 'sound/effects/fighters/warmup.ogg', 100, FALSE)

		if("ignition")
			var/obj/item/fighter_component/engine/engine = loadout.get_slot(HARDPOINT_SLOT_ENGINE)
			if(!engine)
				to_chat(usr, SPAN_WARNING("[src] does not have an engine installed!"))
				return

			engine.try_start()

		if("canopy_lock")
			var/obj/item/fighter_component/canopy/canopy = loadout.get_slot(HARDPOINT_SLOT_CANOPY)
			if(!canopy)
				return

			toggle_canopy()

		if("docking_mode")
			var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
			if(!DC || !istype(DC))
				to_chat(usr, SPAN_WARNING("[src] does not have a docking computer installed!"))
				return

			to_chat(usr, SPAN_NOTICE("You [DC.docking_mode ? "disengage" : "engage"] [src]'s docking computer."))
			DC.docking_mode = !DC.docking_mode
			relay('sound/effects/fighters/switch.ogg')
			return

		if("brakes")
			toggle_brakes()
			relay('sound/effects/fighters/switch.ogg')
			return

		if("inertial_dampeners")
			toggle_inertia()
			relay('sound/effects/fighters/switch.ogg')
			return

		if("weapon_safety")
			toggle_safety()
			relay('sound/effects/fighters/switch.ogg')
			return

		if("master_caution")
			set_master_caution(FALSE)
			return

		if("show_dradis")
			dradis?.ui_interact(usr)
			return

		if("toggle_ftl")
			var/obj/item/fighter_component/ftl/ftl = loadout.get_slot(HARDPOINT_SLOT_FTL)
			if(!ftl)
				to_chat(usr, SPAN_WARNING("FTL unit not properly installed."))
				return
			ftl.toggle()
			relay('sound/effects/fighters/switch.ogg')

		if("anchor_ftl")
			var/obj/item/fighter_component/ftl/ftl = loadout.get_slot(HARDPOINT_SLOT_FTL)
			if(!ftl)
				to_chat(usr, SPAN_WARNING("FTL unit not properly installed."))
				return

			var/obj/structure/overmap/new_target = get_overmap()
			if(new_target)
				ftl.anchored_to = new_target
			else
				to_chat(usr, SPAN_WARNING("Unable to update telemetry. Ensure you are in proximity to a Seegson FTL drive."))
			relay('sound/effects/fighters/switch.ogg')

		if("return_jump")
			var/obj/item/fighter_component/ftl/ftl = loadout.get_slot(HARDPOINT_SLOT_FTL)
			if(!ftl)
				return

			if(ftl.ftl_state != FTL_STATE_READY)
				to_chat(usr, SPAN_WARNING("Unable to comply. FTL vector calculation still in progress."))
				return

			if(!ftl.anchored_to)
				to_chat(usr, SPAN_WARNING("Unable to comply. FTL tether lost."))
				return

			var/datum/star_system/dest = SSstar_system.ships[ftl.anchored_to]["current_system"]
			if(!dest)
				to_chat(usr, SPAN_WARNING("Unable to comply. Target beacon is currently in FTL transit."))
				return
			ftl.jump(dest)
			return

		if("set_name")
			var/new_name = tgui_input_text(usr, message="What do you want to name \
				your fighter? Keep in mind that particularly terrible names may be \
				rejected by your employers.")
			if(!new_name || length(new_name) <= 0)
				return
			name = new_name
			return

		if("toggle_maintenance")
			maintenance_mode = !maintenance_mode
			return

	relay('sound/effects/fighters/switch.ogg')

/obj/structure/overmap/small_craft/proc/toggle_canopy()
	canopy_open = !canopy_open
	playsound(src, 'sound/effects/fighters/canopy.ogg', 100, 1)

/obj/structure/overmap/small_craft/proc/get_max_fuel()
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	if(!ft)
		return 0
	return ft.reagents.maximum_volume

/obj/structure/overmap/small_craft/proc/empty_fuel_tank()
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	ft?.reagents.clear_reagents()

/obj/structure/overmap/small_craft/stop_piloting(mob/living/M, eject_mob = TRUE, force=  FALSE)
	if(eject_mob && !eject(M, force))
		return FALSE

	unregister_signal(src, COMSIG_MOB_OVERMAP_CHANGE)
	M.remove_verb(overmap_verbs)
	return ..()

/obj/structure/overmap/small_craft/proc/eject(mob/living/M, force=FALSE)
	var/obj/item/fighter_component/canopy/C = loadout.get_slot(HARDPOINT_SLOT_CANOPY)
	if(!canopy_open && C && !force)
		to_chat(M, SPAN_WARNING("[src]'s canopy isn't open."))
		if(prob(50))
			playsound(src, GET_SFX(SFX_GLASS_HIT), 75, 1)
			to_chat(M, SPAN_WARNING("You bump your head on [src]'s canopy."))
			visible_message(SPAN_WARNING("You hear a muffled thud."))
		return FALSE

	if(!force)
		to_chat(M, SPAN_WARNING("[src] won't let you jump out of it mid flight."))
		return FALSE

	DIRECT_OUTPUT(M, sound(null))
	mobs_in_ship -= M
	M.forceMove(get_turf(src))
	return TRUE

/obj/structure/overmap/small_craft/proc/pilot_overmap_change(mob/living/M, obj/structure/overmap/newOM) // in case we get forceMoved outside of the ship somehow
	SIGNAL_HANDLER
	if(newOM != src)
		INVOKE_ASYNC(src, nameof(.proc/stop_piloting), M, FALSE, TRUE)

/obj/structure/overmap/small_craft/proc/create_escape_pod(path, mob/last_pilot)
	pass()

/obj/structure/overmap/small_craft/attack_hand(mob/user)
	. = ..()
	if(allowed(user))
		if(pilot)
			to_chat(user, SPAN_NOTICE("[src] already has a pilot."))
			return FALSE
		if(do_after(user, 2 SECONDS, target=src))
			enter(user)
			start_piloting(user, OVERMAP_USER_ROLE_PILOT)
			to_chat(user, SPAN_NOTICE("You climb into [src]'s cockpit."))
			tgui_interact(user)
			return TRUE

/obj/structure/overmap/small_craft/proc/enter(mob/user)
	var/obj/structure/overmap/OM = user.get_overmap()
	if(OM)
		OM.mobs_in_ship -= user
	user.forceMove(src)
	mobs_in_ship |= user
	if(engines_active())
		DIRECT_OUTPUT(user, sound('sound/effects/fighters/cockpit.wav', repeat = TRUE, wait = 0, volume = 50, channel = SOUND_CHANNEL_SHIP_ALERT))

/obj/structure/overmap/small_craft/proc/handle_moved()
	pass()

/obj/structure/overmap/small_craft/can_move()
	return engines_active()

/obj/structure/overmap/proc/hardpoint_fire(atom/target, fireMode)
	if(istype(src, /obj/structure/overmap/small_craft))
		var/obj/structure/overmap/small_craft/F = src
		for(var/slot in F.loadout.equippable_slots)
			var/obj/item/fighter_component/weapon = F.loadout.hardpoint_slots[slot]
			if(!weapon || !weapon.active)
				continue

			weapon.fire(target)
			return TRUE

	return FALSE

/obj/structure/overmap/small_craft/touch_map_edge()
	var/obj/structure/overmap/O = get_overmap()
	if(istype(O))
		forceMove(O.loc)
	//	var/datum/star_system/SS = SSstar_system.ships[O]["current_system"]
//	if(!(O.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_OVERMAP)))
//		var/obj/structure/overmap/O =

/obj/structure/overmap/small_craft/get_delta_v()
	return forward_maxthrust
