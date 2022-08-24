/*
	MATERIAL DATUMS
	This data is used by various parts of the game for basic physical properties and behaviors
	of the metals/materials used for constructing many objects. Each var is commented and should be pretty
	self-explanatory but the various object types may have their own documentation. ~Z

	PATHS THAT USE DATUMS
		turf/simulated/wall
		obj/item/material
		obj/structure/barricade
		obj/item/stack/material
		obj/structure/table

	VALID ICONS
		WALLS
			stone
			metal
			solid
			cult
		DOORS
			stone
			metal
			resin
			wood
*/

// Assoc list containing all material datums indexed by name.
var/list/name_to_material

//Returns the material the object is made of, if applicable.
//Will we ever need to return more than one value here? Or should we just return the "dominant" material.
/obj/proc/get_material()
	return null

//mostly for convenience
/obj/proc/get_material_name()
	var/material/material = get_material()
	if(material)
		return material.name

// Builds the datum list above.
/proc/populate_material_list(force_remake=0)
	if(name_to_material && !force_remake) return // Already set up!
	name_to_material = list()
	for(var/type in typesof(/material) - /material)
		var/material/new_mineral = new type
		if(!new_mineral.name)
			continue
		name_to_material[lowertext(new_mineral.name)] = new_mineral
	return 1

// Safety proc to make sure the material list exists before trying to grab from it.
/proc/get_material_by_name(name)
	if(!name_to_material)
		populate_material_list()
	. = name_to_material[name]
	if(!.)
		log_error("Unable to acquire material by name '[name]'")

/proc/material_display_name(name)
	var/material/material = get_material_by_name(name)
	if(material)
		return material.display_name
	return null

// Material definition and procs follow.
/material
	var/name	                          // Unique name for use in indexing the list.
	var/display_name                      // Prettier name for display.
	var/adjective_name
	var/use_name
	var/flags = 0                         // Various status modifiers.
	var/sheet_singular_name = "sheet"
	var/sheet_plural_name = "sheets"
	var/is_fusion_fuel

	// Shards/tables/structures
	var/shard_type = SHARD_SHRAPNEL       // Path of debris object.
	var/shard_icon                        // Related to above.
	var/shard_can_repair = 1              // Can shards be turned into sheets with a welder?
	var/list/recipes                      // Holder for all recipes usable with a sheet of this material.
	var/destruction_desc = "breaks apart" // Fancy string for barricades/tables/objects exploding.

	// Icons
	var/icon_colour                                      // Colour applied to products of this material.
	var/icon_base = "metal"                              // Wall and table base icon tag. See header.
	var/door_icon_base = "metal"                         // Door base icon tag. See header.
	var/icon_reinf = "reinf_metal"                       // Overlay used
	var/table_icon_base = "metal"
	var/table_reinf = "reinf_metal"
	var/window_icon_base = "window"
	var/list/stack_origin_tech = list(TECH_MATERIAL = 1) // Research level for stacks.

	// Attributes
	var/cut_delay = 0            // Delay in ticks when cutting through this wall.
	var/ignition_point           // K, point at which the material catches on fire.
	var/melting_point = 1800     // K, walls will take damage if they're next to a fire hotter than this
	var/brute_armor = 2	 		 // Brute damage to a wall is divided by this value if the wall is reinforced by this material.
	var/burn_armor				 // Same as above, but for Burn damage type. If blank brute_armor's value is used.
	var/integrity = 150          // General-use HP value for products.
	var/opacity = 1              // Is the material transparent? 0.5< makes transparent walls/doors.
	var/explosion_resistance = 5 // Only used by walls currently.
	var/conductive = 1           // Objects with this var add CONDUCTS to flags on spawn.
	var/luminescence
	var/list/composite_material  // If set, object matter var will be a list containing these values.
	var/reagent_path = null      // If set, the material is linked with the given chemical reagent.

	var/resilience = 1			 // The higher this value is, the higher is the chance that bullets will ricochet from wall's surface. Don't set negative values.
	var/reflectance = -50		 // Defines whether material in walls raises (positive values) or decreases (negative values) reflection chance. -50 <= reflectance <= 50 - recommended values.

	// Placeholder vars for the time being, todo properly integrate windows/light tiles/rods.
	var/created_window
	var/rod_product
	var/wire_product
	var/list/window_options = list()

	// Damage values.
	var/hardness = 60            // Prob of wall destruction by hulk, used for edge damage in weapons.
	var/weight = 20              // Determines blunt damage/throwforce for weapons.

	var/craft_tool = 2			// Tools required for crafting. 1 for sharp/edge items, 2 for welders.

	// Noise when someone is faceplanted onto a table made of this material.
	var/tableslam_noise = 'sound/weapons/tablehit1.ogg'
	// Noise made when a simple door made of this material opens or closes.
	var/dooropen_noise = 'sound/effects/stonedoor_openclose.ogg'
	// Noise made when you hit structure made of this material.
	var/hitsound = 'sound/effects/fighting/Genhit.ogg'
	// Path to resulting stacktype. Todo remove need for this.
	var/stack_type
	// Wallrot crumble message.
	var/rotting_touch_message = "crumbles under your touch"

