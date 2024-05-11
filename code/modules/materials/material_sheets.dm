// Stacked resources. They use a material datum for a lot of inherited values.
/obj/item/stack/material
	item_state = "sheet-metal" // Placeholder, since we don't have icons for all the sheets yet. Better than invisible icons, I suppose ~ToTh
	force = 5.0
	throwforce = 5
	w_class = ITEM_SIZE_NORMAL
	throw_range = 3
	max_amount = 50
	center_of_mass = null
	randpixel = 3
	storage_cost_mult = 1.25

	var/default_type = MATERIAL_STEEL
	var/material/material
	var/perunit = SHEET_MATERIAL_AMOUNT
	var/apply_colour //temp pending icon rewrite

	drop_sound = SFX_DROP_AXE
	pickup_sound = SFX_PICKUP_AXE

/obj/item/stack/material/Initialize()
	. = ..()
	if(!default_type)
		default_type = MATERIAL_STEEL
	material = get_material_by_name("[default_type]")
	if(!material)
		return INITIALIZE_HINT_QDEL

	recipes = material.get_recipes()
	stacktype = material.stack_type
	if(islist(material.stack_origin_tech))
		origin_tech = material.stack_origin_tech.Copy()

	if(apply_colour)
		color = material.icon_colour

	if(material.conductive)
		obj_flags |= OBJ_FLAG_CONDUCTIBLE
	else
		obj_flags &= (~OBJ_FLAG_CONDUCTIBLE)

	matter = material.get_matter()
	if(!uses_charge)
		craft_tool = material.craft_tool
	update_strings()

	if(material.reagent_path)
		create_reagents(get_max_amount() * REAGENTS_PER_MATERIAL_SHEET)
		reagents.add_reagent(material.reagent_path, amount * REAGENTS_PER_MATERIAL_SHEET, null, FALSE)

/obj/item/stack/material/get_material()
	return material

/obj/item/stack/material/proc/update_strings()
	// Update from material datum.
	singular_name = material.sheet_singular_name

	if(amount>1)
		SetName("[material.use_name] [material.sheet_plural_name]")
		desc = "A stack of [material.use_name] [material.sheet_plural_name]."
		gender = PLURAL
	else
		SetName("[material.use_name] [material.sheet_singular_name]")
		desc = "A [material.sheet_singular_name] of [material.use_name]."
		gender = NEUTER

/obj/item/stack/material/add(extra)
	. = ..(extra)
	if(. && material.reagent_path)
		reagents.add_reagent(material.reagent_path, (extra * REAGENTS_PER_MATERIAL_SHEET))

/obj/item/stack/material/use(used)
	. = ..()
	update_strings()
	if(. && material?.reagent_path)
		reagents?.remove_reagent(material.reagent_path, (amount * REAGENTS_PER_MATERIAL_SHEET))
	return

/obj/item/stack/material/transfer_to(obj/item/stack/S, tamount=null, type_verified)
	var/obj/item/stack/material/M = S
	if(!istype(M) || material.name != M.material.name)
		return 0
	var/transfer = ..(S,tamount,1)
	if(src)
		update_strings()
	if(M)
		M.update_strings()
	return transfer

/obj/item/stack/material/attack_self(mob/user)
	if(!material.build_windows(user, src))
		..()

/obj/item/stack/material/attackby(obj/item/W, mob/user)
	if(isCoil(W))
		material.build_wired_product(user, W, src)
		return
	else if(istype(W, /obj/item/stack/rods))
		material.build_rod_product(user, W, src)
		return
	return ..()

/obj/item/stack/material/iron
	name = "iron"
	icon_state = "silver"
	item_state = "sheet-silver"
	default_type = MATERIAL_IRON
	apply_colour = TRUE

/obj/item/stack/material/sandstone
	name = "sandstone brick"
	icon_state = "sandstone"
	default_type = MATERIAL_SANDSTONE

/obj/item/stack/material/sandstone/fifty
	amount = 50

/obj/item/stack/material/marble
	name = "marble brick"
	icon_state = "marble"
	default_type = MATERIAL_MARBLE

/obj/item/stack/material/marble/ten
	amount = 10

/obj/item/stack/material/marble/fifty
	amount = 50

