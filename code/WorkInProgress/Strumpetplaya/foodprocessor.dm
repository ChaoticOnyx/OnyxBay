//If Dream Maker will let me do it this way, then dammit I'm going to do it this way!
//I challenge you to come up with a more lazy method.
//ALL food processing code is contained here. (Cause BYOND lets you do this!)
//I figure this is probably better/easier than spreading this shit out among multiple files.

/obj/machinery/food_processor
	name = "food processor"
	desc = "A food processor used to... process foods."
	icon = 'cooking.dmi'
	icon_state = "food_processor"
	anchored = 1
	var/doing_stuff = 0

obj/machinery/food_processor/attackby(obj/item/weapon/reagent_containers/food/F as obj, mob/user as mob)
	if(doing_stuff == 1)
		user << "The food processor is already busy processing something."
		return
	if(!F.process_result)
		user << "The food processor can't do anything with that."
		return
	if(F.process_result && doing_stuff == 0)
		user << "You stick the [F.name] into the food processor."
		user.u_equip(F)
		F.loc = src
		user.client.screen -= F
		doing_stuff = 1
		icon_state = "food_processor_on"
		spawn(63)
			icon_state = "food_processor"
			doing_stuff = 0
			new F.process_result(src.loc)
			del(F)

/obj/item/weapon
	var/process_result = null

//Just add a process_result variable to whatever it is you want to be able to process.
/obj/item/weapon/reagent_containers/food/snacks/plant/tomato
	process_result = /obj/item/weapon/reagent_containers/food/snacks/ketchup

/obj/item/weapon/plant/wheat
	process_result = /obj/item/weapon/reagent_containers/food/snacks/flour

/obj/item/weapon/plant/sugar
	process_result = /obj/item/weapon/reagent_containers/food/snacks/sugar