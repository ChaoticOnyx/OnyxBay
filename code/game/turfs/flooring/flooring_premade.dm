// simulated/floor is currently plating by default, but there really should be an explicit plating type.
/turf/simulated/floor/plating
	name = "plating"
	icon = 'icons/turf/flooring/plating.dmi'
	icon_state = "plating"
	plane = PLATING_PLANE


//GRID FLOORING

/turf/simulated/floor/grid
	name = "mainframe floor"
	icon = 'icons/turf/flooring/circuit.dmi'
	icon_state = "rcircuit"
	initial_flooring = /decl/flooring/reinforced/circuit/red
	light_range = 2
	light_power = 2
	light_color = COLOR_RED

/turf/simulated/floor/grid/bluegrid
	name = "mainframe floor"
	icon = 'icons/turf/flooring/circuit.dmi'
	icon_state = "bcircuit"
	initial_flooring = /decl/flooring/reinforced/circuit
	light_range = 2
	light_power = 3
	light_color = COLOR_BLUE

/turf/simulated/floor/grid/bluegrid/airless
	initial_gas = null

/turf/simulated/floor/grid/greengrid
	name = "mainframe floor"
	icon = 'icons/turf/flooring/circuit.dmi'
	icon_state = "gcircuit"
	initial_flooring = /decl/flooring/reinforced/circuit/green
	light_range = 2
	light_power = 3
	light_color = COLOR_GREEN

/turf/simulated/floor/grid/greengrid/airless
	initial_gas = null


//REINFORCED FLOORING

/turf/simulated/floor/reinforced
	name = "reinforced floor"
	icon = 'icons/turf/flooring/tiles.dmi'
	icon_state = "reinforced"
	initial_flooring = /decl/flooring/reinforced

/turf/simulated/floor/reinforced/airless
	initial_gas = null

/turf/simulated/floor/reinforced/airmix
	initial_gas = list("oxygen" = MOLES_O2ATMOS, "nitrogen" = MOLES_N2ATMOS)

/turf/simulated/floor/reinforced/nitrogen
	initial_gas = list("nitrogen" = ATMOSTANK_NITROGEN)

/turf/simulated/floor/reinforced/hydrogen
	initial_gas = list("hydrogen" = ATMOSTANK_HYDROGEN)

/turf/simulated/floor/reinforced/oxygen
	initial_gas = list("oxygen" = ATMOSTANK_OXYGEN)

/turf/simulated/floor/reinforced/phoron
	initial_gas = list("phoron" = ATMOSTANK_PHORON)

/turf/simulated/floor/reinforced/nitrogen/engine
	name = "engine floor"
	initial_gas = list("nitrogen" = MOLES_N2STANDARD)

/turf/simulated/floor/reinforced/phoron/fuel
	initial_gas = list("phoron" = ATMOSTANK_PHORON_FUEL)

/turf/simulated/floor/reinforced/hydrogen
	initial_gas = list("hydrogen" = ATMOSTANK_HYDROGEN)

/turf/simulated/floor/reinforced/hydrogen/fuel
	initial_gas = list("hydrogen" = ATMOSTANK_HYDROGEN_FUEL)

/turf/simulated/floor/reinforced/carbon_dioxide
	initial_gas = list("carbon_dioxide" = ATMOSTANK_CO2)

/turf/simulated/floor/reinforced/n20
	initial_gas = list("sleeping_agent" = ATMOSTANK_NITROUSOXIDE)


//STATION FLOORING

/turf/simulated/floor/tiled
	name = "steel floor"
	icon = 'icons/turf/flooring/tiles.dmi'
	icon_state = "steel"
	initial_flooring = /decl/flooring/tiling

/turf/simulated/floor/tiled/dark
	name = "dark floor"
	icon_state = "dark"
	initial_flooring = /decl/flooring/tiling/dark

/turf/simulated/floor/tiled/dark/airless
	initial_gas = null

/turf/simulated/floor/tiled/white
	name = "white floor"
	icon_state = "white"
	initial_flooring = /decl/flooring/tiling/white

/turf/simulated/floor/tiled/brown
	name = "brown tile floor"
	icon_state = "brown"
	initial_flooring = /decl/flooring/tiling/brown

/turf/simulated/floor/tiled/freezer
	name = "tiles"
	icon_state = "freezer"
	initial_flooring = /decl/flooring/tiling/freezer

/turf/simulated/floor/tiled/dirty
	name = "dirty floor"
	icon_state = "steel_dirty"
	initial_flooring = /decl/flooring/tiling/dirty


//ATMOS PREMADES

/turf/simulated/floor/reinforced/airless
	name = "vacuum floor"
	initial_gas = null
	temperature = TCMB

/turf/simulated/floor/plating/airless
	name = "airless plating"
	initial_gas = null
	temperature = TCMB

/turf/simulated/floor/tiled/airless
	name = "airless floor"
	initial_gas = null
	temperature = TCMB

/turf/simulated/floor/grid/bluegrid/airless
	name = "airless floor"
	initial_gas = null
	temperature = TCMB

/turf/simulated/floor/grid/greengrid/airless
	name = "airless floor"
	initial_gas = null
	temperature = TCMB

/turf/simulated/floor/grid/greengrid/nitrogen
	initial_gas = list("nitrogen" = MOLES_N2STANDARD)

/turf/simulated/floor/tiled/white/airless
	name = "airless floor"
	initial_gas = null
	temperature = TCMB


//INTERIOR FLOORING

/turf/simulated/floor/trim
	name = "interior flooring"
	icon = 'icons/turf/flooring/linoleum.dmi'
	icon_state = "lino"
	initial_flooring = null

