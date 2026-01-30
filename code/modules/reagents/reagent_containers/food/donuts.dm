
/obj/item/reagent_containers/food/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	filling_color = "#d9c386"
	center_of_mass = "x=13;y=16"
	nutriment_amt = 4
	nutriment_desc = list("donut" = 2)
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1,
		/datum/reagent/sugar = 1
		)
	bitesize = 2 // 115 nutrition, 3 bites

	var/overlay_state = "box-donut1"

/obj/item/reagent_containers/food/donut/normal
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1
		)
	bitesize = 2 // 115 nutrition, 3 bites

/obj/item/reagent_containers/food/donut/normal/Initialize()
	. = ..()
	if(prob(30))
		SetName("frosted donut")
		icon_state = "donut2"
		overlay_state = "box-donut2"
		center_of_mass = "x=19;y=16"
		reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 10)
	else
		reagents.add_reagent(/datum/reagent/sugar, 10)

/obj/item/reagent_containers/food/donut/chaos
	name = "Chaos Donut"
	desc = "Like life, it never quite tastes the same."
	icon_state = "donut1"
	filling_color = "#ed11e6"
	nutriment_amt = 4
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1
		)
	bitesize = 2.5 // 11.5 to 16.5 nutrition, 3 bites

/obj/item/reagent_containers/food/donut/chaos/Initialize()
	. = ..()
	var/chaosselect = rand(0.1, 1)
	switch(chaosselect)
		if(1)
			reagents.add_reagent(/datum/reagent/nutriment, 1)
		if(2)
			reagents.add_reagent(/datum/reagent/capsaicin, 1)
		if(3)
			reagents.add_reagent(/datum/reagent/frostoil, 1)
		if(4)
			reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 1)
		if(5)
			reagents.add_reagent(/datum/reagent/toxin/plasma, 1)
		if(6)
			reagents.add_reagent(/datum/reagent/nutriment/coco, 1)
		if(7)
			reagents.add_reagent(/datum/reagent/metroidjelly, 1)
		if(8)
			reagents.add_reagent(/datum/reagent/drink/juice/banana, 1)
		if(9)
			reagents.add_reagent(/datum/reagent/drink/juice/berry, 1)
		if(10)
			reagents.add_reagent(/datum/reagent/tricordrazine, 1)

	if(prob(30))
		src.icon_state = "donut2"
		src.overlay_state = "box-donut2"
		src.SetName("Frosted Chaos Donut")
		reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 1)
	else
		reagents.add_reagent(/datum/reagent/sugar, 1)

/obj/item/reagent_containers/food/donut/jelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ed1169"
	center_of_mass = "x=16;y=11"
	nutriment_amt = 4
	nutriment_desc = list("berry jelly" = 2, "donut" = 2)
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1,
		/datum/reagent/drink/juice/berry = 3
		)
	bitesize = 3 // 16 nutrition, 3 bites

/obj/item/reagent_containers/food/donut/jelly/Initialize()
	. = ..()
	if(prob(30))
		src.icon_state = "jdonut2"
		src.overlay_state = "box-donut2"
		src.SetName("Frosted Jelly Donut")
		reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 1)
	else
		reagents.add_reagent(/datum/reagent/sugar, 1)

/obj/item/reagent_containers/food/donut/metroidjelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ed1169"
	center_of_mass = "x=16;y=11"
	nutriment_amt = 4
	nutriment_desc = list("weird jelly" = 2, "donut" = 2)
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1,
		/datum/reagent/metroidjelly = 1
		)
	bitesize = 2.5 // 11.5 nutrition, 3 bites

/obj/item/reagent_containers/food/donut/metroidjelly/Initialize()
	. = ..()
	if(prob(30))
		src.icon_state = "jdonut2"
		src.overlay_state = "box-donut2"
		src.SetName("Frosted Jelly Donut")
		reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 1)
	else
		reagents.add_reagent(/datum/reagent/sugar, 1)

/obj/item/reagent_containers/food/donut/cherryjelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ed1169"
	center_of_mass = "x=16;y=11"
	nutriment_amt = 4
	nutriment_desc = list("berry jelly" = 2, "donut" = 2)
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1,
		/datum/reagent/nutriment/cherryjelly = 3
		)
	bitesize = 3 // 16 nutrition, 3 bites

/obj/item/reagent_containers/food/donut/cherryjelly/Initialize()
	. = ..()
	if(prob(30))
		src.icon_state = "jdonut2"
		src.overlay_state = "box-donut2"
		src.SetName("Frosted Jelly Donut")
		reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 1)
	else
		reagents.add_reagent(/datum/reagent/sugar, 1)
