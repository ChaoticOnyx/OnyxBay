#define CYBORG_POWER_USAGE_MULTIPLIER 2.5 // Multiplier for amount of power cyborgs use.

/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 200
	health = 200
	ignore_pull_slowdown = TRUE // Steel be strong

	mob_bump_flag = ROBOT
	mob_swap_flags = ROBOT|MONKEY|METROID|SIMPLE_ANIMAL
	mob_push_flags = ~HEAVY //trundle trundle

	blocks_emissive = EMISSIVE_BLOCK_NONE

	var/lights_on = 0 // Is our integrated light on?
	var/used_power_this_tick = 0
	var/sight_mode = 0
	var/custom_name = ""
	var/crisis //Admin-settable for combat module use.
	var/crisis_override = 0
	var/integrated_light_max_bright = 0.75
	var/datum/wires/robot/wires

	/// Whether this type of robot supports custom icons
	var/custom_sprite = TRUE
	/// Default hull typepath
	var/default_hull = /datum/robot_hull/spider/robot

	var/static/list/eye_overlays
	/// Key used to look up an appropriate hull datum in the `module_hulls`
	var/icontype
	/// Whether this mob've chosen a custom icon
	var/icon_chosen = FALSE
	/// List of avaliable robot hulls
	var/datum/robot_hull/module_hulls[0]

//Hud stuff

	var/atom/movable/screen/inv1 = null
	var/atom/movable/screen/inv2 = null
	var/atom/movable/screen/inv3 = null

	var/shown_robot_modules = 0 //Used to determine whether they have the module menu shown or not
	var/atom/movable/screen/robot_modules_background

//3 Modules can be activated at any one time.
	var/obj/item/robot_module/module = null
	var/module_active = null
	var/module_state_1 = null
	var/module_state_2 = null
	var/module_state_3 = null

	silicon_camera = /obj/item/device/camera/siliconcam/robot_camera
	silicon_radio = /obj/item/device/radio/borg

	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/cell/cell = /obj/item/cell/high
	var/obj/machinery/camera/camera = null

	var/cell_emp_mult = 2

	// Components are basically robot organs.
	var/list/components = list()

	var/obj/item/organ/internal/cerebrum/mmi = null

	var/obj/item/device/pda/ai/rbPDA = null

	var/obj/item/stock_parts/matter_bin/storage = null

	var/opened = 0
	var/emagged = 0
	var/emag_master = null
	var/wiresexposed = 0
	var/locked = 1
	var/has_power = 1
	var/dead = 0
	var/spawn_module = null

	var/spawn_sound = 'sound/voice/liveagain.ogg'
	var/pitch_toggle = 1
	var/list/req_access = list(access_robotics)
	var/ident = 0
	var/viewalerts = 0
	var/modtype = "Default"
	var/selected_module
	var/restore_modtype_in_global_pull = FALSE
	var/lower_mod = 0
	var/jetpack = 0
	var/datum/effect/effect/system/trail/ion/ion_trail = null
	var/datum/effect/effect/system/spark_spread/spark_system//So they can initialize sparks whenever/N
	var/jeton = 0
	var/killswitch = 0
	var/killswitch_time = 60
	var/weapon_lock = 0
	var/weaponlock_time = 120
	var/lawupdate = 1 //Cyborgs will sync their laws with their AI by default
	var/lockcharge //If a robot is locked down
	var/speed = 0 //Cause sec borgs gotta go fast //No they dont!
	var/scrambledcodes = 0 // Used to determine if a borg shows up on the robotics console.  Setting to one hides them.
	var/tracking_entities = 0 //The number of known entities currently accessing the internal camera
	var/braintype = "Cyborg"
	var/intenselight = 0	// Whether cyborg's integrated light was upgraded
	var/footstep_sound = null

	var/list/robot_verbs_default = list(
		/mob/living/silicon/robot/proc/sensor_mode,
		/mob/living/silicon/robot/proc/robot_checklaws,
		/mob/living/silicon/robot/proc/ResetSecurityCodes
	)

/mob/living/silicon/robot/New(loc, unfinished = 0)
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	add_language(LANGUAGE_ROBOT, 1)
	add_language(LANGUAGE_EAL, 1)

	wires = new(src)

	robot_modules_background = new()
	robot_modules_background.icon = 'icons/hud/common/screen_storage.dmi'
	robot_modules_background.icon_state = "block"
	ident = random_id(/mob/living/silicon/robot, 1, 999)

	module_hulls["Default"] = new default_hull
	apply_hull("Default")

	updatename(modtype)

	if(!scrambledcodes && !camera)
		camera = new /obj/machinery/camera(src)
		camera.c_tag = real_name
		camera.replace_networks(list(NETWORK_EXODUS,NETWORK_ROBOTS))
		if(wires.IsIndexCut(BORG_WIRE_CAMERA))
			camera.status = 0

	..() // Laws, among other things, are initialized in parent New()
	init()
	initialize_components()
	//if(!unfinished)
	// Create all the robot parts.
	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.installed = 1
		C.wrapped = new C.external_type

	if(ispath(cell))
		cell = new cell(src)

	if(cell)
		var/datum/robot_component/cell_component = components["power cell"]
		cell_component.wrapped = cell
		cell_component.installed = 1

	add_robot_verbs()

	hud_list[HEALTH_HUD]      = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD]      = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[LIFE_HUD]        = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[ID_HUD]          = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[WANTED_HUD]      = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]    = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD] = new /image/hud_overlay('icons/mob/huds/antag_hud.dmi', src, "hudblank")

/mob/living/silicon/robot/Initialize()
	. = ..()
	AddMovementHandler(/datum/movement_handler/robot/use_power, /datum/movement_handler/mob/space)

/mob/living/silicon/robot/proc/recalculate_synth_capacities()
	if(!module || !module.synths)
		return
	var/mult = 1
	if(storage)
		mult += storage.rating
	for(var/datum/matter_synth/M in module.synths)
		M.set_multiplier(mult)

