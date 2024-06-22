

/datum/recipe/dumplings //Missing Recipe
	fruit = list("cabbage" = 1) // A recipe that ACTUALLY uses cabbage.
	reagents = list("soysauce" = 5, "sodiumchloride" = 1, "blackpepper" = 1, "cornoil" = 1) // No sesame oil, corn will have to do.
	items = list(
		/obj/item/reagent_containers/food/rawbacon,
		/obj/item/reagent_containers/food/rawbacon, // Substitute for minced pork.
		/obj/item/reagent_containers/food/doughslice,
	)
	result = /obj/item/reagent_containers/food/dumplings

//Somethin' the fuck else

/datum/recipe/donkpocket
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/meatball
	)
	result = /obj/item/reagent_containers/food/donkpocket //SPECIAL
	proc/warm_up(var/obj/item/reagent_containers/food/donkpocket/being_cooked)
		being_cooked.heat()
	make_food(var/obj/container as obj)
		var/obj/item/reagent_containers/food/donkpocket/being_cooked = ..(container)
		warm_up(being_cooked)
		return being_cooked

/datum/recipe/donkpocket/warm
	reagents = list() //This is necessary since this is a child object of the above recipe and we don't want donk pockets to need flour
	items = list(
		/obj/item/reagent_containers/food/donkpocket
	)
	result = /obj/item/reagent_containers/food/donkpocket //SPECIAL
	make_food(var/obj/container as obj)
		var/obj/item/reagent_containers/food/donkpocket/being_cooked = locate() in container
		if(being_cooked && !being_cooked.warm)
			warm_up(being_cooked)
		return being_cooked

/datum/recipe/soylenviridians
	fruit = list("soybeans" = 1)
	reagents = list("flour" = 10)
	result = /obj/item/reagent_containers/food/soylenviridians

/datum/recipe/soylentgreen
	reagents = list("flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/meat/human,
		/obj/item/reagent_containers/food/meat/human
	)
	result = /obj/item/reagent_containers/food/soylentgreen

/datum/recipe/chaosdonut
	reagents = list("frostoil" = 5, "capsaicin" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/dough
	)
	result = /obj/item/reagent_containers/food/donut/chaos

/datum/recipe/cubancarp
	fruit = list("chili" = 1)
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/meat/carp
	)
	result = /obj/item/reagent_containers/food/cubancarp

/datum/recipe/fortunecookie
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/doughslice,
		/obj/item/paper,
	)
	result = /obj/item/reagent_containers/food/fortunecookie
	make_food(var/obj/container as obj)
		var/obj/item/paper/paper = locate() in container
		paper.loc = null //prevent deletion
		var/obj/item/reagent_containers/food/fortunecookie/being_cooked = ..(container)
		paper.loc = being_cooked
		being_cooked.trash = paper //so the paper is left behind as trash without special-snowflake(TM Nodrak) code ~carn
		return being_cooked
	check_items(var/obj/container as obj)
		. = ..()
		if (.)
			var/obj/item/paper/paper = locate() in container
			if (!paper || !paper.info)
				return 0
		return .

/datum/recipe/friedchicken
	reagents = list("cornoil" = 5, "sodiumchloride" = 1, "blackpepper" = 1, "flour" = 5)
	items = list(/obj/item/reagent_containers/food/chickenbreast)
	result = /obj/item/reagent_containers/food/friedchicken

/datum/recipe/tonkatsu
	reagents = list("sodiumchloride" = 1, "flour" = 5, "egg" = 3, "cornoil" = 2)
	items = list(
		/obj/item/reagent_containers/food/meat/pork,
	)
	result = /obj/item/reagent_containers/food/tonkatsu

/datum/recipe/spacylibertyduff
	reagents = list("water" = 5, "vodka" = 5, "psilocybin" = 5)
	result = /obj/item/reagent_containers/food/spacylibertyduff

/datum/recipe/enchiladas
	fruit = list("chili" = 2, "corn" = 1)
	items = list(/obj/item/reagent_containers/food/cutlet)
	result = /obj/item/reagent_containers/food/enchiladas

/datum/recipe/monkeysdelight
	fruit = list("banana" = 1)
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/monkeycube
	)
	result = /obj/item/reagent_containers/food/monkeysdelight

/datum/recipe/fishandchips
	items = list(
		/obj/item/reagent_containers/food/fries,
		/obj/item/reagent_containers/food/fishfingers,
	)
	result = /obj/item/reagent_containers/food/fishandchips

/datum/recipe/katsudon
	reagents = list("egg" = 3, "soysauce" = 5)
	items = list(
		/obj/item/reagent_containers/food/boiledrice,
		/obj/item/reagent_containers/food/tonkatsu,
		)
	result = /obj/item/reagent_containers/food/katsudon

/datum/recipe/fishfingers
	reagents = list("flour" = 5, "egg" = 3, "cornoil" = 2)
	items = list(
		/obj/item/reagent_containers/food/meat/carp,
	)
	result = /obj/item/reagent_containers/food/fishfingers

/datum/recipe/honey_bun
	reagents = list("sugar" = 3, "honey" = 5, "cream" = 5)
	items = list(
		/obj/item/reagent_containers/food/dough,
		/obj/item/reagent_containers/food/butterslice,
	)
	result = /obj/item/reagent_containers/food/honeybuns

/datum/recipe/honey_pudding
	reagents = list("sugar" = 3, "honey" = 15, "cream" = 5)
	items = list(
		/obj/item/reagent_containers/food/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/honeypudding
