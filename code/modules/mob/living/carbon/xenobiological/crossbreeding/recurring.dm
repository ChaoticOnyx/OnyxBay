/*
Recurring extracts:
	Generates a new charge every few seconds.
	If depleted of its' last charge, stops working.
*/
/obj/item/metroidcross/recurring
	name = "recurring extract"
	desc = "A tiny, glowing core, wrapped in several layers of goo."
	effect = "recurring"
	icon_state = "recurring"
	var/extract_type
	var/obj/item/metroid_extract/extract
	var/cooldown = 0
	var/max_cooldown = 10 // In seconds

/obj/item/metroidcross/recurring/Initialize(mapload)
	. = ..()
	extract = new extract_type(src.loc)
	visible_message(SPAN_NOTICE("[src] wraps a layer of goo around itself!"))
	extract.name = name
	extract.desc = desc
	extract.icon = icon
	extract.icon_state = icon_state
	extract.color = color
	extract.recurring = TRUE
	src.forceMove(extract)
	set_next_think(world.time + 1 SECOND)

/obj/item/metroidcross/recurring/think()
	if(cooldown > 0)
		cooldown -= world.time
	else if(extract.Uses < 10 && extract.Uses > 0)
		extract.Uses++
		cooldown = world.time+max_cooldown
	else if(extract.Uses <= 0)
		extract.visible_message(SPAN_WARNING("The light inside [extract] flickers and dies out."))
		extract.desc = "A tiny, inert core, bleeding dark, cerulean-colored goo."
		extract.icon_state = "prismatic"
		set_next_think(0)
		qdel(src)
	set_next_think(world.time + 1 SECOND)


/obj/item/metroidcross/recurring/Destroy()
	. = ..()
	set_next_think(0)

/obj/item/metroidcross/recurring/grey
	extract_type = /obj/item/metroid_extract/grey
	colour = "grey"

/obj/item/metroidcross/recurring/orange
	extract_type = /obj/item/metroid_extract/orange
	colour = "orange"

/obj/item/metroidcross/recurring/purple
	extract_type = /obj/item/metroid_extract/purple
	colour = "purple"

/obj/item/metroidcross/recurring/blue
	extract_type = /obj/item/metroid_extract/blue
	colour = "blue"

/obj/item/metroidcross/recurring/metal
	extract_type = /obj/item/metroid_extract/metal
	colour = "metal"
	max_cooldown = 20

/obj/item/metroidcross/recurring/yellow
	extract_type = /obj/item/metroid_extract/yellow
	colour = "yellow"
	max_cooldown = 20

/obj/item/metroidcross/recurring/darkpurple
	extract_type = /obj/item/metroid_extract/darkpurple
	colour = "dark purple"
	max_cooldown = 20

/obj/item/metroidcross/recurring/darkblue
	extract_type = /obj/item/metroid_extract/darkblue
	colour = "dark blue"

/obj/item/metroidcross/recurring/silver
	extract_type = /obj/item/metroid_extract/silver
	colour = "silver"

/obj/item/metroidcross/recurring/bluespace
	extract_type = /obj/item/metroid_extract/bluespace
	colour = "bluespace"

/obj/item/metroidcross/recurring/sepia
	extract_type = /obj/item/metroid_extract/sepia
	colour = "sepia"
	max_cooldown = 36 //No infinite timestop for you!

/obj/item/metroidcross/recurring/cerulean
	extract_type = /obj/item/metroid_extract/cerulean
	colour = "cerulean"

/obj/item/metroidcross/recurring/pyrite
	extract_type = /obj/item/metroid_extract/pyrite
	colour = "pyrite"

/obj/item/metroidcross/recurring/red
	extract_type = /obj/item/metroid_extract/red
	colour = "red"

/obj/item/metroidcross/recurring/green
	extract_type = /obj/item/metroid_extract/green
	colour = "green"

/obj/item/metroidcross/recurring/pink
	extract_type = /obj/item/metroid_extract/pink
	colour = "pink"

/obj/item/metroidcross/recurring/gold
	extract_type = /obj/item/metroid_extract/gold
	colour = "gold"
	max_cooldown = 30

/obj/item/metroidcross/recurring/oil
	extract_type = /obj/item/metroid_extract/oil
	colour = "oil" //Why would you want this?

/obj/item/metroidcross/recurring/black
	extract_type = /obj/item/metroid_extract/black
	colour = "black"

/obj/item/metroidcross/recurring/lightpink
	extract_type = /obj/item/metroid_extract/lightpink
	colour = "light pink"

/obj/item/metroidcross/recurring/adamantine
	extract_type = /obj/item/metroid_extract/adamantine
	colour = "adamantine"
	max_cooldown = 20

/obj/item/metroidcross/recurring/rainbow
	extract_type = /obj/item/metroid_extract/rainbow
	colour = "rainbow"
	max_cooldown = 40 //It's pretty powerful.
