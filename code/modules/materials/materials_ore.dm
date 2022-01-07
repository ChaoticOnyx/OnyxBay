/obj/item/ore
	name = "ore"
	icon_state = "lump"
	icon = 'icons/obj/materials/ore.dmi'
	randpixel = 8
	w_class = 2
	var/material/material
	var/datum/geosample/geologic_data

/obj/item/ore/get_material()
	return material

/obj/item/ore/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/core_sampler))
		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
	else
		return ..()

/obj/item/ore/New(newloc, _mat)
	if(_mat)
		matter = list()
		matter[_mat] = SHEET_MATERIAL_AMOUNT
	..(newloc)

/obj/item/ore/Initialize()
	for(var/stuff in matter)
		var/material/M = SSmaterials.get_material_by_name(stuff)
		if(M)
			name = M.ore_name
			desc = M.ore_desc ? M.ore_desc : "A lump of ore."
			material = M
			color = M.icon_colour
			icon_state = M.ore_icon_overlay
			if(M.ore_desc)
				desc = M.ore_desc
			if(icon_state == "dust")
				slot_flags = SLOT_HOLSTER
			break
	. = ..()

// POCKET SAND!
/obj/item/ore/throw_impact(atom/hit_atom)
	..()
	if(icon_state == "dust")
		var/mob/living/carbon/human/H = hit_atom
		if(istype(H) && H.has_eyes() && prob(85))
			to_chat(H,"<span class='danger'>Some of \the [src] gets in your eyes!</span>")
			H.eye_blind += 5
			H.eye_blurry += 10
			QDEL_IN(src, 1)

// Map definitions.
/obj/item/ore/uranium/New(newloc)
	..(newloc, "pitchblende")
/obj/item/ore/iron/New(newloc)
	..(newloc, "hematite")
/obj/item/ore/coal/New(newloc)
	..(newloc, "graphene")
/obj/item/ore/glass/New(newloc)
	..(newloc, "sand")
/obj/item/ore/silver/New(newloc)
	..(newloc, "silver")
/obj/item/ore/gold/New(newloc)
	..(newloc, "gold")
/obj/item/ore/diamond/New(newloc)
	..(newloc, "diamond")
/obj/item/ore/osmium/New(newloc)
	..(newloc, "platinum")
/obj/item/ore/hydrogen/New(newloc)
	..(newloc, "mhydrogen")
/obj/item/ore/slag/New(newloc)
	..(newloc, "waste")
/obj/item/ore/plasma/New(newloc)
	..(newloc, "plasma")
