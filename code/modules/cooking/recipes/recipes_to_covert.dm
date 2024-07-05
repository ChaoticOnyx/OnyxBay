/datum/recipe/dumplings //Missing Recipe
	fruit = list("cabbage" = 1) // A recipe that ACTUALLY uses cabbage.
	reagents = list(/datum/reagent/nutriment/soysauce = 5, /datum/reagent/sodiumchloride = 1, /datum/reagent/blackpepper = 1, /datum/reagent/nutriment/cornoil = 1) // No sesame oil, corn will have to do.
	items = list(
		/obj/item/reagent_containers/food/rawbacon,
		/obj/item/reagent_containers/food/rawbacon, // Substitute for minced pork.
		/obj/item/reagent_containers/food/doughslice,
	)
	result = /obj/item/reagent_containers/food/dumplings

//Somethin' the fuck else

/datum/recipe/donkpocket/proc/warm_up(obj/item/reagent_containers/food/donkpocket/being_cooked)
	being_cooked.heat()

/datum/recipe/donkpocket/warm
	reagents = list() //This is necessary since this is a child object of the above recipe and we don't want donk pockets to need flour
	items = list(
		/obj/item/reagent_containers/food/donkpocket
	)
	result = /obj/item/reagent_containers/food/donkpocket //SPECIAL

/datum/recipe/donkpocket/make_food(obj/container as obj)
	var/obj/item/reagent_containers/food/donkpocket/being_cooked = locate() in container
	if(being_cooked && !being_cooked.warm)
		warm_up(being_cooked)
	return being_cooked


// see code/datums/recipe.dm


/* No telebacon. just no...
/datum/recipe/telebacon
	items = list(
		/obj/item/reagent_containers/food/meat,
		/obj/item/device/assembly/signaler
	)
	result = /obj/item/reagent_containers/food/telebacon

I said no!
/datum/recipe/syntitelebacon
	items = list(
		/obj/item/reagent_containers/food/meat/syntiflesh,
		/obj/item/device/assembly/signaler
	)
	result = /obj/item/reagent_containers/food/telebacon
*/

/datum/recipe/dionaroast
	fruit = list("apple" = 1)
	reagents = list(/datum/reagent/acid/polyacid = 5) //It dissolves the carapace. Still poisonous, though.
	items = list(/obj/item/holder/diona)
	result = /obj/item/reagent_containers/food/dionaroast

/datum/recipe/syntibread
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/meat/syntiflesh,
		/obj/item/reagent_containers/food/meat/syntiflesh,
		/obj/item/reagent_containers/food/meat/syntiflesh,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/sliceable/meatbread


/datum/recipe/soylenviridians
	fruit = list("soybeans" = 1)
	reagents = list(/datum/reagent/nutriment/flour = 10)
	result = /obj/item/reagent_containers/food/soylenviridians

/datum/recipe/soylentgreen
	reagents = list(/datum/reagent/nutriment/flour = 10)
	items = list(
		/obj/item/reagent_containers/food/meat/human,
		/obj/item/reagent_containers/food/meat/human
	)
	result = /obj/item/reagent_containers/food/soylentgreen



/datum/recipe/chaosdonut
	reagents = list(/datum/reagent/frostoil = 5, /datum/reagent/capsaicin = 5, /datum/reagent/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/dough
	)
	result = /obj/item/reagent_containers/food/donut/chaos

/datum/recipe/cubancarp
	fruit = list("chili" = 1)
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/carpmeat
	)
	result = /obj/item/reagent_containers/food/cubancarp

/datum/recipe/popcorn
	reagents = list(/datum/reagent/sodiumchloride = 5)
	fruit = list("corn" = 1)
	result = /obj/item/reagent_containers/food/popcorn

/datum/recipe/fortunecookie
	reagents = list(/datum/reagent/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/doughslice,
		/obj/item/paper,
	)
	result = /obj/item/reagent_containers/food/fortunecookie

/datum/recipe/fortunecookie/make_food(obj/container)
	var/obj/item/paper/paper = locate() in container
	paper.forceMove(null) //prevent deletion
	var/obj/item/reagent_containers/food/fortunecookie/being_cooked = ..(container)
	paper.forceMove(being_cooked)
	being_cooked.trash = paper //so the paper is left behind as trash without special-snowflake(TM Nodrak) code ~carn
	return being_cooked

/datum/recipe/fortunecookie/check_items(obj/container)
	. = ..()
	if(.)
		var/obj/item/paper/paper = locate() in container
		if(!paper || !paper.info)
			return 0
	return .


