
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

/datum/recipe/friedegg
	reagents = list(/datum/reagent/salt = 1, /datum/reagent/blackpepper = 1, /datum/reagent/nutriment/oil = 15)
	items = list(
		/obj/item/reagent_containers/food/egg
	)
	result = /obj/item/reagent_containers/food/friedegg

/datum/recipe/friedegg2
	reagents = list(/datum/reagent/salt = 1, /datum/reagent/blackpepper = 1, /datum/reagent/nutriment/oil/corn = 15)
	items = list(
		/obj/item/reagent_containers/food/egg
	)
	result = /obj/item/reagent_containers/food/friedegg

/datum/recipe/boiledegg
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/egg
	)
	result = /obj/item/reagent_containers/food/boiledegg

/datum/recipe/boiledegg/make_food(obj/container, result_mult = 1)
	var/alist/eggs_list = alist()
	for(var/thing in container)
		if(!istype(thing, /obj/item/reagent_containers/food/egg))
			continue
		eggs_list[thing] = TRUE

	var/list/result_objs = ..(container, result_mult, eggs_list)
	for(var/obj/item/reagent_containers/food/boiledegg/being_cooked in result_objs)
		var/obj/item/reagent_containers/food/egg/egg
		for(var/thing in eggs_list)
			egg = thing
		if(istype(egg))
			being_cooked.name = "Boiled [egg.name]"
			being_cooked.icon = egg.icon
			being_cooked.icon_state = egg.icon_state
			being_cooked.base_icon_state = egg.icon_state
			being_cooked.shell_color = egg.shell_color
			being_cooked.CopyOverlays(egg)
			eggs_list -= egg
			qdel(egg)

	eggs_list.Cut() // Justin Case.
	return result_objs

/datum/recipe/dionaroast
	fruit = list("apple" = 1)
	reagents = list(/datum/reagent/acid/polyacid = 5) //It dissolves the carapace. Still poisonous, though.
	items = list(/obj/item/holder/diona)
	result = /obj/item/reagent_containers/food/dionaroast

/datum/recipe/classichotdog
	items = list(
		/obj/item/reagent_containers/food/bun,
		/obj/item/holder/corgi
	)
	result = /obj/item/reagent_containers/food/classichotdog

/datum/recipe/jellydonut
	reagents = list(/datum/reagent/drink/juice/berry = 90, /datum/reagent/sugar = 30)
	items = list(
		/obj/item/reagent_containers/food/dough
	)
	result = /obj/item/reagent_containers/food/donut/jelly
	amount = 3

/datum/recipe/jellydonut/metroid
	reagents = list(/datum/reagent/metroidjelly = 30, /datum/reagent/sugar = 30)
	items = list(
		/obj/item/reagent_containers/food/dough
	)
	result = /obj/item/reagent_containers/food/donut/metroidjelly
	amount = 3

/datum/recipe/jellydonut/cherry
	reagents = list(/datum/reagent/nutriment/cherryjelly = 90, /datum/reagent/sugar = 30)
	items = list(
		/obj/item/reagent_containers/food/dough
	)
	result = /obj/item/reagent_containers/food/donut/cherryjelly
	amount = 3

/datum/recipe/donut
	reagents = list(/datum/reagent/sugar = 30)
	items = list(
		/obj/item/reagent_containers/food/dough
	)
	result = /obj/item/reagent_containers/food/donut/normal
	amount = 3

/datum/recipe/plainburger
	items = list(
		/obj/item/reagent_containers/food/bun,
		/obj/item/reagent_containers/food/cutlet
	)
	result = /obj/item/reagent_containers/food/plainburger

/datum/recipe/cheeseburger
	items = list(
		/obj/item/reagent_containers/food/bun,
		/obj/item/reagent_containers/food/cutlet,
		/obj/item/reagent_containers/food/cheesewedge
	)
	result = /obj/item/reagent_containers/food/cheeseburger

/datum/recipe/cheeseburger2
	items = list(
		/obj/item/reagent_containers/food/plainburger,
		/obj/item/reagent_containers/food/cheesewedge
	)
	result = /obj/item/reagent_containers/food/cheeseburger