// Placeholders for light tiles and rglass.
/material/proc/build_rod_product(mob/user, obj/item/stack/used_stack, obj/item/stack/target_stack)
	if(!rod_product)
		to_chat(user, "<span class='warning'>You cannot make anything out of \the [target_stack]</span>")
		return
	if(used_stack.get_amount() < 1 || target_stack.get_amount() < 1)
		to_chat(user, "<span class='warning'>You need one rod and one sheet of [display_name] to make anything useful.</span>")
		return
	used_stack.use(1)
	target_stack.use(1)
	var/obj/item/stack/S = new rod_product(get_turf(user))
	S.add_fingerprint(user)
	S.add_to_stacks(user)

/material/proc/build_wired_product(mob/user, obj/item/stack/used_stack, obj/item/stack/target_stack)
	if(!wire_product)
		to_chat(user, "<span class='warning'>You cannot make anything out of \the [target_stack]</span>")
		return
	if(used_stack.get_amount() < 5 || target_stack.get_amount() < 1)
		to_chat(user, "<span class='warning'>You need five wires and one sheet of [display_name] to make anything useful.</span>")
		return

	used_stack.use(5)
	target_stack.use(1)
	to_chat(user, "<span class='notice'>You attach wire to the [name].</span>")
	var/obj/item/product = new wire_product(get_turf(user))
	if(!(user.l_hand && user.r_hand))
		user.put_in_hands(product)

// Make sure we have a display name and shard icon even if they aren't explicitly set.
/material/New()
	..()
	if(!display_name)
		display_name = name
	if(!use_name)
		use_name = display_name
	if(!adjective_name)
		adjective_name = display_name
	if(!shard_icon)
		shard_icon = shard_type
	if(!burn_armor)
		burn_armor = brute_armor

// This is a placeholder for proper integration of windows/windoors into the system.
/material/proc/build_windows(mob/living/user, obj/item/stack/used_stack)
	return 0

// Weapons handle applying a divisor for this value locally.
/material/proc/get_blunt_damage()
	return weight //todo

// Return the matter comprising this material.
/material/proc/get_matter()
	var/list/temp_matter = list()
	if(islist(composite_material))
		for(var/material_string in composite_material)
			temp_matter[material_string] = composite_material[material_string]
	else
		temp_matter[name] = SHEET_MATERIAL_AMOUNT
	return temp_matter

// As above.
/material/proc/get_edge_damage()
	return hardness //todo

// Snowflakey, only checked for alien doors at the moment.
/material/proc/can_open_material_door(mob/living/user)
	return 1

// Currently used for weapons and objects made of uranium to irradiate things.
/material/proc/products_need_process()
	return FALSE

// Used by walls when qdel()ing to avoid neighbor merging.
/material/placeholder
	name = "placeholder"

// Places a girder object when a wall is dismantled, also applies reinforced material.
/material/proc/place_dismantled_girder(turf/target, material/reinf_material)
	var/obj/structure/girder/G = new(target)
	if(reinf_material)
		G.reinf_material = reinf_material
		G.reinforce_girder()

// General wall debris product placement.
// Not particularly necessary aside from snowflakey cult girders.
/material/proc/place_dismantled_product(turf/target,is_devastated)
	for(var/x=1;x<(is_devastated?2:3);x++)
		place_sheet(target)

// Debris product. Used ALL THE TIME.
/material/proc/place_sheet(turf/target)
	if(stack_type)
		return new stack_type(target)

// As above.
/material/proc/place_shard(turf/target)
	if(shard_type)
		return new /obj/item/material/shard(target, src.name)

// Used by walls and weapons to determine if they break or not.
/material/proc/is_brittle()
	return !!(flags & MATERIAL_BRITTLE)

/material/proc/combustion_effect(turf/T, temperature)
	return

