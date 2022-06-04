/datum/gear/cane
	display_name = "cane"
	path = /obj/item/cane

/datum/gear/dice
	display_name = "dice pack"
	path = /obj/item/storage/pill_bottle/dice

/datum/gear/dice/nerd
	display_name = "dice pack (gaming)"
	path = /obj/item/storage/pill_bottle/dice_nerd

/datum/gear/cards
	display_name = "deck of cards"
	path = /obj/item/deck/cards

/datum/gear/tarot
	display_name = "deck of tarot cards"
	path = /obj/item/deck/tarot

/datum/gear/holder
	display_name = "card holder"
	path = /obj/item/deck/holder

/datum/gear/cardemon_pack
	display_name = "Cardemon booster pack"
	path = /obj/item/pack/cardemon

/datum/gear/spaceball_pack
	display_name = "Spaceball booster pack"
	path = /obj/item/pack/spaceball

/datum/gear/coffeecup
	display_name = "coffee cup"
	path = /obj/item/reagent_containers/vessel/mug
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/towel
	display_name = "towel"
	path = /obj/item/towel
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
	plushes["snail plush"] = /obj/item/toy/plushie/snail
	gear_tweaks += new /datum/gear_tweak/path(plushes)

/datum/gear/mirror
	display_name = "handheld mirror"
	path = /obj/item/mirror

/datum/gear/lipstick
	display_name = "lipstick selection"
	path = /obj/item/lipstick
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/comb
	display_name = "plastic comb"
	path = /obj/item/haircomb
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/smokingpipe
	display_name = "pipe, smoking"
	path = /obj/item/clothing/mask/smokable/pipe

/datum/gear/cornpipe
	display_name = "pipe, corn"
	path = /obj/item/clothing/mask/smokable/pipe/cobpipe

/datum/gear/ashtray
	display_name = "ashtray, plastic"
	path = /obj/item/material/ashtray/plastic

/datum/gear/cigars
	display_name = "fancy cigar case"
	path = /obj/item/storage/fancy/cigar
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
	path = /obj/item/storage/wallet
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/accessory/wallet_poly
	display_name = "wallet, polychromic"
	path = /obj/item/storage/wallet/poly
	cost = 2

/datum/gear/welding_cover
	display_name = "welding helmet covers selection"
	path = /obj/item/welding_cover/knight

/datum/gear/welding_cover/New()
	..()
	var/cover_type = list()
	cover_type["knight"] = /obj/item/welding_cover/knight
	cover_type["engie"]  = /obj/item/welding_cover/engie
	cover_type["demon"]  = /obj/item/welding_cover/demon
	cover_type["fancy"]  = /obj/item/welding_cover/fancy
	cover_type["carp"]   = /obj/item/welding_cover/carp
	cover_type["hockey"] = /obj/item/welding_cover/hockey
	cover_type["blue"]   = /obj/item/welding_cover/blue
	cover_type["flame"]  = /obj/item/welding_cover/flame
	cover_type["white"]  = /obj/item/welding_cover/white
	gear_tweaks += new /datum/gear_tweak/path(cover_type)

//Donator's Shop

/datum/gear/rubberducky
	display_name = "bike horn"
	path = /obj/item/bikehorn
	price = 25

/datum/gear/rubberducky
	display_name = "vuvuzela"
	path = /obj/item/bikehorn/vuvuzela
	price = 25

/datum/gear/rubberducky
	display_name = "rubber ducky"
	path = /obj/item/bikehorn/rubberducky
	price = 25

/datum/gear/champion
	display_name = "champion's belt"
	path = /obj/item/storage/belt/champion
	slot = slot_belt
	price = 20

/datum/gear/bedsheet_clown
	display_name = "clown's bedsheet"
	path = /obj/item/bedsheet/clown
	price = 10

/datum/gear/bedsheet_mime
	display_name = "mime's bedsheet"
	path = /obj/item/bedsheet/mime
	price = 10

/datum/gear/bedsheet_rainbow
	display_name = "rainbow's bedsheet"
	path = /obj/item/bedsheet/rainbow
	price = 10

/datum/gear/bosunwhistle
	display_name = "bosun's whistle"
	path = /obj/item/toy/bosunwhistle
	price = 75

/datum/gear/balloon
	display_name = "balloon"
	path = /obj/item/toy/balloon
	price = 100

/datum/gear/balloon/nanotrasen
	display_name = "'motivational' balloon"
	path = /obj/item/toy/balloon/nanotrasen
	price = 75

/datum/gear/spinningtoy
	display_name = "gravitational singularity"
	path = /obj/item/toy/spinningtoy
	price = 30
