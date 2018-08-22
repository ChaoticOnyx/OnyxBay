var/global/list/robot_modules = list(
	"Standard"		= /obj/item/weapon/robot_module/standard,
	"Service" 		= /obj/item/weapon/robot_module/service/butler,
	"Research" 		= /obj/item/weapon/robot_module/research/general,
	"Miner" 		= /obj/item/weapon/robot_module/miner/general,
	"Medical" 		= /obj/item/weapon/robot_module/medical/crisis,
	"Surgeon" 		= /obj/item/weapon/robot_module/medical/surgeon,
	"Security" 		= /obj/item/weapon/robot_module/security/general,
	"Combat" 		= /obj/item/weapon/robot_module/security/combat,
	"Engineering"	= /obj/item/weapon/robot_module/engineering/general,
	"Janitor" 		= /obj/item/weapon/robot_module/janitor/general,
	"Advanced Surgeon"		= /obj/item/weapon/robot_module/medical/surgeon_adv,
	"Advanced Medical"		= /obj/item/weapon/robot_module/medical/crisis_adv,
	"Advanced Engineering"	= /obj/item/weapon/robot_module/engineering/adv,
	"Advanced Miner"		= /obj/item/weapon/robot_module/miner/adv
	)

/obj/item/weapon/robot_module
	name = "robot module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = ITEM_SIZE_NO_CONTAINER
	item_state = "electronic"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	var/hide_on_manifest = 0
	var/channels = list()
	var/networks = list()
	var/languages = list(
		LANGUAGE_SOL_COMMON = 1,
		LANGUAGE_LUNAR = 1,
		LANGUAGE_UNATHI = 0,
		LANGUAGE_SIIK_MAAS = 0,
		LANGUAGE_SKRELLIAN = 0,
		LANGUAGE_GUTTER = 1,
		LANGUAGE_SIGN = 0,
		LANGUAGE_INDEPENDENT = 1,
		LANGUAGE_SPACER = 1)
	var/sprites = list()
	var/can_be_pushed = 1
	var/no_slip = 0
	var/list/modules = list()
	var/list/datum/matter_synth/synths = list()
	var/obj/item/emag = null
	var/list/subsystems = list()
	var/list/obj/item/borg/upgrade/supported_upgrades = list(/obj/item/borg/upgrade/paperwork,/obj/item/borg/upgrade/visor_nvg,/obj/item/borg/upgrade/jetpack,/obj/item/borg/upgrade/visor_x_ray,/obj/item/borg/upgrade/storage,/obj/item/borg/upgrade/visor_flash_screen,/obj/item/borg/upgrade/death_alarm)

	// Bookkeeping
	var/list/original_languages = list()
	var/list/added_networks = list()
	var/appointed_huds = list("Disable", "Security", "Medical")
/obj/item/weapon/robot_module/New(var/mob/living/silicon/robot/R)
	..()
	if (!istype(R))
		return

	R.module = src
	R.avaliable_huds = appointed_huds
	add_camera_networks(R)
	add_languages(R)
	add_subsystems(R)
	apply_status_flags(R)

	if(R.silicon_radio)
		R.silicon_radio.recalculateChannels()

	R.set_module_sprites(sprites)
	R.choose_icon(R.module_sprites.len + 1, R.module_sprites)

	for(var/obj/item/I in modules)
		I.canremove = 0

/obj/item/weapon/robot_module/proc/Reset(var/mob/living/silicon/robot/R)
	remove_camera_networks(R)
	remove_languages(R)
	remove_subsystems(R)
	remove_status_flags(R)

	if(R.silicon_radio)
		R.silicon_radio.recalculateChannels()
	R.choose_icon(0, R.set_module_sprites(list("Default" = "robot")))

/obj/item/weapon/robot_module/Destroy()
	for(var/module in modules)
		qdel(module)
	for(var/synth in synths)
		qdel(synth)
	modules.Cut()
	synths.Cut()
	qdel(emag)
	emag = null
	return ..()

/obj/item/weapon/robot_module/emp_act(severity)
	if(modules)
		for(var/obj/O in modules)
			O.emp_act(severity)
	if(emag)
		emag.emp_act(severity)
	if(synths)
		for(var/datum/matter_synth/S in synths)
			S.emp_act(severity)
	..()
	return

/obj/item/weapon/robot_module/proc/respawn_consumable(var/mob/living/silicon/robot/R, var/rate)
	var/obj/item/device/flash/F = locate() in src.modules
	if(F)
		if(F.broken)
			F.broken = 0
			F.times_used = 0
			F.icon_state = "flash"
		else if(F.times_used)
			F.times_used--
	var/obj/item/weapon/tank/jetpack/carbondioxide/J = locate() in src.modules
	if (J)
		if(J.air_contents.get_total_moles() < 17.4693)
			var/datum/gas_mixture/gas = new /datum/gas_mixture(70, T20C)
			gas.adjust_gas(list("carbon_dioxide" = ONE_ATMOSPHERE), 2, 0)
			J.air_contents.add(gas)
			qdel(gas)
	var/obj/item/weapon/packageWrap/PW = locate() in src.modules
	if (PW)
		PW.amount = 25
	if(!synths || !synths.len)
		return

	for(var/datum/matter_synth/T in synths)
		T.add_charge(T.recharge_rate * rate)

/obj/item/weapon/robot_module/proc/rebuild()//Rebuilds the list so it's possible to add/remove items from the module
	var/list/temp_list = modules
	modules = list()
	for(var/obj/O in temp_list)
		if(O)
			modules += O

/obj/item/weapon/robot_module/proc/add_languages(var/mob/living/silicon/robot/R)
	// Stores the languages as they were before receiving the module, and whether they could be synthezized.
	for(var/datum/language/language_datum in R.languages)
		original_languages[language_datum] = (language_datum in R.speech_synthesizer_langs)

	for(var/language in languages)
		R.add_language(language, languages[language])

