/datum/trader/ship/toyshop
	name = "Toy Shop Employee"
	name_language = TRADER_DEFAULT_NAME
	origin = "Toy Shop"
	trade_flags = TRADER_GOODS|TRADER_MONEY|TRADER_WANTED_ONLY
	possible_origins = list("Toys R Ours", "LEGS GO", "Kay-Cee Toys", "Build-a-Cat", "Magic Box", "The Positronic's Dungeon and Baseball Card Shop")

	speech = list(
		TRADER_HAIL_GENERIC       = "Uhh... hello? Welcome to ORIGIN, I hope you have a, uhh.... good shopping trip.",
		TRADER_HAIL_DENY          = "Nah, you're not allowed here. At all",

		TRADER_TRADE_COMPLETE     = "Thanks for shopping... here... at ORIGIN.",
		TRADER_NO_BLACKLISTED     = "Uuuhhh.... no.",
		TRADER_FOUND_UNWANTED     = "Nah! That's not what I'm looking for. Something rarer.",
		TRADER_NOT_ENOUGH         = "Just 'cause they're made of cardboard doesn't mean they don't cost money...",
		TRADER_HOW_MUCH           = "Uhh... I'm thinking like... VALUE. Right? Or something rare that complements my interest.",
		TRADER_WHAT_WANT          = "Ummmm..... I guess I want",

		TRADER_COMPLEMENT_FAILURE = "Ha! Very funny! You should write your own television show.",
		TRADER_COMPLEMENT_SUCCESS = "Why yes, I do work out.",
		TRADER_INSULT_GOOD        = "Well, well, well. Guess we learned who was the troll here.",
		TRADER_INSULT_BAD         = "I've already written a nasty Spacebook post in my mind about you.",

		TRADER_BRIBE_FAILURE      = "Nah. I need to get moving as soon as uhh... possible.",
		TRADER_BRIBE_SUCCESS      = "You know what, I wasn't doing anything for TIME minutes anyways.",
	)

	possible_wanted_items = list(/obj/item/toy/figure/ert 			= TRADER_THIS_TYPE,
								/obj/item/toy/prize/honk 			= TRADER_THIS_TYPE,
								/obj/item/material/coin 			= TRADER_SUBTYPES_ONLY
								)

	possible_trading_items = list(/obj/item/toy/prize 				= TRADER_SUBTYPES_ONLY,
								/obj/item/toy/prize/honk 			= TRADER_BLACKLIST,
								/obj/item/toy/figure 				= TRADER_SUBTYPES_ONLY,
								/obj/item/toy/figure/ert 			= TRADER_BLACKLIST,
								/obj/item/toy/plushie 				= TRADER_SUBTYPES_ONLY,
								/obj/item/toy/katana 				= TRADER_THIS_TYPE,
								/obj/item/toy/sword 				= TRADER_THIS_TYPE,
								/obj/item/toy/bosunwhistle 			= TRADER_THIS_TYPE,
								/obj/item/board 					= TRADER_THIS_TYPE,
								/obj/item/storage/box/checkers 		= TRADER_ALL,
								/obj/item/deck 						= TRADER_SUBTYPES_ONLY,
								/obj/item/pack 						= TRADER_SUBTYPES_ONLY,
								/obj/item/dice 						= TRADER_ALL,
								/obj/item/dice/d20/cursed 			= TRADER_BLACKLIST,
								/obj/item/gun/launcher/money 		= TRADER_THIS_TYPE
								)

