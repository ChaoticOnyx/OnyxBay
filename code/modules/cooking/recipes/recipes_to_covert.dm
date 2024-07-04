
/* REVIEW Need to write dumplings
/datum/recipe/dumplings //Missing Recipe
	fruit = list("cabbage" = 1) // A recipe that ACTUALLY uses cabbage.
	reagents = list(/datum/reagent/nutriment/soysauce = 5, /datum/reagent/sodiumchloride = 1, /datum/reagent/blackpepper = 1, /datum/reagent/nutriment/cornoil = 1) // No sesame oil, corn will have to do.
	items = list(
		/obj/item/reagent_containers/food/rawbacon,
		/obj/item/reagent_containers/food/rawbacon, // Substitute for minced pork.
		/obj/item/reagent_containers/food/doughslice,
	)
	result = /obj/item/reagent_containers/food/dumplings
*/

//Somethin' the fuck else

/datum/recipe/donkpocket
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/faggot
	)
	result = /obj/item/reagent_containers/food/donkpocket //SPECIAL

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

/datum/recipe/waffles
	reagents = list(/datum/reagent/sugar = 10)
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough
	)
	result = /obj/item/reagent_containers/food/waffles

/datum/recipe/pancakes
	fruit = list("blueberries" = 2)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
		/obj/item/reagent_containers/food/sliceable/flatdough
	)
	result = /obj/item/reagent_containers/food/pancakes


/datum/recipe/meatbread
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/meat,
		/obj/item/reagent_containers/food/meat,
		/obj/item/reagent_containers/food/meat,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/sliceable/meatbread

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

/datum/recipe/xenomeatbread
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/meat/xeno,
		/obj/item/reagent_containers/food/meat/xeno,
		/obj/item/reagent_containers/food/meat/xeno,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/sliceable/xenomeatbread

/datum/recipe/bananabread
	fruit = list("banana" = 1)
	reagents = list(/datum/reagent/drink/milk = 5, /datum/reagent/sugar = 15)
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough
	)
	result = /obj/item/reagent_containers/food/sliceable/bananabread

/datum/recipe/omelette
	items = list(
		/obj/item/reagent_containers/food/egg,
		/obj/item/reagent_containers/food/egg,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/omelette

/datum/recipe/muffin
	reagents = list(/datum/reagent/drink/milk = 5, /datum/reagent/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/dough,
	)
	result = /obj/item/reagent_containers/food/muffin

/datum/recipe/eggplantparm
	fruit = list("eggplant" = 1)
	items = list(
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge
		)
	result = /obj/item/reagent_containers/food/eggplantparm

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

/datum/recipe/meatpie
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
		/obj/item/reagent_containers/food/meat,
	)
	result = /obj/item/reagent_containers/food/meatpie

/datum/recipe/tofupie
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
		/obj/item/reagent_containers/food/tofu,
	)
	result = /obj/item/reagent_containers/food/tofupie

/datum/recipe/xemeatpie
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
		/obj/item/reagent_containers/food/meat/xeno,
	)
	result = /obj/item/reagent_containers/food/xemeatpie

/datum/recipe/pie
	fruit = list("banana" = 1)
	reagents = list(/datum/reagent/sugar = 5)
	items = list(/obj/item/reagent_containers/food/sliceable/flatdough)
	result = /obj/item/reagent_containers/food/pie

/datum/recipe/cherrypie
	fruit = list("cherries" = 1)
	reagents = list(/datum/reagent/sugar = 10)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
	)
	result = /obj/item/reagent_containers/food/cherrypie

/datum/recipe/berryclafoutis
	fruit = list("berries" = 1)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
	)
	result = /obj/item/reagent_containers/food/berryclafoutis

/datum/recipe/wingfangchu
	reagents = list(/datum/reagent/nutriment/soysauce = 5)
	items = list(
		/obj/item/reagent_containers/food/meat/xeno,
	)
	result = /obj/item/reagent_containers/food/wingfangchu

/datum/recipe/chaosdonut
	reagents = list(/datum/reagent/frostoil = 5, /datum/reagent/capsaicin = 5, /datum/reagent/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/dough
	)
	result = /obj/item/reagent_containers/food/donut/chaos

