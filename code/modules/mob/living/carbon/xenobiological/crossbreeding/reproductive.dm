#define REPRODUCTIVE_EXTRACT_VOLUME 3
#define DIGESTION_COOLDOWN 3 SECONDS

/obj/item/metroidcross/reproductive
	name = "reproductive extract"
	desc = "It pulses with a strange hunger."
	icon_state = "reproductive"
	effect = "reproductive"
	effect_desc = "When fed monkey cubes it produces more extracts. Bio bag compatible as well."

	var/extract_type = /obj/item/metroid_extract

	var/meals_left = REPRODUCTIVE_EXTRACT_VOLUME

	var/last_meal = 0

/obj/item/metroidcross/reproductive/examine(mob/user, infix)
	. = ..()
	. += SPAN("notice", "It looks like it has space for [meals_left] more cubes.")

/obj/item/metroidcross/reproductive/attackby(obj/item/O, mob/user)
	if((last_meal + DIGESTION_COOLDOWN) > world.time)
		show_splash_text(user, "still digesting!", "\The [src] is still digesting!")
		return

	if(istype(O, /obj/item/reagent_containers/food/monkeycube))
		if(!_feed_extract(O))
			return
		show_splash_text(user, "cube was successfuly fed.", "You feed \the [src] with \the [O].")

	if(istype(O, /obj/item/storage/xenobag))
		if(!_feed_extracts_from_bag(O, user))
			return
		show_splash_text(user, "extract was successfuly fed from bag.", "You feed \the [src] from \the [O].")

	_reproduce()

/obj/item/metroidcross/reproductive/proc/_feed_extract(obj/item/reagent_containers/food/monkeycube/cube)
	if(!istype(cube))
		return FALSE

	if(meals_left <= 0)
		return FALSE

	meals_left -= 1

	qdel(cube)
	playsound(src, 'sound/items/eatfood.ogg', 20, TRUE)

	return TRUE

/obj/item/metroidcross/reproductive/proc/_feed_extracts_from_bag(obj/item/storage/xenobag/bag)
	if(!istype(bag))
		return FALSE

	if(!length(bag.contents))
		return FALSE

	var/meals_left_temp = meals_left
	for(var/obj/item/reagent_containers/food/monkeycube/M in bag.contents)
		if(meals_left <= 0)
			break

		bag.remove_from_storage(M, src)
		_feed_extract(M)
	if(meals_left_temp == meals_left)
		return FALSE

	return TRUE

/obj/item/metroidcross/reproductive/proc/_reproduce()
	if(meals_left > 0)
		return

	show_splash_text_to_viewers("starts to swell!", "\The [src] starts to swell!")
	meals_left = REPRODUCTIVE_EXTRACT_VOLUME
	last_meal = world.time

	for(var/i in 1 to rand(1,4))
		new extract_type(get_turf(src))

#undef REPRODUCTIVE_EXTRACT_VOLUME
#undef DIGESTION_COOLDOWN

/obj/item/metroidcross/reproductive/grey
	extract_type = /obj/item/metroid_extract/grey
	colour = "grey"

/obj/item/metroidcross/reproductive/orange
	extract_type = /obj/item/metroid_extract/orange
	colour = "orange"

/obj/item/metroidcross/reproductive/purple
	extract_type = /obj/item/metroid_extract/purple
	colour = "purple"

/obj/item/metroidcross/reproductive/blue
	extract_type = /obj/item/metroid_extract/blue
	colour = "blue"

/obj/item/metroidcross/reproductive/metal
	extract_type = /obj/item/metroid_extract/metal
	colour = "metal"

/obj/item/metroidcross/reproductive/yellow
	extract_type = /obj/item/metroid_extract/yellow
	colour = "yellow"

/obj/item/metroidcross/reproductive/darkpurple
	extract_type = /obj/item/metroid_extract/darkpurple
	colour = "dark purple"

/obj/item/metroidcross/reproductive/darkblue
	extract_type = /obj/item/metroid_extract/darkblue
	colour = "dark blue"

/obj/item/metroidcross/reproductive/silver
	extract_type = /obj/item/metroid_extract/silver
	colour = "silver"

/obj/item/metroidcross/reproductive/bluespace
	extract_type = /obj/item/metroid_extract/bluespace
	colour = "bluespace"

/obj/item/metroidcross/reproductive/sepia
	extract_type = /obj/item/metroid_extract/sepia
	colour = "sepia"

/obj/item/metroidcross/reproductive/cerulean
	extract_type = /obj/item/metroid_extract/cerulean
	colour = "cerulean"

/obj/item/metroidcross/reproductive/pyrite
	extract_type = /obj/item/metroid_extract/pyrite
	colour = "pyrite"

/obj/item/metroidcross/reproductive/red
	extract_type = /obj/item/metroid_extract/red
	colour = "red"

/obj/item/metroidcross/reproductive/green
	extract_type = /obj/item/metroid_extract/green
	colour = "green"

/obj/item/metroidcross/reproductive/pink
	extract_type = /obj/item/metroid_extract/pink
	colour = "pink"

/obj/item/metroidcross/reproductive/gold
	extract_type = /obj/item/metroid_extract/gold
	colour = "gold"

/obj/item/metroidcross/reproductive/oil
	extract_type = /obj/item/metroid_extract/oil
	colour = "oil"

/obj/item/metroidcross/reproductive/black
	extract_type = /obj/item/metroid_extract/black
	colour = "black"

/obj/item/metroidcross/reproductive/lightpink
	extract_type = /obj/item/metroid_extract/lightpink
	colour = "light pink"

/obj/item/metroidcross/reproductive/adamantine
	extract_type = /obj/item/metroid_extract/adamantine
	colour = "adamantine"

/obj/item/metroidcross/reproductive/rainbow
	extract_type = /obj/item/metroid_extract/rainbow
	colour = "rainbow"
