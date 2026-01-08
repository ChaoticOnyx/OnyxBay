///
/// Presets for /obj/item/reagent_containers/vessel/plastic
///

/obj/item/reagent_containers/vessel/plastic/limejuice
	name = "Lime Juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	item_state = "limejuice"
	startswith = list(/datum/reagent/drink/juice/lime)

/obj/item/reagent_containers/vessel/plastic/milk
	name = "milk bottle"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	item_state = "milk"
	center_of_mass = "x=16;y=9"
	w_class = ITEM_SIZE_NORMAL

	volume = 1.0 LITER
	amount_per_transfer_from_this = 25
	possible_transfer_amounts = "25;30;50;60;100;150;250;300;1000"

	startswith = list(/datum/reagent/drink/milk)

/obj/item/reagent_containers/vessel/plastic/soymilk
	name = "soymilk bottle"
	desc = "It's soy milk. White and nutritious... goodness?"
	icon_state = "soymilk"
	item_state = "soymilk"
	center_of_mass = "x=16;y=9"
	w_class = ITEM_SIZE_NORMAL

	volume = 1.0 LITER
	amount_per_transfer_from_this = 25
	possible_transfer_amounts = "25;30;50;60;100;150;250;300;1000"

	startswith = list(/datum/reagent/drink/milk/soymilk)

/obj/item/reagent_containers/vessel/plastic/waterbottle
	name = "bottled water"
	desc = "Pure drinking water, imported from the Martian poles."
	icon_state = "waterbottle"
	item_state = "waterbottle"
	center_of_mass = "x=15;y=8"
	startswith = list(/datum/reagent/water)

/obj/item/reagent_containers/vessel/plastic/waterbottle/fi4i
	name = "\improper FI4I water"
	desc = "Said to be NanoTrasen's finest water. In fact, it's just an expensive water container."
	icon_state = "fi4i"
	item_state = "waterbottle"
	center_of_mass = "x=17;y=9"

/obj/item/reagent_containers/vessel/plastic/cup
	name = "plastic cup"
	desc = "Typically encountered around water coolers. Be careful not to crush it!"
	icon_state = "water_cup"
	item_state = "water_cup"
	force = 1.0

	volume = 0.125 LITERS
	amount_per_transfer_from_this = 25
	possible_transfer_amounts = "25;30;50;100;125"

	matter = list(MATERIAL_PLASTIC = 100)
	center_of_mass = "x=16;y=12"
	filling_states = "50;100"
	lid_type = null
	can_flip = FALSE
	var/trash = /obj/item/trash/plastic_cup

	drop_sound = SFX_DROP_PAPERCUP
	pickup_sound = SFX_PICKUP_PAPERCUP

/obj/item/reagent_containers/vessel/plastic/cup/attack_self(mob/user)
	if(!trash)
		return ..()

	if(reagents?.total_volume)
		user.visible_message(SPAN_DANGER("[user] crushes \the [src] in their hand, spilling its contents on themselves!"),
						 	 SPAN_WARNING("You crush \the [src] and its contents spill out onto you!"))
		reagents.splash(user, reagents.total_volume)
	else
		user.visible_message(SPAN_NOTICE("[user] crushes \the [src] in their hand."),
							 SPAN_NOTICE("You crush \the [src]."))

	playsound(user.loc, pick('sound/items/cancrush1.ogg', 'sound/items/cancrush2.ogg'), 50, 1)
	var/obj/item/trash/plastic_cup/trash_item = new trash(get_turf(user))
	user.replace_item(src, trash_item, TRUE, TRUE)

obj/item/reagent_containers/vessel/plastic/cup/Crossed(atom/movable/AM)
	if(isobserver(AM))
		return

	if(!isliving(AM))
		visible_message(SPAN_WARNING("\The [src] is crushed by \the [AM]."))
	else
		var/mob/living/living_mob = AM
		if(living_mob.m_intent == M_WALK)
			return
		living_mob.visible_message(SPAN_WARNING("[living_mob] steps on \the [src], crushing it!"),
								   SPAN_WARNING("You step on \the [src], crushing it!"))

	if(reagents?.total_volume)
		reagents.splash(get_turf(src), reagents.total_volume)

	new /obj/item/trash/plastic_cup(get_turf(src))
	qdel(src)