/obj/item/stack/material/diamond
	name = "diamond"
	icon_state = "diamond"
	item_state = "sheet-diamond"
	default_type = MATERIAL_DIAMOND

/obj/item/stack/material/diamond/ten
	amount = 10

/obj/item/stack/material/uranium
	name = MATERIAL_URANIUM
	icon_state = "uranium"
	item_state = "sheet-uranium"
	default_type = MATERIAL_URANIUM

/obj/item/stack/material/uranium/ten
	amount = 10

/obj/item/stack/material/plasma
	name = "solid plasma"
	icon_state = "solid_plasma"
	item_state = "sheet-plasma"
	default_type = MATERIAL_PLASMA

/obj/item/stack/material/plasma/ten
	amount = 10

/obj/item/stack/material/plasma/fifty
	amount = 50

/obj/item/stack/material/plastic
	name = "plastic"
	icon_state = "plastic"
	item_state = "sheet-plastic"
	default_type = MATERIAL_PLASTIC

/obj/item/stack/material/plastic/ten
	amount = 10

/obj/item/stack/material/plastic/fifty
	amount = 50

/obj/item/stack/material/gold
	name = "gold"
	icon_state = "gold"
	item_state = "sheet-gold"
	default_type = MATERIAL_GOLD

/obj/item/stack/material/gold/ten
	amount = 10

/obj/item/stack/material/silver
	name = "silver"
	icon_state = "silver"
	item_state = "sheet-silver"
	default_type = MATERIAL_SILVER

/obj/item/stack/material/silver/ten
	amount = 10

//Valuable resource, cargo can sell it.
/obj/item/stack/material/platinum
	name = "platinum"
	icon_state = "adamantine"
	item_state = "sheet-platinum"
	default_type = MATERIAL_PLATINUM

/obj/item/stack/material/platinum/ten
	amount = 10

//Extremely valuable to Research.
/obj/item/stack/material/mhydrogen
	name = "metallic hydrogen"
	icon_state = "hydrogen"
	item_state = "sheet-hydrogen"
	default_type = MATERIAL_HYDROGEN

/obj/item/stack/material/mhydrogen/ten
	amount = 10

//God tier resource, cargo can sell it.
/obj/item/stack/material/adamantine
	name = "adamantine"
	icon_state = "adamantine"
	default_type = MATERIAL_ADAMANTINE
	apply_colour = TRUE

//Fuel for MRSPACMAN generator.
/obj/item/stack/material/tritium
	name = "tritium"
	icon_state = "silver"
	item_state = "sheet-silver"
	default_type = MATERIAL_TRITIUM
	apply_colour = TRUE

/obj/item/stack/material/tritium/ten
	amount = 10

/obj/item/stack/material/tritium/fifty
	amount = 50

/obj/item/stack/material/osmium
	name = "osmium"
	icon_state = "silver"
	item_state = "sheet-silver"
	default_type = MATERIAL_OSMIUM
	apply_colour = TRUE

/obj/item/stack/material/osmium/ten
	amount = 10

/obj/item/stack/material/ocp
	name = "osmium-carbide plasteel"
	icon_state = "plasteel"
	item_state = "sheet-plasteel"
	default_type = MATERIAL_OSMIUM_CARBIDE_PLASTEEL
	apply_colour = TRUE

/obj/item/stack/material/ocp/ten
	amount = 10

/obj/item/stack/material/ocp/fifty
	amount = 50

// Fusion fuel.
/obj/item/stack/material/deuterium
	name = "deuterium"
	icon_state = "silver"
	item_state = "sheet-silver"
	default_type = MATERIAL_DEUTERIUM
	apply_colour = TRUE

/obj/item/stack/material/deuterium/fifty
	amount = 50

/obj/item/stack/material/steel
	name = "steel"
	icon_state = "metal"
	item_state = "sheet-metal"
	default_type = MATERIAL_STEEL

/obj/item/stack/material/steel/ten
	amount = 10

/obj/item/stack/material/steel/fifty
	amount = 50

/obj/item/stack/material/plasteel
	name = "plasteel"
	icon_state = "plasteel"
	item_state = "sheet-plasteel"
	default_type = MATERIAL_PLASTEEL

/obj/item/stack/material/plasteel/ten
	amount = 10

/obj/item/stack/material/plasteel/fifty
	amount = 50

