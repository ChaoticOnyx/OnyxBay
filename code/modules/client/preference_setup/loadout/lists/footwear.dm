
/datum/gear/shoes
	sort_category = "Shoes"
	slot = slot_shoes

/datum/gear/shoes/color
	display_name = "shoes selection"
	path = /obj/item/clothing/shoes

/datum/gear/shoes/color/New()
	..()
	var/shoes = list()
	shoes += /obj/item/clothing/shoes/black
	shoes += /obj/item/clothing/shoes/blue
	shoes += /obj/item/clothing/shoes/brown
	shoes += /obj/item/clothing/shoes/laceup
	shoes += /obj/item/clothing/shoes/green
	shoes += /obj/item/clothing/shoes/leather
	shoes += /obj/item/clothing/shoes/orange
	shoes += /obj/item/clothing/shoes/purple
	shoes += /obj/item/clothing/shoes/rainbow
	shoes += /obj/item/clothing/shoes/red
	shoes += /obj/item/clothing/shoes/white
	shoes += /obj/item/clothing/shoes/yellow
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(shoes)

/datum/gear/shoes/sandal
	display_name = "sandals selection"
	path = /obj/item/clothing/shoes/sandal

/datum/gear/shoes/sandal/New()
	..()
	var/sandals = list()
	sandals += /obj/item/clothing/shoes/sandal
	sandals += /obj/item/clothing/shoes/sandal/color/black
	sandals += /obj/item/clothing/shoes/sandal/color/grey
	sandals += /obj/item/clothing/shoes/sandal/color/blue
	sandals += /obj/item/clothing/shoes/sandal/color/pink
	sandals += /obj/item/clothing/shoes/sandal/color/red
	sandals += /obj/item/clothing/shoes/sandal/color/green
	sandals += /obj/item/clothing/shoes/sandal/color/orange
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(sandals)

/datum/gear/shoes/jackboots
	display_name = "jackboots"
	path = /obj/item/clothing/shoes/cheapboots
	cost = 2

/datum/gear/shoes/workboots
	display_name = "workboots"
	path = /obj/item/clothing/shoes/cheapboots/work
	cost = 2

//
// Donator's shop
//

/datum/gear/shoes/clown_shoes
	display_name = "clown shoes"
	path = /obj/item/clothing/shoes/clown_shoes
	price = 18

/datum/gear/shoes/cyborg_shoes
	display_name = "cyborg shoes"
	path = /obj/item/clothing/shoes/cyborg
	price = 2

/datum/gear/shoes/swimmingfins
	display_name = "swimming fins"
	path = /obj/item/clothing/shoes/swimmingfins
	price = 5

/datum/gear/shoes/slippers
	display_name = "bunny slippers"
	path = /obj/item/clothing/shoes/slippers
	price = 5

/datum/gear/shoes/mime_shoes
	display_name = "mime shoes"
	path = /obj/item/clothing/shoes/mime
	price = 12