/datum/recipe/loadedsteak
	reagents = list(/datum/reagent/nutriment/garlicsauce = 5)
	fruit = list("onion" = 1, "mushroom" = 1)
	items = list(/obj/item/reagent_containers/food/meat)
	result = /obj/item/reagent_containers/food/loadedsteak

/datum/recipe/syntisteak
	reagents = list(/datum/reagent/sodiumchloride = 1, /datum/reagent/blackpepper = 1)
	items = list(/obj/item/reagent_containers/food/meat/syntiflesh)
	result = /obj/item/reagent_containers/food/meatsteak


/datum/recipe/syntipizza
	fruit = list("tomato" = 1)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
		/obj/item/reagent_containers/food/meat/syntiflesh,
		/obj/item/reagent_containers/food/meat/syntiflesh,
		/obj/item/reagent_containers/food/meat/syntiflesh,
		/obj/item/reagent_containers/food/cheesewedge
	)
	result = /obj/item/reagent_containers/food/sliceable/pizza/meatpizza

/datum/recipe/spacylibertyduff
	reagents = list(/datum/reagent/water = 5, /datum/reagent/ethanol/vodka = 5, /datum/reagent/psilocybin = 5)
	result = /obj/item/reagent_containers/food/spacylibertyduff

/datum/recipe/amanitajelly
	reagents = list(/datum/reagent/water = 5, /datum/reagent/ethanol/vodka = 5, /datum/reagent/toxin/amatoxin = 5)
	result = /obj/item/reagent_containers/food/amanitajelly
	make_food(obj/container as obj)
		var/obj/item/reagent_containers/food/amanitajelly/being_cooked = ..(container)
		being_cooked.reagents.del_reagent(/datum/reagent/toxin/amatoxin)
		return being_cooked


/datum/recipe/fathersoup
	fruit = list("garlic" = 1, "flamechili" = 1, "tomato" = 1)
	reagents = list(/datum/reagent/nutriment/flour = 10, /datum/reagent/blackpepper = 5)
	items = list(/obj/item/reagent_containers/food/tomatosoup)
	result = /obj/item/reagent_containers/food/fathersoup

/datum/recipe/spellburger
	items = list(
		/obj/item/reagent_containers/food/plainburger,
		/obj/item/clothing/head/wizard/fake,
	)
	result = /obj/item/reagent_containers/food/spellburger

/datum/recipe/spellburger
	items = list(
		/obj/item/reagent_containers/food/plainburger,
		/obj/item/clothing/head/wizard,
	)
	result = /obj/item/reagent_containers/food/spellburger


/datum/recipe/enchiladas
	fruit = list("chili" = 2, "corn" = 1)
	items = list(/obj/item/reagent_containers/food/cutlet)
	result = /obj/item/reagent_containers/food/enchiladas

/datum/recipe/monkeysdelight
	fruit = list("banana" = 1)
	reagents = list(/datum/reagent/sodiumchloride = 1, /datum/reagent/blackpepper = 1, /datum/reagent/nutriment/flour = 10)
	items = list(/obj/item/reagent_containers/food/monkeycube)
	result = /obj/item/reagent_containers/food/monkeysdelight


/datum/recipe/fishandchips
	items = list(
		/obj/item/reagent_containers/food/fries,
		/obj/item/reagent_containers/food/carpmeat,
	)
	result = /obj/item/reagent_containers/food/fishandchips

/datum/recipe/pelmeni
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/pelmeni,
	)
	result = /obj/item/reagent_containers/food/boiledpelmeni


/datum/recipe/poppypretzel
	fruit = list("poppy" = 1)
	items = list(/obj/item/reagent_containers/food/dough)
	result = /obj/item/reagent_containers/food/poppypretzel


/datum/recipe/threebread
	items = list(
		/obj/item/reagent_containers/food/twobread,
		/obj/item/reagent_containers/food/slice/bread,
	)
	result = /obj/item/reagent_containers/food/threebread

/datum/recipe/fishfingers
	reagents = list(/datum/reagent/nutriment/flour = 10)
	items = list(
		/obj/item/reagent_containers/food/egg,
		/obj/item/reagent_containers/food/carpmeat,
	)
	result = /obj/item/reagent_containers/food/fishfingers

// Fuck Science!
/datum/recipe/ruinedvirusdish
	items = list(
		/obj/item/virusdish
	)
	result = /obj/item/ruinedvirusdish

