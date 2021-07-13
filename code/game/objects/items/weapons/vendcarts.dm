/obj/item/weapon/vendcart
	name = "Generic Vending Cartridge"
	desc = "Bluespace box for storing and selling stuff."
	icon = 'icons/obj/vending.dmi'
	icon_state = "cube_a"
	force = 15
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	w_class = ITEM_SIZE_NORMAL
	var/rand_amount = FALSE
	var/list/legal = list()
	var/list/illegal = list()
	var/list/premium = list()
	var/list/product_records = list()

/obj/item/weapon/vendcart/Initialize(mapload)
	..()

	if(mapload)
		rand_amount = TRUE
	else
		rand_amount = FALSE

	BuildInventory()

/obj/item/weapon/vendcart/proc/BuildInventory()
	var/list/all_products = list(
		list(legal, CAT_NORMAL),
		list(illegal, CAT_HIDDEN),
		list(premium, CAT_COIN))

	for(var/current_list in all_products)
		var/category = current_list[2]

		for(var/entry in current_list[1])
			var/datum/stored_items/vending_products/product = new /datum/stored_items/vending_products(src, entry)
			product.price = 0
			product.category = category
			if(rand_amount)
				var/sum = current_list[1][entry]
				product.amount = sum ? max(0, sum - rand(0, round(sum * 1.5))) : 1
			else
				product.amount = current_list[1][entry] || 1

			product_records.Add(product)

//ASSISTANT
/obj/item/weapon/vendcart/assist
	name = "Mr.Grey's Cartridge"
	legal = list(
		/obj/item/device/assembly/prox_sensor = 5,
		/obj/item/device/assembly/igniter = 3,
		/obj/item/device/assembly/signaler = 4,
		/obj/item/weapon/wirecutters = 1,
		/obj/item/weapon/cartridge/signal = 4
	)

	illegal = list(
		/obj/item/device/flashlight = 5,
		/obj/item/device/assembly/timer = 2,
		/obj/item/device/assembly/voice = 2
	)

/obj/item/weapon/vendcart/antag
	name = "Syndie's Tools Cartridge"
	legal = list(
		/obj/item/device/assembly/prox_sensor = 5,
		/obj/item/device/assembly/signaler = 4,
		/obj/item/device/assembly/voice = 4,
		/obj/item/device/assembly/infra = 4,
		/obj/item/device/assembly/prox_sensor = 4,
		/obj/item/weapon/handcuffs = 8,
		/obj/item/device/flash = 4,
		/obj/item/weapon/cartridge/signal = 4,
		/obj/item/clothing/glasses/sunglasses = 4
	)

//BOOZEOMAT
/obj/item/weapon/vendcart/boozeomat
	name = "Booze-O-Mat Cartridge"
	legal = list(
		/obj/item/weapon/reagent_containers/food/drinks/glass2/vodkaglass = 10,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/shot = 10,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/dshot = 10,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/cocktail = 10,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/rocks = 10,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/wine = 10,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/cognac = 10,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/hurricane = 10,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/square = 10,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/shake = 10,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/mug = 10,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/pint = 10,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/bigmug = 10,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/carafe = 2,
		/obj/item/weapon/reagent_containers/food/drinks/coffeecup/metal = 10,
		/obj/item/weapon/reagent_containers/food/drinks/flask/barflask = 5,
		/obj/item/weapon/reagent_containers/food/drinks/flask/vacuumflask = 5,
		/obj/item/weapon/bottle_extra/pourer = 15,
		/obj/item/weapon/glass_extra/stick = 25,
		/obj/item/weapon/glass_extra/straw = 25,
		/obj/item/weapon/glass_extra/orange_slice = 25,
		/obj/item/weapon/glass_extra/lime_slice = 25,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/gin = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/specialwhiskey = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/tequilla = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/chacha = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/rum = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/melonliquor = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/bluecuracao = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/grenadine = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/herbal = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/wine = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/winewhite = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/winerose = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/winesparkling = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/small/beer = 15,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/small/ale = 15,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/small/darkbeer = 15,
		/obj/item/weapon/reagent_containers/food/drinks/cans/machpellabeer = 15,
		/obj/item/weapon/reagent_containers/food/drinks/cans/applecider = 15,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/cream = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/cola = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/space_up = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/space_mountain_wind = 5,
		/obj/item/weapon/reagent_containers/food/drinks/cans/sodawater = 15,
		/obj/item/weapon/reagent_containers/food/drinks/cans/tonic = 15,
		/obj/item/weapon/reagent_containers/food/drinks/cans/cola =15,
		/obj/item/weapon/reagent_containers/food/drinks/cans/colavanilla = 15,
		/obj/item/weapon/reagent_containers/food/drinks/cans/colacherry =15,
		/obj/item/weapon/reagent_containers/food/drinks/tea = 15,
		/obj/item/weapon/reagent_containers/food/drinks/ice = 10
	)

	illegal = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/premiumwine = 2,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/premiumvodka = 2,
		/obj/item/weapon/reagent_containers/food/drinks/cans/dopecola = 5,
		/obj/item/weapon/glass_extra/glassholder = 10
	)
