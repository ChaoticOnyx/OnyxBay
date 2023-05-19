
/obj/machinery/vending/dinnerware
	name = "Dinnerware"
	desc = "A kitchen and restaurant equipment vendor."
	product_ads = "Mm, food stuffs!;Food and food accessories.;Get your plates!;You like forks?;I like forks.;Woo, utensils.;You don't really need these..."
	icon_state = "dinnerware"
	use_vend_state = TRUE
	component_types = list(/obj/item/vending_cartridge/dinnerware)
	legal = list(	/obj/item/tray = 8,
					/obj/item/material/kitchen/utensil/fork = 8,
					/obj/item/material/kitchen/utensil/knife = 8,
					/obj/item/material/kitchen/utensil/spoon = 8,
					/obj/item/material/knife/kitchen = 3,
					/obj/item/material/kitchen/rollingpin = 2,
					/obj/item/reagent_containers/vessel/pitcher = 2,
					/obj/item/reagent_containers/vessel/mug = 8,
					/obj/item/reagent_containers/vessel/glass/carafe = 2,
					/obj/item/reagent_containers/vessel/glass/square = 8,
					/obj/item/clothing/suit/chef/classic = 2,
					/obj/item/storage/lunchbox = 3,
					/obj/item/storage/lunchbox/heart = 3,
					/obj/item/storage/lunchbox/cat = 3,
					/obj/item/storage/lunchbox/nt = 3,
					/obj/item/storage/lunchbox/mars = 3,
					/obj/item/storage/lunchbox/cti = 3,
					/obj/item/storage/lunchbox/nymph = 3,
					/obj/item/storage/lunchbox/syndicate = 3)
	illegal = list(/obj/item/material/knife/butch/kitchen = 2)

/obj/item/vending_cartridge/dinnerware
	name = "dinnerware"
	build_path = /obj/machinery/vending/dinnerware
