
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

/obj/item/reagent_containers/food/packaged/on_update_icon()
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
	nutriment_amt = 30
	startswith = list(
		/datum/reagent/sugar = 10,
		/datum/reagent/sugar/caramel = 10,
		/datum/reagent/nutriment/coco = 10
		)
	bitesize = 15 // 155 nutrition, 4 bites

/obj/item/reagent_containers/food/packaged/sweetroid
	name = "Sweetroid bar"
	desc = "It's green, it's chewy, and it's somehow related to xenoscience. But most definitely it's a candy!"
	icon_state = "sweetroid"
	trash = /obj/item/trash/sweetroid
	filling_color = "#5ba652"
	nutriment_desc = list("chewy sourness" = 6)
	nutriment_amt = 40
	startswith = list(
		/datum/reagent/sugar = 20
		)
	bitesize = 15 // 140 nutrition, 4 bites

/obj/item/reagent_containers/food/packaged/sugarmatter
	name = "SugarMatter bar"
	desc = "Should've been called SuperSugar. <span class='danger'>You get toothaches just from looking at it.</span>"
	icon_state = "sugarmatter"
	trash = /obj/item/trash/sugarmatter
	filling_color = "#5ba652"
	nutriment_desc = list("extreme sweetness" = 9)
	nutriment_amt = 30
	startswith = list(
		/datum/reagent/sugar = 30
		)
	bitesize = 15 // 180 nutrition, 4 bites

/obj/item/reagent_containers/food/packaged/jellaws
	name = "Jellaw's Jellybaton"
	desc = "Not such a robust thing, but its flavorings are definitely stunning!"
	icon_state = "jellaws"
	trash = /obj/item/trash/jellaws
	filling_color = "#5ba652"
	nutriment_desc = list("spicy cherry" = 3)
	nutriment_amt = 35
	startswith = list(
		/datum/reagent/sugar = 20,
		/datum/reagent/capsaicin = 2.5,
		/datum/reagent/flavoring/cherry = 2.5
		)
	bitesize = 15 // 135 nutrition, 4 bites

/obj/item/reagent_containers/food/packaged/nutribar
	name = "protein nutrition bar"
	desc = "SwoleMAX brand nutrition protein bars, guaranteed to get you feeling perfectly overconfident (and overweight)."
	icon_state = "nutribar"
	trash = /obj/item/trash/nutribar
	nutriment_amt = 30
	filling_color = "#e5bf00"
	nutriment_desc = list("packaging foam" = 5)
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 40,
		/datum/reagent/sugar = 20
		)
	bitesize = 20 // 230 nutrition, 5 bites

/obj/item/reagent_containers/food/packaged/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps."
	icon_state = "chips"
	trash = /obj/item/trash/chips
	filling_color = "#e8c31e"
	nutriment_amt = 100
	nutriment_desc = list("salt" = 1, "potato" = 1, "chips" = 3)
	startswith = list(
		/datum/reagent/salt = 10,
		/datum/reagent/nutriment/oil/burned = 40
		)
	bitesize = 15 // 220 nutrition, 10 bites

/obj/item/reagent_containers/food/packaged/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows. Or, perhaps, the finest space soy?"
	trash = /obj/item/trash/sosjerky
	filling_color = "#631212"
	nutriment_desc = list("cured meat" = 5, "salt" = 2)
	nutriment_amt = 40
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 70,
		/datum/reagent/salt = 10
		)
	bitesize = 15 // 215 nutrition, 8 bites

/obj/item/reagent_containers/food/packaged/no_raisin
	name = "4no Raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. Not sure why."
	trash = /obj/item/trash/raisins
	filling_color = "#542342"
	nutriment_desc = list("raisins" = 6)
	nutriment_amt = 72.5
	startswith = list(
		/datum/reagent/flavoring/grape = 2.5,
		/datum/reagent/sugar = 15
		)
	bitesize = 7.5 // 147.5 nutrition, 12 bites

/obj/item/reagent_containers/food/packaged/cheesiehonkers
	name = "Cheesie Honkers"
	icon_state = "cheesie_honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	trash = /obj/item/trash/cheesie
	filling_color = "#ffa305"
	nutriment_amt = 100
	nutriment_desc = list("cheese" = 5, "chips" = 2)
	startswith = list(
		/datum/reagent/salt = 10,
		/datum/reagent/nutriment/oil/burned = 40
		)
	bitesize = 15 // 220 nutrition, 10 bites

