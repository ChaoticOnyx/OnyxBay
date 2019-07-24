GLOBAL_DATUM_INIT(donations, /datum/donations, new)


/datum/donations
	var/list/items = list(
		"Free stuff" = list(
			/obj/item/weapon/reagent_containers/food/drinks/bottle/premiumvodka = 0,
			/obj/item/clothing/head/ushanka = 0,
		),
		"Very not free stuff" = list(
			/obj/item/toy/bosunwhistle = 1000, // This can make annoying sounds.
			/obj/item/toy/balloon = 750, // MOTHERFUCKING SYNDI
			/obj/item/toy/balloon/nanotrasen = 500, // ALL HAIL NT
			/obj/item/toy/spinningtoy = 250 // PRAISE LORD SINGULO
		),
		"Drinks" = list(
			/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe = 100,
			/obj/item/weapon/reagent_containers/food/drinks/bottle/melonliquor = 40,
			/obj/item/weapon/reagent_containers/food/drinks/bottle/bluecuracao = 60,
			/obj/item/weapon/reagent_containers/food/drinks/bottle/grenadine = 70,
			/obj/item/weapon/reagent_containers/food/drinks/bottle/pwine = 100,
			/obj/item/weapon/reagent_containers/food/drinks/bottle/premiumwine = 100
		),
		"Regular Hats" = list(
			/obj/item/clothing/head/kitty = 100,
			/obj/item/clothing/head/beret = 30,
			/obj/item/clothing/head/witchwig = 90,
			/obj/item/clothing/head/wizard/fake = 100,
			/obj/item/clothing/head/flatcap = 80,
			/obj/item/clothing/head/bearpelt = 200
		),
		"Masks" = list(
			/obj/item/clothing/mask/fakemoustache = 25,
			/obj/item/clothing/mask/horsehead = 50,
			/obj/item/clothing/mask/pig = 50,
			/obj/item/clothing/mask/skullmask = 100,
			/obj/item/clothing/mask/gas/plaguedoctor = 180,
			/obj/item/clothing/mask/gas/monkeymask = 180,
			/obj/item/clothing/mask/gas/owl_mask = 180
		),
		"Personal Stuff" = list(
			/obj/item/clothing/glasses/eyepatch = 130,
			/obj/item/weapon/cane = 130,
			/obj/item/weapon/reagent_containers/food/drinks/flask = 50,
			/obj/item/weapon/reagent_containers/food/drinks/flask/lithium = 75,
			/obj/item/weapon/reagent_containers/food/drinks/flask/shiny = 100,
			/obj/item/weapon/bikehorn/rubberducky = 200,
			/obj/item/weapon/storage/belt/champion = 200
		),
		"Shoes" = list(
			/obj/item/clothing/shoes/clown_shoes = 130,
			/obj/item/clothing/shoes/cyborg = 130,
			/obj/item/clothing/shoes/laceup = 130,
			/obj/item/clothing/shoes/sandal = 80,
			/obj/item/clothing/shoes/jackboots = 170
		),
		"Coats" = list(
			/obj/item/clothing/suit/pirate = 120,
			/obj/item/clothing/suit/cardborg = 50,
			/obj/item/clothing/under/captain_fly = 150,
			/obj/item/clothing/under/scratch = 200
		),
		"Jumpsuits" = list(
			/obj/item/clothing/under/rank/vice = 180,
			/obj/item/clothing/under/pirate = 130,
			/obj/item/clothing/under/waiter = 120,
			/obj/item/clothing/under/rank/centcom/officer = 390,
			/obj/item/clothing/under/color/rainbow = 130,
			/obj/item/clothing/under/suit_jacket = 130,
			/obj/item/clothing/under/suit_jacket/really_black = 130,
			/obj/item/clothing/under/schoolgirl = 130,
			/obj/item/clothing/under/syndicate/tacticool = 130,
			/obj/item/clothing/under/soviet = 130,
			/obj/item/clothing/under/kilt = 100,
			/obj/item/clothing/under/gladiator = 100,
			/obj/item/clothing/under/assistantformal = 100,
			/obj/item/clothing/under/psyche = 250,
			/obj/item/clothing/under/blackjumpskirt = 100
		),
		"Gloves" = list(
			/obj/item/clothing/gloves/color/white = 130,
			/obj/item/clothing/gloves/boxing = 120
		),
		"Special Stuff" = list(
			/obj/item/weapon/storage/backpack/santabag = 600,
			/obj/item/weapon/bedsheet/clown = 100,
			/obj/item/weapon/bedsheet/mime = 100,
			/obj/item/weapon/bedsheet/rainbow = 100
		)
	)

	var/database/db = new("donators.db")

	var/list/datum/donator_prize/prizes = list() // Prize list to display (NanoUI)
	var/list/datum/donator/donators = null // null until DB connection established

	var/spawn_period = 3000 // 5 minutes to acquire things, in 1/10th


