
/////////////////////////////////////////////////Sliceable////////////////////////////////////////
// All the food items that can be sliced into smaller bits like Meatbread and Cheesewheels

/obj/item/reagent_containers/food/sliceable
	w_class = ITEM_SIZE_NORMAL //Whole pizzas and cakes shouldn't fit in a pocket, you can slice them if you want to do that.

/**
 *  A food item slice
 *
 *  This path contains some extra code for spawning slices pre-filled with
 *  reagents.
 */
/obj/item/reagent_containers/food/slice
	name = "slice of... something"
	var/whole_path  // path for the item from which this slice comes
	var/filled = FALSE  // should the slice spawn with any reagents

/**
 *  Spawn a new slice of food
 *
 *  If the slice's filled is TRUE, this will also fill the slice with the
 *  appropriate amount of reagents. Note that this is done by spawning a new
 *  whole item, transferring the reagents and deleting the whole item, which may
 *  have performance implications.
 */
/obj/item/reagent_containers/food/slice/Initialize()
	. = ..()
	if(filled && (!reagents || !reagents.total_volume))
		var/obj/item/reagent_containers/food/whole = new whole_path()
		if(whole && whole.slices_num)
			var/reagent_amount = whole.reagents.total_volume/whole.slices_num
			whole.reagents.trans_to_obj(src, reagent_amount)

		qdel(whole)

////////////////////////
/obj/item/reagent_containers/food/sliceable/cheesewheel
	name = "Cheese wheel"
	desc = "A big wheel of delcious Cheddar."
	icon_state = "cheesewheel"
	slice_path = /obj/item/reagent_containers/food/cheesewedge
	slices_num = 5
	filling_color = "#fff700"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("cheese" = 5)
	nutriment_amt = 20
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 5
		)
	bitesize = 2.5 // 325 nutrition, 10 bites

/obj/item/reagent_containers/food/cheesewedge
	name = "Cheese wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	filling_color = "#fff700"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("cheese" = 5)
	nutriment_amt = 4
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 1
		)
	bitesize = 2.5 // 65 nutrition, 2 bites

////////////////////////
/obj/item/reagent_containers/food/sliceable/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "flat dough"
	w_class = ITEM_SIZE_SMALL
	slice_path = /obj/item/reagent_containers/food/doughslice
	slices_num = 3
	center_of_mass = "x=16;y=16"
	nutriment_amt = 12
	nutriment_desc = list("dough" = 1)
	startswith = list(
		/datum/reagent/nutriment/protein/gluten = 3
		)
	bitesize = 2.5 // 157.5 nutrition, 6 bites

/obj/item/reagent_containers/food/sliceable/flatdough/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/reagent_containers/food/faggot) || istype(W, /obj/item/reagent_containers/food/rawfaggot))
		new /obj/item/reagent_containers/food/pelmeni(src)
		to_chat(user, "You make some pelmeni.")
		qdel(src)
		qdel(W)
		return
	return ..()

/obj/item/reagent_containers/food/doughslice
	name = "dough slice"
	desc = "A building block of an impressive dish."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "doughslice"
	slice_path = /obj/item/reagent_containers/food/spagetti
	slices_num = 1
	center_of_mass = "x=17;y=19"
	nutriment_desc = list("dough" = 1)
	nutriment_amt = 4
	startswith = list(
		/datum/reagent/nutriment/protein/gluten = 1
		)
	bitesize = 2.5 // 52.5 nutrition, 2 bites

////////////////////////
/obj/item/reagent_containers/food/sliceable/salami
	name = "Salami"
	desc = "Not the best for sandwiches."
	icon_state = "salami"
	center_of_mass = "x=15;y=15"
	w_class = ITEM_SIZE_SMALL // this mf is sausage-sized
	slice_path = /obj/item/reagent_containers/food/slice/salami
	slices_num = 6
	nutriment_desc = list("salami" = 5)
	nutriment_amt = 2.5
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 7.5,
		/datum/reagent/salt = 1,
		/datum/reagent/blackpepper = 1,
		/datum/reagent/nutriment/garlicsauce = 1.5
		)
	bitesize = 1.25 // 257.5 nutrition, 10 bites

/obj/item/reagent_containers/food/slice/salami
	name = "Salami's slice"
	desc = "A slice of salami. The best for sandwiches"
	icon_state = "salami_s"
	center_of_mass = "x=15;y=15"
	w_class = ITEM_SIZE_TINY
	whole_path = /obj/item/reagent_containers/food/sliceable/salami
	nutriment_desc = list("salami" = 5)
	nutriment_amt = 5
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 1.5,
		/datum/reagent/salt = 1,
		/datum/reagent/blackpepper = 1,
		/datum/reagent/nutriment/garlicsauce = 2
		)
	bitesize = 1.25 // 51.5 nutrition, 2 bites

