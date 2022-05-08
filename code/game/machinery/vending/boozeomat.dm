
/obj/machinery/vending/boozeomat
	name = "Booze-O-Mat"
	desc = "A refrigerated vending unit for alcoholic beverages and alcoholic beverage accessories."
	icon_state = "boozeomat"
	use_vend_state = TRUE
	products = list(/obj/item/reagent_containers/food/drinks/glass2/vodkaglass = 10,
					/obj/item/reagent_containers/food/drinks/glass2/shot = 10,
					/obj/item/reagent_containers/food/drinks/glass2/dshot = 10,
					/obj/item/reagent_containers/food/drinks/glass2/cocktail = 10,
					/obj/item/reagent_containers/food/drinks/glass2/rocks = 10,
					/obj/item/reagent_containers/food/drinks/glass2/wine = 10,
					/obj/item/reagent_containers/food/drinks/glass2/cognac = 10,
					/obj/item/reagent_containers/food/drinks/glass2/hurricane = 10,
					/obj/item/reagent_containers/food/drinks/glass2/square = 10,
					/obj/item/reagent_containers/food/drinks/glass2/shake = 10,
					/obj/item/reagent_containers/food/drinks/glass2/mug = 10,
					/obj/item/reagent_containers/food/drinks/glass2/pint = 10,
					/obj/item/reagent_containers/food/drinks/glass2/bigmug = 10,
					/obj/item/reagent_containers/food/drinks/glass2/carafe = 2,
					/obj/item/reagent_containers/vessel/mug/metal = 10,
					/obj/item/reagent_containers/food/drinks/flask/barflask = 5,
					/obj/item/reagent_containers/food/drinks/flask/vacuumflask = 5,
					/obj/item/bottle_extra/pourer = 15,
					/obj/item/glass_extra/stick = 25,
					/obj/item/glass_extra/straw = 25,
					/obj/item/glass_extra/orange_slice = 25,
					/obj/item/glass_extra/lime_slice = 25,
					/obj/item/reagent_containers/food/drinks/bottle/gin = 5,
					/obj/item/reagent_containers/food/drinks/bottle/whiskey = 5,
					/obj/item/reagent_containers/food/drinks/bottle/specialwhiskey = 5,
					/obj/item/reagent_containers/food/drinks/bottle/tequilla = 5,
					/obj/item/reagent_containers/food/drinks/bottle/vodka = 5,
					/obj/item/reagent_containers/food/drinks/bottle/chacha = 5,
					/obj/item/reagent_containers/food/drinks/bottle/vermouth = 5,
					/obj/item/reagent_containers/food/drinks/bottle/rum = 5,
					/obj/item/reagent_containers/food/drinks/bottle/cognac = 5,
					/obj/item/reagent_containers/food/drinks/bottle/kahlua = 5,
					/obj/item/reagent_containers/food/drinks/bottle/melonliquor = 5,
					/obj/item/reagent_containers/food/drinks/bottle/bluecuracao = 5,
					/obj/item/reagent_containers/food/drinks/bottle/grenadine = 5,
					/obj/item/reagent_containers/food/drinks/bottle/herbal = 5,
					/obj/item/reagent_containers/food/drinks/bottle/absinthe = 5,
					/obj/item/reagent_containers/food/drinks/bottle/wine = 5,
					/obj/item/reagent_containers/food/drinks/bottle/winewhite = 5,
					/obj/item/reagent_containers/food/drinks/bottle/winerose = 5,
					/obj/item/reagent_containers/food/drinks/bottle/winesparkling = 5,
					/obj/item/reagent_containers/food/drinks/bottle/small/beer = 15,
					/obj/item/reagent_containers/food/drinks/bottle/small/ale = 15,
					/obj/item/reagent_containers/food/drinks/bottle/small/darkbeer = 15,
					/obj/item/reagent_containers/food/drinks/cans/machpellabeer = 15,
					/obj/item/reagent_containers/food/drinks/cans/applecider = 15,
					/obj/item/reagent_containers/food/drinks/bottle/orangejuice = 5,
					/obj/item/reagent_containers/food/drinks/bottle/tomatojuice = 5,
					/obj/item/reagent_containers/food/drinks/bottle/limejuice = 5,
					/obj/item/reagent_containers/food/drinks/bottle/cream = 5,
					/obj/item/reagent_containers/food/drinks/bottle/cola = 5,
					/obj/item/reagent_containers/food/drinks/bottle/space_up = 5,
					/obj/item/reagent_containers/food/drinks/bottle/space_mountain_wind = 5,
					/obj/item/reagent_containers/food/drinks/cans/sodawater = 15,
					/obj/item/reagent_containers/food/drinks/cans/tonic = 15,
					/obj/item/reagent_containers/food/drinks/cans/cola =15,
					/obj/item/reagent_containers/food/drinks/cans/colavanilla = 15,
					/obj/item/reagent_containers/food/drinks/cans/colacherry =15,
					/obj/item/reagent_containers/food/drinks/tea = 15,
					/obj/item/reagent_containers/food/drinks/ice = 10)
	contraband = list(/obj/item/reagent_containers/food/drinks/bottle/premiumwine = 2,
					  /obj/item/reagent_containers/food/drinks/bottle/premiumvodka = 2,
				      /obj/item/reagent_containers/food/drinks/cans/dopecola = 5,
					  /obj/item/glass_extra/glassholder = 10)
	vend_delay = 15
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	product_slogans = "I hope nobody asks me for a bloody cup o' tea...;Alcohol is humanity's friend. Would you abandon a friend?;Quite delighted to serve you!;Is nobody thirsty on this station?"
	product_ads = "Drink up!;Booze is good for you!;Alcohol is humanity's best friend.;Quite delighted to serve you!;Care for a nice, cold beer?;Nothing cures you like booze!;Have a sip!;Have a drink!;Have a beer!;Beer is good for you!;Only the finest alcohol!;Best quality booze since 2053!;Award-winning wine!;Maximum alcohol!;Man loves beer.;A toast for progress!"
	req_access = list(access_bar)
