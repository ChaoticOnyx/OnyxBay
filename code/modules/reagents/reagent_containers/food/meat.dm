/obj/item/reagent_containers/food/meat
	name = "meat"
	desc = "A slab of meat."
	icon_state = "meat"
	health = 180
	filling_color = "#ff1c1c"
	center_of_mass = "x=16;y=14"
	startswith = list(/datum/reagent/nutriment/protein = 9)
	bitesize = 3

/obj/item/reagent_containers/food/meat/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/material/knife))
		new /obj/item/reagent_containers/food/rawcutlet(src)
		new /obj/item/reagent_containers/food/rawcutlet(src)
		new /obj/item/reagent_containers/food/rawcutlet(src)
		to_chat(user, "You cut the meat into thin strips.")
		qdel(src)
	else
		..()

/obj/item/reagent_containers/food/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh."

// Seperate definitions because some food likes to know if it's human.
// TODO: rewrite kitchen code to check a var on the meat item so we can remove
// all these sybtypes.
/obj/item/reagent_containers/food/meat/human
/obj/item/reagent_containers/food/meat/monkey
	//same as plain meat

/obj/item/reagent_containers/food/meat/corgi
	name = "corgi meat"
	desc = "Tastes like... well, you know."

/obj/item/reagent_containers/food/meat/beef
	name = "beef slab"
	desc = "The classic red meat."

/obj/item/reagent_containers/food/meat/goat
	name = "chevon slab"
	desc = "Goat meat, to the uncultured."

/obj/item/reagent_containers/food/meat/chicken
	name = "chicken piece"
	desc = "It tastes like you'd expect."

/obj/item/reagent_containers/food/meat/xeno
	name = "xenomeat"
	desc = "A slab of green meat. Smells like acid."
	icon_state = "xenomeat"
	filling_color = "#43de18"
	startswith = list(
		/datum/reagent/nutriment/protein = 9,
		/datum/reagent/acid/polyacid = 9)
	bitesize = 6
