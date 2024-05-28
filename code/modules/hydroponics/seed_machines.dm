/obj/item/disk/botany
	name = "flora data disk"
	desc = "A small disk used for carrying data on plant genetics."

	icon = 'icons/obj/hydroponics_items.dmi'
	icon_state = "disk"

	w_class = ITEM_SIZE_TINY

	var/list/stored_genes

/obj/item/disk/botany/proc/update_appearance()
	var/list/name_postfix = list()
	var/list/desc_postfix = list()

	for (var/gene_key as anything in stored_genes)
		var/datum/plantgene/associated_gene = stored_genes[gene_key]

		name_postfix += associated_gene.source_short
		desc_postfix += associated_gene.source

	SetName(initial(name))
	if (length(name_postfix))
		name += " ([name_postfix.Join(") (")])"

	desc = initial(desc)
	if (length(desc_postfix))
		desc += SPAN_NOTICE("\nThis disk contais following gene data: [english_list(desc_postfix)].")

/obj/item/disk/botany/attack_self(mob/user)
	if (wipe(user))
		return

	return ..()

/obj/item/disk/botany/proc/wipe(mob/user)
	if (!length(stored_genes))
		return FALSE

	var/choice = tgui_alert(user, "Are you sure you want to wipe the disk?", "Genome Data", list("Yes", "No"))
	if (choice != "Yes" || isnull(src) || isnull(user) || !user.Adjacent(get_turf(src)))
		return TRUE

	stored_genes = null

	update_appearance()
	show_splash_text(user, "disk data wiped", "You wipe the disk data.")

	return TRUE

/obj/item/disk/botany/proc/store_gene(datum/seed/seed_genetics, gene_name)
	var/datum/plantgene/seed_gene = seed_genetics.get_gene(gene_name)
	if (isnull(seed_gene))
		return FALSE

	LAZYSET(stored_genes, gene_name, seed_gene)

	update_appearance()

	return TRUE

/obj/item/storage/box/botanydisk
	name = "flora disk box"
	desc = "A box of flora data disks, apparently."

	icon_state = "hydrodisks"

	startswith = list(
		/obj/item/disk/botany = 14
		)

/obj/machinery/genemod
	name = "genetic forge"
	desc = "A high-tech device designed to precisely manipulate plant genes thus increasing botanists productivity."

	icon = 'icons/obj/machines/genemod.dmi'
	icon_state = "genemod"
	base_icon_state = "genemod"

	density = TRUE
	anchored = TRUE

	component_types = list(
		/obj/item/circuitboard/genemod,
		/obj/item/stock_parts/micro_laser,
		/obj/item/stock_parts/manipulator,
		/obj/item/stock_parts/console_screen,
	)

	/// Determines upper-bound when damage to `degradation` is rolled.
	var/deviation = 40;
	/// Represents genome degradation, when 100% is reached `seed_genes` is destroyed.
	var/degradation = 0
	/// Refernce to the seed genetic datum.
	var/datum/seed/seed_genes

	/// Reference to the inserted seed pack.
	var/obj/item/seeds/loaded_pack
	/// Reference to the inserted data disk.
	var/obj/item/disk/botany/loaded_disk

/obj/machinery/genemod/Initialize()
	. = ..()

	update_icon()

/obj/machinery/genemod/proc/update_glow()
	if (inoperable())
		set_light(0)
		return FALSE

	set_light(0.7, 0.1, 1, 2, COLOR_GREEN)
	return TRUE

/obj/machinery/genemod/on_update_icon()
	ClearOverlays()

	icon_state = "[base_icon_state][inoperable() ? "-off" : ""]"

	if (panel_open)
		AddOverlays("[base_icon_state]-open")

	if (!isnull(loaded_disk))
		AddOverlays("[base_icon_state]-disk")

	var/should_glow = update_glow()
	if (should_glow)
		AddOverlays(emissive_appearance(icon, "[base_icon_state]_ea"))

/obj/machinery/genemod/attackby(obj/item/O, mob/user)
	if (default_deconstruction_screwdriver(user, O))
		return

	if (default_deconstruction_crowbar(user, O))
		return

	if (attempt_insert_disk(O, user))
		return

	if (attempt_insert_seed(O, user))
		return

	return ..()

/obj/machinery/genemod/attack_hand(mob/user)
	. = ..()

	tgui_interact(user)

/obj/machinery/genemod/proc/attempt_insert_seed(obj/item/seeds/storing_seed, mob/user)
	if (!istype(storing_seed))
		return FALSE

	if (!isnull(loaded_pack))
		show_splash_text(user, "seeds pack alreay loaded!", "There is already a seeds pack loaded.")
		return TRUE

	if (isnull(storing_seed.seed) || storing_seed.seed.get_trait(TRAIT_IMMUTABLE) > 0)
		show_splash_text(user, "incompatible seed sample!", "That seed is not compatible with our genetics technology.")
		return TRUE

	if (!user.drop(storing_seed, src))
		return FALSE

	loaded_pack = storing_seed
	show_splash_text(user, "seeds pack loaded!", "You load [storing_seed] into \the [src].")

	tgui_update()

	return TRUE

/obj/machinery/genemod/proc/attempt_insert_disk(obj/item/disk/botany/inserting_disk, mob/user)
	if (!istype(inserting_disk))
		return FALSE

	if (!isnull(loaded_disk))
		show_splash_text(user, "disk already present!", "There is already a data disk loaded.")
		return TRUE

	if (!user.drop(inserting_disk, src))
		return FALSE

	loaded_disk = inserting_disk
	show_splash_text(user, "disk loaded", "You load [inserting_disk] into \the [src].")

	update_icon()
	tgui_update()

	return TRUE

/obj/machinery/genemod/RefreshParts()
	. = ..()

	var/obj/item/stock_parts/micro_laser/laser = locate() in component_parts
	var/obj/item/stock_parts/manipulator/manipulator = locate() in component_parts

	deviation = 40 - (laser.rating + manipulator.rating) / 2 * 10

/obj/machinery/genemod/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if (!ui)
		ui = new(user, src, "Genemod", name)
		ui.open()

/obj/machinery/genemod/tgui_data(mob/user)
	var/list/data = list()

	data["hasDisk"] = isnull(loaded_disk) ? FALSE : TRUE
	data["hasPack"] = isnull(loaded_pack) ? FALSE : TRUE
	data["hasGenes"] = isnull(seed_genes) ? FALSE : TRUE
	data["degradation"] = CLAMP01(degradation / 100)
	data["modification"] = loaded_pack?.modified || 0

	data["knownGenes"] = list()
	for (var/gene_name as anything in ALL_GENES)
		data["knownGenes"] += list(list(
			"name" = gene_name,
			"isStored" = LAZYISIN(loaded_disk?.stored_genes, gene_name) ? TRUE : FALSE,
		))

	data["storedGenes"] = list()
	for (var/gene_name as anything in loaded_disk?.stored_genes)
		data["storedGenes"] += gene_name

	return data

/obj/machinery/genemod/tgui_act(action, params)
	. = ..()

	if (.)
		return

	switch (action)
		if ("eject_disk")
			eject_disk()
			return TRUE

		if ("eject_pack")
			eject_pack()
			return TRUE

		if ("store_gene")
			var/gene_name = params["value"]
			if (isnull(gene_name))
				return

			extract_gene(gene_name)
			return TRUE

		if ("apply_gene")
			var/gene_name = params["value"]
			if (isnull(gene_name))
				return

			apply_gene(gene_name)
			return TRUE

		if ("apply_all")
			apply_gene(null)
			return TRUE

		if ("scramble")
			scramble_genes()
			return TRUE

		if ("wipe")
			wipe_genes()
			return TRUE

/obj/machinery/genemod/proc/eject_disk()
	if (isnull(loaded_disk))
		return

	if (!loaded_disk.dropInto(get_turf(src)))
		return

	loaded_disk = null

/obj/machinery/genemod/proc/eject_pack()
	if (isnull(loaded_pack))
		return

	if (!loaded_pack.dropInto(get_turf(src)))
		return

	loaded_pack.seed.save_seed()
	loaded_pack.update_seed()

	loaded_pack = null

/obj/machinery/genemod/proc/scramble_genes()
	if (isnull(loaded_pack) || isnull(loaded_pack.seed))
		return

	seed_genes = loaded_pack.seed
	degradation = 0

	QDEL_NULL(loaded_pack)

/obj/machinery/genemod/proc/wipe_genes()
	seed_genes = null
	degradation = 0

/obj/machinery/genemod/proc/extract_gene(gene_name)
	if (isnull(seed_genes) || isnull(loaded_disk))
		return

	if (!loaded_disk.store_gene(seed_genes, gene_name))
		return

	degradation += rand(20, 20 + deviation)
	if (degradation >= 100)
		wipe_genes()

	audible_message(
		"<b>\The [src]</b> states, \"Gene extraction complete, all relevant data is now stored on the inserted disk.\"",
		splash_override = "Gene extraction complete, all relevant data is now stored on the inserted disk."
	)

/obj/machinery/genemod/proc/apply_gene(gene_name_to_apply)
	if (isnull(loaded_pack) || isnull(loaded_disk))
		return

	if (!isnull(SSplants.seeds[loaded_pack.seed.name]))
		loaded_pack.seed = loaded_pack.seed.diverge(1)
		loaded_pack.seed_type = loaded_pack.seed.name
		loaded_pack.update_seed()

	if (prob(loaded_pack.modified))
		loaded_pack.modified = 101

	for (var/gene_name as anything in loaded_disk.stored_genes)
		var/datum/plantgene/gene = loaded_disk.stored_genes[gene_name]

		if (!istype(gene))
			continue

		if (!isnull(gene_name_to_apply) && gene_name_to_apply != gene_name)
			continue

		loaded_pack.seed.apply_gene(gene)
		loaded_pack.modified += rand(5, 10)

	audible_message(
		"<b>\The [src]</b> states, \"Gene modification complete, thank you for using [src]\"",,
		splash_override = "Gene modification complete, thank you for using [src]"
	)