/datum/recipe/meatkabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/meat,
		/obj/item/reagent_containers/food/meat,
	)
	result = /obj/item/reagent_containers/food/meatkabob

/datum/recipe/tofukabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/tofu,
		/obj/item/reagent_containers/food/tofu,
	)
	result = /obj/item/reagent_containers/food/tofukabob

/datum/recipe/tofubread
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/tofu,
		/obj/item/reagent_containers/food/tofu,
		/obj/item/reagent_containers/food/tofu,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/sliceable/tofubread

/datum/recipe/loadedbakedpotato
	fruit = list("potato" = 1)
	items = list(/obj/item/reagent_containers/food/cheesewedge)
	result = /obj/item/reagent_containers/food/loadedbakedpotato

/datum/recipe/cheesyfries
	items = list(
		/obj/item/reagent_containers/food/fries,
		/obj/item/reagent_containers/food/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/cheesyfries

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

/datum/recipe/cookie
	reagents = list(/datum/reagent/drink/milk = 5, /datum/reagent/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/cookie

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

/datum/recipe/meatsteak
	reagents = list(/datum/reagent/sodiumchloride = 1, /datum/reagent/blackpepper = 1)
	items = list(/obj/item/reagent_containers/food/meat)
	result = /obj/item/reagent_containers/food/meatsteak

/datum/recipe/loadedsteak
	reagents = list(/datum/reagent/nutriment/garlicsauce = 5)
	fruit = list("onion" = 1, "mushroom" = 1)
	items = list(/obj/item/reagent_containers/food/meat)
	result = /obj/item/reagent_containers/food/loadedsteak

/datum/recipe/syntisteak
	reagents = list(/datum/reagent/sodiumchloride = 1, /datum/reagent/blackpepper = 1)
	items = list(/obj/item/reagent_containers/food/meat/syntiflesh)
	result = /obj/item/reagent_containers/food/meatsteak

/datum/recipe/porkchop
	reagents = list(/datum/reagent/sodiumchloride = 1, /datum/reagent/blackpepper = 1)
	items = list(/obj/item/reagent_containers/food/meat/pork)
	result = /obj/item/reagent_containers/food/porkchop

/datum/recipe/pizzamargherita
	fruit = list("tomato" = 1)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge
	)
	result = /obj/item/reagent_containers/food/sliceable/pizza/margherita

/datum/recipe/meatpizza
	fruit = list("tomato" = 1)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
		/obj/item/reagent_containers/food/meat,
		/obj/item/reagent_containers/food/meat,
		/obj/item/reagent_containers/food/meat,
		/obj/item/reagent_containers/food/cheesewedge
	)
	result = /obj/item/reagent_containers/food/sliceable/pizza/meatpizza

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

/datum/recipe/mushroompizza
	fruit = list("mushroom" = 5, "tomato" = 1)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
		/obj/item/reagent_containers/food/cheesewedge
	)
	result = /obj/item/reagent_containers/food/sliceable/pizza/mushroompizza

/datum/recipe/vegetablepizza
	fruit = list("eggplant" = 1, "carrot" = 1, "corn" = 1, "tomato" = 1)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
		/obj/item/reagent_containers/food/cheesewedge
	)
	result = /obj/item/reagent_containers/food/sliceable/pizza/vegetablepizza

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

/datum/recipe/faggotsoup
	fruit = list("carrot" = 1, "potato" = 1)
	reagents = list(/datum/reagent/water = 10)
	items = list(/obj/item/reagent_containers/food/faggot)
	result = /obj/item/reagent_containers/food/faggotsoup

/datum/recipe/fathersoup
	fruit = list("garlic" = 1, "flamechili" = 1, "tomato" = 1)
	reagents = list(/datum/reagent/nutriment/flour = 10, /datum/reagent/blackpepper = 5)
	items = list(/obj/item/reagent_containers/food/tomatosoup)
	result = /obj/item/reagent_containers/food/fathersoup

/datum/recipe/vegetablesoup
	fruit = list("carrot" = 1, "potato" = 1, "corn" = 1, "eggplant" = 1)
	reagents = list(/datum/reagent/water = 10)
	result = /obj/item/reagent_containers/food/vegetablesoup