//CIGS
/obj/item/weapon/vendcart/cigarette
	name = "SiggZ Cartridge"
	legal = list(
		/obj/item/weapon/storage/fancy/cigarettes = 5,
		/obj/item/weapon/storage/fancy/cigarettes/luckystars = 2,
		/obj/item/weapon/storage/fancy/cigarettes/jerichos = 2,
		/obj/item/weapon/storage/fancy/cigarettes/menthols = 2,
		/obj/item/weapon/storage/fancy/cigarettes/carcinomas = 2,
		/obj/item/weapon/storage/fancy/cigarettes/professionals = 2,
		/obj/item/weapon/storage/fancy/cigarettes/cigarello = 2,
		/obj/item/weapon/storage/fancy/cigarettes/cigarello/mint = 2,
		/obj/item/weapon/storage/fancy/cigarettes/cigarello/variety = 2,
		/obj/item/weapon/storage/box/matches = 10,
		/obj/item/weapon/flame/lighter/random = 5,
		/obj/item/weapon/storage/fancy/rollingpapers = 5,
		/obj/item/weapon/storage/fancy/rollingpapers/good = 3,
		/obj/item/weapon/storage/tobaccopack/generic = 2,
		/obj/item/weapon/storage/tobaccopack/menthol = 2,
		/obj/item/weapon/storage/tobaccopack/cherry = 2,
		/obj/item/weapon/storage/tobaccopack/chocolate = 2,
		/obj/item/clothing/mask/smokable/ecig/simple = 10,
		/obj/item/clothing/mask/smokable/ecig/util = 5,
		/obj/item/clothing/mask/smokable/ecig/deluxe = 1,
		/obj/item/weapon/reagent_containers/ecig_cartridge/med_nicotine = 10,
		/obj/item/weapon/reagent_containers/ecig_cartridge/high_nicotine = 5,
		/obj/item/weapon/reagent_containers/ecig_cartridge/orange = 5,
		/obj/item/weapon/reagent_containers/ecig_cartridge/mint = 5,
		/obj/item/weapon/reagent_containers/ecig_cartridge/watermelon = 5,
		/obj/item/weapon/reagent_containers/ecig_cartridge/grape = 5,
		/obj/item/weapon/reagent_containers/ecig_cartridge/lemonlime = 5,
		/obj/item/weapon/reagent_containers/ecig_cartridge/coffee = 5,
		/obj/item/weapon/reagent_containers/ecig_cartridge/blanknico = 2
	)

	illegal = list(
		/obj/item/weapon/flame/lighter/zippo = 4,
		/obj/item/weapon/storage/tobaccopack/contraband = 1
	)

	premium = list(
		/obj/item/weapon/storage/fancy/cigar = 5,
		/obj/item/weapon/storage/fancy/cigarettes/killthroat = 5,
		/obj/item/weapon/storage/tobaccopack/premium = 3,
		/obj/item/clothing/mask/smokable/pipe = 1
	)