/datum/recipe/brainburger
	items = list(
		/obj/item/reagent_containers/food/bun,
		/obj/item/reagent_containers/food/organ/brain
	)
	result = /obj/item/reagent_containers/food/brainburger

/datum/recipe/roburger
	items = list(
		/obj/item/reagent_containers/food/bun,
		/obj/item/robot_parts/head
	)
	result = /obj/item/reagent_containers/food/roburger

/datum/recipe/xenoburger
	items = list(
		/obj/item/reagent_containers/food/bun,
		/obj/item/reagent_containers/food/meat/xeno
	)
	result = /obj/item/reagent_containers/food/xenoburger

/datum/recipe/fishburger
	items = list(
		/obj/item/reagent_containers/food/bun,
		/obj/item/reagent_containers/food/carpmeat
	)
	result = /obj/item/reagent_containers/food/fishburger

/datum/recipe/tofuburger
	items = list(
		/obj/item/reagent_containers/food/bun,
		/obj/item/reagent_containers/food/tofu
	)
	result = /obj/item/reagent_containers/food/tofuburger

/datum/recipe/ghostburger
	items = list(
		/obj/item/reagent_containers/food/bun,
		/obj/item/ectoplasm //where do you even find this stuff
	)
	result = /obj/item/reagent_containers/food/ghostburger

/datum/recipe/clownburger
	items = list(
		/obj/item/reagent_containers/food/bun,
		/obj/item/clothing/mask/gas/clown_hat
	)
	result = /obj/item/reagent_containers/food/clownburger

/datum/recipe/mimeburger
	items = list(
		/obj/item/reagent_containers/food/bun,
		/obj/item/clothing/head/beret
	)
	result = /obj/item/reagent_containers/food/mimeburger

/datum/recipe/bunbun
	items = list(
		/obj/item/reagent_containers/food/bun,
		/obj/item/reagent_containers/food/bun
	)
	result = /obj/item/reagent_containers/food/bunbun

/datum/recipe/hotdog
	items = list(
		/obj/item/reagent_containers/food/bun,
		/obj/item/reagent_containers/food/sausage
	)
	result = /obj/item/reagent_containers/food/hotdog

/datum/recipe/pancakes
	fruit = list("blueberries" = 2)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
		/obj/item/reagent_containers/food/sliceable/flatdough
	)
	result = /obj/item/reagent_containers/food/pancakes
	amount = 3

/datum/recipe/donkpocket
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/faggot
	)
	result = /obj/item/reagent_containers/food/donkpocket //SPECIAL

/datum/recipe/donkpocket/proc/warm_up(obj/item/reagent_containers/food/donkpocket/being_cooked)
	being_cooked.heat()

/datum/recipe/donkpocket/make_food(obj/container, result_mult = 1)
	var/list/result_objs = ..()
	for(var/obj/item/reagent_containers/food/donkpocket/being_cooked in result_objs)
		warm_up(being_cooked)
	return result_objs

/datum/recipe/donkpocket/warm
	reagents = list() //This is necessary since this is a child object of the above recipe and we don't want donk pockets to need flour
	items = list(
		/obj/item/reagent_containers/food/donkpocket
	)
	result = /obj/item/reagent_containers/food/donkpocket //SPECIAL

/datum/recipe/donkpocket/warm/make_food(obj/container, result_mult = 1)
	var/list/result_objs = ..()
	for(var/obj/item/reagent_containers/food/donkpocket/being_cooked in result_objs)
		if(!being_cooked.warm)
			warm_up(being_cooked)
	return result_objs

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
	reagents = list(/datum/reagent/drink/milk = 100, /datum/reagent/sugar = 50)
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
	reagents = list(/datum/reagent/drink/milk = 100, /datum/reagent/sugar = 30)
	items = list(
		/obj/item/reagent_containers/food/dough,
	)
	result = /obj/item/reagent_containers/food/muffin
	amount = 3

/datum/recipe/eggplantparm
	fruit = list("eggplant" = 1)
	items = list(
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge
		)
	result = /obj/item/reagent_containers/food/eggplantparm

/datum/recipe/waffles
	reagents = list(/datum/reagent/sugar = 30)
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough
	)
	result = /obj/item/reagent_containers/food/waffles
	amount = 3