/datum/trader/ship/electronics
	name = "Electronic Shop Employee"
	name_language = TRADER_DEFAULT_NAME
	origin = "Electronic Shop"
	possible_origins = list("Best Sale", "Overstore", "Oldegg", "Circuit Citadel", "Silicon Village", "Positronic Solutions LLC", "Sunvolt Inc.")

	speech = list(
		TRADER_HAIL_GENERIC       = "Hello, sir! Welcome to ORIGIN, I hope you find what you are looking for.",
		TRADER_HAIL_DENY          = "Your call has been disconnected.",

		TRADER_TRADE_COMPLETE     = "Thank you for shopping at ORIGIN, would you like to get the extended warranty as well?",
		TRADER_NO_BLACKLISTED     = "Sir, this is a /electronics/ store.",
		TRADER_NO_GOODS           = "As much as I'd love to buy that from you, I can't.",
		TRADER_NOT_ENOUGH         = "Your offer isn't adequate, sir.",
		TRADER_HOW_MUCH           = "Your total comes out to VALUE credits.",

		TRADER_COMPLEMENT_FAILURE = "Hahaha! Yeah... funny...",
		TRADER_COMPLEMENT_SUCCESS = "That's very nice of you!",
		TRADER_INSULT_GOOD        = "That was uncalled for, sir. Don't make me get my manager.",
		TRADER_INSULT_BAD         = "Sir, I am allowed to hang up the phone if you continue, sir.",

		TRADER_BRIBE_FAILURE      = "Sorry, sir, but I can't really do that.",
		TRADER_BRIBE_SUCCESS      = "Why not! Glad to be here for a few more minutes.",
	)

	possible_trading_items = list(/obj/item/circuitboard 										= TRADER_SUBTYPES_ONLY,
								/obj/item/circuitboard/telecomms 								= TRADER_BLACKLIST,
								/obj/item/circuitboard/unary_atmos 								= TRADER_BLACKLIST,
								/obj/item/circuitboard/arcade 									= TRADER_BLACKLIST,
								/obj/item/circuitboard/mecha 									= TRADER_BLACKLIST,
								/obj/item/circuitboard/mecha/odysseus 							= TRADER_BLACKLIST,
								/obj/item/circuitboard/mecha/honker 							= TRADER_BLACKLIST,
								/obj/item/circuitboard/mecha/durand 							= TRADER_BLACKLIST,
								/obj/item/circuitboard/mecha/gygax 								= TRADER_BLACKLIST,
								/obj/item/circuitboard/mecha/ripley 							= TRADER_BLACKLIST,
								/obj/item/circuitboard/broken 									= TRADER_BLACKLIST,
								/obj/item/stack/cable_coil 										= TRADER_SUBTYPES_ONLY,
								/obj/item/stack/cable_coil/cyborg 								= TRADER_BLACKLIST,
								/obj/item/stack/cable_coil/random 								= TRADER_BLACKLIST,
								/obj/item/stack/cable_coil/cut 									= TRADER_BLACKLIST,
								/obj/item/airalarm_electronics 									= TRADER_THIS_TYPE,
								/obj/item/airlock_electronics 									= TRADER_ALL,
								/obj/item/cell 													= TRADER_THIS_TYPE,
								/obj/item/cell/crap 											= TRADER_THIS_TYPE,
								/obj/item/cell/high 											= TRADER_THIS_TYPE,
								/obj/item/cell/super 											= TRADER_THIS_TYPE,
								/obj/item/cell/hyper 											= TRADER_THIS_TYPE,
								/obj/item/module 												= TRADER_SUBTYPES_ONLY,
								/obj/item/tracker_electronics 									= TRADER_THIS_TYPE,
								/obj/item/combotool/advtool 									= TRADER_THIS_TYPE,
								/obj/item/modular_computer/tablet/preset/custom_loadout/cheap 	= TRADER_THIS_TYPE,
								/obj/item/modular_computer/laptop/preset/custom_loadout/cheap 	= TRADER_THIS_TYPE,
								/obj/item/computer_hardware										= TRADER_ALL,
								/obj/item/computer_hardware/battery_module 						= TRADER_SUBTYPES_ONLY,
								/obj/item/computer_hardware/hard_drive/portable 				= TRADER_BLACKLIST_ALL,
								/obj/item/computer_hardware/hard_drive/cluster 					= TRADER_BLACKLIST,
								/obj/item/computer_hardware/network_card/advanced 				= TRADER_BLACKLIST,
								/obj/item/computer_hardware/processor_unit/photonic 			= TRADER_BLACKLIST
								)


/* Clothing stores: each a different type. A hat/glove store, a shoe store, and a jumpsuit store. */