//COFFEE
/obj/item/weapon/vendcart/coffee
	name = "StarDucks Cartridge"
	legal = list(
		/obj/item/weapon/reagent_containers/food/drinks/coffee = 25,
		/obj/item/weapon/reagent_containers/food/drinks/tea = 25,
		/obj/item/weapon/reagent_containers/food/drinks/h_chocolate = 25
	)

	illegal = list(
		/obj/item/weapon/reagent_containers/food/drinks/ice = 10
	)

//COLA
/obj/item/weapon/vendcart/cola
	name = "CoceCola Cartridge"
	legal = list(
		/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/colavanilla = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/colacherry = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/space_mountain_wind = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/starkist = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/space_up = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/iced_tea = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/grape_juice = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/red_mule = 5
	)

	illegal = list(
		/obj/item/weapon/reagent_containers/food/drinks/cans/thirteenloko = 5,
		/obj/item/weapon/reagent_containers/food/drinks/cans/dopecola = 5,
		/obj/item/weapon/reagent_containers/food/snacks/liquidfood = 6
	)

	premium = list(
		/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle/fi4i = 5
	)

//CONTAINERS
/obj/item/weapon/vendcart/containers
	name = "Containers Cartridge"
	legal = list(
		/obj/structure/closet/crate/freezer = 2,
		/obj/structure/closet = 3,
		/obj/structure/closet/crate = 3
	)
//DINNERWARE
/obj/item/weapon/vendcart/dinnerware
	name = "Dinnerware Cartridge"
	legal = list(
		/obj/item/weapon/tray = 8,
		/obj/item/weapon/material/kitchen/utensil/fork = 8,
		/obj/item/weapon/material/kitchen/utensil/knife = 8,
		/obj/item/weapon/material/kitchen/utensil/spoon = 8,
		/obj/item/weapon/material/knife/kitchen = 3,
		/obj/item/weapon/material/kitchen/rollingpin = 2,
		/obj/item/weapon/reagent_containers/food/drinks/pitcher = 2,
		/obj/item/weapon/reagent_containers/food/drinks/coffeecup = 8,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/carafe = 2,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/square = 8,
		/obj/item/clothing/suit/chef/classic = 2,
		/obj/item/weapon/storage/lunchbox = 3,
		/obj/item/weapon/storage/lunchbox/heart = 3,
		/obj/item/weapon/storage/lunchbox/cat = 3,
		/obj/item/weapon/storage/lunchbox/nt = 3,
		/obj/item/weapon/storage/lunchbox/mars = 3,
		/obj/item/weapon/storage/lunchbox/cti = 3,
		/obj/item/weapon/storage/lunchbox/nymph = 3,
		/obj/item/weapon/storage/lunchbox/syndicate = 3
	)

	illegal = list(
		/obj/item/weapon/material/knife/butch/kitchen = 2
	)
//ENGINEERING
/obj/item/weapon/vendcart/engineering
	name = "RTM Cartridge"
	legal = list(
		/obj/item/weapon/storage/belt/utility = 4,
		/obj/item/clothing/glasses/hud/standard/meson = 4,
		/obj/item/clothing/gloves/insulated = 4,
		/obj/item/weapon/screwdriver = 12,
		/obj/item/weapon/crowbar = 12,
		/obj/item/weapon/wirecutters = 12,
		/obj/item/device/multitool = 12,
		/obj/item/weapon/wrench = 12,
		/obj/item/device/t_scanner = 12,
		/obj/item/weapon/cell = 8,
		/obj/item/weapon/weldingtool = 8,
		/obj/item/clothing/head/welding = 8,
		/obj/item/weapon/light/tube = 10,
		/obj/item/weapon/stock_parts/scanning_module = 5,
		/obj/item/weapon/stock_parts/micro_laser = 5,
		/obj/item/weapon/stock_parts/matter_bin = 5,
		/obj/item/weapon/stock_parts/manipulator = 5,
		/obj/item/weapon/stock_parts/console_screen = 5,
		/obj/item/weapon/stock_parts/capacitor = 5
	)

	illegal = list(
		/obj/item/weapon/rcd = 1,
		/obj/item/weapon/rcd_ammo = 5
	)

