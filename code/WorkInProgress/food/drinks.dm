/obj/item/weapon/reagent_containers/food/drinks
	name = "drink"
	desc = "It's a glass."
	icon = 'food.dmi'
	icon_state = null
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.
		//The gulp size has been marked as broken since the goon code. What exactly is broken?

	examine()
		set src in view(2)
		..()
		usr << "\blue It contains:"
		if(!reagents) return
		if(reagents.total_volume)
			reagents.update_total()
			usr << "\blue [reagents.total_volume] units of liquid."
		else
			usr << "\blue Nothing."

	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
	/*	update_gulp_size()

	proc
		update_gulp_size()
			gulp_size = round(reagents.total_volume / 5)
			if (gulp_size < 5) gulp_size = 5
			Go away gulp_size, you are not wanted here!

	on_reagent_change()
		update_gulp_size() GO AWAY GULP SIZE, YOU ARE NOT WANTED HERE! */

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		var/datum/reagents/R = src.reagents

		if(!R.total_volume || !R)
			user << "\red None of [src] left, oh no!"
			return 0

		if(M == user)
			M << "\blue You swallow a gulp from the [src]."
			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, gulp_size)

			playsound(M.loc,'drink.ogg', rand(10,50), 1)
			M.urine += 0.1
			return 1

		else if( istype(M, /mob/living/carbon/human) )

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] attempts to feed [M] [src].", 1)
			if(!do_mob(user, M)) return
			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] feeds [M] [src].", 1)

			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, gulp_size)

			playsound(M.loc,'drink.ogg', rand(10,50), 1)
			M.urine += 0.1
			return 1

		return 0

	attackby(obj/item/I as obj, mob/user as mob)
		return

	afterattack(obj/target, mob/user , flag)

		if(istype(target, /obj/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if(!target.reagents.total_volume)
				user << "\red [target] is empty."
				return

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "\red [src] is full."
				return

			var/trans = target.reagents.trans_to(src, 10)
			user << "\blue You fill [src] with [trans] units of the contents of [target]."

		else if(target.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
			if(!reagents.total_volume)
				user << "\red [src] is empty."
				return

			if(target.reagents && target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return

			var/trans = src.reagents.trans_to(target, 10)
			user << "\blue You transfer [trans] units of the solution to [target]."

		else if (istype(target, /obj/machinery/sink)) //THIS ARE FOR MAKE PUT DRINK IN SINK SO EMPTY CUP.
			if(!reagents.total_volume)
				user << "\red [src] is empty."
				return

			var/trans = src.reagents.remove_any(30)
			user << "\blue You tip [trans] units of the solution down the [target]."
		return


/obj/item/weapon/reagent_containers/food/drinks/glass
	name = "drinking glass"
	icon = 'kitchen.dmi'
	icon_state = "glass_empty"
	item_state = "beaker"
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	amount_per_transfer_from_this = 10
	throwforce = 5
	g_amt = 100
	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src

/obj/item/weapon/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("coffee", 30)

/obj/item/weapon/reagent_containers/food/drinks/cola
	name = "space cola"
	desc = "Cola... in space."
	icon_state = "cola"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("cola", 30)

/obj/item/weapon/reagent_containers/food/drinks/beer
	name = "Space Beer"
	desc = "Beer... in space."
	icon_state = "beer"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("beer", 30)

/obj/item/weapon/reagent_containers/food/drinks/vodka
	name = "Space Vodka"
	desc = "IN SOVIET SPACE, VODKA DRINKS YOU!"
	icon_state = "vodka"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("vodka", 50)

/obj/item/weapon/reagent_containers/food/drinks/dwine
	name = "Dwarven Wine"
	desc = "Warning: highly toxic."
	icon_state = "dwine"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("dwine", 50)