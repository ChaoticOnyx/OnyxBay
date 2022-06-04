
/obj/item/reagent_containers/food/packaged
	name = "packaged snack"
	desc = "An edible object in a sealed wrapper."
	icon_state = "chips"
	icon = 'icons/obj/food_packaged.dmi'
	filling_color = "#7d5f46"
	center_of_mass = "x=16;y=16"
	atom_flags = null
	nutriment_amt = 1

/obj/item/reagent_containers/food/packaged/attack_self(mob/user)
	if(!is_open_container())
		to_chat(user, SPAN("notice", "You open \the [src]!"))
		atom_flags |= ATOM_FLAG_OPEN_CONTAINER
		update_icon()
		playsound(loc, 'sound/items/shpshpsh.ogg', 50, 1)
		return
	return ..()

/obj/item/reagent_containers/food/packaged/update_icon()
	if(is_open_container())
		if(bitecount)
			icon_state = "[initial(icon_state)]2"
		else
			icon_state = "[initial(icon_state)]1"
	else
		icon_state = initial(icon_state)


/obj/item/reagent_containers/food/packaged/tweakers
	name = "Tweakers bar"
	desc = "Nougat, love it or hate it. Along with caramel and peanuts, enrobed in milk chocolate. Technical assistants' favourite!"
	icon_state = "tweakers"
	trash = /obj/item/trash/tweakers
	filling_color = "#7d5f46"
	nutriment_desc = list("nougat-n-nuts" = 6)
	nutriment_amt = 6
	startswith = list(/datum/reagent/sugar = 3)
	bitesize = 3

/obj/item/reagent_containers/food/packaged/sweetroid
	name = "Sweetroid bar"
	desc = "It's green, it's chewy, and it's somehow related to xenoscience. But most definitely it's a candy!"
	icon_state = "sweetroid"
	trash = /obj/item/trash/sweetroid
	filling_color = "#5ba652"
	nutriment_desc = list("chewy sourness" = 6)
	nutriment_amt = 6
	startswith = list(/datum/reagent/sugar = 3)
	bitesize = 3

/obj/item/reagent_containers/food/packaged/sugarmatter
	name = "SugarMatter bar"
	desc = "Should've been called SuperSugar. <span class='danger'>You get toothaches just from looking at it.</span>"
	icon_state = "sugarmatter"
	trash = /obj/item/trash/sugarmatter
	filling_color = "#5ba652"
	nutriment_desc = list("extreme sweetness" = 6)
	nutriment_amt = 6
	startswith = list(/datum/reagent/sugar = 6)
	bitesize = 4

/obj/item/reagent_containers/food/packaged/jellaws
	name = "Jellaw's Jellybaton"
	desc = "Not such a robust thing, but its flavorings are definitely stunning!"
	icon_state = "jellaws"
	trash = /obj/item/trash/jellaws
	filling_color = "#5ba652"
	nutriment_desc = list("spicy cherry" = 3)
	nutriment_amt = 3
	startswith = list(
		/datum/reagent/sugar = 3,
		/datum/reagent/capsaicin = 1,
		/datum/reagent/nutriment/cherryjelly = 2)
	bitesize = 3

/obj/item/reagent_containers/food/packaged/nutribar
	name = "protein nutrition bar"
	desc = "SwoleMAX brand nutrition protein bars, guaranteed to get you feeling perfectly overconfident (and overweight)."
	icon_state = "nutribar"
	trash = /obj/item/trash/nutribar
	nutriment_amt = 7
	filling_color = "#e5bf00"
	nutriment_desc = list("packaging foam" = 1)
	startswith = list(
		/datum/reagent/nutriment/protein = 7,
		/datum/reagent/sugar = 2)
	bitesize = 4

/obj/item/reagent_containers/food/packaged/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps."
	icon_state = "chips"
	trash = /obj/item/trash/chips
	filling_color = "#e8c31e"
	nutriment_amt = 6
	nutriment_desc = list("salt" = 1, "chips" = 2)
	startswith = list(/datum/reagent/sodiumchloride = 2)
	bitesize = 1

/obj/item/reagent_containers/food/packaged/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows. Or, perhaps, the finest space soy?"
	trash = /obj/item/trash/sosjerky
	filling_color = "#631212"
	nutriment_desc = list("cured meat" = 5, "salt" = 2)
	nutriment_amt = 2
	startswith = list(
		/datum/reagent/nutriment/protein = 7,
		/datum/reagent/sodiumchloride = 1)
	bitesize = 2

/obj/item/reagent_containers/food/packaged/no_raisin
	name = "4no Raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. Not sure why."
	trash = /obj/item/trash/raisins
	filling_color = "#542342"
	nutriment_desc = list("raisins" = 6)
	nutriment_amt = 6
	startswith = list(/datum/reagent/drink/juice/grape = 4)
	bitesize = 1

/obj/item/reagent_containers/food/packaged/cheesiehonkers
	name = "Cheesie Honkers"
	icon_state = "cheesie_honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	trash = /obj/item/trash/cheesie
	filling_color = "#ffa305"
	nutriment_desc = list("cheese" = 5, "chips" = 2)
	nutriment_amt = 6
	startswith = list(/datum/reagent/sodiumchloride = 2)
	bitesize = 1

/obj/item/reagent_containers/food/packaged/hematogen
	name = "Hema-2-Gen"
	desc = "It's made of blood. It makes you produce blood. Ain't that kind of suspicious?.."
	icon_state = "hema2gen"
	trash = /obj/item/trash/hematogen
	filling_color = "#7d5f46"
	nutriment_amt = 2
	nutriment_desc = list("candy" = 1)
	startswith = list(
		/datum/reagent/nutriment/protein = 1,
		/datum/reagent/sugar = 2,
		/datum/reagent/albumin = 10)
	bitesize = 5

/obj/item/reagent_containers/food/packaged/hemptogen
	name = "Hemp-2-Gen"
	desc = "It's made of cannabis. It sends you high. That's the medicine we truly deserve."
	icon_state = "hemp2gen"
	trash = /obj/item/trash/hemptogen
	filling_color = "#7d5f46"
	nutriment_amt = 2
	nutriment_desc = list("candy" = 1, "hemp" = 1)
	startswith = list(
		/datum/reagent/sugar = 3,
		/datum/reagent/thc = 10)
	bitesize = 5

/obj/item/reagent_containers/food/packaged/tastybread
	name = "bread tube"
	desc = "Bread in a tube. Chewy...and surprisingly tasty."
	icon_state = "tastybread"
	trash = /obj/item/trash/tastybread
	filling_color = "#a66829"
	nutriment_desc = list("bread" = 2, "sweetness" = 3)
	nutriment_amt = 6
	bitesize = 2

/obj/item/reagent_containers/food/packaged/skrellsnacks
	name = "\improper SkrellSnax"
	desc = "Cured fungus shipped all the way from Jargon 4, almost like jerky! Almost."
	icon_state = "skrellsnacks"
	filling_color = "#a66829"
	trash = /obj/item/trash/skrellsnacks
	nutriment_desc = list("mushroom" = 5, "salt" = 2)
	nutriment_amt = 9
	startswith = list(/datum/reagent/sodiumchloride = 1)
	bitesize = 2

/obj/item/reagent_containers/food/packaged/syndicake
	name = "Syndi-Cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	filling_color = "#ff5d05"
	trash = /obj/item/trash/syndi_cakes
	nutriment_desc = list("sweetness" = 3, "cake" = 1)
	nutriment_amt = 4
	startswith = list(/datum/reagent/drink/doctor_delight = 5)
	bitesize = 3