/obj/item/reagent_containers/food/slice/salami/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/sushi
	name = "Sushi"
	desc = "Konnichiwa!"
	icon_state = "sushi"
	slices_num = 6
	center_of_mass = "x=15;y=15"
	slice_path = /obj/item/reagent_containers/food/slice/sushi
	nutriment_desc = list("sushi" = 5)
	nutriment_amt = 18
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 12
		)
	bitesize = 3 // 480 nutrition, 10 bites

/obj/item/reagent_containers/food/slice/sushi
	name = "Sushi's slice"
	desc = "A slice of sushi. Smaller konnichiwa."
	icon_state = "sushi_s"
	center_of_mass = "x=15;y=15"
	whole_path = /obj/item/reagent_containers/food/sliceable/sushi
	nutriment_desc = list("sushi" = 5)
	nutriment_amt = 3.5
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 2
		)
	bitesize = 6 // 80 nutrition, 1 bite

/obj/item/reagent_containers/food/slice/sushi/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/bread
	name = "Bread"
	icon_state = "Some plain old Earthen bread."
	icon_state = "bread"
	slice_path = /obj/item/reagent_containers/food/slice/bread
	slices_num = 10
	filling_color = "#ffe396"
	center_of_mass = "x=16;y=9"
	nutriment_desc = list("bread" = 3)
	nutriment_amt = 36
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 9
		)
	bitesize = 2.5 // 585 nutrition, 23 bites

/obj/item/reagent_containers/food/slice/bread
	name = "Bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#d27332"
	center_of_mass = "x=16;y=4"
	whole_path = /obj/item/reagent_containers/food/sliceable/bread
	nutriment_desc = list("bread" = 3)
	nutriment_amt = 3.6
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1
		)
	bitesize = 2.5 // 58.5 nutrition, 2 bites

/obj/item/reagent_containers/food/slice/bread/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/meatbread
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	slice_path = /obj/item/reagent_containers/food/slice/meatbread
	slices_num = 10
	filling_color = "#ff7575"
	center_of_mass = "x=19;y=9"
	nutriment_desc = list("bread" = 3, "meat" = 3, "cheese" = 2)
	nutriment_amt = 48
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 48,
		/datum/reagent/nutriment/protein/gluten/cooked = 9
		)
	bitesize = 3.5 // 1905 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/meatbread
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#ff7575"
	center_of_mass = "x=16;y=13"
	whole_path = /obj/item/reagent_containers/food/sliceable/meatbread
	nutriment_desc = list("bread" = 3, "meat" = 3, "cheese" = 2)
	nutriment_amt = 5
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 5,
		/datum/reagent/nutriment/protein/gluten/cooked = 1
		)
	bitesize = 3.5 // 190.5 nutrition, 3 bites

/obj/item/reagent_containers/food/slice/meatbread/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/xenomeatbread
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquent gentleman. Extra Heretical."
	icon_state = "xenomeatbread"
	slice_path = /obj/item/reagent_containers/food/slice/xenomeatbread
	slices_num = 5
	filling_color = "#8aff75"
	center_of_mass = "x=16;y=9"
	nutriment_desc = list("bread" = 3, "heresy" = 3, "cheese" = 2)
	nutriment_amt = 48
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 48,
		/datum/reagent/nutriment/protein/gluten/cooked = 9
		)
	bitesize = 3.5 // 1905 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/xenomeatbread
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon_state = "xenobreadslice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#8aff75"
	center_of_mass = "x=16;y=13"
	whole_path = /obj/item/reagent_containers/food/sliceable/xenomeatbread
	nutriment_desc = list("bread" = 3, "heresy" = 3, "cheese" = 2)
	nutriment_amt = 5
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 5,
		/datum/reagent/nutriment/protein/gluten/cooked = 1
		)
	bitesize = 3.5 // 190.5 nutrition, 3 bites

/obj/item/reagent_containers/food/slice/xenomeatbread/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/bananabread
	name = "Banana bread"
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	slice_path = /obj/item/reagent_containers/food/slice/bananabread
	slices_num = 10
	filling_color = "#ede5ad"
	center_of_mass = "x=16;y=9"
	nutriment_desc = list("bread" = 3, "banana" = 3)
	nutriment_amt = 61
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 9,
		/datum/reagent/sugar = 5
		)
	bitesize = 3 // 1085 nutrition, 25 bites