/datum/recipe/nettlesoup
	fruit = list("nettle" = 1, "potato" = 1)
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/reagent_containers/food/egg
	)
	result = /obj/item/reagent_containers/food/nettlesoup

/datum/recipe/wishsoup
	reagents = list(/datum/reagent/water = 20)
	result= /obj/item/reagent_containers/food/wishsoup

/datum/recipe/hotchili
	fruit = list("chili" = 1, "tomato" = 1)
	items = list(/obj/item/reagent_containers/food/meat)
	result = /obj/item/reagent_containers/food/hotchili

/datum/recipe/coldchili
	fruit = list("icechili" = 1, "tomato" = 1)
	items = list(/obj/item/reagent_containers/food/meat)
	result = /obj/item/reagent_containers/food/coldchili

/datum/recipe/amanita_pie
	reagents = list(/datum/reagent/toxin/amatoxin = 5)
	items = list(/obj/item/reagent_containers/food/sliceable/flatdough)
	result = /obj/item/reagent_containers/food/amanita_pie

/datum/recipe/plump_pie
	fruit = list("plumphelmet" = 1)
	items = list(/obj/item/reagent_containers/food/sliceable/flatdough)
	result = /obj/item/reagent_containers/food/plump_pie

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

/datum/recipe/bigbiteburger
	items = list(
		/obj/item/reagent_containers/food/plainburger,
		/obj/item/reagent_containers/food/meat,
		/obj/item/reagent_containers/food/meat,
		/obj/item/reagent_containers/food/meat,
		/obj/item/reagent_containers/food/egg,
	)
	result = /obj/item/reagent_containers/food/bigbiteburger

/datum/recipe/enchiladas
	fruit = list("chili" = 2, "corn" = 1)
	items = list(/obj/item/reagent_containers/food/cutlet)
	result = /obj/item/reagent_containers/food/enchiladas

/datum/recipe/creamcheesebread
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/sliceable/creamcheesebread

/datum/recipe/monkeysdelight
	fruit = list("banana" = 1)
	reagents = list(/datum/reagent/sodiumchloride = 1, /datum/reagent/blackpepper = 1, /datum/reagent/nutriment/flour = 10)
	items = list(/obj/item/reagent_containers/food/monkeycube)
	result = /obj/item/reagent_containers/food/monkeysdelight

/datum/recipe/baguette
	reagents = list(/datum/reagent/sodiumchloride = 1, /datum/reagent/blackpepper = 1)
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough,
	)
	result = /obj/item/reagent_containers/food/baguette

/datum/recipe/fishandchips
	items = list(
		/obj/item/reagent_containers/food/fries,
		/obj/item/reagent_containers/food/carpmeat,
	)
	result = /obj/item/reagent_containers/food/fishandchips

/datum/recipe/bread
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/egg
	)
	result = /obj/item/reagent_containers/food/sliceable/bread

/datum/recipe/sandwich
	items = list(
		/obj/item/reagent_containers/food/meatsteak,
		/obj/item/reagent_containers/food/slice/bread,
		/obj/item/reagent_containers/food/slice/bread,
		/obj/item/reagent_containers/food/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/sandwich

/datum/recipe/pelmeni
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/pelmeni,
	)
	result = /obj/item/reagent_containers/food/boiledpelmeni

/datum/recipe/toastedsandwich
	items = list(
		/obj/item/reagent_containers/food/sandwich
	)
	result = /obj/item/reagent_containers/food/toastedsandwich

/datum/recipe/grilledcheese
	items = list(
		/obj/item/reagent_containers/food/slice/bread,
		/obj/item/reagent_containers/food/slice/bread,
		/obj/item/reagent_containers/food/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/grilledcheese

/datum/recipe/tomatosoup
	fruit = list("tomato" = 2)
	reagents = list(/datum/reagent/water = 10)
	result = /obj/item/reagent_containers/food/tomatosoup

/datum/recipe/rofflewaffles
	reagents = list(/datum/reagent/psilocybin = 5, /datum/reagent/sugar = 10)
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough,
	)
	result = /obj/item/reagent_containers/food/rofflewaffles

