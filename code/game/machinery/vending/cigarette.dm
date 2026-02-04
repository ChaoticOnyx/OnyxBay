
/obj/machinery/vending/cigarette
	name = "Cigarette machine" // OCD had to be uppercase to look nice with the new formating
	desc = "A specialized vending machine designed to contribute to your slow and uncomfortable death."

	icon = 'icons/obj/machines/vending/cigs.dmi'
	icon_state = "cigs"
	light_color = "#54A496"

	vend_delay = 30
	use_alt_icons = TRUE
	use_vend_state = TRUE
	alt_icons = list("cigs", "cigs_alt")
	product_slogans = "There's no better time to start smokin'.;\
		Smoke now, and win the adoration of your peers.;\
		They beat cancer centuries ago, so smoke away.;\
		If you're not smoking, you must be joking."
	product_ads = "Probably not bad for you!;\
		Don't believe the scientists!;\
		It's good for you!;\
		Don't quit, buy more!;\
		Smoke!;\
		Nicotine heaven.;\
		Best cigarettes since 2150.;\
		Award-winning cigarettes, all the best brands.;\
		Feeling temperamental? Try a Temperamento!;\
		Carcinoma Angels - go fuck yerself!;\
		Don't be so hard on yourself, kid. Smoke a Lucky Star!;\
		We understand the depressed, alcoholic cowboy in you. That's why we also smoke Jericho.;\
		Professionals. Better cigarettes for better people. Yes, better people.;\
		StarLing - look cool 'till you drool!"

	vending_sound = SFX_VENDING_DROP

	component_types = list(
		/obj/item/vending_cartridge/cigarette
		)

	legal = list(
		/obj/item/storage/fancy/cigarettes = 5,
		/obj/item/storage/fancy/cigarettes/luckystars = 2,
		/obj/item/storage/fancy/cigarettes/jerichos = 2,
		/obj/item/storage/fancy/cigarettes/menthols = 2,
		/obj/item/storage/fancy/cigarettes/carcinomas = 2,
		/obj/item/storage/fancy/cigarettes/professionals = 2,
		/obj/item/storage/fancy/cigarettes/cigarello = 2,
		/obj/item/storage/fancy/cigarettes/cigarello/mint = 2,
		/obj/item/storage/fancy/cigarettes/cigarello/variety = 2,
		/obj/item/storage/box/matches = 10,
		/obj/item/flame/lighter/random = 5,
		/obj/item/storage/fancy/rollingpapers = 5,
		/obj/item/storage/fancy/rollingpapers/good = 3,
		/obj/item/storage/tobaccopack/generic = 2,
		/obj/item/storage/tobaccopack/menthol = 2,
		/obj/item/storage/tobaccopack/cherry = 2,
		/obj/item/storage/tobaccopack/chocolate = 2,
		/obj/item/clothing/mask/smokable/ecig/simple = 10,
		/obj/item/clothing/mask/smokable/ecig/util = 5,
		/obj/item/clothing/mask/smokable/ecig/deluxe = 1,
		/obj/item/reagent_containers/ecig_cartridge/med_nicotine = 10,
		/obj/item/reagent_containers/ecig_cartridge/high_nicotine = 5,
		/obj/item/reagent_containers/ecig_cartridge/orange = 5,
		/obj/item/reagent_containers/ecig_cartridge/mint = 5,
		/obj/item/reagent_containers/ecig_cartridge/watermelon = 5,
		/obj/item/reagent_containers/ecig_cartridge/grape = 5,
		/obj/item/reagent_containers/ecig_cartridge/lemonlime = 5,
		/obj/item/reagent_containers/ecig_cartridge/coffee = 5,
		/obj/item/reagent_containers/ecig_cartridge/blanknico = 2,
		/obj/item/clothing/mask/smokable/ecig/disposable = 15
		)

	illegal = list(
		/obj/item/flame/lighter/zippo = 4,
		/obj/item/storage/tobaccopack/contraband = 1,
		/obj/item/storage/fancy/cigarettes/syndi_cigs/tricordrazine = 1
		)

	premium = list(
		/obj/item/storage/fancy/cigar = 5,
		/obj/item/storage/fancy/cigarettes/killthroat = 5,
		/obj/item/storage/tobaccopack/premium = 3,
		/obj/item/clothing/mask/smokable/pipe = 1,
		/obj/item/reagent_containers/vessel/hookah = 1
		)

	prices = list(
		/obj/item/storage/fancy/cigarettes = 45,
		/obj/item/storage/fancy/cigarettes/luckystars = 50,
		/obj/item/storage/fancy/cigarettes/jerichos = 65,
		/obj/item/storage/fancy/cigarettes/menthols = 55,
		/obj/item/storage/fancy/cigarettes/carcinomas = 65,
		/obj/item/storage/fancy/cigarettes/professionals = 70,
		/obj/item/storage/fancy/cigarettes/cigarello = 85,
		/obj/item/storage/fancy/cigarettes/cigarello/mint = 85,
		/obj/item/storage/fancy/cigarettes/cigarello/variety = 85,
		/obj/item/storage/box/matches = 3,
		/obj/item/flame/lighter/random = 10,
		/obj/item/storage/fancy/rollingpapers = 20,
		/obj/item/storage/fancy/rollingpapers/good = 35,
		/obj/item/storage/tobaccopack/generic = 35,
		/obj/item/storage/tobaccopack/menthol = 40,
		/obj/item/storage/tobaccopack/cherry = 50,
		/obj/item/storage/tobaccopack/chocolate = 50,
		/obj/item/clothing/mask/smokable/ecig/simple = 50,
		/obj/item/clothing/mask/smokable/ecig/util = 100,
		/obj/item/clothing/mask/smokable/ecig/deluxe = 250,
		/obj/item/reagent_containers/ecig_cartridge/med_nicotine = 15,
		/obj/item/reagent_containers/ecig_cartridge/high_nicotine = 15,
		/obj/item/reagent_containers/ecig_cartridge/orange = 15,
		/obj/item/reagent_containers/ecig_cartridge/mint = 15,
		/obj/item/reagent_containers/ecig_cartridge/watermelon = 15,
		/obj/item/reagent_containers/ecig_cartridge/grape = 15,
		/obj/item/reagent_containers/ecig_cartridge/lemonlime = 15,
		/obj/item/reagent_containers/ecig_cartridge/coffee = 15,
		/obj/item/reagent_containers/ecig_cartridge/blanknico = 15,
		/obj/item/clothing/mask/smokable/ecig/disposable = 25
		)

