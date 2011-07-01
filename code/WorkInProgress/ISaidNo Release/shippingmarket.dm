// I wrote this so that the shipping prices would fluctuate for QMs to make the shipping budget thing more interesting.
// It's stored in a global variable and the gameticker takes care of the timing of it.

/datum/shipping_market

	var/list/commodities = new/list()
	var/time_between_shifts = 0.0
	var/time_until_shift = 0.0
	var/demand_multiplier = 2


	New()
		src.commodities += new /datum/commodity/electronics(src)
		src.commodities += new /datum/commodity/fruit/tomato(src)
		src.commodities += new /datum/commodity/fruit/orange(src)
		src.commodities += new /datum/commodity/fruit/grape(src)
		src.commodities += new /datum/commodity/fruit/melon(src)
		src.commodities += new /datum/commodity/fruit/banana(src)
		src.commodities += new /datum/commodity/fruit/apple(src)
		src.commodities += new /datum/commodity/fruit/carrot(src)
		src.commodities += new /datum/commodity/fruit/chili(src)
		src.commodities += new /datum/commodity/fruit/lemon(src)
		src.commodities += new /datum/commodity/fruit/lime(src)
		src.commodities += new /datum/commodity/fruit/potato(src)
		src.commodities += new /datum/commodity/fruit/pumpkin(src)
		src.commodities += new /datum/commodity/fruit/lettuce(src)
		src.commodities += new /datum/commodity/plant/asomna(src)
		src.commodities += new /datum/commodity/plant/commol(src)
		src.commodities += new /datum/commodity/plant/contusine(src)
		src.commodities += new /datum/commodity/plant/nureous(src)
		src.commodities += new /datum/commodity/plant/venne(src)
		src.commodities += new /datum/commodity/plant/wheat(src)
		src.commodities += new /datum/commodity/plant/sugar(src)
		src.commodities += new /datum/commodity/ore/mauxite(src)
		src.commodities += new /datum/commodity/ore/pharosium(src)
		src.commodities += new /datum/commodity/ore/molitz(src)
		src.commodities += new /datum/commodity/ore/char(src)
		src.commodities += new /datum/commodity/ore/cobryl(src)
		src.commodities += new /datum/commodity/ore/bohrum(src)
		src.commodities += new /datum/commodity/ore/claretine(src)
		src.commodities += new /datum/commodity/ore/erebite(src)
		src.commodities += new /datum/commodity/ore/cerenkite(src)
		src.commodities += new /datum/commodity/ore/plasmastone(src)
		src.commodities += new /datum/commodity/ore/syreline(src)
		src.commodities += new /datum/commodity/ore/cytine(src)
		src.commodities += new /datum/commodity/ore/uqill(src)
		src.commodities += new /datum/commodity/ore/telecrystal(src)
		src.commodities += new /datum/commodity/artifact(src)
		time_between_shifts = 6000 // Base of 10 minutes = 6000 milliseconds
		time_until_shift = time_between_shifts + rand(-900,900) // Fluctuation of three minutes

	proc/timeleft()
		var/timeleft = round(src.time_until_shift - (world.timeofday)/10 ,1)

		if(timeleft <= 0)
			market_shift()
			src.time_until_shift = round((world.timeofday + time_between_shifts + rand(-900,900)) / 10, 1)
			return 0

		return timeleft

	//Returns the time, in MM:SS format
	proc/get_market_timeleft()
		var/timeleft = src.timeleft()
		if(timeleft)
			return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"

	proc/market_shift()
		for (var/datum/commodity/C in src.commodities)
			C.indemand = 0 // Clear current in-demand products so we can set new ones later
			if (prob(90)) C.price += rand(C.lowerfluc,C.upperfluc) // Most of the time price fluctuates normally
			else
				var/multiplier = rand(2,4)
				C.price += rand(C.lowerfluc * multiplier,C.upperfluc * multiplier) // Sometimes it goes apeshit though!
			if (C.price < 0) C.price = 0 // No point in paying centcom to take your goods away
			if (prob(5)) C.price = C.baseprice // Small chance of a price being sent back to its original value

		if (prob(3)) src.demand_multiplier = rand(2,4) // Small chance of the multiplier of in-demand items being altered
		var/demands = rand(2,4) // How many goods are going to be in demand this time?
		while(demands > 0)
			var/datum/commodity/D = pick(src.commodities)
			if (D.price > 0) D.indemand = 1 // Goods that are in demand sell for a multiplied price
			demands--

