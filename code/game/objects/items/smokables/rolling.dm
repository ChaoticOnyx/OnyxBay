
////////////
// PAPERS //
////////////
/obj/item/rollingpaper
	name = "rolling paper"
	desc = "A sheet of thin paper."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig paper"
	throwforce = 0
	w_class = ITEM_SIZE_TINY
	throw_range = 1
	throw_speed = 3
	force = 0
	var/quality = ""

/obj/item/rollingpaper/cheap
	name = "rolling paper"
	desc = "A sheet of thin bleached paper. Looks uneven and smells like an old eggbox."
	icon_state = "papers_cheap"
	quality = "cheap"

/obj/item/rollingpaper/good
	name = "rolling paper"
	desc = "A sheet of thin unbleached paper. This one looks like it may end up being a big nice joint."
	icon_state = "papers_good"
	quality = "good"

/obj/item/rollingpaper/proc/roll_smokable(obj/item/reagent_containers/food/W, mob/user, is_cig = FALSE)
	var/obj/item/clothing/mask/smokable/cigarette/roll/R
	var/R_loc = loc
	var/roll_in_hands = FALSE
	if(ishuman(loc))
		R_loc = user.loc
		roll_in_hands = TRUE
	if(is_cig)
		if(quality == "cheap")
			R = new /obj/item/clothing/mask/smokable/cigarette/roll(R_loc)
		else if(quality == "good")
			R = new /obj/item/clothing/mask/smokable/cigarette/roll/good(R_loc)
		to_chat(user, SPAN("notice", "You roll a cigarette!"))
	else
		if(quality == "cheap")
			R = new /obj/item/clothing/mask/smokable/cigarette/roll/joint(R_loc)
		else if(quality == "good")
			R = new /obj/item/clothing/mask/smokable/cigarette/roll/joint/good(R_loc)
		R.desc += " Looks like it contains some [W]."
		to_chat(user, SPAN("notice", "You grind \the [W] and roll a joint!"))
	if(W.reagents)
		if(W.reagents.has_reagent(/datum/reagent/nutriment))
			W.reagents.del_reagent(/datum/reagent/nutriment)
		W.reagents.trans_to_obj(R, W.reagents.total_volume)
	R.add_fingerprint(user)
	qdel(src)
	qdel(W)
	if(roll_in_hands)
		user.pick_or_drop(R)

/obj/item/rollingpaper/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/reagent_containers/food/grown))
		var/obj/item/reagent_containers/food/grown/G = W
		if(!G.dry)
			to_chat(user, SPAN("notice", "[G] must be dried before you can grind and roll it."))
			return
		roll_smokable(W, user)
		return
	if(istype(W, /obj/item/reagent_containers/food/tobacco))
		roll_smokable(W, user, TRUE)
		return
	..()

/////////////
// TOBACCO //
/////////////
/obj/item/reagent_containers/food/tobacco // tobacco is a snack, tasty and delicious
	name = "tobacco pile"
	desc = "A small pile of dried and grinded herbs."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "tpile_generic"
	filling_color = "#7d5f46"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 0
	throwforce = 0
	w_class = ITEM_SIZE_TINY
	throw_range = 1

/obj/item/reagent_containers/food/tobacco/Initialize()
	. = ..()
	bitesize = 3

/obj/item/reagent_containers/food/tobacco/generic/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tobacco, 4)

/obj/item/reagent_containers/food/tobacco/cherry
	desc = "A small pile of dried and grinded herbs. Smells of cherries."
	icon_state = "tpile_cherry"

/obj/item/reagent_containers/food/tobacco/cherry/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tobacco, 3)
	reagents.add_reagent(/datum/reagent/nutriment/cherryjelly, 2)

/obj/item/reagent_containers/food/tobacco/menthol
	desc = "A small pile of dried and grinded herbs. Smells of mint."
	icon_state = "tpile_menthol"

/obj/item/reagent_containers/food/tobacco/menthol/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tobacco, 3)
	reagents.add_reagent(/datum/reagent/menthol, 2)

/obj/item/reagent_containers/food/tobacco/chocolate
	desc = "A small pile of dried and grinded herbs. Smells of cocoa."
	icon_state = "tpile_chocolate"

/obj/item/reagent_containers/food/tobacco/chocolate/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tobacco, 3)
	reagents.add_reagent(/datum/reagent/nutriment/coco, 2)

/obj/item/reagent_containers/food/tobacco/premium
	desc = "A small pile of evenly dried and finely grounded herbs. Smells of quality."
	icon_state = "tpile_premium"

/obj/item/reagent_containers/food/tobacco/premium/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tobacco/fine, 4)

/obj/item/reagent_containers/food/tobacco/contraband
	desc = "A suspicious pile of dried and grinded herbs. Smells of something barely legal."
	icon_state = "tpile_contraband"

/obj/item/reagent_containers/food/tobacco/contraband/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tobacco, 2)
	reagents.add_reagent(/datum/reagent/thc, 4)

// Packs
/obj/item/storage/tobaccopack
	name = "tobacco bag"
	desc = "A bag of tobacco."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state ="tobacco_generic"
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_TINY
	storage_slots = 10

/obj/item/storage/tobaccopack/generic
	name = "bag of StarLing Classic"
	desc = "A bag of tobacco."
	icon_state ="tobacco_generic"
	startswith = list(/obj/item/reagent_containers/food/tobacco/generic = 10)

