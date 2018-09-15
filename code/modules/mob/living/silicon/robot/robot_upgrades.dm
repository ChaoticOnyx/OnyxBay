// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/locked = 0
	var/require_module = 0
	var/installed = 0

/obj/item/borg/upgrade/proc/can_install(var/type, var/mob/living/silicon/robot/R)
	if(R.module)
		var/t = locate(type) in R.module.supported_upgrades
		if (!t)
			to_chat(R, "Upgrade mounting error!  No suitable hardpoint detected!")
			to_chat(usr, "There's no mounting point for the module!")
			return 0
		var/obj/item/borg/upgrade/U = locate(type) in R.contents
		if(U && U.installed)
			to_chat(R, "There is already a [src] present!")
			to_chat(usr, "[src] is already installed!")
			return 0
	return 1

/obj/item/borg/upgrade/proc/action(var/mob/living/silicon/robot/R)
	if(R.stat == DEAD)
		to_chat(usr, "<span class='warning'>The [src] will not function on a deceased robot.</span>")
		return 1
	return 0

/obj/item/borg/upgrade/reset
	name = "robotic module reset board"
	desc = "Used to reset a cyborg's module. Destroys any other upgrades applied to the robot."
	icon_state = "cyborg_upgrade1"
	require_module = 1

/obj/item/borg/upgrade/reset/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	R.uneq_all()
	R.modtype = initial(R.modtype)
	R.hands.icon_state = initial(R.hands.icon_state)

	R.notify_ai(ROBOT_NOTIFICATION_MODULE_RESET, R.module.name)
	R.module.Reset(R)
	qdel(R.module)
	R.module = null
	R.updatename("Default")
	installed = 1

	return 1

/obj/item/borg/upgrade/remodel
	name = "default model board"
	desc = "Used to remodel a cyborg."
	icon_state = "cyborg_upgrade1"
	require_module = 0
	var/module = "Standard"

/obj/item/borg/upgrade/remodel/advanced
	icon_state = "cyborg_upgrade4"

/obj/item/borg/upgrade/remodel/action(var/mob/living/silicon/robot/R, var/mob/user)
	if(..()) return 0
	R.active_hud = 0
	R.sensor_mode = 0
	spawn(1)	//will do stuff after proc end so item can be put in borg
		if(R.module)
			R.uneq_all()
			R.hands.icon_state = initial(R.hands.icon_state)
			if (R.shown_robot_modules)
				R.shown_robot_modules = !R.shown_robot_modules
				R.hud_used.update_robot_modules_display()
			R.module.Reset(R)
			qdel(R.module)
			R.module = null
		R.drop_all_upgrades()
		var/module_type = robot_modules[module]
		new module_type(R)
		R.modtype = module
		R.hands.icon_state = lowertext(module)
		feedback_inc("cyborg_[lowertext(module)]",1)
		R.recalculate_synth_capacities()
		R.updatename()
		R.notify_ai(ROBOT_NOTIFICATION_NEW_MODULE, R.module.name)
		installed = 1
	return 1

/obj/item/borg/upgrade/remodel/surgeon
	name = "surgeon model board"
	module = "Surgeon"

/obj/item/borg/upgrade/remodel/advanced/surgeon
	name = "advanced surgeon model board"
	module = "Advanced Surgeon"

/obj/item/borg/upgrade/remodel/service
	name = "service model board"
	module = "Service"

/obj/item/borg/upgrade/remodel/research
	name = "research model board"
	module = "Research"

/obj/item/borg/upgrade/remodel/miner
	name = "miner model board"
	module = "Miner"

/obj/item/borg/upgrade/remodel/medical
	name = "medical model board"
	module = "Medical"	

/obj/item/borg/upgrade/remodel/security
	name = "security model board"
	module = "Security"	

/obj/item/borg/upgrade/remodel/combat
	name = "combat model board"
	module = "Combat"	

/obj/item/borg/upgrade/remodel/engineering
	name = "engineering model board"
	module = "Engineering"

