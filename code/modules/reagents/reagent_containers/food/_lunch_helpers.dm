var/list/lunchables_lunches_ = list(
									/obj/item/reagent_containers/food/sandwich,
									/obj/item/reagent_containers/food/slice/meatbread/filled,
									/obj/item/reagent_containers/food/slice/tofubread/filled,
									/obj/item/reagent_containers/food/slice/creamcheesebread/filled,
									/obj/item/reagent_containers/food/slice/margherita/filled,
									/obj/item/reagent_containers/food/slice/meatpizza/filled,
									/obj/item/reagent_containers/food/slice/mushroompizza/filled,
									/obj/item/reagent_containers/food/slice/vegetablepizza/filled,
									/obj/item/reagent_containers/food/packaged/tastybread,
									/obj/item/reagent_containers/food/liquidfood,
									/obj/item/reagent_containers/food/jellysandwich/cherry,
									/obj/item/reagent_containers/food/tossedsalad
								  )

var/list/lunchables_snacks_ = list(
									/obj/item/reagent_containers/food/donut/jelly,
									/obj/item/reagent_containers/food/donut/cherryjelly,
									/obj/item/reagent_containers/food/muffin,
									/obj/item/reagent_containers/food/popcorn,
									/obj/item/reagent_containers/food/packaged/sosjerky,
									/obj/item/reagent_containers/food/packaged/tweakers,
									/obj/item/reagent_containers/food/packaged/no_raisin,
									/obj/item/reagent_containers/food/spacetwinkie,
									/obj/item/reagent_containers/food/packaged/cheesiehonkers,
									/obj/item/reagent_containers/food/poppypretzel,
									/obj/item/reagent_containers/food/carrotfries,
									/obj/item/reagent_containers/food/candiedapple,
									/obj/item/reagent_containers/food/applepie,
									/obj/item/reagent_containers/food/cherrypie,
									/obj/item/reagent_containers/food/plumphelmetbiscuit,
									/obj/item/reagent_containers/food/appletart,
									/obj/item/reagent_containers/food/slice/carrotcake/filled,
									/obj/item/reagent_containers/food/slice/cheesecake/filled,
									/obj/item/reagent_containers/food/slice/plaincake/filled,
									/obj/item/reagent_containers/food/slice/orangecake/filled,
									/obj/item/reagent_containers/food/slice/limecake/filled,
									/obj/item/reagent_containers/food/slice/lemoncake/filled,
									/obj/item/reagent_containers/food/slice/chocolatecake/filled,
									/obj/item/reagent_containers/food/slice/birthdaycake/filled,
									/obj/item/reagent_containers/food/watermelonslice,
									/obj/item/reagent_containers/food/slice/applecake/filled,
									/obj/item/reagent_containers/food/slice/pumpkinpie/filled,
									/obj/item/reagent_containers/food/packaged/skrellsnacks
								   )

var/list/lunchables_drinks_ = list(
									/obj/item/reagent_containers/vessel/plastic/waterbottle,
									/obj/item/reagent_containers/vessel/can/cola,
									/obj/item/reagent_containers/vessel/can/space_mountain_wind,
									/obj/item/reagent_containers/vessel/can/dr_gibb,
									/obj/item/reagent_containers/vessel/can/starkist,
									/obj/item/reagent_containers/vessel/can/space_up,
									/obj/item/reagent_containers/vessel/can/lemon_lime,
									/obj/item/reagent_containers/vessel/can/iced_tea,
									/obj/item/reagent_containers/vessel/can/grape_juice,
									/obj/item/reagent_containers/vessel/can/tonic,
									/obj/item/reagent_containers/vessel/can/sodawater
								   )

// This default list is a bit different, it contains items we don't want
var/list/lunchables_drink_reagents_ = list(
											/datum/reagent/drink/nothing,
											/datum/reagent/drink/doctor_delight,
											/datum/reagent/drink/dry_ramen,
											/datum/reagent/drink/hell_ramen,
											/datum/reagent/drink/hot_ramen,
											/datum/reagent/drink/nuka_cola
										)

// This default list is a bit different, it contains items we don't want
var/list/lunchables_ethanol_reagents_ = list(
												/datum/reagent/ethanol/acid_spit,
												/datum/reagent/ethanol/atomicbomb,
												/datum/reagent/ethanol/beepsky_smash,
												/datum/reagent/ethanol/coffee,
												/datum/reagent/ethanol/hippies_delight,
												/datum/reagent/ethanol/hooch,
												/datum/reagent/ethanol/thirteenloko,
												/datum/reagent/ethanol/manhattan_proj,
												/datum/reagent/ethanol/neurotoxin,
												/datum/reagent/ethanol/pwine,
												/datum/reagent/ethanol/threemileisland,
												/datum/reagent/ethanol/toxins_special,
												/datum/reagent/ethanol/siegbrau,
												/datum/reagent/ethanol/shroombeer,
												/datum/reagent/ethanol/quas
											)

// Add reagent to [vacuum]-flask no need delete reagent from lunchables_ethanol_reagents_ it's works fine
var/list/additional_reagents = list(
										/datum/reagent/drink/tea,
										/datum/reagent/ethanol/coffee,
										/datum/reagent/drink/hot_coco,
										/datum/reagent/drink/milkshake
									)
/proc/lunchables_lunches()
	if(!(lunchables_lunches_[lunchables_lunches_[1]]))
		lunchables_lunches_ = init_lunchable_list(lunchables_lunches_)
	return lunchables_lunches_

/proc/lunchables_snacks()
	if(!(lunchables_snacks_[lunchables_snacks_[1]]))
		lunchables_snacks_ = init_lunchable_list(lunchables_snacks_)
	return lunchables_snacks_

/proc/lunchables_drinks()
	if(!(lunchables_drinks_[lunchables_drinks_[1]]))
		lunchables_drinks_ = init_lunchable_list(lunchables_drinks_)
	return lunchables_drinks_

/proc/lunchables_drink_reagents()
	if(!(lunchables_drink_reagents_[lunchables_drink_reagents_[1]]))
		lunchables_drink_reagents_ = init_lunchable_reagent_list(lunchables_drink_reagents_, /datum/reagent/drink)
	return lunchables_drink_reagents_

/proc/lunchables_ethanol_reagents()
	if(!(lunchables_ethanol_reagents_[lunchables_ethanol_reagents_[1]]))
		lunchables_ethanol_reagents_ = init_lunchable_reagent_list(lunchables_ethanol_reagents_, /datum/reagent/ethanol, additional_reagents)
	return lunchables_ethanol_reagents_

/proc/init_lunchable_list(list/lunches)
	. = list()
	for(var/lunch in lunches)
		var/obj/O = lunch
		.[initial(O.name)] = lunch
	return sortAssoc(.)

/proc/init_lunchable_reagent_list(list/banned_reagents, reagent_types, list/additional_reagents)
	. = list()
	for(var/reagent_type in subtypesof(reagent_types))

		if(reagent_type in banned_reagents)
			continue

		var/datum/reagent/reagent = reagent_type
		.[initial(reagent.name)] = reagent_type

	for(var/reagent_type in additional_reagents)
		if(!(reagent_type in .))

			var/datum/reagent/reagent = reagent_type
			.[initial(reagent.name)] = reagent_type

	return sortAssoc(.)