//////////////////////////////////////////
// bs12 food port stuff
//////////////////////////////////////////

/datum/recipe/onionrings
	fruit = list("onion" = 1)
	items = list(
		/obj/item/reagent_containers/food/doughslice
	)
	result = /obj/item/reagent_containers/food/onionrings

/datum/recipe/mint
	reagents = list(/datum/reagent/sugar = 5, /datum/reagent/frostoil = 5)
	result = /obj/item/reagent_containers/food/mint



/datum/recipe/cake/metroid
	items = list(/obj/item/metroid_extract)
	reagents = list(/datum/reagent/drink/milk = 5, /datum/reagent/nutriment/flour = 15, /datum/reagent/nutriment/protein/egg = 9, /datum/reagent/sugar = 15)
	result = /obj/item/reagent_containers/food/sliceable/metroidcake

/datum/recipe/smokedsausage
	items = list(/obj/item/reagent_containers/food/sausage)
	reagents = list(/datum/reagent/sodiumchloride = 5, /datum/reagent/blackpepper = 5)
	result = /obj/item/reagent_containers/food/smokedsausage

/datum/recipe/julienne
	fruit = list("mushroom" = 2, "onion" = 1)
	items = list(/obj/item/reagent_containers/food/cheesewedge, /obj/item/reagent_containers/food/meat)
	result = /obj/item/reagent_containers/food/julienne

/datum/recipe/ricewithmeat
	items = list(/obj/item/reagent_containers/food/boiledrice, /obj/item/reagent_containers/food/cutlet, /obj/item/reagent_containers/food/cutlet)
	result = /obj/item/reagent_containers/food/ricewithmeat

/datum/recipe/eggbowl
	items = list(/obj/item/reagent_containers/food/boiledrice, /obj/item/reagent_containers/food/boiledegg)
	fruit = list("carrot" = 1, "corn" = 1)
	result = /obj/item/reagent_containers/food/eggbowl

/datum/recipe/meatbun
	items = list(/obj/item/reagent_containers/food/bun, /obj/item/reagent_containers/food/faggot)
	reagents = list(/datum/reagent/nutriment/soysauce = 5)
	fruit = list("cabbage" = 1)
	result = /obj/item/reagent_containers/food/meatbun

/datum/recipe/salami
	items = list(/obj/item/reagent_containers/food/smokedsausage)
	reagents = list(/datum/reagent/nutriment/garlicsauce = 5)
	result = /obj/item/reagent_containers/food/sliceable/salami

/datum/recipe/sushi
	items = list(/obj/item/reagent_containers/food/tofu, /obj/item/reagent_containers/food/boiledrice, /obj/item/reagent_containers/food/carpmeat)
	result = /obj/item/reagent_containers/food/sliceable/sushi

/datum/recipe/fruitcup
	fruit = list("apple" = 1, "orange" = 1,"ambrosia" = 1, "banana" = 1, "lemon" = 1, "watermelon" = 1)
	result = /obj/item/reagent_containers/food/fruitcup

/datum/recipe/fruitsalad
	fruit = list("apple" = 1, "orange" = 1, "watermelon" = 1)
	result = /obj/item/reagent_containers/food/fruitsalad

/datum/recipe/delightsalad
	fruit = list("lemon" = 1, "orange" = 1, "lime" = 1)
	result = /obj/item/reagent_containers/food/delightsalad

/datum/recipe/junglesalad
	fruit = list("apple" = 1, "banana" = 2, "watermelon" = 1)
	result = /obj/item/reagent_containers/food/junglesalad

/datum/recipe/chowmein
	items = list(/obj/item/reagent_containers/food/boiledspaghetti, /obj/item/reagent_containers/food/cutlet)
	fruit = list("cabbage" = 2, "carrot" = 1)
	result = /obj/item/reagent_containers/food/chowmein

/datum/recipe/beefnoodles
	items = list(/obj/item/reagent_containers/food/boiledspaghetti,/obj/item/reagent_containers/food/cutlet, /obj/item/reagent_containers/food/cutlet)
	fruit = list("cabbage" = 1)
	result = /obj/item/reagent_containers/food/beefnoodles

/datum/recipe/nachos
	items = list(/obj/item/reagent_containers/food/tortilla)
	reagents = list(/datum/reagent/sodiumchloride = 1)
	result = /obj/item/reagent_containers/food/nachos

