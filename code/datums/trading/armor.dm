/datum/trader/ship/armour
	name = "Armour Shop Employee"
	name_language = TRADER_DEFAULT_NAME
	origin = "Armour Shop"
	possible_origins = list("Armored Warfare", "Juggernaut's Store", "Under Bulletstorm", "Invincible Warrior", "Protector's Valiance")
	speech = list("hail_generic"	= "Hello there! Welcome to ORIGIN, Here we brough you best armour you can find in whole universe!",
				"hail_deny"			= "You are not welcome here",

				"trade_complete"	= "Thanks for buying our armour from ORIGIN! Remember, no refunds!",
				"trade_blacklist"	= "We'll not make a deal of that.",
				"trade_no_goods"	= "I'm sorry, but we deal in cash only.",
				"trade_not_enough"	= "I think, value of these goods is higher than you offer",
				"how_much"			= "Our armor is hard to underestimate, so I'd sell that to you for VALUE.",
				"compliment_deny"	= "Hah, nice... Actually it isn't.",
				"compliment_accept" = "Thank you for your appreciation.",
				"insult_good"		= "Think twice before saying something stupid.",
				"insult_bad"		= "I hope you'll get a bullet you deserve, idiot.",

				"bribe_refusal"		= "I have other customers to trade with.",
				"bribe_accept"		= "Yeah, maybe I'll stay for TIME more minutes."
				)



	possible_trading_items = list(/obj/item/clothing/head/helmet						= TRADER_THIS_TYPE,
								/obj/item/clothing/head/helmet/ablative					= TRADER_THIS_TYPE,
								/obj/item/clothing/head/helmet/ballistic				= TRADER_THIS_TYPE,
								/obj/item/clothing/head/helmet/syndi						= TRADER_THIS_TYPE,
								/obj/item/clothing/head/helmet/nt						= TRADER_ALL,
								/obj/item/clothing/head/helmet/riot						= TRADER_THIS_TYPE,
								/obj/item/clothing/head/helmet/swat						= TRADER_THIS_TYPE,
								/obj/item/clothing/accessory/armguards					= TRADER_ALL,
								/obj/item/clothing/accessory/armor/helmcover			= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/accessory/armor/tag					= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/accessory/armorplate					= TRADER_ALL,
								/obj/item/clothing/accessory/legguards					= TRADER_ALL,
								/obj/item/clothing/accessory/storage/pouches			= TRADER_ALL,
								/obj/item/clothing/suit/armor/bulletproof				= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/armor/hos						= TRADER_ALL,
								/obj/item/clothing/suit/armor/laserproof				= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/armor/pcarrier					= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/armor/reactive					= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/armor/riot						= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/armor/vest						= TRADER_ALL,
								/obj/item/clothing/suit/armor/vest/ert					= TRADER_BLACKLIST_ALL
								)
