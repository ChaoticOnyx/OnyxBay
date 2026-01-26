
/obj/machinery/vending/boozeomat
	name = "Booze-O-Mat"
	desc = "A refrigerated vending unit for alcoholic beverages and alcoholic beverage accessories."

	icon = 'icons/obj/machines/vending/boozeomat.dmi'
	icon_state = "boozeomat"
	light_color = "#69A6C6"

	req_access = list(access_bar)

	vend_delay = 15
	use_vend_state = TRUE
	gen_rand_amount = FALSE
	idle_power_usage = 211 WATTS //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	product_slogans = "I hope nobody asks me for a bloody cup o' tea...;Alcohol is humanity's friend. Would you abandon a friend?;Quite delighted to serve you!;Is nobody thirsty on this station?"
	product_ads = "Drink up!;Booze is good for you!;Alcohol is humanity's best friend.;Quite delighted to serve you!;Care for a nice, cold beer?;Nothing cures you like booze!;Have a sip!;Have a drink!;Have a beer!;Beer is good for you!;Only the finest alcohol!;Best quality booze since 2053!;Award-winning wine!;Maximum alcohol!;Man loves beer.;A toast for progress!"

	vending_sound = SFX_VENDING_GENERIC

	component_types = list(
		/obj/item/vending_cartridge/boozeomat
		)

	legal = list(
		/obj/item/reagent_containers/vessel/glass/vodkaglass = 10,
		/obj/item/reagent_containers/vessel/glass/shot = 10,
		/obj/item/reagent_containers/vessel/glass/dshot = 10,
		/obj/item/reagent_containers/vessel/glass/cocktail = 10,
		/obj/item/reagent_containers/vessel/glass/rocks = 10,
		/obj/item/reagent_containers/vessel/glass/wine = 10,
		/obj/item/reagent_containers/vessel/glass/cognac = 10,
		/obj/item/reagent_containers/vessel/glass/hurricane = 10,
		/obj/item/reagent_containers/vessel/glass/square = 10,
		/obj/item/reagent_containers/vessel/glass/shake = 10,
		/obj/item/reagent_containers/vessel/glass/mug = 10,
		/obj/item/reagent_containers/vessel/glass/pint = 10,
		/obj/item/reagent_containers/vessel/glass/bigmug = 10,
		/obj/item/reagent_containers/vessel/glass/carafe = 2,
		/obj/item/reagent_containers/vessel/mug/metal = 10,
		/obj/item/reagent_containers/vessel/takeaway = 15,
		/obj/item/reagent_containers/vessel/flask/barflask = 5,
		/obj/item/reagent_containers/vessel/flask/vacuumflask = 5,
		/obj/item/bottle_extra/pourer = 15,
		/obj/item/glass_extra/cocktail_stick = 25,
		/obj/item/glass_extra/straw = 25,
		/obj/item/glass_extra/orange_slice = 25,
		/obj/item/glass_extra/lime_slice = 25,
		/obj/item/reagent_containers/vessel/bottle/gin = 5,
		/obj/item/reagent_containers/vessel/bottle/whiskey = 5,
		/obj/item/reagent_containers/vessel/bottle/specialwhiskey = 5,
		/obj/item/reagent_containers/vessel/bottle/tequilla = 5,
		/obj/item/reagent_containers/vessel/bottle/vodka = 5,
		/obj/item/reagent_containers/vessel/bottle/chacha = 5,
		/obj/item/reagent_containers/vessel/bottle/vermouth = 5,
		/obj/item/reagent_containers/vessel/bottle/rum = 5,
		/obj/item/reagent_containers/vessel/bottle/cognac = 5,
		/obj/item/reagent_containers/vessel/bottle/kahlua = 5,
		/obj/item/reagent_containers/vessel/bottle/melonliquor = 5,
		/obj/item/reagent_containers/vessel/bottle/bluecuracao = 5,
		/obj/item/reagent_containers/vessel/bottle/grenadine = 5,
		/obj/item/reagent_containers/vessel/bottle/herbal = 5,
		/obj/item/reagent_containers/vessel/bottle/absinthe = 5,
		/obj/item/reagent_containers/vessel/bottle/wine = 5,
		/obj/item/reagent_containers/vessel/bottle/winewhite = 5,
		/obj/item/reagent_containers/vessel/bottle/winerose = 5,
		/obj/item/reagent_containers/vessel/bottle/winesparkling = 5,
		/obj/item/reagent_containers/vessel/bottle/small/beer = 15,
		/obj/item/reagent_containers/vessel/bottle/small/ale = 15,
		/obj/item/reagent_containers/vessel/bottle/small/darkbeer = 15,
		/obj/item/reagent_containers/vessel/can/machpellabeer = 15,
		/obj/item/reagent_containers/vessel/can/applecider = 15,
		/obj/item/reagent_containers/vessel/carton/orangejuice = 5,
		/obj/item/reagent_containers/vessel/carton/tomatojuice = 5,
		/obj/item/reagent_containers/vessel/plastic/limejuice = 5,
		/obj/item/reagent_containers/vessel/carton/cream = 5,
		/obj/item/reagent_containers/vessel/bottle/cola = 5,
		/obj/item/reagent_containers/vessel/bottle/space_up = 5,
		/obj/item/reagent_containers/vessel/bottle/space_mountain_wind = 5,
		/obj/item/reagent_containers/vessel/can/sodawater = 15,
		/obj/item/reagent_containers/vessel/can/tonic = 15,
		/obj/item/reagent_containers/vessel/can/cola =15,
		/obj/item/reagent_containers/vessel/can/colavanilla = 15,
		/obj/item/reagent_containers/vessel/can/colacherry =15,
		/obj/item/reagent_containers/vessel/tea = 15,
		/obj/item/reagent_containers/vessel/ice = 10
		)

	illegal = list(
		/obj/item/reagent_containers/vessel/bottle/premiumwine = 2,
		/obj/item/reagent_containers/vessel/bottle/premiumvodka = 2,
		/obj/item/reagent_containers/vessel/can/dopecola = 5,
		/obj/item/glass_extra/glassholder = 10
		)

	premium = list(
		/obj/item/reagent_containers/vessel/bottle/pwine = 1,
		)

/obj/item/vending_cartridge/boozeomat
	icon_state = "refill_booze"
	build_path = /obj/machinery/vending/boozeomat