/obj/item/stack/material/plasteel/titanium
	name = "titanium"
	icon_state = "metal"
	item_state = "sheet-titanium"
	default_type = MATERIAL_TITANIUM
	apply_colour = TRUE

/obj/item/stack/material/plasteel/titanium/ten
	amount = 10

/obj/item/stack/material/plasteel/titanium/fifty
	amount = 50

/obj/item/stack/material/wood
	name = "wooden plank"
	icon_state = "wood"
	item_state = "sheet-wood"
	default_type = MATERIAL_WOOD
	drop_sound = SFX_DROP_WOODEN
	pickup_sound = SFX_PICKUP_WOODEN

/obj/item/stack/material/wood/ten
	amount = 10

/obj/item/stack/material/wood/fifty
	amount = 50

/obj/item/stack/material/darkwood
	name = "darkwood plank"
	icon_state = "darkwood"
	item_state = "sheet-wood"
	default_type = MATERIAL_DARKWOOD

/obj/item/stack/material/darkwood/ten
	amount = 10

/obj/item/stack/material/darkwood/fifty
	amount = 50

/obj/item/stack/material/cloth
	name = "cloth"
	icon_state = "cloth"
	default_type = MATERIAL_CLOTH

/obj/item/stack/material/cardboard
	name = "cardboard"
	icon_state = "card"
	item_state = "sheet-card"
	default_type = MATERIAL_CARDBOARD

/obj/item/stack/material/cardboard/ten
	amount = 10

/obj/item/stack/material/cardboard/fifty
	amount = 50

/obj/item/stack/material/leather
	name = "leather"
	desc = "The by-product of mob grinding."
	icon_state = "leather"
	item_state = "clipboard"
	default_type = MATERIAL_LEATHER

	drop_sound = SFX_DROP_LEATHER
	pickup_sound = SFX_PICKUP_LEATHER

/obj/item/stack/material/glass
	name = "glass"
	icon_state = "glass"
	item_state = "sheet-glass"
	default_type = MATERIAL_GLASS
	drop_sound = SFX_DROP_GLASS
	pickup_sound = SFX_PICKUP_GLASS

/obj/item/stack/material/glass/ten
	amount = 10

/obj/item/stack/material/glass/fifty
	amount = 50

/obj/item/stack/material/glass/reinforced
	name = "reinforced glass"
	icon_state = "rglass"
	item_state = "sheet-rglass"
	default_type = MATERIAL_REINFORCED_GLASS

/obj/item/stack/material/glass/reinforced/ten
	amount = 10

/obj/item/stack/material/glass/reinforced/fifty
	amount = 50

/obj/item/stack/material/glass/plass
	name = "plass"
	desc = "This sheet is special plasma-glass alloy designed to withstand large temperatures."
	singular_name = "plass sheet"
	icon_state = "plass"
	item_state = "sheet-plass"
	default_type = MATERIAL_PLASS

/obj/item/stack/material/glass/plass/ten
	amount = 10

/obj/item/stack/material/glass/plass/fifty
	amount = 50

/obj/item/stack/material/glass/rplass
	name = "reinforced plass"
	desc = "This sheet is special plasma-glass alloy designed to withstand large temperatures. It is reinforced with few rods."
	singular_name = "reinforced plass sheet"
	icon_state = "rplass"
	item_state = "sheet-rplass"
	default_type = MATERIAL_REINFORCED_PLASS

/obj/item/stack/material/glass/rplass/ten
	amount = 10

/obj/item/stack/material/glass/rplass/fifty
	amount = 50

/obj/item/stack/material/glass/black
	name = "tinted glass"
	singular_name = "tinted glass sheet"
	icon_state = "bglass"
	item_state = "sheet-glass"
	default_type = MATERIAL_BLACK_GLASS

/obj/item/stack/material/glass/black/ten
	amount = 10

/obj/item/stack/material/glass/black/fifty
	amount = 50

/obj/item/stack/material/glass/rblack
	name = "reinforced tinted glass"
	singular_name = "reinforced tinted glass sheet"
	icon_state = "rbglass"
	item_state = "sheet-rglass"
	default_type = MATERIAL_REINFORCED_BLACK_GLASS

/obj/item/stack/material/glass/rblack/ten
	amount = 10

/obj/item/stack/material/glass/rblack/fifty
	amount = 50