// Datum definitions follow.
/material/uranium
	name = MATERIAL_URANIUM
	stack_type = /obj/item/stack/material/uranium
	icon_base = "stone"
	door_icon_base = "stone"
	table_icon_base = "stone"
	icon_reinf = "reinf_stone"
	icon_colour = "#557755"
	weight = 40
	resilience = 16
	reflectance = 15
	stack_origin_tech = list(TECH_MATERIAL = 5)
	reagent_path = /datum/reagent/uranium

/material/diamond
	name = MATERIAL_DIAMOND
	stack_type = /obj/item/stack/material/diamond
	flags = MATERIAL_UNMELTABLE
	integrity = 250
	cut_delay = 60
	icon_colour = "#cefff6"
	opacity = 0.4
	shard_type = SHARD_SHARD
	tableslam_noise = 'sound/effects/breaking/window/break1.ogg'
	hardness = 100
	weight = 10
	brute_armor = 10
	burn_armor = 50		// Diamond walls are immune to fire, therefore it makes sense for them to be almost undamageable by burn damage type.
	resilience = 25
	reflectance = 50
	stack_origin_tech = list(TECH_MATERIAL = 6)
	conductive = 0

/material/gold
	name = MATERIAL_GOLD
	stack_type = /obj/item/stack/material/gold
	icon_colour = "#edb52f"
	weight = 40
	hardness = 25
	integrity = 100
	resilience = 4
	reflectance = 20
	stack_origin_tech = list(TECH_MATERIAL = 4)
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	reagent_path = /datum/reagent/gold

/material/gold/bronze //placeholder for ashtrays
	name = MATERIAL_BRONZE
	icon_colour = "#dd8639"
	hardness = 55
	weight = 30
	reagent_path = null // Why in the world is this inherited from gold, sigh

/material/silver
	name = MATERIAL_SILVER
	stack_type = /obj/item/stack/material/silver
	icon_colour = "#d1e6e3"
	weight = 22
	hardness = 50
	resilience = 9
	reflectance = 25
	stack_origin_tech = list(TECH_MATERIAL = 3)
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	reagent_path = /datum/reagent/silver

/material/plasma
	name = MATERIAL_PLASMA
	stack_type = /obj/item/stack/material/plasma
	ignition_point = PLASMA_MINIMUM_BURN_TEMPERATURE
	icon_base = "stone"
	table_icon_base = "stone"
	icon_colour = "#a109e2"
	shard_type = SHARD_SHARD
	hardness = 30
	resilience = 4
	reflectance = 25
	stack_origin_tech = list(TECH_MATERIAL = 2, TECH_PLASMA = 2)
	door_icon_base = "stone"
	sheet_singular_name = "crystal"
	sheet_plural_name = "crystals"
	is_fusion_fuel = 1
	reagent_path = /datum/reagent/toxin/plasma

/material/plasma/supermatter
	name = MATERIAL_SUPERMATTER
	icon_colour = "#ffff00"
	stack_origin_tech = list(TECH_BLUESPACE = 2, TECH_MATERIAL = 6, TECH_PLASMA = 4)
	stack_type = null
	luminescence = 3
	reagent_path = null

//Controls plasma and plasma based objects reaction to being in a turf over 200c -- Plasma's flashpoint.
/material/plasma/combustion_effect(turf/T, temperature, effect_multiplier)
	if(isnull(ignition_point))
		return 0
	if(temperature < ignition_point)
		return 0
	var/totalPlasma = 0
	for(var/turf/simulated/floor/target_tile in range(2,T))
		var/plasmaToDeduce = (temperature/30) * effect_multiplier
		totalPlasma += plasmaToDeduce
		target_tile.assume_gas("plasma", plasmaToDeduce, 200 CELSIUS)
		spawn (0)
			target_tile.hotspot_expose(temperature, 400)
	return round(totalPlasma/100)


/material/stone
	name = MATERIAL_SANDSTONE
	stack_type = /obj/item/stack/material/sandstone
	icon_base = "stone"
	table_icon_base = "stone"
	icon_reinf = "reinf_stone"
	icon_colour = "#d9c179"
	shard_type = SHARD_STONE_PIECE
	weight = 22
	hardness = 55
	brute_armor = 3
	door_icon_base = "stone"
	sheet_singular_name = "brick"
	sheet_plural_name = "bricks"
	conductive = 0
	resilience = 9
	craft_tool = 1
	reagent_path = /datum/reagent/silicon

