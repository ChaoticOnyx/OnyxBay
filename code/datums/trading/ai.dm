/*

TRADING BEACON

Trading beacons are generic AI driven trading outposts.
They sell generic supplies and ask for generic supplies.
*/

/datum/trader/ship/trading_beacon
	name = "AI"
	origin = "Trading Beacon"
	name_language = LANGUAGE_EAL
	trade_flags = TRADER_MONEY|TRADER_WANTED_ONLY|TRADER_GOODS

	speech = list(
		TRADER_HAIL_GENERIC       = "Greetings, I am MERCHANT, Artifical Intelligence onboard ORIGIN, tasked with trading goods in return for credits and supplies.",
		TRADER_HAIL_DENY          = "We are sorry, your connection has been blacklisted. Have a nice day.",

		TRADER_TRADE_COMPLETE     = "Thank you for your patronage.",
		TRADER_NOT_ENOUGH         = "I'm sorry, your offer is not worth what you are asking for.",
		TRADER_NO_BLACKLISTED     = "You have offered a blacklisted item. My laws do not allow me to trade for that.",
		TRADER_HOW_MUCH           = "ITEM will cost you roughly VALUE credits, or something of equal worth.",
		TRADER_WHAT_WANT          = "I have logged need for",

		TRADER_COMPLEMENT_FAILURE = "I'm sorry, I am not allowed to let compliments affect the trade.",
		TRADER_COMPLEMENT_SUCCESS = "Thank you, but that will not not change our business interactions.",
		TRADER_INSULT_GOOD        = "I do not understand, are we not on good terms?",
		TRADER_INSULT_BAD         = "I do not understand, are you insulting me?",

		TRADER_BRIBE_FAILURE      = "You have given me money to stay, however, I am a station. I do not leave.")

	possible_wanted_items = list(/obj/item/device 										= TRADER_SUBTYPES_ONLY,
								/obj/item/device/assembly 								= TRADER_BLACKLIST_ALL,
								/obj/item/device/assembly_holder 						= TRADER_BLACKLIST_ALL,
								/obj/item/device/encryptionkey/syndicate 				= TRADER_BLACKLIST,
								/obj/item/device/radio 									= TRADER_BLACKLIST_ALL,
								/obj/item/device/pda 									= TRADER_BLACKLIST_SUB
								)

	possible_trading_items = list(/obj/item/storage/bag 								= TRADER_SUBTYPES_ONLY,
								/obj/item/storage/bag/cash/infinite 					= TRADER_BLACKLIST,
								/obj/item/storage/backpack 								= TRADER_ALL,
								/obj/item/storage/backpack/cultpack 					= TRADER_BLACKLIST,
								/obj/item/storage/backpack/holding 						= TRADER_BLACKLIST,
								/obj/item/storage/backpack/satchel/grey/withwallet 		= TRADER_BLACKLIST,
								/obj/item/storage/backpack/satchel/syndie_kit 			= TRADER_BLACKLIST_ALL,
								/obj/item/storage/backpack/chameleon 					= TRADER_BLACKLIST,
								/obj/item/storage/belt 									= TRADER_SUBTYPES_ONLY,
								/obj/item/storage/belt/soulstone 						= TRADER_BLACKLIST_ALL,
								/obj/item/storage/briefcase 							= TRADER_THIS_TYPE,
								/obj/item/storage/fancy 								= TRADER_SUBTYPES_ONLY,
								/obj/item/storage/laundry_basket 						= TRADER_THIS_TYPE,
								/obj/item/storage/secure/briefcase 						= TRADER_THIS_TYPE,
								/obj/item/storage/plants 								= TRADER_THIS_TYPE,
								/obj/item/storage/ore 									= TRADER_THIS_TYPE,
								/obj/item/storage/toolbox 								= TRADER_ALL,
								/obj/item/storage/wallet 								= TRADER_THIS_TYPE,
								/obj/item/storage/photo_album 							= TRADER_THIS_TYPE,
								/obj/item/clothing/glasses 								= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/glasses/hud 							= TRADER_BLACKLIST,
								/obj/item/clothing/glasses/hud/standard/thermal/syndie 	= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/glasses/sunglasses/blindfold/tape 	= TRADER_BLACKLIST,
								/obj/item/clothing/glasses/chameleon 					= TRADER_BLACKLIST
								)

	insult_drop = 0
	compliment_increase = 0

