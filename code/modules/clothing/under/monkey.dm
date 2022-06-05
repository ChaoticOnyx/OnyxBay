
/obj/item/clothing/under/monkey
	name = "monkey clothing"
	desc = "Monkey shall never wear this. Because of reasons."
	species_restricted = list(SPECIES_MONKEY)

/obj/item/clothing/under/monkey/punpun
	name = "fancy monkey uniform"
	desc = "For the most fashionable of apes."
	icon_state = "punpun"

/obj/item/clothing/under/monkey/pants
	name = "monkey pants"
	desc = "Too smol pant. For monke."
	icon_state = "jeansmustang"

// colored monke clothing
/obj/item/clothing/under/monkey/color
	name = "monkey suit"
	desc = "Monkey shall never kill monkey. In theory."
	icon_state = "monkey_jump"

/obj/item/clothing/under/monkey/color/white
	name = "white monkey suit"
	color = "#ffffff"

/obj/item/clothing/under/monkey/color/black
	name = "black monkey suit"
	color = "#3d3d3d"

/obj/item/clothing/under/monkey/color/grey
	name = "grey monkey suit"
	color = "#c4c4c4"

/obj/item/clothing/under/monkey/color/blue
	name = "blue monkey suit"
	color = "#0066ff"

/obj/item/clothing/under/monkey/color/pink
	name = "pink monkey suit"
	color = "#df20a6"

/obj/item/clothing/under/monkey/color/red
	name = "red monkey suit"
	color = "#ee1511"

/obj/item/clothing/under/monkey/color/green
	name = "green monkey suit"
	color = "#42a345"

/obj/item/clothing/under/monkey/color/yellow
	name = "yellow monkey suit"
	color = "#ffee00"

/obj/item/clothing/under/monkey/color/lightpurple
	name = "light purple monkey suit"
	color = "#c600fc"

/obj/item/clothing/under/monkey/color/brown
	name = "brown monkey suit"
	color = "#c08720"

/obj/item/clothing/under/monkey/color/random/Initialize()
	. = ..()
	color = rgb(rand(255), rand(255), rand(255))
	update_icon()