/obj/item/reagent_containers/food/slice/bananabread
	name = "Banana bread slice"
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#ede5ad"
	center_of_mass = "x=16;y=8"
	whole_path = /obj/item/reagent_containers/food/sliceable/bananabread
	nutriment_desc = list("bread" = 3, "banana" = 3)
	nutriment_amt = 6
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1,
		/datum/reagent/sugar = 0.5
		)
	bitesize = 3 // 108.5 nutrition, 3 bites

/obj/item/reagent_containers/food/slice/bananabread/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/tofubread
	name = "Tofubread"
	icon_state = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	slice_path = /obj/item/reagent_containers/food/slice/tofubread
	slices_num = 10
	filling_color = "#f7ffe0"
	center_of_mass = "x=16;y=9"
	nutriment_desc = list("bread" = 3, "tofu" = 3, "cheese" = 2)
	nutriment_amt = 70
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 12
		)
	bitesize = 3 // 1000 nutrition, 28 bites

/obj/item/reagent_containers/food/slice/tofubread
	name = "Tofubread slice"
	desc = "A slice of delicious tofubread."
	icon_state = "tofubreadslice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#f7ffe0"
	center_of_mass = "x=16;y=13"
	whole_path = /obj/item/reagent_containers/food/sliceable/tofubread
	nutriment_desc = list("bread" = 3, "tofu" = 3, "cheese" = 2)
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1
		)
	bitesize = 3 // 100 nutrition, 3 bites

/obj/item/reagent_containers/food/slice/tofubread/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/creamcheesebread
	name = "Cream Cheese Bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/reagent_containers/food/slice/creamcheesebread
	slices_num = 10
	filling_color = "#fff896"
	center_of_mass = "x=16;y=9"
	nutriment_desc = list("bread" = 3, "cheese" = 3, "cream" = 2)
	nutriment_amt = 70
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 12
		)
	bitesize = 3 // 1000 nutrition, 28 bites

/obj/item/reagent_containers/food/slice/creamcheesebread
	name = "Cream Cheese Bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#fff896"
	bitesize = 2
	center_of_mass = "x=16;y=13"
	whole_path = /obj/item/reagent_containers/food/sliceable/creamcheesebread
	nutriment_desc = list("bread" = 3, "cheese" = 3, "cream" = 2)
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.2
		)
	bitesize = 3 // 100 nutrition, 3 bites

/obj/item/reagent_containers/food/slice/creamcheesebread/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/carrotcake
	name = "Carrot Cake"
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon_state = "carrotcake"
	slice_path = /obj/item/reagent_containers/food/slice/carrotcake
	slices_num = 6
	filling_color = "#ffd675"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("cake" = 10, "sweetness" = 10, "carrot" = 15)
	nutriment_amt = 42
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 9,
		/datum/reagent/nutriment/protein/cooked = 9,
		/datum/reagent/sugar = 12,
		/datum/reagent/imidazoline = 1.2
		)
	bitesize = 2.5 // 1470 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/carrotcake
	name = "Carrot Cake slice"
	desc = "Carrotty slice of Carrot Cake, carrots are good for your eyes! Also not a lie."
	icon_state = "carrotcake_slice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#ffd675"
	center_of_mass = "x=16;y=14"
	whole_path = /obj/item/reagent_containers/food/sliceable/carrotcake
	nutriment_desc = list("cake" = 10, "carrot" = 10)
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/nutriment/protein/cooked = 1.5,
		/datum/reagent/sugar = 2,
		/datum/reagent/imidazoline = 1
		)
	bitesize = 2.5 // 147 nutrition, 5 bites

/obj/item/reagent_containers/food/slice/carrotcake/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/braincake
	name = "Brain Cake"
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	slice_path = /obj/item/reagent_containers/food/slice/braincake
	slices_num = 6
	filling_color = "#e6aedb"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("cake" = 10, "slime" = 10)
	nutriment_amt = 51
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 9,
		/datum/reagent/sugar = 12,
		/datum/reagent/alkysine = 1.2
		)
	bitesize = 2.5 // 1335 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/braincake
	name = "Brain Cake slice"
	desc = "Lemme tell you something about prions. THEY'RE DELICIOUS."
	icon_state = "braincakeslice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#e6aedb"
	center_of_mass = "x=16;y=12"
	whole_path = /obj/item/reagent_containers/food/sliceable/braincake
	nutriment_desc = list("cake" = 10, "slime" = 10)
	nutriment_amt = 85
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/sugar = 2,
		/datum/reagent/alkysine = 1
		)
	bitesize = 2.5 // 133.5 nutrition, 5 bites

