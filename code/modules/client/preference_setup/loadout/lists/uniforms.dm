/datum/gear/uniform
	sort_category = "Uniforms"
	slot = slot_w_uniform

/datum/gear/uniform/jumpsuit
	display_name = "jumpsuit, colour select"
	path = /obj/item/clothing/under/color
	flags = GEAR_HAS_COLOR_SELECTION

// /datum/gear/uniform/shortjumpskirt
// 	display_name = "short jumpskirt, colour select"
// 	path = /obj/item/clothing/under/shortjumpskirt
// 	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/roboticist_skirt
	display_name = "skirt, roboticist"
	path = /obj/item/clothing/under/rank/roboticist/skirt

/datum/gear/uniform/suit
	display_name = "clothes selection"
	path = /obj/item/clothing/under

/datum/gear/uniform/suit/New()
	..()
	var/suits = list()
	suits += /obj/item/clothing/under/sl_suit
	suits += /obj/item/clothing/under/suit_jacket
	suits += /obj/item/clothing/under/lawyer/blue
	suits += /obj/item/clothing/under/suit_jacket/really_black
	suits += /obj/item/clothing/under/suit_jacket/female
	suits += /obj/item/clothing/under/gentlesuit
	suits += /obj/item/clothing/under/lawyer/oldman
	suits += /obj/item/clothing/under/lawyer/purpsuit
	suits += /obj/item/clothing/under/suit_jacket/red
	suits += /obj/item/clothing/under/lawyer/red
	suits += /obj/item/clothing/under/lawyer/black
	suits += /obj/item/clothing/under/scratch
	suits += /obj/item/clothing/under/lawyer/bluesuit
	suits += /obj/item/clothing/under/rank/internalaffairs/plain
	suits += /obj/item/clothing/under/blazer
	suits += /obj/item/clothing/under/blackjumpskirt
	suits += /obj/item/clothing/under/kilt
	suits += /obj/item/clothing/under/dress/dress_hr
	suits += /obj/item/clothing/under/det
	suits += /obj/item/clothing/under/det/black
	suits += /obj/item/clothing/under/det/grey
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(suits)

/datum/gear/uniform/scrubs
	display_name = "standard medical scrubs"
	path = /obj/item/clothing/under/rank/medical/scrubs
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/uniform/scrubs/custom
	display_name = "scrubs, colour select"
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/dress_selection
	display_name = "dress selection"
	path = /obj/item/clothing/under

/datum/gear/uniform/dress_selection/New()
	..()
	var/dresses = list()
	dresses += /obj/item/clothing/under/sundress_white
	dresses += /obj/item/clothing/under/dress/dress_fire
	dresses += /obj/item/clothing/under/dress/dress_green
	dresses += /obj/item/clothing/under/dress/dress_orange
	dresses += /obj/item/clothing/under/dress/dress_pink
	dresses += /obj/item/clothing/under/dress/dress_purple
	dresses += /obj/item/clothing/under/sundress
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(dresses)

/datum/gear/uniform/skirt
	display_name = "skirt selection"
	path = /obj/item/clothing/under/skirt
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/uniform/skirt_c
	display_name = "short skirt, colour select"
	path = /obj/item/clothing/under/skirt_c
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/skirt_c/dress
	display_name = "simple dress, colour select"
	path = /obj/item/clothing/under/skirt_c/dress
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/casual_pants
	display_name = "casual pants selection"
	path = /obj/item/clothing/under/casual_pants
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/uniform/formal_pants
	display_name = "formal pants selection"
	path = /obj/item/clothing/under/formal_pants
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/uniform/formal_pants/custom
	display_name = "suit pants, colour select"
	path = /obj/item/clothing/under/formal_pants
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/shorts
	display_name = "shorts selection"
	path = /obj/item/clothing/under/shorts/jeans
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/uniform/shorts/custom
	display_name = "athletic shorts, colour select"
	path = /obj/item/clothing/under/shorts/
	flags = GEAR_HAS_COLOR_SELECTION

// /datum/gear/uniform/turtleneck
// 	display_name = "sweater, colour select"
// 	path = /obj/item/clothing/under/rank/psych/turtleneck/sweater
// 	flags = GEAR_HAS_COLOR_SELECTION

/* MissingNo. uniform. Causes logs wreckage. *shrug
/datum/gear/uniform/corporate
	display_name = "corporate uniform selection"
	path = /obj/item/clothing/under

/datum/gear/uniform/corporate/New()
	..()
	var/corps = list()
	// corps += /obj/item/clothing/under/mbill
	// corps += /obj/item/clothing/under/saare
	// corps += /obj/item/clothing/under/aether
	// corps += /obj/item/clothing/under/hephaestus
	// corps += /obj/item/clothing/under/pcrc
	// corps += /obj/item/clothing/under/wardt
	// corps += /obj/item/clothing/under/grayson
	// corps += /obj/item/clothing/under/focal
	// corps += /obj/item/clothing/under/rank/ntwork
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(corps)
*/

/datum/gear/uniform/sterile
	display_name = "sterile jumpsuit"
	path = /obj/item/clothing/under/sterile

/datum/gear/uniform/hazard
	display_name = "hazard jumpsuit"
	path = /obj/item/clothing/under/hazard

