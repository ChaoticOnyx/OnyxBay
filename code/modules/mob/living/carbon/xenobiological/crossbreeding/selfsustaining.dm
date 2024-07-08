/*
Self-sustaining extracts:
	Produces 4 extracts that do not need reagents.
*/
/obj/item/metroidcross/selfsustaining
	name = "self-sustaining extract"
	effect = "self-sustaining"
	icon_state = "selfsustaining"
	var/extract_type = /obj/item/metroid_extract

/obj/item/autometroid
	name = "autometroid"
	desc = "It resembles a normal metroid extract, but seems filled with a strange, multi-colored fluid."
	var/obj/item/metroid_extract/extract
	var/effect_desc = "A self-sustaining metroid extract. When used, lets you choose which reaction you want."
	can_get_wet = FALSE
	can_be_wrung_out = FALSE

//Just divides into the actual item.
/obj/item/metroidcross/selfsustaining/Initialize(mapload)
	..()
	visible_message(SPAN_WARNING("The [src] shudders, and splits into four smaller extracts."))
	var/amount = rand(1,4)
	for(var/i in 1 to amount)
		var/obj/item/autometroid/A = new /obj/item/autometroid(src.loc)
		var/obj/item/metroid_extract/X = new extract_type(A)
		A.extract = X
		A.icon = icon
		A.icon_state = icon_state
		A.color = color
		A.name = "self-sustaining " + colour + " extract"
	return INITIALIZE_HINT_QDEL

/obj/item/autometroid/Initialize(mapload)
	return ..()

/obj/item/autometroid/attack_self(mob/user)
	var/reagentselect = tgui_input_list(user, "Reagent the extract will produce.", "Self-sustaining Reaction", sort_list(extract.activate_reagents, /proc/cmp_name_or_type_asc))
	if(isnull(reagentselect))
		return
	var/amount = 5
	var/secondary

	if (user.get_active_item() != src || user.stat != CONSCIOUS || user.restrained())
		return
	if(!reagentselect)
		return
	if(reagentselect == "Plasma")
		reagentselect = /datum/reagent/toxin/plasma
	if(reagentselect == "Water")
		reagentselect = /datum/reagent/water
	if(reagentselect == "Blood")
		reagentselect = /datum/reagent/blood
	if(reagentselect == "Metroid Jelly")
		reagentselect = /datum/reagent/metroidjelly

	extract.forceMove(user.drop_location())
	qdel(src)
	user.put_in_active_hand(extract)
	extract.reagents.add_reagent(reagentselect,amount)
	if(secondary)
		extract.reagents.add_reagent(secondary,amount)

/obj/item/autometroid/examine(mob/user, infix)
	. = ..()

	if(effect_desc)
		. += SPAN_NOTICE("[effect_desc]")

//Different types.

/obj/item/metroidcross/selfsustaining/grey
	extract_type = /obj/item/metroid_extract/grey
	colour = "grey"

/obj/item/metroidcross/selfsustaining/orange
	extract_type = /obj/item/metroid_extract/orange
	colour = "orange"

/obj/item/metroidcross/selfsustaining/purple
	extract_type = /obj/item/metroid_extract/purple
	colour = "purple"

/obj/item/metroidcross/selfsustaining/blue
	extract_type = /obj/item/metroid_extract/blue
	colour = "blue"

/obj/item/metroidcross/selfsustaining/metal
	extract_type = /obj/item/metroid_extract/metal
	colour = "metal"

/obj/item/metroidcross/selfsustaining/yellow
	extract_type = /obj/item/metroid_extract/yellow
	colour = "yellow"

/obj/item/metroidcross/selfsustaining/darkpurple
	extract_type = /obj/item/metroid_extract/darkpurple
	colour = "dark purple"

/obj/item/metroidcross/selfsustaining/darkblue
	extract_type = /obj/item/metroid_extract/darkblue
	colour = "dark blue"

/obj/item/metroidcross/selfsustaining/silver
	extract_type = /obj/item/metroid_extract/silver
	colour = "silver"

/obj/item/metroidcross/selfsustaining/bluespace
	extract_type = /obj/item/metroid_extract/bluespace
	colour = "bluespace"

/obj/item/metroidcross/selfsustaining/sepia
	extract_type = /obj/item/metroid_extract/sepia
	colour = "sepia"

/obj/item/metroidcross/selfsustaining/cerulean
	extract_type = /obj/item/metroid_extract/cerulean
	colour = "cerulean"

/obj/item/metroidcross/selfsustaining/pyrite
	extract_type = /obj/item/metroid_extract/pyrite
	colour = "pyrite"

/obj/item/metroidcross/selfsustaining/red
	extract_type = /obj/item/metroid_extract/red
	colour = "red"

/obj/item/metroidcross/selfsustaining/green
	extract_type = /obj/item/metroid_extract/green
	colour = "green"

/obj/item/metroidcross/selfsustaining/pink
	extract_type = /obj/item/metroid_extract/pink
	colour = "pink"

/obj/item/metroidcross/selfsustaining/gold
	extract_type = /obj/item/metroid_extract/gold
	colour = "gold"

/obj/item/metroidcross/selfsustaining/oil
	extract_type = /obj/item/metroid_extract/oil
	colour = "oil"

/obj/item/metroidcross/selfsustaining/black
	extract_type = /obj/item/metroid_extract/black
	colour = "black"

/obj/item/metroidcross/selfsustaining/lightpink
	extract_type = /obj/item/metroid_extract/lightpink
	colour = "light pink"

/obj/item/metroidcross/selfsustaining/adamantine
	extract_type = /obj/item/metroid_extract/adamantine
	colour = "adamantine"

/obj/item/metroidcross/selfsustaining/rainbow
	extract_type = /obj/item/metroid_extract/rainbow
	colour = "rainbow"