/datum/recipe/rofflewaffles
	reagents = list(/datum/reagent/psilocybin = 5, /datum/reagent/sugar = 30)
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough,
	)
	result = /obj/item/reagent_containers/food/rofflewaffles
	amount = 3

/datum/recipe/soylenviridians
	fruit = list("soybeans" = 2)
	reagents = list(/datum/reagent/nutriment/flour = 150)
	result = /obj/item/reagent_containers/food/soylenviridians
	amount = 3

/datum/recipe/soylentgreen
	reagents = list(/datum/reagent/nutriment/flour = 150)
	items = list(
		/obj/item/reagent_containers/food/meat/human,
		/obj/item/reagent_containers/food/meat/human
		)
	result = /obj/item/reagent_containers/food/soylentgreen
	amount = 3

/datum/recipe/pie
	fruit = list("banana" = 1)
	reagents = list(/datum/reagent/sugar = 20)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough
		)
	result = /obj/item/reagent_containers/food/pie

/datum/recipe/applepie
	fruit = list("apple" = 1)
	reagents = list(/datum/reagent/sugar = 20)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough
		)
	result = /obj/item/reagent_containers/food/applepie

/datum/recipe/cherrypie
	fruit = list("cherries" = 1)
	reagents = list(/datum/reagent/sugar = 20)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
		)
	result = /obj/item/reagent_containers/food/cherrypie

/datum/recipe/amanita_pie
	fruit = list("amanita" = 1)
	items = list(/obj/item/reagent_containers/food/sliceable/flatdough)
	result = /obj/item/reagent_containers/food/amanita_pie

/datum/recipe/plump_pie
	fruit = list("plumphelmet" = 1)
	items = list(/obj/item/reagent_containers/food/sliceable/flatdough)
	result = /obj/item/reagent_containers/food/plump_pie

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

/datum/recipe/berryclafoutis
	fruit = list("berries" = 1)
	reagents = list(/datum/reagent/sugar = 10)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
	)
	result = /obj/item/reagent_containers/food/berryclafoutis

/datum/recipe/appletart
	fruit = list("goldapple" = 1)
	reagents = list(/datum/reagent/sugar = 10, /datum/reagent/drink/milk = 50)
	items = list(
		/obj/item/reagent_containers/food/doughslice,
		/obj/item/reagent_containers/food/doughslice,
		/obj/item/reagent_containers/food/doughslice,
		/obj/item/reagent_containers/food/egg
	)
	result = /obj/item/reagent_containers/food/appletart

/datum/recipe/wingfangchu
	reagents = list(/datum/reagent/nutriment/soysauce = 5)
	items = list(
		/obj/item/reagent_containers/food/meat/xeno,
	)
	result = /obj/item/reagent_containers/food/wingfangchu

/datum/recipe/chaosdonut
	reagents = list(/datum/reagent/frostoil = 10, /datum/reagent/capsaicin = 10, /datum/reagent/sugar = 30)
	items = list(
		/obj/item/reagent_containers/food/dough
	)
	result = /obj/item/reagent_containers/food/donut/chaos
	amount = 3

/datum/recipe/meatkabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/meat,
		/obj/item/reagent_containers/food/meat,
	)
	result = /obj/item/reagent_containers/food/meatkabob
	amount = 3

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
	reagents = list(/datum/reagent/salt = 10, /datum/reagent/nutriment/oil = 30)
	fruit = list("corn" = 1)
	result = /obj/item/reagent_containers/food/popcorn

/datum/recipe/popcorn2
	reagents = list(/datum/reagent/salt = 10, /datum/reagent/nutriment/oil/corn = 30)
	fruit = list("corn" = 1)
	result = /obj/item/reagent_containers/food/popcorn

/datum/recipe/cookie
	reagents = list(/datum/reagent/drink/milk = 100, /datum/reagent/sugar = 30)
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/cookie
	amount = 6

/datum/recipe/fortunecookie
	reagents = list(/datum/reagent/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/doughslice,
		/obj/item/paper,
	)
	result = /obj/item/reagent_containers/food/fortunecookie

