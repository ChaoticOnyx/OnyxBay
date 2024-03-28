/datum/reagent
	///Whether it will evaporate if left untouched on a liquids simulated puddle
	var/evaporates = FALSE

	///How much fire power does the liquid have, for burning on simulated liquids. Not enough fire power/unit of entire mixture may result in no fire
	var/liquid_fire_power = 0

	///How fast does the liquid burn on simulated turfs, if it does
	var/liquid_fire_burnrate = 0.1

	///Whether a fire from this requires oxygen in the atmosphere
	var/fire_needs_oxygen = TRUE

/*
*	ALCOHOL REAGENTS
*/
/datum/reagent/ethanol
	liquid_fire_power = 10
	liquid_fire_burnrate = 0.1

// 0 fire power
/datum/reagent/ethanol/beer/light
	liquid_fire_power = 0

/datum/reagent/ethanol/threemileisland
	liquid_fire_power = 0

/datum/reagent/ethanol/grog
	liquid_fire_power = 0

/datum/reagent/ethanol/fetching_fizz
	liquid_fire_power = 0

/datum/reagent/ethanol/sugar_rush
	liquid_fire_power = 0

/datum/reagent/ethanol/crevice_spike
	liquid_fire_power = 0

/datum/reagent/ethanol/fanciulli
	liquid_fire_power = 0

// 2 fire power
/datum/reagent/ethanol/beer
	liquid_fire_power = 2

/datum/reagent/ethanol/wine
	liquid_fire_power = 2

/datum/reagent/ethanol/lizardwine
	liquid_fire_power = 2

/datum/reagent/ethanol/amaretto
	liquid_fire_power = 2

/datum/reagent/ethanol/goldschlager
	liquid_fire_power = 2

/datum/reagent/ethanol/gintonic
	liquid_fire_power = 2

/datum/reagent/ethanol/iced_beer
	liquid_fire_power = 2

/datum/reagent/ethanol/irishcarbomb
	liquid_fire_power = 2

/datum/reagent/ethanol/hcider
	liquid_fire_power = 2

/datum/reagent/ethanol/narsour
	liquid_fire_power = 2

/datum/reagent/ethanol/peppermint_patty
	liquid_fire_power = 2

/datum/reagent/ethanol/blank_paper
	liquid_fire_power = 2

/datum/reagent/ethanol/applejack
	liquid_fire_power = 2

/datum/reagent/ethanol/jack_rose
	liquid_fire_power = 2

/datum/reagent/ethanol/old_timer
	liquid_fire_power = 2

/datum/reagent/ethanol/duplex
	liquid_fire_power = 2

/datum/reagent/ethanol/painkiller
	liquid_fire_power = 2

// 3 fire power
/datum/reagent/ethanol/longislandicedtea
	liquid_fire_power = 3

/datum/reagent/ethanol/irishcoffee
	liquid_fire_power = 3

/datum/reagent/ethanol/margarita
	liquid_fire_power = 3

/datum/reagent/ethanol/manhattan
	liquid_fire_power = 3

/datum/reagent/ethanol/snowwhite
	liquid_fire_power = 3

/datum/reagent/ethanol/bahama_mama
	liquid_fire_power = 3

/datum/reagent/ethanol/singulo
	liquid_fire_power = 3

/datum/reagent/ethanol/red_mead
	liquid_fire_power = 3

/datum/reagent/ethanol/mead
	liquid_fire_power = 3

/datum/reagent/ethanol/aloe
	liquid_fire_power = 3

/datum/reagent/ethanol/andalusia
	liquid_fire_power = 3

/datum/reagent/ethanol/alliescocktail
	liquid_fire_power = 3

/datum/reagent/ethanol/amasec
	liquid_fire_power = 3

/datum/reagent/ethanol/erikasurprise
	liquid_fire_power = 3

/datum/reagent/ethanol/whiskey_sour
	liquid_fire_power = 3

/datum/reagent/ethanol/triple_sec
	liquid_fire_power = 3

/datum/reagent/ethanol/creme_de_menthe
	liquid_fire_power = 3

/datum/reagent/ethanol/creme_de_cacao
	liquid_fire_power = 3

/datum/reagent/ethanol/creme_de_coconut
	liquid_fire_power = 3

/datum/reagent/ethanol/quadruple_sec
	liquid_fire_power = 3

/datum/reagent/ethanol/grasshopper
	liquid_fire_power = 3

/datum/reagent/ethanol/stinger
	liquid_fire_power = 3

/datum/reagent/ethanol/bastion_bourbon
	liquid_fire_power = 3

/datum/reagent/ethanol/squirt_cider
	liquid_fire_power = 3

/datum/reagent/ethanol/amaretto_alexander
	liquid_fire_power = 3

/datum/reagent/ethanol/sidecar
	liquid_fire_power = 3

/datum/reagent/ethanol/mojito
	liquid_fire_power = 3

/datum/reagent/ethanol/moscow_mule
	liquid_fire_power = 3

/datum/reagent/ethanol/fruit_wine
	liquid_fire_power = 3

/datum/reagent/ethanol/champagne
	liquid_fire_power = 3

/datum/reagent/ethanol/pina_colada
	liquid_fire_power = 3

/datum/reagent/ethanol/ginger_amaretto
	liquid_fire_power = 3

// 4 fire power
/datum/reagent/ethanol/rum_coke
	liquid_fire_power = 4

/datum/reagent/ethanol/booger
	liquid_fire_power = 4

/datum/reagent/ethanol/tequila_sunrise
	liquid_fire_power = 4

/*
*	PYROTECHNIC REAGENTS
*/
/datum/reagent/thermite
	liquid_fire_power = 20
	liquid_fire_burnrate = 0.3

/*
*	OTHER
*/

/datum/reagent/fuel
	liquid_fire_power = 10
	liquid_fire_burnrate = 0.2

/datum/reagent/plasma
	liquid_fire_power = 15
	liquid_fire_burnrate = 0.2
