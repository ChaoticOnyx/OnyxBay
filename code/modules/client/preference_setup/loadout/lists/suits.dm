/datum/gear/suit
	slot = slot_wear_suit
	sort_category = "Suits"

/datum/gear/suit/poncho
	display_name = "poncho selection"
	path = /obj/item/clothing/suit/poncho/colored
	cost = 1
	subgroup = "Ponchos"
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/suit/security_poncho
	display_name = "poncho, security"
	path = /obj/item/clothing/suit/poncho/roles/security
	subgroup = "Ponchos"
	allowed_roles = SECURITY_ROLES

/datum/gear/suit/medical_poncho
	display_name = "poncho, medical"
	path = /obj/item/clothing/suit/poncho/roles/medical
	subgroup = "Ponchos"
	allowed_roles = MEDICAL_ROLES

/datum/gear/suit/engineering_poncho
	display_name = "poncho, engineering"
	path = /obj/item/clothing/suit/poncho/roles/engineering
	subgroup = "Ponchos"
	allowed_roles = ENGINEERING_ROLES

/datum/gear/suit/science_poncho
	display_name = "poncho, science"
	path = /obj/item/clothing/suit/poncho/roles/science
	subgroup = "Ponchos"
	allowed_roles = RESEARCH_ROLES

/datum/gear/suit/cargo_poncho
	display_name = "poncho, supply"
	path = /obj/item/clothing/suit/poncho/roles/cargo
	subgroup = "Ponchos"
	allowed_roles = CARGO_ROLES

/datum/gear/suit/suit_jacket
	display_name = "standard suit jackets"
	path = /obj/item/clothing/suit/storage/toggle/suit
	subgroup = "Jackets & Coats"

/datum/gear/suit/suit_jacket/New()
	..()
	var/suitjackets = list()
	suitjackets += /obj/item/clothing/suit/storage/toggle/suit/black
	suitjackets += /obj/item/clothing/suit/storage/toggle/suit/blue
	suitjackets += /obj/item/clothing/suit/storage/toggle/suit/purple
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(suitjackets)

/datum/gear/suit/custom_suit_jacket
	display_name = "suit jacket, colour select"
	path = /obj/item/clothing/suit/storage/toggle/suit
	subgroup = "Jackets & Coats"
	flags = GEAR_HAS_COLOR_SELECTION


/datum/gear/suit/varsity
	display_name = "varsity, various colors"
	path = /obj/item/clothing/suit/storage/toggle/varsity
	subgroup = "Jackets & Coats"

/datum/gear/suit/varsity/New()
	..()
	var/varsity = list()
	varsity += /obj/item/clothing/suit/storage/toggle/varsity
	varsity += /obj/item/clothing/suit/storage/toggle/varsity/blue
	varsity += /obj/item/clothing/suit/storage/toggle/varsity/red
	varsity += /obj/item/clothing/suit/storage/toggle/varsity/brown
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(varsity)

/datum/gear/suit/hazard
	display_name = "hazard vests"
	path = /obj/item/clothing/suit/storage/hazardvest
	subgroup = "Jackets & Coats"
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/suit/hoodie
	display_name = "hoodie, colour select"
	path = /obj/item/clothing/suit/storage/hooded/hoodie
	subgroup = "Jackets & Coats"
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/suit/ziphoodie
	display_name = "zip-up hoodie, colour select"
	path = /obj/item/clothing/suit/storage/hooded/toggle/hoodie
	subgroup = "Jackets & Coats"
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/suit/labcoat
	display_name = "labcoat, colour select"
	path = /obj/item/clothing/suit/storage/toggle/labcoat
	subgroup = "Jackets & Coats"
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/suit/coat
	display_name = "coat, colour select"
	path = /obj/item/clothing/suit/storage/toggle/labcoat/coat
	subgroup = "Jackets & Coats"
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/suit/leather
	display_name = "jacket selection"
	path = /obj/item/clothing/suit
	subgroup = "Jackets & Coats"

/datum/gear/suit/leather/New()
	..()
	var/jackets = list()
	jackets += /obj/item/clothing/suit/storage/toggle/bomber
	jackets += /obj/item/clothing/suit/storage/black_jacket_NT
	jackets += /obj/item/clothing/suit/storage/toggle/brown_jacket_NT
	jackets += /obj/item/clothing/suit/storage/leather_jacket
	jackets += /obj/item/clothing/suit/storage/toggle/brown_jacket
	jackets += /obj/item/clothing/suit/storage/mbill
	jackets += /obj/item/clothing/suit/storage/black_jacket_long
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(jackets)

/datum/gear/suit/wintercoat
	display_name = "winter coat"
	path = /obj/item/clothing/suit/storage/hooded/wintercoat
	subgroup = "Jackets & Coats"

/datum/gear/suit/track
	display_name = "track jacket selection"
	path = /obj/item/clothing/suit/storage/toggle/track
	subgroup = "Jackets & Coats"
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/suit/blueapron
	display_name = "apron, blue"
	path = /obj/item/clothing/suit/apron
	subgroup = "Workwear"
	cost = 1

