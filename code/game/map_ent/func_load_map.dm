/obj/map_ent/func_load_map
	name = "func_load_map"
	icon_state = "func_load_map"

	var/ev_map_path
	var/ev_clear_conents = TRUE

/obj/map_ent/func_load_map/activate()
	if(!ev_map_path)
		util_crash_with("func_load_map has invalid ev_map_path: `[ev_map_path]`")
		return

	var/map_file

	if(istext(ev_map_path))
		map_file = file(ev_map_path)

// Copypasta from `map_template` 👇
	var/list/atoms_to_initialise = list()
	var/datum/map_load_metadata/M = maploader.load_map(map_file, loc.x, loc.y, loc.z, FALSE, FALSE, TRUE, ev_clear_conents)

	if (M)
		atoms_to_initialise += M.atoms_to_initialise
	else
		util_crash_with("can't load map")
		return

	// Initialize things that are normally initialized after map load
	__init_atoms(atoms_to_initialise)

/obj/map_ent/func_load_map/proc/__init_atoms(list/atoms)
	if (SSatoms.init_state == INITIALIZATION_INSSATOMS)
		return // Let proper initialisation handle it later

	var/list/turf/turfs = list()
	var/list/obj/machinery/atmospherics/atmos_machines = list()
	var/list/obj/machinery/machines = list()
	var/list/obj/structure/cable/cables = list()

	for(var/atom/A in atoms)
		if(istype(A, /turf))
			turfs += A
		if(istype(A, /obj/structure/cable))
			cables += A
		if(istype(A, /obj/machinery/atmospherics))
			atmos_machines += A
		if(istype(A, /obj/machinery))
			machines += A

	SSatoms.InitializeAtoms(atoms)

	SSmachines.setup_template_powernets(cables)
	SSair.setup_template_machinery(atmos_machines)

	for (var/i in machines)
		var/obj/machinery/machine = i
		machine.power_change()

	for (var/i in turfs)
		var/turf/T = i
		T.post_change()
