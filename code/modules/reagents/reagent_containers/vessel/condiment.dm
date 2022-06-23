
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.
//Notes by TobyThorne: This code is such a piece of shit i just can't. Rewrite it from scratch !!!as soon as possible!!!

//Food items that aren't eaten normally and leave an empty container behind.
/obj/item/reagent_containers/vessel/condiment
	name = "Condiment Container"
	desc = "Just your average condiment container."
	icon = 'icons/obj/reagent_containers/condiments.dmi'
	icon_state = "emptycondiment"
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	possible_transfer_amounts = "1;5;10"
	center_of_mass = "x=16;y=6"
	volume = 50
	lid_type = null

/obj/item/reagent_containers/vessel/condiment/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/pen) || istype(W, /obj/item/device/flashlight/pen))
		var/tmp_label = sanitizeSafe(input(user, "Enter a label for [name]", "Label", label_text), MAX_NAME_LEN)
		if(tmp_label == label_text)
			return
		if(length(tmp_label) > 10)
			to_chat(user, "<span class='notice'>The label can be at most 10 characters long.</span>")
		else
			if(length(tmp_label))
				to_chat(user, "<span class='notice'>You set the label to \"[tmp_label]\".</span>")
				label_text = tmp_label
				name = addtext(name," ([label_text])")
			else
				to_chat(user, "<span class='notice'>You remove the label.</span>")
				label_text = null
				on_reagent_change()
		return



/obj/item/reagent_containers/vessel/condiment/attack_self(mob/user as mob)
	return

/obj/item/reagent_containers/vessel/condiment/attack(mob/M as mob, mob/user as mob, def_zone)
	if(standard_feed_mob(user, M))
		return

/obj/item/reagent_containers/vessel/condiment/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return

	if(standard_dispenser_refill(user, target))
		return
	if(standard_pour_into(user, target))
		return

	if(istype(target, /obj/item/reagent_containers/food)) // These are not opencontainers but we can transfer to them
		if(!reagents || !reagents.total_volume)
			to_chat(user, "<span class='notice'>There is no condiment left in \the [src].</span>")
			return

		if(!target.reagents.get_free_space())
			to_chat(user, "<span class='notice'>You can't add more condiment to \the [target].</span>")
			return

		var/trans = reagents.trans_to_obj(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You add [trans] units of the condiment to \the [target].</span>")
	else
		..()

/obj/item/reagent_containers/vessel/condiment/self_feed_message(mob/user)
	to_chat(user, "<span class='notice'>You swallow some of contents of \the [src].</span>")

/obj/item/reagent_containers/vessel/condiment/on_reagent_change()
	if(reagents.reagent_list.len > 0)
		switch(reagents.get_master_reagent_type())
			if(/datum/reagent/nutriment/ketchup)
				name = "Ketchup"
				desc = "You feel more American already."
				icon_state = "ketchup"
				center_of_mass = "x=16;y=6"
			if(/datum/reagent/nutriment/barbecue)
				name = "Barbecue Sauce"
				desc = "Barbecue sauce, it's labeled 'sweet and spicy'"
				icon_state = "barbecue"
				center_of_mass = "x=16;y=6"
			if(/datum/reagent/capsaicin)
				name = "Hotsauce"
				desc = "You can almost TASTE the stomach ulcers now!"
				icon_state = "hotsauce"
				center_of_mass = "x=16;y=6"
			if(/datum/reagent/enzyme)
				name = "Universal Enzyme"
				desc = "Used in cooking various dishes."
				icon_state = "enzyme"
				center_of_mass = "x=16;y=6"
			if(/datum/reagent/nutriment/soysauce)
				name = "Soy Sauce"
				desc = "A salty soy-based flavoring."
				icon_state = "soysauce"
				center_of_mass = "x=16;y=6"
			if(/datum/reagent/frostoil)
				name = "Coldsauce"
				desc = "Leaves the tongue numb in its passage."
				icon_state = "coldsauce"
				center_of_mass = "x=16;y=6"
			if(/datum/reagent/sodiumchloride)
				name = "Salt Shaker"
				desc = "Salt. From space oceans, presumably."
				icon_state = "saltshaker"
				center_of_mass = "x=16;y=10"
			if(/datum/reagent/blackpepper)
				name = "Pepper Mill"
				desc = "Often used to flavor food or make people sneeze."
				icon_state = "peppermillsmall"
				center_of_mass = "x=16;y=10"
			if(/datum/reagent/nutriment/cornoil)
				name = "Corn Oil"
				desc = "A delicious oil used in cooking. Made from corn."
				icon_state = "oliveoil"
				center_of_mass = "x=16;y=6"
			if(/datum/reagent/sugar)
				name = "Sugar"
				desc = "Tastey space sugar!"
				center_of_mass = "x=16;y=6"
			else
				name = "Misc Condiment Bottle"
				if (reagents.reagent_list.len==1)
					desc = "Looks like it is [reagents.get_master_reagent_name()], but you are not sure."
				else
					desc = "A mixture of various condiments. [reagents.get_master_reagent_name()] is one of them."
				icon_state = "mixedcondiments"
				center_of_mass = "x=16;y=6"
	else
		icon_state = "emptycondiment"
		name = "Condiment Bottle"
		desc = "An empty condiment bottle."
		center_of_mass = "x=16;y=6"
	if(label_text)
		name = addtext(name," ([label_text])")

	return

/obj/item/reagent_containers/vessel/condiment/enzyme
	name = "Universal Enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"
	startswith = list(/datum/reagent/enzyme)

/obj/item/reagent_containers/vessel/condiment/barbecue
	name = "Barbecue Sauce"
	desc = "Barbecue sauce, it's labeled 'sweet and spicy'"
	icon_state = "barbecue"
	startswith = list(/datum/reagent/nutriment/barbecue)

/obj/item/reagent_containers/vessel/condiment/sugar
	startswith = list(/datum/reagent/sugar)

/obj/item/reagent_containers/vessel/condiment/small
	possible_transfer_amounts = "1;20"
	amount_per_transfer_from_this = 1
	volume = 20

/obj/item/reagent_containers/vessel/condiment/small/on_reagent_change()
	return

/obj/item/reagent_containers/vessel/condiment/small/saltshaker
	name = "salt shaker"
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	center_of_mass = "x=16;y=9"
	startswith = list(/datum/reagent/sodiumchloride)

/obj/item/reagent_containers/vessel/condiment/small/peppermill
	name = "pepper mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	center_of_mass = "x=16;y=8"
	startswith = list(/datum/reagent/blackpepper)

/obj/item/reagent_containers/vessel/condiment/small/sugar
	name = "sugar"
	desc = "Sweetness in a bottle"
	icon_state = "sugarsmall"
	center_of_mass = "x=17;y=9"
	startswith = list(/datum/reagent/sugar)

/obj/item/reagent_containers/vessel/condiment/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon_state = "flour"
	item_state = "flour"
	randpixel = 10
	startswith = list(/datum/reagent/nutriment/flour)

/obj/item/reagent_containers/vessel/condiment/flour/on_reagent_change()
	return
