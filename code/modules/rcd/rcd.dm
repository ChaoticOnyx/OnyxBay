/// Multiplier applied on construction & deconstruction time when building multiple structures
#define FREQUENT_USE_DEBUFF_MULTIPLIER 3

//RAPID CONSTRUCTION DEVICE

/obj/item/construction/rcd
	name = "rapid-construction-device (RCD)"
	desc = "Small, portable, and far, far heavier than it looks, this gun-shaped device has a port into which one may insert compressed matter cartridges."
	description_info = "On use, this device will toggle between various types of structures (or their removal). You can examine it to see its current mode. It must be loaded with compressed matter cartridges, which can be obtained from an autolathe. Click an adjacent tile to use the device."
	description_fluff = "Advents in material printing and synthesis technology have produced everyday miracles, such as the RCD, which in certain industries has single-handedly put entire construction crews out of a job."
	description_antag = "RCDs can be incredibly dangerous in the wrong hands. Use them to swiftly block off corridors, or instantly breach the ship wherever you want."


	icon = 'icons/obj/items.dmi'
	icon_state = "rcd-e"

	max_matter = 160

	/// main category of currently selected design[Structures, Airlocks, Airlock Access]
	var/root_category
	/// category of currently selected design
	var/design_category
	/// name of currently selected design
	var/design_title
	/// type of structure being built, used to decide what variables are used to build what structure
	var/mode
	/// temporary holder of mode, used to restore mode original value after rcd deconstruction act
	var/construction_mode
	/// The path of the structure the rcd is currently creating
	var/atom/movable/rcd_design_path

	/// Owner of this rcd. It can either be a construction console, player, or mech.
	var/atom/owner
	/// used by arcd, can this rcd work from a range
	var/ranged = FALSE
	/// delay multiplier for all construction types
	var/delay_mod = 1
	/// variable for R walls to deconstruct them
	var/canRturf = FALSE
	/// integrated airlock electronics for setting access to a newly built airlocks
	var/obj/item/airlock_electronics/airlock_electronics

	///number of active rcd effects in use e.g. when building multiple walls at once this value increases
	var/current_active_effects = 0

	var/static/list/designs_icons = list()

	matter = list(MATERIAL_STEEL = 20000, MATERIAL_GLASS = 10000)

/obj/effect/rcd_hologram
	name = "hologram"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/rcd_hologram/Initialize(mapload)
	. = ..()
	QDEL_IN(src, RCD_HOLOGRAM_FADE_TIME)

/obj/item/construction/rcd/Initialize(mapload)
	. = ..()
	airlock_electronics = new(src)
	airlock_electronics.name = "Access Control"

	root_category =  GLOB.rcd_designs[1]
	design_category = GLOB.rcd_designs[root_category][1]
	var/list/design = GLOB.rcd_designs[root_category][design_category][1]

	rcd_design_path = design["[RCD_DESIGN_PATH]"]
	design_title = initial(rcd_design_path.type)
	mode = design["[RCD_DESIGN_MODE]"]
	construction_mode = mode

/obj/item/construction/rcd/Destroy()
	QDEL_NULL(airlock_electronics)
	. = ..()

/**
 * checks if we can build the structure
 * Arguments
 *
 * * [atom][target]- the target we are trying to build on/deconstruct e.g. turf, wall etc
 * * rcd_results- list of params specifically the build type of our structure
 * * [mob][user]- the user
 */