/datum/donations/proc/meta_init()
	var/list/collectable_hats = typesof(/obj/item/clothing/head/collectable) - list(/obj/item/clothing/head/collectable) // 19 types
	src.items["Collectible Hats"] = list()
	for (var/type in collectable_hats)
		src.items["Collectible Hats"][type] = 50

	var/list/toy_figures = typesof(/obj/item/toy/figure) - list(/obj/item/toy/figure)
	toy_figures.Add(typesof(/obj/item/toy/prize) - list(/obj/item/toy/prize))
	src.items["Collectible Figures"] = list()
	for (var/type in toy_figures)
		src.items["Collectible Figures"][type] = 30

	var/list/plushies = typesof(/obj/item/toy/plushie) - list(/obj/item/toy/plushie)
	src.items["Plushies"] = list()
	for (var/type in plushies)
		src.items["Plushies"][type] = 60

	var/list/crayons = typesof(/obj/item/weapon/pen/crayon) - list(/obj/item/weapon/pen/crayon)
	src.items["Crayons"] = list()
	for (var/type in crayons)
		src.items["Crayons"][type] = 30
		if (type == /obj/item/weapon/pen/crayon/rainbow)
			src.items["Crayons"][type] = 80

	var/list/swimsuits = typesof(/obj/item/clothing/under/swimsuit) - list(/obj/item/clothing/under/swimsuit) // OwO whats this
	for (var/type in swimsuits)
		src.items["Jumpsuits"][type] = 100

	var/list/dresses = typesof(/obj/item/clothing/under/dress) - list(/obj/item/clothing/under/dress, /obj/item/clothing/under/dress/dress_cap, /obj/item/clothing/under/dress/dress_hr, /obj/item/clothing/under/dress/dress_hop)
	src.items["Dresses"] = list()
	for (var/type in dresses)
		src.items["Dresses"][type] = 125

/datum/donations/proc/ensure_init()
	var/static/already_run = 0
	var/static/list/datum/donator_prize/type_list_prizes = list() // type -> prize

	src.meta_init()

	if (already_run)
		return

	for (var/category in src.items)
		for (var/type in src.items[category])
			var/cost = src.items[category][type]
			var/datum/donator_prize/prize = new

			var/obj/virtual_object = new type

			prize.object = virtual_object
			prize.category = category
			prize.cost = cost

			src.prizes.Add(prize)
			type_list_prizes[type] = prize

	var/database/query/q = new({"
		CREATE TABLE IF NOT EXISTS donators (
			ckey TEXT NOT NULL,
			bought_for INT NOT NULL,
			type TEXT NOT NULL
	);"})
	q.Execute(GLOB.donations.db)

	establish_db_connection()
	if (dbcon && dbcon.IsConnected())
		src.donators = list()

		var/DBQuery/q1 = dbcon.NewQuery("SELECT ckey, current, total FROM donators")
		q1.Execute()

		while (q1.NextRow())
			var/datum/donator/donator = new

			donator.ckey = q1.item[1]
			donator.money = text2num(q1.item[2])
			donator.total = text2num(q1.item[3])

			var/database/query/q2 = new("SELECT type, bought_for FROM donators WHERE ckey=?", donator.ckey)
			if (q2.Execute(GLOB.donations.db))
				while (q2.NextRow())
					var/type_as_text = q2.GetColumn(1)
					var/bought_for = q2.GetColumn(2)

					var/type = text2path(type_as_text)
					if (!type || !type_list_prizes[type])
						world.log << "Donator rollback for [type_as_text] which was bought for [bought_for]"
						donator.full_refund(type_as_text, bought_for)
					else
						var/datum/donator_prize/prize = type_list_prizes[type]

						var/price_delta = bought_for - prize.cost
						var/still_available = 1
						if (price_delta > 0)
							world.log << "Donator rebalance for [type_as_text] which will refund [bought_for - price_delta]"
							donator.partial_refund(type_as_text, bought_for, prize.cost)
						else if (price_delta < 0)
							world.log << "Donator rollback for [type_as_text] which was bought for [bought_for]"
							donator.full_refund(type_as_text, bought_for)
							still_available = 0
						if (still_available)
							donator.available.Add(type_list_prizes[type])
							donator.unacquired.Add(type_list_prizes[type])
			donators[donator.ckey] = donator

	already_run = 1