/datum/trader/ship/clothingshop
	name = "Clothing Store Employee"
	name_language = TRADER_DEFAULT_NAME
	origin = "Clothing Store"
	possible_origins = list("Space Eagle", "Banana Democracy", "Forever 22", "Textiles Factory Warehouse Outlet", "Blocks Brothers")

	speech = list(
		TRADER_HAIL_GENERIC       = "Hello, sir! Welcome to ORIGIN!",
		TRADER_HAIL_DENY          = "We do not trade with rude customers. Consider yourself blacklisted.",

		TRADER_TRADE_COMPLETE     = "Thank you for shopping at ORIGIN. Remember: We cannot accept returns without the original tags!",
		TRADER_NO_BLACKLISTED     = "Hm, how about no?",
		TRADER_NO_GOODS           = "We don't buy, sir. Only sell.",
		TRADER_NOT_ENOUGH         = "Sorry, ORIGIN policy to not accept trades below our marked prices.",
		TRADER_HOW_MUCH           = "Your total comes out to VALUE credits.",

		TRADER_COMPLEMENT_FAILURE = "Excuse me?",
		TRADER_COMPLEMENT_SUCCESS = "Aw, you're so nice!",
		TRADER_INSULT_GOOD        = "Sir.",
		TRADER_INSULT_BAD         = "Wow. I don't have to take this.",

		TRADER_BRIBE_FAILURE      = "ORIGIN policy clearly states we cannot stay for more than the designated time.",
		TRADER_BRIBE_SUCCESS      = "Hm.... sure! We'll have a few minutes of 'engine troubles'.",
	)

	possible_trading_items = list(/obj/item/clothing/under 								= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/under/acj 							= TRADER_BLACKLIST,
								/obj/item/clothing/under/assistantformal/bluespace_tech = TRADER_BLACKLIST,
								/obj/item/clothing/under/chameleon 						= TRADER_BLACKLIST,
								/obj/item/clothing/under/color 							= TRADER_BLACKLIST,
								/obj/item/clothing/under/gimmick 						= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/under/pj 							= TRADER_BLACKLIST,
								/obj/item/clothing/under/rank 							= TRADER_BLACKLIST,
								/obj/item/clothing/under/stripper 						= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/under/swimsuit 						= TRADER_BLACKLIST,
								/obj/item/clothing/under/vox 							= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/under/wedding 						= TRADER_BLACKLIST,
								/obj/item/clothing/under/monkey 						= TRADER_BLACKLIST,
								/obj/item/clothing/suit 								= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/suit/armor 							= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/suit/bio_suit 						= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/suit/fire 							= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/suit/lightrig 						= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/suit/poncho 							= TRADER_BLACKLIST,
								/obj/item/clothing/suit/poncho/roles 					= TRADER_BLACKLIST,
								/obj/item/clothing/suit/radiation 						= TRADER_BLACKLIST,
								/obj/item/clothing/suit/bluetag 						= TRADER_BLACKLIST,
								/obj/item/clothing/suit/redtag 							= TRADER_BLACKLIST,
								/obj/item/clothing/suit/rubber 							= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/suit/security 						= TRADER_BLACKLIST,
								/obj/item/clothing/suit/space 							= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/suit/storage 						= TRADER_BLACKLIST,
								/obj/item/clothing/suit/storage/hooded 					= TRADER_BLACKLIST,
								/obj/item/clothing/suit/storage/toggle 					= TRADER_BLACKLIST,
								/obj/item/clothing/suit/straight_jacket 				= TRADER_BLACKLIST,
								/obj/item/clothing/suit/stripper 						= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/suit/syndicatefake 					= TRADER_BLACKLIST,
								/obj/item/clothing/suit/tajaran 						= TRADER_BLACKLIST,
								/obj/item/clothing/suit/unathi 							= TRADER_BLACKLIST
								)

/datum/trader/ship/clothingshop/New()
	..()
	speech[TRADER_HAIL_START + SPECIES_VOX] = "Well hello, sir! I don't believe we have any clothes that fit you... but you can still look!"


