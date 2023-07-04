/*
Reproductive extracts:
	When fed three monkey cubes, produces between
	1 and 4 normal metroid extracts of the same colour.
*/


/obj/item/metroidcross/reproductive
	name = "reproductive extract"
	desc = "It pulses with a strange hunger."
	icon_state = "reproductive"
	effect = "reproductive"
	effect_desc = "When fed monkey cubes it produces more extracts. Bio bag compatible as well."
	var/extract_type = /obj/item/metroid_extract
	var/cooldown = 5 SECONDS
	var/feedAmount = 3
	var/last_produce = 0

/obj/item/metroidcross/reproductive/_examine_text(mob/user)
	. = ..()
	. += SPAN_DANGER("It appears to need eat [feedAmount] monkey cubes more")

/obj/item/metroidcross/reproductive/Initialize(mapload)
	. = ..()

/obj/item/metroidcross/reproductive/attackby(obj/item/O, mob/user)
	if((last_produce + cooldown) > world.time)
		to_chat(user, SPAN_WARNING("[src] is still digesting!"))
		return

	if(istype(O, /obj/item/reagent_containers/food/monkeycube))
		if(feedAmount>0)
			to_chat(user, SPAN_NOTICE("You feed 1 Monkey Cube to [src], and it pulses gently."))
			feedAmount-=1
			playsound(src, 'sound/items/eatfood.ogg', 20, TRUE)
			qdel(O)
			last_produce = world.time + cooldown
		else
			to_chat(user, SPAN_NOTICE("The [src] rejects the Monkey Cube!")) //in case it fails to insert for whatever reason you get feedback
	else
		to_chat(user, SPAN_NOTICE("The [src] rejects the [O]!"))

	if(feedAmount<=0)
		feedAmount=3
		visible_message(SPAN_NOTICE("The [src] starts to fizzle!"))
		spawn(cooldown)
		for(var/i in 1 to rand(1,4))
			new extract_type(get_turf(src))


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