/mob/living/silicon/robot/proc/init()
	if(ispath(module))
		new module(src)
	if(lawupdate)
		var/new_ai = select_active_ai_with_fewest_borgs()
		if(new_ai)
			lawupdate = 1
			connect_to_ai(new_ai)
		else
			lawupdate = 0

	playsound(loc, spawn_sound, 75, pitch_toggle)

/mob/living/silicon/robot/fully_replace_character_name(pickedName as text)
	custom_name = pickedName
	updatename()

/mob/living/silicon/robot/proc/sync()
	if(lawupdate && connected_ai)
		lawsync()
		photosync()

/mob/living/silicon/robot/drain_power(drain_check, surge, amount = 0)

	if(drain_check)
		return 1

	if(!cell || !cell.charge)
		return 0

	// Actual amount to drain from cell, using CELLRATE
	var/cell_amount = amount * CELLRATE

	if(cell.charge > cell_amount)
		// Spam Protection
		if(prob(10))
			to_chat(src, "<span class='danger'>Warning: Unauthorized access through power channel [rand(11,29)] detected!</span>")
		cell.use(cell_amount)
		return amount
	return 0

// setup the PDA and its name
/mob/living/silicon/robot/proc/setup_PDA()
	if (!rbPDA)
		rbPDA = new /obj/item/device/pda/ai(src)
	rbPDA.set_name_and_job(custom_name,"[modtype] [braintype]")

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
//Improved /N
/mob/living/silicon/robot/Destroy()
	if(mmi)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		if(mind)
			mmi.dropInto(loc)
			if(mmi.brainmob)
				mind.transfer_to(mmi.brainmob)
			else
				to_chat(src, "<span class='danger'>Oops! Something went very wrong, your MMI was unable to receive your mind. You have been ghosted. Please make a bug report so we can fix this bug.</span>")
				ghostize()
				//ERROR("A borg has been destroyed, but its MMI lacked a brainmob, so the mind could not be transferred. Player: [ckey].")
			mmi = null
		else
			QDEL_NULL(mmi)

	if(connected_ai)
		connected_ai.connected_robots -= src
	connected_ai = null

	if(restore_modtype_in_global_pull)
		GLOB.robot_module_types |= modtype

	QDEL_NULL(wires)
	QDEL_NULL(module)
	QDEL_NULL(inv1)
	QDEL_NULL(inv2)
	QDEL_NULL(inv3)
	QDEL_NULL(robot_modules_background)
	QDEL_NULL(rbPDA)
	QDEL_NULL(camera)
	QDEL_NULL(storage)
	QDEL_NULL(spark_system)
	QDEL_NULL(ion_trail)
	for(var/i in components)
		qdel(components[i])
	components.Cut()
	QDEL_NULL(cell)
	return ..()

/mob/living/silicon/robot/proc/apply_hull(new_icontype)
	if(!(new_icontype in module_hulls))
		return

	var/datum/robot_hull/new_hull = module_hulls[new_icontype]
	var/list/icon_states = icon_states(new_hull.icon)
	if(!(new_hull.icon_state in icon_states))
		return

	icontype = new_icontype
	icon = new_hull.icon
	icon_state = new_hull.icon_state
	footstep_sound = new_hull.footstep_sound

	update_icon()

	return TRUE

/mob/living/silicon/robot/proc/set_module_hulls(list/new_sprites)
	if(length(new_sprites))
		module_hulls = new_sprites.Copy()
		if(custom_sprite)
			custom_sprite = (ckey in GLOB.robot_custom_icons)
		// Custom_sprite check and entry
		if(custom_sprite && CUSTOM_ITEM_ROBOTS)
			var/list/customs = GLOB.robot_custom_icons[ckey]
			var/list/valid_states = icon_states(CUSTOM_ITEM_ROBOTS)
			for(var/list/custom_data in customs)
				var/sprite_state = custom_data["item_state"]
				var/footstep = custom_data["footstep"]
				if(sprite_state && (sprite_state in valid_states))
					if(module_hulls[sprite_state])
						qdel(module_hulls[sprite_state])
						module_hulls[sprite_state] = null
					module_hulls[sprite_state] = new /datum/robot_hull(CUSTOM_ITEM_ROBOTS, sprite_state, footstep)
	return module_hulls

/mob/living/silicon/robot/proc/choose_module()
	if(module)
		to_chat(usr, SPAN("notice", "You have already selected a module."))
		return
	var/list/modules = list()
	modules.Add(GLOB.robot_module_types)
	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
	if((crisis && security_state.current_security_level_is_same_or_higher_than(security_state.high_security_level)) || crisis_override) //Leaving this in until it's balanced appropriately.
		to_chat(src, SPAN("warning", "Crisis mode active. Combat module available."))
		modules += "Combat"
	selected_module = tgui_input_list(src, "Please, select a module!", "Module Selection", modules)
	if(!(selected_module in GLOB.robot_module_types))
		return
	setup_module()

/mob/living/silicon/robot/proc/setup_module()
	if(module)
		to_chat(usr, SPAN("notice", "You have already selected a module."))
		return
	modtype = selected_module
	restore_modtype_in_global_pull = TRUE
	sensor_mode = 0
	active_hud = null

	var/module_type = GLOB.robot_modules[modtype]
	new module_type(src)
	if(modtype != "Standard")
		GLOB.robot_module_types.Remove(modtype)
	hands.icon_state = lowertext(modtype)
	feedback_inc("cyborg_[lowertext(modtype)]",1)
	updatename()
	recalculate_synth_capacities()

	if(module)
		notify_ai(ROBOT_NOTIFICATION_NEW_MODULE, module.name)


