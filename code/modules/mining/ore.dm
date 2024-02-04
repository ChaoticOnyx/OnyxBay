/obj/item/ore
	name = "small rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore2"
	randpixel = 10
	w_class = ITEM_SIZE_SMALL
	var/datum/geosample/geologic_data
	var/ore/ore = null // set to a type to find the right instance on init

/obj/item/ore/Initialize()
	. = ..()
	if(ispath(ore))
		ore = GLOB.ores_by_type[ore]
		if(ore.ore != type)
			log_error("[src] ([src.type]) had ore type [ore.type] but that type does not have [src.type] set as its ore item!")
		update_ore()

/obj/item/ore/proc/update_ore()
	SetName(ore.display_name)
	icon_state = "ore_[ore.icon_tag]"
	origin_tech = ore.origin_tech.Copy()

/obj/item/ore/Value(base)
	. = ..()
	if(!ore)
		return
	var/material/M
	if(ore.smelts_to)
		M = get_material_by_name(ore.smelts_to)
	else if (ore.compresses_to)
		M = get_material_by_name(ore.compresses_to)
	if(!istype(M))
		return
	return 0.5*M.value*ore.result_amount

/obj/item/ore/slag
	name = "slag"
	desc = "Someone screwed up..."
	icon_state = "slag"

/obj/item/ore/uranium
	ore = /ore/uranium

/obj/item/ore/uranium/Initialize()
	. = ..()

	create_reagents()
	reagents.add_reagent(/datum/reagent/uranium, ore.result_amount, null, FALSE)

/obj/item/ore/iron
	ore = /ore/hematite

/obj/item/ore/coal
	ore = /ore/coal

/obj/item/ore/glass
	ore = /ore/glass
	slot_flags = SLOT_HOLSTER

// POCKET SAND!
/obj/item/ore/glass/throw_impact(atom/hit_atom)
	..()
	var/mob/living/carbon/human/H = hit_atom
	if(istype(H) && H.has_eyes() && prob(85))
		to_chat(H, "<span class='danger'>Some of \the [src] gets in your eyes!</span>")
		H.eye_blind += 5
		H.eye_blurry += 10
		spawn(1)
			if(istype(loc, /turf/)) qdel(src)


/obj/item/ore/plasma
	ore = /ore/plasma

/obj/item/ore/silver
	ore = /ore/silver

/obj/item/ore/gold
	ore = /ore/gold

/obj/item/ore/diamond
	ore = /ore/diamond

/obj/item/ore/osmium
	ore = /ore/platinum

/obj/item/ore/hydrogen
	ore = /ore/hydrogen

/obj/item/ore/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/core_sampler))
		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
	else
		return ..()
