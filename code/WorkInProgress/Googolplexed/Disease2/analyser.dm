/obj/machinery/disease2/diseaseanalyser
	name = "Disease Analyser"
	icon = 'stationobjs.dmi'
	icon_state = "autolathe1"
	anchored = 1
	density = 1

	var/scanning = 0

	var/obj/item/weapon/virusdish/dish = null

/obj/machinery/disease2/diseaseanalyser/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I,/obj/item/weapon/virusdish))
		var/mob/living/carbon/c = user
		if(!dish)

			dish = I
			c.drop_item()
			I.loc = src
			for(var/mob/M in viewers(src))
				if(M == user)	continue
				M.show_message("\blue [user.name] inserts the [dish.name] in the [src.name]", 3)


		else
			user << "There is already a dish inserted"

	//else
	return


/obj/machinery/disease2/diseaseanalyser/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)
	src.updateDialog()


	if(dish && !scanning)
		if(dish.virus2 && dish.growth > 50)
			dish.growth -= 10
			scanning = 25
		else
			dish.loc = src.loc
			dish = null
			for(var/mob/M in viewers(src))
				M.show_message("\blue The [src.name] buzzes", 2)

	if(scanning)
		scanning -= 1
		if(scanning == 0)
			var/r = "GNAv2 based virus lifeform"
			r += "<BR>Infection rate : [dish.virus2.infectionchance * 10]"
			r += "<BR>Spread form : [dish.virus2.spreadtype]"
			r += "<BR>Progress Speed : [dish.virus2.stageprob * 10]"
			for(var/datum/disease2/effectholder/E in dish.virus2.effects)
				r += "<BR>Effect:[E.effect.name]. Strength : [E.multiplier * 8]. Verosity : [E.chance * 15]. Type : [5-E.stage]."
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(src.loc)
			P.info = r
			dish.info = r
			dish.analysed = 1
			dish.loc = src.loc
			dish = null

			for(var/mob/O in hearers(src, null))
				O.show_message("\blue The [src.name] prints a sheet of paper", 3)



	return