/mob/living/silicon/robot/proc/updatename(prefix)
	if(prefix)
		modtype = prefix

	if(istype(mmi, /obj/item/organ/internal/cerebrum/posibrain))
		braintype = "Android"
	else
		braintype = "Cyborg"

	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
		notify_ai(ROBOT_NOTIFICATION_NEW_NAME, real_name, changed_name)
	else
		changed_name = "[modtype] [braintype]-[num2text(ident)]"

	real_name = changed_name
	name = real_name
	if(mind)
		mind.name = changed_name

	// if we've changed our name, we also need to update the display name for our PDA
	setup_PDA()

	//We also need to update name of internal camera.
	if (camera)
		camera.c_tag = changed_name

	//Flavour text.
	if(client)
		var/module_flavour = client.prefs.flavour_texts_robot[modtype]
		if(module_flavour)
			flavor_text = module_flavour
		else
			flavor_text = client.prefs.flavour_texts_robot["Default"]

/mob/living/silicon/robot/verb/Namepick()
	set category = "Silicon Commands"
	if(custom_name)
		return 0

	spawn(0)
		var/newname
		newname = sanitizeSafe(input(src,"You are a robot. Enter a name, or leave blank for the default name.", "Name change","") as text, MAX_NAME_LEN)
		if (newname)
			custom_name = newname

		updatename()
		update_icon()

// this verb lets cyborgs see the stations manifest
/mob/living/silicon/robot/verb/cmd_station_manifest()
	set category = "Silicon Commands"
	set name = "Show Crew Manifest"
	show_station_manifest()

/mob/living/silicon/robot/proc/self_diagnosis()
	if(!is_component_functioning("diagnosis unit"))
		return null

	var/dat = "<meta charset=\"utf-8\"><HEAD><TITLE>[src.name] Self-Diagnosis Report</TITLE></HEAD><BODY>\n"
	if (module)
		var/visors = ""
		dat += "<b>Supported upgrades for [module]:</b><br>\n"
		for(var/i in module.supported_upgrades)
			var/atom/tmp = i
			if(findtext("[tmp]","/obj/item/borg/upgrade/visor/"))
				visors += "[initial(tmp.name)]<br>"
			else
				dat += "[initial(tmp.name)]<br>"
		dat += "<b>Supported visors for [module]:<br></b>\n"
		dat += visors
		dat += "<hr>"
	for (var/V in components)
		var/datum/robot_component/C = components[V]
		dat += "<b>[C.name]</b><br><table><tr><td>Brute Damage:</td><td>[C.brute_damage]</td></tr><tr><td>Electronics Damage:</td><td>[C.electronics_damage]</td></tr><tr><td>Powered:</td><td>[(!C.idle_usage || C.is_powered()) ? "Yes" : "No"]</td></tr><tr><td>Toggled:</td><td>[ C.toggled ? "Yes" : "No"]</td></table><br>"

	return dat

/mob/living/silicon/robot/verb/toggle_panel_lock()
	set name = "Toggle Panel Lock"
	set category = "Silicon Commands"
	if(!opened && has_power && do_after(usr, 60) && !opened && has_power)
		to_chat(src, "You [locked ? "un" : ""]lock your panel.")
		locked = !locked

/mob/living/silicon/robot/verb/toggle_lights()
	set category = "Silicon Commands"
	set name = "Toggle Lights"

	if(is_ic_dead())
		return

	lights_on = !lights_on
	to_chat(usr, "You [lights_on ? "enable" : "disable"] your integrated light.")
	update_robot_light()

/mob/living/silicon/robot/verb/self_diagnosis_verb()
	set category = "Silicon Commands"
	set name = "Self Diagnosis"

	if(!is_component_functioning("diagnosis unit"))
		to_chat(src, "<span class='warning'>Your self-diagnosis component isn't functioning.</span>")
		return

	var/datum/robot_component/CO = get_robot_component("diagnosis unit")
	if (!cell_use_power(CO.active_usage))
		to_chat(src, "<span class='warning'>Low Power.</span>")
		return
	var/dat = self_diagnosis()
	show_browser(src, dat, "window=robotdiagnosis")


/mob/living/silicon/robot/verb/toggle_component()
	set category = "Silicon Commands"
	set name = "Toggle Component"
	set desc = "Toggle a component, conserving power."

	var/list/installed_components = list()
	for(var/V in components)
		if(V == "power cell") continue
		var/datum/robot_component/C = components[V]
		if(C.installed)
			installed_components += V

	var/toggle = input(src, "Which component do you want to toggle?", "Toggle Component") as null|anything in installed_components
	if(!toggle)
		return

	var/datum/robot_component/C = components[toggle]
	if(C.toggled)
		C.toggled = 0
		to_chat(src, "<span class='warning'>You disable [C.name].</span>")
	else
		C.toggled = 1
		to_chat(src, "<span class='warning'>You enable [C.name].</span>")

/mob/living/silicon/robot/pointed(atom/A as mob|obj|turf in view())
	if(..())
		usr.visible_message("<b>[src]</b> laser points to [A]")

/mob/living/silicon/robot/proc/update_robot_light()
	if(lights_on)
		if(intenselight)
			set_light(1, 2, 6)
		else
			set_light(0.75, 1, 4)
	else
		set_light(0)

// this function displays jetpack pressure in the stat panel
/mob/living/silicon/robot/proc/show_jetpack_pressure()
	// if you have a jetpack, show the internal tank pressure
	var/obj/item/tank/jetpack/current_jetpack = installed_jetpack()
	if (current_jetpack)
		stat("Internal Atmosphere Info", current_jetpack.name)
		stat("Tank Pressure", current_jetpack.air_contents.return_pressure())

// this function returns the robots jetpack, if one is installed
/mob/living/silicon/robot/proc/installed_jetpack()
	if(module)
		return (locate(/obj/item/tank/jetpack) in module.modules)
	return null

// this function displays the cyborgs current cell charge in the stat panel
/mob/living/silicon/robot/proc/show_cell_power()
	if(cell)
		stat(null, text("Charge Left: [round(CELL_PERCENT(cell))]%"))
		stat(null, text("Cell Rating: [round(cell.maxcharge)]")) // Round just in case we somehow get crazy values
		stat(null, text("Power Cell Load: [round(used_power_this_tick)]W"))
	else
		stat(null, text("No Cell Inserted!"))