//ENGIVEND
/obj/item/weapon/vendcart/engivend
	name = "Engi-Vend Cartridge"
	legal = list(
		/obj/item/clothing/glasses/hud/standard/meson = 2,
		/obj/item/device/multitool = 4,
		/obj/item/device/geiger = 4,
		/obj/item/weapon/airlock_electronics = 10,
		/obj/item/weapon/module/power_control = 10,
		/obj/item/weapon/airalarm_electronics = 10,
		/obj/item/weapon/cell = 10,
		/obj/item/clamp = 10
	)

	illegal = list(
		/obj/item/weapon/cell/high = 3
	)

	premium = list(
		/obj/item/weapon/storage/belt/utility = 3
	)

//FASHIONVEND
/obj/item/weapon/vendcart/fashionvend
	name = "Smashing Fashions Cartridge"
	legal = list(
		/obj/item/weapon/mirror = 8,
		/obj/item/weapon/haircomb = 8,
		/obj/item/clothing/glasses/monocle = 5,
		/obj/item/clothing/glasses/sunglasses = 5,
		/obj/item/weapon/lipstick = 3,
		/obj/item/weapon/lipstick/black = 3,
		/obj/item/weapon/lipstick/purple = 3,
		/obj/item/weapon/lipstick/jade = 3,
		/obj/item/weapon/storage/bouquet = 3,
		/obj/item/weapon/storage/wallet/poly = 2
	)

	illegal = list(
		/obj/item/clothing/glasses/eyepatch = 2,
		/obj/item/clothing/accessory/horrible = 2,
		/obj/item/clothing/under/monkey/color/random = 3
	)

	premium = list(
		/obj/item/clothing/mask/smokable/pipe = 3
	)

//FITNESS
/obj/item/weapon/vendcart/fitness
	name = "SweatMAX Cartridge"
	legal = list(
		/obj/item/weapon/reagent_containers/food/drinks/milk/smallcarton = 8,
		/obj/item/weapon/reagent_containers/food/drinks/milk/smallcarton/chocolate = 8,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/fitnessflask/proteinshake = 8,
		/obj/item/weapon/reagent_containers/food/drinks/glass2/fitnessflask = 8,
		/obj/item/weapon/reagent_containers/food/snacks/packaged/nutribar = 8,
		/obj/item/weapon/reagent_containers/food/snacks/liquidfood = 8,
		/obj/item/weapon/reagent_containers/pill/diet = 8,
		/obj/item/weapon/towel/random = 8
	)

	illegal = list(
		/obj/item/weapon/reagent_containers/syringe/steroid/packaged = 4
	)
//GAMES
/obj/item/weapon/vendcart/games
	name = "GCF Cartridge"
	legal = list(
		/obj/item/toy/blink = 5,
		/obj/item/toy/spinningtoy = 2,
		/obj/item/weapon/deck/cards = 5,
		/obj/item/weapon/deck/tarot = 5,
		/obj/item/weapon/pack/cardemon = 6,
		/obj/item/weapon/pack/spaceball = 6,
		/obj/item/weapon/storage/pill_bottle/dice_nerd = 5,
		/obj/item/weapon/storage/pill_bottle/dice = 5,
		/obj/item/weapon/storage/box/checkers = 2,
		/obj/item/weapon/storage/box/checkers/chess/red = 2,
		/obj/item/weapon/storage/box/checkers/chess = 2
	)

	illegal = list(
		/obj/item/weapon/reagent_containers/spray/waterflower = 2,
		/obj/item/weapon/storage/box/snappops = 3
	)
	premium = list(
		/obj/item/weapon/gun/projectile/revolver/capgun = 1,
		/obj/item/ammo_magazine/caps = 4
	)