/obj/item/borg/upgrade/remodel/janitor
	name = "janitor model board"
	module = "Janitor"

/obj/item/borg/upgrade/remodel/advanced/medical
	name = "advanced medical model board"
	module = "Advanced Medical"

/obj/item/borg/upgrade/remodel/advanced/engineering
	name = "advanced engineering model board"
	module = "Advanced Engineering"

/obj/item/borg/upgrade/remodel/advanced/miner
	name = "advanced miner model board"
	module = "Advanced Miner"

/obj/item/borg/upgrade/rename
	name = "robot reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = ""

/obj/item/borg/upgrade/rename/attack_self(mob/user as mob)
	heldname = sanitizeSafe(input(user, "Enter new robot name", "Robot Reclassification", heldname), MAX_NAME_LEN)

/obj/item/borg/upgrade/rename/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	spawn(1)
		if (heldname == "")
			heldname = sanitizeSafe(input(R, "Enter new robot name", "Robot Reclassification", heldname), MAX_NAME_LEN)
		R.notify_ai(ROBOT_NOTIFICATION_NEW_NAME, R.name, heldname)
		R.SetName(heldname)
		R.custom_name = heldname
		R.real_name = heldname

	return 1

/obj/item/borg/upgrade/floodlight
	name = "robot floodlight module"
	desc = "Used to boost cyborg's light intensity."
	icon_state = "cyborg_upgrade1"

/obj/item/borg/upgrade/floodlight/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(R.intenselight)
		to_chat(usr, "This cyborg's light was already upgraded")
		return 0
	else
		R.intenselight = 1
		R.update_robot_light()
		to_chat(R, "Lighting systems upgrade detected.")
		installed = 1
	return 1

/obj/item/borg/upgrade/restart
	name = "robot emergency restart module"
	desc = "Used to force a restart of a disabled-but-repaired robot, bringing it back online."
	icon_state = "cyborg_upgrade1"


/obj/item/borg/upgrade/restart/action(var/mob/living/silicon/robot/R)
	if(R.health < 0)
		to_chat(usr, "You have to repair the robot before using this module!")
		return 0

	if(!R.key)
		for(var/mob/observer/ghost/ghost in GLOB.player_list)
			if(ghost.mind && ghost.mind.current == R)
				R.key = ghost.key

	R.set_stat(CONSCIOUS)
	R.switch_from_dead_to_living_mob_list()
	R.dead = 0
	R.notify_ai(ROBOT_NOTIFICATION_NEW_UNIT)
	installed = 1
	return 1


/obj/item/borg/upgrade/vtec
	name = "robotic VTEC Module"
	desc = "Used to kick in a robot's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	require_module = 1

/obj/item/borg/upgrade/vtec/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(R.speed == -1)
		return 0

	R.speed--
	installed = 1
	return 1


/obj/item/borg/upgrade/tasercooler
	name = "robotic Rapid Taser Cooling Module"
	desc = "Used to cool a mounted taser, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	require_module = 1


/obj/item/borg/upgrade/tasercooler/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src,R))
		return 0
	var/obj/item/weapon/gun/energy/taser/mounted/cyborg/T = locate() in R.module
	if(!T)
		T = locate() in R.module.contents
	if(!T)
		T = locate() in R.module.modules
	if(!T)
		to_chat(usr, "This robot has had its taser removed!")
		return 0

	if(T.recharge_time <= 2)
		to_chat(R, "Maximum cooling achieved for this hardpoint!")
		to_chat(usr, "There's no room for another cooling unit!")
		return 0

	else
		T.recharge_time = max(2 , T.recharge_time - 4)
		installed = 1

	return 1

/obj/item/borg/upgrade/lasercooler
	name = "robotic Rapid Laser Carbine Cooling Module"
	desc = "Used to cool a mounted laser carbine, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	require_module = 1