// /datum/gear/uniform/frontier
// 	display_name = "frontier clothes"
// 	path = /obj/item/clothing/under/frontier


//
// Donator's shop
//

/datum/gear/uniform/rank/vice
	display_name = "vice officer's jumpsuit"
	path = /obj/item/clothing/under/rank/vice
	price = 18

/datum/gear/uniform/pirate
	display_name = "pirate outfit"
	path = /obj/item/clothing/under/pirate
	price = 13

/datum/gear/uniform/waiter
	display_name = "waiter's outfit"
	path = /obj/item/clothing/under/waiter
	price = 12

/datum/gear/uniform/rank/centcom/officer
	display_name = "officer's dress uniform"
	path = /obj/item/clothing/under/rank/centcom/officer
	price = 39

/datum/gear/uniform/schoolgirl
	display_name = "schoolgirl uniform"
	path = /obj/item/clothing/under/schoolgirl
	price = 13

/datum/gear/uniform/soviet
	display_name = "soviet uniform"
	path = /obj/item/clothing/under/soviet
	price = 13

/datum/gear/uniform/gladiator
	display_name = "gladiator uniform"
	path = /obj/item/clothing/under/gladiator
	price = 10

/datum/gear/uniform/assistantformal
	display_name = "assistant's formal uniform"
	path = /obj/item/clothing/under/assistantformal
	price = 10

/datum/gear/uniform/psyche
	display_name = "psychedelic jumpsuit"
	path = /obj/item/clothing/under/psyche
	price = 25

/datum/gear/uniform/captain_fly
	display_name = "rogue's uniform"
	path = /obj/item/clothing/under/captain_fly
	price = 15

/datum/gear/uniform/mailman
	display_name = "mailman's jumpsuit"
	path = /obj/item/clothing/under/rank/mailman
	price = 10

/datum/gear/uniform/nasa
	display_name = "NASA jumpsuit"
	path = /obj/item/clothing/under/space
	price = 10

/datum/gear/uniform/sexyclown
	display_name = "sexy clown outfit"
	path = /obj/item/clothing/under/sexyclown
	price = 10

/datum/gear/uniform/sexymime
	display_name = "sexy mime outfit"
	path = /obj/item/clothing/under/sexymime
	price = 10

/datum/gear/uniform/owl
	display_name = "owl uniform"
	path = /obj/item/clothing/under/owl
	price = 5

/datum/gear/uniform/psycho
	display_name = "psycho suit"
	path = /obj/item/clothing/under/psysuit
	price = 10

/datum/gear/uniform/johnny
	display_name = "johnny jumpsuit"
	path = /obj/item/clothing/under/johnny
	price = 10

/datum/gear/uniform/dress/maid
	display_name = "maid uniform"
	path = /obj/item/clothing/under/dress/maid
	price = 15

/datum/gear/uniform/dress/gothic_d
	display_name = "gothic dress"
	path = /obj/item/clothing/under/dress/gothic_d
	price = 2

/datum/gear/uniform/dress/bride_white
	display_name = "silky wedding dress"
	path = /obj/item/clothing/under/wedding/bride_white
	price = 10

/datum/gear/uniform/dress/bride_blue
	display_name = "blue wedding dress"
	path = /obj/item/clothing/under/wedding/bride_blue
	price = 10

/datum/gear/uniform/dress/bride_red
	display_name = "red wedding dress"
	path = /obj/item/clothing/under/wedding/bride_red
	price = 10

/datum/gear/uniform/dress/bride_purple
	display_name = "purple wedding dress"
	path = /obj/item/clothing/under/wedding/bride_purple
	price = 10

/datum/gear/uniform/dress/bride_orange
	display_name = "orange wedding dress"
	path = /obj/item/clothing/under/wedding/bride_orange
	price = 10

/datum/gear/uniform/dress/long_gown
	display_name = "silk gown"
	path = /obj/item/clothing/under/skirt_c/dress/long/gown
	price = 10

/datum/gear/uniform/dress/black
	display_name = "black short dress"
	path = /obj/item/clothing/under/skirt_c/dress/black
	price = 10

/datum/gear/uniform/dress/long_black
	display_name = "black maxi dress"
	path = /obj/item/clothing/under/skirt_c/dress/long/black
	price = 10

/datum/gear/uniform/dress/long_eggshell
	display_name = "eggshell maxi dress"
	path = /obj/item/clothing/under/skirt_c/dress/long/eggshell
	price = 10

/datum/gear/uniform/dress/mintcream
	display_name = "mint short dress"
	path = /obj/item/clothing/under/skirt_c/dress/mintcream
	price = 10

/datum/gear/uniform/dress/long_mintcream
	display_name = "mint maxi dress"
	path = /obj/item/clothing/under/skirt_c/dress/long/mintcream
	price = 10

/datum/gear/uniform/dress/long
	display_name = "maxi dress"
	path = /obj/item/clothing/under/skirt_c/dress/long
	price = 10

/datum/gear/uniform/hosformal
	display_name = "HoS's formal uniform"
	allowed_roles = list(/datum/job/hos)
	price = 15

/datum/gear/uniform/hosformal/New()
	..()
	var/suits = list()
	suits += /obj/item/clothing/under/hosformalmale
	suits += /obj/item/clothing/under/hosformalfem
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(suits)