/obj/item/construction/rcd/proc/can_place(atom/target, list/rcd_results, mob/user)
	var/rcd_mode = rcd_results["[RCD_DESIGN_MODE]"]
	var/atom/movable/rcd_structure = rcd_results["[RCD_DESIGN_PATH]"]
	/**
	 *For anything that does not go an a wall we have to make sure that turf is clear for us to put the structure on it
	 *If we are just trying to destory something then this check is not nessassary
	 *RCD_WALLFRAME is also returned as the rcd_mode when upgrading apc, airalarm, firealarm using simple circuits upgrade
	 */
	if(rcd_mode != RCD_WALLFRAME && rcd_mode != RCD_DECONSTRUCT)
		var/turf/target_turf = get_turf(target)
		//if we are trying to build a window we check for specific edge cases
		if(rcd_mode == RCD_WINDOWSMALL)
			var/obj/structure/window/window_type = rcd_structure
			var/is_full_tile = initial(window_type.is_full_window)

			var/list/structures_to_ignore
			if(istype(target, /obj/structure/grille))
				if(is_full_tile) //if we are trying to build full-tile windows we ignore the grille
					structures_to_ignore = list(/obj/structure/grille)
				else //when building directional windows we ignore the grill and other directional windows
					structures_to_ignore = list(/obj/structure/grille, /obj/structure/window)
			else //for directional windows we ignore other directional windows as they can be in diffrent directions on the turf.
				structures_to_ignore = list(/obj/structure/window)

			//check if we can build our window on the grill
			if(is_blocked_turf(target_turf, caller = null, exclude_mobs = FALSE, ignore_atoms = structures_to_ignore))
				playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
				show_splash_text(user, "something is blocking the turf", SPAN("warning", "There's something blocking the turf!"))
				return FALSE

		/**
		 * if we are trying to create plating on turf which is not a proper floor then dont check for objects on top of the turf just allow that turf to be converted into plating. e.g. create plating beneath a player or underneath a machine frame/any dense object
		 * if we are trying to finish a wall girder then let it finish then make sure no one/nothing is stuck in the girder
		 */
		else if(rcd_mode == RCD_TURF && rcd_structure == /turf/simulated/floor/plating  && (!istype(target_turf, /turf/simulated/floor) || istype(target, /obj/structure/girder)))
			//if a player builds a wallgirder on top of himself manually with iron sheets he can't finish the wall if he is still on the girder. Exclude the girder itself when checking for other dense objects on the turf
			if(istype(target, /obj/structure/girder) && is_blocked_turf(target_turf))
				playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
				show_splash_text(user, "something is on the girder!", SPAN("warning", "There's something blocking the girder!"))
				return FALSE

		//check if turf is blocked in for dense structures
		else
			//structures which are small enough to fit on turfs containing directional windows.
			var/static/list/small_structures = list(
				/obj/structure/table,
				/obj/structure/bed,
				/obj/item/stool,
				/obj/structure/window/basic,
				/obj/structure/window/reinforced,
			)

			//edge cases for what we can/can't ignore
			var/list/ignored_types
			if(rcd_mode == RCD_WINDOWSMALL || is_path_in_list(rcd_structure, small_structures))
				ignored_types = list(/obj/structure/window)
				//if we are trying to create grills/windoors we can go ahead and further ignore other windoors on the turf
				if(rcd_mode == RCD_WINDOWSMALL || (rcd_mode == RCD_AIRLOCK && ispath(rcd_structure, /obj/machinery/door/window)))
					//only ignore mobs if we are trying to create windoors and not grills. We dont want to drop a grill on top of somebody
					ignored_types += /obj/machinery/door/window
				//if we are trying to create full airlock doors then we do the regular checks and make sure we have the full space for them. i.e. dont ignore anything dense on the turf
				else if(rcd_mode == RCD_AIRLOCK)
					ignored_types = list()

			//check if the structure can fit on this turf
			if(is_blocked_turf(target_turf))
				playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
				show_splash_text(user, "something is on the tile!", SPAN("warning", "There's something blocking the tile!"))
				return FALSE

	return TRUE

/**
 * actual proc to create the structure
 *
 * Arguments
 * * [atom][target]- the target we are trying to build on/deconstruct e.g. turf, wall etc
 * * [mob][user]- the user building this structure
 */
/obj/item/construction/rcd/proc/rcd_create(atom/target, mob/user)
	//does this atom allow for rcd actions?
	var/list/rcd_results = target.rcd_vals(user, src)
	if(!rcd_results)
		return FALSE

	rcd_results["[RCD_DESIGN_MODE]"] = mode
	rcd_results["[RCD_DESIGN_PATH]"] = rcd_design_path

	var/delay = rcd_results["delay"] * delay_mod
	if (
		!(upgrade & RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN) \
			&& !rcd_results[RCD_RESULT_BYPASS_FREQUENT_USE_COOLDOWN] \
			&& current_active_effects > 0
	)
		delay *= FREQUENT_USE_DEBUFF_MULTIPLIER

	current_active_effects += 1
	_rcd_create_effect(target, user, delay, rcd_results)
	current_active_effects -= 1

/**
 * Internal proc which creates the rcd effects & creates the structure
 *
 * Arguments
 * * [atom][target]- the target we are trying to build on/deconstruct e.g. turf, wall etc
 * * [mob][user]- the user trying to build the structure
 * * delay- the delay with the disk upgrades applied
 * * rcd_results- list of params which contains the cost & build mode to create the structure
 */
/obj/item/construction/rcd/proc/_rcd_create_effect(atom/target, mob/user, delay, list/rcd_results)
	var/obj/effect/constructing_effect/rcd_effect = new(get_turf(target), delay, rcd_results["[RCD_DESIGN_MODE]"], upgrade)

	//resource & structure placement sanity checks before & after delay along with beam effects
	if(!checkResource(rcd_results["cost"], user) || !can_place(target, rcd_results, user))
		qdel(rcd_effect)
		return FALSE

	var/beam
	if(ranged)
		var/atom/beam_source = owner ? owner : user
		beam = beam_source.Beam(target, icon_state = "rped_upgrade", time = delay)
	if(delay && !do_after(user, delay, target = target)) // no need for do_after with no delay
		qdel(rcd_effect)
		if(!isnull(beam))
			qdel(beam)
		return FALSE

	if(QDELETED(rcd_effect))
		return FALSE

	if(!checkResource(rcd_results["cost"], user) || !can_place(target, rcd_results, user))
		qdel(rcd_effect)
		return FALSE

	if(!useResource(rcd_results["cost"], user))
		qdel(rcd_effect)
		return FALSE

	activate()
	if(!target.rcd_act(user, src, rcd_results))
		qdel(rcd_effect)
		return FALSE

	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	rcd_effect.end_animation()
	return TRUE