/obj/item/borg/upgrade/lasercooler/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src,R))
		return 0
	var/obj/item/weapon/gun/energy/laser/mounted/cyborg/T = locate() in R.module
	if(!T)
		T = locate() in R.module.contents
	if(!T)
		T = locate() in R.module.modules
	if(!T)
		to_chat(usr, "This robot has had its laser removed!")
		return 0

	if(T.recharge_time <= 2)
		to_chat(R, "Maximum cooling achieved for this hardpoint!")
		to_chat(usr, "There's no room for another cooling unit!")
		return 0

	else
		T.recharge_time = max(2 , T.recharge_time - 4)
		installed = 1

	return 1

/obj/item/borg/upgrade/jetpack
	name = "robot jetpack"
	desc = "A carbon dioxide jetpack suitable for low-gravity operations."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/jetpack/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		var/obj/item/weapon/tank/jetpack/carbondioxide/J = new /obj/item/weapon/tank/jetpack/carbondioxide
		J.toggle()
		R.module.modules += J
		J.ion_trail.set_up(R)
		J.ion_trail.start()
		for(var/obj/item/weapon/tank/jetpack/carbondioxide in R.module.modules)
			R.internals = src
		installed = 1
		return 1

/obj/item/borg/upgrade/visor/thermal
	name = "thermal visor upgrade"
	desc = "Module contains callibration settings for cyborg visial sensors (THERMAL)."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/visor/thermal/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.avaliable_huds += "Thermal"
		installed = 1
		return 1

/obj/item/borg/upgrade/visor/nvg
	name = "night visor upgrade"
	desc = "Module contains callibration settings for cyborg visial sensors (NIGHT VISION)."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/visor/nvg/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.avaliable_huds += "Night Vision"
		installed = 1
		return 1

/obj/item/borg/upgrade/visor/flash_screen
	name = "flash screen visor upgrade"
	desc = "Module contains lenses with toggleable tint that protects against bright light."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/visor/flash_screen/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.avaliable_huds += "Flash Screen"
		installed = 1
		return 1

/obj/item/borg/upgrade/visor/meson
	name = "meson visor upgrade"
	desc = "Module contains callibration settings for cyborg visial sensors (MESON VISION)."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/visor/meson/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.avaliable_huds += "Meson"
		installed = 1
		return 1

/obj/item/borg/upgrade/visor/x_ray
	name = "x-ray visor upgrade"
	desc = "Module contains callibration settings for cyborg visial sensors (X-RAY)."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/visor/x_ray/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.avaliable_huds += "X-Ray"
		installed = 1
		return 1

/obj/item/borg/upgrade/rcd
	name = "engineering robot RCD"
	desc = "A rapid construction device module for use during construction operations."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/rcd/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.module.modules += new /obj/item/weapon/rcd/borg(R.module)
		installed = 1
		return 1

/obj/item/borg/upgrade/rped
	name = "science robot RPED"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/rped/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.module.modules += new /obj/item/weapon/storage/part_replacer(R.module)
		installed = 1
		return 1

/obj/item/borg/upgrade/bb_printer
	name = "bodybag printer"
	desc = "Special printer module designed to rapidly manufacture bodybags."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/bb_printer/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src,R))
		return 0
	else
		R.module.modules += new /obj/item/weapon/robot_item_dispenser/bodybag(R.module)
		installed = 1
		return 1

/obj/item/borg/upgrade/paramedic
	name = "paramedic module"
	desc = "A paramedic kit for cyborgs."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/paramedic/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		var/datum/matter_synth/medicine = new /datum/matter_synth/medicine(6000)
		R.module.synths += medicine
		R.module.modules += new /obj/item/device/healthanalyzer(R.module)
		R.module.modules += new /obj/item/roller_holder(R.module)
		var/obj/item/stack/medical/bruise_pack/B = new /obj/item/stack/medical/bruise_pack(R.module)
		B.uses_charge = 1
		B.charge_costs = list(1000)
		B.synths = list(medicine)
		R.module.modules += B
		installed = 1

		return 1

