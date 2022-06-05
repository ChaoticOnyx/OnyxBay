/datum/gear/drinks
	sort_category = "Food and Drinks"
	cost = 2

/datum/gear/drinks/absinthe
	display_name = "jailbreaker verte"
	path = /obj/item/reagent_containers/vessel/bottle/absinthe
	price = 10

/datum/gear/drinks/melonliquor
	display_name = "emeraldine melon liquor"
	path = /obj/item/reagent_containers/vessel/bottle/melonliquor
	price = 4

/datum/gear/drinks/bluecuracao
	display_name = "miss blue curacao"
	path = /obj/item/reagent_containers/vessel/bottle/bluecuracao
	price = 6

/datum/gear/drinks/grenadine
	display_name = "briar rose grenadine syrup"
	path = /obj/item/reagent_containers/vessel/bottle/grenadine
	price = 7

/datum/gear/drinks/pwine
	display_name = "warlock's velvet"
	path = /obj/item/reagent_containers/vessel/bottle/pwine
	price = 10

/datum/gear/drinks/absinthe
	display_name = "premium wine"
	path = /obj/item/reagent_containers/vessel/bottle/premiumwine
	price = 10

/datum/gear/food
	sort_category = "Food and Drinks"
	price = 6
	cost = 2

/datum/gear/food/lunchbox/common
	display_name = "lunchbox"
	path = /obj/item/storage/lunchbox/filled
	price = 0

/datum/gear/food/lunchbox/heart
	display_name = "heart lunchbox"
	path = /obj/item/storage/lunchbox/heart/filled

/datum/gear/food/lunchbox/cat
	display_name = "cat lunchbox"
	path = /obj/item/storage/lunchbox/cat/filled

/datum/gear/food/lunchbox/nt
	display_name = "nt lunchbox"
	path = /obj/item/storage/lunchbox/nt/filled

/datum/gear/food/lunchbox/nymph
	display_name = "diona nymph lunchbox"
	path = /obj/item/storage/lunchbox/nymph/filled

/datum/gear/food/lunchbox/cti
	display_name = "cti lunchbox"
	path = /obj/item/storage/lunchbox/cti/filled

/datum/gear/food/lunchbox/mars
	display_name = "mariner university lunchbox"
	path = /obj/item/storage/lunchbox/mars/filled

/datum/gear/flask
	sort_category = "Food and Drinks"
	display_name = "flask"
	path = /obj/item/reagent_containers/vessel/flask
	price = 5

/datum/gear/flask/New()
	..()
	gear_tweaks += new /datum/gear_tweak/reagents(lunchables_ethanol_reagents())

/datum/gear/flask/bar
	display_name = "bar flask"
	path = /obj/item/reagent_containers/vessel/flask/barflask
	price = 0

/datum/gear/flask/vacuum
	display_name = "vacuum flask"
	path = /obj/item/reagent_containers/vessel/flask/vacuumflask
	price = 0

/datum/gear/flask/lithium
	display_name = "lithium flask"
	path = /obj/item/reagent_containers/vessel/flask/lithium
	price = 8

/datum/gear/flask/shiny
	display_name = "shiny flask"
	path = /obj/item/reagent_containers/vessel/flask/shiny
	price = 10