/obj/item/reagent_containers/food/packaged/hematogen
	name = "Hema-2-Gen"
	desc = "It's made of blood. It makes you produce blood. Ain't that kind of suspicious?.."
	icon_state = "hema2gen"
	trash = /obj/item/trash/hematogen
	filling_color = "#7d5f46"
	nutriment_amt = 15
	nutriment_desc = list("candy" = 5)
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 20,
		/datum/reagent/sugar = 15,
		/datum/reagent/albumin = 10
		)
	bitesize = 15 // 140 nutrition, 4 bites

/obj/item/reagent_containers/food/packaged/hemptogen
	name = "Hemp-2-Gen"
	desc = "It's made of cannabis. It sends you high. That's the medicine we truly deserve."
	icon_state = "hemp2gen"
	trash = /obj/item/trash/hemptogen
	filling_color = "#7d5f46"
	nutriment_amt = 2
	nutriment_desc = list("candy" = 1, "hemp" = 1)
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 20,
		/datum/reagent/sugar = 15,
		/datum/reagent/thc = 10
		)
	bitesize = 5 // 140 nutrition, 4 bites

/obj/item/reagent_containers/food/packaged/tastybread
	name = "bread tube"
	desc = "Bread in a tube. Chewy...and surprisingly tasty."
	icon_state = "tastybread"
	trash = /obj/item/trash/tastybread
	filling_color = "#a66829"
	nutriment_desc = list("bread" = 2, "sweetness" = 3)
	nutriment_amt = 150
	bitesize = 25 // 150 nutrition, 6 bites

/obj/item/reagent_containers/food/packaged/skrellsnacks
	name = "\improper SkrellSnax"
	desc = "Cured fungus shipped all the way from Jargon 4, almost like jerky! Almost."
	icon_state = "skrellsnacks"
	filling_color = "#a66829"
	trash = /obj/item/trash/skrellsnacks
	nutriment_desc = list("mushroom" = 5, "salt" = 2)
	nutriment_amt = 30
	startswith = list(
		/datum/reagent/nutriment/protein/fungal = 80,
		/datum/reagent/salt = 10
		)
	bitesize = 15 // 130 nutrition (230 for skrells), 8 bites

/obj/item/reagent_containers/food/packaged/syndicake
	name = "Syndi-Cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	filling_color = "#ff5d05"
	trash = /obj/item/trash/syndi_cakes
	nutriment_desc = list("sweetness" = 3, "cake" = 1)
	nutriment_amt = 100
	startswith = list(
		/datum/reagent/sugar = 15,
		/datum/reagent/drink/doctor_delight = 5
		)
	bitesize = 20 // 175 nutrition, 6 bites

/obj/item/reagent_containers/food/packaged/surstromming
	name = "\improper old canned food"
	icon_state = "surstromming"
	desc = "Extremely old canned food made of some sort of fermented fish."
	filling_color = "#cc8880"
	trash = /obj/item/trash/surstromming
	nutriment_desc = list("roting meat" = 3, "salt" = 4)
	nutriment_amt = 50
	startswith = list(
		/datum/reagent/salt = 10,
		/datum/reagent/nutriment/protein/cooked = 100,
		/datum/reagent/ethylredoxrazine = 1,
		/datum/reagent/sulfur = 10)
	bitesize = 30 // 300 nutrition, 6 bites

/obj/item/reagent_containers/food/packaged/surstromming/attack_self(mob/user)
	if(!is_open_container())
		trigger_vomit()
		playsound(loc, 'sound/items/cancrush1.ogg', 50, 1)
	return ..()

/obj/item/reagent_containers/food/packaged/surstromming/proc/trigger_vomit()
	var/list/mobs = list()
	var/list/objs = list()
	get_mobs_and_objs_in_view_fast(get_turf(src), 3, mobs, objs, 0)
	for(var/mob/living/carbon/human/H in mobs)
		if(H.internals && H.internals.icon_state == "internal1")
			continue
		H.vomit(0, 7, 3)
		to_chat(H, FONT_HUGE(SPAN_WARNING("You feel horrible stench! Every breath you take makes you want to puke!")))
	set_next_think(world.time + 20 SECONDS)

/obj/item/reagent_containers/food/packaged/surstromming/think()
	if(is_open_container())
		trigger_vomit()
	else
		set_next_think(0)
