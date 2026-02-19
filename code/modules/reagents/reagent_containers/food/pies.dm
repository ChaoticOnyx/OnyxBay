
// Sweet pies
/obj/item/reagent_containers/food/pie
	name = "Banana Cream Pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/dish/plate
	filling_color = "#fbffb8"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("pie" = 3, "cream" = 2)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30,
		/datum/reagent/sugar = 20,
		/datum/reagent/drink/juice/banana = 10
		)
	bitesize = 30 // 300 nutrition, 6 bites

/obj/item/reagent_containers/food/pie/throw_impact(atom/hit_atom, datum/thrownthing/TT)
	..()
	new /obj/effect/decal/cleanable/pie_smudge(loc)
	visible_message(SPAN("danger", "\The [src] splats."), SPAN("danger", "You hear a splat."))
	qdel(src)

/obj/item/reagent_containers/food/berryclafoutis
	name = "Berry Clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("pie" = 3, "berries" = 2)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30,
		/datum/reagent/sugar = 20,
		/datum/reagent/drink/juice/berry = 10
		)
	bitesize = 30 // 300 nutrition, 6 bites

/obj/item/reagent_containers/food/berryclafoutis/throw_impact(atom/hit_atom, datum/thrownthing/TT)
	..()
	new /obj/effect/decal/cleanable/pie_smudge(loc)
	visible_message(SPAN("danger", "\The [src] splats."), SPAN("danger", "You hear a splat."))
	qdel(src)

/obj/item/reagent_containers/food/applepie
	name = "Apple Pie"
	desc = "A pie containing sweet sweet love... or apple."
	icon_state = "applepie"
	filling_color = "#e0edc5"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("apple" = 2, "pie" = 3)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30,
		/datum/reagent/sugar = 20,
		/datum/reagent/drink/juice/apple = 10
		)
	bitesize = 30 // 300 nutrition, 6 bites

/obj/item/reagent_containers/food/applepie/throw_impact(atom/hit_atom, datum/thrownthing/TT)
	..()
	new /obj/effect/decal/cleanable/pie_smudge(loc)
	visible_message(SPAN("danger", "\The [src] splats."), SPAN("danger", "You hear a splat."))
	qdel(src)

/obj/item/reagent_containers/food/cherrypie
	name = "Cherry Pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	filling_color = "#ff525a"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("cherry" = 2, "pie" = 2)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30,
		/datum/reagent/sugar = 10,
		/datum/reagent/nutriment/cherryjelly = 10
		)
	bitesize = 30 // 300 nutrition, 6 bites

/obj/item/reagent_containers/food/cherrypie/throw_impact(atom/hit_atom, datum/thrownthing/TT)
	..()
	new /obj/effect/decal/cleanable/pie_smudge(loc)
	visible_message(SPAN("danger", "\The [src] splats."), SPAN("danger", "You hear a splat."))
	qdel(src)

// Meat pies
/obj/item/reagent_containers/food/meatpie
	name = "Meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	trash = /obj/item/trash/dish/plate
	filling_color = "#948051"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("pie" = 3, "meat" = 2)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30,
		/datum/reagent/nutriment/protein/cooked = 150
		)
	bitesize = 25 // 570 nutrition, 12 bites

/obj/item/reagent_containers/food/xemeatpie
	name = "Xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/dish/plate
	filling_color = "#43de18"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("pie" = 3, "heresy" = 2)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30,
		/datum/reagent/nutriment/protein/cooked = 150
		)
	bitesize = 25 // 570 nutrition, 12 bites

/obj/item/reagent_containers/food/tofupie
	name = "Tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	trash = /obj/item/trash/dish/plate
	filling_color = "#fffee0"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("tofu" = 2, "pie" = 3)
	nutriment_amt = 195
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30
		)
	bitesize = 25 // 270 nutrition, 9 bites

// Mushroom pies
/obj/item/reagent_containers/food/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	filling_color = "#ffcccc"
	center_of_mass = "x=17;y=9"
	nutriment_desc = list("mushroom" = 3, "pie" = 2)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30 // Let's keep the basic stuff safe since amanitas w/ TRAIT_POTENCY=0 are non-toxic, we can get all the funny stuff during cooking.
		)
	bitesize = 25 // 195+ nutrition, 6+ bites

/obj/item/reagent_containers/food/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	filling_color = "#b8279b"
	center_of_mass = "x=17;y=9"
	nutriment_desc = list("heartiness" = 2, "mushroom" = 3, "pie" = 2)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30 // The same as above.
		)
	bitesize = 30 // 195+ nutrition, 5+ bites

/obj/item/reagent_containers/food/plump_pie/Initialize()
	. = ..()
	var/quality = rand(1, 100)
	switch(quality)
		if(100)
			name = "Planepacked Pie"
			desc = "This is a plump pie. All craftsdwarfship is of the highest quality. It is encrusted with Limestone, Gypsum, Native platinum, Magnetite, Limonite and Malachite, studded with Pig iron, decorated with cave lobster shell and dog leather and encircled with bands of Limestone, Gypsum, Magnetite, Native gold, Malachite, Limonite and Oak. This object is adorned with hanging rings of Limestone, Gypsum, Native platinum, Magnetite and Limonite and menaces with spikes of Limestone, Gypsum, Magnetite, Limonite, Malachite, Orthoclase, Steel and Brown jasper. On the item is an image of Fok'Byiond the Invisible virology airlock in Limestone."
			reagents.add_reagent(/datum/reagent/adminordrazine, 10)
		if(97 to 99)
			name = "¤plump pie¤"
			desc = "Microwave is taken by a fey mood! It has cooked a masterful plump pie!"
			reagents.add_reagent(/datum/reagent/tricordrazine, 15)
			reagents.add_reagent(/datum/reagent/drink/doctor_delight, 30)
		if(91 to 96)
			name = "≡plump pie≡"
			desc = "It's an exceptional plump pie. I bet you love stuff made out of plump helmets!"
			reagents.add_reagent(/datum/reagent/tricordrazine, 15)
			reagents.add_reagent(/datum/reagent/drink/doctor_delight, 15)
		if(81 to 90)
			name = "*plump pie*"
			desc = "It's a superior quality plump pie. I bet you love stuff made out of plump helmets!"
			reagents.add_reagent(/datum/reagent/tricordrazine, 15)
		if(66 to 80)
			name = "+plump pie+"
			desc = "It's a finely-cooked plump pie. I bet you love stuff made out of plump helmets!"
			reagents.add_reagent(/datum/reagent/tricordrazine, 10)
		if(46 to 65)
			name = "-plump pie-"
			desc = "It's a well-cooked plump pie. I bet you love stuff made out of plump helmets!"
			reagents.add_reagent(/datum/reagent/tricordrazine, 5)