/material/stone/marble
	name = MATERIAL_MARBLE
	icon_colour = "#aaaaaa"
	weight = 26
	hardness = 60
	brute_armor = 3
	integrity = 201 //hack to stop kitchen benches being flippable, todo: refactor into weight system
	resilience = 9
	reflectance = 5
	stack_type = /obj/item/stack/material/marble
	craft_tool = 1
	reagent_path = /datum/reagent/carbon

/material/steel
	name = MATERIAL_STEEL
	stack_type = /obj/item/stack/material/steel
	hardness = 60
	integrity = 200
	brute_armor = 5
	icon_base = "solid"
	icon_reinf = "reinf_over"
	icon_colour = "#666666"
	shard_type = SHARD_SCRAP
	hitsound = 'sound/effects/fighting/Genhit.ogg'
	resilience = 36
	reflectance = 13

/material/diona
	name = "biomass"
	icon_colour = null
	stack_type = null
	integrity = 600
	icon_base = "diona"
	icon_reinf = "noreinf"
	hitsound = 'sound/effects/attackblob.ogg'
	conductive = 0
	craft_tool = 1

/material/diona/place_dismantled_product()
	return

/material/diona/place_dismantled_girder(turf/target)
	spawn_diona_nymph(target)

/material/steel/holographic
	name = "holo" + MATERIAL_STEEL
	display_name = MATERIAL_STEEL
	stack_type = null
	shard_type = SHARD_NONE
	conductive = 0

/material/plasteel
	name = MATERIAL_PLASTEEL
	stack_type = /obj/item/stack/material/plasteel
	integrity = 400
	melting_point = 6000
	icon_base = "solid"
	icon_reinf = "reinf_over"
	icon_colour = "#777777"
	shard_type = SHARD_SCRAP
	explosion_resistance = 25
	brute_armor = 6
	burn_armor = 10
	hardness = 80
	weight = 23
	resilience = 49
	reflectance = 20
	stack_origin_tech = list(TECH_MATERIAL = 2)
	composite_material = list(MATERIAL_STEEL = 3750, MATERIAL_PLATINUM = 3750) //todo

/material/plasteel/titanium
	name = MATERIAL_TITANIUM
	brute_armor = 10
	burn_armor = 8
	integrity = 200
	melting_point = 3000
	stack_type = null
	resilience = 49
	reflectance = 15
	icon_base = "metal"
	door_icon_base = "metal"
	icon_colour = "#d1e6e3"
	icon_reinf = "reinf_metal"

/material/plasteel/ocp
	name = MATERIAL_OSMIUM_CARBIDE_PLASTEEL
	stack_type = /obj/item/stack/material/ocp
	integrity = 300
	melting_point = 12000
	icon_base = "solid"
	icon_reinf = "reinf_over"
	icon_colour = "#9bc6f2"
	brute_armor = 4
	burn_armor = 20
	weight = 27
	resilience = 49
	reflectance = 25
	stack_origin_tech = list(TECH_MATERIAL = 3)
	composite_material = list(MATERIAL_PLASTEEL = 7500, MATERIAL_OSMIUM = 3750)


/material/glass
	name = MATERIAL_GLASS
	stack_type = /obj/item/stack/material/glass
	flags = MATERIAL_BRITTLE
	icon_colour = "#b5edff"
	opacity = 0.3
	integrity = 50
	shard_type = SHARD_SHARD
	tableslam_noise = 'sound/effects/breaking/window/break1.ogg'
	hardness = 50
	melting_point = 100 CELSIUS
	weight = 14
	brute_armor = 1
	burn_armor = 2
	resilience = 0
	reflectance = 30
	door_icon_base = "stone"
	table_icon_base = "solid"
	window_icon_base = "window"
	destruction_desc = "shatters"
	window_options = list("Panel" = 1)
	created_window = /obj/structure/window/basic
	rod_product = /obj/item/stack/material/glass/reinforced
	hitsound = 'sound/effects/breaking/window/break1.ogg'
	conductive = 0
	reagent_path = /datum/reagent/glass