/obj/item/reagent_containers/food/slice/braincake/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/cheesecake
	name = "Cheese Cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	slice_path = /obj/item/reagent_containers/food/slice/cheesecake
	slices_num = 6
	filling_color = "#faf7af"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("cake" = 10, "cheese" = 10)
	nutriment_amt = 39
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 9,
		/datum/reagent/nutriment/protein/cooked = 12,
		/datum/reagent/sugar = 12
		)
	bitesize = 2.5 // 1515 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/cheesecake
	name = "Cheese Cake slice"
	desc = "Slice of pure cheestisfaction."
	icon_state = "cheesecake_slice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#faf7af"
	center_of_mass = "x=16;y=14"
	whole_path = /obj/item/reagent_containers/food/sliceable/cheesecake
	nutriment_desc = list("cake" = 10, "cheese" = 10)
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/nutriment/protein/cooked = 2,
		/datum/reagent/sugar = 2
		)
	bitesize = 2.5 // 151.5 nutrition, 5 bites

/obj/item/reagent_containers/food/slice/cheesecake/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/plaincake
	name = "Vanilla Cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	slice_path = /obj/item/reagent_containers/food/slice/plaincake
	slices_num = 6
	filling_color = "#f7edd5"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("cake" = 10)
	nutriment_amt = 42
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 9,
		/datum/reagent/nutriment/protein/cooked = 9,
		/datum/reagent/sugar = 12
		)
	bitesize = 2.5 // 1470 nutrition, 29 bites

/obj/item/reagent_containers/food/slice/plaincake
	name = "Vanilla Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#f7edd5"
	center_of_mass = "x=16;y=14"
	whole_path = /obj/item/reagent_containers/food/sliceable/plaincake
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/nutriment/protein/cooked = 1.5,
		/datum/reagent/sugar = 2
		)
	bitesize = 2.5 // 147 nutrition, 5 bites

