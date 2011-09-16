

/obj/item/kitchen/food_processor
	icon = 'code/WorkInProgress/Uristqwerty/food_processor_placeholder.dmi'


/obj/item/kitchen/food_processor/attackby(obj/item/weapon/W as obj, mob/user as mob)

	var/list/processables = list(
		/obj/item/weapon/plant/sugar = /obj/item/weapon/reagent_containers/food/snacks/sugar,

		/obj/item/weapon/reagent_containers/food/snacks/plant/tomato = list(/obj/item/weapon/reagent_containers/food/snacks/ketchup,
																	  /obj/item/weapon/reagent_containers/food/snacks/ketchup)
		)

	//Note:Associations in output list could be used for something. Perhaps probability of creation?

	if(istype(loc, /turf) && W.type in processables)
		if(istype(processables[W.type], /list))
			for(var/result_type in processables[W.type])
				new result_type(loc)

			del W

		else if(ispath(processables[W.type]))
			var/result_type = processables[W.type]
			new result_type(loc)

			del W

	else
		..()
