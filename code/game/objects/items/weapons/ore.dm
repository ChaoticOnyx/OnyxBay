

/obj/item/weapon/ore/New()
	src.amt = rand(1,4)
	processing_items+=src
	..()

/obj/item/weapon/ore/proc/cook()
	var/obj/item/weapon/sheet/metal/m = new /obj/item/weapon/sheet/metal( src.loc )
	m.amount = src.amt
	del src

/obj/item/weapon/ore/process()
	var/turf/t = get_turf(src)
	var/datum/gas_mixture/air_sample = t.return_air()
	if(t.temperature>=src.cook_temp||air_sample.temperature>=src.cook_temp)
		src.cook+=1
		if(src.cook>=src.cook_time)
			src.cook()
	else
		if(src.cook)
			src.cook-=1