/obj/item/weapon/robot_module/proc/remove_languages(var/mob/living/silicon/robot/R)
	// Clear all added languages, whether or not we originally had them.
	for(var/language in languages)
		R.remove_language(language)

	// Then add back all the original languages, and the relevant synthezising ability
	for(var/original_language in original_languages)
		R.add_language(original_language, original_languages[original_language])
	original_languages.Cut()

/obj/item/weapon/robot_module/proc/add_camera_networks(var/mob/living/silicon/robot/R)
	if(R.camera && (NETWORK_ROBOTS in R.camera.network))
		for(var/network in networks)
			if(!(network in R.camera.network))
				R.camera.add_network(network)
				added_networks |= network

/obj/item/weapon/robot_module/proc/remove_camera_networks(var/mob/living/silicon/robot/R)
	if(R.camera)
		R.camera.remove_networks(added_networks)
	added_networks.Cut()

/obj/item/weapon/robot_module/proc/add_subsystems(var/mob/living/silicon/robot/R)
	for(var/subsystem_type in subsystems)
		R.init_subsystem(subsystem_type)

/obj/item/weapon/robot_module/proc/remove_subsystems(var/mob/living/silicon/robot/R)
	for(var/subsystem_type in subsystems)
		R.remove_subsystem(subsystem_type)

/obj/item/weapon/robot_module/proc/apply_status_flags(var/mob/living/silicon/robot/R)
	if(!can_be_pushed)
		R.status_flags &= ~CANPUSH

/obj/item/weapon/robot_module/proc/remove_status_flags(var/mob/living/silicon/robot/R)
	if(!can_be_pushed)
		R.status_flags |= CANPUSH

/obj/item/weapon/robot_module/standard
	name = "standard robot module"
	sprites = list(	"Basic" = "robot_old",
					"Android" = "droid",
					"Default" = "robot",
					"Drone" = "drone-standard",
					"Doot" = "eyebot-standard"
				  )