/obj/item/reagent_containers/food/slice/plaincake/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/orangecake
	name = "Orange Cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/reagent_containers/food/slice/orangecake
	slices_num = 6
	filling_color = "#fada8e"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("cake" = 10, "orange" = 10)
	nutriment_amt = 42
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 9,
		/datum/reagent/nutriment/protein/cooked = 9,
		/datum/reagent/sugar = 12
		)
	bitesize = 2.5 // 1470 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/orangecake
	name = "Orange Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#fada8e"
	center_of_mass = "x=16;y=14"
	whole_path = /obj/item/reagent_containers/food/sliceable/orangecake
	nutriment_desc = list("cake" = 10, "orange" = 10)
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/nutriment/protein/cooked = 1.5,
		/datum/reagent/sugar = 2
		)
	bitesize = 2.5 // 147 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/orangecake/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/limecake
	name = "Lime Cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	slice_path = /obj/item/reagent_containers/food/slice/limecake
	slices_num = 6
	filling_color = "#cbfa8e"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("cake" = 10, "lime" = 10)
	nutriment_amt = 42
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 9,
		/datum/reagent/nutriment/protein/cooked = 9,
		/datum/reagent/sugar = 12
		)
	bitesize = 2.5 // 1470 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/limecake
	name = "Lime Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#cbfa8e"
	center_of_mass = "x=16;y=14"
	whole_path = /obj/item/reagent_containers/food/sliceable/limecake
	nutriment_desc = list("cake" = 10, "lime" = 10)
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/nutriment/protein/cooked = 1.5,
		/datum/reagent/sugar = 2
		)
	bitesize = 2.5 // 147 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/limecake/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/lemoncake
	name = "Lemon Cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/reagent_containers/food/slice/lemoncake
	slices_num = 6
	filling_color = "#fafa8e"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("cake" = 10, "lemon" = 10)
	nutriment_amt = 42
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 9,
		/datum/reagent/nutriment/protein/cooked = 9,
		/datum/reagent/sugar = 12
		)
	bitesize = 2.5 // 1470 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/lemoncake
	name = "Lemon Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "lemoncake_slice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#fafa8e"
	center_of_mass = "x=16;y=14"
	whole_path = /obj/item/reagent_containers/food/sliceable/lemoncake
	nutriment_desc = list("cake" = 10, "lemon" = 10)
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/nutriment/protein/cooked = 1.5,
		/datum/reagent/sugar = 2
		)
	bitesize = 2.5 // 147 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/lemoncake/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/chocolatecake
	name = "Chocolate Cake"
	desc = "A cake with added chocolate."
	icon_state = "chocolatecake"
	slice_path = /obj/item/reagent_containers/food/slice/chocolatecake
	slices_num = 6
	filling_color = "#805930"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("cake" = 10, "chocolate" = 15)
	nutriment_amt = 36
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 9,
		/datum/reagent/nutriment/protein/cooked = 9,
		/datum/reagent/sugar = 12,
		/datum/reagent/nutriment/coco = 6
		)
	bitesize = 2.5 // 1560 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/chocolatecake
	name = "Chocolate Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "chocolatecake_slice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#805930"
	center_of_mass = "x=16;y=14"
	whole_path = /obj/item/reagent_containers/food/sliceable/chocolatecake
	nutriment_desc = list("cake" = 10, "chocolate" = 15)
	nutriment_amt = 4
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/nutriment/protein/cooked = 1.5,
		/datum/reagent/sugar = 2,
		/datum/reagent/nutriment/coco = 1
		)
	bitesize = 2.5 // 156 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/chocolatecake/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/metroidcake
	name = "Metroid Cake"
	desc = "A cake with some slimy filling."
	icon_state = "metroidcake"
	slice_path = /obj/item/reagent_containers/food/slice/metroidcake
	slices_num = 6
	filling_color = "#D3D3D3"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("cake" = 10, "goo" = 15)
	nutriment_amt = 42
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 9,
		/datum/reagent/nutriment/protein/cooked = 9,
		/datum/reagent/sugar = 12
		)
	bitesize = 2.5 // 1470 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/metroidcake
	name = "Metroid Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "metroidcake_slice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#D3D3D3"
	center_of_mass = "x=16;y=14"
	whole_path = /obj/item/reagent_containers/food/sliceable/metroidcake
	nutriment_desc = list("cake" = 10, "goo" = 15)
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/nutriment/protein/cooked = 1.5,
		/datum/reagent/sugar = 2
		)
	bitesize = 2.5 // 147 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/metroidcake/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/birthdaycake
	name = "Birthday Cake"
	desc = "Happy Birthday..."
	icon_state = "birthdaycake"
	slice_path = /obj/item/reagent_containers/food/slice/birthdaycake
	slices_num = 6
	filling_color = "#ffd6d6"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("cake" = 10, "lie" = 1)
	nutriment_amt = 42
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 9,
		/datum/reagent/nutriment/protein/cooked = 9,
		/datum/reagent/nutriment/sprinkles = 12
		)
	bitesize = 2.5 // 1470 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/birthdaycake
	name = "Birthday Cake slice"
	desc = "A slice of your birthday."
	icon_state = "birthdaycakeslice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#ffd6d6"
	center_of_mass = "x=16;y=14"
	whole_path = /obj/item/reagent_containers/food/sliceable/birthdaycake
	nutriment_desc = list("cake" = 10, "lie" = 1)
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/nutriment/protein/cooked = 1.5,
		/datum/reagent/nutriment/sprinkles = 2
		)
	bitesize = 2.5 // 147 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/birthdaycake/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/watermelonslice
	name = "Watermelon Slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice"
	filling_color = "#ff3867"
	bitesize = 2
	center_of_mass = "x=16;y=10"

////////////////////////
/obj/item/reagent_containers/food/sliceable/applecake
	name = "Apple Cake"
	desc = "A cake centred with apples."
	icon_state = "applecake"
	slice_path = /obj/item/reagent_containers/food/slice/applecake
	slices_num = 5
	filling_color = "#ebf5b8"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("cake" = 10, "apple" = 10)
	nutriment_amt = 42
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 9,
		/datum/reagent/nutriment/protein/cooked = 9,
		/datum/reagent/sugar = 12
		)
	bitesize = 2.5 // 1470 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/applecake
	name = "Apple Cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#ebf5b8"
	center_of_mass = "x=16;y=14"
	whole_path = /obj/item/reagent_containers/food/sliceable/applecake
	nutriment_desc = list("cake" = 10, "apple" = 10)
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/nutriment/protein/cooked = 1.5,
		/datum/reagent/sugar = 2
		)
	bitesize = 2.5 // 147 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/applecake/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/pumpkinpie
	name = "Pumpkin Pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/reagent_containers/food/slice/pumpkinpie
	slices_num = 6
	filling_color = "#f5b951"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("pie" = 5, "cream" = 5, "pumpkin" = 5)
	nutriment_amt = 42
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 9,
		/datum/reagent/nutriment/protein/cooked = 9,
		/datum/reagent/sugar = 12
		)
	bitesize = 2.5 // 1470 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/pumpkinpie
	name = "Pumpkin Pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/dish/plate
	filling_color = "#f5b951"
	center_of_mass = "x=16;y=12"
	whole_path = /obj/item/reagent_containers/food/sliceable/pumpkinpie
	nutriment_desc = list("pie" = 5, "cream" = 5, "pumpkin" = 5)
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/nutriment/protein/cooked = 1.5,
		/datum/reagent/sugar = 2
		)
	bitesize = 2.5 // 147 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/pumpkinpie/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/noel
	name = "Buche de Noel"
	desc = "What?"
	icon_state = "noel"
	trash = /obj/item/trash/dish/tray
	slice_path = /obj/item/reagent_containers/food/slice/noel
	slices_num = 5
	center_of_mass = "x=15;y=15"
	nutriment_amt = 8
	startswith = list(
		/datum/reagent/drink/milk/cream = 3,
		/datum/reagent/sugar = 3,
		/datum/reagent/drink/juice/berry = 3,
		/datum/reagent/nutriment/coco = 2)