//HYDRONUTRIENTS
/obj/item/weapon/vendcart/hydronutrients
	name = "NutriMax Cartridge"
	legal = list(
		/obj/item/weapon/reagent_containers/glass/bottle/eznutrient = 5,
		/obj/item/weapon/reagent_containers/glass/bottle/left4zed = 5,
		/obj/item/weapon/reagent_containers/glass/bottle/robustharvest = 5,
		/obj/item/weapon/reagent_containers/glass/bottle/mutogrow = 5,
		/obj/item/weapon/plantspray/pests = 20,
		/obj/item/weapon/reagent_containers/syringe = 5,
		/obj/item/weapon/storage/plants = 5
	)

	illegal = list(
		/obj/item/weapon/reagent_containers/glass/bottle/ammonia = 10,
		/obj/item/weapon/reagent_containers/glass/bottle/diethylamine = 5,
		/obj/item/device/dociler = 1
	)
//MAGIVEND
/obj/item/weapon/vendcart/magivend
	name = "MagiVend Cartridge"
	legal = list(
		/obj/item/clothing/head/wizard = 1,
		/obj/item/clothing/suit/wizrobe = 1,
		/obj/item/clothing/head/wizard/red = 1,
		/obj/item/clothing/suit/wizrobe/red = 1,
		/obj/item/clothing/shoes/sandal = 1,
		/obj/item/weapon/staff = 2
	)

//MEDICAL
/obj/item/weapon/vendcart/medical
	name = "NanoMed Plus Cartridge"
	icon_state = "cube_b"
	legal = list(
		/obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/stoxin = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/toxin = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/spaceacillin = 2,
		/obj/item/weapon/reagent_containers/syringe = 12,
		/obj/item/device/healthanalyzer = 5,
		/obj/item/weapon/reagent_containers/glass/beaker = 4,
		/obj/item/weapon/reagent_containers/dropper = 2,
		/obj/item/stack/medical/advanced/bruise_pack = 3,
		/obj/item/stack/medical/advanced/ointment = 3,
		/obj/item/stack/medical/splint = 2,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/pain = 4
	)

	illegal = list(
		/obj/item/weapon/reagent_containers/pill/tox = 3,
		/obj/item/weapon/reagent_containers/pill/stox = 4,
		/obj/item/weapon/reagent_containers/pill/dylovene = 6,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/combatpain = 2
	)

//PLASMARESEARCH
/obj/item/weapon/vendcart/plasmaresearch
	name = "Toximate 3000 Cartridge"
	legal = list(
		/obj/item/clothing/suit/bio_suit = 6,
		/obj/item/clothing/head/bio_hood = 6,
		/obj/item/device/transfer_valve = 6,
		/obj/item/device/assembly/timer = 6,
		/obj/item/device/assembly/signaler = 6,
		/obj/item/device/assembly/voice = 6,
		/obj/item/device/assembly/prox_sensor = 6,
		/obj/item/device/assembly/igniter = 6
	)

//PROPS
/obj/item/weapon/vendcart/props
	name = "O'Props Cartridge"
	legal = list(
		/obj/structure/flora/pottedplant = 2,
		/obj/item/device/flashlight/lamp = 2,
		/obj/item/device/flashlight/lamp/green = 2,
		/obj/item/weapon/reagent_containers/food/drinks/jar = 1,
		/obj/item/weapon/nullrod = 1,
		/obj/item/toy/cultsword = 4,
		/obj/item/toy/katana = 2
	)