/turf/simulated/floor/trim/lino
	name = "lino"
	icon = 'icons/turf/flooring/linoleum.dmi'
	icon_state = "lino"
	initial_flooring = /decl/flooring/linoleum


/turf/simulated/floor/trim/wood
	name = "wooden floor"
	icon = 'icons/turf/flooring/wood.dmi'
	icon_state = "wood"
	initial_flooring = /decl/flooring/wood

/turf/simulated/floor/trim/wood/darkwood
	name = "wooden floor"
	icon_state = "wood_new_dark"
	initial_flooring = /decl/flooring/wood/darkwood

/turf/simulated/floor/trim/wood/broken0
	name = "wooden floor"
	icon_state = "wood_broken0"
	initial_flooring = /decl/flooring/wood/broken0

/turf/simulated/floor/trim/wood/broken1
	name = "wooden floor"
	icon_state = "wood_broken1"
	initial_flooring = /decl/flooring/wood/broken1

/turf/simulated/floor/trim/wood/broken2
	name = "wooden floor"
	icon_state = "wood_broken2"
	initial_flooring = /decl/flooring/wood/broken2

/turf/simulated/floor/trim/wood/broken3
	name = "wooden floor"
	icon_state = "wood_broken3"
	initial_flooring = /decl/flooring/wood/broken3

/turf/simulated/floor/trim/wood/broken4
	name = "wooden floor"
	icon_state = "wood_broken4"
	initial_flooring = /decl/flooring/wood/broken4

/turf/simulated/floor/trim/wood/broken5
	name = "wooden floor"
	icon_state = "wood_broken5"
	initial_flooring = /decl/flooring/wood/broken5

/turf/simulated/floor/trim/wood/broken6
	name = "wooden floor"
	icon_state = "wood_broken6"
	initial_flooring = /decl/flooring/wood/broken6


/turf/simulated/floor/trim/carpet
	name = "brown carpet"
	icon = 'icons/turf/flooring/carpet.dmi'
	icon_state = "brown"
	initial_flooring = /decl/flooring/carpet

/turf/simulated/floor/trim/carpet/blue
	name = "blue carpet"
	icon_state = "blue1"
	initial_flooring = /decl/flooring/carpet/blue

/turf/simulated/floor/trim/carpet/blue2
	name = "pale blue carpet"
	icon_state = "blue2"
	initial_flooring = /decl/flooring/carpet/blue2

/turf/simulated/floor/trim/carpet/oldred
	name = "red carpet"
	icon = 'icons/turf/flooring/carpet.dmi'
	icon_state = "oldred"
	initial_flooring = /decl/flooring/carpet/oldred

/turf/simulated/floor/trim/carpet/purple
	name = "purple carpet"
	icon_state = "purple"
	initial_flooring = /decl/flooring/carpet/purple

/turf/simulated/floor/trim/carpet/orange
	name = "orange carpet"
	icon_state = "orange"
	initial_flooring = /decl/flooring/carpet/orange

/turf/simulated/floor/trim/carpet/green
	name = "green carpet"
	icon_state = "green"
	initial_flooring = /decl/flooring/carpet/green

/turf/simulated/floor/trim/carpet/red
	name = "red carpet"
	icon_state = "red"
	initial_flooring = /decl/flooring/carpet/red


//NATURAL FLOORING

/turf/simulated/floor/natural
	name = "natural flooring"
	icon = 'icons/turf/flooring/grass.dmi'
	icon_state = "grass0"
	initial_flooring = null

/turf/simulated/floor/natural/grass
	name = "grass patch"
	icon = 'icons/turf/flooring/grass.dmi'
	icon_state = "grass0"
	initial_flooring = /decl/flooring/grass

/turf/simulated/floor/natural/ice
	name = "ice"
	icon = 'icons/turf/snow.dmi'
	icon_state = "ice"

/turf/simulated/floor/natural/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/turf/simulated/floor/natural/lava
	name = "lava"
	icon = 'icons/turf/flooring/lava.dmi'
	icon_state = "lava"

/turf/simulated/floor/natural/snow/New()
	icon_state = pick("snow[rand(1,12)]","snow0")
	..()

/turf/simulated/floor/natural/beach
	name = "beach"
	icon = 'icons/misc/beach.dmi'

/turf/simulated/floor/natural/beach/sand
	name = "sand"
	icon_state = "sand"

/turf/simulated/floor/natural/beach/sand/desert
	icon_state = "desert"
	has_resources = 1

/turf/simulated/floor/natural/beach/sand/desert/New()
	icon_state = "desert[rand(0,5)]"
	..()

/turf/simulated/floor/natural/beach/coastline
	name = "coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/simulated/floor/natural/beach/water
	name = "water"
	icon_state = "water"

/turf/simulated/floor/natural/beach/water/update_dirt()
	return	// Water doesn't become dirty

/turf/simulated/floor/natural/beach/water/ocean
	icon_state = "seadeep"

/turf/simulated/floor/natural/beach/water/New()
	..()
	overlays += image("icon"='icons/misc/beach.dmi',"icon_state"="water5","layer"=MOB_LAYER+0.1)


//MISCELLANEOUS FLOORING

/turf/simulated/floor/misc
	name = "miscellaneous flooring"
	icon = 'icons/turf/flooring/plating.dmi'
	icon_state = "plating"
	initial_flooring = null

/turf/simulated/floor/misc/diona
	name = "biomass"
	icon = 'icons/turf/floors.dmi'
	initial_flooring = /decl/flooring/diona

/turf/simulated/floor/misc/cult
	name = "engraved floor"
	icon = 'icons/turf/flooring/cult.dmi'
	icon_state = "cult"
	initial_flooring = /decl/flooring/reinforced/cult

/turf/simulated/floor/misc/cult/cultify()
	return