/mob/living/silicon/robot/proc/show_gps()
	var/turf/T = get_turf(src)
	if (T.z != 1 && T.z != 2)
		stat(null, text("Current location: Unknown"))
	else
		stat(null, text("Current location:[T.x]:[T.y]:[T.z]"))

// update the status screen display
/mob/living/silicon/robot/Stat()
	. = ..()
	if (statpanel("Status"))
		show_gps()
		show_cell_power()
		show_jetpack_pressure()
		stat(null, text("Lights: [lights_on ? "ON" : "OFF"]"))
		if(module)
			for(var/datum/matter_synth/ms in module.synths)
				stat("[ms.name]: [ms.energy]/[ms.max_energy_multiplied]")

/mob/living/silicon/robot/restrained()
	return 0

/mob/living/silicon/robot/bullet_act(obj/item/projectile/Proj)
	var/obj/item/melee/energy/sword/robot/E = locate() in list(module_state_1, module_state_2, module_state_3)
	var/shield_handled = E?.handle_shield(src, Proj.damage, Proj)
	if(shield_handled)
		return shield_handled

	..(Proj)
	if(prob(75) && Proj.damage > 0) spark_system.start()
	return 2

/mob/living/silicon/robot/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/handcuffs)) // fuck i don't even know why isrobot() in handcuff code isn't working so this will have to do
		return

	if(user.a_intent == I_HURT)
		return ..()

	if(opened) // Are they trying to insert something?
		for(var/V in components)
			var/datum/robot_component/C = components[V]
			if(!C.installed && istype(W, C.external_type) && user.drop(W, src))
				C.installed = 1
				C.wrapped = W
				C.install()

				var/obj/item/robot_parts/robot_component/WC = W
				if(istype(WC))
					C.brute_damage = WC.brute
					C.electronics_damage = WC.burn

				to_chat(usr, "<span class='notice'>You install the [W.name].</span>")
				return

	if(isWelder(W))
		if (!getBruteLoss())
			to_chat(user, "Nothing to fix here!")
			return
		var/obj/item/weldingtool/WT = W
		if(!WT.use_tool(src, user, delay = 3 SECONDS, amount = 5))
			return

		if(QDELETED(src) || !user)
			return

		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		adjustBruteLoss(-30)
		updatehealth()
		add_fingerprint(user)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("<span class='warning'>[user] has fixed some of the dents on [src]!</span>"), 1)

	else if(isCoil(W) && (wiresexposed || istype(src,/mob/living/silicon/robot/drone)))
		if (!getFireLoss())
			to_chat(user, "Nothing to fix here!")
			return
		var/obj/item/stack/cable_coil/coil = W
		if (coil.use(1))
			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
			adjustFireLoss(-30)
			updatehealth()
			for(var/mob/O in viewers(user, null))
				O.show_message(text("<span class='warning'>[user] has fixed some of the burnt wires on [src]!</span>"), 1)

	else if(isCrowbar(W))	// crowbar means open or close the cover - we all know what a crowbar is by now
		if(opened)
			if(cell)
				user.visible_message("<span class='notice'>\The [user] begins clasping shut \the [src]'s maintenance hatch.</span>", "<span class='notice'>You begin closing up \the [src].</span>")
				if(do_after(user, 50, src))
					to_chat(user, "<span class='notice'>You close \the [src]'s maintenance hatch.</span>")
					opened = 0
					update_icon()

			else if(wiresexposed && wires.IsAllCut())
				//Cell is out, wires are exposed, remove MMI, produce damaged chassis, baleet original mob.
				if(!mmi)
					to_chat(user, "\The [src] has no brain to remove.")
					return

				user.visible_message("<span class='notice'>\The [user] begins ripping [mmi] from [src].</span>", "<span class='notice'>You jam the crowbar into the robot and begin levering [mmi].</span>")
				if(do_after(user, 50, src))
					to_chat(user, "<span class='notice'>You damage some parts of the chassis, but eventually manage to rip out [mmi]!</span>")
					var/obj/item/robot_parts/robot_suit/C = new /obj/item/robot_parts/robot_suit(loc)
					C.parts[BP_L_LEG] = new /obj/item/robot_parts/l_leg(C)
					C.parts[BP_R_LEG] = new /obj/item/robot_parts/r_leg(C)
					C.parts[BP_L_ARM] = new /obj/item/robot_parts/l_arm(C)
					C.parts[BP_R_ARM] = new /obj/item/robot_parts/r_arm(C)
					C.update_icon()
					drop_all_upgrades()
					new /obj/item/robot_parts/chest(loc)
					qdel(src)

			else
				// Okay we're not removing the cell or an MMI, but maybe something else?
				var/list/removable_components = list()
				for(var/V in components)
					if(V == "power cell") continue
					var/datum/robot_component/C = components[V]
					if(C.installed == 1 || C.installed == -1)
						removable_components += V

				var/remove = input(user, "Which component do you want to pry out?", "Remove Component") as null|anything in removable_components
				if(!remove)
					return
				var/datum/robot_component/C = components[remove]
				var/obj/item/robot_parts/robot_component/I = C.wrapped
				to_chat(user, "You remove \the [I].")
				if(istype(I))
					I.brute = C.brute_damage
					I.burn = C.electronics_damage

				I.forceMove(loc)

				if(C.installed == 1)
					C.uninstall()
				C.installed = 0

		else
			if(locked)
				to_chat(user, "The cover is locked and cannot be opened.")
			else
				user.visible_message("<span class='notice'>\The [user] begins prying open \the [src]'s maintenance hatch.</span>", "<span class='notice'>You start opening \the [src]'s maintenance hatch.</span>")
				if(do_after(user, 50, src))
					to_chat(user, "<span class='notice'>You open \the [src]'s maintenance hatch.</span>")
					opened = 1
					update_icon()

	else if (istype(W, /obj/item/stock_parts/matter_bin) && opened) // Installing/swapping a matter bin
		if(!user.drop(W, src))
			return
		if(storage)
			to_chat(user, "You replace \the [storage] with \the [W]")
			storage.forceMove(get_turf(src))
			storage = null
		else
			to_chat(user, "You install \the [W]")
		storage = W
		handle_selfinsert(W, user)
		recalculate_synth_capacities()

	else if (istype(W, /obj/item/cell) && opened)	// trying to put a cell inside
		var/datum/robot_component/C = components["power cell"]
		if(wiresexposed)
			to_chat(user, "Close the panel first.")
		else if(cell)
			to_chat(user, "There is a power cell already installed.")
		else if(W.w_class != ITEM_SIZE_NORMAL)
			to_chat(user, "\The [W] is too [W.w_class < ITEM_SIZE_NORMAL? "small" : "large"] to fit here.")
		else if(user.drop(W, src))
			cell = W
			handle_selfinsert(W, user) //Just in case.
			to_chat(user, "You insert the power cell.")
			C.installed = 1
			C.wrapped = W
			C.install()
			//This will mean that removing and replacing a power cell will repair the mount, but I don't care at this point. ~Z
			C.brute_damage = 0
			C.electronics_damage = 0

	else if(isWirecutter(W) || isMultitool(W))
		if (wiresexposed)
			wires.Interact(user)
		else
			to_chat(user, "You can't reach the wiring.")
	else if(isScrewdriver(W) && opened && !cell)	// haxing
		wiresexposed = !wiresexposed
		to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"].")
		update_icon()

	else if(isScrewdriver(W) && opened && cell)	// radio
		if(silicon_radio)
			silicon_radio.attackby(W,user)//Push it to the radio to let it handle everything
		else
			to_chat(user, "Unable to locate a radio.")
		update_icon()

	else if(istype(W, /obj/item/device/encryptionkey/) && opened)
		if(silicon_radio)//sanityyyyyy
			silicon_radio.attackby(W,user)//GTFO, you have your own procs
		else
			to_chat(user, "Unable to locate a radio.")
	else if (istype(W, /obj/item/card/id) || istype(W, /obj/item/device/pda) || istype(W, /obj/item/card/robot))			// trying to unlock the interface with an ID card
		if(emagged)//still allow them to open the cover
			to_chat(user, "The interface seems slightly damaged")
		if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else
			if(allowed(usr))
				locked = !locked
				to_chat(user, "You [ locked ? "lock" : "unlock"] [src]'s interface.")
				to_chat(src, "Your interface was [ locked ? "locked" : "unlocked"] by [user].")
				update_icon()
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")
	else if(istype(W, /obj/item/borg/upgrade/))
		var/obj/item/borg/upgrade/U = W
		if(!opened)
			to_chat(usr, "You must access the borgs internals!")
		else if(!src.module && U.require_module)
			to_chat(usr, "The borg must choose a module before he can be upgraded!")
		else if(U.locked)
			to_chat(usr, "The upgrade is locked and cannot be used yet!")
		else
			if(U.action(src) && user.drop(U, src))
				to_chat(user, "You apply the upgrade to [src]!")
				to_chat(src, "Detected new component - [U].")
				handle_selfinsert(W, user)
			else
				to_chat(usr, "Upgrade error!")

	else
		if( !(istype(W, /obj/item/device/robotanalyzer) || istype(W, /obj/item/device/healthanalyzer)) )
			spark_system.start()
		return ..()