/material/glass/build_windows(mob/living/user, obj/item/stack/used_stack)

	if(!user || !used_stack || !created_window || !window_options.len)
		return 0

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>This task is too complex for your clumsy hands.</span>")
		return 1

	var/turf/T = user.loc
	if(!istype(T))
		to_chat(user, "<span class='warning'>You must be standing on open flooring to build a window.</span>")
		return 1

	var/choice = ""
	if(window_options.len == 1)
		choice = window_options[1]
	else
		var/title = "Sheet-[used_stack.name] ([used_stack.get_amount()] sheet\s left)"
		choice = input(title, "What would you like to construct?") as null|anything in window_options

	if(!choice || !used_stack || !user || used_stack.loc != user || user.stat || user.loc != T)
		return 1

	// Get data for building windows here.
	var/list/possible_directions = GLOB.cardinal.Copy()
	var/window_count = 0
	for(var/obj/structure/window_frame/WF in user.loc)
		if(WF.outer_pane || WF.inner_pane)
			to_chat(user, SPAN("warning", "There is no room in this location."))
			return

	for (var/obj/structure/window/check_window in user.loc)
		window_count++
		possible_directions  -= check_window.dir

	// Get the closest available dir to the user's current facing.
	var/build_dir = SOUTHWEST //Default to southwest for fulltile windows.
	var/failed_to_build

	if(window_count >= 4)
		failed_to_build = 1
	else
		if(choice in list("Panel","Windoor"))
			if(possible_directions.len)
				for(var/direction in list(user.dir, turn(user.dir,90), turn(user.dir,180), turn(user.dir,270) ))
					if(direction in possible_directions)
						build_dir = direction
						break
			else
				failed_to_build = 1
			if(!failed_to_build && choice == "Windoor")
				if(!is_reinforced())
					to_chat(user, "<span class='warning'>This material is not reinforced enough to use for a door.</span>")
					return
				if((locate(/obj/structure/windoor_assembly) in T.contents) || (locate(/obj/machinery/door/window) in T.contents))
					failed_to_build = 1
	if(failed_to_build)
		to_chat(user, "<span class='warning'>There is no room in this location.</span>")
		return 1

	var/build_path = /obj/structure/windoor_assembly
	var/sheets_needed = window_options[choice]
	if(choice == "Windoor")
		build_dir = user.dir
	else
		build_path = created_window

	if(used_stack.get_amount() < sheets_needed)
		to_chat(user, "<span class='warning'>You need at least [sheets_needed] sheets to build this.</span>")
		return 1

	// Build the structure and update sheet count etc.
	if(do_after(user, 5, used_stack) && used_stack.use(sheets_needed))
		new build_path(T, build_dir, 1)
		return 1
	return 0

/material/glass/proc/is_reinforced()
	return (integrity > 75) //todo

/material/glass/is_brittle()
	return ..() && !is_reinforced()

/material/glass/reinforced
	name = MATERIAL_REINFORCED_GLASS
	display_name = "reinforced glass"
	stack_type = /obj/item/stack/material/glass/reinforced
	flags = MATERIAL_BRITTLE
	icon_colour = "#97d3e5"
	window_icon_base = "rwindow"
	opacity = 0.3
	integrity = 100
	melting_point = 750 CELSIUS
	shard_type = SHARD_SHARD
	tableslam_noise = 'sound/effects/breaking/window/break1.ogg'
	weight = 17
	brute_armor = 2
	burn_armor = 3
	resilience = 9
	reflectance = 25
	stack_origin_tech = list(TECH_MATERIAL = 2)
	composite_material = list(MATERIAL_STEEL = 1875, MATERIAL_GLASS = 3750)
	window_options = list("Panel" = 1, "Windoor" = 5)
	created_window = /obj/structure/window/reinforced
	wire_product = null
	rod_product = null

/material/glass/plass
	name = MATERIAL_PLASS
	display_name = "plass"
	stack_type = /obj/item/stack/material/glass/plass
	flags = MATERIAL_BRITTLE
	integrity = 70
	brute_armor = 2
	burn_armor = 5
	melting_point = 2000 CELSIUS
	icon_colour = "#d67ac8"
	window_icon_base = "plasmawindow"
	resilience = 0
	reflectance = 40
	stack_origin_tech = list(TECH_MATERIAL = 4)
	created_window = /obj/structure/window/plasmabasic
	wire_product = null
	rod_product = /obj/item/stack/material/glass/rplass
	reagent_path = null

/material/glass/plass/reinforced
	name = MATERIAL_REINFORCED_PLASS
	display_name = "reinforced plass"
	brute_armor = 3
	burn_armor = 10
	melting_point = 4000 CELSIUS
	window_icon_base = "plasmarwindow"
	stack_type = /obj/item/stack/material/glass/rplass
	resilience = 36
	reflectance = 35
	stack_origin_tech = list(TECH_MATERIAL = 5)
	composite_material = list() //todo
	created_window = /obj/structure/window/plasmareinforced
	// I think that duplicating lines wasn't the best idea of Bay12 coders
	//stack_origin_tech = list(TECH_MATERIAL = 2)
	//composite_material = list() //todo
	rod_product = null
	integrity = 100