/datum/recipe/cheesenachos
	items = list(/obj/item/reagent_containers/food/tortilla,/obj/item/reagent_containers/food/cheesewedge)
	reagents = list(/datum/reagent/sodiumchloride = 1)
	result = /obj/item/reagent_containers/food/cheesenachos

/datum/recipe/cubannachos
	items = list(/obj/item/reagent_containers/food/tortilla)
	fruit = list("chili" = 2)
	result = /obj/item/reagent_containers/food/cubannachos

/datum/recipe/eggwrap
	items = list(/obj/item/reagent_containers/food/boiledegg)
	fruit = list("cabbage" = 1)
	reagents = list(/datum/reagent/nutriment/soysauce = 10)
	result = /obj/item/reagent_containers/food/eggwrap

/datum/recipe/cheeseburrito
	items = list(/obj/item/reagent_containers/food/tortilla,/obj/item/reagent_containers/food/cheesewedge, /obj/item/reagent_containers/food/cheesewedge)
	fruit = list("soybeans" = 1)
	result = /obj/item/reagent_containers/food/cheeseburrito

/datum/recipe/sundae
	items = list(/obj/item/reagent_containers/food/doughslice)
	fruit = list("banana" = 1, "cherries" = 1)
	reagents = list(/datum/reagent/drink/milk/cream = 10)
	result = /obj/item/reagent_containers/food/sundae

/datum/recipe/burrito
	items = list(/obj/item/reagent_containers/food/tortilla)
	fruit = list("soybeans" = 2)
	result = /obj/item/reagent_containers/food/burrito

/datum/recipe/carnaburrito
	items = list(/obj/item/reagent_containers/food/tortilla,/obj/item/reagent_containers/food/cutlet, /obj/item/reagent_containers/food/cutlet)
	fruit = list("soybeans" = 1)
	result = /obj/item/reagent_containers/food/carnaburrito

/datum/recipe/plasmaburrito
	items = list(/obj/item/reagent_containers/food/tortilla)
	fruit = list("soybeans" = 1, "chili" = 2)
	result = /obj/item/reagent_containers/food/plasmaburrito

/datum/recipe/risotto
	items = list(/obj/item/reagent_containers/food/cheesewedge)
	reagents = list(/datum/reagent/nutriment/rice = 10, /datum/reagent/ethanol/wine = 5)
	result = /obj/item/reagent_containers/food/risotto


/datum/recipe/bruschetta
	items = list(/obj/item/reagent_containers/food/cheesewedge)
	fruit = list("tomato" = 1, "garlic" = 1)
	reagents = list(/datum/reagent/nutriment/flour = 10, /datum/reagent/sodiumchloride = 2)
	result = /obj/item/reagent_containers/food/bruschetta

/datum/recipe/quiche
	items = list(/obj/item/reagent_containers/food/cheesewedge, /obj/item/reagent_containers/food/egg)
	fruit = list("tomato" = 1, "garlic" = 1)
	result = /obj/item/reagent_containers/food/quiche

/datum/recipe/lasagna
	items = list(
	/obj/item/reagent_containers/food/cheesewedge,
	/obj/item/reagent_containers/food/sliceable/flatdough,
	/obj/item/reagent_containers/food/sliceable/flatdough,
	/obj/item/reagent_containers/food/meat,
	/obj/item/reagent_containers/food/meat
	)
	fruit = list("tomato" = 3, "eggplant" = 1)
	result = /obj/item/reagent_containers/food/lasagna

/datum/recipe/noel
	items = list(
	/obj/item/reagent_containers/food/chocolatebar,
	/obj/item/reagent_containers/food/chocolatebar
	)
	fruit = list("berries" = 2)
	reagents = list(
	/datum/reagent/nutriment/protein/egg = 6,
	/datum/reagent/nutriment/flour = 15,
	/datum/reagent/drink/milk = 5,
	/datum/reagent/drink/milk/cream = 10
	)
	result = /obj/item/reagent_containers/food/sliceable/noel

/datum/recipe/choccherrycake
	items = list(
	/obj/item/reagent_containers/food/chocolatebar,
	/obj/item/reagent_containers/food/chocolatebar
	)
	fruit = list("cherries" = 2)
	reagents = list(
	/datum/reagent/nutriment/protein/egg = 9,
	/datum/reagent/nutriment/flour = 15,
	/datum/reagent/drink/milk = 5
	)
	result = /obj/item/reagent_containers/food/sliceable/choccherrycake

/datum/recipe/capturedevice_hacked
	items = list(
		/obj/item/capturedevice
	)
	result = /obj/item/capturedevice/hacked