/datum/recipe/stew
	fruit = list("potato" = 1, "tomato" = 1, "carrot" = 1, "eggplant" = 1, "mushroom" = 1)
	reagents = list(/datum/reagent/water = 10)
	items = list(/obj/item/reagent_containers/food/meat)
	result = /obj/item/reagent_containers/food/stew

/datum/recipe/metroidtoast
	reagents = list(/datum/reagent/metroidjelly = 5)
	items = list(
		/obj/item/reagent_containers/food/slice/bread,
	)
	result = /obj/item/reagent_containers/food/jelliedtoast/metroid

/datum/recipe/jelliedtoast
	reagents = list(/datum/reagent/nutriment/cherryjelly = 5)
	items = list(
		/obj/item/reagent_containers/food/slice/bread,
	)
	result = /obj/item/reagent_containers/food/jelliedtoast/cherry

/datum/recipe/milosoup
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/reagent_containers/food/soydope,
		/obj/item/reagent_containers/food/soydope,
		/obj/item/reagent_containers/food/tofu,
		/obj/item/reagent_containers/food/tofu,
	)
	result = /obj/item/reagent_containers/food/milosoup

/datum/recipe/stewedsoymeat
	fruit = list("carrot" = 1, "tomato" = 1)
	items = list(
		/obj/item/reagent_containers/food/soydope,
		/obj/item/reagent_containers/food/soydope
	)
	result = /obj/item/reagent_containers/food/stewedsoymeat

/*/datum/recipe/spaghetti We have the processor now
	items = list(
		/obj/item/reagent_containers/food/doughslice
	)
	result= /obj/item/reagent_containers/food/spaghetti*/

/datum/recipe/boiledspaghetti
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/spaghetti,
	)
	result = /obj/item/reagent_containers/food/boiledspaghetti

/datum/recipe/boiledrice
	reagents = list(/datum/reagent/water = 5, /datum/reagent/nutriment/rice = 10)
	result = /obj/item/reagent_containers/food/boiledrice

/datum/recipe/ricepudding
	reagents = list(/datum/reagent/drink/milk = 5, /datum/reagent/nutriment/rice = 10)
	result = /obj/item/reagent_containers/food/ricepudding

/datum/recipe/pastatomato
	fruit = list("tomato" = 2)
	reagents = list(/datum/reagent/water = 5)
	items = list(/obj/item/reagent_containers/food/spaghetti)
	result = /obj/item/reagent_containers/food/pastatomato

/datum/recipe/poppypretzel
	fruit = list("poppy" = 1)
	items = list(/obj/item/reagent_containers/food/dough)
	result = /obj/item/reagent_containers/food/poppypretzel

/datum/recipe/faggotspaghetti
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/spaghetti,
		/obj/item/reagent_containers/food/faggot,
		/obj/item/reagent_containers/food/faggot,
	)
	result = /obj/item/reagent_containers/food/faggotspaghetti

/datum/recipe/spesslaw
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/spaghetti,
		/obj/item/reagent_containers/food/faggot,
		/obj/item/reagent_containers/food/faggot,
		/obj/item/reagent_containers/food/faggot,
		/obj/item/reagent_containers/food/faggot,
	)
	result = /obj/item/reagent_containers/food/spesslaw

/datum/recipe/superbiteburger
	fruit = list("tomato" = 1)
	reagents = list(/datum/reagent/sodiumchloride = 5, /datum/reagent/blackpepper = 5)
	items = list(
		/obj/item/reagent_containers/food/bigbiteburger,
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/meat,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/boiledegg,
	)
	result = /obj/item/reagent_containers/food/superbiteburger

/datum/recipe/candiedapple
	fruit = list("apple" = 1)
	reagents = list(/datum/reagent/water = 5, /datum/reagent/sugar = 5)
	result = /obj/item/reagent_containers/food/candiedapple

/datum/recipe/applepie
	fruit = list("apple" = 1)
	items = list(/obj/item/reagent_containers/food/sliceable/flatdough)
	result = /obj/item/reagent_containers/food/applepie

/datum/recipe/metroidburger
	reagents = list(/datum/reagent/metroidjelly = 5)
	items = list(
		/obj/item/reagent_containers/food/bun
	)
	result = /obj/item/reagent_containers/food/jellyburger/metroid

