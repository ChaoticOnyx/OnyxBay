/datum/trader/ship/spacesuits
	name = "Spacesuit Shop Employee"
	name_language = TRADER_DEFAULT_NAME
	origin = "Spacesuit Shop"
	possible_origins = list("Firestarters", "Everyday Life in Vacuum", "Void Tourism", "Lost In Space", "Space Safety Store", "Star Runners")
	speech = list("hail_generic"    = "Hello, sir or ma'am! Welcome to ORIGIN, I hope you find what you are looking for.",
				"hail_deny"         = "Go bother someone else",

				"trade_complete"    = "Thanks for buying our sturdy suits from ORIGIN!",
				"trade_blacklist"   = "No-no-no. No deal",
				"trade_no_goods"    = "I'm sorry, but we deal in cash only.",
				"trade_not_enough"  = "These are goods of highest quality and they cost more than that, trust me.",
				"how_much"          = "Our EVA suits are hard to find elsewhere, so I'd sell that to you for VALUE.",
				"compliment_deny"   = "I think you need to think your jokes twice.",
				"compliment_accept" = "Thank you for your appreciation.",
				"insult_good"       = "Woah, man, easy, it's not good for business.",
				"insult_bad"        = "Go breath some fresh vacuum, maybe that will put your mind in place, retard.",

				"bribe_refusal"     = "I have other customers to trade with.",
				"bribe_accept"      = "Yeah, maybe I'll stay for TIME more minutes."
				)



	possible_trading_items = list(
								/obj/item/weapon/tank/oxygen											= TRADER_THIS_TYPE,
								/obj/item/weapon/tank/emergency											= TRADER_SUBTYPES_ONLY,
								/obj/item/weapon/tank/jetpack/oxygen									= TRADER_THIS_TYPE,
								/obj/machinery/portable_atmospherics/canister/oxygen					= TRADER_THIS_TYPE,
								/obj/item/device/suit_cooling_unit										= TRADER_THIS_TYPE,
								/obj/item/clothing/mask/breath											= TRADER_THIS_TYPE,
								/obj/item/clothing/mask/gas												= TRADER_THIS_TYPE,
								/obj/item/clothing/mask/gas/old											= TRADER_THIS_TYPE,
								/obj/item/clothing/shoes/magboots										= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/space											= TRADER_THIS_TYPE,
								/obj/item/clothing/head/helmet/space									= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/space/skrell									= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/head/helmet/space/skrell								= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/suit/space/syndicate									= TRADER_ALL,
								/obj/item/clothing/head/helmet/space/syndicate							= TRADER_ALL,
								/obj/item/clothing/suit/space/void/atmos/alt/prepared					= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/space/void/atmos/prepared						= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/space/void/engineering/alt/prepared				= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/space/void/engineering/salvage/prepared			= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/space/void/engineering/prepared					= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/space/void/excavation/prepared					= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/space/void/exploration/prepared					= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/space/void/medical/alt/prepared					= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/space/void/medical/prepared						= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/space/void/syndi/prepared						= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/space/void/mining/alt/prepared					= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/space/void/mining/prepared						= TRADER_THIS_TYPE,
								///obj/item/clothing/suit/space/void/mining/reinforced/prepared			= TRADER_THIS_TYPE,   uncomment as soon as it is added
								/obj/item/clothing/suit/space/void/pilot/prepared						= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/space/void/security/alt/prepared				= TRADER_THIS_TYPE,
								/obj/item/clothing/suit/space/void/security/prepared					= TRADER_THIS_TYPE,
								/obj/item/weapon/rig/ce													= TRADER_THIS_TYPE,
								/obj/item/weapon/rig/eva												= TRADER_THIS_TYPE,
								/obj/item/weapon/rig/security											= TRADER_THIS_TYPE,
								/obj/item/weapon/rig/hazmat												= TRADER_THIS_TYPE,
								/obj/item/weapon/rig/light/stealth										= TRADER_THIS_TYPE,
								/obj/item/weapon/rig/medical											= TRADER_THIS_TYPE,
								/obj/item/weapon/rig/industrial											= TRADER_THIS_TYPE,
								/obj/item/weapon/rig/syndi/empty											= TRADER_THIS_TYPE,
								/obj/item/weapon/rig/unathi												= TRADER_ALL,
								/obj/item/rig_module													= TRADER_ALL,
								/obj/item/rig_module/chem_dispenser/ninja								= TRADER_BLACKLIST,
								/obj/item/rig_module/datajack											= TRADER_BLACKLIST,
								/obj/item/rig_module/mounted											= TRADER_BLACKLIST,
								/obj/item/rig_module/mounted/energy_blade								= TRADER_BLACKLIST,
								/obj/item/rig_module/fabricator											= TRADER_BLACKLIST,
								/obj/item/rig_module/stealth_field										= TRADER_BLACKLIST,
								/obj/item/rig_module/teleporter											= TRADER_BLACKLIST,
								/obj/item/rig_module/vision/multi										= TRADER_BLACKLIST
								)