/obj/item/reagent_containers/food/slice/noel
	name = "Noel's slice"
	desc = "Slice of what?"
	icon_state = "noel_s"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	whole_path = /obj/item/reagent_containers/food/sliceable/noel
	bitesize = 2

/obj/item/reagent_containers/food/slice/noel/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/choccherrycake
	name = "Chocolate-cherry cake"
	desc = "Another cake. However."
	icon_state = "choccherrycake"
	slice_path = /obj/item/reagent_containers/food/slice/choccherrycake
	slices_num = 6
	center_of_mass = "x=15;y=15"
	nutriment_desc = list("cake" = 5, "chocolate" = 5, "cherry" = 5)
	nutriment_amt = 36
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 9,
		/datum/reagent/nutriment/protein/cooked = 9,
		/datum/reagent/sugar = 12,
		/datum/reagent/nutriment/coco = 6
		)
	bitesize = 2.5 // 1560 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/choccherrycake
	name = "Chocolate - cherry cake's slice"
	desc = "Slice of another cake. Wait, what?"
	icon_state = "choccherrycake_s"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	whole_path = /obj/item/reagent_containers/food/sliceable/choccherrycake
	nutriment_desc = list("cake" = 5, "chocolate" = 5, "cherry" = 5)
	nutriment_amt = 6
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/nutriment/protein/cooked = 1.5,
		/datum/reagent/sugar = 2,
		/datum/reagent/nutriment/coco = 1
		)
	bitesize = 2.5 // 156 nutrition, 30 bites

/obj/item/reagent_containers/food/slice/choccherrycake/filled
	filled = TRUE



/////////////////////////////////////////////////PIZZA////////////////////////////////////////

/obj/item/reagent_containers/food/sliceable/pizza
	slices_num = 8
	filling_color = "#baa14c"

////////////////////////
/obj/item/reagent_containers/food/sliceable/pizza/margherita
	name = "Margherita"
	desc = "The golden standard of pizzas."
	icon_state = "pizzamargherita"
	slice_path = /obj/item/reagent_containers/food/slice/margherita
	slices_num = 8
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("pizza crust" = 1, "tomato" = 1, "cheese" = 2)
	nutriment_amt = 57
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 13,
		/datum/reagent/drink/juice/tomato = 10
		)
	bitesize = 2.5 // 945 nutrition (+312 with rims), 32 bites

/obj/item/reagent_containers/food/slice/margherita
	name = "Margherita slice"
	desc = "A slice of the classic pizza."
	icon_state = "pizzamargheritaslice"
	filling_color = "#baa14c"
	center_of_mass = "x=18;y=13"
	whole_path = /obj/item/reagent_containers/food/sliceable/pizza/margherita
	nutriment_desc = list("pizza crust" = 1, "tomato" = 1, "cheese" = 2)
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 2,
		/datum/reagent/drink/juice/tomato = 1.25
		)
	bitesize = 2.5 // 119 nutrition (+39 with a rim), 4 bites
	trash = /obj/item/reagent_containers/food/pizzarim

/obj/item/reagent_containers/food/slice/margherita/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/pizza/meatpizza
	name = "Meatpizza"
	desc = "A pizza with meat topping."
	icon_state = "meatpizza"
	slice_path = /obj/item/reagent_containers/food/slice/meatpizza
	slices_num = 8
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("pizza crust" = 1, "tomato" = 1, "cheese" = 2, "meat" = 2)
	nutriment_amt = 56
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 12,
		/datum/reagent/nutriment/protein/gluten/cooked = 15,
		/datum/reagent/drink/juice/tomato = 5
		)
	bitesize = 2.5 // 1260 nutrition (+312 with rims), 36 bites

