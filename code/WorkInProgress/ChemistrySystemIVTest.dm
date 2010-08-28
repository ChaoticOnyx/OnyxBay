datum
	chemical
		hydrogen
			name = "Hydrogen"
			symbol = "H"

			density_solid = 1 //grams/milliliter
			density_liquid = 0.1
			density_gas = 0.001

			current_density = 0.01

			state = GAS

			molar_mass = 1 //grams/mole

			melting_point = T0C - 500
			boiling_point = T0C - 200

		oxygen //Yeah, oxygen's diatomic but whatever, it's a test setup.
			name = "Oxygen"
			symbol = "O"

			density_solid = 3.5 //grams/milliliter
			density_liquid = 0.7
			density_gas = 0.08

			current_density = 0.08

			state = GAS

			molar_mass = 1 //grams/mole

			melting_point = T0C - 500
			boiling_point = T0C - 200

		water
			name = "Water"
			symbol = "H2O"

			density_solid = 1 //grams/milliliter
			density_liquid = 1
			density_gas = 1

			current_density = 1

			state = SOLID

			molar_mass = 3 //grams/mole

			melting_point = T0C
			boiling_point = T0C + 100

		agent_orange
			name = "Agent Orange"
			symbol = "Or"

			density_solid = 1 //grams/milliliter
			density_liquid = 1
			density_gas = 1

			current_density = 1

			state = SOLID

			molar_mass = 1 //grams/mole

			melting_point = T0C
			boiling_point = T0C + 100

		agent_orange_compound
			name = "Orange Compound"
			symbol = "H2Or"

			density_solid = 1 //grams/milliliter
			density_liquid = 1
			density_gas = 1

			current_density = 1

			state = SOLID

			molar_mass = 3 //grams/mole

			melting_point = T0C
			boiling_point = T0C + 100

	reaction
		water_reaction
			equation = "2H + O -> H2O"
			rate = 200

			heat_required = T0C
			heat_produced = 0

			pressure_required = 85
		agent_orange
			equation = "H2O + Or -> H2Or + O"
			rate = 50

			heat_produced = 5

mob
	var/datum/chemical_holder/my_holder
	verb/TestReaction()
		initialize_csIV()
		my_holder = new()
		my_holder.chemicals += new/datum/chemical/hydrogen(20)
		my_holder.chemicals += new/datum/chemical/oxygen(10)
		src << "Reaction started."
		//react_chemicals(my_holder)
	//	src << "Reaction finished."
		my_holder.chemicals += new/datum/chemical/agent_orange(10)
		src << "New reaction started."
		//react_chemicals(my_holder)
	//	src << "Finished."
	Stat()
		. = ..()
		statpanel("Chemistry Test")
		if(my_holder)
			stat("-Chemicals-")
			for(var/datum/chemical/C in my_holder.chemicals)
				stat("[C.name]")
				stat("Moles: [C.moles]")
			statpanel("Chemistry Test","Temp: ",my_holder.temperature)