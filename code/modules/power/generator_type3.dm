/obj/machinery/power/generator_type3/New()
	..()

	spawn(5)
		input1 = locate(/obj/machinery/atmos_new/generator_input) in get_step(src,EAST)
		input2 = locate(/obj/machinery/atmos_new/generator_input) in get_step(src,WEST)
		if(!input1 || !input2)
			stat |= BROKEN

		updateicon()

/obj/machinery/power/generator_type3/proc/updateicon()

	if(stat & (NOPOWER|BROKEN))
		overlays = null
	else
		overlays = null

		if(lastgenlev != 0)
			overlays += image('power.dmi', "teg-op[lastgenlev]")

/obj/machinery/power/generator_type3/process()

	if(!input1 || !input2)
		return

	var/datum/gas_mixture/air1 = input1.return_exchange_air()
	var/datum/gas_mixture/air2 = input2.return_exchange_air()


	lastgen = 0

	if(air1 && air2)
		var/datum/gas_mixture/hot_air = air1
		var/datum/gas_mixture/cold_air = air2

		if(hot_air.temperature < cold_air.temperature)
			hot_air = air2
			cold_air = air1

		var/hot_air_heat_capacity = hot_air.heat_capacity()
		var/cold_air_heat_capacity = cold_air.heat_capacity()

		var/delta_temperature = hot_air.temperature - cold_air.temperature

		if(delta_temperature > 1 && cold_air_heat_capacity > 0.01 && hot_air_heat_capacity > 0.01)
			var/efficiency = (1 - cold_air.temperature/hot_air.temperature) * 0.75 //45% of Carnot efficiency

			var/energy_transfer = delta_temperature*hot_air_heat_capacity*cold_air_heat_capacity/(hot_air_heat_capacity+cold_air_heat_capacity)
			energy_transfer *= (transferpercent/100)
			var/heat = energy_transfer*(1-efficiency)
			lastgen = energy_transfer*efficiency*outputpercent

			hot_air.temperature = hot_air.temperature - energy_transfer/hot_air_heat_capacity
			cold_air.temperature = cold_air.temperature + heat/cold_air_heat_capacity

			AddPower(lastgen)
	// update icon overlays only if displayed level has changed

	var/genlev = max(0, min( round(11*lastgen / 100000), 11))
	if(genlev != lastgenlev)
		lastgenlev = genlev
		updateicon()

	src.updateDialog()


/obj/machinery/power/generator_type3/attack_ai(mob/user)
	if(stat & (BROKEN|NOPOWER)) return

	interact(user)

/obj/machinery/power/generator_type3/attack_hand(mob/user)

	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER)) return

	interact(user)

/obj/machinery/power/generator_type3/proc/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) && (!istype(user, /mob/living/silicon/ai)))
		user.machine = null
		user << browse(null, "window=teg")
		return

	user.machine = src
	var/datum/gas_mixture
		input1_air_contents = input1.return_exchange_air()
		input2_air_contents = input2.return_exchange_air()

	var/t = "<PRE><B>Thermo-Electric Generator</B><HR>"

	t += "Output : [round(lastgen)] W<BR><BR>"

	t += "<B>Cold loop</B><BR>"
	t += "Temperature: [round(input1_air_contents.temperature, 0.1)] K<BR>"
	t += "Pressure: [round(input1_air_contents.return_pressure(), 0.1)] kPa<BR>"

	t += "<B>Hot loop</B><BR>"
	t += "Temperature: [round(input2_air_contents.temperature, 0.1)] K<BR>"
	t += "Pressure: [round(input2_air_contents.return_pressure(), 0.1)] kPa<BR>"

	t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A>"

	t += "</PRE>"
	user << browse(t, "window=teg;size=460x300")
	onclose(user, "teg")
	return 1

/obj/machinery/power/generator_type3/Topic(href, href_list)
	..()

	if( href_list["close"] )
		usr << browse(null, "window=teg")
		usr.machine = null
		return 0

	return 1

/obj/machinery/power/generator_type3/power_change()
	..()
	updateicon()