/obj/machinery/anomaly/anomalyanalyser
	name = "Anomaly Analyser"
	icon = 'virology.dmi'
	icon_state = "analyser"
	anchored = 1
	density = 1
	var/scanning = 0
	var/pause = 0

	var/obj/item/weapon/anomaly/a= null

/obj/machinery/anomaly/anomalyanalyser/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I,/obj/item/weapon/anomaly))
		var/mob/living/carbon/c = user
		if(!a)

			a = I
			c.drop_item()
			I.loc = src
			for(var/mob/M in viewers(src))
				if(M == user)	continue
				M.show_message("\blue [user.name] inserts the [a.name] in the [src.name]", 3)


		else
			user << "There is already an anomaly inserted"

	//else
	return


/obj/machinery/anomaly/anomalyanalyser/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)
	src.updateDialog()


	if(scanning)
		scanning -= 1
		if(scanning == 0)
			var/r = "[a.name]"
			r += "<BR>Effect :	[a.e.fluff]"
			r += "<BR>Range :	[a.e.range]"
			r += "<BR>Magnitude :	[a.e.magnitude]"
			r += "<BR>Predicted recharge period :	[a.e.cooldown]"
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(src.loc)
			P.info = r
			a.loc = src.loc
			a = null
			icon_state = "analyser"

			for(var/mob/O in hearers(src, null))
				O.show_message("\icon[src] \blue The [src.name] prints a sheet of paper", 3)
	else if(a && !scanning)
		scanning = 25
		icon_state = "analyser_processing"




	return