/datum/trader/ship/clothingshop/hatglovesboots
	possible_origins = list("Baldie's Hats, Gloves and Shoes", "The Right Fit", "Like a Glove", "Space Fashion")
	possible_trading_items = list(/obj/item/clothing/gloves 							= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/gloves/color/white/bluespace_tech 	= TRADER_BLACKLIST,
								/obj/item/clothing/gloves/lightrig 						= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/gloves/rig 							= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/gloves/chameleon 					= TRADER_BLACKLIST,
								/obj/item/clothing/head 								= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/head/HoS/dermal 						= TRADER_BLACKLIST,
								/obj/item/clothing/head/beret/deathsquad 				= TRADER_BLACKLIST,
								/obj/item/clothing/head/bio_hood 						= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/head/bomb_hood 						= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/head/centhat 						= TRADER_BLACKLIST,
								/obj/item/clothing/head/chameleon 						= TRADER_BLACKLIST,
								/obj/item/clothing/head/collectable 					= TRADER_BLACKLIST,
								/obj/item/clothing/head/culthood 						= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/head/helmet 							= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/head/hoodiehood 						= TRADER_BLACKLIST,
								/obj/item/clothing/head/lightrig 						= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/head/radiation 						= TRADER_BLACKLIST,
								/obj/item/clothing/head/syndicatefake 					= TRADER_BLACKLIST,
								/obj/item/clothing/head/tajaran 						= TRADER_BLACKLIST,
								/obj/item/clothing/head/warden 							= TRADER_BLACKLIST,
								/obj/item/clothing/head/welding 						= TRADER_BLACKLIST,
								/obj/item/clothing/head/winterhood 						= TRADER_BLACKLIST,
								/obj/item/clothing/shoes 								= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/shoes/black/bluespace_tech 			= TRADER_BLACKLIST,
								/obj/item/clothing/shoes/chameleon 						= TRADER_BLACKLIST,
								/obj/item/clothing/shoes/clown_shoes 					= TRADER_BLACKLIST,
								/obj/item/clothing/shoes/cult 							= TRADER_BLACKLIST,
								/obj/item/clothing/shoes/cyborg 						= TRADER_BLACKLIST,
								/obj/item/clothing/shoes/lightrig 						= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/shoes/magboots 						= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/shoes/syndigaloshes 					= TRADER_BLACKLIST
								)

/datum/trader/ship/clothingshop/accessories
	possible_origins = list("Liquid Accessories", "Golden Paradise", "Mr Joe's shop", "Holy Trinity of Akta")
	possible_trading_items = list(/obj/item/clothing/accessory 							= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/accessory/badge 						= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/accessory/holster 					= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/accessory/medal 						= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/accessory/storage 					= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/accessory/armguards 					= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/accessory/armor 						= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/accessory/holochip 					= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/accessory/legguards 					= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/accessory/stethoscope 				= TRADER_BLACKLIST,
								/obj/item/clothing/accessory/storage/pouches 			= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/accessory/armorplate 				= TRADER_BLACKLIST_ALL,
								/obj/item/clothing/ears/earring 						= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/ring 								= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/ring/seal 							= TRADER_SUBTYPES_ONLY,
								/obj/item/clothing/ring/reagent 						= TRADER_BLACKLIST_ALL,
								/obj/item/underwear/wrist 								= TRADER_SUBTYPES_ONLY
								)
