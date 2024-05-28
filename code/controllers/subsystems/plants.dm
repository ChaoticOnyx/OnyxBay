PROCESSING_SUBSYSTEM_DEF(plants)
	name = "Plants"
	priority = SS_PRIORITY_PLANTS
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING
	init_order = SS_INIT_PLANTS
	wait = 60

	process_proc = /obj/machinery/portable_atmospherics/hydroponics/Process

	var/list/product_descs = list()           // Stores generated fruit descs.
	var/list/seeds = list()                   // All seed data stored here.
	var/list/gene_tag_masks = list()          // Gene obfuscation for delicious trial and error goodness.
	var/list/plant_icon_cache = list()        // Stores images of growth, fruits and seeds.
	var/list/plant_sprites = list()           // List of all harvested product sprites.
	var/list/plant_product_sprites = list()   // List of all growth sprites plus number of growth stages.
	var/list/plant_gene_datums = list()       // Stored datum versions of the gene list.
	var/list/canonical_plants = list()        // Validation keys for canonical icons usage.
	var/list/canonical_plant_sprites = list() // The same as plant_sprites, but for the canonical ones.
	var/list/canonical_plant_icon_cache = list()

/datum/controller/subsystem/processing/plants/Initialize()
	// Build the icon lists.
	for(var/icostate in icon_states('icons/obj/hydroponics_growing.dmi'))
		var/split = findtext(icostate, "-")
		if(!split)
			// invalid icon_state
			continue

		var/ikey = copytext(icostate, (split + 1))
		if(ikey == "dead")
			// don't count dead icons
			continue
		ikey = text2num(ikey)
		var/base = copytext(icostate, 1, split)

		if(!(plant_sprites[base]) || (plant_sprites[base]<ikey))
			plant_sprites[base] = ikey

	for(var/icostate in icon_states('icons/obj/hydroponics_products.dmi'))
		var/split = findtext(icostate, "-")
		if(split)
			plant_product_sprites |= copytext(icostate, 1, split)

	for(var/icostate in icon_states('icons/obj/hydroponics_growing_canonical.dmi'))
		var/split = findtext(icostate, "-")
		if(!split)
			continue

		var/ikey = copytext(icostate, (split + 1))
		if(ikey == "dead" || ikey == "harvest")
			continue

		ikey = text2num(ikey)
		var/base = copytext(icostate, 1, split)

		if(!canonical_plant_sprites[base] || (canonical_plant_sprites[base] < ikey))
			canonical_plant_sprites[base] = ikey

	// Populate the global seed datum list.
	for(var/type in typesof(/datum/seed) - /datum/seed)
		var/datum/seed/S = new type
		if(S.canonical_icon)
			canonical_plants[S.canonical_icon] = S.get_canonical_key()
		S.update_growth_stages()
		seeds[S.name] = S
		S.roundstart = TRUE

	// Make sure any seed packets that were mapped in are updated
	// correctly (since the seed datums did not exist a tick ago).
	for(var/obj/item/seeds/S in world)
		S.update_seed()

	for (var/decl/plantgene/gene as anything in decls_repository.get_decls_of_subtype(/decl/plantgene))
		plant_gene_datums[gene.gene_tag] = gene

	. = ..()

// Proc for creating a random seed type.
/datum/controller/subsystem/processing/plants/proc/create_random_seed(survive_on_station)
	var/datum/seed/seed = new()
	seed.randomize()
	seed.name = "[seed.uid]"
	seeds[seed.name] = seed

	if(survive_on_station)
		if(seed.consume_gasses)
			seed.consume_gasses["plasma"] = null
			seed.consume_gasses["carbon_dioxide"] = null
		if(seed.chems && !isnull(seed.chems[/datum/reagent/acid/polyacid]))
			seed.chems[/datum/reagent/acid/polyacid] = null // Eating through the hull will make these plants completely inviable, albeit very dangerous.
			seed.chems -= null // Setting to null does not actually remove the entry, which is weird.
		seed.set_trait(TRAIT_IDEAL_HEAT,293)
		seed.set_trait(TRAIT_HEAT_TOLERANCE,20)
		seed.set_trait(TRAIT_IDEAL_LIGHT,4)
		seed.set_trait(TRAIT_LIGHT_TOLERANCE,5)
		seed.set_trait(TRAIT_LOWKPA_TOLERANCE,25)
		seed.set_trait(TRAIT_HIGHKPA_TOLERANCE,200)
	return seed