/datum/recipe/jellyburger
	reagents = list(/datum/reagent/nutriment/cherryjelly = 5)
	items = list(
		/obj/item/reagent_containers/food/bun
	)
	result = /obj/item/reagent_containers/food/jellyburger/cherry

/datum/recipe/twobread
	reagents = list(/datum/reagent/ethanol/wine = 5)
	items = list(
		/obj/item/reagent_containers/food/slice/bread,
		/obj/item/reagent_containers/food/slice/bread,
	)
	result = /obj/item/reagent_containers/food/twobread

/datum/recipe/threebread
	items = list(
		/obj/item/reagent_containers/food/twobread,
		/obj/item/reagent_containers/food/slice/bread,
	)
	result = /obj/item/reagent_containers/food/threebread

/datum/recipe/metroidsandwich
	reagents = list(/datum/reagent/metroidjelly = 5)
	items = list(
		/obj/item/reagent_containers/food/slice/bread,
		/obj/item/reagent_containers/food/slice/bread,
	)
	result = /obj/item/reagent_containers/food/jellysandwich/metroid

/datum/recipe/cherrysandwich
	reagents = list(/datum/reagent/nutriment/cherryjelly = 5)
	items = list(
		/obj/item/reagent_containers/food/slice/bread,
		/obj/item/reagent_containers/food/slice/bread,
	)
	result = /obj/item/reagent_containers/food/jellysandwich/cherry

/datum/recipe/bloodsoup
	reagents = list(/datum/reagent/blood = 30)
	result = /obj/item/reagent_containers/food/bloodsoup

/datum/recipe/metroidsoup
	reagents = list(/datum/reagent/water = 10, /datum/reagent/metroidjelly = 5)
	items = list()
	result = /obj/item/reagent_containers/food/metroidsoup

/datum/recipe/boiledmetroidextract
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/metroid_extract,
	)
	result = /obj/item/reagent_containers/food/boiledmetroidcore

