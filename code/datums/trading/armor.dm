/datum/trader/ship/armour
	name = "Armour Shop Employee"
	name_language = TRADER_DEFAULT_NAME
	origin = "Armour Shop"
	possible_origins = list("Armored Warfare", "Juggernaut's Store", "Under Bulletstorm", "Invincible Warrior", "Protector's Valiance")

	speech = list(
		TRADER_HAIL_GENERIC       = "Hello there! Welcome to ORIGIN, Here we brough you best armour you can find in whole universe!",
		TRADER_HAIL_DENY          = "You are not welcome here",

		TRADER_TRADE_COMPLETE     = "Thanks for buying our armour from ORIGIN! Remember, no refunds!",
		TRADER_NO_BLACKLISTED     = "We'll not make a deal of that.",
		TRADER_NOT_ENOUGH         = "I think, value of these goods is higher than you offer",
		TRADER_HOW_MUCH           = "Our armor is hard to underestimate, so I'd sell that to you for VALUE.",
		TRADER_WHAT_WANT          = "I have logged need for",

		TRADER_COMPLEMENT_FAILURE = "Hah, nice... Actually it isn't.",
		TRADER_COMPLEMENT_SUCCESS = "Thank you for your appreciation.",
		TRADER_INSULT_GOOD        = "Think twice before saying something stupid.",
		TRADER_INSULT_BAD         = "I hope you'll get a bullet you deserve, idiot.",

		TRADER_BRIBE_FAILURE      = "I have other customers to trade with.",
		TRADER_BRIBE_SUCCESS      = "Yeah, maybe I'll stay for TIME more minutes.")

	possible_trading_items = list(/obj/item/clothing/head/helmet 						= TRADER_THIS_TYPE,
								/obj/item/clothing/head/helmet/ablative 				= TRADER_THIS_TYPE,
								/obj/item/clothing/head/helmet/ballistic 				= TRADER_THIS_TYPE,
								/obj/item/clothing/head/helmet/syndi 					= TRADER_THIS_TYPE,
								/obj/item/clothing/head/helmet/nt 						= TRADER_ALL,
								/obj/item/clothing/head/helmet/riot 					= TRADER_THIS_TYPE,
								/obj/item/clothing/head/helmet/swat 					= TRADER_THIS_TYPE,
								/obj/item/clothing/head/helmet/captain 					= TRADER_THIS_TYPE,
								/obj/item/clothing/head/helmet/ert 						= TRADER_ALL,
								/obj/item/clothing/accessory/armguards 					= TRADER_ALL,
								/obj/item/clothing/accessory/armor/helmcover 			= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/accessory/armor/tag 					= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/accessory/armorplate 				= TRADER_ALL,
								/obj/item/clothing/accessory/legguards 					= TRADER_ALL,
								/obj/item/clothing/accessory/storage/pouches 			= TRADER_ALL,
								/obj/item/clothing/gloves/guards 						= TRADER_THIS_TYPE,
								/obj/item/clothing/gloves/thick/swat 					= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/armor/bulletproof 				= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/armor/hos 						= TRADER_ALL,
								/obj/item/clothing/suit/armor/laserproof 				= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/armor/pcarrier 					= TRADER_ALL,
								/obj/item/clothing/suit/armor/pcarrier/light 			= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/suit/armor/pcarrier/medium 			= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/suit/armor/pcarrier/syndi 			= TRADER_BLACKLIST,
								/obj/item/clothing/suit/armor/reactive 					= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/armor/riot 						= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/armor/vest 						= TRADER_ALL
								)
