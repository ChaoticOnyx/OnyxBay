/*
Prismatic extracts:
	Becomes an infinite-use paintbrush.
*/
/obj/item/metroidcross/prismatic
	name = "prismatic extract"
	desc = "It's constantly wet with a semi-transparent, colored goo."
	effect = "prismatic"
	effect_desc = "When used it paints whatever it hits."
	icon_state = "prismatic"
	var/paintcolor = "#FFFFFF"

/obj/item/metroidcross/prismatic/afterattack(turf/target, mob/user, proximity)
	if(!proximity)
		return
	if(!istype(target) || isspaceturf(target))
		return
	target.color = paintcolor
	playsound(target, 'sound/effects/slosh.ogg', 20, TRUE)

/obj/item/metroidcross/prismatic/grey/
	colour = "grey"
	desc = "It's constantly wet with a pungent-smelling, clear chemical."

/obj/item/metroidcross/prismatic/grey/afterattack(turf/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(target) && target.color != initial(target.color))
		target.color = initial(target.color)
		playsound(target, 'sound/effects/slosh.ogg', 20, TRUE)

/obj/item/metroidcross/prismatic/orange
	paintcolor = "#FFA500"
	colour = "orange"

/obj/item/metroidcross/prismatic/purple
	paintcolor = "#B19CD9"
	colour = "purple"

/obj/item/metroidcross/prismatic/blue
	paintcolor = "#ADD8E6"
	colour = "blue"

/obj/item/metroidcross/prismatic/metal
	paintcolor = "#7E7E7E"
	colour = "metal"

/obj/item/metroidcross/prismatic/yellow
	paintcolor = "#FFFF00"
	colour = "yellow"

/obj/item/metroidcross/prismatic/darkpurple
	paintcolor = "#551A8B"
	colour = "dark purple"

/obj/item/metroidcross/prismatic/darkblue
	paintcolor = "#0000FF"
	colour = "dark blue"

/obj/item/metroidcross/prismatic/silver
	paintcolor = "#D3D3D3"
	colour = "silver"

/obj/item/metroidcross/prismatic/bluespace
	paintcolor = "#32CD32"
	colour = "bluespace"

/obj/item/metroidcross/prismatic/sepia
	paintcolor = "#704214"
	colour = "sepia"

/obj/item/metroidcross/prismatic/cerulean
	paintcolor = "#2956B2"
	colour = "cerulean"

/obj/item/metroidcross/prismatic/pyrite
	paintcolor = "#FAFAD2"
	colour = "pyrite"

/obj/item/metroidcross/prismatic/red
	paintcolor = "#FF0000"
	colour = "red"

/obj/item/metroidcross/prismatic/green
	paintcolor = "#00FF00"
	colour = "green"

/obj/item/metroidcross/prismatic/pink
	paintcolor = "#FF69B4"
	colour = "pink"

/obj/item/metroidcross/prismatic/gold
	paintcolor = "#FFD700"
	colour = "gold"

/obj/item/metroidcross/prismatic/oil
	paintcolor = "#505050"
	colour = "oil"

/obj/item/metroidcross/prismatic/black
	paintcolor = "#000000"
	colour = "black"

/obj/item/metroidcross/prismatic/lightpink
	paintcolor = "#FFB6C1"
	colour = "light pink"

/obj/item/metroidcross/prismatic/adamantine
	paintcolor = "#008B8B"
	colour = "adamantine"

/obj/item/metroidcross/prismatic/rainbow
	paintcolor = "#FFFFFF"
	colour = "rainbow"

/obj/item/metroidcross/prismatic/rainbow/attack_self(mob/user)
	var/newcolor = input(user, "Choose the metroid color:", "Color change",paintcolor) as color|null
	if(user.incapacitated())
		return
	if(!newcolor)
		return
	paintcolor = newcolor
	return
