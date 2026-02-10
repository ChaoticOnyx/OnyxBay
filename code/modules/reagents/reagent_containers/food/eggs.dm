
/obj/item/reagent_containers/food/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	filling_color = "#fdffd1"
	volume = 60
	static_volume = TRUE
	center_of_mass = "x=16;y=13"
	startswith = list(
		/datum/reagent/nutriment/protein/egg = 45
		)
	bitesize = 30 // 56.25 nutrition, 2 bites

	var/colorable = TRUE
	var/amount_grown = 0
	var/max_growth = 300 // How many seconds it takes to hatch
	var/whos_that_pokemon = null
	var/hatch_data = null

/obj/item/reagent_containers/food/egg/Initialize()
	. = ..()
	if(whos_that_pokemon)
		make_fertile(whos_that_pokemon)

/obj/item/reagent_containers/food/egg/Destroy()
	hatch_data = null
	return ..()

/obj/item/reagent_containers/food/egg/think()
	if(!ismob(loc) && !isturf(loc)) // So that we can store these in a fridge without causing chickpocalypse
		set_next_think(world.time + 10 SECONDS)
		return

	amount_grown++

	if(amount_grown >= max_growth)
		if(prob(20))
			hatch()
		else
			set_next_think(world.time + 5 SECONDS)
		return

	if(amount_grown == max_growth * 0.75) // Disguisting. And a bit more nutritive.
		desc += " It feels warm to the touch."
		reagents.add_reagent(/datum/reagent/blood, 10)

	set_next_think(world.time + 1 SECOND)
	return

/obj/item/reagent_containers/food/egg/proc/make_fertile(pokemon_type, _hatch_data = null)
	if(!pokemon_type)
		return FALSE
	whos_that_pokemon = pokemon_type
	hatch_data = _hatch_data
	set_next_think(world.time + 1 SECOND)
	return TRUE

/obj/item/reagent_containers/food/egg/proc/hatch(silent = FALSE)
	if(!whos_that_pokemon)
		return FALSE
	if(!silent)
		visible_message("[src] hatches with a quiet cracking sound.")

	var/mob/M = new whos_that_pokemon(get_turf(src))

	if(istype(M, /mob/living/simple_animal/chick))
		var/mob/living/simple_animal/chick/C = M
		C.species = hatch_data
	else if(istype(M, /mob/living/simple_animal/lizard))
		var/mob/living/simple_animal/lizard/L = M
		L.setPoison(hatch_data)
		L.last_breed = world.time

	qdel_self()
	return TRUE

/obj/item/reagent_containers/food/egg/afterattack(obj/O, mob/user, proximity)
	if(istype(O,/obj/machinery/microwave))
		return ..()
	if(!(proximity && O.is_open_container()))
		return

	if(amount_grown >= max_growth * 0.9)
		to_chat(user, "You crack \the [src], and something suddenly hatches from it!")
		hatch(TRUE)
		return

	to_chat(user, "You crack \the [src] into \the [O].")
	reagents.trans_to(O, reagents.total_volume)
	qdel(src)
	return

/obj/item/reagent_containers/food/egg/throw_impact(atom/hit_atom)
	..()
	if(QDELETED(src))
		return // Could be happened hitby()

	if(amount_grown >= max_growth * 0.9)
		visible_message(SPAN("warning", "\The [src] cracks, and something suddenly hatches from it!"), SPAN("warning", "You hear a smack."))
		hatch(TRUE)
		return

	new /obj/effect/decal/cleanable/egg_smudge(src.loc)
	src.reagents.splash(hit_atom, src.reagents.total_volume)
	src.visible_message("<span class='warning'>\The [src] has been squashed!</span>","<span class='warning'>You hear a smack.</span>")
	qdel(src)
	return

/obj/item/reagent_containers/food/egg/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/pen/crayon) && colorable)
		var/obj/item/pen/crayon/C = W
		var/clr = C.colourName

		if(!(clr in list("blue","green","mime","orange","purple","rainbow","red","yellow")))
			to_chat(usr, "<span class='notice'>The egg refuses to take on this color!</span>")
			return

		to_chat(usr, "<span class='notice'>You color \the [src] [clr]</span>")
		icon_state = "egg-[clr]"
	else
		..()

/obj/item/reagent_containers/food/egg/randomcolor/Initialize()
	. = ..()
	var/clr = pick("blue","green","mime","orange","purple","rainbow","red","yellow")
	icon_state = "egg-[clr]"

/obj/item/reagent_containers/food/egg/blue
	icon_state = "egg-blue"

/obj/item/reagent_containers/food/egg/green
	icon_state = "egg-green"

/obj/item/reagent_containers/food/egg/mime
	icon_state = "egg-mime"

/obj/item/reagent_containers/food/egg/orange
	icon_state = "egg-orange"

/obj/item/reagent_containers/food/egg/purple
	icon_state = "egg-purple"

/obj/item/reagent_containers/food/egg/rainbow
	icon_state = "egg-rainbow"

