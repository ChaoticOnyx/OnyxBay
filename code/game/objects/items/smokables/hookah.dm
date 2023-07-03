
// Hookah itself
/obj/item/reagent_containers/vessel/hookah
	name = "hookah"
	desc = "What was supposed to be a cyborg hull once, but ended up being a hookah because of an intern roboticist's genius. Nevertheless, the design was so breathtaking, it was adapted by Acme Co., resulting in the most iconic hookah of the 26th century."
	icon = 'icons/obj/hookah.dmi'
	icon_state = "hookah"
	var/base_icon = "hookah"
	item_state = "beaker"
	center_of_mass = "x=16;y=5"
	force = 12.5
	mod_weight = 1.35
	mod_reach = 1.0
	mod_handy = 0.6
	matter = list(MATERIAL_GLASS = 5000)
	brittle = FALSE
	filling_states = "5;10;25;50;75;80;100"
	label_icon = FALSE
	overlay_icon = FALSE
	lid_type = null
	rad_resist = list(
		RADIATION_ALPHA_PARTICLE = 11.8 MEGA ELECTRONVOLT,
		RADIATION_BETA_PARTICLE = 0.8 MEGA ELECTRONVOLT,
		RADIATION_HAWKING = 1 ELECTRONVOLT
	)

	var/obj/item/hookah_coal/HC = null
	var/obj/item/hookah_hose/H1 = null
	var/obj/item/hookah_hose/H2 = null
	var/has_second_hose = TRUE

/obj/item/reagent_containers/vessel/hookah/Initialize()
	. = ..()
	H1 = new /obj/item/hookah_hose(src)
	if(has_second_hose)
		H2 = new /obj/item/hookah_hose(src)
	HC = new /obj/item/hookah_coal(src)

/obj/item/reagent_containers/vessel/hookah/update_icon()
	if(H1)
		overlays += image(icon, "[base_icon]_left_0"
	else
		overlays += image(icon, "[base_icon]_left_1"
	if(has_second_hose)
		if(H2)
			overlays += image(icon, "[base_icon]_right_0"
		else
			overlays += image(icon, "[base_icon]_right_1"

/obj/item/reagent_containers/vessel/hookah/Destroy()
	. = ..()
	if(HC)
		QDEL_NULL(HC)
	if(H1)
		QDEL_NULL(H1)
	if(H2)
		QDEL_NULL(H2)

// Mouthpieces
/obj/item/hookah_hose
	name = "hookah mouthpiece"
	desc = "God knows how many tongues this thing has seen so far."
	icon = 'icons/obj/hookah.dmi'
	icon_state = "mouthpiece"

// Coal
/obj/item/hookah_coal
	name = "electric hookah coal"
	desc = "No real coals aboard the station. Period."
	icon = 'icons/obj/hookah.dmi'
	var/chem_volume = 40
	var/pulls_left = 0

/obj/item/hookah_coal/New()
	..()
	atom_flags |= ATOM_FLAG_OPEN_CONTAINER

/obj/item/hookah_coal/Initialize()
	. = ..()
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of [chem_volume]

/obj/item/hookah_coal/attack_self(mob/user)
	if(pulls_left)
		var/turf/location = get_turf(user)
		user.visible_message(SPAN("notice", "[user] empties out [src]."), SPAN("notice", "You empty out [src]."))
		new /obj/effect/decal/cleanable/ash(location)
		pulls_left = 0
		reagents.clear_reagents()
		SetName("empty [initial(name)]")

/obj/item/hookah_coal/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/G = W
		if(istype(W, /obj/item/reagent_containers/food/grown))
			G = W
			if(!G.dry)
				to_chat(user, SPAN("notice", "[G] must be dried before you stuff it into [src]."))
				return
		else if(!istype(W, /obj/item/reagent_containers/food/tobacco))
			return
		if(smoketime)
			to_chat(user, SPAN("notice", "[src] is already packed."))
			return
		pulls_left = 40
		if(G.reagents)
			G.reagents.trans_to_obj(src, G.reagents.total_volume)
		SetName("[G.name]-packed [initial(name)]")
		qdel(G)
