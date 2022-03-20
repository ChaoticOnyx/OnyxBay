/obj/item/fuel_assembly
	name = "fuel rod assembly"
	icon = 'icons/obj/machines/power/fusion.dmi'
	icon_state = "fuel_assembly"
	layer = 4

	var/material_name

	var/percent_depleted = 1
	var/list/rod_quantities = list()
	var/fuel_type = "composite"
	var/fuel_colour
	var/radioactivity = 0
	var/const/initial_amount = 300

/obj/item/fuel_assembly/New(newloc, _material, _colour)
	fuel_type = _material
	fuel_colour = _colour
	..(newloc)

/obj/item/fuel_assembly/Initialize()
	. = ..()
	var/material/material = get_material_by_name(fuel_type)
	if(istype(material))
		SetName("[material.use_name] fuel rod assembly")
		desc = "A fuel rod for a fusion reactor. This one is made from [material.use_name]."
		fuel_colour = material.icon_colour
		fuel_type = material.use_name
		if(material.luminescence)
			set_light(material.luminescence, 0.1, material.luminescence, 2, material.icon_colour)
	else
		SetName("[fuel_type] fuel rod assembly")
		desc = "A fuel rod for a fusion reactor. This one is made from [fuel_type]."

	icon_state = "blank"
	var/image/I = image(icon, "fuel_assembly")
	I.color = fuel_colour
	overlays += list(I, image(icon, "fuel_assembly_bracket"))
	rod_quantities[fuel_type] = initial_amount

/obj/item/fuel_assembly/Process()
	if(!radioactivity)
		return PROCESS_KILL

	if(istype(loc, /turf))
		SSradiation.radiate(src, max(1,ceil(radioactivity/30)))

/obj/item/fuel_assembly/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

// Mapper shorthand.
/obj/item/fuel_assembly/deuterium/New(newloc)
	..(newloc, MATERIAL_DEUTERIUM)

/obj/item/fuel_assembly/tritium/New(newloc)
	..(newloc, MATERIAL_TRITIUM)

/obj/item/fuel_assembly/plasma/New(newloc)
	..(newloc, MATERIAL_PLASMA)

/obj/item/fuel_assembly/supermatter/New(newloc)
	..(newloc, MATERIAL_SUPERMATTER)

/obj/item/fuel_assembly/hydrogen/New(newloc)
	..(newloc, MATERIAL_HYDROGEN)