/datum/recipe/fortunecookie/make_food(obj/container, result_mult = 1)
	var/alist/papers_list = alist()
	for(var/thing in container)
		if(!istype(thing, /obj/item/paper))
			continue
		papers_list[thing] = TRUE

	var/list/result_objs = ..(container, result_mult, papers_list)
	for(var/obj/item/reagent_containers/food/fortunecookie/being_cooked in result_objs)
		var/obj/item/paper/paper
		for(var/thing in papers_list)
			paper = thing
		if(istype(paper))
			paper.forceMove(being_cooked)
			being_cooked.trash = paper //so the paper is left behind as trash without special-snowflake(TM Nodrak) code ~carn
			papers_list -= paper

	papers_list.Cut() // Just in case
	return result_objs

/datum/recipe/meatsteak
	reagents = list(/datum/reagent/salt = 1, /datum/reagent/blackpepper = 1)
	items = list(/obj/item/reagent_containers/food/meat)
	result = /obj/item/reagent_containers/food/meatsteak

/datum/recipe/loadedsteak
	reagents = list(/datum/reagent/nutriment/garlicsauce = 10)
	fruit = list("onion" = 1, "mushroom" = 1)
	items = list(/obj/item/reagent_containers/food/meat)
	result = /obj/item/reagent_containers/food/loadedsteak

/datum/recipe/syntisteak
	reagents = list(/datum/reagent/salt = 1, /datum/reagent/blackpepper = 1)
	items = list(/obj/item/reagent_containers/food/meat/syntiflesh)
	result = /obj/item/reagent_containers/food/meatsteak

/datum/recipe/porkchop
	reagents = list(/datum/reagent/salt = 1, /datum/reagent/blackpepper = 1)
	items = list(/obj/item/reagent_containers/food/meat/pork)
	result = /obj/item/reagent_containers/food/porkchop

/datum/recipe/pizzamargherita
	fruit = list("tomato" = 2)
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
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge
	)
	result = /obj/item/reagent_containers/food/sliceable/pizza/meatpizza

/datum/recipe/syntipizza
	fruit = list("tomato" = 1)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
		/obj/item/reagent_containers/food/meat/syntiflesh,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge
	)
	result = /obj/item/reagent_containers/food/sliceable/pizza/meatpizza

/datum/recipe/mushroompizza
	fruit = list("mushroom" = 5, "tomato" = 1)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge
	)
	result = /obj/item/reagent_containers/food/sliceable/pizza/mushroompizza

/datum/recipe/vegetablepizza
	fruit = list("eggplant" = 1, "carrot" = 1, "corn" = 1, "tomato" = 1)
	items = list(
		/obj/item/reagent_containers/food/sliceable/flatdough,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge
	)
	result = /obj/item/reagent_containers/food/sliceable/pizza/vegetablepizza

/datum/recipe/spacylibertyduff
	reagents = list(/datum/reagent/water = 50, /datum/reagent/ethanol/vodka = 50, /datum/reagent/psilocybin = 5)
	result = /obj/item/reagent_containers/food/spacylibertyduff

/datum/recipe/amanitajelly
	fruit = list("amanita" = 1)
	reagents = list(/datum/reagent/water = 50, /datum/reagent/ethanol/vodka = 50)
	result = /obj/item/reagent_containers/food/amanitajelly

/datum/recipe/amanitajelly/make_food(obj/container, result_mult = 1)
	var/list/result_objs = ..()
	for(var/obj/item/reagent_containers/food/amanitajelly/being_cooked in result_objs)
		being_cooked.reagents.del_reagent(/datum/reagent/toxin/amatoxin)
	return result_objs

/datum/recipe/faggotsoup
	fruit = list("carrot" = 1, "potato" = 1)
	reagents = list(/datum/reagent/water = 300)
	items = list(/obj/item/reagent_containers/food/faggot)
	result = /obj/item/reagent_containers/food/faggotsoup

/datum/recipe/fathersoup
	fruit = list("garlic" = 1, "flamechili" = 1, "tomato" = 1)
	reagents = list(/datum/reagent/nutriment/flour = 30, /datum/reagent/blackpepper = 5)
	items = list(/obj/item/reagent_containers/food/tomatosoup)
	result = /obj/item/reagent_containers/food/fathersoup