/obj/item/reagent_containers/food/egg/red
	icon_state = "egg-red"

/obj/item/reagent_containers/food/egg/yellow
	icon_state = "egg-yellow"

/obj/item/reagent_containers/food/egg/robot
	name = "robot egg"
	icon_state = "egg-robot"
	startswith = list(
		/datum/reagent/nutriment/protein/egg = 45,
		/datum/reagent/nanites = 1
		)
	colorable = FALSE

/obj/item/reagent_containers/food/egg/golden
	name = "golden egg"
	icon_state = "egg-golden"
	startswith = list(
		/datum/reagent/nutriment/protein/egg = 45,
		/datum/reagent/gold = 15
		)
	colorable = FALSE

/obj/item/reagent_containers/food/egg/plasma
	name = "plasma egg"
	icon_state = "egg-plasma"
	startswith = list(
		/datum/reagent/nutriment/protein/egg = 45,
		/datum/reagent/toxin/plasma = 15
		)

/obj/item/reagent_containers/food/egg/fertile
	whos_that_pokemon = /mob/living/simple_animal/chick

// Lizzy eggies
/obj/item/reagent_containers/food/egg/lizard
	name = "tiny egg"
	icon_state = "lizegg"
	item_state = "egg"
	colorable = FALSE

/obj/item/reagent_containers/food/egg/lizard/make_fertile(pokemon_type, _hatch_data = null)
	. = ..()
	if(!.)
		return FALSE
	if(_hatch_data)
		reagents.add_reagent(_hatch_data, 5)
	update_icon()
	return TRUE

/obj/item/reagent_containers/food/egg/lizard/on_update_icon()
	ClearOverlays()
	var/overlay_color = null
	for(var/datum/reagent/R in reagents.reagent_list)
		if(istype(R, /datum/reagent/nutriment/protein/egg))
			continue
		overlay_color = R.color // Since we only do this after spawning the egg, there shouldn't be anything but the lizardish poison
	if(!overlay_color)
		overlay_color = "#00C000"
	var/image/I = new(icon, "[icon_state]-over")
	I.color = overlay_color
	AddOverlays(I)
	return

/obj/item/reagent_containers/food/egg/lizard/fertile
	whos_that_pokemon = /mob/living/simple_animal/lizard

/obj/item/reagent_containers/food/egg/lizard/fertile/random/make_fertile(pokemon_type, _hatch_data = null)
	. = ..()
	if(!.)
		return FALSE
	hatch_data = pick(POSSIBLE_LIZARD_TOXINS)
	reagents.add_reagent(hatch_data, 5)
	update_icon()
	return TRUE

////////////////////
// Actual foodies //
////////////////////
/obj/item/reagent_containers/food/vegg
	name = "vegg"
	desc = "So... It's more like a seed, right?"
	icon_state = "egg-vegan"
	filling_color = "#70bf70"
	volume = 60
	static_volume = TRUE
	center_of_mass = "x=16;y=13"
	nutriment_amt = 50
	bitesize = 30 // 50 nutrition, 2 bites

/obj/item/reagent_containers/food/boiledegg
	name = "Boiled egg"
	desc = "A hard boiled egg."
	icon_state = "egg"
	filling_color = "#ffffff"
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 45
		)
	bitesize = 25 // 112.5 nutrition, 2 bites

/obj/item/reagent_containers/food/friedegg
	name = "Fried egg"
	desc = "A fried egg, with a touch of salt and pepper."
	icon_state = "friedegg"
	filling_color = "#ffdf78"
	center_of_mass = "x=16;y=14"
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 45,
		/datum/reagent/salt = 1,
		/datum/reagent/blackpepper = 1,
		/datum/reagent/nutriment/oil = 15
		)
	bitesize = 12.5 // 157.5 nutrition, 5 bites

/obj/item/reagent_containers/food/omelette
	name = "Omelette Du Fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	trash = /obj/item/trash/dish/plate
	filling_color = "#fff9a8"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("cheese" = 2, "omelette" = 3)
	nutriment_amt = 70
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 110
		)
	bitesize = 30 // 345 nutrition, 6 bites

/obj/item/reagent_containers/food/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#f0f2e4"
	center_of_mass = "x=17;y=10"
	nutriment_desc = list("eggs" = 3, "friendship" = 1)
	nutriment_amt = 55
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 90,
		/datum/reagent/nutriment/soysauce = 5
		)
	bitesize = 30 // 280 nutrition, 5 bites

/obj/item/reagent_containers/food/eggsbenedict
	name = "Eggs Benedict"
	desc = "It's has only one egg, how rough."
	icon_state = "eggsbenedict"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	nutriment_amt = 6
	startswith = list(/datum/reagent/nutriment/protein = 4)
	bitesize = 4

/obj/item/reagent_containers/food/eggwrap
	name = "Egg Wrap"
	desc = "Eggs, cabbage, and soy. Interesting."
	icon_state = "eggwrap"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 5
	startswith = list(/datum/reagent/nutriment/soysauce = 10)
	bitesize = 4