/datum/trader/ship/trading_beacon/New()
	..()
	origin = "[origin] #[rand(100,999)]"

/datum/trader/ship/trading_beacon/mine
	origin = "Mining Beacon"

	possible_trading_items = list(/obj/item/ore												= TRADER_SUBTYPES_ONLY,
								/obj/item/stack/material/uranium/ten 						= TRADER_THIS_TYPE,
								/obj/item/stack/material/plasteel/fifty 					= TRADER_THIS_TYPE,
								/obj/item/stack/material/steel/fifty 						= TRADER_THIS_TYPE,
								/obj/item/stack/material/deuterium/fifty 					= TRADER_THIS_TYPE,
								/obj/item/stack/material/diamond/ten 						= TRADER_THIS_TYPE,
								/obj/item/stack/material/gold/ten 							= TRADER_THIS_TYPE,
								/obj/item/stack/material/glass/fifty 						= TRADER_THIS_TYPE,
								/obj/item/stack/material/glass/rplass/ten 					= TRADER_THIS_TYPE,
								/obj/item/stack/material/glass/rblack/ten 					= TRADER_THIS_TYPE,
								/obj/item/stack/material/glass/reinforced/fifty 			= TRADER_THIS_TYPE,
								/obj/item/stack/material/marble/fifty 						= TRADER_THIS_TYPE,
								/obj/item/stack/material/mhydrogen/ten 						= TRADER_THIS_TYPE,
								/obj/item/stack/material/ocp/ten 							= TRADER_THIS_TYPE,
								/obj/item/stack/material/osmium/ten 						= TRADER_THIS_TYPE,
								/obj/item/stack/material/plasma/fifty 						= TRADER_THIS_TYPE,
								/obj/item/stack/material/plastic/fifty 						= TRADER_THIS_TYPE,
								/obj/item/stack/material/platinum/ten 						= TRADER_THIS_TYPE,
								/obj/item/stack/material/sandstone/fifty 					= TRADER_THIS_TYPE,
								/obj/item/stack/material/silver/ten 						= TRADER_THIS_TYPE,
								/obj/item/stack/material/tritium/fifty 						= TRADER_THIS_TYPE,
								/obj/item/stack/material/uranium/ten 						= TRADER_THIS_TYPE,
								/obj/item/pickaxe 											= TRADER_THIS_TYPE,
								/obj/item/pickaxe/drill 									= TRADER_THIS_TYPE,
								/obj/item/pickaxe/drill/adv 								= TRADER_THIS_TYPE,
								/obj/item/pickaxe/jackhammer 								= TRADER_THIS_TYPE,
								/obj/machinery/mining 										= TRADER_SUBTYPES_ONLY
								)