/material/glass/black
	name = MATERIAL_BLACK_GLASS
	display_name = "tinted glass"
	stack_type = /obj/item/stack/material/glass/black
	icon_colour = "#111919"
	window_icon_base = "blackwindow"
	reflectance = 30
	stack_origin_tech = list(TECH_MATERIAL = 2)
	rod_product = /obj/item/stack/material/glass/rblack
	window_options = list()
	opacity = 1.0
	melting_point = 150 CELSIUS

/material/glass/black/reinforced
	name = MATERIAL_REINFORCED_BLACK_GLASS
	display_name = "reinforced tinted glass"
	stack_type = /obj/item/stack/material/glass/rblack
	icon_colour = "#060a0a"
	window_icon_base = "rblackwindow"
	integrity = 100
	melting_point = 850 CELSIUS
	shard_type = SHARD_SHARD
	tableslam_noise = 'sound/effects/breaking/window/break1.ogg'
	weight = 17
	brute_armor = 2
	burn_armor = 3
	resilience = 9
	reflectance = 25
	stack_origin_tech = list(TECH_MATERIAL = 3)
	wire_product = null
	rod_product = null


/material/plastic
	name = MATERIAL_PLASTIC
	stack_type = /obj/item/stack/material/plastic
	flags = MATERIAL_BRITTLE
	icon_base = "solid"
	icon_reinf = "reinf_over"
	icon_colour = "#cccccc"
	hardness = 10
	weight = 5
	melting_point = 371 CELSIUS //assuming heat resistant plastic
	resilience = 0
	reflectance = -20
	stack_origin_tech = list(TECH_MATERIAL = 3)
	conductive = 0
	reagent_path = /datum/reagent/toxin/plasticide

/material/plastic/holographic
	name = "holoplastic"
	display_name = "plastic"
	stack_type = null
	shard_type = SHARD_NONE
	reagent_path = null

/material/osmium
	name = MATERIAL_OSMIUM
	stack_type = /obj/item/stack/material/osmium
	icon_colour = "#9999ff"
	stack_origin_tech = list(TECH_MATERIAL = 5)
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"

/material/tritium
	name = MATERIAL_TRITIUM
	stack_type = /obj/item/stack/material/tritium
	icon_colour = "#777777"
	stack_origin_tech = list(TECH_MATERIAL = 5)
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	is_fusion_fuel = 1

/material/deuterium
	name = MATERIAL_DEUTERIUM
	stack_type = /obj/item/stack/material/deuterium
	icon_colour = "#999999"
	stack_origin_tech = list(TECH_MATERIAL = 3)
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	is_fusion_fuel = 1

/material/mhydrogen
	name = MATERIAL_HYDROGEN
	stack_type = /obj/item/stack/material/mhydrogen
	icon_colour = "#e6c5de"
	stack_origin_tech = list(TECH_MATERIAL = 6, TECH_POWER = 6, TECH_MAGNET = 5)
	is_fusion_fuel = 1
	reagent_path = /datum/reagent/hydrazine

/material/platinum
	name = MATERIAL_PLATINUM
	stack_type = /obj/item/stack/material/platinum
	icon_colour = "#bbd0e8"
	weight = 27
	resilience = 16
	reflectance = 20
	stack_origin_tech = list(TECH_MATERIAL = 2)
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"

/material/iron
	name = MATERIAL_IRON
	stack_type = /obj/item/stack/material/iron
	icon_colour = "#5c5454"
	weight = 22
	resilience = 25
	reflectance = 10
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	hitsound = 'sound/effects/fighting/smash.ogg'
	shard_type = SHARD_SCRAP
	reagent_path = /datum/reagent/iron

// Adminspawn only, do not let anyone get this.
/material/voxalloy
	name = MATERIAL_VOX
	display_name = "durable alloy"
	stack_type = null
	icon_colour = "#6c7364"
	integrity = 1200
	resilience = 49
	reflectance = 10
	melting_point = 6000       // Hull plating.
	explosion_resistance = 200 // Hull plating.
	hardness = 500
	weight = 500
	shard_type = SHARD_SCRAP

// Likewise.
/material/voxalloy/elevatorium
	name = MATERIAL_ELEVATORIUM
	display_name = "elevator panelling"
	icon_colour = "#666666"