//ROBOTICS
/obj/item/weapon/vendcart/robotics
	name = "Robotech Deluxe Cartridge"
	legal = list(
		/obj/item/stack/cable_coil = 4,
		/obj/item/device/flash/synthetic = 4,
		/obj/item/weapon/cell = 4,
		/obj/item/device/healthanalyzer = 2,
		/obj/item/device/robotanalyzer = 2,
		/obj/item/weapon/scalpel = 1,
		/obj/item/weapon/circular_saw = 1,
		/obj/item/weapon/tank/anesthetic = 2,
		/obj/item/clothing/mask/breath/medical = 5,
		/obj/item/weapon/screwdriver = 2,
		/obj/item/weapon/crowbar = 2
	)

	illegal = list(
		/obj/item/device/flash = 2
	)
//SECURITY
/obj/item/weapon/vendcart/security
	name = "SecTech Cartridge"
	legal = list(
		/obj/item/weapon/handcuffs = 8,
		/obj/item/weapon/grenade/flashbang = 4,
		/obj/item/weapon/grenade/chem_grenade/teargas = 4,
		/obj/item/device/flash = 5,
		/obj/item/weapon/reagent_containers/food/snacks/donut/normal = 12,
		/obj/item/weapon/storage/box/evidence = 6
	)

	illegal = list(
		/obj/item/clothing/glasses/sunglasses = 2,
		/obj/item/weapon/storage/box/donut = 2
	)
//SNACK
/obj/item/weapon/vendcart/snack
	name = "Getmore Chocolate Cartridge"
	legal = list(
		/obj/item/weapon/reagent_containers/food/snacks/packaged/tweakers = 6,
		/obj/item/weapon/reagent_containers/food/snacks/packaged/sweetroid = 6,
		/obj/item/weapon/reagent_containers/food/snacks/packaged/sugarmatter = 6,
		/obj/item/weapon/reagent_containers/food/snacks/packaged/jellaws = 6,
		/obj/item/weapon/reagent_containers/food/drinks/dry_ramen = 6,
		/obj/item/weapon/reagent_containers/food/drinks/chickensoup = 6,
		/obj/item/weapon/reagent_containers/food/snacks/packaged/chips = 6,
		/obj/item/weapon/reagent_containers/food/snacks/packaged/sosjerky = 6,
		/obj/item/weapon/reagent_containers/food/snacks/packaged/no_raisin = 6,
		/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 6,
		/obj/item/weapon/reagent_containers/food/snacks/packaged/cheesiehonkers = 6,
		/obj/item/weapon/reagent_containers/food/snacks/packaged/tastybread = 6
	)

	illegal = list(
		/obj/item/weapon/reagent_containers/food/snacks/packaged/syndicake = 6,
		/obj/item/weapon/reagent_containers/food/snacks/packaged/skrellsnacks = 3
	)

/obj/item/weapon/vendcart/medbay
	name = "Getmore Healthy Cartridge"
	legal = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 10,
		/obj/item/weapon/reagent_containers/food/snacks/packaged/hematogen = 10,
		/obj/item/weapon/reagent_containers/food/snacks/packaged/nutribar = 10,
		/obj/item/weapon/reagent_containers/food/snacks/packaged/no_raisin = 10,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange = 10,
		/obj/item/weapon/reagent_containers/food/snacks/packaged/tastybread = 10
	)

	illegal = list(
		/obj/item/weapon/reagent_containers/food/snacks/cannabar = 3,
		/obj/item/weapon/reagent_containers/food/snacks/packaged/skrellsnacks = 3
	)

//SODA TODO: Russian soda can & Russian cola can
/obj/item/weapon/vendcart/sovietsoda
	name = "BODA Cartridge"
	legal = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/space_up = 30
	)

	illegal = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/cola = 20
	)