/datum/recipe/chocolateegg
	items = list(
		/obj/item/reagent_containers/food/egg,
		/obj/item/reagent_containers/food/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/chocolateegg

/datum/recipe/sausage
	items = list(
		/obj/item/reagent_containers/food/faggot,
		/obj/item/reagent_containers/food/cutlet,
	)
	result = /obj/item/reagent_containers/food/sausage

/datum/recipe/fishfingers
	reagents = list(/datum/reagent/nutriment/flour = 10)
	items = list(
		/obj/item/reagent_containers/food/egg,
		/obj/item/reagent_containers/food/carpmeat,
	)
	result = /obj/item/reagent_containers/food/fishfingers

/datum/recipe/mysterysoup
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/reagent_containers/food/badrecipe,
		/obj/item/reagent_containers/food/tofu,
		/obj/item/reagent_containers/food/egg,
		/obj/item/reagent_containers/food/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/mysterysoup

/datum/recipe/pumpkinpie
	fruit = list("pumpkin" = 1)
	reagents = list(
	/datum/reagent/drink/milk = 5,
	/datum/reagent/sugar = 5,
	/datum/reagent/nutriment/protein/egg = 3,
	/datum/reagent/nutriment/flour = 10
	)
	result = /obj/item/reagent_containers/food/sliceable/pumpkinpie

/datum/recipe/plumphelmetbiscuit
	fruit = list("plumphelmet" = 1)
	reagents = list(/datum/reagent/water = 5, /datum/reagent/nutriment/flour = 5)
	result = /obj/item/reagent_containers/food/plumphelmetbiscuit

/datum/recipe/mushroomsoup
	fruit = list("mushroom" = 1)
	reagents = list(/datum/reagent/drink/milk = 10)
	result = /obj/item/reagent_containers/food/mushroomsoup

/datum/recipe/chawanmushi
	fruit = list("mushroom" = 1)
	reagents = list(/datum/reagent/water = 5, /datum/reagent/nutriment/soysauce = 5)
	items = list(
		/obj/item/reagent_containers/food/egg,
		/obj/item/reagent_containers/food/egg
	)
	result = /obj/item/reagent_containers/food/chawanmushi

/datum/recipe/beetsoup
	fruit = list("whitebeet" = 1, "cabbage" = 1)
	reagents = list(/datum/reagent/water = 10)
	result = /obj/item/reagent_containers/food/beetsoup

/datum/recipe/appletart
	fruit = list("goldapple" = 1)
	reagents = list(/datum/reagent/sugar = 5, /datum/reagent/drink/milk = 5, /datum/reagent/nutriment/flour = 10)
	items = list(
		/obj/item/reagent_containers/food/egg
	)
	result = /obj/item/reagent_containers/food/appletart

/datum/recipe/tossedsalad
	fruit = list("cabbage" = 2, "tomato" = 1, "carrot" = 1, "apple" = 1)
	result = /obj/item/reagent_containers/food/tossedsalad

/datum/recipe/aesirsalad
	fruit = list("goldapple" = 1, "ambrosiadeus" = 1)
	result = /obj/item/reagent_containers/food/aesirsalad

/datum/recipe/validsalad
	fruit = list("potato" = 1, "ambrosia" = 3)
	items = list(/obj/item/reagent_containers/food/faggot)
	result = /obj/item/reagent_containers/food/validsalad
	make_food(obj/container as obj)
		var/obj/item/reagent_containers/food/validsalad/being_cooked = ..(container)
		being_cooked.reagents.del_reagent(/datum/reagent/toxin)
		return being_cooked

/datum/recipe/cracker
	reagents = list(/datum/reagent/sodiumchloride = 1)
	items = list(
		/obj/item/reagent_containers/food/doughslice
	)
	result = /obj/item/reagent_containers/food/cracker

/datum/recipe/stuffing
	reagents = list(/datum/reagent/water = 5, /datum/reagent/sodiumchloride = 1, /datum/reagent/blackpepper = 1)
	items = list(
		/obj/item/reagent_containers/food/sliceable/bread,
	)
	result = /obj/item/reagent_containers/food/stuffing

/datum/recipe/tofurkey
	items = list(
		/obj/item/reagent_containers/food/tofu,
		/obj/item/reagent_containers/food/tofu,
		/obj/item/reagent_containers/food/stuffing,
	)
	result = /obj/item/reagent_containers/food/tofurkey

// Fuck Science!
/datum/recipe/ruinedvirusdish
	items = list(
		/obj/item/virusdish
	)
	result = /obj/item/ruinedvirusdish

//////////////////////////////////////////
// bs12 food port stuff
//////////////////////////////////////////

/datum/recipe/taco
	items = list(
		/obj/item/reagent_containers/food/doughslice,
		/obj/item/reagent_containers/food/cutlet,
		/obj/item/reagent_containers/food/cheesewedge
	)
	result = /obj/item/reagent_containers/food/taco

/datum/recipe/bun
	items = list(
		/obj/item/reagent_containers/food/dough
	)
	result = /obj/item/reagent_containers/food/bun

/datum/recipe/flatbread
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough
	)
	result = /obj/item/reagent_containers/food/flatbread

/datum/recipe/faggot
	items = list(
		/obj/item/reagent_containers/food/rawfaggot
	)
	result = /obj/item/reagent_containers/food/faggot

/datum/recipe/cutlet
	items = list(
		/obj/item/reagent_containers/food/rawcutlet
	)
	result = /obj/item/reagent_containers/food/cutlet

/datum/recipe/fries
	items = list(
		/obj/item/reagent_containers/food/rawsticks
	)
	result = /obj/item/reagent_containers/food/fries

/datum/recipe/onionrings
	fruit = list("onion" = 1)
	items = list(
		/obj/item/reagent_containers/food/doughslice
	)
	result = /obj/item/reagent_containers/food/onionrings

/datum/recipe/mint
	reagents = list(/datum/reagent/sugar = 5, /datum/reagent/frostoil = 5)
	result = /obj/item/reagent_containers/food/mint


// Cakes.
/datum/recipe/cake
	reagents = list(
	/datum/reagent/drink/milk = 5,
	/datum/reagent/nutriment/flour = 15,
	/datum/reagent/sugar = 15,
	/datum/reagent/nutriment/protein/egg = 9
	)
	result = /obj/item/reagent_containers/food/sliceable/plaincake