/obj/item/reagent_containers/food/slice/meatpizza
	name = "Meatpizza slice"
	desc = "A slice of a meaty pizza."
	icon_state = "meatpizzaslice"
	filling_color = "#baa14c"
	center_of_mass = "x=18;y=13"
	whole_path = /obj/item/reagent_containers/food/sliceable/pizza/meatpizza
	nutriment_desc = list("pizza crust" = 1, "tomato" = 1, "cheese" = 2, "meat" = 2)
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/nutriment/protein/cooked = 2,
		/datum/reagent/drink/juice/tomato = 0.6
		)
	bitesize = 2.5 // 157.5 nutrition (+39 with a rim), 5 bites
	trash = /obj/item/reagent_containers/food/pizzarim

/obj/item/reagent_containers/food/slice/meatpizza/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/pizza/mushroompizza
	name = "Mushroompizza"
	desc = "Very special pizza."
	icon_state = "mushroompizza"
	slice_path = /obj/item/reagent_containers/food/slice/mushroompizza
	slices_num = 8
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("pizza crust" = 1, "tomato" = 1, "cheese" = 2, "mushroom" = 2)
	nutriment_amt = 56
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 12,
		/datum/reagent/nutriment/protein/fungal = 15,
		/datum/reagent/drink/juice/tomato = 5
		)
	bitesize = 2.5 // 1072.5 nutrition (+312 with rims), 36 bites

/obj/item/reagent_containers/food/slice/mushroompizza
	name = "Mushroompizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	filling_color = "#baa14c"
	center_of_mass = "x=18;y=13"
	whole_path = /obj/item/reagent_containers/food/sliceable/pizza/mushroompizza
	nutriment_desc = list("pizza crust" = 1, "tomato" = 1, "cheese" = 2, "mushroom" = 2)
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/nutriment/protein/fungal = 2,
		/datum/reagent/drink/juice/tomato = 0.6
		)
	bitesize = 2.5 // 157.5 nutrition (+39 with a rim), 5 bites
	trash = /obj/item/reagent_containers/food/pizzarim

/obj/item/reagent_containers/food/slice/mushroompizza/filled
	filled = TRUE

////////////////////////
/obj/item/reagent_containers/food/sliceable/pizza/vegetablepizza
	name = "Vegetable pizza"
	desc = "No one of Tomato Sapiens were harmed during making this pizza."
	icon_state = "vegetablepizza"
	slice_path = /obj/item/reagent_containers/food/slice/vegetablepizza
	slices_num = 8
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("pizza crust" = 1, "tomato" = 1, "cheese" = 2, "eggplant" = 1, "carrot" = 1, "corn" = 1)
	nutriment_amt = 56
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 12,
		/datum/reagent/nutriment/protein/fungal = 15,
		/datum/reagent/drink/juice/tomato = 5,
		/datum/reagent/imidazoline = 1.2
		)
	bitesize = 2.5

/obj/item/reagent_containers/food/slice/vegetablepizza
	name = "Vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients."
	icon_state = "vegetablepizzaslice"
	filling_color = "#baa14c"
	center_of_mass = "x=18;y=13"
	whole_path = /obj/item/reagent_containers/food/sliceable/pizza/vegetablepizza
	nutriment_desc = list("pizza crust" = 1, "tomato" = 1, "cheese" = 2, "eggplant" = 1, "carrot" = 1, "corn" = 1)
	nutriment_amt = 56
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		/datum/reagent/drink/juice/tomato = 0.6,
		/datum/reagent/imidazoline = 1
		)
	bitesize = 2.5
	trash = /obj/item/reagent_containers/food/pizzarim

/obj/item/reagent_containers/food/slice/vegetablepizza/filled
	filled = TRUE

////////////////////////
/obj/item/pizzabox
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food.dmi'
	icon_state = "pizzabox1"

	var/open = 0 // Is the box open?
	var/ismessy = 0 // Fancy mess on the lid
	var/obj/item/reagent_containers/food/sliceable/pizza/pizza // Content pizza
	var/list/boxes = list() // If the boxes are stacked, they come here
	var/boxtag = ""