/obj/item/construction/rcd/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RapidConstructionDevice", name)
		ui.open()

/obj/item/construction/rcd/tgui_static_data(mob/user)
	var/list/data = ..()

	data["root_categories"] = list()
	for(var/category in GLOB.rcd_designs)
		data["root_categories"] += category
	data["selected_root"] = root_category

	data["categories"] = list()
	for(var/sub_category as anything in GLOB.rcd_designs[root_category])
		var/list/target_category =  GLOB.rcd_designs[root_category][sub_category]
		if(!length(target_category))
			continue

		//skip category if upgrades were not installed for these
		if(sub_category == "Machines" && !(upgrade & RCD_UPGRADE_FRAMES))
			continue
		if(sub_category == "Furniture" && !(upgrade & RCD_UPGRADE_FURNISHING))
			continue

		var/list/designs = list() //initialize all designs under this category
		for(var/list/design in target_category)
			var/atom/design_path = design[RCD_DESIGN_PATH]
			var/icon/design_icon

			var/design_name = initial(design_path.name)
			var/design_type = initial(design_path.type)

			if(isnull(designs_icons[design_path]))
				designs_icons[design_path] = icon(icon = initial(design_path.icon), icon_state = initial(design_path.icon_state), dir = SOUTH, frame = 1)

			design_icon = designs_icons[design_path]

			designs += list(list("title" = design_name, "type" = design_type, "icon" = icon2base64html(design_icon)))
		data["categories"] += list(list("cat_name" = sub_category, "designs" = designs))

	return data

/obj/item/construction/rcd/tgui_data(mob/user)
	var/list/data = ..()

	//main categories
	data["selected_category"] = design_category
	data["selected_design"] = design_title

	//merge airlock_electronics ui data with this
	var/list/airlock_data = airlock_electronics.tgui_data(user)
	for(var/key in airlock_data)
		data[key] = airlock_data[key]

	return data

/obj/item/construction/rcd/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	switch(action)
		if("root_category")
			var/new_root = params["root_category"]
			if(GLOB.rcd_designs[new_root] != null) //is a valid category
				root_category = new_root
				update_static_data(usr)

		if("design")
			//read and validate params from UI
			var/category_name = params["category"]
			var/index = params["index"]
			var/list/root = GLOB.rcd_designs[root_category]
			if(root == null) //not a valid root
				return TRUE

			var/list/category = root[category_name]
			if(category == null) //not a valid category
				return TRUE

			/**
			 * The advantage of organizing designs into categories is that
			 * You can ignore an complete category if the design disk upgrade for that category isn't installed.
			 */
			//You can't select designs from the Machines category if you dont have the frames upgrade installed.
			if(category == "Machines" && !(upgrade & RCD_UPGRADE_FRAMES))
				return TRUE
			//You can't select designs from the Furniture category if you dont have the furnishing upgrade installed.
			if(category == "Furniture" && !(upgrade & RCD_UPGRADE_FURNISHING))
				return TRUE

			//use UI params to set variables
			var/list/design = category[index]
			if(design == null) //not a valid design
				return TRUE
			design_category = category_name
			mode = design["[RCD_DESIGN_MODE]"]
			construction_mode = mode
			rcd_design_path = design["[RCD_DESIGN_PATH]"]
			design_title = initial(rcd_design_path.type)

		else
			airlock_electronics.handle_act(action, params)

	return TRUE

/obj/item/construction/rcd/attack_self(mob/user)
	. = ..()
	tgui_interact(user)

/obj/item/construction/rcd/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	//proximity check for normal rcd & range check for arcd
	if((!proximity_flag && !ranged) || (ranged && !range_check(target, user)))
		return FALSE

	//HARM == deconstruction, HELP == construction
	if(user.a_intent == I_HURT)
		mode = RCD_DECONSTRUCT
	else
		mode = construction_mode

	rcd_create(target, user)

	return .

/obj/item/construction/rcd/proc/detonate_pulse()
	audible_message("<span class='danger'><b>[src] begins to vibrate and \
		buzz loudly!</b></span>","<span class='danger'><b>[src] begins \
		vibrating violently!</b></span>")
	set_next_think(world.time + 5 SECONDS)

/obj/item/construction/rcd/think()
	explosion(src, light_impact_range = 3, flash_range = 1)
	qdel(src)

/obj/item/construction/rcd/loaded
	local_matter = 160

/obj/item/construction/rcd/loaded/upgraded
	upgrade = RCD_ALL_UPGRADES

#undef FREQUENT_USE_DEBUFF_MULTIPLIER
