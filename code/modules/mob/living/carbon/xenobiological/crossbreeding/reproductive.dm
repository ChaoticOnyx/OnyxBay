/*
Reproductive extracts:
	When fed three monkey cubes, produces between
	1 and 4 normal slime extracts of the same colour.
*/


/obj/item/metroidcross/reproductive
	name = "reproductive extract"
	desc = "It pulses with a strange hunger."
	icon_state = "reproductive"
	effect = "reproductive"
	effect_desc = "When fed monkey cubes it produces more extracts. Bio bag compatible as well."
	var/extract_type = /obj/item/metroid_extract/
	var/cooldown = 3 SECONDS
	var/feedAmount = 3
	var/last_produce = 0

/obj/item/metroidcross/reproductive/_examine_text(mob/user)
	. = ..()
	. += SPAN_DANGER("It appears to have eaten [length(contents)] Monkey Cube")

/obj/item/metroidcross/reproductive/Initialize(mapload)
	. = ..()
	//FIXME create_storage(type = /datum/storage/extract_inventory)

/obj/item/metroidcross/reproductive/attackby(obj/item/O, mob/user)
	/* FIXME
	var/datum/storage/extract_inventory/slime_storage = atom_storage
	if(!istype(slime_storage))
		return

	if((last_produce + cooldown) > world.time)
		to_chat(user, SPAN_WARNING("[src] is still digesting!"))
		return

	if(length(contents) >= feedAmount) //if for some reason the contents are full, but it didnt digest, attempt to digest again
		to_chat(user, SPAN_WARNING("[src] appears to be full but is not digesting! Maybe poking it stimulated it to digest."))
		slime_storage?.processCubes(user)
		return

	if(istype(O, /obj/item/storage/bag/xenobiology))
		var/list/inserted = list()
		O.atom_storage.remove_type(/obj/item/reagent_containers/food/monkeycube, src, feedAmount - length(contents), TRUE, FALSE, user, inserted)
		if(inserted.len)
			to_chat(user, SPAN_NOTICE("You feed [length(inserted)] Monkey Cube[p_s()] to [src], and it pulses gently."))
			playsound(src, 'sound/items/eatfood.ogg', 20, TRUE)
			slime_storage?.processCubes(user)
		else
			to_chat(user, SPAN_WARNING("There are no monkey cubes in the bio bag!"))
		return

	elseif(istype(O, /obj/item/reagent_containers/food/monkeycube))
		if(atom_storage?.attempt_insert(O, user, override = TRUE, force = TRUE))
			to_chat(user, SPAN_NOTICE("You feed 1 Monkey Cube to [src], and it pulses gently."))
			slime_storage?.processCubes(user)
			playsound(src, 'sound/items/eatfood.ogg', 20, TRUE)
			return
		else
			to_chat(user, SPAN_NOTICE("The [src] rejects the Monkey Cube!")) //in case it fails to insert for whatever reason you get feedback
	*/

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
