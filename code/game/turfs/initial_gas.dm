
/decl/initial_gas_mix
	var/list/gases // Initial air contents (in moles)

/decl/initial_gas_mix/empty
	gases = list()

/decl/initial_gas_mix/air
	gases = list("oxygen" = MOLES_O2_STANDARD, "nitrogen" = MOLES_N2_STANDARD)

/decl/initial_gas_mix/air/high_pressure
	gases = list("oxygen" = MOLES_O2_ATMOS, "nitrogen" = MOLES_N2_ATMOS)

/decl/initial_gas_mix/oxygen
	gases = list("oxygen" = MOLES_CELL_STANDARD)

/decl/initial_gas_mix/oxygen/high_pressure
	gases = list("oxygen" = ATMOSTANK_OXYGEN)

/decl/initial_gas_mix/nitrogen
	gases = list("nitrogen" = MOLES_CELL_STANDARD)

/decl/initial_gas_mix/nitrogen/high_pressure
	gases = list("nitrogen" = ATMOSTANK_NITROGEN)

/decl/initial_gas_mix/co2
	gases = list("carbon_dioxide" = MOLES_CELL_STANDARD)

/decl/initial_gas_mix/co2/high_pressure
	gases = list("carbon_dioxide" = ATMOSTANK_CO2)

/decl/initial_gas_mix/hydrogen
	gases = list("hydrogen" = MOLES_CELL_STANDARD)

/decl/initial_gas_mix/hydrogen/high_pressure
	gases = list("hydrogen" = ATMOSTANK_HYDROGEN)

/decl/initial_gas_mix/hydrogen/fuel
	gases = list("hydrogen" = ATMOSTANK_HYDROGEN_FUEL)

/decl/initial_gas_mix/plasma
	gases = list("plasma" = MOLES_CELL_STANDARD)

/decl/initial_gas_mix/plasma/high_pressure
	gases = list("plasma" = ATMOSTANK_PLASMA)

/decl/initial_gas_mix/plasma/fuel
	gases = list("plasma" = ATMOSTANK_PLASMA_FUEL)

/decl/initial_gas_mix/n2o
	gases = list("sleeping_agent" = MOLES_CELL_STANDARD)

/decl/initial_gas_mix/n2o/high_pressure
	gases = list("sleeping_agent" = ATMOSTANK_NITROUSOXIDE)

/decl/initial_gas_mix/air/asteroid
	gases = list("oxygen" = 1.05 * MOLES_O2_STANDARD, "nitrogen" = 1.05 * MOLES_N2_STANDARD, "carbon_dioxide" = MOLES_CELL_STANDARD * 0.1)