/material/darkwood
	name = MATERIAL_DARKWOOD
	adjective_name = "darkwooden"
	stack_type = /obj/item/stack/material/wood
	icon_colour = "#892929"
	integrity = 50
	icon_base = "solid"
	icon_reinf = "reinfwood"
	table_icon_base = "solid"
	table_reinf = "reinfwood"
	explosion_resistance = 2
	shard_type = SHARD_SPLINTER
	shard_can_repair = 0 // you can't weld splinters back into planks
	hardness = 15
	brute_armor = 1
	weight = 18
	melting_point = 300 CELSIUS //okay, not melting in this case, but hot enough to destroy wood
	ignition_point = 288 CELSIUS
	stack_origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	dooropen_noise = 'sound/effects/doorcreaky.ogg'
	door_icon_base = "wood"
	destruction_desc = "splinters"
	sheet_singular_name = "plank"
	sheet_plural_name = "planks"
	hitsound = 'sound/effects/woodhit.ogg'
	conductive = 0
	craft_tool = 1
	reagent_path = /datum/reagent/woodpulp

/material/wood
	name = MATERIAL_WOOD
	adjective_name = "wooden"
	stack_type = /obj/item/stack/material/wood
	icon_colour = "#936041"
	integrity = 50
	icon_base = "solid"
	table_icon_base = "solid"
	explosion_resistance = 2
	shard_type = SHARD_SPLINTER
	shard_can_repair = 0 // you can't weld splinters back into planks
	hardness = 15
	brute_armor = 1
	weight = 18
	melting_point = 300 CELSIUS //okay, not melting in this case, but hot enough to destroy wood
	ignition_point = 288 CELSIUS
	stack_origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	dooropen_noise = 'sound/effects/doorcreaky.ogg'
	door_icon_base = "wood"
	destruction_desc = "splinters"
	sheet_singular_name = "plank"
	sheet_plural_name = "planks"
	hitsound = 'sound/effects/woodhit.ogg'
	conductive = 0
	craft_tool = 1
	reagent_path = /datum/reagent/woodpulp

/material/wood/holographic
	name = "holowood"
	display_name = "wood"
	stack_type = null
	shard_type = SHARD_NONE
	reagent_path = null

/material/cardboard
	name = MATERIAL_CARDBOARD
	stack_type = /obj/item/stack/material/cardboard
	flags = MATERIAL_BRITTLE
	integrity = 10
	icon_base = "solid"
	icon_reinf = "reinf_over"
	icon_colour = "#aaaaaa"
	hardness = 1
	brute_armor = 1
	weight = 1
	ignition_point = 232 CELSIUS //"the temperature at which book-paper catches fire, and burns." close enough
	melting_point = 232 CELSIUS //temperature at which cardboard walls would be destroyed
	stack_origin_tech = list(TECH_MATERIAL = 1)
	door_icon_base = "wood"
	destruction_desc = "crumples"
	conductive = 0
	craft_tool = 1
	reagent_path = /datum/reagent/woodpulp // Probably makes some sense

/material/cloth //todo
	name = MATERIAL_CLOTH
	stack_origin_tech = list(TECH_MATERIAL = 2)
	door_icon_base = "wood"
	ignition_point = 232 CELSIUS
	melting_point = 300 CELSIUS
	flags = MATERIAL_PADDING
	brute_armor = 1
	conductive = 0
	craft_tool = 1

/material/cult
	name = MATERIAL_CULT
	display_name = "disturbing stone"
	icon_base = "cult"
	icon_colour = "#402821"
	icon_reinf = "reinf_cult"
	shard_type = SHARD_STONE_PIECE
	resilience = 16
	sheet_singular_name = "brick"
	sheet_plural_name = "bricks"
	conductive = 0

/material/cult/place_dismantled_girder(turf/target)
	new /obj/structure/girder/cult(target)

/material/cult/reinf
	name = MATERIAL_REINFORCED_CULT
	display_name = "runic inscriptions"
	resilience = 25

/material/resin
	name = MATERIAL_RESIN
	icon_colour = "#443f59"
	dooropen_noise = 'sound/effects/attackblob.ogg'
	door_icon_base = "resin"
	melting_point = 300 CELSIUS
	sheet_singular_name = "blob"
	sheet_plural_name = "blobs"
	conductive = 0
	integrity = 20

/material/resin/can_open_material_door(mob/living/user)
	var/mob/living/carbon/M = user
	if(istype(M) && locate(/obj/item/organ/internal/xenos/hivenode) in M.internal_organs)
		return 1
	return 0

/material/aliumium
	name = "alien alloy"
	stack_type = null
	icon_base = "jaggy"
	door_icon_base = "metal"
	icon_reinf = "reinf_metal"
	hitsound = 'sound/effects/fighting/smash.ogg'
	sheet_singular_name = "chunk"
	sheet_plural_name = "chunks"