/obj/item/vending_cartridge/cigarette
	icon_state = "refill_smoke"
	build_path = /obj/machinery/vending/cigarette

/obj/machinery/vending/cigars  //////// cigars midcentury vend
	name = "Cigars midcentury machine" //OCD had to be uppercase to look nice with the new formating
	desc = "Classy vending machine designed to contribute to your slow and uncomfortable death with style."

	icon = 'icons/obj/machines/vending/cigs.dmi'
	icon_state = "cigars"
	light_color = COLOR_PALE_BLUE_GRAY

	vend_delay = 21
	use_vend_state = TRUE
	product_slogans = "There's no better time to start smokin'.;\
		Smoke now, and win the adoration of your peers.;\
		They beat cancer centuries ago, so smoke away.;\
		If you're not smoking, you must be joking."
	product_ads = "Probably not bad for you!;\
		Don't believe the scientists!;\
		It's good for you!;\
		Don't quit, buy more!;\
		Smoke!;\
		Nicotine heaven.;\
		Best cigarettes since 2150.;\
		Award-winning cigarettes, all the best brands.;\
		Feeling temperamental? Try a Temperamento!;\
		Carcinoma Angels - go fuck yerself!;\
		Don't be so hard on yourself, kid. Smoke a Lucky Star!;\
		We understand the depressed, alcoholic cowboy in you. That's why we also smoke Jericho.;\
		Professionals. Better cigarettes for better people. Yes, better people.;\
		StarLing - look cool 'till you drool!"

	component_types = list(
		/obj/item/vending_cartridge/cigars
		)

	legal = list(
		/obj/item/storage/fancy/cigarettes = 5,
		/obj/item/storage/fancy/cigarettes/luckystars = 2,
		/obj/item/storage/fancy/cigarettes/jerichos = 2,
		/obj/item/storage/fancy/cigarettes/menthols = 2,
		/obj/item/storage/fancy/cigarettes/carcinomas = 2,
		/obj/item/storage/fancy/cigarettes/professionals = 2,
		/obj/item/storage/fancy/cigarettes/cigarello = 2,
		/obj/item/storage/fancy/cigarettes/cigarello/mint = 2,
		/obj/item/storage/fancy/cigarettes/cigarello/variety = 2,
		/obj/item/storage/box/matches = 10,
		/obj/item/flame/lighter/random = 5,
		/obj/item/storage/fancy/rollingpapers = 5,
		/obj/item/storage/fancy/rollingpapers/good = 3,
		/obj/item/storage/tobaccopack/generic = 2,
		/obj/item/storage/tobaccopack/menthol = 2,
		/obj/item/storage/tobaccopack/cherry = 2,
		/obj/item/storage/tobaccopack/chocolate = 2,
		/obj/item/clothing/mask/smokable/ecig/simple = 10,
		/obj/item/clothing/mask/smokable/ecig/util = 5,
		/obj/item/clothing/mask/smokable/ecig/deluxe = 1,
		/obj/item/reagent_containers/ecig_cartridge/med_nicotine = 10,
		/obj/item/reagent_containers/ecig_cartridge/high_nicotine = 5,
		/obj/item/reagent_containers/ecig_cartridge/orange = 5,
		/obj/item/reagent_containers/ecig_cartridge/mint = 5,
		/obj/item/reagent_containers/ecig_cartridge/watermelon = 5,
		/obj/item/reagent_containers/ecig_cartridge/grape = 5,
		/obj/item/reagent_containers/ecig_cartridge/lemonlime = 5,
		/obj/item/reagent_containers/ecig_cartridge/coffee = 5,
		/obj/item/reagent_containers/ecig_cartridge/blanknico = 2,
		/obj/item/clothing/mask/smokable/ecig/disposable = 15
		)

	illegal = list(
		/obj/item/flame/lighter/zippo = 4,
		/obj/item/storage/tobaccopack/contraband = 1,
		/obj/item/storage/fancy/cigarettes/syndi_cigs/tricordrazine = 1
		)

	premium = list(
		/obj/item/storage/fancy/cigar = 5,
		/obj/item/storage/fancy/cigarettes/killthroat = 5,
		/obj/item/storage/tobaccopack/premium = 3,
		/obj/item/clothing/mask/smokable/pipe = 1,
		/obj/item/reagent_containers/vessel/hookah = 1
		)

	prices = list(
		/obj/item/storage/fancy/cigarettes = 45,
		/obj/item/storage/fancy/cigarettes/luckystars = 50,
		/obj/item/storage/fancy/cigarettes/jerichos = 65,
		/obj/item/storage/fancy/cigarettes/menthols = 55,
		/obj/item/storage/fancy/cigarettes/carcinomas = 65,
		/obj/item/storage/fancy/cigarettes/professionals = 70,
		/obj/item/storage/fancy/cigarettes/cigarello = 85,
		/obj/item/storage/fancy/cigarettes/cigarello/mint = 85,
		/obj/item/storage/fancy/cigarettes/cigarello/variety = 85,
		/obj/item/storage/box/matches = 3,
		/obj/item/flame/lighter/random = 10,
		/obj/item/storage/fancy/rollingpapers = 20,
		/obj/item/storage/fancy/rollingpapers/good = 35,
		/obj/item/storage/tobaccopack/generic = 35,
		/obj/item/storage/tobaccopack/menthol = 40,
		/obj/item/storage/tobaccopack/cherry = 50,
		/obj/item/storage/tobaccopack/chocolate = 50,
		/obj/item/clothing/mask/smokable/ecig/simple = 50,
		/obj/item/clothing/mask/smokable/ecig/util = 100,
		/obj/item/clothing/mask/smokable/ecig/deluxe = 250,
		/obj/item/reagent_containers/ecig_cartridge/med_nicotine = 15,
		/obj/item/reagent_containers/ecig_cartridge/high_nicotine = 15,
		/obj/item/reagent_containers/ecig_cartridge/orange = 15,
		/obj/item/reagent_containers/ecig_cartridge/mint = 15,
		/obj/item/reagent_containers/ecig_cartridge/watermelon = 15,
		/obj/item/reagent_containers/ecig_cartridge/grape = 15,
		/obj/item/reagent_containers/ecig_cartridge/lemonlime = 15,
		/obj/item/reagent_containers/ecig_cartridge/coffee = 15,
		/obj/item/reagent_containers/ecig_cartridge/blanknico = 15,
		/obj/item/clothing/mask/smokable/ecig/disposable = 25
		)

/obj/item/vending_cartridge/cigars
	name = "cigars midcentury"
	build_path = /obj/machinery/vending/cigars
