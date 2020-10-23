
/obj/item/weapon/reagent_containers/food/snacks/packaged
	name = "packaged snack"
	desc = "An edible object in a sealed wrapper."
	icon_state = "chips"
	icon = 'icons/obj/food_packaged.dmi'
	filling_color = "#7d5f46"
	center_of_mass = "x=16;y=16"
	atom_flags = null
	nutriment_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/packaged/attack_self(mob/user as mob)
	if(!is_open_container())
		to_chat(user, SPAN("notice", "You open \the [src]!"))
		atom_flags |= ATOM_FLAG_OPEN_CONTAINER
		update_icon()

/obj/item/weapon/reagent_containers/food/snacks/packaged/on_reagent_change()
	update_icon()
	return

/obj/item/weapon/reagent_containers/food/snacks/packaged/update_icon()
	if(is_open_container())
		if(bitecount)
			icon_state = "[initial(icon_state)]2"
		else
			icon_state = "[initial(icon_state)]1"
	else
		icon_state = initial(icon_state)

/obj/item/weapon/reagent_containers/food/snacks/packaged/tweakers
	name = "Tweakers bar"
	desc = "Nougat, love it or hate it. Along with caramel and peanuts, enrobed in milk chocolate. Technical assistants' favourite!"
	icon_state = "tweakers"
	trash = /obj/item/trash/tweakers
	filling_color = "#7d5f46"
	nutriment_desc = list("nougat-n-nuts" = 6)
	nutriment_amt = 6

/obj/item/weapon/reagent_containers/food/snacks/packaged/tweakers/New()
	..()
	reagents.add_reagent(/datum/reagent/sugar, 3)
	bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/packaged/sweetroid
	name = "Sweetroid bar"
	desc = "It's green, it's chewy, and it's somehow related to xenoscience. But most definitely it's a candy."
	icon_state = "sweetroid"
	trash = /obj/item/trash/sweetroid
	filling_color = "#5ba652"
	nutriment_desc = list("chewy sourness" = 6)
	nutriment_amt = 6

/obj/item/weapon/reagent_containers/food/snacks/packaged/sweetroid/New()
	..()
	reagents.add_reagent(/datum/reagent/sugar, 3)
	bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/packaged/sugarmatter
	name = "SugarMatter bar"
	desc = "Shoud've been called SuperSugar. <span class='danger'>You get toothaches just from looking at it.</span>"
	icon_state = "sugarmatter"
	trash = /obj/item/trash/sugarmatter
	filling_color = "#5ba652"
	nutriment_desc = list("extreme sweetness" = 6)
	nutriment_amt = 6

/obj/item/weapon/reagent_containers/food/snacks/packaged/sugarmatter/New()
	..()
	reagents.add_reagent(/datum/reagent/sugar, 6)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/packaged/jellaws
	name = "Jellaw's Jellybaton"
	desc = "Not such a robust thing, but it's flavorings are definitely stunning."
	icon_state = "jellaws"
	trash = /obj/item/trash/jellaws
	filling_color = "#5ba652"
	nutriment_desc = list("spicy cherry" = 3)
	nutriment_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/packaged/jellaws/New()
	..()
	reagents.add_reagent(/datum/reagent/sugar, 3)
	reagents.add_reagent(/datum/reagent/capsaicin, 1)
	reagents.add_reagent(/datum/reagent/nutriment/cherryjelly, 2)
	bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/packaged/nutribar
	name = "protein nutrition bar"
	desc = "SwoleMAX brand nutrition protein bars, guaranteed to get you feeling perfectly overconfident (and overweight)."
	icon_state = "nutribar"
	trash = /obj/item/trash/nutribar
	nutriment_amt = 7
	filling_color = "#e5bf00"
	nutriment_desc = list("packaging foam" = 1)

/obj/item/weapon/reagent_containers/food/snacks/packaged/nutribar/New()
	..()
	reagents.add_reagent(/datum/reagent/nutriment/protein, 7)
	reagents.add_reagent(/datum/reagent/sugar, 2)
	bitesize = 4


/obj/item/weapon/reagent_containers/food/snacks/packaged/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps."
	icon_state = "chips"
	trash = /obj/item/trash/chips
	filling_color = "#e8c31e"
	nutriment_amt = 6
	nutriment_desc = list("salt" = 1, "chips" = 2)

/obj/item/weapon/reagent_containers/food/snacks/packaged/chips/New()
	..()
	reagents.add_reagent(/datum/reagent/sodiumchloride, 2)
	bitesize = 1


/obj/item/weapon/reagent_containers/food/snacks/packaged/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows. Or, perhaps, the finest space soy?"
	trash = /obj/item/trash/sosjerky
	filling_color = "#631212"
	nutriment_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/packaged/sosjerky/New()
	..()
	reagents.add_reagent(/datum/reagent/nutriment/protein, 7)
	reagents.add_reagent(/datum/reagent/sodiumchloride, 1)
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/packaged/no_raisin
	name = "4no Raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. Not sure why."
	trash = /obj/item/trash/raisins
	filling_color = "#542342"
	nutriment_desc = list("raisins" = 6)
	nutriment_amt = 6

/obj/item/weapon/reagent_containers/food/snacks/packaged/no_raisin/New()
	..()
	reagents.add_reagent(/datum/reagent/drink/juice/grape, 4)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/packaged/cheesiehonkers
	name = "Cheesie Honkers"
	icon_state = "cheesie_honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	trash = /obj/item/trash/cheesie
	filling_color = "#ffa305"
	nutriment_desc = list("cheese" = 5, "chips" = 2)
	nutriment_amt = 6

/obj/item/weapon/reagent_containers/food/snacks/packaged/cheesiehonkers/New()
	..()
	reagents.add_reagent(/datum/reagent/sodiumchloride, 2)
	bitesize = 1


/obj/item/weapon/reagent_containers/food/snacks/packaged/hematogen
	name = "Hema-2-Gen"
	desc = "It's made of blood. It makes you produce blood. Ain't that kind of suspicious?.."
	icon_state = "hema2gen"
	trash = /obj/item/trash/hematogen
	filling_color = "#7d5f46"
	nutriment_amt = 2
	nutriment_desc = list("candy" = 1)

/obj/item/weapon/reagent_containers/food/snacks/packaged/hematogen/New()
	..()
	reagents.add_reagent(/datum/reagent/nutriment/protein, 1)
	reagents.add_reagent(/datum/reagent/sugar, 2)
	reagents.add_reagent(/datum/reagent/albumin, 10)
	bitesize = 5