/datum/recipe/vegetablesoup
	fruit = list("carrot" = 1, "potato" = 1, "corn" = 1, "eggplant" = 1)
	reagents = list(/datum/reagent/water = 300)
	result = /obj/item/reagent_containers/food/vegetablesoup

/datum/recipe/nettlesoup
	fruit = list("nettle" = 1, "potato" = 1)
	reagents = list(/datum/reagent/water = 300)
	items = list(
		/obj/item/reagent_containers/food/egg
	)
	result = /obj/item/reagent_containers/food/nettlesoup

/datum/recipe/wishsoup
	reagents = list(/datum/reagent/water = 300)
	result= /obj/item/reagent_containers/food/wishsoup

/datum/recipe/hotchili
	fruit = list("chili" = 1, "tomato" = 1)
	items = list(/obj/item/reagent_containers/food/meat)
	result = /obj/item/reagent_containers/food/hotchili

/datum/recipe/coldchili
	fruit = list("icechili" = 1, "tomato" = 1)
	items = list(/obj/item/reagent_containers/food/meat)
	result = /obj/item/reagent_containers/food/coldchili

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
	reagents = list(/datum/reagent/drink/milk = 300)
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/sliceable/creamcheesebread

/datum/recipe/monkeysdelight
	fruit = list("banana" = 1)
	reagents = list(/datum/reagent/salt = 1, /datum/reagent/blackpepper = 1, /datum/reagent/nutriment/flour = 10)
	items = list(/obj/item/reagent_containers/food/monkeycube)
	result = /obj/item/reagent_containers/food/monkeysdelight

/datum/recipe/baguette
	reagents = list(/datum/reagent/salt = 1, /datum/reagent/blackpepper = 1)
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
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/dough
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
	reagents = list(/datum/reagent/water = 300)
	result = /obj/item/reagent_containers/food/tomatosoup

/datum/recipe/stew
	fruit = list("potato" = 1, "tomato" = 1, "carrot" = 1, "eggplant" = 1, "mushroom" = 1)
	reagents = list(/datum/reagent/water = 200)
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
	reagents = list(/datum/reagent/water = 200)
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

/*/datum/recipe/spagetti We have the processor now
	items = list(
		/obj/item/reagent_containers/food/doughslice
	)
	result= /obj/item/reagent_containers/food/spagetti*/

/datum/recipe/poppypretzel
	fruit = list("poppy" = 1)
	items = list(/obj/item/reagent_containers/food/dough)
	result = /obj/item/reagent_containers/food/poppypretzel
	amount = 6

/datum/recipe/boiledspagetti
	reagents = list(/datum/reagent/water = 200)
	items = list(
		/obj/item/reagent_containers/food/spagetti,
	)
	result = /obj/item/reagent_containers/food/boiledspagetti

/datum/recipe/boiledrice
	reagents = list(/datum/reagent/water = 100, /datum/reagent/nutriment/rice = 50)
	result = /obj/item/reagent_containers/food/boiledrice

/datum/recipe/risotto
	items = list(/obj/item/reagent_containers/food/cheesewedge)
	reagents = list(/datum/reagent/nutriment/rice = 50, /datum/reagent/ethanol/wine = 100)
	result = /obj/item/reagent_containers/food/risotto

/datum/recipe/ricepudding
	reagents = list(/datum/reagent/drink/milk = 100, /datum/reagent/nutriment/rice = 50)
	result = /obj/item/reagent_containers/food/ricepudding

/datum/recipe/pastatomato
	fruit = list("tomato" = 2)
	reagents = list(/datum/reagent/water = 200)
	items = list(/obj/item/reagent_containers/food/spagetti)
	result = /obj/item/reagent_containers/food/pastatomato

/datum/recipe/pastatomato2
	fruit = list("tomato" = 2)
	items = list(/obj/item/reagent_containers/food/boiledspagetti)
	result = /obj/item/reagent_containers/food/pastatomato

/datum/recipe/faggotspagetti
	reagents = list(/datum/reagent/water = 200)
	items = list(
		/obj/item/reagent_containers/food/spagetti,
		/obj/item/reagent_containers/food/faggot,
		/obj/item/reagent_containers/food/faggot,
	)
	result = /obj/item/reagent_containers/food/faggotspagetti

