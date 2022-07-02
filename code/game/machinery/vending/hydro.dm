
/obj/machinery/vending/hydronutrients
	name = "NutriMax"
	desc = "A plant nutrients vendor."
	product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	product_ads = "We like plants!;Don't you want some?;The greenest thumbs ever.;We like big plants.;Soft soil..."
	icon_state = "nutri"
	use_vend_state = TRUE
	gen_rand_amount = FALSE
	vend_delay = 26 SECONDS
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	component_types = list(/obj/item/vending_cartridge/hydronutrients)
	legal = list(	/obj/item/reagent_containers/vessel/plastic/eznutrient = 5,
					/obj/item/reagent_containers/vessel/plastic/left4zed = 5,
					/obj/item/reagent_containers/vessel/plastic/robustharvest = 5,
					/obj/item/reagent_containers/vessel/plastic/mutogrow = 5,
					/obj/item/plantspray/pests = 20,
					/obj/item/reagent_containers/syringe = 5,
					/obj/item/storage/plants = 5)
	premium = list(	/obj/item/reagent_containers/vessel/bottle/chemical/ammonia = 10,
					/obj/item/reagent_containers/vessel/bottle/chemical/diethylamine = 5)

/obj/item/vending_cartridge/hydronutrients
	name = "hydronutrients"
	build_path = /obj/machinery/vending/hydronutrients

/obj/machinery/vending/hydroseeds
	name = "MegaSeed Servitor"
	desc = "When you need seeds fast!"
	product_slogans = "THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;Hands down the best seed selection this half of the galaxy!;Also certain mushroom varieties available, more for experts! Get certified today!"
	product_ads = "We like plants!;Grow some crops!;Grow, baby, growww!;Aw h'yeah son!"
	icon_state = "seeds"
	use_vend_state = TRUE
	gen_rand_amount = FALSE
	vend_delay = 13 SECONDS
	component_types = list(/obj/item/vending_cartridge/hydroseeds)
	legal = list(	/obj/item/seeds/bananaseed = 3, /obj/item/seeds/berryseed = 3, /obj/item/seeds/carrotseed = 3, /obj/item/seeds/chantermycelium = 3, /obj/item/seeds/chiliseed = 3,
					/obj/item/seeds/cornseed = 3, /obj/item/seeds/eggplantseed = 3, /obj/item/seeds/potatoseed = 3, /obj/item/seeds/replicapod = 3, /obj/item/seeds/soyaseed = 3,
					/obj/item/seeds/sunflowerseed = 3, /obj/item/seeds/tomatoseed = 3, /obj/item/seeds/towermycelium = 3, /obj/item/seeds/wheatseed = 3, /obj/item/seeds/appleseed = 3,
					/obj/item/seeds/poppyseed = 3, /obj/item/seeds/sugarcaneseed = 3, /obj/item/seeds/ambrosiavulgarisseed = 3, /obj/item/seeds/peanutseed = 3, /obj/item/seeds/whitebeetseed = 3, /obj/item/seeds/watermelonseed = 3, /obj/item/seeds/limeseed = 3,
					/obj/item/seeds/lemonseed = 3, /obj/item/seeds/orangeseed = 3, /obj/item/seeds/grassseed = 3, /obj/item/seeds/cocoapodseed = 3, /obj/item/seeds/plumpmycelium = 2,
					/obj/item/seeds/cabbageseed = 3, /obj/item/seeds/grapeseed = 3, /obj/item/seeds/pumpkinseed = 3, /obj/item/seeds/cherryseed = 3, /obj/item/seeds/plastiseed = 3, /obj/item/seeds/riceseed = 3, /obj/item/seeds/lavenderseed = 3)
	illegal = list(	/obj/item/seeds/amanitamycelium = 2, /obj/item/seeds/glowshroom = 2, /obj/item/seeds/libertymycelium = 2, /obj/item/seeds/mtearseed = 2,
					/obj/item/seeds/nettleseed = 2, /obj/item/seeds/reishimycelium = 2, /obj/item/seeds/reishimycelium = 2, /obj/item/seeds/shandseed = 2, )
	premium = list(/obj/item/reagent_containers/spray/waterflower = 1)

/obj/item/vending_cartridge/hydroseeds
	name = "hydroseeds"
	build_path = /obj/machinery/vending/hydroseeds