/datum/commodity/
	var/comname = "commodity" // Name of the item on the market
	var/comtype = null // Type Path of the item on the market
	var/price = 0 // Current selling price for this commodity
	var/baseprice = 0 // Baseline selling price for this commodity
	var/onmarket = 1 // Whether this item is currently being accepted for sale
	var/indemand = 0 // Whether this item is currently being bought at a high price
	var/upperfluc = 0 // Highest this item's price can raise in one shift
	var/lowerfluc = 0 // Lowest this item's price can drop in one shift (negative numbers only)

/datum/commodity/electronics
	comname = "Electronic Parts"
	comtype = /obj/item/weapon/electronics/
	price = 10
	baseprice = 10
	upperfluc = 6
	lowerfluc = 2

/datum/commodity/fruit
	comname = "fruit"
	comtype = null
	price = 5
	baseprice = 5
	upperfluc = 2
	lowerfluc = 2

/datum/commodity/fruit/tomato
	comname = "Tomato"
	comtype = /obj/item/weapon/reagent_containers/food/snacks/plant/tomato

/datum/commodity/fruit/orange
	comname = "Orange"
	comtype = /obj/item/weapon/reagent_containers/food/snacks/plant/orange

/datum/commodity/fruit/grape
	comname = "Grape"
	comtype = /obj/item/weapon/reagent_containers/food/snacks/plant/grape

/datum/commodity/fruit/melon
	comname = "Melon"
	comtype = /obj/item/weapon/reagent_containers/food/snacks/plant/melon
	price = 8
	baseprice = 8
	upperfluc = 4
	lowerfluc = 4

/datum/commodity/fruit/apple
	comname = "Apple"
	comtype = /obj/item/weapon/reagent_containers/food/snacks/plant/apple

/datum/commodity/fruit/banana
	comname = "Banana"
	comtype = /obj/item/weapon/reagent_containers/food/snacks/plant/banana

/datum/commodity/fruit/lettuce
	comname = "Lettuce"
	comtype = /obj/item/weapon/reagent_containers/food/snacks/plant/lettuce

/datum/commodity/fruit/carrot
	comname = "Carrot"
	comtype = /obj/item/weapon/reagent_containers/food/snacks/plant/carrot

/datum/commodity/fruit/chili
	comname = "Chili Pepper"
	comtype = /obj/item/weapon/reagent_containers/food/snacks/plant/chili
	upperfluc = 5
	lowerfluc = 4

/datum/commodity/fruit/lemon
	comname = "Lemon"
	comtype = /obj/item/weapon/reagent_containers/food/snacks/plant/lemon

/datum/commodity/fruit/lime
	comname = "Lime"
	comtype = /obj/item/weapon/reagent_containers/food/snacks/plant/lime

/datum/commodity/fruit/potato
	comname = "Potato"
	comtype = /obj/item/weapon/reagent_containers/food/snacks/plant/potato
	price = 10
	baseprice = 10
	upperfluc = 1
	lowerfluc = 1

/datum/commodity/fruit/pumpkin
	comname = "Pumpkin"
	comtype = /obj/item/weapon/reagent_containers/food/snacks/plant/pumpkin

/datum/commodity/plant
	comname = "plant"
	comtype = null
	price = 7
	baseprice = 7
	upperfluc = 4
	lowerfluc = 3

