/////////////////////////////////////////
//Material Rings
/obj/item/clothing/ring/material
	icon = 'icons/obj/clothing/rings.dmi'
	icon_state = "material"
	var/material/material

/obj/item/clothing/ring/material/New(newloc, new_material)
	..(newloc)
	if(!new_material)
		new_material = MATERIAL_STEEL
	material = get_material_by_name(new_material)
	if(!istype(material))
		qdel(src)
		return
	name = "[material.display_name] ring"
	desc = "A ring made from [material.display_name]."
	color = material.icon_colour

/obj/item/clothing/ring/material/get_material()
	return material

/obj/item/clothing/ring/material/wood/New(newloc)
	..(newloc, MATERIAL_WOOD)

/obj/item/clothing/ring/material/plastic/New(newloc)
	..(newloc, MATERIAL_PLASTIC)

/obj/item/clothing/ring/material/steel/New(newloc)
	..(newloc, MATERIAL_STEEL)

/obj/item/clothing/ring/material/silver/New(newloc)
	..(newloc, MATERIAL_SILVER)

/obj/item/clothing/ring/material/gold/New(newloc)
	..(newloc, MATERIAL_GOLD)

/obj/item/clothing/ring/material/platinum/New(newloc)
	..(newloc, MATERIAL_PLATINUM)

/obj/item/clothing/ring/material/bronze/New(newloc)
	..(newloc, MATERIAL_BRONZE)

/obj/item/clothing/ring/material/glass/New(newloc)
	..(newloc, MATERIAL_GLASS)