//TOOL
/obj/item/weapon/vendcart/tool
	name = "YouTool Cartridge"
	legal = list(
		/obj/item/stack/cable_coil/random = 10,
		/obj/item/weapon/crowbar = 5,
		/obj/item/weapon/weldingtool = 3,
		/obj/item/weapon/wirecutters = 5,
		/obj/item/weapon/wrench = 5,
		/obj/item/device/analyzer = 5,
		/obj/item/device/t_scanner = 5,
		/obj/item/weapon/screwdriver = 5,
		/obj/item/device/flashlight/glowstick = 3,
		/obj/item/device/flashlight/glowstick/red = 3
	)

	illegal = list(
		/obj/item/weapon/weldingtool/hugetank = 2,
		/obj/item/clothing/gloves/insulated/cheap = 2
	)

	premium = list(
		/obj/item/clothing/gloves/insulated = 1
	)

//WALLMED
/obj/item/weapon/vendcart/wallmed1
	name = "NanoMed Cartridge"
	icon_state = "cube_b"
	legal = list(
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector = 4
	)

	illegal = list(
		/obj/item/weapon/reagent_containers/syringe/antitoxin/packaged = 4,
		/obj/item/weapon/reagent_containers/syringe/antiviral/packaged = 4,
		/obj/item/weapon/reagent_containers/pill/tox = 1
	)

/obj/item/weapon/vendcart/wallmed2
	name = "NanoMed Mini Cartridge"
	icon_state = "cube_b"
	legal = list(
		/obj/item/weapon/reagent_containers/hypospray/autoinjector = 5,
		/obj/item/weapon/reagent_containers/syringe/antitoxin/packaged = 1,
		/obj/item/stack/medical/bruise_pack = 3,
		/obj/item/stack/medical/ointment =3
	)

	illegal = list(
		/obj/item/weapon/reagent_containers/pill/tox = 3,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/pain = 2
	)
//SEEDS
/obj/item/weapon/vendcart/seed_storage
	name = "O'Seedz Cartridge"
	icon_state = "cube_c"
	var/list/piles = list()

/obj/item/weapon/vendcart/seed_storage/Initialize()
	..()
	for(var/typepath in legal)
		var/amount = legal[typepath]
		if(isnull(amount))
			amount = 1
		for (var/i = 1 to amount)
			var/O = new typepath
			add(O)

/obj/item/weapon/vendcart/seed_storage/proc/add(obj/item/seeds/O as obj)
	O.loc = src
	var/newID = 0

	for (var/datum/seed_pile/N in piles)
		if (N.matches(O))
			++N.amount
			N.seeds += (O)
			return
		else if(N.ID >= newID)
			newID = N.ID + 1

	piles += new /datum/seed_pile(O, newID)
	return

/obj/item/weapon/vendcart/seed_storage/garden
	desc = "Bluespace box for storing and selling stuff. This one has garden seeds inside."
	legal = list(
		/obj/item/seeds/appleseed = 5,
		/obj/item/seeds/bananaseed = 5,
		/obj/item/seeds/berryseed = 5,
		/obj/item/seeds/blueberryseed = 5,
		/obj/item/seeds/cabbageseed = 5,
		/obj/item/seeds/carrotseed = 5,
		/obj/item/seeds/cherryseed = 5,
		/obj/item/seeds/chiliseed = 5,
		/obj/item/seeds/cocoapodseed = 5,
		/obj/item/seeds/cornseed = 5,
		/obj/item/seeds/peanutseed = 5,
		/obj/item/seeds/eggplantseed = 5,
		/obj/item/seeds/grapeseed = 5,
		/obj/item/seeds/grassseed = 5,
		/obj/item/seeds/harebell = 5,
		/obj/item/seeds/lavenderseed = 5,
		/obj/item/seeds/lemonseed = 5,
		/obj/item/seeds/limeseed = 5,
		/obj/item/seeds/mtearseed = 5,
		/obj/item/seeds/orangeseed = 5,
		/obj/item/seeds/plumpmycelium = 5,
		/obj/item/seeds/poppyseed = 5,
		/obj/item/seeds/potatoseed = 5,
		/obj/item/seeds/onionseed = 5,
		/obj/item/seeds/garlicseed = 5,
		/obj/item/seeds/pumpkinseed = 5,
		/obj/item/seeds/reishimycelium = 5,
		/obj/item/seeds/riceseed = 5,
		/obj/item/seeds/soyaseed = 5,
		/obj/item/seeds/peppercornseed = 5,
		/obj/item/seeds/sugarcaneseed = 5,
		/obj/item/seeds/sunflowerseed = 5,
		/obj/item/seeds/shandseed = 5,
		/obj/item/seeds/tobaccoseed = 5,
		/obj/item/seeds/tomatoseed = 5,
		/obj/item/seeds/towermycelium = 5,
		/obj/item/seeds/watermelonseed = 5,
		/obj/item/seeds/wheatseed = 5,
		/obj/item/seeds/whitebeetseed = 5
	)

