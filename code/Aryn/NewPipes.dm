#define RADIATION_CAPACITY 30000
#define CONDUCTION_SKIP 0

/obj/cabling/flexipipe
	icon = 'pipes_net.dmi'

	name = "Pipeline"
	layer = 2.4

	ConnectableTypes = list( /obj/machinery/atmos_new )
	NetworkControllerType = /datum/UnifiedNetworkController/FlexipipeNetworkController
	DropCablePieceType = /obj/item/weapon/CableCoil/flexipipe
	EquivalentCableType = /obj/cabling/flexipipe
	var/conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

	manifold
		var/initialize_directions
		icon = 'pipes.dmi'
		icon_state = "manifold"
		New()
			icon = 'pipes_net.dmi'
			switch(dir)
				if(1)
					new/obj/cabling/flexipipe(loc,2,4)
					new/obj/cabling/flexipipe(loc,2,8)
					new/obj/cabling/flexipipe(loc,1,2)
					del src
				if(2)
					new/obj/cabling/flexipipe(loc,1,4)
					new/obj/cabling/flexipipe(loc,1,8)
					new/obj/cabling/flexipipe(loc,1,2)
					del src
				if(4)
					new/obj/cabling/flexipipe(loc,1,8)
					new/obj/cabling/flexipipe(loc,2,8)
					new/obj/cabling/flexipipe(loc,4,8)
					del src
				if(8)
					new/obj/cabling/flexipipe(loc,1,4)
					new/obj/cabling/flexipipe(loc,2,4)
					new/obj/cabling/flexipipe(loc,4,8)
					del src

	simple
		icon = 'pipes.dmi'
		icon_state = "intact"
		var/initialize_directions
		New()
			icon = 'pipes_net.dmi'
			switch(dir)
				if(1 to 2) icon_state = "1-2"
				if(4) icon_state = "4-8"
				if(5) icon_state = "1-4"
				if(6) icon_state = "2-4"
				if(8) icon_state = "4-8"
				if(9) icon_state = "1-8"
				if(10) icon_state = "2-8"
			. = ..()
		insulated
			icon = 'red_pipe.dmi'
			icon_state = "intact"
			New()
				icon = 'pipes_insulated.dmi'
				switch(dir)
					if(1 to 2) icon_state = "1-2"
					if(4) icon_state = "4-8"
					if(5) icon_state = "1-4"
					if(6) icon_state = "2-4"
					if(8) icon_state = "4-8"
					if(9) icon_state = "1-8"
					if(10) icon_state = "2-8"
				. = ..()

/obj/item/weapon/CableCoil/flexipipe
	icon_state = "pipecoil3"
	CoilColour = "pipe"
	BaseName  = "Tubing"
	ShortDesc = "A piece of hollow tubing"
	LongDesc  = "A long piece of hollow tubing"
	CoilDesc  = "A Spool of hollow tubing"
	CableType = /obj/cabling/flexipipe
	CanLayDiagonally = 0

