// Uniform slot
/datum/gear/uniform
	display_name = "blazer, blue"
	path = /obj/item/clothing/under/blazer
	slot = slot_w_uniform
	sort_category = "Uniforms and Casual Dress"

/datum/gear/uniform/kilt
	display_name = "kilt"
	path = /obj/item/clothing/under/kilt

/datum/gear/uniform/jumpskirt
	display_name = "jumpskirt, black"
	path = /obj/item/clothing/under/blackjumpskirt

/datum/gear/uniform/jumpsuit
	display_name = "generic jumpsuits"
	path = /obj/item/clothing/under/color/grey

/datum/gear/uniform/jumpsuit/New()
	..()
	gear_tweaks += new /datum/gear_tweak/path(/obj/item/clothing/under/color)

/datum/gear/uniform/roboticist_skirt
	display_name = "skirt, roboticist"
	path = /obj/item/clothing/under/rank/roboticist/skirt
	allowed_roles = list(/datum/job/roboticist)

/datum/gear/uniform/suit
	display_name = "suit selection"
	path = /obj/item/clothing/under/lawyer/bluesuit

/datum/gear/uniform/suit/New()
	..()
	var/suits = list()
	suits["amish suit"] = /obj/item/clothing/under/sl_suit
	suits["black suit"] = /obj/item/clothing/under/suit_jacket
	suits["blue suit"] = /obj/item/clothing/under/lawyer/blue
	suits["executive suit"] = /obj/item/clothing/under/suit_jacket/really_black
	suits["female executive suit"] = /obj/item/clothing/under/suit_jacket/female
	suits["gentleman suit"] = /obj/item/clothing/under/gentlesuit
	suits["old man suit"] = /obj/item/clothing/under/lawyer/oldman
	suits["purple suit"] = /obj/item/clothing/under/lawyer/purpsuit
	suits["red suit"] = /obj/item/clothing/under/suit_jacket/red
	suits["red lawyer suit"] = /obj/item/clothing/under/lawyer/red
	suits["shiny black suit"] = /obj/item/clothing/under/lawyer/black
	suits["white suit"] = /obj/item/clothing/under/scratch
	suits["white-blue suit"] = /obj/item/clothing/under/lawyer/bluesuit
	gear_tweaks += new /datum/gear_tweak/path(suits)

/datum/gear/uniform/dress
	display_name = "dress selection"
	path = /obj/item/clothing/under/dress

/datum/gear/uniform/dress/New()
	..()
	var/dresses = list()
	dresses["flame dress"] = /obj/item/clothing/under/dress/dress_fire
	dresses["green dress"] = /obj/item/clothing/under/dress/dress_green
	dresses["orange dress"] = /obj/item/clothing/under/dress/dress_orange
	dresses["pink dress"] = /obj/item/clothing/under/dress/dress_pink
	dresses["purple dress"] = /obj/item/clothing/under/dress/dress_purple
	dresses["sundress"] = /obj/item/clothing/under/sundress
	dresses["white sundress"] = /obj/item/clothing/under/sundress_white
	gear_tweaks += new /datum/gear_tweak/path(dresses)

/datum/gear/uniform/uniform_captain
	display_name = "uniform, captain's dress"
	path = /obj/item/clothing/under/dress/dress_cap
	allowed_roles = list(/datum/job/captain)

/datum/gear/uniform/corpsecsuit
	display_name = "uniform, corporate (Security)"
	path = /obj/item/clothing/under/rank/security/corp
	allowed_roles = SECURITY_ROLES

/datum/gear/uniform/uniform_hop
	display_name = "uniform, HoP's dress"
	path = /obj/item/clothing/under/dress/dress_hop
	allowed_roles = list(/datum/job/hop)

/datum/gear/uniform/uniform_hr
	display_name = "uniform, HR director (HoP)"
	path = /obj/item/clothing/under/dress/dress_hr
	allowed_roles = list(/datum/job/hop)

/datum/gear/uniform/navysecsuit
	display_name = "uniform, navyblue (Security)"
	path = /obj/item/clothing/under/rank/security/navyblue
	allowed_roles = SECURITY_ROLES

/datum/gear/uniform/skirt
	display_name = "skirt selection"
	path = /obj/item/clothing/under/skirt

/datum/gear/uniform/skirt/New()
	..()
	var/list/skirts = list()
	for(var/skirt in (typesof(/obj/item/clothing/under/skirt)))
		var/obj/item/clothing/under/skirt/skirt_type = skirt
		skirts[initial(skirt_type.name)] = skirt_type
	gear_tweaks += new /datum/gear_tweak/path(sortAssoc(skirts))

/datum/gear/uniform/tacticool
	display_name = "tacticool turtleneck"
	path = /obj/item/clothing/under/syndicate/tacticool

// /datum/gear/uniform/turtleneck
// 	display_name = "sweater"
// 	path = /obj/item/clothing/under/rank/psych/turtleneck/sweater
// 	flags = GEAR_HAS_COLOR_SELECTION