/datum/gear/suit/overalls
	display_name = "apron, overalls"
	path = /obj/item/clothing/suit/apron/overalls
	subgroup = "Workwear"
	cost = 1

/datum/gear/suit/medcoat
	display_name = "medical suit selection"
	path = /obj/item/clothing/suit
	subgroup = "Workwear"

/datum/gear/suit/medcoat/New()
	..()
	gear_tweaks += new /datum/gear_tweak/path/specified_types_args(/obj/item/clothing/suit/storage/toggle/fr_jacket, /obj/item/clothing/suit/storage/toggle/labcoat/blue, /obj/item/clothing/suit/surgicalapron)

/datum/gear/suit/trenchcoat
	display_name = "trenchcoat selection"
	path = /obj/item/clothing/suit
	subgroup = "Jackets & Coats"
	cost = 3

/datum/gear/suit/trenchcoat/New()
	..()
	var/trenchcoats = list()
	trenchcoats += /obj/item/clothing/suit/storage/civ_trench
	trenchcoats += /obj/item/clothing/suit/storage/civ_trench/grey
	trenchcoats += /obj/item/clothing/suit/storage/toggle/leathercoat
	trenchcoats += /obj/item/clothing/suit/storage/toggle/browncoat
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(trenchcoats)

//
// Donator's shop
//

/datum/gear/suit/pirate
	display_name = "pirate suit"
	path = /obj/item/clothing/suit/pirate
	subgroup = "Costumes"
	price = 15

/datum/gear/suit/cardborg
	display_name = "cardborg suit"
	path = /obj/item/clothing/suit/cardborg
	subgroup = "Costumes"
	price = 6

/datum/gear/suit/santa
	display_name = "santa's suit"
	path = /obj/item/clothing/suit/space/santa
	subgroup = "Costumes"
	price = 40

/datum/gear/suit/plaguedoctorsuit
	display_name = "plague doctor suit"
	path = /obj/item/clothing/suit/bio_suit/plaguedoctorsuit
	subgroup = "Costumes"
	price = 20

/datum/gear/suit/hgpirate
	display_name = "pirate captain coat"
	path = /obj/item/clothing/suit/hgpirate
	subgroup = "Jackets & Coats"
	price = 10

/datum/gear/suit/johnny_coat
	display_name = "johnny coat"
	path = /obj/item/clothing/suit/johnny_coat
	subgroup = "Jackets & Coats"
	price = 10

/datum/gear/suit/judgerobe
	display_name = "judge's robe"
	path = /obj/item/clothing/suit/judgerobe
	subgroup = "Costumes"
	price = 10

/datum/gear/suit/monkeysuit
	display_name = "monkey suit"
	path = /obj/item/clothing/suit/monkeysuit
	subgroup = "Costumes"
	price = 10

/datum/gear/suit/chickensuit
	display_name = "chicken suit"
	path = /obj/item/clothing/suit/chickensuit
	subgroup = "Costumes"
	price = 10

/datum/gear/suit/yuri
	display_name = "yuri coat"
	path = /obj/item/clothing/suit/yuri
	subgroup = "Jackets & Coats"
	price = 10

/datum/gear/suit/bee
	display_name = "bee suit"
	path = /obj/item/clothing/suit/storage/hooded/bee
	subgroup = "Costumes"
	price = 10

/datum/gear/suit/hos_formal
	display_name = "head of security's formal coat"
	path = /obj/item/clothing/suit/hos_formal
	subgroup = "Jackets & Coats"
	price = 10
	allowed_roles = list(/datum/job/hos)

/datum/gear/suit/witchhunter
	display_name = "witchunter garb"
	path = /obj/item/clothing/suit/witchhunter
	subgroup = "Costumes"
	price = 10
	allowed_roles = list(/datum/job/chaplain)

/datum/gear/suit/wizrobe_fake
	display_name = "wizard robe"
	path = /obj/item/clothing/suit/wizrobe/fake
	subgroup = "Costumes"
	price = 20

/datum/gear/suit/wizrobe_marisa_fake
	display_name = "witch robe"
	path = /obj/item/clothing/suit/wizrobe/marisa/fake
	subgroup = "Costumes"
	price = 20

/datum/gear/suit/ianshirt
	display_name = "ian shirt"
	path = /obj/item/clothing/suit/ianshirt
	subgroup = "Costumes"
	price = 5

/datum/gear/suit/punk_jacket_AC
	display_name = "punk jacket black"
	path = /obj/item/clothing/suit/storage/toggle/punk_jacket_AC
	subgroup = "Jackets & Coats"
	price = 20

/datum/gear/suit/punk_jacket_RD
	display_name = "punk jacket raven"
	path = /obj/item/clothing/suit/storage/toggle/punk_jacket_RD
	subgroup = "Jackets & Coats"
	price = 20

/datum/gear/suit/punk_jacket_TS
	display_name = "punk jacket brown"
	path = /obj/item/clothing/suit/storage/toggle/punk_jacket_TS
	subgroup = "Jackets & Coats"
	price = 20

/datum/gear/suit/fashionable_coat
	display_name = "fashionable coat"
	path = /obj/item/clothing/suit/storage/fashionable_coat
	subgroup = "Jackets & Coats"
	price = 20