/*
Sells devices, odds and ends, and medical stuff
*/
/datum/trader/ship/devices
	name = "Drugstore Employee"
	name_language = TRADER_DEFAULT_NAME
	origin = "Drugstore"
	possible_origins = list("Buy 'n Save", "Drug Carnival", "C&B", "Fentles", "Dr. Goods", "Beevees", "McGillicuddy's")

	speech = list(
		TRADER_HAIL_GENERIC       = "Hello, hello! Bits and bobs and everything in between, I hope you find what you're looking for!",
		TRADER_HAIL_DENY          = "Oh no. I don't want to deal with YOU.",

		TRADER_TRADE_COMPLETE     = "Thank you! Now remember, there isn't any return policy here, so be careful with that!",
		TRADER_NO_BLACKLISTED     = "Hm. Well that would be illegal, so no.",
		TRADER_NO_GOODS           = "I'm sorry, I only sell goods.",
		TRADER_NOT_ENOUGH         = "Gotta pay more than that to get that!",
		TRADER_HOW_MUCH           = "Well... I bought it for a lot, but I'll give it to you for VALUE.",

		TRADER_COMPLEMENT_FAILURE = "Uh... did you say something?",
		TRADER_COMPLEMENT_SUCCESS = "Mhm! I can agree to that!",
		TRADER_INSULT_GOOD        = "Wow, where was that coming from?",
		TRADER_INSULT_BAD         = "Don't make me blacklist your connection.",

		TRADER_BRIBE_FAILURE      = "Well, as much as I'd love to say 'yes', you realize I operate on a station, correct?"
	)

	possible_trading_items = list(/obj/item/device/flashlight 				= TRADER_ALL,
								/obj/item/device/kit/paint 					= TRADER_SUBTYPES_ONLY,
								/obj/item/aicard 							= TRADER_THIS_TYPE,
								/obj/item/device/handcharger/empty 			= TRADER_THIS_TYPE,
								/obj/item/device/binoculars 				= TRADER_THIS_TYPE,
								/obj/item/device/cable_painter 				= TRADER_THIS_TYPE,
								/obj/item/device/flash 						= TRADER_THIS_TYPE,
								/obj/item/device/floor_painter 				= TRADER_THIS_TYPE,
								/obj/item/device/multitool 					= TRADER_THIS_TYPE,
								/obj/item/device/lightreplacer 				= TRADER_THIS_TYPE,
								/obj/item/device/megaphone 					= TRADER_THIS_TYPE,
								/obj/item/device/paicard 					= TRADER_THIS_TYPE,
								/obj/item/device/pipe_painter 				= TRADER_THIS_TYPE,
								/obj/item/device/healthanalyzer 			= TRADER_THIS_TYPE,
								/obj/item/device/analyzer 					= TRADER_ALL,
								/obj/item/device/mass_spectrometer 			= TRADER_ALL,
								/obj/item/device/reagent_scanner 			= TRADER_ALL,
								/obj/item/device/metroid_scanner 			= TRADER_THIS_TYPE,
								/obj/item/device/suit_cooling_unit 			= TRADER_THIS_TYPE,
								/obj/item/device/t_scanner 					= TRADER_THIS_TYPE,
								/obj/item/device/taperecorder 				= TRADER_THIS_TYPE,
								/obj/item/device/batterer 					= TRADER_THIS_TYPE,
								/obj/item/device/hailer 					= TRADER_THIS_TYPE,
								/obj/item/device/uv_light 					= TRADER_THIS_TYPE,
								/obj/item/organ/internal/cerebrum/mmi 		= TRADER_ALL,
								/obj/item/device/robotanalyzer 				= TRADER_THIS_TYPE,
								/obj/item/device/toner 						= TRADER_THIS_TYPE,
								/obj/item/device/camera_film 				= TRADER_THIS_TYPE,
								/obj/item/device/camera 					= TRADER_THIS_TYPE,
								/obj/item/device/destTagger 				= TRADER_THIS_TYPE,
								/obj/item/device/gps 						= TRADER_THIS_TYPE,
								/obj/item/device/measuring_tape 			= TRADER_THIS_TYPE,
								/obj/item/device/ano_scanner 				= TRADER_THIS_TYPE,
								/obj/item/device/core_sampler 				= TRADER_THIS_TYPE,
								/obj/item/device/depth_scanner 				= TRADER_THIS_TYPE,
								/obj/item/pinpointer/radio 					= TRADER_THIS_TYPE,
								/obj/item/device/antibody_scanner 			= TRADER_THIS_TYPE,
								/obj/item/device/synthesized_instrument 	= TRADER_SUBTYPES_ONLY,
								/obj/item/stack/medical/advanced 			= TRADER_BLACKLIST
								)

/datum/trader/ship/devices/New()
	..()
	speech[TRADER_HAIL_START + "silicon"] = "Ah! Hello, robot. We only sell things that, ah.... people can hold in their hands, unfortunately. You are still allowed to buy, though!"


