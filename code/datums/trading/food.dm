/datum/trader/ship/pizzaria
	name = "Pizza Shop Employee"
	name_language = TRADER_DEFAULT_NAME
	origin = "Pizzeria"
	possible_origins = list("Papa Joe's", "Pizza Ship", "Dominator Pizza", "Little Kaezars", "Pizza Planet", "Cheese Louise", "Little Taste o' Neo-Italy", "Pizza Gestapo")
	trade_flags = TRADER_MONEY
	possible_wanted_items = list() //They are a pizza shop, not a bargainer.
	possible_trading_items = list(/obj/item/reagent_containers/food/sliceable/pizza   = TRADER_SUBTYPES_ONLY)

	speech = list("hail_generic"    = "Hello! Welcome to ORIGIN, may I take your order?",
				"hail_deny"         = "Beeeep... I'm sorry, your connection has been severed.",

				"trade_complete"    = "Thank you for choosing ORIGIN!",
				"trade_no_goods"    = "I'm sorry but we only take cash.",
				"trade_blacklisted" = "Sir that's... highly illegal.",
				"trade_not_enough"  = "Uhh... that's not enough money for pizza.",
				"how_much"          = "That pizza will cost you VALUE credits.",

				"compliment_deny"   = "That's a bit forward, don't you think?",
				"compliment_accept" = "Thanks, sir! You're very nice!",
				"insult_good"       = "Please stop that, sir.",
				"insult_bad"        = "Sir, just because I'm contractually obligated to keep you on the line for a minute doesn't mean I have to take this.",

				"bribe_refusal"     = "Uh... thanks for the cash, sir. As long as you're in the area, we'll be here...",
				)

/datum/trader/ship/pizzaria/trade(list/offers, num, turf/location)
	. = ..()
	if(.)
		var/atom/movable/M = .
		var/obj/item/pizzabox/box = new(location)
		M.forceMove(box)
		box.pizza = M
		box.boxtag = "A special order from [origin]"

/datum/trader/ship/chinese
	name = "Chinese Restaurant"
	name_language = TRADER_DEFAULT_NAME
	origin = "Captain Panda Bistro"
	possible_origins = list("888 Shanghai Kitchen", "Mr. Lee's Greater Hong Kong", "The House of the Venerable and Inscrutable Colonel", "Lucky Dragon")
	trade_flags = TRADER_MONEY
	possible_wanted_items = list()
	possible_trading_items = list(/obj/item/reagent_containers/food/meatkabob    	       = TRADER_THIS_TYPE,
							/obj/item/reagent_containers/food/monkeysdelight             = TRADER_THIS_TYPE,
							/obj/item/reagent_containers/food/ricepudding                = TRADER_THIS_TYPE,
							/obj/item/reagent_containers/food/slice/xenomeatbread/filled = TRADER_THIS_TYPE,
							/obj/item/reagent_containers/food/soydope                    = TRADER_THIS_TYPE,
							/obj/item/reagent_containers/food/stewedsoymeat              = TRADER_THIS_TYPE,
							/obj/item/reagent_containers/food/wingfangchu                = TRADER_THIS_TYPE,
							/obj/item/reagent_containers/food/drinks/dry_ramen                  = TRADER_THIS_TYPE
							)

	var/list/fortunes = list("Today it's up to you to create the peacefulness you long for.",
							"If you refuse to accept anything but the best, you very often get it.",
							"A smile is your passport into the hearts of others.",
							"Hard work pays off in the future, laziness pays off now.",
							"Change can hurt, but it leads a path to something better.",
							"Hidden in a valley beside an open stream- This will be the type of place where you will find your dream.",
							"Never give up. You're not a failure if you don't give up.",
							"Love can last a lifetime, if you want it to.",
							"The love of your life is stepping into your planet this summer.",
							"Your ability for accomplishment will follow with success.",
							"Please help me, I'm trapped in a fortune cookie factory!")

	speech = list("hail_generic"     = "There are two things constant in life, death and Chinese food. How may I help you?",
				"hail_deny"          = "We do not take orders from rude customers.",

				"trade_complete"     = "Thank you, sir, for your patronage.",
				"trade_blacklist"    = "No, that is very odd. Why would you trade that away?",
				"trade_no_goods"     = "I only accept money transfers.",
				"trade_not_enough"   = "No, I am sorry, that is not possible. I need to make a living.",
				"how_much"           = "I give you ITEM, for VALUE credits. No more, no less.",

				"compliment_deny"    = "That was an odd thing to say. You are very odd.",
				"compliment_accept"  = "Good philosophy, see good in bad, I like.",
				"insult_good"        = "As a man said long ago, \"When anger rises, think of the consequences.\" Think on that.",
				"insult_bad"         = "I do not need to take this from you.",

				"bribe_refusal"     = "Hm... I'll think about it.",
				"bribe_accept"      = "Oh yes! I think I'll stay a few more minutes, then.",
				)

/datum/trader/ship/chinese/trade(list/offers, num, turf/location)
	. = ..()
	if(.)
		var/obj/item/reagent_containers/food/fortunecookie/cookie = new(location)
		var/obj/item/paper/paper = new(cookie)
		cookie.trash = paper
		paper.SetName("Fortune")
		paper.info = pick(fortunes)