/obj/machinery/atmos_new
	icon = 'pipes_placeholder.dmi'
	anchored = 1
	proc/Process()
	proc/Detach()

	/*
	Still Needed -
	Tanks [X]
	Air Filter [X]
	Mixer [X]
	Vent/Filter [ ]
	Temp. Exchangers [X]
	Freezers [X]
	*/

	tank
		name = "Gas Tank"
		icon = 'pipe_tank.dmi'
		var/volume = 1620
		var/datum/gas_mixture/air_contents = new
		New()
			. = ..()
			air_contents.volume = volume
			air_contents.temperature = T20C

		Process(datum/UnifiedNetworkController/FlexipipeNetworkController/Controller)
			var/env_pressure = Controller.air_contents.return_pressure()
			var/datum/gas_mixture/environment = Controller.air_contents
			var/pressure_delta = (air_contents.return_pressure() - env_pressure)
			//Can not have a pressure delta that would cause environment pressure > tank pressure

			var/transfer_moles = 0
			if((air_contents.temperature > 0) && (pressure_delta > 0))
				transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

				//Actually transfer the gas
				var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

				environment.merge(removed)
			else if(pressure_delta < 0)
				// take in air from outside
				transfer_moles = -pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = environment.remove(transfer_moles)

				air_contents.merge(removed)

		co2_tank
			name = "Gas Tank \[CO2\]"
			New()
				. = ..()
				air_contents.carbon_dioxide = (35*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
		plasma_tank
			name = "Gas Tank \[Toxin (Bio)\]"
			icon = 'orange_pipe_tank.dmi'
			New()
				. = ..()
				air_contents.toxins = (35*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

		oxy_tank
			name = "Gas Tank \[Oxygen\]"
			icon = 'blue_pipe_tank.dmi'
			New()
				. = ..()
				air_contents.oxygen = (35*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

		air_tank
			name = "Gas Tank \[Air\]"
			icon = 'red_pipe_tank.dmi'
			New()
				. = ..()
				air_contents.oxygen = (35*ONE_ATMOSPHERE*O2STANDARD)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
				air_contents.nitrogen = (35*ONE_ATMOSPHERE*N2STANDARD)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
		nitro_tank
			name = "Gas Tank \[Nitrogen\]"
			icon = 'red_pipe_tank.dmi'
			New()
				. = ..()
				air_contents.nitrogen = (35*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	vent
		name = "Gas Vent"
		icon_state = "vent"

		Process(datum/UnifiedNetworkController/FlexipipeNetworkController/Controller)
			var/datum/gas_mixture/air_contents = loc.return_air()
			var/env_pressure = Controller.air_contents.return_pressure()
			var/datum/gas_mixture/environment = Controller.air_contents
			var/pressure_delta = (air_contents.return_pressure() - env_pressure)
			//Can not have a pressure delta that would cause environment pressure > tank pressure

			var/transfer_moles = 0
			if((air_contents.temperature > 0) && (pressure_delta > 0))
				transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

				//Actually transfer the gas
				var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

				environment.merge(removed)
			else if(pressure_delta < 0)
				// take in air from outside
				transfer_moles = -pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = environment.remove(transfer_moles)

				air_contents.merge(removed)

	vent_filter
		name = "Gas Vent"
		icon_state = "vent"
		var/burst = 0
		var/on = 1
		var/pump_direction = 0 //0 = equalizing, 1 = releasing, -1 = siphoning
		var/toxins_fil = 1
		var/o2_fil = 0
		var/co2_fil = 1
		var/trace_fil = 1
		var/no_fil = 0
		var/external_pressure_bound = ONE_ATMOSPHERE
		var/internal_pressure_bound = 4000

		var/panic_fill = 0		//Strumpetplaya - Added this as quick fix to get alarm interfaces working again.
		var/panic_filling = 0	//This too.


		var/pressure_checks = 1
		//1: Do not pass external_pressure_bound
		//2: Do not pass internal_pressure_bound
		//3: Do not pass either

		var/debug_info = 0


		Process(datum/UnifiedNetworkController/FlexipipeNetworkController/Controller)

			var/turf/locT = src.loc
			var/datum/gas_mixture/air_contents = Controller:air_contents
			if(locT.zone.space_connections.len >= 1)
				return
			if(!on)
				return 0
			var/datum/gas_mixture/environment = loc.return_air(1)
		//	var/environment_pressure = environment.return_pressure()
			if(pressure_checks & 1)
				if(environment.return_pressure() >= external_pressure_bound) return

			var/turf/simulated/T = loc
			var
				used_pressure = air_contents.return_pressure()//min(air_contents.return_pressure(),external_pressure_bound)
				used_temperature = environment.temperature
			var/transfer_moles = used_pressure*air_contents.volume/(max(used_temperature,TCMB) * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/env = air_contents.remove(transfer_moles)
			var/datum/gas_mixture/filtered_out = new
			if(panic_fill && istype(loc, /turf/simulated/))
				if(T.zone && T.zone.pressure < ONE_ATMOSPHERE*0.95)
					var/K = ONE_ATMOSPHERE - T.zone.pressure
					K = K/R_IDEAL_GAS_EQUATION/used_temperature*T.zone.volume
					if(debug_info) world << "moles:[K]Pressure:[T.zone.pressure]/[ONE_ATMOSPHERE]Total moles:[T.zone.total_moles()]"
					var/datum/gas_mixture/env2 = air_contents.remove(K)
					T.assume_air(env2)
				else
					panic_fill = 0
			if(!env)
				return
			if(toxins_fil && env.toxins)
				filtered_out.toxins = env.toxins
				env.toxins = 0
			if(co2_fil && env.carbon_dioxide)
				filtered_out.carbon_dioxide = env.carbon_dioxide
				env.carbon_dioxide = 0
			if(trace_fil)
				if(env.trace_gases.len>0)
					for(var/datum/gas/trace_gas in env.trace_gases)
						if(istype(trace_gas, /datum/gas/oxygen_agent_b))
							env.trace_gases -= trace_gas
							filtered_out.trace_gases += trace_gas
			air_contents.merge(filtered_out)
			if(env) T.assume_air(env)
			return 1

	vent_scrubber
		name = "Scrubber"
		icon_state = "inlet"
		var/on = 0
		var/scrubbing = 1 //0 = siphoning, 1 = scrubbing
		var/scrub_CO2 = 1
		var/scrub_Toxins = 1
		var/scrub_Sleep = 1

		var/volume_rate = 120
		Process(datum/UnifiedNetworkController/FlexipipeNetworkController/Controller)
			if(!on)
				return 0

			var/datum/gas_mixture/environment = loc.return_air()
			var/datum/gas_mixture/air_contents = Controller:air_contents

			if(scrubbing)
				if((environment.toxins>0) || (environment.carbon_dioxide>0) || (environment.trace_gases.len>0))
					var/transfer_moles = min(1, volume_rate/environment.volume)*environment.total_moles()

					//Take a gas sample
					var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

					//Filter it
					var/datum/gas_mixture/filtered_out = new
					filtered_out.temperature = removed.temperature
					if(scrub_Toxins)
						filtered_out.toxins = removed.toxins
						removed.toxins = 0
					if(scrub_CO2)
						filtered_out.carbon_dioxide = removed.carbon_dioxide
						removed.carbon_dioxide = 0


					if(removed.trace_gases.len>0)
						for(var/datum/gas/trace_gas in removed.trace_gases)
							if(istype(trace_gas, /datum/gas/oxygen_agent_b))
								if(scrub_Toxins)
									removed.trace_gases -= trace_gas
									filtered_out.trace_gases += trace_gas
							if(istype(trace_gas, /datum/gas/sleeping_agent))
								if(scrub_Sleep)
									removed.trace_gases -= trace_gas
									filtered_out.trace_gases += trace_gas

					//Remix the resulting gases
					air_contents.merge(filtered_out)

					loc.assume_air(removed)


			else //Just siphoning all air
				var/transfer_moles = environment.total_moles()*(volume_rate/environment.volume)

				var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

				air_contents.merge(removed)

			return 1
	vent_pump
		icon_state = "vent"
		name = "Vent Pump"
		var/on = 1
		var/pump_direction = 1 //0 = siphoning, 1 = releasing

		var/external_pressure_bound = ONE_ATMOSPHERE
		var/internal_pressure_bound = 0

		var/pressure_checks = 1
		//1: Do not pass external_pressure_bound
		//2: Do not pass internal_pressure_bound
		//3: Do not pass either

		Process(datum/UnifiedNetworkController/FlexipipeNetworkController/Controller)
			..()
			if(!on)
				icon_state = "vent"
				return 0

			if(pump_direction)
				icon_state = "out"
			else
				icon_state = "in"

			var/datum/gas_mixture/environment = loc.return_air(1)
			var/datum/gas_mixture/air_contents = Controller.air_contents
			//var/environment_pressure = environment.return_pressure()
			if(pump_direction)
				var/pressure_delta = external_pressure_bound - environment.return_pressure()
				//Can not have a pressure delta that would cause environment pressure > tank pressure

				var/transfer_moles = 0
				if(air_contents.temperature > 0)
					transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)
					transfer_moles *= 10 // fuck it, just speed up the process by 10 times

					//Actually transfer the gas
					var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

					if(removed) loc.assume_air(removed)
			else
				var/pressure_delta = internal_pressure_bound - air_contents.return_pressure()
				//Can not have a pressure delta that would cause environment pressure > tank pressure

				var/transfer_moles = 0
				if(environment.temperature > 0)
					transfer_moles = pressure_delta*air_contents.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)
					transfer_moles *= 10

					//Actually transfer the gas
					var/datum/gas_mixture/removed

					removed = loc.remove_air(transfer_moles)

					if(removed) air_contents.merge(removed)

		//Radio remote control

		proc
			set_frequency(new_frequency)
				radio_controller.remove_object(src, "[frequency]")
				frequency = new_frequency
				if(frequency)
					radio_connection = radio_controller.add_object(src, "[frequency]")

			broadcast_status()
				if(!radio_connection)
					return 0

				var/datum/signal/signal = new
				signal.transmission_method = 1 //radio signal
				signal.source = src

				signal.data["tag"] = id
				signal.data["device"] = "AVP"
				signal.data["power"] = on?("on"):("off")
				signal.data["direction"] = pump_direction?("release"):("siphon")
				signal.data["checks"] = pressure_checks
				signal.data["internal"] = internal_pressure_bound
				signal.data["external"] = external_pressure_bound

				radio_connection.post_signal(src, signal)

				return 1

		var/frequency = 0
		var/id = null
		var/datum/radio_frequency/radio_connection

		New()
			..()
			if(frequency)
				set_frequency(frequency)

		receive_signal(datum/signal/signal)
			if(signal.data["tag"] && (signal.data["tag"] != id))
				return 0

			switch(signal.data["command"])
				if("power_on")
					on = 1

				if("power_off")
					on = 0

				if("power_toggle")
					on = !on

				if("set_direction")
					var/number = text2num(signal.data["parameter"])
					if(number > 0.5)
						pump_direction = 1
					else
						pump_direction = 0

				if("purge")
					pressure_checks &= ~1
					pump_direction = 0

				if("stabalize")
					pressure_checks |= 1
					pump_direction = 1

				if("set_checks")
					var/number = round(text2num(signal.data["parameter"]),1)
					pressure_checks = number

				if("set_internal_pressure")
					var/number = text2num(signal.data["parameter"])
					number = min(max(number, 0), ONE_ATMOSPHERE*50)

					internal_pressure_bound = number

				if("set_external_pressure")
					var/number = text2num(signal.data["parameter"])
					number = min(max(number, 0), ONE_ATMOSPHERE*50)

					external_pressure_bound = number

			if(signal.data["tag"])
				spawn(5 * tick_multiplier) broadcast_status()


	filter
		name = "Pipeline Filtration Hub"
		icon_state = "filter_off"
		var/target_pressure = 500
		var/filter_type = 0
		var/on = 1
		var/turf
			A
			B
			C
		Process(datum/UnifiedNetworkController/FlexipipeNetworkController/Controller)
			if(!on)
				icon_state = "filter_off"
				return 1
			else
				icon_state = "filter_on"
			if(!A)
				A = get_step(src,turn(dir,270))
				//A.overlays += 'debug_connect.dmi'
			if(!B)
				B = get_step(src,dir)
				//B.overlays += 'debug_connect.dmi'
			if(!C)
				C = get_step(src,turn(dir,180))
				//C.overlays += 'debug_connect.dmi'
			var/datum/UnifiedNetwork
				OutputANet
				OutputBNet
				InputNet
			for(var/obj/cabling/flexipipe/P in A)
				if(P.Networks[P.type] && (P.Direction1 == turn(dir,90) || P.Direction2 == turn(dir,90)))
					OutputANet = P.Networks[P.type]

			for(var/obj/cabling/flexipipe/P in B)
				if(P.Networks[P.type] && (P.Direction1 == turn(dir,180) || P.Direction2 == turn(dir,180)))
					OutputBNet = P.Networks[P.type]

			for(var/obj/cabling/flexipipe/P in C)
				if(P.Networks[P.type] && (P.Direction1 == dir || P.Direction2 == dir))
					InputNet = P.Networks[P.type]

			if(OutputANet && OutputBNet && InputNet)
				var/datum/gas_mixture
					air_in = InputNet.Controller:air_contents
					air_out1 = OutputANet.Controller:air_contents
					air_out2 = OutputBNet.Controller:air_contents

				var/output_starting_pressure = air_out2.return_pressure()

				if(output_starting_pressure >= target_pressure)
					//No need to mix if target is already full!
					return 1

				//Calculate necessary moles to transfer using PV=nRT

				var/pressure_delta = target_pressure - output_starting_pressure
				var/transfer_moles

				if(air_in.temperature > 0)
					transfer_moles = pressure_delta*air_out2.volume/(air_in.temperature * R_IDEAL_GAS_EQUATION)

				//Actually transfer the gas

				if(transfer_moles > 0)
					var/datum/gas_mixture/removed = air_in.remove(transfer_moles)

					var/datum/gas_mixture/filtered_out = new
					filtered_out.temperature = removed.temperature

					switch(filter_type)
						if(0) //removing hydrocarbons
							filtered_out.toxins = removed.toxins
							removed.toxins = 0

							filtered_out.carbon_dioxide = removed.carbon_dioxide
							removed.carbon_dioxide = 0

							if(removed.trace_gases.len>0)
								for(var/datum/gas/trace_gas in removed.trace_gases)
									if(istype(trace_gas, /datum/gas/oxygen_agent_b))
										removed.trace_gases -= trace_gas
										filtered_out.trace_gases += trace_gas

						if(1) //removing O2
							filtered_out.oxygen = removed.oxygen
							removed.oxygen = 0

						if(2) //removing N2
							filtered_out.nitrogen = removed.nitrogen
							removed.nitrogen = 0

							if(removed.trace_gases.len>0)
								for(var/datum/gas/trace_gas in removed.trace_gases)
									if(istype(trace_gas, /datum/gas/sleeping_agent))
										removed.trace_gases -= trace_gas
										filtered_out.trace_gases += trace_gas

						if(3) //removing CO2
							filtered_out.carbon_dioxide = removed.carbon_dioxide
							removed.carbon_dioxide = 0

						if(4) //All but plasma and agent B

							filtered_out.oxygen = removed.oxygen
							removed.oxygen = 0

							filtered_out.nitrogen = removed.nitrogen
							removed.nitrogen = 0

							filtered_out.carbon_dioxide = removed.carbon_dioxide
							removed.carbon_dioxide = 0

							for(var/datum/gas/trace_gas in removed.trace_gases)
								if(istype(trace_gas, /datum/gas/sleeping_agent))
									removed.trace_gases -= trace_gas
									filtered_out.trace_gases += trace_gas

						if(5) //Plasma + OAB
							filtered_out.toxins = removed.toxins
							removed.toxins = 0

							if(removed.trace_gases.len>0)
								for(var/datum/gas/trace_gas in removed.trace_gases)
									if(istype(trace_gas, /datum/gas/oxygen_agent_b))
										removed.trace_gases -= trace_gas
										filtered_out.trace_gases += trace_gas


					air_out1.merge(filtered_out)
					air_out2.merge(removed)
			else
				if(!OutputANet) icon_state = "filter_Oerror"
				if(!OutputBNet) icon_state = "filter_Ferror"

		examine()
			var/datum/UnifiedNetwork/Network = Networks[/obj/cabling/flexipipe]
			for(var/obj/cabling/C in Network.Cables)
				C.overlays += 'debug_update.dmi'
				spawn(10) C.overlays -= 'debug_update.dmi'
	mixer
		name = "Pipeline Combination Hub"
		icon_state = "mixer_off"
		var/node1_concentration = 0.5
		var/node2_concentration = 0.5
		var/target_pressure = 1000
		var/datum/gas_mixture
			air_in1
			air_in2
			air_out
		var/turf
			A
			B
			C
		var/on = 0
		var/id
		Process(datum/UnifiedNetworkController/FlexipipeNetworkController/Controller)
			if(!on)
				icon_state = "mixer_off"
				return 1
			else
				icon_state = "mixer_on"
			if(!A) A = get_step(src,turn(dir,180))
			if(!B) B = get_step(src,turn(dir,270))
			if(!C) C = get_step(src,dir)
			var/datum/UnifiedNetwork
				InputANet
				InputBNet
				OutputNet
			for(var/obj/cabling/flexipipe/P in A)
				if(P.Networks[P.type] && (P.Direction1 == dir || P.Direction2 == dir))
					InputANet = P.Networks[P.type]

			for(var/obj/cabling/flexipipe/P in B)
				if(P.Networks[P.type] && (P.Direction1 == turn(dir,90) || P.Direction2 == turn(dir,90)))
					InputBNet = P.Networks[P.type]
			for(var/obj/cabling/flexipipe/P in C)
				if(P.Networks[P.type] && (P.Direction1 == turn(dir,180) || P.Direction2 == turn(dir,180)))
					OutputNet = P.Networks[P.type]

			if(InputANet && InputBNet && OutputNet)
				air_in1 = InputANet.Controller:air_contents
				air_in2 = InputBNet.Controller:air_contents
				air_out = OutputNet.Controller:air_contents

				var/output_starting_pressure = air_out.return_pressure()

				if(output_starting_pressure >= target_pressure)
					//No need to mix if target is already full!
					return 1

				//Calculate necessary moles to transfer using PV=nRT

				var/pressure_delta = target_pressure - output_starting_pressure //How much pressure to add

				var/transfer_moles1 = 0 //How much is needed from pipe A
				var/transfer_moles2 = 0 //How much is needed from pipe B

				if(air_in1.temperature > 0)
					transfer_moles1 = (node1_concentration*pressure_delta)*air_out.volume/(air_in1.temperature * R_IDEAL_GAS_EQUATION)

				if(air_in2.temperature > 0)
					transfer_moles2 = (node2_concentration*pressure_delta)*air_out.volume/(air_in2.temperature * R_IDEAL_GAS_EQUATION)



				var/air_in1_moles = air_in1.total_moles()
				var/air_in2_moles = air_in2.total_moles()



				if((air_in1_moles < transfer_moles1) || (air_in2_moles < transfer_moles2))



					var/ratio = min((transfer_moles1 ? air_in1_moles/transfer_moles1 : 1e31), (transfer_moles2 ? air_in2_moles/transfer_moles2 : 1e31))

					transfer_moles1 *= ratio
					transfer_moles2 *= ratio

				//Actually transfer the gas

				if(transfer_moles1 > 0)
					var/datum/gas_mixture/removed1 = air_in1.remove(transfer_moles1)
					air_out.merge(removed1)

				if(transfer_moles2 > 0)
					var/datum/gas_mixture/removed2 = air_in2.remove(transfer_moles2)
					air_out.merge(removed2)

				return 1

	valve
		name = "Manual Valve"
		icon_state = "valve1"
		var/open = 1
		var/obj/cabling/flexipipe/F
		New()
			. = ..()
			dir = min(dir,turn(dir,180))
			if(icon_state == "valve1")
				F = new/obj/cabling/flexipipe(loc,dir,turn(dir,180))
			else
				F = locate() in loc
				if(F) del F

		attack_hand()
			Toggle()
		attack_paw()
			return attack_hand()
		attack_ai()
			return

		proc/Toggle()
			if(F)
				del F
				icon_state = "valve0"
				flick("valve10",src)
			else
				F = new/obj/cabling/flexipipe(loc,dir,turn(dir,180))
				icon_state = "valve1"
				flick("valve01",src)

	digital_valve
		name = "Digital Valve"
		icon_state = "dvalve1"
		var/open = 1
		var/obj/cabling/flexipipe/F
		New()
			. = ..()
			dir = min(dir,turn(dir,180))
			if(icon_state == "dvalve1")
				F = new/obj/cabling/flexipipe(loc,dir,turn(dir,180))
			else
				F = locate() in loc
				if(F) del F

		Process()
			if(stat & (BROKEN|NOPOWER))
				icon_state = "dvalve[F?"1":"0"]nopower"
				return 0
			use_power(5)

		attack_hand()
			Toggle()
		attack_paw()
			return attack_hand()
		attack_ai()
			return attack_hand()

		proc/Toggle()
			if(stat & (BROKEN|NOPOWER))
				return 0
			if(F)
				del F
				icon_state = "dvalve0"
				flick("dvalve10",src)
			else
				F = new/obj/cabling/flexipipe(loc,dir,turn(dir,180))
				icon_state = "hvalve1"
				flick("dvalve01",src)
	connector
		name = "Portable Atmospherics Connector"
		icon_state = "connector"
		var/obj/machinery/portable_atmospherics/connected_device
		Process(datum/UnifiedNetworkController/FlexipipeNetworkController/Controller)

			if(connected_device)
				if(!istype(connected_device,/obj/machinery/portable_atmospherics/canister))
					Controller.air_contents.share(connected_device.air_contents)

				/*var/datum/gas_mixture/combined_contents = new

				combined_contents.copy_from(Controller.air_contents)
				combined_contents.merge(connected_device.air_contents)

				var/ratio = connected_device.air_contents.volume / Controller.air_contents.volume
				connected_device.air_contents = combined_contents.remove_ratio(ratio)*/

	pump
		name = "Pipeline Outlet"
		icon_state = "pump"
		var/release_pressure = 1010.25
		Detach()
			icon_state = "pump_off"
		Process(datum/UnifiedNetworkController/FlexipipeNetworkController/FController)
			icon_state = "pump"
			var/turf/T = loc
			var/external_pressure_bound = release_pressure
			var/datum/gas_mixture/air_contents = FController:air_contents
			if(T.zone)
				var/pressure_delta = external_pressure_bound - T.zone.pressure()
				pressure_delta *= 10
					//Can not have a pressure delta that would cause environment pressure > tank pressure

				var/transfer_moles = 0
				if(air_contents.temperature > 0)
					transfer_moles = pressure_delta*T.zone.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

						//Actually transfer the gas
					var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

					if(removed) T.assume_air(removed)
			else
				var/pressure_delta = external_pressure_bound - 0
				//Can not have a pressure delta that would cause environment pressure > tank pressure

				var/transfer_moles = 0
				if(air_contents.temperature > 0)
					transfer_moles = pressure_delta*100000/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

					//Actually transfer the gas
					var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)
					if(removed) del removed
	intake
		name = "Pipeline Inlet"
		icon_state = "inlet"
		var/intake_pressure = 1010.25
		Process(datum/UnifiedNetworkController/FlexipipeNetworkController/FController)
			var/turf/T = loc
			var/datum/gas_mixture/air_contents = FController:air_contents
			if(T.zone)
				var/pressure_delta = intake_pressure - air_contents.return_pressure()
				//Can not have a pressure delta that would cause environment pressure > tank pressure
				pressure_delta *= 10

				var/transfer_moles = 0
				if(T.zone.temp > 0)
					transfer_moles = pressure_delta*air_contents.volume/(T.zone.temp * R_IDEAL_GAS_EQUATION)

					//Actually transfer the gas
					var/datum/gas_mixture/removed

					removed = T.remove_air(transfer_moles)

					if(removed) air_contents.merge(removed)
	thermal_plate
		name = "Thermal Exchange Plate"
		icon_state = "exchanger"

		Process(datum/UnifiedNetworkController/FlexipipeNetworkController/Controller)
			var/datum/gas_mixture
				environment = loc.return_air()
				air_contents = Controller:air_contents

			//Get processable air sample and thermal info from environment

			var/transfer_moles = 0.25 * environment.total_moles()
			var/datum/gas_mixture/external_removed = environment.remove(transfer_moles)

			if (!external_removed)
				return radiate(Controller)

			if (external_removed.total_moles() < 10)
				return radiate(Controller)

			//Get same info from connected gas

			var/internal_transfer_moles = 0.25 * air_contents.total_moles()
			var/datum/gas_mixture/internal_removed = air_contents.remove(internal_transfer_moles)

			if (!internal_removed)
				environment.merge(external_removed)
				return 1

			var/combined_heat_capacity = internal_removed.heat_capacity() + external_removed.heat_capacity()
			var/combined_energy = internal_removed.temperature * internal_removed.heat_capacity() + external_removed.heat_capacity() * external_removed.temperature

			if(!combined_heat_capacity) combined_heat_capacity = 1
			var/final_temperature = combined_energy / combined_heat_capacity

			external_removed.temperature = final_temperature
			environment.merge(external_removed)

			internal_removed.temperature = final_temperature
			air_contents.merge(internal_removed)

			return 1

		proc/radiate(datum/UnifiedNetworkController/FlexipipeNetworkController/Controller)

			var/datum/gas_mixture/air_contents = Controller:air_contents

			var/internal_transfer_moles = 0.25 * air_contents.total_moles()
			var/datum/gas_mixture/internal_removed = air_contents.remove(internal_transfer_moles)

			if (!internal_removed)
				return 1

			var/combined_heat_capacity = internal_removed.heat_capacity() + RADIATION_CAPACITY
			var/combined_energy = internal_removed.temperature * internal_removed.heat_capacity() + (RADIATION_CAPACITY * 6.4)

			var/final_temperature = combined_energy / combined_heat_capacity

			internal_removed.temperature = final_temperature
			air_contents.merge(internal_removed)

			return 1
	generator_input
		icon = 'heat_exchanger.dmi'
		icon_state = "intact"
		density = 1

		name = "Generator Input"
		desc = "Placeholder"

		proc
			return_exchange_air()
				var/datum/UnifiedNetwork/Network = Networks[/obj/cabling/flexipipe]
				if(!Network)
					return new/datum/gas_mixture
				return Network.Controller:air_contents
	freezer
		icon_state = "freezer"
		var/safety_off = 0
		var/on = 0
		var/maximum_temperature = T0C + 90
		var/safe_maximum_temperature = T0C + 90
		var/minimum_temperature = T0C - 200
		var/safe_minimum_temperature = T0C - 200

		var/current_temperature = T20C
		var/current_heat_capacity = 1000
		attack_ai(mob/user as mob)
			return src.attack_hand(user)

		attack_paw(mob/user as mob)
			return src.attack_hand(user)

		attack_hand(mob/user as mob)
			user.machine = src
			var/datum/UnifiedNetwork/Network = Networks[/obj/cabling/flexipipe]
			if(Network)
				var/datum/gas_mixture/air_contents = Network.Controller:air_contents
				var/temp_text = ""
				if(air_contents.temperature > (T0C - 20))
					temp_text = "<FONT color=red>[air_contents.temperature]</FONT>"
				else if(air_contents.temperature < (T0C - 20) && air_contents.temperature > (T0C - 100))
					temp_text = "<FONT color=black>[air_contents.temperature]</FONT>"
				else
					temp_text = "<FONT color=blue>[air_contents.temperature]</FONT>"

				var/dat = {"<B>Cryo gas cooling system</B><BR>
				Current status: [ on ? "<A href='?src=\ref[src];start=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];start=1'>On</A>"]<BR>
				Current gas temperature: [temp_text]<BR>
				Current air pressure: [air_contents.return_pressure()]<BR>
				Target gas temperature: [safety_off?"<A href='?src=\ref[src];temp=min'>min</A> <A href='?src=\ref[src];temp=-100'>-</A>":"min -"] <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> [current_temperature] <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A> [safety_off?"<A href='?src=\ref[src];temp=100'>+</A> <A href='?src=\ref[src];temp=max'>max</A>":"+ max"]<BR>
				[safety_off?"":"<A href='?src=\ref[src];safety-off=1'>disable safety limits</a><br>"]
				"}

				user << browse(dat, "window=freezer;size=400x500")
				onclose(user, "freezer")
			else
				usr.machine = null
				usr << "\red Error: No network connected."

		Topic(href, href_list)
			if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
				usr.machine = src
				if (href_list["start"])
					src.on = !src.on

				if(href_list["temp"])
					var/old = current_temperature
					if(href_list["temp"] == "min")
						src.current_temperature = minimum_temperature
					else if(href_list["temp"] == "max")
						src.current_temperature = maximum_temperature
					else
						var/amount = text2num(href_list["temp"])
						if(amount > 0)
							src.current_temperature = min(maximum_temperature, src.current_temperature+amount)
						else
							src.current_temperature = max(minimum_temperature, src.current_temperature+amount)
					var/change = abs(old - current_temperature)

					if(change > 10)
						safety_off = safety_off //Avoid 'if statement has no effect'. Remove once real code is added
						//Todo: A chance of something bad happening here.

					if(current_temperature < safe_minimum_temperature || current_temperature > safe_maximum_temperature)
						safety_off = safety_off //Avoid 'if statement has no effect'. Remove once real code is added
						//Todo: Here, as well

				if(href_list["safety-off"])
					var/message =	"Warning! The limits are there for a reason, and bypassing them may damage the equipment. Without them, it is possible to change the temperature too quickly, or to values outside of the safe operating range, risking equipment damage.<br><br>"
					message +=		"<A href='?src=\ref[src];safety-off-confirm=1'>Disable limits</A> (Note: requires officer ID)"
					usr << browse(message, "window=freezerlimits")

				if(href_list["safety-off-confirm"])
					if(usr.has_access(list(access_heads)))
						safety_off = 1
						minimum_temperature = safe_minimum_temperature - 50
						maximum_temperature = safe_maximum_temperature + 50
						usr << browse(null, "window=freezerlimits")
					else
						var/message =	"Warning! The limits are there for a reason, and bypassing them may damage the equipment. Without them, it is possible to change the temperature too quickly, or to values outside of the safe operating range, risking equipment damage.<br><br>"
						message +=		"<A href='?src=\ref[src];safety-off-confirm=1'>Disable limits</A> (Note: requires officer ID)<br>"
						message +=		"<FONT COLOR=red>Inadequate ID!</FONT>"
						usr << browse(message, "window=freezerlimits")


			src.updateUsrDialog()
			src.add_fingerprint(usr)
			return

		Detach()
			icon_state = "freezer_error"

		Process(datum/UnifiedNetworkController/FlexipipeNetworkController/Controller)
			if(!on)
				icon_state = "freezer"
				return 0
			icon_state = "freezer_1"
			var/datum/gas_mixture/air_contents = Controller:air_contents
			var/air_heat_capacity = air_contents.heat_capacity()
			var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
		//	var/old_temperature = air_contents.temperature

			if(combined_heat_capacity > 0)
				var/combined_energy = current_temperature*current_heat_capacity + air_heat_capacity*air_contents.temperature
				air_contents.temperature = combined_energy/combined_heat_capacity

			//todo: have current temperature affected. require power to bring down current temperature again

			updateUsrDialog()
			return 1

	meter
		name = "Pressure Meter"
		desc = "A meter for measuring the gas pressure in pipes"
		icon = 'meter.dmi'
		icon_state = "meterX"
		var/obj/machinery/atmospherics/pipe/target = null
		anchored = 1.0
		var/frequency = 0
		var/id

		Detach()
			icon_state = "meterX"

		Process(datum/UnifiedNetworkController/FlexipipeNetworkController/Controller)


			if(stat & (BROKEN|NOPOWER))
				icon_state = "meter0"
				return 0

			use_power(5)

			var/datum/gas_mixture/environment = Controller:air_contents
			if(!environment)
				icon_state = "meterX"
				return 0

			var/env_pressure = environment.return_pressure()
			if(env_pressure <= 0.15*ONE_ATMOSPHERE)
				icon_state = "meter0"
			else if(env_pressure <= 1.8*ONE_ATMOSPHERE)
				var/val = min(round(env_pressure/(ONE_ATMOSPHERE*0.3) + 0.5), 6)
				icon_state = "meter1_[val]"
			else if(env_pressure <= 30*ONE_ATMOSPHERE)
				var/val = min(round(env_pressure/(ONE_ATMOSPHERE*5)-0.35) + 1, 6)
				icon_state = "meter2_[val]"
			else if(env_pressure <= 59*ONE_ATMOSPHERE)
				var/val = min(round(env_pressure/(ONE_ATMOSPHERE*5) - 6) + 1, 6)
				icon_state = "meter3_[val]"
			else
				icon_state = "meter4"

			if(frequency)
				var/datum/radio_frequency/radio_connection = radio_controller.return_frequency("[frequency]")

				if(!radio_connection) return

				var/datum/signal/signal = new
				signal.source = src
				signal.transmission_method = 1

				signal.data["tag"] = id
				signal.data["device"] = "AM"
				signal.data["pressure"] = round(env_pressure)

				radio_connection.post_signal(src, signal)

		examine()
			set src in oview(1)

			var/t = "A gas flow meter. "
			if (src.target)
				var/datum/gas_mixture/environment = target.return_air(1)
				if(environment)
					t += text("The pressure gauge reads [] kPa", round(environment.return_pressure(), 0.1))
				else
					t += "The sensor error light is blinking."
			else
				t += "The connect error light is blinking."

			usr << t



/obj/machinery/meter/Click()

	if(stat & (NOPOWER|BROKEN))
		return

	var/t = null
	if (get_dist(usr, src) <= 3 || istype(usr, /mob/living/silicon/ai))
		if (src.target)
			var/datum/gas_mixture/environment = target.return_air(1)
			if(environment)
				t = text("<B>Pressure:</B> [] kPa", round(environment.return_pressure(), 0.1))
			else
				t = "\red <B>Results: Sensor Error!</B>"
		else
			t = "\red <B>Results: Connection Error!</B>"
	else
		usr << "\blue <B>You are too far away.</B>"

	usr << t
	return


var/PipeVolume = 25

/datum/UnifiedNetworkController/FlexipipeNetworkController
	var/datum/gas_mixture/air_contents = new
	AttachNode(var/obj/Node)
		return

	DetachNode(var/obj/machinery/atmos_new/Node)
		Node.Detach()
		return

	AddCable(var/obj/cabling/Cable)
		air_contents.volume = PipeVolume*Network.Cables.len
		return

	RemoveCable(var/obj/cabling/Cable)
		if(air_contents)
			air_contents.volume = PipeVolume*Network.Cables.len
		return

	StartSplit(var/datum/UnifiedNetwork/NewNetwork)
		return

	FinishSplit(var/datum/UnifiedNetwork/NewNetwork)
		var/proportion = NewNetwork.Cables.len / Network.Cables.len
		NewNetwork.Controller:air_contents:merge(air_contents.remove_ratio(proportion))
		air_contents.volume = PipeVolume*Network.Cables.len
		NewNetwork.Controller:air_contents:volume = PipeVolume*NewNetwork.Cables.len
		return

	CableCut(var/obj/cabling/Cable, var/mob/User)
		return

	CableBuilt(var/obj/cabling/Cable, var/mob/User)
		return

	Initialize()
		air_contents.volume = PipeVolume*Network.Cables.len
		return

	Finalize()
		return

	BeginMerge(var/datum/UnifiedNetwork/TargetNetwork, var/Slave)
		if(!Slave)
			var/datum/UnifiedNetworkController/FlexipipeNetworkController/TargetController = TargetNetwork.Controller
			air_contents.merge(TargetController.air_contents)
			air_contents.volume = PipeVolume*Network.Cables.len
		return

	FinishMerge()
		return

	DeviceUsed(var/obj/item/device/Device, var/obj/cabling/Cable, var/mob/User)
		switch(Device.type)
			if(/obj/item/device/analyzer)
				var/pressure = air_contents.return_pressure()
				var/total_moles = air_contents.total_moles()

				User << "\blue Results of analysis of pipeline:"
				if (total_moles>0)
					var/o2_concentration = air_contents.oxygen/total_moles
					var/n2_concentration = air_contents.nitrogen/total_moles
					var/co2_concentration = air_contents.carbon_dioxide/total_moles
					var/plasma_concentration = air_contents.toxins/total_moles

					var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)

					User << "\blue Volume: [air_contents.volume] L"

					User << "\blue Pressure: [round(pressure,0.1)] kPa"
					User << "\blue Nitrogen: [round(n2_concentration*100)]%"
					User << "\blue Oxygen: [round(o2_concentration*100)]%"
					User << "\blue CO2: [round(co2_concentration*100)]%"
					User << "\blue Plasma: [round(plasma_concentration*100)]%"
					if(unknown_concentration>0.01)
						User << "\red Unknown: [round(unknown_concentration*100)]%"
					User << "\blue Temperature: [round(air_contents.temperature-T0C)]&deg;C"
					//for(var/obj/cabling/C in Network.Cables)
					//	C.overlays += 'debug_update.dmi'
					//	spawn(5) C.overlays -= 'debug_update.dmi'
				else
					User << "\blue Pipeline is empty!"
		return

	CableTouched(var/obj/cabling/Cable, var/mob/User)
		return

	Process()
		for(var/obj/machinery/atmos_new/N in Network.Nodes)
			N.Process(src)
		var/count = 0
		var/skipped_conductivity = 0
		count = count
		for(var/obj/cabling/flexipipe/C in Network.Cables)
			if(CONDUCTION_SKIP)
				count++
				if(count % CONDUCTION_SKIP)
					skipped_conductivity += C.conductivity
					continue
				else
					skipped_conductivity = 0
			HeatExchange(C.loc,C.conductivity + skipped_conductivity)

	proc/HeatExchange(turf/target,thermal_conductivity)
		var/datum/gas_mixture/air = air_contents
		var/total_heat_capacity = air.heat_capacity()
		var/share_volume = PipeVolume

		var/partial_heat_capacity = total_heat_capacity*(share_volume/air.volume)

		if(istype(target, /turf/simulated))
			var/turf/simulated/modeled_location = target

			if(modeled_location.blocks_air)

				if((modeled_location.heat_capacity>0) && (partial_heat_capacity>0))
					var/delta_temperature = air.temperature - modeled_location.temperature

					var/heat = thermal_conductivity*delta_temperature* \
						(partial_heat_capacity*modeled_location.heat_capacity/(partial_heat_capacity+modeled_location.heat_capacity))

					air.temperature -= heat/total_heat_capacity
					modeled_location.temperature += heat/modeled_location.heat_capacity

			else
				var/delta_temperature = 0
				var/sharer_heat_capacity = 0

				if(modeled_location.parent)// && modeled_location.parent.group_processing)
					delta_temperature = (air.temperature - modeled_location.parent.air.temperature)
					sharer_heat_capacity = modeled_location.parent.air.heat_capacity()
				else
					delta_temperature = (air.temperature - modeled_location.air.temperature)
					sharer_heat_capacity = modeled_location.air.heat_capacity()

				var/self_temperature_delta = 0
				var/sharer_temperature_delta = 0

				if((sharer_heat_capacity>0) && (partial_heat_capacity>0))
					var/heat = thermal_conductivity*delta_temperature* \
						(partial_heat_capacity*sharer_heat_capacity/(partial_heat_capacity+sharer_heat_capacity))

					self_temperature_delta = -heat/total_heat_capacity
					sharer_temperature_delta = heat/sharer_heat_capacity
				else
					return 1

				air.temperature += self_temperature_delta

				if(modeled_location.parent)// && modeled_location.parent.group_processing)
					if((abs(sharer_temperature_delta) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) && (abs(sharer_temperature_delta) > MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND*modeled_location.parent.air.temperature))
						//modeled_location.parent.suspend_group_processing()

						modeled_location.air.temperature += sharer_temperature_delta

					else
						modeled_location.parent.air.temperature += sharer_temperature_delta/modeled_location.parent.air.group_multiplier
				else
					modeled_location.air.temperature += sharer_temperature_delta


		else
			if((target.heat_capacity>0) && (partial_heat_capacity>0))
				var/delta_temperature = air.temperature - target.temperature

				var/heat = thermal_conductivity*delta_temperature* \
					(partial_heat_capacity*target.heat_capacity/(partial_heat_capacity+target.heat_capacity))

				air.temperature -= heat/total_heat_capacity
		return

/*
	if(!Networks[/obj/cabling/flexipipe])
		NO CONNECTION
	else
		var/datum/UnifiedNetwork/GasNetwork = Networks[/obj/cabling/flexipipe]
		var/datum/UnifiedNetworkController/FlexipipeNetworkController/Controller = GasNetwork.Controller
		for(var/obj/machinery in GasNetwork.Nodes)
*/