/datum/trader/ship/robots
	name = "Robot Seller"
	name_language = TRADER_DEFAULT_NAME
	origin = "Robot Store"
	possible_origins = list("AI for the Straight Guy", "Mechanical Buddies", "Bot Chop Shop", "Omni Consumer Projects")

	speech = list(
		TRADER_HAIL_GENERIC       = "Welcome to ORIGIN! Let me walk you through our fine robotic selection!",
		TRADER_HAIL_DENY          = "ORIGIN no longer wants to speak to you.",

		TRADER_TRADE_COMPLETE     = "I hope you enjoy your new robot!",
		TRADER_NO_BLACKLISTED     = "I work with robots, sir. Not that.",
		TRADER_NO_GOODS           = "You gotta buy the robots, sir. I don't do trades.",
		TRADER_NOT_ENOUGH         = "You're coming up short on cash.",
		TRADER_HOW_MUCH           = "My fine selection of robots will cost you VALUE!",

		TRADER_COMPLEMENT_FAILURE = "Well, I almost believed that.",
		TRADER_COMPLEMENT_SUCCESS = "Thank you! My craftsmanship is my life.",
		TRADER_INSULT_GOOD        = "Uncalled for.... uncalled for.",
		TRADER_INSULT_BAD         = "I've programmed AI better at insulting than you!",

		TRADER_BRIBE_FAILURE      = "I've got too many customers waiting in other sectors, sorry.",
		TRADER_BRIBE_SUCCESS      = "Hm. Don't keep me waiting too long, though."
	)

	possible_trading_items = list(/obj/item/device/bot_kit 							= TRADER_THIS_TYPE,
								/obj/item/device/paicard 							= TRADER_THIS_TYPE,
								/obj/item/device/tvcamera 							= TRADER_THIS_TYPE,
								/obj/item/device/robotanalyzer 						= TRADER_THIS_TYPE,
								/obj/item/aicard 									= TRADER_THIS_TYPE,
								/obj/item/weldingtool/mini 							= TRADER_THIS_TYPE,
								/obj/item/weldingtool/hugetank 						= TRADER_THIS_TYPE,
								/obj/item/stack/nanopaste 							= TRADER_THIS_TYPE,
								/mob/living/bot 									= TRADER_SUBTYPES_ONLY,
								/mob/living/bot/mulebot 							= TRADER_BLACKLIST,
								/obj/item/organ/internal/cerebrum/posibrain 		= TRADER_THIS_TYPE,
								/obj/item/robot_parts 								= TRADER_SUBTYPES_ONLY,
								/obj/item/stock_parts/manipulator 					= TRADER_THIS_TYPE,
								/obj/item/borg/upgrade 								= TRADER_SUBTYPES_ONLY,
								/obj/item/borg/upgrade/remodel/advanced 			= TRADER_BLACKLIST_ALL,
								/obj/item/borg/upgrade/syndicate 					= TRADER_BLACKLIST,
								/obj/item/borg/upgrade/visor 						= TRADER_BLACKLIST,
								/obj/item/borg/upgrade/visor/thermal 				= TRADER_BLACKLIST,
								/obj/item/borg/upgrade/visor/x_ray 					= TRADER_BLACKLIST,
								/obj/item/borg/upgrade/visor/flash_screen 			= TRADER_BLACKLIST
								)
/datum/trader/ship/robots/New()
	..()
	speech[TRADER_HAIL_START + "silicon"] = "Welcome to ORIGIN! Let- oh, you're a synth! Well, your money is good anyway. Welcome, welcome!"



///datum/trader/xeno_shop            This trader was merged with pet_shop
//	name = "Xenolife Collector"
//	origin = "CSV Not a Poacher"
//	trade_flags = TRADER_GOODS|TRADER_MONEY|TRADER_WANTED_ONLY|TRADER_WANTED_ALL
//	want_multiplier = 15
//	possible_origins = list("XenoHugs","NT Specimen Acquisition","Lonely Pete's Exotic Companionship","Space Wei's Exotic Cuisine")
//	speech = list("hail_generic"    = "Welcome! We are always looking to acquire more exotic life forms.",
//				"hail_deny"         = "We no longer wish to speak to you. Please contact our legal representative if you wish to rectify this.",
//
//				"trade_complete"    = "Remember to give them attention and food. They are living beings, and you should treat them like so.",
//				"trade_blacklist"   = "Legally I can't do that. Morally... well, I refuse to do that.",
//				"trade_found_unwanted" = "I only want animals. I don't need food or shiny things. I'm looking for specific ones, at that. Ones I already have the cage and food for.",
//				"trade_not_enough"   = "I'd give you this for free, but I need the money to feed the specimens. So you must pay in full.",
//				"how_much"          = "This is a good choice. I believe it will cost you VALUE credits.",
//				"what_want"         = "I have the facilities, currently, to support",
//
//				"compliment_deny"   = "According to customs on 34 planets I traded with, this constitutes sexual harrasment.",
//				"compliment_accept" = "Thank you. I needed that.",
//				"insult_good"       = "No need to be upset, I believe we can do business.",
//				"insult_bad"        = "I have traded dogs with more bark than that.",
//				)
//
//	possible_wanted_items = list(/obj/item/seeds 					  = TRADER_SUBTYPES_ONLY)
//
//	possible_trading_items = list(/mob/living/simple_animal/hostile/carp= TRADER_THIS_TYPE,
//								/obj/item/device/dociler              = TRADER_THIS_TYPE,
//								/obj/item/beartrap			  = TRADER_THIS_TYPE,
//								/obj/item/device/metroid_scanner = TRADER_THIS_TYPE)