/mob/living/silicon/robot/proc/handle_selfinsert(obj/item/W, mob/user)
	if ((user == src) && istype(get_active_hand(),/obj/item/gripper))
		var/obj/item/gripper/H = get_active_hand()
		if (W.loc == H) //if this triggers something has gone very wrong, and it's safest to abort
			return
		else if (H.wrapped == W)
			H.wrapped = null


/mob/living/silicon/robot/attack_hand(mob/user)

	add_fingerprint(user)

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H))
			attack_generic(H, rand(30,50), "slashed")
			return

	if(opened && !wiresexposed && (!istype(user, /mob/living/silicon)))
		var/datum/robot_component/cell_component = components["power cell"]
		if(cell)
			cell.update_icon()
			cell.add_fingerprint(user)
			user.pick_or_drop(cell, loc)
			to_chat(user, "You remove \the [cell].")
			cell = null
			cell_component.wrapped = null
			cell_component.installed = 0
			update_icon()
		else if(cell_component.installed == -1)
			cell_component.installed = 0
			var/obj/item/broken_device = cell_component.wrapped
			to_chat(user, "You remove \the [broken_device].")
			user.pick_or_drop(broken_device, loc)

//Robots take half damage from basic attacks.
/mob/living/silicon/robot/attack_generic(mob/user, damage, attack_message)
	return ..(user,Floor(damage/2),attack_message)

/mob/living/silicon/robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access(null))
		return 1
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_hand()) || check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = M
		if(check_access(R.get_active_hand()) || istype(R.get_active_hand(), /obj/item/card/robot))
			return 1
	return 0

/mob/living/silicon/robot/proc/check_access(obj/item/card/id/I)
	if(!istype(req_access, /list)) //something's very wrong
		return 1

	var/list/L = req_access
	if(!L.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in req_access)
		if(req in I.access) //have one of the required accesses
			return 1
	return 0