/datum/recipe/faggotspagetti2
	items = list(
		/obj/item/reagent_containers/food/boiledspagetti,
		/obj/item/reagent_containers/food/faggot,
		/obj/item/reagent_containers/food/faggot,
	)
	result = /obj/item/reagent_containers/food/faggotspagetti

/datum/recipe/spesslaw
	reagents = list(/datum/reagent/water = 200)
	items = list(
		/obj/item/reagent_containers/food/spagetti,
		/obj/item/reagent_containers/food/faggot,
		/obj/item/reagent_containers/food/faggot,
		/obj/item/reagent_containers/food/faggot,
		/obj/item/reagent_containers/food/faggot,
	)
	result = /obj/item/reagent_containers/food/spesslaw

/datum/recipe/spesslaw2
	items = list(
		/obj/item/reagent_containers/food/boiledspagetti,
		/obj/item/reagent_containers/food/faggot,
		/obj/item/reagent_containers/food/faggot,
		/obj/item/reagent_containers/food/faggot,
		/obj/item/reagent_containers/food/faggot,
	)
	result = /obj/item/reagent_containers/food/spesslaw

/datum/recipe/superbiteburger
	fruit = list("tomato" = 1)
	reagents = list(/datum/reagent/salt = 5, /datum/reagent/blackpepper = 5)
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
	reagents = list(/datum/reagent/water = 25, /datum/reagent/sugar = 25)
	result = /obj/item/reagent_containers/food/candiedapple

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
	reagents = list(/datum/reagent/ethanol/wine = 20)
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
	reagents = list(/datum/reagent/blood = 300)
	result = /obj/item/reagent_containers/food/bloodsoup

/datum/recipe/metroidsoup
	reagents = list(/datum/reagent/water = 300, /datum/reagent/metroidjelly = 10)
	items = list()
	result = /obj/item/reagent_containers/food/metroidsoup

/datum/recipe/boiledmetroidextract
	reagents = list(/datum/reagent/water = 200)
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
	reagents = list(/datum/reagent/nutriment/flour = 50)
	items = list(
		/obj/item/reagent_containers/food/egg,
		/obj/item/reagent_containers/food/carpmeat,
	)
	result = /obj/item/reagent_containers/food/fishfingers
	amount = 3

/datum/recipe/mysterysoup
	reagents = list(/datum/reagent/water = 300)
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
	/datum/reagent/drink/milk = 150,
	/datum/reagent/nutriment/flour = 300,
	/datum/reagent/sugar = 120,
	/datum/reagent/nutriment/protein/egg = 90
	)
	result = /obj/item/reagent_containers/food/sliceable/pumpkinpie

/datum/recipe/plumphelmetbiscuit
	fruit = list("plumphelmet" = 1)
	reagents = list(/datum/reagent/water = 50, /datum/reagent/nutriment/flour = 50)
	result = /obj/item/reagent_containers/food/plumphelmetbiscuit

/datum/recipe/mushroomsoup
	fruit = list("mushroom" = 1)
	reagents = list(/datum/reagent/water = 100, /datum/reagent/drink/milk = 200)
	result = /obj/item/reagent_containers/food/mushroomsoup

/datum/recipe/chawanmushi
	fruit = list("mushroom" = 1)
	reagents = list(/datum/reagent/water = 50, /datum/reagent/nutriment/soysauce = 5)
	items = list(
		/obj/item/reagent_containers/food/egg,
		/obj/item/reagent_containers/food/egg
	)
	result = /obj/item/reagent_containers/food/chawanmushi

/datum/recipe/beetsoup
	fruit = list("whitebeet" = 1, "cabbage" = 1)
	reagents = list(/datum/reagent/water = 300)
	result = /obj/item/reagent_containers/food/beetsoup

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

/datum/recipe/validsalad/make_food(obj/container, result_mult = 1)
	var/list/result_objs = ..()
	for(var/obj/item/reagent_containers/food/validsalad/being_cooked in result_objs)
		being_cooked.reagents.del_reagent(/datum/reagent/toxin)
	return result_objs

/datum/recipe/cracker
	reagents = list(/datum/reagent/salt = 3)
	items = list(
		/obj/item/reagent_containers/food/doughslice
	)
	result = /obj/item/reagent_containers/food/cracker
	amount = 3

