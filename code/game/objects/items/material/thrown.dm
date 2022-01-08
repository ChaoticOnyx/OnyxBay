/obj/item/material/star
	name = "shuriken"
	desc = "A sharp, star-shaped piece of metal."
	icon_state = "star"
	randpixel = 12
	w_class = ITEM_SIZE_SMALL
	force_const = 3.0
	thrown_force_const = 3.0
	mod_weight = 0.5
	mod_reach = 0.35
	mod_handy = 0.75
	force_divisor = 0.05 // 3 with hardness 60 (steel)
	thrown_force_divisor = 0.35 // 7 with weight 20 (steel)
	throw_speed = 10
	throw_range = 15
	sharp = 1
	edge =  1

/obj/item/material/star/New()
	..()

/obj/item/material/star/throw_impact(atom/hit_atom)
	..()
	if(material.radioactivity>0 && istype(hit_atom,/mob/living))
		var/mob/living/M = hit_atom
		var/urgh = material.radioactivity
		M.adjustToxLoss(rand(urgh/2,urgh))

/obj/item/material/star/ninja
	default_material = MATERIAL_URANIUM
	desc = "A sharp, perfectly weighted piece of metal."