/obj/item/borg/upgrade/paperwork
	name = "paperwork module"
	desc = "A paperwork kit for cyborgs."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/paperwork/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.module.modules += new /obj/item/weapon/pen/robopen(R.module)
		R.module.modules += new /obj/item/weapon/form_printer(R.module)
		R.module.modules += new /obj/item/weapon/gripper/paperwork(R.module)
		R.module.modules += new /obj/item/weapon/hand_labeler(R.module)
		R.module.modules += new /obj/item/weapon/stamp(R.module)
		R.module.modules += new /obj/item/weapon/stamp/denied(R.module)
		
		installed = 1
		return 1

/obj/item/borg/upgrade/cargo_managment
	name = "cargo managment module"
	desc = "A tool kit for cargo manipulation."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/cargo_managment/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.module.modules += new /obj/item/device/destTagger(R.module)
		R.module.modules += new /obj/item/weapon/packageWrap(R.module)
		R.module.modules += new /obj/item/weapon/robot_item_dispenser/crates(R.module)
		R.module.modules += new /obj/item/robot_rack/cargo(R.module)
		
		installed = 1
		return 1

/obj/item/borg/upgrade/detective
	name = "detective module"
	desc = "A detective kit for cyborgs."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/detective/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.module.modules += new /obj/item/weapon/gripper/detective(R.module)
		R.module.modules += new /obj/item/robot_rack/detective(R.module)
		R.module.modules += new /obj/item/weapon/reagent_containers/spray/luminol(R.module)
		R.module.modules += new /obj/item/device/uv_light(R.module)
		R.module.modules += new /obj/item/weapon/forensics/sample_kit(R.module)
		R.module.modules += new /obj/item/weapon/forensics/sample_kit/powder(R.module)
		R.module.modules += new /obj/item/weapon/forensics/swab/cyborg(R.module)
		R.module.modules += new /obj/item/weapon/reagent_containers/dna_sampler/detective(R.module)
		R.module.modules += new /obj/item/device/mass_spectrometer(R.module)
		R.module.modules += new /obj/item/device/reagent_scanner(R.module)
		R.module.modules += new /obj/item/weapon/scalpel(R.module)
		R.module.modules += new /obj/item/weapon/autopsy_scanner(R.module)
		installed = 1
		return 1

/obj/item/borg/upgrade/archeologist
	name = "archeologist module"
	desc = "A archeologist kit for cyborgs."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/archeologist/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.module.modules += new /obj/item/weapon/pickaxe/brush(R.module)
		R.module.modules += new /obj/item/weapon/pickaxe/one_pick(R.module)
		R.module.modules += new /obj/item/weapon/pickaxe/two_pick(R.module)
		R.module.modules += new /obj/item/weapon/pickaxe/three_pick(R.module)
		R.module.modules += new /obj/item/weapon/pickaxe/four_pick(R.module)
		R.module.modules += new /obj/item/weapon/pickaxe/five_pick(R.module)
		R.module.modules += new /obj/item/weapon/pickaxe/six_pick(R.module)
		R.module.modules += new /obj/item/weapon/pickaxe/hand(R.module)
		if (istype(R.module,/obj/item/weapon/robot_module/research))
			R.module.modules += new /obj/item/weapon/pickaxe(R.module)
		R.module.modules += new /obj/item/device/measuring_tape(R.module)
		R.module.modules += new /obj/item/device/core_sampler(R.module)
		R.module.modules += new /obj/item/weapon/gripper/archeologist(R.module)
		R.module.modules += new /obj/item/weapon/storage/bag/fossils(R.module)
		R.module.modules += new /obj/item/robot_rack/archeologist(R.module)
		R.module.modules += new /obj/item/device/ano_scanner(R.module)
		R.module.modules += new /obj/item/device/depth_scanner(R.module)
		installed = 1
		return 1