/obj/item/storage/tobaccopack/cherry
	name = "bag of StarLing Cherry"
	desc = "A bag of cherry-flavored tobacco."
	icon_state ="tobacco_cherry"
	startswith = list(/obj/item/reagent_containers/food/tobacco/cherry = 10)

/obj/item/storage/tobaccopack/menthol
	name = "bag of StarLing Menthol"
	desc = "A bag of menthol-flavored tobacco."
	icon_state ="tobacco_menthol"
	startswith = list(/obj/item/reagent_containers/food/tobacco/menthol = 10)

/obj/item/storage/tobaccopack/chocolate
	name = "bag of StarLing Chocolate"
	desc = "A bag of chocolate-flavored tobacco."
	icon_state ="tobacco_chocolate"
	startswith = list(/obj/item/reagent_containers/food/tobacco/chocolate = 10)

/obj/item/storage/tobaccopack/premium
	name = "box of Admiral's Pipe"
	desc = "A small metal box of high-quality tobacco."
	icon_state ="tobacco_premium"
	startswith = list(/obj/item/reagent_containers/food/tobacco/premium = 10)

/obj/item/storage/tobaccopack/contraband
	name = "bag of Rawdmann's"
	desc = "A bag of... whatever is this."
	icon_state ="tobacco_contraband"
	startswith = list(/obj/item/reagent_containers/food/tobacco/contraband = 10)

///////////////////////////
//  HAND-ROLLS & JOINTS  //
///////////////////////////
/obj/item/clothing/mask/smokable/cigarette/roll
	name = "hand-rolled cigarette"
	desc = "A roll-your-own smokable."
	icon_state = "cigroll"
	item_state = "cigroll"
	type_butt = /obj/item/cigbutt/roll
	smoketime = 120
	chem_volume = 7.5
	filter_trans = 0.75
	filling = list()

/obj/item/clothing/mask/smokable/cigarette/roll/generate_lighting_message(obj/item/tool, mob/holder)
	if(!holder || !tool)
		return ..()
	if(src.loc != holder)
		return ..()

	if(isWelder(tool))
		return SPAN("notice", "[holder] looks like a real stoner after lighting \his [name] with \a [tool].")
	return ..()

/obj/item/clothing/mask/smokable/cigarette/roll/good
	desc = "A roll-your-own smokable made of high-quality paper."
	icon_state = "ciggoodroll"
	item_state = "ciggoodroll"
	type_butt = /obj/item/cigbutt/roll/good
	smoketime = 180

/obj/item/clothing/mask/smokable/cigarette/roll/joint
	name = "joint"
	desc = "A regular joint."
	icon_state = "jointoff"
	item_state = "jointoff"
	icon_on = "jointon"
	ember_state = ""
	type_butt = /obj/item/cigbutt/joint
	chem_volume = 10.0
	filter_trans = 0.9
	dynamic_icon = FALSE

/obj/item/clothing/mask/smokable/cigarette/roll/joint/good
	name = "joint"
	desc = "A high-quality joint."
	icon_state = "goodjointoff"
	item_state = "goodjointoff"
	icon_on = "goodjointon"
	type_butt = /obj/item/cigbutt/joint/good
	smoketime = 180

/obj/item/clothing/mask/smokable/cigarette/roll/joint/big
	name = "big joint"
	desc = "A big joint made of a regular sheet of paper."
	icon_state = "bigjointoff"
	item_state = "bigjointoff"
	icon_on = "bigjointon"
	chem_volume = 15.0
	smoketime = 240

/obj/item/cigbutt/roll
	name = "hand-rolled cigarette butt"
	desc = "A crumpled roll-your-own cigarette butt. Still has some burnt tobacco inside."
	icon_state = "cigbuttroll"

/obj/item/cigbutt/roll/good
	icon_state = "cigbuttgoodroll"

/obj/item/cigbutt/joint
	name = "joint butt"
	desc = "A crumpled joint butt. Still contains some burnt herbs inside."
	icon_state = "jointbutt"

/obj/item/cigbutt/joint/good
	icon_state = "goodjointbutt"

//////////////////////
//  LEGACY PREROLL  //
//////////////////////
/obj/item/clothing/mask/smokable/cigarette/spliff
	name = "spliff"
	desc = "What makes me happy? A big spliff!"
	icon_state = "spliffoff"
	item_state = "spliffoff"
	icon_on = "spliffon"
	ember_state = ""
	type_butt = /obj/item/cigbutt/spliffbutt
	throw_speed = 2
	smoketime = 120
	chem_volume = 15
	filter_trans = 1.0 // Smoke it all, b1tch!
	filling = list(/datum/reagent/thc = 12)
	dynamic_icon = FALSE

/obj/item/clothing/mask/smokable/cigarette/spliff/generate_lighting_message(obj/tool, mob/holder)
	if(!holder || !tool)
		return ..()
	if(src.loc != holder)
		return ..()

	if(isitem(tool))
		var/obj/item/I = tool
		if(isWelder(I))
			return SPAN("notice", "[holder] looks like a real stoner after lighting \his [name] with \a [tool].")
	return ..()

/obj/item/cigbutt/spliffbutt
	name = "spliff butt"
	desc = "Still contains some burnt weed inside."
	icon_state = "jointbutt"