/datum/recipe/stuffing
	reagents = list(/datum/reagent/water = 5, /datum/reagent/salt = 1, /datum/reagent/blackpepper = 1)
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
		/obj/item/reagent_containers/food/faggot/raw
	)
	result = /obj/item/reagent_containers/food/faggot

/datum/recipe/cutlet
	items = list(
		/obj/item/reagent_containers/food/cutlet/raw
	)
	result = /obj/item/reagent_containers/food/cutlet

/datum/recipe/fries
	reagents = list(/datum/reagent/nutriment/oil = 30)
	items = list(
		/obj/item/reagent_containers/food/rawsticks
	)
	result = /obj/item/reagent_containers/food/fries

/datum/recipe/fries2
	reagents = list(/datum/reagent/nutriment/oil/corn = 30)
	items = list(
		/obj/item/reagent_containers/food/rawsticks
	)
	result = /obj/item/reagent_containers/food/fries

/datum/recipe/onionrings
	reagents = list(/datum/reagent/nutriment/oil = 15)
	fruit = list("onion" = 1)
	items = list(
		/obj/item/reagent_containers/food/doughslice
	)
	result = /obj/item/reagent_containers/food/onionrings

/datum/recipe/onionrings2
	reagents = list(/datum/reagent/nutriment/oil/corn = 15)
	fruit = list("onion" = 1)
	items = list(
		/obj/item/reagent_containers/food/doughslice
	)
	result = /obj/item/reagent_containers/food/onionrings

/datum/recipe/mint
	reagents = list(/datum/reagent/sugar = 1, /datum/reagent/frostoil = 1)
	result = /obj/item/reagent_containers/food/mint


// Cakes.
/datum/recipe/cake
	reagents = list(
	/datum/reagent/drink/milk = 150,
	/datum/reagent/nutriment/flour = 300,
	/datum/reagent/sugar = 120,
	/datum/reagent/nutriment/protein/egg = 90
	)
	result = /obj/item/reagent_containers/food/sliceable/plaincake

/datum/recipe/cake/carrot
	fruit = list("carrot" = 2)
	reagents = list(
	/datum/reagent/drink/milk = 150,
	/datum/reagent/nutriment/flour = 300,
	/datum/reagent/sugar = 120,
	/datum/reagent/nutriment/protein/egg = 90
	)
	result = /obj/item/reagent_containers/food/sliceable/carrotcake

/datum/recipe/cake/cheese
	items = list(
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge,
		/obj/item/reagent_containers/food/cheesewedge
	)
	reagents = list(
	/datum/reagent/drink/milk = 150,
	/datum/reagent/nutriment/flour = 300,
	/datum/reagent/sugar = 120,
	/datum/reagent/nutriment/protein/egg = 90
	)
	result = /obj/item/reagent_containers/food/sliceable/cheesecake

/datum/recipe/cake/orange
	fruit = list("orange" = 2)
	reagents = list(
	/datum/reagent/drink/milk = 150,
	/datum/reagent/nutriment/flour = 300,
	/datum/reagent/sugar = 120,
	/datum/reagent/nutriment/protein/egg = 90
	)
	result = /obj/item/reagent_containers/food/sliceable/orangecake

/datum/recipe/cake/lime
	fruit = list("lime" = 2)
	reagents = list(
	/datum/reagent/drink/milk = 150,
	/datum/reagent/nutriment/flour = 300,
	/datum/reagent/sugar = 120,
	/datum/reagent/nutriment/protein/egg = 90
	)
	result = /obj/item/reagent_containers/food/sliceable/limecake

/datum/recipe/cake/lemon
	fruit = list("lemon" = 2)
	reagents = list(
	/datum/reagent/drink/milk = 150,
	/datum/reagent/nutriment/flour = 300,
	/datum/reagent/sugar = 120,
	/datum/reagent/nutriment/protein/egg = 90
	)
	result = /obj/item/reagent_containers/food/sliceable/lemoncake