/obj/item/pizzabox/on_update_icon()

	ClearOverlays()

	// Set appropriate description
	if( open && pizza )
		desc = "A box suited for pizzas. It appears to have a [pizza.name] inside."
	else if( boxes.len > 0 )
		desc = "A pile of boxes suited for pizzas. There appears to be [boxes.len + 1] boxes in the pile."

		var/obj/item/pizzabox/topbox = boxes[boxes.len]
		var/toptag = topbox.boxtag
		if( toptag != "" )
			desc = "[desc] The box on top has a tag, it reads: '[toptag]'."
	else
		desc = "A box suited for pizzas."

		if( boxtag != "" )
			desc = "[desc] The box has a tag, it reads: '[boxtag]'."

	// Icon states and overlays
	if( open )
		if( ismessy )
			icon_state = "pizzabox_messy"
		else
			icon_state = "pizzabox_open"

		if( pizza )
			var/image/pizzaimg = image("food.dmi", icon_state = pizza.icon_state)
			pizzaimg.pixel_y = -3
			AddOverlays(pizzaimg)

		return
	else
		// Stupid code because byondcode sucks
		var/doimgtag = 0
		if( boxes.len > 0 )
			var/obj/item/pizzabox/topbox = boxes[boxes.len]
			if( topbox.boxtag != "" )
				doimgtag = 1
		else
			if( boxtag != "" )
				doimgtag = 1

		if( doimgtag )
			var/image/tagimg = image("food.dmi", icon_state = "pizzabox_tag")
			tagimg.pixel_y = boxes.len * 3
			AddOverlays(tagimg)

	icon_state = "pizzabox[boxes.len+1]"

/obj/item/pizzabox/attack_hand( mob/user as mob )

	if( open && pizza )
		user.put_in_hands( pizza )

		to_chat(user, "<span class='warning'>You take \the [src.pizza] out of \the [src].</span>")
		src.pizza = null
		update_icon()
		return

	if( boxes.len > 0 )
		if( user.get_inactive_hand() != src )
			..()
			return

		var/obj/item/pizzabox/box = boxes[boxes.len]
		boxes -= box

		user.put_in_hands( box )
		to_chat(user, "<span class='warning'>You remove the topmost [src] from your hand.</span>")
		box.update_icon()
		update_icon()
		return
	..()

/obj/item/pizzabox/attack_self( mob/user as mob )

	if( boxes.len > 0 )
		return

	open = !open

	if( open && pizza )
		ismessy = 1

	update_icon()

/obj/item/pizzabox/attackby( obj/item/I as obj, mob/user as mob )
	if( istype(I, /obj/item/pizzabox/) )
		var/obj/item/pizzabox/box = I

		if( !box.open && !src.open )
			// Make a list of all boxes to be added
			var/list/boxestoadd = list()
			boxestoadd += box
			for(var/obj/item/pizzabox/i in box.boxes)
				boxestoadd += i

			if((boxes.len + 1) + boxestoadd.len <= 5)
				if(!user.drop(box, src))
					return
				box.boxes = list() // Clear the box boxes so we don't have boxes inside boxes. - Xzibit
				boxes.Add(boxestoadd)
				box.update_icon()
				update_icon()

				to_chat(user, "<span class='warning'>You put \the [box] ontop of \the [src]!</span>")
			else
				to_chat(user, "<span class='warning'>The stack is too high!</span>")
		else
			to_chat(user, "<span class='warning'>Close \the [box] first!</span>")

		return

	if(istype(I, /obj/item/reagent_containers/food/sliceable/pizza)) // Long ass fucking object name
		if(open)
			if(!user.drop(I, src))
				return
			pizza = I
			update_icon()
			to_chat(user, "<span class='warning'>You put \the [I] in \the [src]!</span>")
		else
			to_chat(user, "<span class='warning'>You try to push \the [I] through the lid but it doesn't work!</span>")
		return

	if( istype(I, /obj/item/pen/) )

		if( src.open )
			return

		var/t = sanitize(input("Enter what you want to add to the tag:", "Write", null, null) as text, 30)

		var/obj/item/pizzabox/boxtotagto = src
		if( boxes.len > 0 )
			boxtotagto = boxes[boxes.len]

		boxtotagto.boxtag = copytext("[boxtotagto.boxtag][t]", 1, 30)

		update_icon()
		return
	..()

/obj/item/pizzabox/margherita/Initialize()
	. = ..()
	pizza = new /obj/item/reagent_containers/food/sliceable/pizza/margherita(src)
	boxtag = "Margherita Deluxe"

/obj/item/pizzabox/vegetable/Initialize()
	. = ..()
	pizza = new /obj/item/reagent_containers/food/sliceable/pizza/vegetablepizza(src)
	boxtag = "Gourmet Vegatable"

/obj/item/pizzabox/mushroom/Initialize()
	. = ..()
	pizza = new /obj/item/reagent_containers/food/sliceable/pizza/mushroompizza(src)
	boxtag = "Mushroom Special"

/obj/item/pizzabox/meat/Initialize()
	. = ..()
	pizza = new /obj/item/reagent_containers/food/sliceable/pizza/meatpizza(src)
	boxtag = "Meatlover's Supreme"
