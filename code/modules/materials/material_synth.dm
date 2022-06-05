// These objects are used by cyborgs to get around a lot of the limitations on stacks
// and the weird bugs that crop up when expecting borg module code to behave sanely.
/obj/item/stack/material/cyborg
	uses_charge = 1
	charge_costs = list(1000)
	gender = NEUTER
	matter = null // Don't shove it in the autolathe.

/obj/item/stack/material/cyborg/New()
	if(..())
		name = "[material.display_name] synthesiser"
		desc = "A device that synthesises [material.display_name]."
		matter = null

/obj/item/stack/material/cyborg/plastic
	icon_state = "plastic"
	default_type = MATERIAL_PLASTIC

/obj/item/stack/material/cyborg/steel
	icon_state = "metal"
	default_type = MATERIAL_STEEL

/obj/item/stack/material/cyborg/plasteel
	icon_state = "plasteel"
	default_type = MATERIAL_PLASTEEL

/obj/item/stack/material/cyborg/wood
	icon_state = "wood"
	default_type = MATERIAL_WOOD

/obj/item/stack/material/cyborg/marble
	icon_state = "marble"
	default_type = MATERIAL_MARBLE

/obj/item/stack/material/cyborg/glass
	icon_state = "glass"
	default_type = MATERIAL_GLASS

/obj/item/stack/material/cyborg/glass/reinforced
	icon_state = "rglass"
	default_type = MATERIAL_REINFORCED_GLASS
	charge_costs = list(500, 1000)
