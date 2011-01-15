/datum/event/electricalstorm
	var
		list/datum/radio_frequency/ScrambledFrequencies = list( )
		list/obj/machinery/light/Lights = list( )
		list/obj/machinery/light/APCs = list( )
		list/obj/machinery/light/Doors = list( )

	Announce()
		command_alert("The ship is flying through an electrical storm.  Radio communications may be disrupted", "Anomaly Alert")

		for (var/datum/radio_frequency/Freq in radio_controller.frequencies)
			if(prob(35))
				radio_controller.RegisterScrambler(Freq)
				ScrambledFrequencies += Freq

		for(var/obj/machinery/light/Light in world)
			if(Light.z < 5)
				Lights += Light

		for(var/obj/machinery/power/apc/APC in world)
			if(APC.z < 5 && !APC.crit)
				APCs += APC

		for(var/obj/machinery/door/airlock/Door in world)
			if(Door.z < 5)
				Doors += Door

	Tick()
		for(var/x = 0; x < 2; x++)
			if (prob(75))
				BlowLight()
		if (prob(20))
			DisruptAPC()
		if (prob(20))
			DisableDoor()


	Die()
		command_alert("The ship has cleared the electrical storm.  Radio communications restored", "Anomaly Alert")
		for (var/datum/radio_frequency/Freq in ScrambledFrequencies)
			radio_controller.UnregisterScrambler(Freq)

	proc
		BlowLight() //Blow out a light fixture
			var/obj/machinery/light/Light = null
			var/insanity = 0
			while (Light == null || Light.status != LIGHT_OK)
				Light = pick(Lights)
				insanity++
				if (insanity >= Lights.len)
					return

			spawn(0) //Overload the light, spectacularly.
				Light.ul_SetLuminosity(10)
				sleep(2)
				Light.on = 1
				Light.broken()

		DisruptAPC()
			var/insanity = 0
			var/obj/machinery/power/apc/APC
			while (!APC || !APC.operating)
				APC = pick(APCs)
				insanity++
				if (insanity >= APCs.len)
					return

			if (prob(40))
				APC.operating = 0 //Blow its breaker
			if (prob(8))
				APC.set_broken()

		DisableDoor()
			var/obj/machinery/door/airlock/Airlock
			while (!Airlock || Airlock.z > 4)
				Airlock = pick(Doors)
			Airlock.pulse(airlockIndexToWireColor[AIRLOCK_WIRE_DOOR_BOLTS])
			for (var/x = 0; x < 2; x++)
				var/Wire = 0
				while(!Wire || Wire == 4)
					Wire = rand(1, 9)
				Airlock.pulse(airlockIndexToWireColor[Wire])
			Airlock.update_icon()