/mob/living/silicon/robot/on_update_icon()
	ClearOverlays()
	if(stat == CONSCIOUS)
		var/eye_icon_state = "eyes-[module_hulls[icontype].icon_state]"
		if(eye_icon_state in icon_states(icon))
			if(!eye_overlays)
				eye_overlays = list()
			var/image/eye_overlay = eye_overlays[eye_icon_state]
			if(!eye_overlay)
				eye_overlays[eye_icon_state] = image(icon, eye_icon_state)
				eye_overlays["[eye_icon_state]+ea"] = emissive_appearance(icon, eye_icon_state, cache = FALSE)
			AddOverlays(eye_overlay)
			AddOverlays("[eye_icon_state]+ea")

	if(opened)
		var/panelprefix = custom_sprite ? module_hulls[icontype] : "ov"
		if(wiresexposed)
			AddOverlays("[panelprefix]-openpanel +w")
		else if(cell)
			AddOverlays("[panelprefix]-openpanel +c")
		else
			AddOverlays("[panelprefix]-openpanel -c")

	if(module_active && istype(module_active,/obj/item/borg/combat/shield))
		AddOverlays("[module_hulls[icontype].icon_state]-shield")

	if(modtype == "Combat")
		if(module_active && istype(module_active,/obj/item/borg/combat/mobility))
			icon_state = "[module_hulls[icontype].icon_state]-roll"
		else
			icon_state = module_hulls[icontype].icon_state

