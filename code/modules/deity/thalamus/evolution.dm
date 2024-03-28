/datum/evolution_category/thalamus/defense
	name = "Defense"
	items = list(
		/datum/evolution_package/thalamus/basic_defense,
		/datum/evolution_package/thalamus/enhanced_tendrils,
		/datum/evolution_package/thalamus/enhanced_turrets
	)

/datum/evolution_package/thalamus/basic_defense
	name = "Basic Defense"
	tier = DEITY_ETIER_1
	unlocks = list(
		/datum/deity_power/structure/thalamus/tendril,
		/datum/deity_power/structure/thalamus/trap,
		/obj/machinery/turret/thalamus
	)

/datum/evolution_package/thalamus/enhanced_tendrils
	name = "Enhanced tendrils"
	tier = DEITY_ETIER_2
	unlocks = list(
		/datum/deity_power/structure/thalamus/tendril_enhanced,
	)

/datum/evolution_package/thalamus/enhanced_turrets
	name = "Enhanced tendrils"
	tier = DEITY_ETIER_2
	unlocks = list(
		/obj/machinery/turret/thalamus/enhanced,
	)

/datum/evolution_category/thalamus/conversion
	name = "Symbiotic Evolution"
	items = list(
		/datum/evolution_package/thalamus/convert,
		/datum/evolution_package/thalamus/upgrade_resilience,
		/datum/evolution_package/thalamus/upgrade_speed,
		/datum/evolution_package/thalamus/chogall
	)

/datum/evolution_package/thalamus/convert
	name = "Basic Convert"
	desc = "Convert humans to zombies xd lmao"
	tier = DEITY_ETIER_1
	unlocks = list(
		/datum/deity_power/structure/thalamus/converter
	)

/datum/evolution_package/thalamus/upgrade_resilience
	name = "Resilience"
	desc = "Xddd make ur humans more robust"
	tier = DEITY_ETIER_2
	unlocks = list(
		/datum/deity_power/structure/thalamus/converter
	)

/datum/evolution_package/thalamus/upgrade_speed
	name = "Basic Convert"
	desc = "Xddd make ur humans go fast brrr"
	tier = DEITY_ETIER_2
	unlocks = list(
		/datum/deity_power/structure/thalamus/converter
	)

/datum/evolution_package/thalamus/chogall
	name = "Chogall"
	desc = "Chogall"
	tier = DEITY_ETIER_3
	unlocks = list(
		/datum/deity_power/structure/thalamus/converter
	)