/datum/trader/ship/grocery
	name = "Grocer"
	name_language = TRADER_DEFAULT_NAME
	possible_origins = list("HyTee", "Kreugars", "Spaceway", "Privaxs", "FutureValue", "Phyvendyme", "Skreller's Market")
	trade_flags = TRADER_MONEY

	possible_trading_items = list(/obj/item/reagent_containers/food                      = TRADER_SUBTYPES_ONLY,
							/obj/item/reagent_containers/food/drinks/cans                       = TRADER_SUBTYPES_ONLY,
							/obj/item/reagent_containers/food/drinks/bottle                     = TRADER_SUBTYPES_ONLY,
							/obj/item/reagent_containers/food/drinks/bottle/small               = TRADER_BLACKLIST,
							/obj/item/reagent_containers/food/boiledmetroidcore            = TRADER_BLACKLIST,
							/obj/item/reagent_containers/food/checker                    = TRADER_BLACKLIST_ALL,
							/obj/item/reagent_containers/food/fruit_slice                = TRADER_BLACKLIST,
							/obj/item/reagent_containers/food/slice                      = TRADER_BLACKLIST_ALL,
							/obj/item/reagent_containers/food/grown                      = TRADER_BLACKLIST_ALL,
							/obj/item/reagent_containers/food/human                      = TRADER_BLACKLIST_ALL,
							/obj/item/reagent_containers/food/sliceable/braincake        = TRADER_BLACKLIST,
							/obj/item/reagent_containers/food/meat/human                 = TRADER_BLACKLIST,
							/obj/item/reagent_containers/food/variable                   = TRADER_BLACKLIST_ALL
							)

	speech = list("hail_generic"     = "Hello, welcome to ORIGIN, grocery store of the future!",
				"hail_deny"          = "I'm sorry, we've blacklisted your communications due to rude behavior.",

				"trade_complete"     = "Thank you for shopping at ORIGIN!",
				"trade_blacklist"    = "I... wow, that's... no, sir. No.",
				"trade_no_goods"     = "ORIGIN only accepts cash, sir.",
				"trade_not_enough"   = "That is not enough money, sir.",
				"how_much"           = "Sir, that'll cost you VALUE credits. Will that be all?",

				"compliment_deny"    = "Sir, this is a professional environment. Please don't make me get my manager.",
				"compliment_accept"  = "Thank you, sir!",
				"insult_good"        = "Sir, please do not make a scene.",
				"insult_bad"         = "Sir, I WILL get my manager if you don't calm down.",

				"bribe_refusal"      = "Of course sir! ORIGIN is always here for you!",
				)

/datum/trader/ship/bakery
	name = "Pastry Chef"
	name_language = TRADER_DEFAULT_NAME
	origin = "Bakery"
	possible_origins = list("Cakes By Design", "Corner Bakery Local", "My Favorite Cake & Pastry Cafe", "Mama Joes Bakery", "Sprinkles and Fun", "Cakestrosity")

	speech = list("hail_generic"     = "Hello, welcome to ORIGIN! We serve baked goods, including pies, cakes, and anything sweet!",
				"hail_deny"          = "Our food is a privilege, not a right. Goodbye.",

				"trade_complete"     = "Thank you for your purchase! Come again if you're hungry for more!",
				"trade_blacklist"    = "We only accept money. Not... that.",
				"trade_no_goods"     = "Cash for cakes! That's our business!",
				"trade_not_enough"   = "Our dishes are much more expensive than that, sir.",
				"how_much"           = "That lovely dish will cost you VALUE credits.",

				"compliment_deny"    = "Oh wow, how nice of you...",
				"compliment_accept"  = "You're almost as sweet as my pies!",
				"insult_good"        = "My pies are NOT knockoffs!",
				"insult_bad"         = "Well, aren't you a sour apple?",

				"bribe_refusal"      = "Oh ho ho! I'd never think of taking ORIGIN on the road!",
				)
	possible_trading_items = list(/obj/item/reagent_containers/food/slice/birthdaycake/filled     = TRADER_THIS_TYPE,
								/obj/item/reagent_containers/food/slice/carrotcake/filled         = TRADER_THIS_TYPE,
								/obj/item/reagent_containers/food/slice/cheesecake/filled         = TRADER_THIS_TYPE,
								/obj/item/reagent_containers/food/slice/chocolatecake/filled      = TRADER_THIS_TYPE,
								/obj/item/reagent_containers/food/slice/lemoncake/filled          = TRADER_THIS_TYPE,
								/obj/item/reagent_containers/food/slice/limecake/filled           = TRADER_THIS_TYPE,
								/obj/item/reagent_containers/food/slice/orangecake/filled         = TRADER_THIS_TYPE,
								/obj/item/reagent_containers/food/slice/plaincake/filled          = TRADER_THIS_TYPE,
								/obj/item/reagent_containers/food/slice/pumpkinpie/filled         = TRADER_THIS_TYPE,
								/obj/item/reagent_containers/food/slice/bananabread/filled        = TRADER_THIS_TYPE,
								/obj/item/reagent_containers/food/sliceable                       = TRADER_SUBTYPES_ONLY,
								/obj/item/reagent_containers/food/sliceable/pizza                 = TRADER_BLACKLIST_ALL,
								/obj/item/reagent_containers/food/sliceable/xenomeatbread         = TRADER_BLACKLIST,
								/obj/item/reagent_containers/food/sliceable/flatdough             = TRADER_BLACKLIST,
								/obj/item/reagent_containers/food/sliceable/braincake             = TRADER_BLACKLIST,
								/obj/item/reagent_containers/food/pie                             = TRADER_THIS_TYPE,
								/obj/item/reagent_containers/food/applepie                        = TRADER_THIS_TYPE)
