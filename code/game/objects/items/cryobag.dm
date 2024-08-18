
/obj/item/bodybag/cryobag
	name = "stasis bag"
	desc = "A folded, non-reusable bag designed to prevent additional damage to an occupant, especially useful if short on time or in \
	a hostile enviroment."
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_folded"
	item_state = "bodybag_folded"
	origin_tech = list(TECH_BIO = 4)
	var/stasis_power
	var/bag_structure = /obj/structure/closet/body_bag/cryobag

/obj/item/bodybag/cryobag/attack_self(mob/user)
	var/obj/structure/closet/body_bag/cryobag/R = new bag_structure(user.loc)
	if(stasis_power)
		R.stasis_power = stasis_power
	R.update_icon()
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/closet/body_bag/cryobag
	name = "stasis bag"
	desc = "A non-reusable plastic bag designed to prevent additional damage to an occupant, especially useful if short on time or in \
	a hostile enviroment."
	icon = 'icons/obj/cryobag.dmi'
	item_path = /obj/item/bodybag/cryobag

	storage_types = CLOSET_STORAGE_MOBS
	intact_closet = FALSE
	var/datum/gas_mixture/airtank

	var/syndi

	var/stasis_power = 20
	var/degradation_time = 150 //ticks until stasis power degrades, ~5 minutes

/obj/structure/closet/body_bag/cryobag/Initialize()
	. = ..()
	airtank = new()
	if(syndi)
		airtank.temperature = -25 CELSIUS
	else
		airtank.temperature = 0 CELSIUS
	airtank.adjust_gas("oxygen", MOLES_O2STANDARD, 0)
	airtank.adjust_gas("nitrogen", MOLES_N2STANDARD)
	update_icon()

/obj/structure/closet/body_bag/cryobag/Destroy()
	QDEL_NULL(airtank)
	return ..()

/obj/structure/closet/body_bag/cryobag/Entered(atom/movable/AM)
	if(ishuman(AM))
		set_next_think(world.time)
	..()

/obj/structure/closet/body_bag/cryobag/Exited(atom/movable/AM)
	if(ishuman(AM))
		set_next_think(0)
	. = ..()

/obj/structure/closet/body_bag/cryobag/on_update_icon()
	..()
	ClearOverlays()
	var/image/I = image(icon, "indicator[opened]")
	I.appearance_flags = DEFAULT_APPEARANCE_FLAGS | RESET_COLOR
	var/maxstasis = initial(stasis_power)
	if(stasis_power > 0.5 * maxstasis)
		I.color = COLOR_LIME
	else if(stasis_power)
		I.color = COLOR_YELLOW
	else
		I.color = COLOR_RED
	AddOverlays(I)

/obj/structure/closet/body_bag/cryobag/proc/get_saturation()
	return -155 * (1 - stasis_power/initial(stasis_power))

/obj/structure/closet/body_bag/cryobag/fold(user)
	var/obj/item/bodybag/cryobag/folded = ..()
	if(istype(folded))
		folded.stasis_power = stasis_power
		folded.color = color_saturation(get_saturation())

/obj/structure/closet/body_bag/cryobag/think()
	if(stasis_power < 2)
		return
	var/mob/living/carbon/human/H = locate() in src
	if(!H)
		return
	degradation_time--
	if(degradation_time < 0)
		degradation_time = initial(degradation_time)
		stasis_power = round(0.75 * stasis_power)
		animate(src, color = color_saturation(get_saturation()), time = 10)
		update_icon()

	if(H.stasis_sources[STASIS_CRYOBAG] != stasis_power)
		H.SetStasis(stasis_power, STASIS_CRYOBAG)

	set_next_think(world.time + 1 SECOND)

/obj/structure/closet/body_bag/cryobag/return_air() //Used to make stasis bags protect from vacuum.
	if(airtank)
		return airtank
	..()

/obj/structure/closet/body_bag/cryobag/examine(mob/user, infix)
	. = ..()

	. += "The stasis meter shows '[stasis_power]x'."

	if(Adjacent(user)) //The bag's rather thick and opaque from a distance.
		. += SPAN_INFO("You peer into \the [src].")
		for(var/mob/living/L in contents)
			L.examine(user)

/obj/item/usedcryobag
	name = "used stasis bag"
	desc = "Pretty useless now.."
	icon_state = "bodybag_used"
	icon = 'icons/obj/cryobag.dmi'

/obj/item/bodybag/cryobag/syndi
	name = "modified stasis bag"
	icon = 'icons/obj/syndi_cryobag.dmi'
	bag_structure = /obj/structure/closet/body_bag/cryobag/syndi

/obj/structure/closet/body_bag/cryobag/syndi
	name = "modified stasis bag"
	icon = 'icons/obj/syndi_cryobag.dmi'
	syndi = 1
	item_path = /obj/item/bodybag/cryobag/syndi
	stasis_power = 10
	degradation_time = 300

/obj/structure/closet/body_bag/cryobag/syndi/fold(user)
	var/obj/item/bodybag/cryobag/syndi/folded = ..()
	if(istype(folded))
		folded.stasis_power = stasis_power
		folded.color = color_saturation(get_saturation())

/obj/structure/closet/body_bag/cryobag/syndi/Process()
	..()

	var/mob/living/carbon/human/H = locate() in src
	if(!H)
		return PROCESS_KILL

	H.add_chemical_effect(CE_CRYO, 2)
	H.add_chemical_effect(CE_STABLE)
	H.add_chemical_effect(CE_OXYGENATED, 1)
	H.add_chemical_effect(CE_ANTITOX , 1)
	H.add_chemical_effect(CE_PULSE, -1)

// Bag'o'Vat
/obj/item/bodybag/cryobag/vatgrownbody
	name = "VAT stasis bag"
	icon = 'icons/obj/vat_cryobag.dmi'
	bag_structure = /obj/structure/closet/body_bag/cryobag/vatgrownbody

/obj/structure/closet/body_bag/cryobag/vatgrownbody
	name = "VAT stasis bag"
	desc = "A non-reusable plastic bag designed to prevent additional damage to an occupant, especially useful if short on time or in \
	a hostile enviroment. This one is marked with big \"VAT\" letters and has some sort of document glued to it."
	icon = 'icons/obj/vat_cryobag.dmi'
	item_path = /obj/item/bodybag/cryobag/vatgrownbody
	var/mobpath = null

/obj/structure/closet/body_bag/cryobag/vatgrownbody/Initialize()
	. = ..()
	if(mobpath)
		new mobpath(src)
		contains_body = 1
		update_icon()

/obj/structure/closet/body_bag/cryobag/vatgrownbody/male
	mobpath = /mob/living/carbon/human/vatgrown

/obj/structure/closet/body_bag/cryobag/vatgrownbody/female
	mobpath = /mob/living/carbon/human/vatgrown/female
