/obj/item/reagent_containers/food/meat
	name = "meat"
	desc = "A slab of meat."
	icon_state = "meat"
	item_state = "meat"
	health = 180
	filling_color = "#cd1c1c"
	center_of_mass = "x=16;y=14"
	startswith = list(/datum/reagent/nutriment/protein = 150)
	bitesize = 30

	drop_sound = SFX_DROP_FLESH
	pickup_sound = SFX_PICKUP_FLESH

	slices_num = 3
	slice_path = /obj/item/reagent_containers/food/cutlet/raw

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

/obj/item/reagent_containers/food/meat/bear
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	filling_color = "#db0000"
	center_of_mass = "x=16;y=10"
	startswith = list(
		/datum/reagent/nutriment/protein = 145,
		/datum/reagent/hyperzine = 5)

/obj/item/reagent_containers/food/meat/xeno
	name = "xenomeat"
	desc = "A slab of green meat. Smells like acid."
	icon_state = "xenomeat"
	item_state = "xenomeat"
	filling_color = "#43de18"
	startswith = list(
		/datum/reagent/nutriment/protein = 100,
		/datum/reagent/acid/polyacid = 50)

/obj/item/reagent_containers/food/meat/pork
	name = "pork slab"
	desc = "It tastes... Humane."
	icon_state = "pork"

	slices_num = 3
	slice_path = /obj/item/reagent_containers/food/bacon