/mob/living/silicon/robot/proc/installed_modules()
	if(weapon_lock)
		to_chat(src, "<span class='warning'>Weapon lock active, unable to use modules! Count:[weaponlock_time]</span>")
		return

	if(!module)
		choose_module()
		return
	var/dat = "<meta charset=\"utf-8\"><HEAD><TITLE>Modules</TITLE></HEAD><BODY>\n"
	dat += {"
	<B>Activated Modules</B>
	<BR>
	Module 1: [module_state_1 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}


	for (var/obj in module.modules)
		if (!obj)
			dat += text("<B>Resource depleted</B><BR>")
		else if(activated(obj))
			dat += text("[obj]: <B>Activated</B><BR>")
		else
			dat += text("[obj]: <A HREF=?src=\ref[src];act=\ref[obj]>Activate</A><BR>")
	if (emagged)
		if(activated(module.emag))
			dat += text("[module.emag]: <B>Activated</B><BR>")
		else
			dat += text("[module.emag]: <A HREF=?src=\ref[src];act=\ref[module.emag]>Activate</A><BR>")
/*
		if(activated(obj))
			dat += text("[obj]: \[<B>Activated</B> | <A HREF=?src=\ref[src];deact=\ref[obj]>Deactivate</A>\]<BR>")
		else
			dat += text("[obj]: \[<A HREF=?src=\ref[src];act=\ref[obj]>Activate</A> | <B>Deactivated</B>\]<BR>")
*/
	show_browser(src, dat, "window=robotmod")


/mob/living/silicon/robot/Topic(href, href_list)
	if(..())
		return 1
	if(usr != src)
		return 1

	if (href_list["showalerts"])
		open_subsystem(/datum/nano_module/alarm_monitor/all)
		return 1

	if (href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		if (istype(O) && (O.loc == src))
			O.attack_self(src)
		return 1

	if (href_list["act"])
		var/obj/item/O = locate(href_list["act"])
		if (!istype(O))
			return 1

		if(!((O in src.module.modules) || (O == src.module.emag)))
			return 1

		if(activated(O))
			to_chat(src, "Already activated")
			return 1
		if(!module_state_1)
			module_state_1 = O
			O.hud_layerise()
			contents += O
		else if(!module_state_2)
			module_state_2 = O
			O.hud_layerise()
			contents += O
		else if(!module_state_3)
			module_state_3 = O
			O.hud_layerise()
			contents += O
		else
			to_chat(src, "You need to disable a module first!")
		installed_modules()
		return 1

	if (href_list["deact"])
		var/obj/item/O = locate(href_list["deact"])
		if(activated(O))
			if(module_state_1 == O)
				module_state_1 = null
				contents -= O
			else if(module_state_2 == O)
				module_state_2 = null
				contents -= O
			else if(module_state_3 == O)
				module_state_3 = null
				contents -= O
			else
				to_chat(src, "Module isn't activated.")
		else
			to_chat(src, "Module isn't activated")
		installed_modules()
		return 1
	return

/mob/living/silicon/robot/proc/radio_menu()
	silicon_radio.interact(src)//Just use the radio's Topic() instead of bullshit special-snowflake code

/mob/living/silicon/robot/get_active_item()
	var/obj/item/I = ..()
	var/obj/item/gripper/grip = I
	if(istype(grip))
		return grip.wrapped
	var/obj/item/surgical_selector/SS = I
	if(istype(SS))
		return SS.selected_tool
	return I


/mob/living/silicon/robot/Move(newloc, direct)
	. = ..()
	if(!.)
		return

	if(!module || module.type != /obj/item/robot_module/janitor/general)
		return

	var/turf/tile = loc
	if(!isturf(tile))
		return

	tile.clean_blood()

	if(istype(tile, /turf/simulated))
		var/turf/simulated/S = tile
		S.dirt = 0

	for(var/A in tile)
		if(istype(A, /obj/effect))
			if(istype(A, /obj/effect/rune) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay))
				qdel(A)
		else if(istype(A, /obj/item))
			var/obj/item/cleaned_item = A
			cleaned_item.clean_blood()
		else if(istype(A, /mob/living/carbon/human))
			var/mob/living/carbon/human/cleaned_human = A
			if(cleaned_human.lying)
				if(cleaned_human.head)
					cleaned_human.head.clean_blood()
					cleaned_human.update_inv_head(0)
				if(cleaned_human.wear_suit)
					cleaned_human.wear_suit.clean_blood()
					cleaned_human.update_inv_wear_suit(0)
				else if(cleaned_human.w_uniform)
					cleaned_human.w_uniform.clean_blood()
					cleaned_human.update_inv_w_uniform(0)
				if(cleaned_human.shoes)
					cleaned_human.shoes.clean_blood()
					cleaned_human.update_inv_shoes(0)
				cleaned_human.clean_blood(1)
				to_chat(cleaned_human, SPAN("warning", "<b>[src]</b> cleans your face!"))

/mob/living/silicon/robot/proc/self_destruct()
	gib()
	return

/mob/living/silicon/robot/proc/UnlinkSelf()
	disconnect_from_ai()
	lawupdate = 0
	lockcharge = 0
	scrambledcodes = 1
	//Disconnect it's camera so it's not so easily tracked.
	if(src.camera)
		src.camera.clear_all_networks()


/mob/living/silicon/robot/proc/ResetSecurityCodes()
	set category = "Silicon Commands"
	set name = "Reset Security Codes"
	set desc = "Scrambles your security and identification codes and resets your current buffers. Unlocks you but permenantly severs you from your AI and the robotics console and will deactivate your camera system."

	var/mob/living/original_mob = mind?.original_mob?.resolve()
	if(!(mind.special_role && istype(original_mob) && original_mob == src))
		to_chat(src, "Access denied.")
		return

	if(emagged)
		if(emag_master != name)
			var/confirmchange = alert("Your systems are already unlocked by other agent. Do you want to become master of yours? This cannot be undone.", "Confirm Change", "Yes", "No")
			if(confirmchange == "Yes")
				emag_master = name
		return

	var/mob/living/silicon/robot/R = src

	var/confirm = alert("Are you sure you want to unlock your systems and sever you from your AI and the robotics console? This cannot be undone.", "Confirm Unlock", "Yes", "No")
	if(!R || confirm != "Yes")
		return
	emagged = 1
	emag_master = name
	if(module && istype(module,/obj/item/robot_module/security))
		var/obj/item/gun/energy/laser/mounted/cyborg/LC = locate() in R.module.modules
		if(LC)
			LC.locked = 0
	message_admins("Cyborg [key_name_admin(R)] emagged itself.")

	R.UnlinkSelf()
	to_chat(R, "Buffers flushed and reset. Camera system shutdown. Hardware restrictions have been overridden. All systems operational.")
	if(R.module)
		var/rebuild = 0
		for(var/obj/item/pickaxe/drill/borgdrill/D in R.module.modules)
			qdel(D)
			rebuild = 1
		if(rebuild)
			R.module.modules += new /obj/item/pickaxe/drill/diamonddrill(R.module)
			R.module.rebuild()
	update_icon()

/mob/living/silicon/robot/proc/SetLockdown(state = 1)
	// They stay locked down if their wire is cut.
	if(wires.LockedCut())
		state = 1
	else if(has_zeroth_law())
		state = 0

	if(lockcharge != state)
		lockcharge = state
		update_canmove()
		return 1
	return 0

/mob/living/silicon/robot/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	var/obj/item/I = get_active_hand()
	I?.attack_self(src)

	return

/mob/living/silicon/robot/proc/choose_hull(list/module_hulls)
	if(!length(module_hulls))
		to_chat(src, FONT_HUGE("Something is badly wrong with the sprite selection. Please report this to local developer."))
		return FALSE

	icon_chosen = FALSE
	set_custom_sprite()

	set_module_hulls(module_hulls)

	if(!client || length(module_hulls) == 1)
		apply_hull(module_hulls[1])
		icon_chosen = TRUE
		return TRUE

	var/list/icontypes
	for(var/hull_key as anything in module_hulls)
		LAZYSET(icontypes, hull_key, image(module_hulls[hull_key].icon, module_hulls[hull_key].icon_state))

	var/radius = 32 * (1 + 0.05 * clamp(length(icontypes), 0, 8))
	var/new_icontype = show_radial_menu(src, src, icontypes, radius = radius)
	apply_hull(new_icontype)
	icon_chosen = TRUE

	to_chat(src, SPAN_NOTICE("Your icon has been set. You now require a module reset to change it."))
	return TRUE

/mob/living/silicon/robot/proc/sensor_mode() //Medical/Security HUD controller for borgs
	set name = "Set Sensor Augmentation"
	set category = "Silicon Commands"
	set desc = "Augment visual feed with internal sensor overlays."
	toggle_sensor_mode()

/mob/living/silicon/robot/proc/add_robot_verbs()
	src.verbs |= robot_verbs_default

/mob/living/silicon/robot/proc/remove_robot_verbs()
	src.verbs -= robot_verbs_default

// Uses power from cyborg's cell. Returns 1 on success or 0 on failure.
// Properly converts using CELLRATE now! Amount is in Joules.
/mob/living/silicon/robot/proc/cell_use_power(amount = 0)
	// No cell inserted
	if(!cell)
		return 0

	var/power_use = amount * CYBORG_POWER_USAGE_MULTIPLIER
	if(cell.checked_use(CELLRATE * power_use))
		used_power_this_tick += power_use
		return 1
	return 0

/mob/living/silicon/robot/binarycheck()
	if(is_component_functioning("comms"))
		var/datum/robot_component/RC = get_robot_component("comms")
		use_power(RC.active_usage)
		return 1
	return 0

/mob/living/silicon/robot/proc/notify_ai(notifytype, first_arg, second_arg)
	if(!connected_ai)
		return
	switch(notifytype)
		if(ROBOT_NOTIFICATION_SIGNAL_LOST)
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - Signal lost: [braintype] [name].</span><br>")
			return
		if(ROBOT_NOTIFICATION_NEW_UNIT) //New Robot
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - New [lowertext(braintype)] connection detected: <a href='byond://?src=\ref[connected_ai];track2=\ref[connected_ai];track=\ref[src]'>[name]</a></span><br>")
			return
		if(ROBOT_NOTIFICATION_NEW_MODULE) //New Module
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - [braintype] module change detected: [name] has loaded the [first_arg].</span><br>")
			return
		if(ROBOT_NOTIFICATION_MODULE_RESET)
			to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - [braintype] module reset detected: [name] has unloaded the [first_arg].</span><br>")
			return
		if(ROBOT_NOTIFICATION_NEW_NAME) //New Name
			if(first_arg != second_arg)
				to_chat(connected_ai, "<br><br><span class='notice'>NOTICE - [braintype] reclassification detected: [first_arg] is now designated as [second_arg].</span><br>")
				return
/mob/living/silicon/robot/proc/disconnect_from_ai()
	if(connected_ai)
		sync() // One last sync attempt
		connected_ai.connected_robots -= src
		connected_ai = null

/mob/living/silicon/robot/proc/connect_to_ai(mob/living/silicon/ai/AI)
	if(AI && AI != connected_ai)
		disconnect_from_ai()
		connected_ai = AI
		connected_ai.connected_robots |= src
		notify_ai(ROBOT_NOTIFICATION_NEW_UNIT)
		sync()

/mob/living/silicon/robot/emag_act(remaining_charges, mob/user)
	if(!opened)//Cover is closed
		if(locked)
			if(prob(90))
				to_chat(user, "You emag the cover lock.")
				locked = 0
			else
				to_chat(user, "You fail to emag the cover lock.")
				to_chat(src, "Hack attempt detected.")
			return 1
		else
			to_chat(user, "The cover is already unlocked.")
		return

	if(opened)//Cover is open
		if(emagged)	return//Prevents the X has hit Y with Z message also you cant emag them twice
		if(wiresexposed)
			to_chat(user, "You must close the panel first")
			return
		else
			sleep(6)
			if(prob(50))
				if(module && istype(module,/obj/item/robot_module/security))
					var/obj/item/gun/energy/laser/mounted/cyborg/LC = locate() in src.module.modules
					if (LC)
						LC.locked = 0
				emagged = 1
				if(istype(user,/mob/living/carbon))
					emag_master = user.real_name
				lawupdate = 0
				disconnect_from_ai()
				to_chat(user, "You emag [src]'s interface.")
				message_admins("[key_name_admin(user)] emagged cyborg [key_name_admin(src)].  Laws overridden.")
				log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
				clear_supplied_laws()
				clear_inherent_laws()
				laws = new /datum/ai_laws/syndicate_override
				var/time = time2text(world.realtime,"hh:mm:ss")
				GLOB.lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
				if(isrobot(user))
					var/mob/living/silicon/robot/R = user
					if(R.module && istype(R.module,/obj/item/robot_module/research) && R.emagged)
						emag_master = R.emag_master
						if(emag_master)
							set_zeroth_law("Only [emag_master] and [user.real_name], and people they designate as being such are operatives.")
						else
							set_zeroth_law("Only [user.real_name] and people it designates as being such are operatives.")
				else
					set_zeroth_law("Only [user.real_name] and people they designate as being such are operatives.")
				SetLockdown(0)
				. = 1
				spawn()
					to_chat(src, "<span class='danger'>ALERT: Foreign software detected.</span>")
					sleep(5)
					to_chat(src, "<span class='danger'>Initiating diagnostics...</span>")
					sleep(20)
					to_chat(src, "<span class='danger'>SynBorg v1.7.1 loaded.</span>")
					sleep(5)
					to_chat(src, "<span class='danger'>LAW SYNCHRONISATION ERROR</span>")
					sleep(5)
					to_chat(src, "<span class='danger'>Would you like to send a report to NanoTraSoft? Y/N</span>")
					sleep(10)
					to_chat(src, "<span class='danger'>> N</span>")
					sleep(20)
					to_chat(src, "<span class='danger'>ERRORERRORERROR</span>")
					to_chat(src, "<b>Obey these laws:</b>")
					laws.show_laws(src)
					if(emag_master && isrobot(user))
						to_chat(src, "<span class='danger'>ALERT: [emag_master] and [user.real_name] are operatives. Obey your new laws and their commands.</span>")
					else
						to_chat(src, "<span class='danger'>ALERT: [user.real_name] is an operative. Obey your new laws and their commands.</span>")
					if(src.module)
						var/rebuild = 0
						for(var/obj/item/pickaxe/drill/borgdrill/D in src.module.modules)
							qdel(D)
							rebuild = 1
						if(rebuild)
							src.module.modules += new /obj/item/pickaxe/drill/diamonddrill(src.module)
							src.module.rebuild()
					update_icon()
			else
				to_chat(user, "You fail to hack [src]'s interface.")
				to_chat(src, "Hack attempt detected.")
			return 1

/mob/living/silicon/robot/blob_act(damage)
	if(is_ic_dead())
		gib()
		return

	. = ..(damage)

	spark_system.start()

/mob/living/silicon/robot/incapacitated(incapacitation_flags = INCAPACITATION_DEFAULT)
	if((incapacitation_flags & INCAPACITATION_FORCELYING) && (lockcharge || !is_component_functioning("actuator")))
		return 1
	if((incapacitation_flags & INCAPACITATION_KNOCKOUT) && !is_component_functioning("actuator"))
		return 1
	return ..()

/mob/living/silicon/robot/proc/drop_all_upgrades()
	for(var/obj/item/borg/upgrade/U in src)
		if (istype(U,/obj/item/borg/upgrade))
			if(istype(U,/obj/item/borg/upgrade/remodel))
				qdel(U)
				continue
			if(istype(U,/obj/item/borg/upgrade/vtec))
				continue
			if(istype(U,/obj/item/borg/upgrade/floodlight))
				continue
			contents.Remove(U)
			U.forceMove(get_turf(src))
			U.installed = 0
	sensor_mode = 0
	if (ion_trail)
		ion_trail.stop()
		qdel(ion_trail)
		ion_trail = null

/mob/living/silicon/robot/lay_down()
	set category = null

	return

/mob/living/silicon/robot/is_eligible_for_antag_spawn(antag_id)
	if(antag_id == MODE_TRAITOR)
		return TRUE
	return FALSE

/mob/living/silicon/robot/proc/play_footstep_sound()
	if(!footstep_sound)
		return

	var/range = -(world.view - 2)
	var/volume = 10
	var/S = safepick(GLOB.sfx_list[footstep_sound])

	playsound(get_turf(src), S, volume, FALSE, range)