/material/aliumium/New()
	icon_base = pick("jaggy","curvy")
	icon_colour = rgb(rand(10,150),rand(10,150),rand(10,150))
	explosion_resistance = rand(25,40)
	brute_armor = rand(10,20)
	burn_armor = rand(10,20)
	hardness = rand(15,100)
	integrity = rand(200,400)
	melting_point = rand(400,10000)
	..()

/material/aliumium/place_dismantled_girder(turf/target, material/reinf_material)
	return

//TODO PLACEHOLDERS:
/material/leather
	name = MATERIAL_LEATHER
	icon_colour = "#5c4831"
	stack_origin_tech = list(TECH_MATERIAL = 2)
	flags = MATERIAL_PADDING
	ignition_point = 300 CELSIUS
	melting_point = 300 CELSIUS
	conductive = 0
	craft_tool = 1

/material/carpet
	name = MATERIAL_CARPET
	display_name = "comfy"
	use_name = "red upholstery"
	icon_colour = "#da020a"
	flags = MATERIAL_PADDING
	ignition_point = 232 CELSIUS
	melting_point = 300 CELSIUS
	sheet_singular_name = "tile"
	sheet_plural_name = "tiles"
	conductive = 0
	craft_tool = 1

/material/cotton
	name = MATERIAL_COTTON
	display_name ="cotton"
	icon_colour = "#ffffff"
	flags = MATERIAL_PADDING
	ignition_point = 232 CELSIUS
	melting_point = 300 CELSIUS
	conductive = 0
	craft_tool = 1

/material/cloth_teal
	name = "teal"
	display_name ="teal"
	use_name = "teal cloth"
	icon_colour = "#00eafa"
	flags = MATERIAL_PADDING
	ignition_point = 232 CELSIUS
	melting_point = 300 CELSIUS
	conductive = 0

/material/cloth_black
	name = "black"
	display_name = "black"
	use_name = "black cloth"
	icon_colour = "#505050"
	flags = MATERIAL_PADDING
	ignition_point = 232 CELSIUS
	melting_point = 300 CELSIUS
	conductive = 0

/material/cloth_green
	name = "green"
	display_name = "green"
	use_name = "green cloth"
	icon_colour = "#01c608"
	flags = MATERIAL_PADDING
	ignition_point = 232 CELSIUS
	melting_point = 300 CELSIUS
	conductive = 0

/material/cloth_puple
	name = "purple"
	display_name = "purple"
	use_name = "purple cloth"
	icon_colour = "#9c56c4"
	flags = MATERIAL_PADDING
	ignition_point = 232 CELSIUS
	melting_point = 300 CELSIUS
	conductive = 0

/material/cloth_blue
	name = "blue"
	display_name = "blue"
	use_name = "blue cloth"
	icon_colour = "#6b6fe3"
	flags = MATERIAL_PADDING
	ignition_point = 232 CELSIUS
	melting_point = 300 CELSIUS
	conductive = 0

/material/cloth_beige
	name = "beige"
	display_name = "beige"
	use_name = "beige cloth"
	icon_colour = "#e8e7c8"
	flags = MATERIAL_PADDING
	ignition_point = 232 CELSIUS
	melting_point = 300 CELSIUS
	conductive = 0

/material/cloth_lime
	name = "lime"
	display_name = "lime"
	use_name = "lime cloth"
	icon_colour = "#62e36c"
	flags = MATERIAL_PADDING
	ignition_point = 232 CELSIUS
	melting_point = 300 CELSIUS
	conductive = 0

/material/goat_hide
	name = "goat hide"
	use_name = "goat hide"
	stack_type = /obj/item/stack/material/animalhide/goat
	stack_origin_tech = list(TECH_MATERIAL = 2)
	icon_colour = "#e8e7c8"
	flags = MATERIAL_PADDING
	ignition_point = 300 CELSIUS
	melting_point = 300 CELSIUS
	conductive = 0
	craft_tool = 1

/material/hairless_hide
	name = "hairless hide"
	use_name = "hairless hide"
	stack_type = /obj/item/stack/material/hairlesshide
	stack_origin_tech = list(TECH_MATERIAL = 2)
	icon_colour = "#e8e7c8"
	flags = MATERIAL_PADDING
	ignition_point = 300 CELSIUS
	melting_point = 300 CELSIUS
	conductive = 0
	craft_tool = 1