/obj/item/weapon/robot_module/standard/New()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/melee/baton/loaded(src)
	src.modules += new /obj/item/weapon/extinguisher(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/device/healthanalyzer(src)
	src.modules += new /obj/item/weapon/inflatable_dispenser/robot(src)
	src.emag = new /obj/item/weapon/melee/energy/sword(src)
	..()

/obj/item/weapon/robot_module/medical
	name = "medical robot module"
	channels = list("Medical" = 1)
	networks = list(NETWORK_MEDICAL)
	subsystems = list(/datum/nano_module/crew_monitor)
	can_be_pushed = 0

/obj/item/weapon/robot_module/medical/New()
	..()
	supported_upgrades += list(/obj/item/borg/upgrade/visor_thermal,/obj/item/borg/upgrade/visor_meson, /obj/item/borg/upgrade/bb_printer)

/obj/item/weapon/robot_module/medical/surgeon
	name = "surgeon robot module"
	sprites = list(
					"Basic" = "Medbot",
					"Standard" = "surgeon",
					"Advanced Droid" = "droid-medical",
					"Needles" = "medicalrobot",
					"Drone" = "drone-surgery",
					"Doot" = "eyebot-medical"
					)

/obj/item/weapon/robot_module/medical/surgeon/New()
	supported_upgrades += list(/obj/item/borg/upgrade/organ_printer)

	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.modules += new /obj/item/device/healthanalyzer(src)
	src.modules += new /obj/item/weapon/reagent_containers/borghypo/surgeon(src)
	src.modules += new /obj/item/weapon/scalpel/manager(src)
	src.modules += new /obj/item/weapon/hemostat(src)
	src.modules += new /obj/item/weapon/retractor(src)
	src.modules += new /obj/item/weapon/cautery(src)
	src.modules += new /obj/item/weapon/bonegel(src)
	src.modules += new /obj/item/weapon/FixOVein(src)
	src.modules += new /obj/item/weapon/bonesetter(src)
	src.modules += new /obj/item/weapon/circular_saw(src)
	src.modules += new /obj/item/weapon/surgicaldrill(src)
	src.modules += new /obj/item/weapon/gripper/surgical(src)
	src.modules += new /obj/item/weapon/reagent_containers/dna_sampler(src)
	src.modules += new /obj/item/roller_holder(src)
	src.modules += new /obj/item/weapon/shockpaddles/robot(src)
	src.modules += new /obj/item/robot_rack/medical/surgical(src)
	src.emag = new /obj/item/weapon/reagent_containers/spray(src)
	src.emag.reagents.add_reagent(/datum/reagent/acid/polyacid, 250)
	src.emag.SetName("Polyacid spray")

	var/datum/matter_synth/medicine = new /datum/matter_synth/medicine(10000)
	synths += medicine

	var/obj/item/stack/nanopaste/N = new /obj/item/stack/nanopaste(src)
	var/obj/item/stack/medical/advanced/bruise_pack/B = new /obj/item/stack/medical/advanced/bruise_pack(src)
	N.uses_charge = 1
	N.charge_costs = list(1000)
	N.synths = list(medicine)
	B.uses_charge = 1
	B.charge_costs = list(1000)
	B.synths = list(medicine)
	src.modules += N
	src.modules += B

	..()

/obj/item/weapon/robot_module/medical/surgeon/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	if(src.emag)
		var/obj/item/weapon/reagent_containers/spray/PS = src.emag
		PS.reagents.add_reagent(/datum/reagent/acid/polyacid, 5 * amount)
	..()

/obj/item/weapon/robot_module/medical/surgeon_adv
	name = "advanced surgeon robot module"
	sprites = list(
					"Basic" = "Medbot",
					"Standard" = "surgeon",
					"Advanced Droid" = "droid-medical",
					"Needles" = "medicalrobot",
					"Drone" = "drone-surgery",
					"Doot" = "eyebot-medical"
					)


/obj/item/weapon/robot_module/medical/surgeon_adv/New()
	supported_upgrades += list(/obj/item/borg/upgrade/organ_printer)

	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.modules += new /obj/item/device/healthanalyzer(src)
	src.modules += new /obj/item/weapon/autopsy_scanner(src)
	src.modules += new /obj/item/weapon/reagent_containers/borghypo/surgeon_adv(src)
	src.modules += new /obj/item/weapon/scalpel/manager(src)
	src.modules += new /obj/item/weapon/hemostat/pico(src)
	src.modules += new /obj/item/weapon/retractor(src)
	src.modules += new /obj/item/weapon/cautery(src)
	src.modules += new /obj/item/weapon/FixOVein/clot(src)
	src.modules += new /obj/item/weapon/bonesetter/bone_mender(src)
	src.modules += new /obj/item/weapon/circular_saw/plasmasaw(src)
	src.modules += new /obj/item/weapon/surgicaldrill(src)
	src.modules += new /obj/item/weapon/gripper/surgical(src)
	src.modules += new /obj/item/weapon/reagent_containers/dna_sampler(src)
	src.modules += new /obj/item/weapon/shockpaddles/robot(src)
	src.modules += new /obj/item/weapon/reagent_containers/dropper/industrial(src)
	src.modules += new /obj/item/robot_rack/medical/surgical(src)
	var/obj/item/weapon/reagent_containers/spray/cleaner/drone/SC = new /obj/item/weapon/reagent_containers/spray/cleaner/drone(src)
	SC.reagents.add_reagent(/datum/reagent/space_cleaner,150)
	src.modules += SC
	src.emag = new /obj/item/weapon/reagent_containers/spray(src)
	src.emag.reagents.add_reagent(/datum/reagent/acid/polyacid, 250)
	src.emag.SetName("Polyacid spray")

	var/datum/matter_synth/medicine = new /datum/matter_synth/medicine(20000)
	synths += medicine

	var/obj/item/stack/nanopaste/N = new /obj/item/stack/nanopaste(src)
	var/obj/item/stack/medical/advanced/bruise_pack/B = new /obj/item/stack/medical/advanced/bruise_pack(src)
	N.uses_charge = 1
	N.charge_costs = list(1000)
	N.synths = list(medicine)
	B.uses_charge = 1
	B.charge_costs = list(1000)
	B.synths = list(medicine)
	src.modules += N
	src.modules += B
	src.modules += new /obj/item/roller_holder(src)
	..()

/obj/item/weapon/robot_module/medical/surgeon_adv/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	if(src.emag)
		var/obj/item/weapon/reagent_containers/spray/PS = src.emag
		PS.reagents.add_reagent(/datum/reagent/acid/polyacid, 5 * amount)

	var/obj/item/weapon/reagent_containers/spray/cleaner/drone/SC = locate(/obj/item/weapon/reagent_containers/spray/cleaner/drone) in src.modules
	SC.reagents.add_reagent(/datum/reagent/space_cleaner,10 * amount)

	..()

/obj/item/weapon/robot_module/medical/crisis
	name = "medical robot module"
	sprites = list(
					"Basic" = "Medbot",
					"Standard" = "surgeon",
					"Advanced Droid" = "droid-medical",
					"Needles" = "medicalrobot",
					"Drone - Medical" = "drone-medical",
					"Drone - Chemistry" = "drone-chemistry",
					"Doot" = "eyebot-medical"
					)

/obj/item/weapon/robot_module/medical/crisis/New()
	supported_upgrades += list(/obj/item/borg/upgrade/blood_printer)
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.modules += new /obj/item/device/healthanalyzer(src)
	src.modules += new /obj/item/device/reagent_scanner/adv(src)
	src.modules += new /obj/item/weapon/reagent_containers/borghypo/crisis(src)
	src.modules += new /obj/item/weapon/shockpaddles/robot(src)
	src.modules += new /obj/item/weapon/reagent_containers/dropper(src)
	src.modules += new /obj/item/weapon/reagent_containers/syringe(src)
	src.modules += new /obj/item/weapon/gripper/chemistry(src)
	src.modules += new /obj/item/taperoll/medical(src)
	src.modules += new /obj/item/robot_rack/medical(src)
	src.modules += new /obj/item/weapon/inflatable_dispenser/robot(src) // Allows usage of inflatables. Since they are basically robotic alternative to EMTs, they should probably have them.
	src.emag = new /obj/item/weapon/reagent_containers/spray(src)
	src.emag.reagents.add_reagent(/datum/reagent/acid/polyacid, 250)
	src.emag.SetName("Polyacid spray")

	var/datum/matter_synth/medicine = new /datum/matter_synth/medicine(15000)
	synths += medicine

	var/obj/item/stack/medical/ointment/O = new /obj/item/stack/medical/ointment(src)
	var/obj/item/stack/medical/bruise_pack/B = new /obj/item/stack/medical/bruise_pack(src)
	var/obj/item/stack/medical/splint/S = new /obj/item/stack/medical/splint(src)
	O.uses_charge = 1
	O.charge_costs = list(1000)
	O.synths = list(medicine)
	B.uses_charge = 1
	B.charge_costs = list(1000)
	B.synths = list(medicine)
	S.uses_charge = 1
	S.charge_costs = list(1000)
	S.synths = list(medicine)
	src.modules += O
	src.modules += B
	src.modules += S
	src.modules += new /obj/item/roller_holder(src)

	appointed_huds += list("Science")
	..()

/obj/item/weapon/robot_module/medical/crisis/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	var/obj/item/weapon/reagent_containers/syringe/S = locate() in src.modules
	if(S.mode == 2)
		S.reagents.clear_reagents()
		S.mode = initial(S.mode)
		S.desc = initial(S.desc)
		S.update_icon()

	if(src.emag)
		var/obj/item/weapon/reagent_containers/spray/PS = src.emag
		PS.reagents.add_reagent(/datum/reagent/acid/polyacid, 5 * amount)

	..()

/obj/item/weapon/robot_module/medical/crisis_adv
	name = "advanced medical robot module"
	sprites = list(
					"Basic" = "Medbot",
					"Standard" = "surgeon",
					"Advanced Droid" = "droid-medical",
					"Needles" = "medicalrobot",
					"Drone - Medical" = "drone-medical",
					"Drone - Chemistry" = "drone-chemistry",
					"Doot" = "eyebot-medical"
					)

/obj/item/weapon/robot_module/medical/crisis_adv/New()
	supported_upgrades += list(/obj/item/borg/upgrade/blood_printer)

	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.modules += new /obj/item/device/healthanalyzer_advanced(src)
	src.modules += new /obj/item/device/slime_scanner(src)
	src.modules += new /obj/item/device/reagent_scanner/adv(src)
	src.modules += new /obj/item/device/mass_spectrometer/adv(src)
	src.modules += new /obj/item/weapon/reagent_containers/borghypo/crisis_adv(src)
	src.modules += new /obj/item/weapon/shockpaddles/robot(src)
	src.modules += new /obj/item/weapon/reagent_containers/dropper/industrial(src)
	src.modules += new /obj/item/weapon/reagent_containers/syringe(src)
	src.modules += new /obj/item/weapon/gripper/chemistry(src)
	src.modules += new /obj/item/taperoll/medical(src)
	src.modules += new /obj/item/robot_rack/medical(src)
	src.modules += new /obj/item/weapon/inflatable_dispenser/robot(src) // Allows usage of inflatables. Since they are basically robotic alternative to EMTs, they should probably have them.
	var/obj/item/weapon/reagent_containers/spray/cleaner/drone/SC = new /obj/item/weapon/reagent_containers/spray/cleaner/drone(src)
	SC.reagents.add_reagent(/datum/reagent/space_cleaner,150)
	src.emag = new /obj/item/weapon/reagent_containers/spray(src)
	src.modules += SC
	src.emag.reagents.add_reagent(/datum/reagent/acid/polyacid, 250)
	src.emag.SetName("Polyacid spray")

	var/datum/matter_synth/medicine = new /datum/matter_synth/medicine(25000)
	synths += medicine

	var/obj/item/stack/medical/advanced/ointment/O = new /obj/item/stack/medical/advanced/ointment(src)
	var/obj/item/stack/medical/advanced/bruise_pack/B = new /obj/item/stack/medical/advanced/bruise_pack(src)
	var/obj/item/stack/medical/splint/S = new /obj/item/stack/medical/splint(src)
	O.uses_charge = 1
	O.charge_costs = list(1000)
	O.synths = list(medicine)
	B.uses_charge = 1
	B.charge_costs = list(1000)
	B.synths = list(medicine)
	S.uses_charge = 1
	S.charge_costs = list(1000)
	S.synths = list(medicine)
	src.modules += O
	src.modules += B
	src.modules += S
	src.modules += new /obj/item/roller_holder(src)

	appointed_huds += list("Science", "Meson")
	..()

/obj/item/weapon/robot_module/medical/crisis_adv/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	var/obj/item/weapon/reagent_containers/syringe/S = locate() in src.modules
	if(S.mode == 2)
		S.reagents.clear_reagents()
		S.mode = initial(S.mode)
		S.desc = initial(S.desc)
		S.update_icon()

	if(src.emag)
		var/obj/item/weapon/reagent_containers/spray/PS = src.emag
		PS.reagents.add_reagent(/datum/reagent/acid/polyacid, 5 * amount)

	var/obj/item/weapon/reagent_containers/spray/cleaner/drone/SC = locate(/obj/item/weapon/reagent_containers/spray/cleaner/drone) in src.modules
	SC.reagents.add_reagent(/datum/reagent/space_cleaner,10 * amount)

	..()


/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"
	channels = list("Engineering" = 1)
	networks = list(NETWORK_ENGINEERING)
	subsystems = list(/datum/nano_module/power_monitor, /datum/nano_module/supermatter_monitor)
	sprites = list(
					"Basic" = "Engineering",
					"Antique" = "engineerrobot",
					"Landmate" = "landmate",
					"Landmate - Treaded" = "engiborg+tread",
					"Drone" = "drone-engineer",
					"Doot" = "eyebot-engineering"
					)
	no_slip = 1

/obj/item/weapon/robot_module/engineering/New()
	..()
	supported_upgrades += list(/obj/item/borg/upgrade/cargo_managment,/obj/item/borg/upgrade/rcd,/obj/item/borg/upgrade/paramedic,/obj/item/borg/upgrade/engineer_printer,/obj/item/borg/upgrade/pipe_printer)

/obj/item/weapon/robot_module/engineering/general/New()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/extinguisher(src)
	src.modules += new /obj/item/weapon/weldingtool/largetank(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/wirecutters(src)
	src.modules += new /obj/item/device/multitool(src)
	src.modules += new /obj/item/device/t_scanner(src)
	src.modules += new /obj/item/device/analyzer(src)
	src.modules += new /obj/item/device/geiger(src)
	src.modules += new /obj/item/taperoll/engineering(src)
	src.modules += new /obj/item/taperoll/atmos(src)
	src.modules += new /obj/item/weapon/gripper(src)
	src.modules += new /obj/item/device/lightreplacer(src)
	src.modules += new /obj/item/weapon/inflatable_dispenser/robot(src)
	src.modules += new /obj/item/robot_rack/engineer(src)
	src.emag = new /obj/item/weapon/melee/baton/robot/electrified_arm(src)

	var/datum/matter_synth/metal = new /datum/matter_synth/metal(60000)
	var/datum/matter_synth/glass = new /datum/matter_synth/glass(40000)
	var/datum/matter_synth/plasteel = new /datum/matter_synth/plasteel(20000)
	var/datum/matter_synth/wire = new /datum/matter_synth/wire(100)
	synths += metal
	synths += glass
	synths += plasteel
	synths += wire

	var/obj/item/weapon/matter_decompiler/MD = new /obj/item/weapon/matter_decompiler(src)
	MD.metal = metal
	MD.glass = glass
	src.modules += MD

	var/obj/item/stack/material/cyborg/steel/M = new (src)
	M.synths = list(metal)
	src.modules += M

	var/obj/item/stack/material/cyborg/glass/G = new (src)
	G.synths = list(glass)
	src.modules += G

	var/obj/item/stack/rods/cyborg/R = new /obj/item/stack/rods/cyborg(src)
	R.synths = list(metal)
	src.modules += R

	var/obj/item/stack/cable_coil/cyborg/C = new /obj/item/stack/cable_coil/cyborg(src)
	C.synths = list(wire)
	src.modules += C

	var/obj/item/stack/tile/floor/cyborg/S = new /obj/item/stack/tile/floor/cyborg(src)
	S.synths = list(metal)
	src.modules += S

	var/obj/item/stack/material/cyborg/glass/reinforced/RG = new (src)
	RG.synths = list(metal, glass)
	src.modules += RG

	var/obj/item/stack/material/cyborg/plasteel/PL = new (src)
	PL.synths = list(plasteel)
	src.modules += PL

	appointed_huds += list("Meson")
	..()

/obj/item/weapon/robot_module/engineering/general/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	var/obj/item/device/lightreplacer/LR = locate() in src.modules
	LR.Charge(R, amount)
	..()

/obj/item/weapon/robot_module/engineering/adv
	name = "advanced engineering robot module"
	subsystems = list(/datum/nano_module/power_monitor,/datum/nano_module/rcon,/datum/nano_module/supermatter_monitor,/datum/nano_module/atmos_control)


/obj/item/weapon/robot_module/engineering/adv/New()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/extinguisher(src)
	src.modules += new /obj/item/weapon/weldingtool/hugetank(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/crowbar/brace_jack(src)
	src.modules += new /obj/item/weapon/wirecutters(src)
	src.modules += new /obj/item/device/multitool(src)
	src.modules += new /obj/item/device/t_scanner/advanced(src)
	src.modules += new /obj/item/device/analyzer(src)
	src.modules += new /obj/item/device/geiger(src)
	src.modules += new /obj/item/weapon/shield_diffuser(src)
	src.modules += new /obj/item/taperoll/engineering(src)
	src.modules += new /obj/item/taperoll/atmos(src)
	src.modules += new /obj/item/weapon/gripper(src)
	src.modules += new /obj/item/device/lightreplacer/advanced(src)
	src.modules += new /obj/item/device/pipe_painter(src)
	src.modules += new /obj/item/device/floor_painter(src)
	src.modules += new /obj/item/weapon/inflatable_dispenser/robot(src)
	src.modules += new /obj/item/robot_rack/engineer(src)
	src.emag = new /obj/item/weapon/melee/baton/robot/electrified_arm(src)

	var/datum/matter_synth/metal = new /datum/matter_synth/metal(80000)
	var/datum/matter_synth/glass = new /datum/matter_synth/glass(60000)
	var/datum/matter_synth/wood = new /datum/matter_synth/wood(40000)
	var/datum/matter_synth/plastic = new /datum/matter_synth/plastic(40000)
	var/datum/matter_synth/marble = new /datum/matter_synth/marble(40000)
	var/datum/matter_synth/plasteel = new /datum/matter_synth/plasteel(30000)
	var/datum/matter_synth/wire = new /datum/matter_synth/wire(100)
	synths += metal
	synths += glass
	synths += wood
	synths += plastic
	synths += marble
	synths += plasteel
	synths += wire

	var/obj/item/weapon/matter_decompiler/MD = new /obj/item/weapon/matter_decompiler(src)
	MD.metal = metal
	MD.glass = glass
	src.modules += MD

	var/obj/item/stack/material/cyborg/steel/M = new (src)
	M.synths = list(metal)
	src.modules += M

	var/obj/item/stack/material/cyborg/glass/G = new (src)
	G.synths = list(glass)
	src.modules += G

	var/obj/item/stack/material/cyborg/wood/W = new (src)
	W.synths = list(wood)
	src.modules += W

	var/obj/item/stack/material/cyborg/plastic/P = new (src)
	P.synths = list(plastic)
	src.modules += P

	var/obj/item/stack/material/cyborg/marble/MA = new (src)
	MA.synths = list(marble)
	src.modules += MA

	var/obj/item/stack/rods/cyborg/R = new /obj/item/stack/rods/cyborg(src)
	R.synths = list(metal)
	src.modules += R

	var/obj/item/stack/cable_coil/cyborg/C = new /obj/item/stack/cable_coil/cyborg(src)
	C.synths = list(wire)
	src.modules += C

	var/obj/item/stack/tile/floor/cyborg/S = new /obj/item/stack/tile/floor/cyborg(src)
	S.synths = list(metal)
	src.modules += S

	var/obj/item/stack/material/cyborg/glass/reinforced/RG = new (src)
	RG.synths = list(metal, glass)
	src.modules += RG

	var/obj/item/stack/material/cyborg/plasteel/PL = new (src)
	PL.synths = list(plasteel)
	src.modules += PL

	appointed_huds += list("Meson", "Material")
	..()

/obj/item/weapon/robot_module/engineering/general/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	var/obj/item/device/lightreplacer/advanced/LR = locate() in src.modules
	LR.Charge(R, amount)
	..()

/obj/item/weapon/robot_module/security
	name = "security robot module"
	channels = list("Security" = 1)
	networks = list(NETWORK_SECURITY)
	subsystems = list(/datum/nano_module/crew_monitor, /datum/nano_module/digitalwarrant)
	can_be_pushed = 0

/obj/item/weapon/robot_module/security/New()
	..()
	supported_upgrades += list(/obj/item/borg/upgrade/lasercooler,/obj/item/borg/upgrade/tasercooler,/obj/item/borg/upgrade/visor_thermal,/obj/item/borg/upgrade/paramedic,/obj/item/borg/upgrade/detective)

/obj/item/weapon/robot_module/security/general
	sprites = list(
					"Basic" = "secborg",
					"Red Knight" = "Security",
					"Black Knight" = "securityrobot",
					"Bloodhound" = "bloodhound",
					"Bloodhound - Treaded" = "secborg+tread",
					"Drone" = "drone-sec",
					"Doot" = "eyebot-security",
					"Tridroid" = "orb-security"
				)

/obj/item/weapon/robot_module/security/general/New()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.modules += new /obj/item/weapon/handcuffs/cyborg(src)
	src.modules += new /obj/item/weapon/melee/baton/robot(src)
	src.modules += new /obj/item/weapon/gun/energy/taser/mounted/cyborg(src)
	src.modules += new /obj/item/taperoll/police(src)
	src.modules += new /obj/item/robot_rack/weapon(src)
	src.modules += new /obj/item/device/megaphone(src)
	src.modules += new /obj/item/weapon/gripper/security(src)
	src.modules += new /obj/item/weapon/card/robot_sec(src)
	src.modules += new /obj/item/device/holowarrant(src)
	var/obj/item/weapon/gun/energy/laser/mounted/cyborg/LC = new /obj/item/weapon/gun/energy/laser/mounted/cyborg(src)
	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
	if (security_state.current_security_level.name == "code red")
		LC.locked = 0
	src.modules += LC
	src.emag = new /obj/item/weapon/gun/energy/lasercannon/mounted(src)
	..()

/obj/item/weapon/robot_module/security/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	..()
	var/obj/item/weapon/gun/energy/taser/mounted/cyborg/T = locate() in src.modules
	var/obj/item/weapon/gun/energy/laser/mounted/cyborg/LC = locate() in src.modules
	if(T && T.power_supply)
		if(T.power_supply.charge < T.power_supply.maxcharge)
			T.power_supply.give(T.charge_cost * amount)
			T.update_icon()
		else
			T.charge_tick = 0
	if(LC && LC.power_supply)
		if(LC.power_supply.charge < LC.power_supply.maxcharge)
			LC.power_supply.give(LC.charge_cost * amount)
			LC.update_icon()
		else
			LC.charge_tick = 0

	var/obj/item/weapon/reagent_containers/spray/luminol/L = locate(/obj/item/weapon/reagent_containers/spray/luminol) in src.modules
	if (L)
		L.reagents.add_reagent(/datum/reagent/luminol,5 * amount)
	
	var/obj/item/weapon/melee/baton/robot/B = locate() in src.modules
	if(B && B.bcell)
		B.bcell.give(amount)

/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"
	channels = list("Service" = 1)
	sprites = list(
					"Basic" = "JanBot2",
					"Mopbot"  = "janitorrobot",
					"Mop Gear Rex" = "mopgearrex",
					"Drone" = "drone-janitor",
					"Doot" = "eyebot-janitor"
					)

/obj/item/weapon/robot_module/janitor/general/New()
	supported_upgrades += list(/obj/item/borg/upgrade/paramedic)

	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.modules += new /obj/item/weapon/soap/nanotrasen(src)
	src.modules += new /obj/item/weapon/storage/bag/trash(src)
	src.modules += new /obj/item/weapon/mop(src)
	src.modules += new /obj/item/device/lightreplacer(src)

	src.emag = new /obj/item/weapon/reagent_containers/spray(src)
	src.emag.reagents.add_reagent(/datum/reagent/lube, 250)
	src.emag.SetName("Lube spray")
	..()


/obj/item/weapon/robot_module/janitor/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	..()
	var/obj/item/device/lightreplacer/LR = locate() in src.modules
	LR.Charge(R, amount)
	if(src.emag)
		var/obj/item/weapon/reagent_containers/spray/S = src.emag
		S.reagents.add_reagent(/datum/reagent/lube, 20 * amount)

/obj/item/weapon/robot_module/service
	name = "service robot module"
	channels = list("Service" = 1)
	languages = list(
					LANGUAGE_SOL_COMMON	= 1,
					LANGUAGE_UNATHI		= 1,
					LANGUAGE_SIIK_MAAS	= 1,
					LANGUAGE_SIIK_TAJR	= 0,
					LANGUAGE_SKRELLIAN	= 1,
					LANGUAGE_LUNAR	= 1,
					LANGUAGE_GUTTER		= 1,
					LANGUAGE_INDEPENDENT= 1,
					LANGUAGE_SPACER = 1
					)
/obj/item/weapon/robot_module/service/New()
	..()
	supported_upgrades += list(/obj/item/borg/upgrade/paramedic)


/obj/item/weapon/robot_module/service/butler
	sprites = list(	"Waitress" = "Service",
					"Kent" = "toiletbot",
					"Bro" = "Brobot",
					"Rich" = "maximillion",
					"Default" = "Service2",
					"Drone - Service" = "drone-service",
					"Drone - Hydro" = "drone-hydro",
					"Doot" = "eyebot-standard"
				  	)

/obj/item/weapon/robot_module/service/butler/New()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/crowbar(src)	
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.modules += new /obj/item/weapon/gripper/service(src)
	src.modules += new /obj/item/weapon/reagent_containers/glass/bucket(src)
	src.modules += new /obj/item/weapon/material/minihoe(src)
	src.modules += new /obj/item/weapon/material/hatchet(src)
	src.modules += new /obj/item/device/analyzer/plant_analyzer(src)
	src.modules += new /obj/item/weapon/storage/plants(src)
	src.modules += new /obj/item/weapon/robot_harvester(src)
	src.modules += new /obj/item/weapon/material/kitchen/rollingpin(src)
	src.modules += new /obj/item/weapon/material/knife(src)

	var/obj/item/weapon/rsf/M = new /obj/item/weapon/rsf(src)
	M.stored_matter = 30
	src.modules += M

	src.modules += new /obj/item/weapon/reagent_containers/dropper/industrial(src)

	var/obj/item/weapon/flame/lighter/zippo/L = new /obj/item/weapon/flame/lighter/zippo(src)
	L.lit = 1
	src.modules += L

	src.modules += new /obj/item/weapon/tray/robotray(src)
	src.modules += new /obj/item/weapon/reagent_containers/borghypo/service(src)
	src.emag = new /obj/item/weapon/reagent_containers/food/drinks/bottle/small/beer(src)

	var/datum/reagents/R = src.emag.create_reagents(50)
	R.add_reagent(/datum/reagent/chloralhydrate/beer2, 50)
	src.emag.SetName("Mickey Finn's Special Brew")
	..()

/obj/item/weapon/robot_module/general/butler/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	..()
	var/obj/item/weapon/reagent_containers/food/condiment/enzyme/E = locate() in src.modules
	E.reagents.add_reagent(/datum/reagent/enzyme, 10 * amount)
	if(src.emag)
		var/obj/item/weapon/reagent_containers/food/drinks/bottle/small/beer/B = src.emag
		B.reagents.add_reagent(/datum/reagent/chloralhydrate/beer2, 10 * amount)

/obj/item/weapon/robot_module/miner
	name = "miner robot module"
	subsystems = list(/datum/nano_module/supply)
	channels = list("Supply" = 1, "Science" = 1)
	networks = list(NETWORK_MINE)
	sprites = list(
					"Basic" = "Miner_old",
					"Advanced Droid" = "droid-miner",
					"Treadhead" = "Miner",
					"Drone" = "drone-miner",
					"Doot" = "eyebot-miner"
				)

/obj/item/weapon/robot_module/miner/New()
	..()
	supported_upgrades += list(/obj/item/borg/upgrade/cargo_managment,/obj/item/borg/upgrade/visor_thermal,/obj/item/borg/upgrade/paramedic,/obj/item/borg/upgrade/archeologist)

/obj/item/weapon/robot_module/miner/general/New()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/storage/ore(src)
	src.modules += new /obj/item/weapon/pickaxe/borgdrill(src)
	src.modules += new /obj/item/weapon/storage/sheetsnatcher/borg(src)
	src.modules += new /obj/item/weapon/gripper/miner(src)
	src.modules += new /obj/item/weapon/mining_scanner(src)
	src.emag = new /obj/item/weapon/gun/energy/plasmacutter(src)
	appointed_huds += list("Meson")
	..()

/obj/item/weapon/robot_module/miner/adv/New()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/storage/ore(src)
	src.modules += new /obj/item/weapon/pickaxe/diamonddrill(src)
	src.modules += new /obj/item/weapon/gun/energy/kinetic_accelerator/cyborg(src)
	src.modules += new /obj/item/weapon/storage/sheetsnatcher/borg(src)
	src.modules += new /obj/item/weapon/gripper/miner(src)
	src.modules += new /obj/item/robot_rack/miner(src)
	src.modules += new /obj/item/weapon/mining_scanner(src)
	src.emag = new /obj/item/weapon/gun/energy/plasmacutter(src)
	appointed_huds += list("Meson")
	..()

/obj/item/weapon/robot_module/research
	name = "research module"

	channels = list("Science" = 1)
	networks = list(NETWORK_RESEARCH)
	//subsystems = list(/datum/nano_module/computer_ntnetmonitor) reserved for adv_science
	sprites = list(
					"Droid" = "droid-science",
					"Drone" = "drone-science",
					"Doot" = "eyebot-science"
					)

/obj/item/weapon/robot_module/research/general/New()
	supported_upgrades += list(/obj/item/borg/upgrade/cargo_managment,/obj/item/borg/upgrade/visor_thermal,/obj/item/borg/upgrade/visor_meson,/obj/item/borg/upgrade/rped,/obj/item/borg/upgrade/paramedic,/obj/item/borg/upgrade/archeologist)

	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.modules += new /obj/item/weapon/portable_destructive_analyzer(src)
	src.modules += new /obj/item/weapon/gripper/research(src)
	src.modules += new /obj/item/weapon/gripper/no_use/loader(src)
	src.modules += new /obj/item/device/robotanalyzer(src)
	src.modules += new /obj/item/weapon/card/robot(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/weldingtool/mini(src)
	src.modules += new /obj/item/weapon/wirecutters(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/scalpel/laser3(src)
	src.modules += new /obj/item/weapon/circular_saw(src)
	src.modules += new /obj/item/weapon/reagent_containers/syringe(src)
	src.modules += new /obj/item/weapon/gripper/chemistry(src)
	src.emag = new /obj/prefab/hand_teleporter(src)

	var/datum/matter_synth/nanite = new /datum/matter_synth/nanite(10000)
	synths += nanite

	var/obj/item/stack/nanopaste/N = new /obj/item/stack/nanopaste(src)
	N.uses_charge = 1
	N.charge_costs = list(1000)
	N.synths = list(nanite)
	src.modules += N
	appointed_huds += list("Science")
	..()

/obj/item/weapon/robot_module/syndicate
	name = "illegal robot module"
	hide_on_manifest = 1
	sprites = list(
					"Dread" = "securityrobot",
				)
	var/id

/obj/item/weapon/robot_module/syndicate/New(var/mob/living/silicon/robot/R)
	supported_upgrades += list(/obj/item/borg/upgrade/tasercooler,/obj/item/borg/upgrade/lasercooler,/obj/item/borg/upgrade/visor_thermal,/obj/item/borg/upgrade/paramedic,/obj/item/borg/upgrade/detective)

	loc = R
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.modules += new /obj/item/weapon/melee/energy/sword(src)
	src.modules += new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(src)
	src.modules += new /obj/item/weapon/card/emag(src)
	var/jetpack = new/obj/item/weapon/tank/jetpack/carbondioxide(src)
	src.modules += jetpack
	R.internals = jetpack

	id = R.idcard
	src.modules += id
	..()

/obj/item/weapon/robot_module/syndicate/Destroy()
	src.modules -= id
	id = null
	return ..()

/obj/item/weapon/robot_module/security/combat
	name = "combat robot module"
	hide_on_manifest = 1
	sprites = list("Combat Android" = "droid-combat")

/obj/item/weapon/robot_module/security/combat/New()
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/gun/energy/laser/mounted(src)
	src.modules += new /obj/item/weapon/gun/energy/plasmacutter(src)
	src.modules += new /obj/item/borg/combat/shield(src)
	src.modules += new /obj/item/borg/combat/mobility(src)
	src.emag = new /obj/item/weapon/gun/energy/lasercannon/mounted(src)
	..()

/obj/item/weapon/robot_module/drone
	name = "drone module"
	hide_on_manifest = 1
	no_slip = 1
	networks = list(NETWORK_ENGINEERING)

/obj/item/weapon/robot_module/drone/New(var/mob/living/silicon/robot/robot)
	src.modules += new /obj/item/weapon/weldingtool(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/wirecutters(src)
	src.modules += new /obj/item/device/multitool(src)
	src.modules += new /obj/item/device/lightreplacer(src)
	src.modules += new /obj/item/weapon/gripper(src)
	src.modules += new /obj/item/weapon/soap(src)
	src.modules += new /obj/item/weapon/gripper/no_use/loader(src)
	src.modules += new /obj/item/weapon/extinguisher/mini(src)
	src.modules += new /obj/item/device/pipe_painter(src)
	src.modules += new /obj/item/device/floor_painter(src)
	src.modules += new /obj/item/robot_rack/general(src)
	src.modules += new /obj/item/weapon/robot_item_dispenser/engineer(src)
	src.modules += new /obj/item/weapon/robot_item_dispenser/pipe(src)
	src.modules += new /obj/item/weapon/reagent_containers/spray/cleaner/drone(src)
	src.modules += new /obj/item/device/t_scanner(src)

	robot.internals = new/obj/item/weapon/tank/jetpack/carbondioxide(src)
	src.modules += robot.internals

	src.emag = new /obj/item/weapon/gun/energy/plasmacutter(src)
	src.emag.SetName("Plasma Cutter")

	var/datum/matter_synth/metal = new /datum/matter_synth/metal(25000)
	var/datum/matter_synth/glass = new /datum/matter_synth/glass(25000)
	var/datum/matter_synth/wood = new /datum/matter_synth/wood(2000)
	var/datum/matter_synth/plastic = new /datum/matter_synth/plastic(1000)
	var/datum/matter_synth/wire = new /datum/matter_synth/wire(30)
	synths += metal
	synths += glass
	synths += wood
	synths += plastic
	synths += wire

	var/obj/item/weapon/matter_decompiler/MD = new /obj/item/weapon/matter_decompiler(src)
	MD.metal = metal
	MD.glass = glass
	MD.wood = wood
	MD.plastic = plastic
	src.modules += MD

	var/obj/item/stack/material/cyborg/steel/M = new (src)
	M.synths = list(metal)
	src.modules += M

	var/obj/item/stack/material/cyborg/glass/G = new (src)
	G.synths = list(glass)
	src.modules += G

	var/obj/item/stack/rods/cyborg/R = new /obj/item/stack/rods/cyborg(src)
	R.synths = list(metal)
	src.modules += R

	var/obj/item/stack/cable_coil/cyborg/C = new /obj/item/stack/cable_coil/cyborg(src)
	C.synths = list(wire)
	src.modules += C

	var/obj/item/stack/tile/floor/cyborg/S = new /obj/item/stack/tile/floor/cyborg(src)
	S.synths = list(metal)
	src.modules += S

	var/obj/item/stack/material/cyborg/glass/reinforced/RG = new (src)
	RG.synths = list(metal, glass)
	src.modules += RG

	var/obj/item/stack/tile/wood/cyborg/WT = new /obj/item/stack/tile/wood/cyborg(src)
	WT.synths = list(wood)
	src.modules += WT

	var/obj/item/stack/material/cyborg/wood/W = new (src)
	W.synths = list(wood)
	src.modules += W

	var/obj/item/stack/material/cyborg/plastic/P = new (src)
	P.synths = list(plastic)
	src.modules += P
	..()

/obj/item/weapon/robot_module/drone/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	..()
	var/obj/item/weapon/reagent_containers/spray/cleaner/drone/SC = locate() in src.modules
	SC.reagents.add_reagent(/datum/reagent/space_cleaner, 10 * amount)

/obj/item/weapon/robot_module/drone/construction
	name = "construction drone module"
	hide_on_manifest = 1
	channels = list("Engineering" = 1)
	languages = list()

/obj/item/weapon/robot_module/drone/construction/New()
	src.modules += new /obj/item/weapon/rcd/borg(src)
	..()

/obj/item/weapon/robot_module/drone/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	var/obj/item/device/lightreplacer/LR = locate() in src.modules
	LR.Charge(R, amount)
	..()
	return