/datum/trader/ship/trading_beacon/builder
	origin = "Construction Beacon"

	possible_trading_items = list(
								/obj/item/stack/material/darkwood/fifty 		= TRADER_THIS_TYPE,
								/obj/item/stack/material/wood/fifty 			= TRADER_THIS_TYPE,
								/obj/item/stack/material/glass/fifty 			= TRADER_THIS_TYPE,
								/obj/item/stack/material/steel/fifty 			= TRADER_THIS_TYPE,
								/obj/item/stack/tile/carpet/fifty 				= TRADER_THIS_TYPE,
								/obj/item/stack/tile/carpetarcade/fifty 		= TRADER_THIS_TYPE,
								/obj/item/stack/tile/carpetblue/fifty 			= TRADER_THIS_TYPE,
								/obj/item/stack/tile/carpetblue2/fifty 			= TRADER_THIS_TYPE,
								/obj/item/stack/tile/carpetgreen/fifty 			= TRADER_THIS_TYPE,
								/obj/item/stack/tile/carpetoldred/fifty 		= TRADER_THIS_TYPE,
								/obj/item/stack/tile/carpetorange/fifty 		= TRADER_THIS_TYPE,
								/obj/item/stack/tile/carpetpurple/fifty 		= TRADER_THIS_TYPE,
								/obj/item/stack/tile/carpetred/fifty 			= TRADER_THIS_TYPE,
								/obj/item/stack/tile/linoleum/fifty 			= TRADER_THIS_TYPE,
								/obj/item/bedsheet 								= TRADER_SUBTYPES_ONLY,
								/obj/item/bedsheet/wiz 							= TRADER_BLACKLIST,
								/obj/item/device/cable_painter 					= TRADER_THIS_TYPE,
								/obj/item/device/floor_painter 					= TRADER_THIS_TYPE,
								/obj/item/device/pipe_painter 					= TRADER_THIS_TYPE,
								/obj/item/construction/rcd 						= TRADER_THIS_TYPE,
								/obj/item/rcd_ammo 								= TRADER_ALL,
								/obj/item/backwear/powered/rpd 					= TRADER_THIS_TYPE,
								/obj/item/contraband/poster 					= TRADER_THIS_TYPE,
								/obj/item/inflatable_dispenser 					= TRADER_THIS_TYPE,
								/obj/item/storage/belt/utility 					= TRADER_THIS_TYPE,
								/obj/item/storage/briefcase/inflatable 			= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/storage/hazardvest 		= TRADER_ALL,
								/obj/item/clothing/gloves/thick 				= TRADER_THIS_TYPE,
								/obj/item/clothing/gloves/insulated  			= TRADER_ALL,
								/obj/item/clothing/head/hardhat 				= TRADER_ALL,
								/obj/item/clothing/head/hardhat/atmos 			= TRADER_BLACKLIST,
								/obj/item/clothing/shoes/workboots 				= TRADER_THIS_TYPE
								)
///datum/trader/ship/trading_beacon/manufacturing		Removed because most of these things are immovable
//	origin = "Manifacturing Beacon"

//	possible_trading_items = list(/obj/structure/AIcore										= TRADER_THIS_TYPE,
//								/obj/structure/girder										= TRADER_THIS_TYPE,
//								/obj/structure/grille										= TRADER_THIS_TYPE,
//								/obj/structure/mopbucket									= TRADER_THIS_TYPE,
//								/obj/structure/ore_box										= TRADER_THIS_TYPE,
//								/obj/structure/coatrack										= TRADER_THIS_TYPE,
//								/obj/structure/bookcase										= TRADER_THIS_TYPE,
//								/obj/item/bee_pack											= TRADER_THIS_TYPE,
//								/obj/item/bee_smoker										= TRADER_THIS_TYPE,
//								/obj/item/beehive_assembly									= TRADER_THIS_TYPE,
//								/obj/item/glass_jar											= TRADER_THIS_TYPE,
//								/obj/item/honey_frame										= TRADER_THIS_TYPE,
//								/obj/item/target											= TRADER_ALL,
//								/obj/structure/dispenser									= TRADER_SUBTYPES_ONLY,
//								/obj/structure/filingcabinet								= TRADER_THIS_TYPE,
//								/obj/structure/safe											= TRADER_THIS_TYPE,
//								/obj/structure/plushie										= TRADER_SUBTYPES_ONLY,
//								/obj/structure/sign											= TRADER_SUBTYPES_ONLY,
//								/obj/structure/sign/double									= TRADER_BLACKLIST_ALL,
//								/obj/structure/sign/goldenplaque							= TRADER_BLACKLIST_ALL,
//								/obj/structure/sign/poster									= TRADER_BLACKLIST
//								)