/obj/item/borg/upgrade/storage
	name = "storage module"
	desc = "A storage module for items."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/storage/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.module.modules += new /obj/item/robot_rack/general(R.module)
		installed = 1
		return 1

/obj/item/borg/upgrade/organ_printer
	name = "organ synthesizer module"
	desc = "Special printer module designed to rapidly manufacture organs and limbs."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/organ_printer/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.module.modules += new /obj/item/weapon/robot_item_dispenser/organs(R.module)
		installed = 1
		return 1

/obj/item/borg/upgrade/blood_printer
	name = "blood synthesizer module"
	desc = "Special printer module designed to rapidly synthesize blood."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/blood_printer/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.module.modules += new /obj/item/weapon/robot_item_dispenser/blood(R.module)
		installed = 1
		return 1

/obj/item/borg/upgrade/pipe_printer
	name = "pipe printer module"
	desc = "Special printer module designed to rapidly manufacture pipes."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/pipe_printer/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.module.modules += new /obj/item/weapon/robot_item_dispenser/pipe(R.module)
		installed = 1
		return 1

/obj/item/borg/upgrade/engineer_printer
	name = "construction parts printer module"
	desc = "Special printer module designed to rapidly manufacture construction part and basic circuits."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/engineer_printer/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!can_install(src, R))
		return 0
	else
		R.module.modules += new /obj/item/weapon/robot_item_dispenser/engineer(R.module)
		installed = 1
		return 1

/obj/item/borg/upgrade/syndicate/
	name = "illegal equipment module"
	desc = "Unlocks the hidden, deadlier functions of a robot."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/syndicate/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(R.emagged == 1)
		return 0

	R.emagged = 1
	installed = 1
	return 1

/obj/item/borg/upgrade/death_alarm
	name = "death alarm module"
	desc = "An alarm which monitors cyborg signals and transmits a radio message upon destruction."
	icon_state = "cyborg_upgrade1"
	origin_tech = list(TECH_MATERIAL = 2, TECH_DATA = 2)
	var/mob/living/silicon/robot/host = null
	var/active = 1
	var/broken = 0

/obj/item/borg/upgrade/death_alarm/proc/activate(var/cause)
	var/area/t = get_area(host)
	var/location = t.name
	if (cause == "emp" && prob(50))
		location =  pick(teleportlocs)
	if(!t.requires_power) // We assume areas that don't use power are some sort of special zones
		var/area/default = world.area
		location = initial(default.name)

	var/death_message = "[host] has been destroyed in [location]!"
	if(!cause)
		death_message = "[host] has been destroyed-zzzzt in-in-in..."
	var/obj/item/weapon/robot_module/CH = host.module
	for(var/channel in CH.channels)
		if (channel != "Science")
			GLOB.global_headset.autosay(death_message, "[host]'s Death Alarm", channel)
	GLOB.global_headset.autosay(death_message, "[host]'s Death Alarm", "Science")

/obj/item/borg/upgrade/death_alarm/Process()
	if (!installed) return

	if(isnull(host)) // If the mob got gibbed
		activate()
		STOP_PROCESSING(SSobj, src)
		installed = 0
	else if (!broken && active && host.stat == DEAD)
		active = 0
		activate("death")
	else if (broken)
		qdel(src)
	else if(host.stat != DEAD)		
		active = 1


/obj/item/borg/upgrade/death_alarm/emp_act(severity)
	if(prob(20))
		activate("emp")	//let's shout that this borg is dead
	if(severity == 1)
		if(prob(60) && !broken)	//small chance of obvious meltdown
			to_chat(host, "<span class='warning'>Your's \the [src] stopped recive signals!</span>")
			broken = 1
			name = "melted circuit"
			desc = "Charred circuit. Wonder what that used to be..."
			STOP_PROCESSING(SSobj, src)

/obj/item/borg/upgrade/death_alarm/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	if(!can_install(src, R))
		return 0
	else
		host = R
		installed = 1
		START_PROCESSING(SSobj, src)
		return 1