/datum/commodity/plant/asomna
	comname = "Asomna Herb"
	comtype = /obj/item/weapon/plant/asomna

/datum/commodity/plant/commol
	comname = "Commol Herb"
	comtype = /obj/item/weapon/plant/commol

/datum/commodity/plant/contusine
	comname = "Contusine Herb"
	comtype = /obj/item/weapon/plant/contusine

/datum/commodity/plant/nureous
	comname = "Nureous Herb"
	comtype = /obj/item/weapon/plant/nureous

/datum/commodity/plant/venne
	comname = "Venne Herb"
	comtype = /obj/item/weapon/plant/venne

/datum/commodity/plant/wheat
	comname = "Wheat"
	comtype = /obj/item/weapon/plant/wheat
	price = 3
	baseprice = 3
	upperfluc = 1
	lowerfluc = 1

/datum/commodity/plant/sugar
	comname = "Sugar Cane"
	comtype = /obj/item/weapon/plant/sugar
	price = 5
	baseprice = 5
	upperfluc = 1
	lowerfluc = 1

/datum/commodity/ore
	comname = "ore"
	comtype = null
	price = 25
	baseprice = 25
	upperfluc = 5
	lowerfluc = 5

/datum/commodity/ore/mauxite
	comname = "Mauxite"
	comtype = /obj/item/weapon/ore/mauxite

/datum/commodity/ore/pharosium
	comname = "Pharosium"
	comtype = /obj/item/weapon/ore/pharosium

/datum/commodity/ore/char
	comname = "Char"
	comtype = /obj/item/weapon/ore/char

/datum/commodity/ore/molitz
	comname = "Molitz"
	comtype = /obj/item/weapon/ore/molitz

/datum/commodity/ore/cobryl
	comname = "Cobryl"
	comtype = /obj/item/weapon/ore/cobryl
	price = 60
	baseprice = 60
	upperfluc = 30
	lowerfluc = 30

/datum/commodity/ore/cytine
	comname = "Cytine"
	comtype = /obj/item/weapon/ore/cytine
	price = 75
	baseprice = 75
	upperfluc = 90
	lowerfluc = 90

/datum/commodity/ore/uqill
	comname = "Uqill"
	comtype = /obj/item/weapon/ore/uqill
	price = 100
	baseprice = 100
	upperfluc = 2
	lowerfluc = 2

/datum/commodity/ore/telecrystal
	comname = "Telecrystal"
	comtype = /obj/item/weapon/ore/telecrystal
	price = 200
	baseprice = 200
	upperfluc = 90
	lowerfluc = 100

/datum/commodity/ore/bohrum
	comname = "Bohrum"
	comtype = /obj/item/weapon/ore/bohrum
	price = 40
	baseprice = 40

/datum/commodity/ore/claretine
	comname = "Claretine"
	comtype = /obj/item/weapon/ore/claretine
	price = 40
	baseprice = 40

/datum/commodity/ore/erebite
	comname = "Erebite"
	comtype = /obj/item/weapon/ore/erebite
	price = 80
	baseprice = 80
	upperfluc = 80
	lowerfluc = 80

/datum/commodity/ore/cerenkite
	comname = "Cerenkite"
	comtype = /obj/item/weapon/ore/cerenkite
	price = 80
	baseprice = 80
	upperfluc = 40
	lowerfluc = 40

/datum/commodity/ore/plasmastone
	comname = "Plasmastone"
	comtype = /obj/item/weapon/ore/plasmastone
	price = 80
	baseprice = 80
	upperfluc = 5
	lowerfluc = 5

/datum/commodity/ore/syreline
	comname = "Syreline"
	comtype = /obj/item/weapon/ore/syreline
	price = 250
	baseprice = 250
	upperfluc = 30
	lowerfluc = 25

/datum/commodity/artifact
	comname = "Alien Artifacts"
	comtype = /obj/machinery/artifact
	price = 7500
	baseprice = 7500
	upperfluc = 2500
	lowerfluc = 2500