/datum/recipe/cake/chocolate
	reagents = list(
	/datum/reagent/drink/milk = 150,
	/datum/reagent/nutriment/flour = 300,
	/datum/reagent/sugar = 120,
	/datum/reagent/nutriment/protein/egg = 90,
	/datum/reagent/nutriment/coco = 60
	)
	result = /obj/item/reagent_containers/food/sliceable/chocolatecake

/datum/recipe/choccherrycake
	fruit = list("cherries" = 3)
	reagents = list(
	/datum/reagent/drink/milk = 150,
	/datum/reagent/nutriment/flour = 300,
	/datum/reagent/sugar = 120,
	/datum/reagent/nutriment/protein/egg = 90,
	/datum/reagent/nutriment/coco = 60
	)
	result = /obj/item/reagent_containers/food/sliceable/choccherrycake

/datum/recipe/cake/metroid
	items = list(/obj/item/metroid_extract)
	reagents = list(
	/datum/reagent/drink/milk = 150,
	/datum/reagent/nutriment/flour = 300,
	/datum/reagent/sugar = 120,
	/datum/reagent/nutriment/protein/egg = 90
	)
	result = /obj/item/reagent_containers/food/sliceable/metroidcake

/datum/recipe/cake/birthday
	items = list(/obj/item/clothing/head/cakehat)
	reagents = list(
	/datum/reagent/drink/milk = 150,
	/datum/reagent/nutriment/flour = 300,
	/datum/reagent/sugar = 120,
	/datum/reagent/nutriment/protein/egg = 90
	)
	result = /obj/item/reagent_containers/food/sliceable/birthdaycake

/datum/recipe/cake/apple
	fruit = list("apple" = 2)
	reagents = list(
	/datum/reagent/drink/milk = 150,
	/datum/reagent/nutriment/flour = 300,
	/datum/reagent/sugar = 120,
	/datum/reagent/nutriment/protein/egg = 90
	)
	result = /obj/item/reagent_containers/food/sliceable/applecake

/datum/recipe/cake/brain
	items = list(/obj/item/reagent_containers/food/organ/brain)
	reagents = list(
	/datum/reagent/drink/milk = 150,
	/datum/reagent/nutriment/flour = 300,
	/datum/reagent/sugar = 120,
	/datum/reagent/nutriment/protein/egg = 90
	)
	result = /obj/item/reagent_containers/food/sliceable/braincake

/datum/recipe/smokedsausage
	items = list(/obj/item/reagent_containers/food/sausage)
	reagents = list(/datum/reagent/salt = 5, /datum/reagent/blackpepper = 5)
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
	reagents = list(/datum/reagent/nutriment/garlicsauce = 15)
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
	items = list(/obj/item/reagent_containers/food/boiledspagetti, /obj/item/reagent_containers/food/cutlet)
	fruit = list("cabbage" = 2, "carrot" = 1)
	result = /obj/item/reagent_containers/food/chowmein

/datum/recipe/beefnoodles
	items = list(/obj/item/reagent_containers/food/boiledspagetti,/obj/item/reagent_containers/food/cutlet, /obj/item/reagent_containers/food/cutlet)
	fruit = list("cabbage" = 1)
	result = /obj/item/reagent_containers/food/beefnoodles

/datum/recipe/tortilla
	fruit = list("corn" = 1)
	reagents = list(/datum/reagent/nutriment/flour = 50)
	result = /obj/item/reagent_containers/food/tortilla

/datum/recipe/nachos
	items = list(/obj/item/reagent_containers/food/tortilla)
	reagents = list(/datum/reagent/salt = 1)
	result = /obj/item/reagent_containers/food/nachos

/datum/recipe/cheesenachos
	items = list(/obj/item/reagent_containers/food/tortilla,/obj/item/reagent_containers/food/cheesewedge)
	reagents = list(/datum/reagent/salt = 1)
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

/datum/recipe/bruschetta
	items = list(/obj/item/reagent_containers/food/cheesewedge)
	fruit = list("tomato" = 1, "garlic" = 1)
	reagents = list(/datum/reagent/water = 50, /datum/reagent/nutriment/flour = 100, /datum/reagent/salt = 5)
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
	amount = 4

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

/datum/recipe/capturedevice_hacked
	items = list(
		/obj/item/capturedevice
	)
	result = /obj/item/capturedevice/hacked