/datum/trader/ship/medical
	name = "Medical Supplier"
	origin = "Infirmary of CSV Iniquity"
	trade_flags = TRADER_GOODS|TRADER_MONEY|TRADER_WANTED_ONLY
	want_multiplier = 1.2
	margin = 2
	possible_origins = list("Dr.Krieger's Practice", "Legit Medical Supplies (No Refund)", "Mom's & Pop's Addictive Opoids", "Legitimate Pharmaceutical Firm", "Designer Drugs by Lil Xanny")

	speech = list(
		TRADER_HAIL_GENERIC       = "Huh? How'd you get this number?! Oh well, if you wanna talk biz, I'm listening.",
		TRADER_HAIL_DENY          = "This is an automated message. Feel free to fuck the right off after the buzzer. *buzz*",

		TRADER_TRADE_COMPLETE     = "Good to have business with ya. Remember, no refunds.",
		TRADER_NO_BLACKLISTED     = "Whoa whoa, I don't want this shit, put it away.",
		TRADER_FOUND_UNWANTED     = "What the hell do you expect me to do with this junk?",
		TRADER_NOT_ENOUGH         = "Sorry, pal, full payment upfront, I don't write the rules. Well, I do, but that's beside the point.",
		TRADER_HOW_MUCH           = "Hmm, this is one damn fine item, but I'll part with it for VALUE credits.",
		TRADER_WHAT_WANT          = "I could always use some fucking",

		TRADER_COMPLEMENT_FAILURE = "Haha, how nice of you. Why don't you go fall in an elevator shaft.",
		TRADER_COMPLEMENT_SUCCESS = "Damn right I'm awesome, tell me more.",
		TRADER_INSULT_GOOD        = "Damn, pal, no need to get snippy.",
		TRADER_INSULT_BAD         = "*muffled laughter* Sorry, was that you trying to talk shit? Adorable."
	)

	possible_wanted_items = list(/obj/item/reagent_containers/vessel/bottle/chemical 		= TRADER_THIS_TYPE,
								/obj/item/reagent_containers/vessel/bottle/chemical/big 	= TRADER_THIS_TYPE,
								/obj/item/reagent_containers/vessel/bottle/chemical/small 	= TRADER_THIS_TYPE,
								/obj/item/reagent_containers/vessel/beaker 					= TRADER_ALL,
								/obj/item/reagent_containers/vessel/beaker/vial/random 		= TRADER_BLACKLIST_ALL,
								/obj/item/reagent_containers/vessel/beaker/cryoxadone 		= TRADER_BLACKLIST,
								/obj/item/reagent_containers/vessel/beaker/sulphuric 		= TRADER_BLACKLIST,
								/obj/item/organ/internal/liver 								= TRADER_THIS_TYPE,
								/obj/item/organ/internal/kidneys 							= TRADER_THIS_TYPE,
								/obj/item/organ/internal/lungs 								= TRADER_THIS_TYPE,
								/obj/item/organ/internal/heart 								= TRADER_THIS_TYPE,
								/obj/item/organ/internal/stomach 							= TRADER_THIS_TYPE,
								/obj/item/storage/fancy/cigarettes 							= TRADER_ALL
								)

	possible_trading_items = list(/obj/item/storage/pill_bottle 											= TRADER_SUBTYPES_ONLY,
								/obj/item/storage/pill_bottle/dice_nerd 									= TRADER_BLACKLIST,
								/obj/item/storage/firstaid 													= TRADER_ALL,
								/obj/item/storage/firstaid/surgery/syndie 									= TRADER_BLACKLIST,
								/obj/item/storage/box/bloodpacks 											= TRADER_THIS_TYPE,
								/obj/item/storage/box/gloves 												= TRADER_THIS_TYPE,
								/obj/item/storage/box/masks 												= TRADER_THIS_TYPE,
								/obj/item/reagent_containers/ivbag 											= TRADER_SUBTYPES_ONLY,
								/obj/item/defibrillator/loaded 												= TRADER_THIS_TYPE,
								/obj/item/defibrillator/compact/loaded 										= TRADER_THIS_TYPE,
								/obj/item/defibrillator/compact/combat/loaded 								= TRADER_THIS_TYPE,
								/obj/item/scalpel/manager 													= TRADER_THIS_TYPE,
								/obj/item/bonesetter/bone_mender 											= TRADER_THIS_TYPE,
								/obj/item/bonegel  															= TRADER_THIS_TYPE,
								/obj/item/circular_saw/plasmasaw 											= TRADER_THIS_TYPE,
								/obj/item/hemostat/pico 													= TRADER_THIS_TYPE,
								/obj/item/FixOVein/clot 													= TRADER_THIS_TYPE,
								/obj/item/stack/nanopaste 													= TRADER_THIS_TYPE,
								/obj/item/organfixer/advanced 												= TRADER_THIS_TYPE,
								/obj/item/clothing/accessory/stethoscope 									= TRADER_THIS_TYPE,
								/obj/item/virusdish/random 													= TRADER_THIS_TYPE,
								/obj/item/reagent_containers/vessel/bottle/chemical/inaprovaline 			= TRADER_THIS_TYPE,
								/obj/item/reagent_containers/vessel/bottle/chemical/stoxin 					= TRADER_THIS_TYPE,
								/obj/item/reagent_containers/vessel/bottle/chemical/antitoxin 				= TRADER_THIS_TYPE,
								/obj/item/reagent_containers/vessel/bottle/chemical/spaceacillin 			= TRADER_THIS_TYPE,
								/obj/item/bodybag/cryobag 													= TRADER_THIS_TYPE,
								/obj/item/reagent_containers/hypospray/autoinjector/combatpain 				= TRADER_THIS_TYPE,
								/obj/item/reagent_containers/hypospray/autoinjector/dermaline 				= TRADER_THIS_TYPE,
								/obj/item/reagent_containers/hypospray/autoinjector/bicaridine 				= TRADER_THIS_TYPE,
								/obj/item/reagent_containers/hypospray/autoinjector/dexalinp 				= TRADER_THIS_TYPE,
								/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine 			= TRADER_THIS_TYPE,
								/obj/item/reagent_containers/hypospray/vial 								= TRADER_THIS_TYPE,
								/obj/item/sign/medipolma 													= TRADER_THIS_TYPE,
								/mob/living/carbon/human/blank 												= TRADER_THIS_TYPE
								)

