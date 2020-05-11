/datum/gear/cane
	display_name = "cane"
	path = /obj/item/weapon/cane

/datum/gear/dice
	display_name = "dice pack"
	path = /obj/item/weapon/storage/pill_bottle/dice

/datum/gear/dice/nerd
	display_name = "dice pack (gaming)"
	path = /obj/item/weapon/storage/pill_bottle/dice_nerd

/datum/gear/cards
	display_name = "deck of cards"
	path = /obj/item/weapon/deck/cards

/datum/gear/tarot
	display_name = "deck of tarot cards"
	path = /obj/item/weapon/deck/tarot

/datum/gear/holder
	display_name = "card holder"
	path = /obj/item/weapon/deck/holder

/datum/gear/cardemon_pack
	display_name = "Cardemon booster pack"
	path = /obj/item/weapon/pack/cardemon

/datum/gear/spaceball_pack
	display_name = "Spaceball booster pack"
	path = /obj/item/weapon/pack/spaceball

/datum/gear/flask
	display_name = "flask"
	path = /obj/item/weapon/reagent_containers/food/drinks/flask
	price = 5

/datum/gear/flask/New()
	..()
	gear_tweaks += new /datum/gear_tweak/reagents(lunchables_ethanol_reagents())

/datum/gear/flask/bar
	display_name = "bar flask"
	path = /obj/item/weapon/reagent_containers/food/drinks/flask/barflask
	price = 0

/datum/gear/flask/vacuum
	display_name = "vacuum-flask"
	path = /obj/item/weapon/reagent_containers/food/drinks/flask/vacuumflask
	price = 0

/datum/gear/flask/lithium
	display_name = "lithium flask"
	path = /obj/item/weapon/reagent_containers/food/drinks/flask/lithium
	price = 8

/datum/gear/flask/shiny
	display_name = "shiny flask"
	path = /obj/item/weapon/reagent_containers/food/drinks/flask/shiny
	price = 10

/datum/gear/coffeecup
	display_name = "coffee cup"
	path = /obj/item/weapon/reagent_containers/food/drinks/coffeecup
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/boot_knife
	display_name = "boot knife"
	path = /obj/item/weapon/material/kitchen/utensil/knife/boot
	cost = 3

/datum/gear/lunchbox
	display_name = "lunchbox"
	description = "A little lunchbox."
	cost = 2
	path = /obj/item/weapon/storage/lunchbox

/datum/gear/lunchbox/New()
	..()
	var/list/lunchboxes = list()
	for(var/lunchbox_type in typesof(/obj/item/weapon/storage/lunchbox))
		var/obj/item/weapon/storage/lunchbox/lunchbox = lunchbox_type
		if(!initial(lunchbox.filled))
			lunchboxes[initial(lunchbox.name)] = lunchbox_type
	gear_tweaks += new /datum/gear_tweak/path(lunchboxes)
	gear_tweaks += new /datum/gear_tweak/contents(lunchables_lunches(), lunchables_snacks(), lunchables_drinks())

/datum/gear/towel
	display_name = "towel"
	path = /obj/item/weapon/towel
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/plush_toy
	display_name = "plush toy"
	description = "A plush toy."
	path = /obj/item/toy/plushie

/datum/gear/plush_toy/New()
	..()
	var/plushes = list()
	plushes["diona nymph plush"] = /obj/item/toy/plushie/nymph
	plushes["mouse plush"] = /obj/item/toy/plushie/mouse
	plushes["kitten plush"] = /obj/item/toy/plushie/kitten
	plushes["lizard plush"] = /obj/item/toy/plushie/lizard
	plushes["spider plush"] = /obj/item/toy/plushie/spider
	plushes["farwa plush"] = /obj/item/toy/plushie/farwa
	gear_tweaks += new /datum/gear_tweak/path(plushes)

/datum/gear/mirror
	display_name = "handheld mirror"
	path = /obj/item/weapon/mirror

/datum/gear/lipstick
	display_name = "lipstick selection"
	path = /obj/item/weapon/lipstick
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/comb
	display_name = "plastic comb"
	path = /obj/item/weapon/haircomb
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/smokingpipe
	display_name = "pipe, smoking"
	path = /obj/item/clothing/mask/smokable/pipe

/datum/gear/cornpipe
	display_name = "pipe, corn"
	path = /obj/item/clothing/mask/smokable/pipe/cobpipe

/datum/gear/matchbook
	display_name = "matchbook"
	path = /obj/item/weapon/storage/box/matches

/datum/gear/lighter
	display_name = "cheap lighter"
	path = /obj/item/weapon/flame/lighter

/datum/gear/zippo
	display_name = "zippo"
	path = /obj/item/weapon/flame/lighter/zippo

/datum/gear/ashtray
	display_name = "ashtray, plastic"
	path = /obj/item/weapon/material/ashtray/plastic

/datum/gear/cigars
	display_name = "fancy cigar case"
	path = /obj/item/weapon/storage/fancy/cigar
	cost = 2

/datum/gear/cigar
	display_name = "fancy cigar"
	path = /obj/item/clothing/mask/smokable/cigarette/cigar

/datum/gear/cigar/New()
	..()
	var/cigar_type = list()
	cigar_type["premium"] = /obj/item/clothing/mask/smokable/cigarette/cigar
	cigar_type["Cohiba Robusto"] = /obj/item/clothing/mask/smokable/cigarette/cigar/cohiba
	gear_tweaks += new /datum/gear_tweak/path(cigar_type)

/datum/gear/ecig
	display_name = "electronic cigarette"
	path = /obj/item/clothing/mask/smokable/ecig/util

/datum/gear/ecig/deluxe
	display_name = "electronic cigarette, deluxe"
	path = /obj/item/clothing/mask/smokable/ecig/deluxe
	cost = 2

/datum/gear/accessory/wallet
	display_name = "wallet, colour select"
	path = /obj/item/weapon/storage/wallet
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/accessory/wallet_poly
	display_name = "wallet, polychromic"
	path = /obj/item/weapon/storage/wallet/poly
	cost = 2

/datum/gear/rubberducky
	display_name = "rubber ducky"
	path = /obj/item/weapon/bikehorn/rubberducky
	price = 20

/datum/gear/champion
	display_name = "champion's belt"
	path = /obj/item/weapon/storage/belt/champion
	slot = slot_belt
	price = 20

/datum/gear/bedsheet_clown
	display_name = "clown's bedsheet"
	path = /obj/item/weapon/bedsheet/clown
	price = 10

/datum/gear/bedsheet_mime
	display_name = "mime's bedsheet"
	path = /obj/item/weapon/bedsheet/mime
	price = 10

/datum/gear/bedsheet_rainbow
	display_name = "rainbow's bedsheet"
	path = /obj/item/weapon/bedsheet/rainbow
	price = 10

/datum/gear/bosunwhistle
	display_name = "bosun's whistle"
	path = /obj/item/toy/bosunwhistle
	price = 100

/datum/gear/balloon
	display_name = "balloon"
	path = /obj/item/toy/balloon
	price = 75

/datum/gear/balloon/nanotrasen
	display_name = "'motivational' balloon"
	path = /obj/item/toy/balloon/nanotrasen
	price = 50

/datum/gear/spinningtoy
	display_name = "gravitational singularity"
	path = /obj/item/toy/spinningtoy
	price = 25