/obj/item/weapon/vendcart/seed_storage/xenobotany
	desc = "Bluespace box for storing and selling stuff. This one has xenobotany seeds inside."
	legal = list(
		/obj/item/seeds/appleseed = 5,
		/obj/item/seeds/greenappleseed = 5,
		/obj/item/seeds/yellowappleseed = 5,
		/obj/item/seeds/bananaseed = 10,
		/obj/item/seeds/berryseed = 10,
		/obj/item/seeds/blueberryseed = 10,
		/obj/item/seeds/cabbageseed = 10,
		/obj/item/seeds/carrotseed = 10,
		/obj/item/seeds/cannabisseed = 10,
		/obj/item/seeds/chantermycelium = 10,
		/obj/item/seeds/cherryseed = 10,
		/obj/item/seeds/chiliseed = 10,
		/obj/item/seeds/cocoapodseed = 10,
		/obj/item/seeds/coconutseed = 10,
		/obj/item/seeds/cornseed = 10,
		/obj/item/seeds/peanutseed = 10,
		/obj/item/seeds/replicapod = 10,
		/obj/item/seeds/eggplantseed = 10,
		/obj/item/seeds/amanitamycelium = 10,
		/obj/item/seeds/glowshroom = 10,
		/obj/item/seeds/grapeseed = 10,
		/obj/item/seeds/grassseed = 10,
		/obj/item/seeds/harebell = 10,
		/obj/item/seeds/kudzuseed = 10,
		/obj/item/seeds/lavenderseed = 10,
		/obj/item/seeds/lemonseed = 10,
		/obj/item/seeds/libertymycelium = 10,
		/obj/item/seeds/limeseed = 10,
		/obj/item/seeds/mtearseed = 10,
		/obj/item/seeds/nettleseed = 10,
		/obj/item/seeds/orangeseed = 10,
		/obj/item/seeds/plastiseed = 10,
		/obj/item/seeds/plumpmycelium = 10,
		/obj/item/seeds/poppyseed = 10,
		/obj/item/seeds/potatoseed = 10,
		/obj/item/seeds/onionseed = 10,
		/obj/item/seeds/garlicseed = 10,
		/obj/item/seeds/pumpkinseed = 10,
		/obj/item/seeds/reishimycelium = 10,
		/obj/item/seeds/riceseed = 10,
		/obj/item/seeds/soyaseed = 10,
		/obj/item/seeds/peppercornseed = 10,
		/obj/item/seeds/sugarcaneseed = 10,
		/obj/item/seeds/sunflowerseed = 10,
		/obj/item/seeds/shandseed = 10,
		/obj/item/seeds/tobaccoseed = 10,
		/obj/item/seeds/tomatoseed = 10,
		/obj/item/seeds/towermycelium = 10,
		/obj/item/seeds/watermelonseed = 10,
		/obj/item/seeds/wheatseed = 10,
		/obj/item/seeds/whitebeetseed = 10,
		/obj/item/seeds/random = 10
	)

/obj/item/weapon/vendcart/seed_storage/random
	desc = "Bluespace box for storing and selling stuff. This one has random seeds inside."
	legal = list(
		/obj/item/seeds/random = 50
	)