///datum/trader/ship/mining     		Merged with trader/ship/trading_beacon/manufacturing
//	name = "Rock'n'Drill Mining Inc"
//	origin = "Automated Smelter AH-532"
//	trade_flags = TRADER_GOODS|TRADER_MONEY|TRADER_WANTED_ONLY|TRADER_WANTED_ALL
//	want_multiplier = 1.5
//	margin = 2
//	possible_origins = list("Automated Smelter AH-532", "CMV Locust", "The Galactic Foundry Company", "Crucible LLC")
//	speech = list("hail_generic"    = "Welcome to R'n'D Mining. Please place your order.",
//				"hail_deny"         = "There is no response on the line.",
//
//				"trade_complete"    = "Transaction complete. Please use our services again",
//				"trade_blacklist"   = "Whoa whoa, I don't want this shit, put it away.",
//				"trade_found_unwanted" = "Sorry, we are currently not looking to purchase these items.",
//				"trade_not_enough"   = "Sorry, this is an insufficient sum for this purchase.",
//				"how_much"          = "For ONE entry of ITEM the price would be VALUE credits.",
//				"what_want"         = "We are currently looking to procure",
//
//				"compliment_deny"   = "I am afraid this is beyond my competency.",
//				"compliment_accept" = "Thank you.",
//				"insult_good"       = "Alright, we will reconsider the terms.",
//				"insult_bad"        = "This is not acceptable, please cease.",
//				)
//
//	possible_wanted_items = list(/obj/item/ore/ = TRADER_SUBTYPES_ONLY,
//								/obj/item/disk/survey = TRADER_THIS_TYPE,
//								/obj/item/ore/slag = TRADER_BLACKLIST)
//
//	possible_trading_items = list(/obj/machinery/mining/drill 										= TRADER_THIS_TYPE,
//								  /obj/machinery/mining/brace 										= TRADER_THIS_TYPE,
//								  /obj/machinery/floodlight											= TRADER_THIS_TYPE,
//								  /obj/item/storage/box/greenglowsticks 						= TRADER_THIS_TYPE,
//								  /obj/item/clothing/suit/space/void/engineering/salvage/prepared 	= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/uranium/ten 								= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/plasteel/fifty 							= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/steel/fifty 								= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/deuterium/fifty 							= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/diamond/ten 								= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/gold/ten 								= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/glass/fifty 								= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/glass/plass/ten 							= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/glass/reinforced/fifty 					= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/marble/fifty 							= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/mhydrogen/ten 							= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/ocp/ten 									= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/osmium/ten 								= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/plasma/fifty 							= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/plastic/fifty 							= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/platinum/ten 							= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/sandstone/fifty 							= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/silver/ten 								= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/tritium/fifty 							= TRADER_THIS_TYPE,
//								  /obj/item/stack/material/uranium/ten 								= TRADER_THIS_TYPE,
//								)
