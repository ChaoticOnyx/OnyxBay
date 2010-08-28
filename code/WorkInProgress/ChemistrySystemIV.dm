var/list/reactions = list()

var/list/symbol_table = list()

proc/initialize_csIV()

	for(var/CT in typesof(/datum/chemical) - /datum/chemical)

		var/datum/chemical/C = new CT()

		symbol_table += C.symbol
		symbol_table[C.symbol] = C.type

	for(var/RT in typesof(/datum/reaction) - /datum/reaction)

		var/datum/reaction/R = new RT()

		parse_reaction(R)

		reactions += R


datum
	chemical
		var
			name = "Water"
			symbol = "H2O"

			density_solid = 1 //grams/milliliter
			density_liquid = 1
			density_gas = 1

			current_density = 1

			state = SOLID

			molar_mass = 10 //grams/mole

			tmp
				moles = 1 //mole
				volume = 10 //milliliter
				mass = 10 //gram
				//temperature = T20C
				//pressure = 101.35 //kPa

			melting_point = T0C
			boiling_point = T0C + 100

		New(start_moles)
			moles = start_moles
			mass = moles * molar_mass
			volume = current_density*mass
			spawn(1)
				for(var/datum/chemical_holder/H)
					if(src in H.chemicals)
						react_chemicals(H)

		proc
			add_moles(n)
				if(n < 0 && moles < abs(n))
					. = moles
					del src
				else
					moles += n
					moles = QUANTIZE(moles)
					mass = moles * molar_mass
					mass = QUANTIZE(mass)
					volume = current_density*mass
					volume = QUANTIZE(volume)
					. = abs(n)

			subtract_moles(n)
				return add_moles(-n)

	chemical_holder
		var
			pressure = 101.35 //kPa
			temperature = T20C
			volume = 500 //ml

			list/chemicals = list()
		proc
			increase_temperature(n)
				if(n < 0 && (temperature - 2.7) < n)
					. = temperature - 2.7
					temperature = 2.7
					return .
				else
					temperature += n
					temperature = QUANTIZE(temperature)
					. = abs(n)

	reaction
		var
			equation = "2H + O -> H2O"
			rate = 100 //In thousandths of a mole (of chemical with no coefficent) produced per tick.

			heat_required = 0
			heat_produced = 2 //Degrees C per mole produced.

			pressure_required = 0

			//Stuff done at initialization for speed reasons, no need to mess with these.

			list/chemicals_required
			list/chemicals_produced


proc/parse_reaction(datum/reaction/R)

	R.chemicals_required = list()
	R.chemicals_produced = list()

	if(!findtext(R.equation," -> "))
		world.log << "Error: Reaction [R.equation] missing -> sign."
		return


	var
		equation_divided = dd_text2list(R.equation," -> ")
		reactants_unseparated = equation_divided[1]
		products_unseparated = equation_divided[2]

		reactants_separated = dd_text2list(reactants_unseparated," + ")
		products_separated = dd_text2list(products_unseparated," + ")


	for(var/symbol in reactants_separated)

		var/coefficient = text2num(copytext(symbol,1,2))

		if(!coefficient)
			coefficient = 1
		else
			symbol = copytext(symbol,2)

		if(!(symbol in symbol_table))
			world.log << "Error : [R.equation] : Symbol [symbol] is not used by any defined chemical."
			return

		var/reactant_type = symbol_table[symbol]

		R.chemicals_required += reactant_type
		R.chemicals_required[reactant_type] = coefficient


	for(var/symbol in products_separated)

		var/coefficient = text2num(copytext(symbol,1,2))

		if(!coefficient)
			coefficient = 1
		else
			symbol = copytext(symbol,2)

		if(!(symbol in symbol_table))
			world.log << "Error : [R.equation] : Symbol [symbol] is not used by any defined chemical."
			return

		var/reactant_type = symbol_table[symbol]

		R.chemicals_produced += reactant_type
		R.chemicals_produced[reactant_type] = coefficient




proc/react_chemicals(datum/chemical_holder/H)
	for(var/datum/reaction/R in reactions)
		var/list/requirements = R.chemicals_required.Copy()

		for(var/datum/chemical/C in H.chemicals)
			if(C.type in requirements)
				if(C.moles > 0.001*requirements[C.type])
					requirements -= C.type

		if(!requirements.len && H.temperature > R.heat_required && H.pressure > R.pressure_required)
			//Met all the requirements for this reaction to take place.
			spawn()
				var/reaction_timer = 0
				reaction:
					while(1)

						if(!(reaction_timer % R.rate)) sleep(1)
						reaction_timer++

						for(var/chem_type in R.chemicals_required)
							var/datum/chemical/C = locate(chem_type) in H.chemicals
							if(C)
								var/sub_amt = 0.001*R.chemicals_required[C.type]
								if(C.subtract_moles(sub_amt) < sub_amt)
									del C
									break reaction
							else
								break reaction //No more reactant.

						for(var/chem_type in R.chemicals_produced)
							var/datum/chemical/C = locate(chem_type) in H.chemicals
							if(C)
								C.add_moles(0.001*R.chemicals_produced[chem_type])
							else
								C = new chem_type(0.001*R.chemicals_produced[chem_type])
								H.chemicals += C

						H.increase_temperature(0.001*R.heat_produced)

				for(var/datum/chemical/C in H.chemicals)
					if(C.moles <= 0) del C