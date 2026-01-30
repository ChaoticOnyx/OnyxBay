
/obj/item/reagent_containers/food/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	filling_color = "#fdffd1"
	volume = 60
	static_volume = TRUE
	center_of_mass = "x=16;y=13"
	startswith = list(
		/datum/reagent/nutriment/protein/egg = 4.5
		)
	bitesize = 3 // 56.25 nutrition, 2 bites

/obj/item/reagent_containers/food/egg/afterattack(obj/O, mob/user, proximity)
	if(istype(O,/obj/machinery/microwave))
		return ..()
	if(!(proximity && O.is_open_container()))
		return
	to_chat(user, "You crack \the [src] into \the [O].")
	reagents.trans_to(O, reagents.total_volume)
	qdel(src)

/obj/item/reagent_containers/food/egg/throw_impact(atom/hit_atom)
	..()
	if(QDELETED(src))
		return // Could be happened hitby()
	new /obj/effect/decal/cleanable/egg_smudge(src.loc)
	src.reagents.splash(hit_atom, src.reagents.total_volume)
	src.visible_message("<span class='warning'>\The [src] has been squashed!</span>","<span class='warning'>You hear a smack.</span>")
	qdel(src)

/obj/item/reagent_containers/food/egg/attackby(obj/item/W, mob/user)
	if(istype( W, /obj/item/pen/crayon ))
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
		/datum/reagent/nutriment/protein/egg = 4.5,
		/datum/reagent/nanites = 0.1
		)

/obj/item/reagent_containers/food/egg/golden
	name = "golden egg"
	icon_state = "egg-golden"
	startswith = list(
		/datum/reagent/nutriment/protein/egg = 4.5,
		/datum/reagent/gold = 1.5
		)

/obj/item/reagent_containers/food/egg/plasma
	name = "plasma egg"
	icon_state = "egg-plasma"
	startswith = list(
		/datum/reagent/nutriment/protein/egg = 4.5,
		/datum/reagent/toxin/plasma = 1.5
		)

/obj/item/reagent_containers/food/vegg
	name = "vegg"
	desc = "So... It's more like a seed, right?"
	icon_state = "egg-vegan"
	filling_color = "#70bf70"
	volume = 6
	static_volume = TRUE
	center_of_mass = "x=16;y=13"
	nutriment_amt = 5
	bitesize = 3 // 5 nutrition, 2 bites

/obj/item/reagent_containers/food/boiledegg
	name = "Boiled egg"
	desc = "A hard boiled egg."
	icon_state = "egg"
	filling_color = "#ffffff"
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 4.5
		)
	bitesize = 2.5 // 112.5 nutrition, 2 bites

/obj/item/reagent_containers/food/friedegg
	name = "Fried egg"
	desc = "A fried egg, with a touch of salt and pepper."
	icon_state = "friedegg"
	filling_color = "#ffdf78"
	center_of_mass = "x=16;y=14"
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 4.5,
		/datum/reagent/salt = 1,
		/datum/reagent/blackpepper = 1,
		/datum/reagent/nutriment/oil = 1.5
		)
	bitesize = 1.5 // ~15.75 nutrition, 5 bites

/obj/item/reagent_containers/food/omelette
	name = "Omelette Du Fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	trash = /obj/item/trash/dish/plate
	filling_color = "#fff9a8"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("cheese" = 2, "omelette" = 3)
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 11
		)
	bitesize = 3 // 34.5 nutrition, 6 bites

/obj/item/reagent_containers/food/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#f0f2e4"
	center_of_mass = "x=17;y=10"
	nutriment_desc = list("eggs" = 3, "friendship" = 1)
	nutriment_amt = 5.5
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 9,
		/datum/reagent/nutriment/soysauce = 1
		)
	bitesize = 3 // 28 nutrition, 5 bites

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