/datum/recipe/cake/carrot
	fruit = list("carrot" = 3)
	reagents = list(
	/datum/reagent/drink/milk = 5,
	/datum/reagent/nutriment/flour = 15,
	/datum/reagent/sugar = 15,
	/datum/reagent/nutriment/protein/egg = 9
	)
	result = /obj/item/reagent_containers/food/sliceable/carrotcake

/datum/recipe/cake/cheese
	items = list(
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge
	)
	reagents = list(
	/datum/reagent/drink/milk = 5,
	/datum/reagent/nutriment/flour = 15,
	/datum/reagent/nutriment/protein/egg = 9,
	/datum/reagent/sugar = 15
	)
	result = /obj/item/reagent_containers/food/sliceable/cheesecake

/datum/recipe/cake/orange
	fruit = list("orange" = 1)
	reagents = list(
	/datum/reagent/drink/milk = 5,
	/datum/reagent/nutriment/flour = 15,
	/datum/reagent/nutriment/protein/egg = 9,
	/datum/reagent/sugar = 15
	)
	result = /obj/item/reagent_containers/food/sliceable/orangecake

/datum/recipe/cake/lime
	fruit = list("lime" = 1)
	reagents = list(
	/datum/reagent/drink/milk = 5,
	/datum/reagent/nutriment/flour = 15,
	/datum/reagent/nutriment/protein/egg = 9,
	/datum/reagent/sugar = 15
	)
	result = /obj/item/reagent_containers/food/sliceable/limecake

/datum/recipe/cake/lemon
	fruit = list("lemon" = 1)
	reagents = list(
	/datum/reagent/drink/milk = 5,
	/datum/reagent/nutriment/flour = 15,
	/datum/reagent/nutriment/protein/egg = 9,
	/datum/reagent/sugar = 15
	)
	result = /obj/item/reagent_containers/food/sliceable/lemoncake

/datum/recipe/cake/chocolate
	items = list(/obj/item/reagent_containers/food/chocolatebar)
	reagents = list(
	/datum/reagent/drink/milk = 5,
	/datum/reagent/nutriment/flour = 15,
	/datum/reagent/nutriment/protein/egg = 9,
	/datum/reagent/sugar = 15
	)
	result = /obj/item/reagent_containers/food/sliceable/chocolatecake

/datum/recipe/cake/metroid
	items = list(/obj/item/metroid_extract)
	reagents = list(/datum/reagent/drink/milk = 5, /datum/reagent/nutriment/flour = 15, /datum/reagent/nutriment/protein/egg = 9, /datum/reagent/sugar = 15)
	result = /obj/item/reagent_containers/food/sliceable/metroidcake

/datum/recipe/cake/birthday
	items = list(/obj/item/clothing/head/cakehat)
	reagents = list(
	/datum/reagent/drink/milk = 5,
	/datum/reagent/nutriment/flour = 15,
	/datum/reagent/nutriment/protein/egg = 9,
	/datum/reagent/sugar = 15
	)
	result = /obj/item/reagent_containers/food/sliceable/birthdaycake

/datum/recipe/cake/apple
	fruit = list("apple" = 2)
	reagents = list(
	/datum/reagent/drink/milk = 5,
	/datum/reagent/nutriment/flour = 15,
	/datum/reagent/nutriment/protein/egg = 9,
	/datum/reagent/sugar = 15
	)
	result = /obj/item/reagent_containers/food/sliceable/applecake

/datum/recipe/cake/brain
	items = list(/obj/item/reagent_containers/food/organ/brain)
	reagents = list(
	/datum/reagent/drink/milk = 5,
	/datum/reagent/nutriment/flour = 15,
	/datum/reagent/nutriment/protein/egg = 9,
	/datum/reagent/sugar = 15
	)
	result = /obj/item/reagent_containers/food/sliceable/braincake

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

/datum/recipe/eggsbenedict
	items = list(/obj/item/reagent_containers/food/egg, /obj/item/reagent_containers/food/meatsteak, /obj/item/reagent_containers/food/slice/bread)
	result = /obj/item/reagent_containers/food/eggsbenedict

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

/datum/recipe/tortilla
	fruit = list("corn" = 1)
	reagents = list(/datum/reagent/nutriment/flour = 10)
	result = /obj/item/reagent_containers/food/tortilla

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
