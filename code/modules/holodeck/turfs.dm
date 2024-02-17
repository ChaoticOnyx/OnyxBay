/turf/simulated/floor/holofloor
	thermal_conductivity = 0

/turf/simulated/floor/holofloor/attackby(obj/item/W, mob/user)
	return // HOLOFLOOR DOES NOT GIVE A FUCK

/turf/simulated/floor/holofloor/set_flooring()
	return


/turf/simulated/floor/holofloor/carpet
	icon_state = "brown"
	icon = 'icons/turf/flooring/carpet.dmi'

	base_name = "brown carpet"
	base_desc = "Comfy and fancy carpeting."

	base_icon_state = "brown"
	base_icon = 'icons/turf/flooring/carpet.dmi'

	initial_flooring = /decl/flooring/carpet


/turf/simulated/floor/holofloor/tiled
	name = "floor"
	desc = "Scuffed from the passage of countless greyshirts."

	icon_state = "steel_rough"
	icon = 'icons/turf/flooring/tiles.dmi'


/turf/simulated/floor/holofloor/tiled/dark
	name = "dark floor"
	desc = "How ominous."

	icon_state = "dark_rough"


/turf/simulated/floor/holofloor/lino
	name = "linoleum"
	desc = "It's like the 2390's all over again."

	icon_state = "lino"
	icon = 'icons/turf/flooring/linoleum.dmi'


/turf/simulated/floor/holofloor/wood
	name = "wooden floor"
	desc = "Polished redwood planks."

	icon_state = "wood"
	icon = 'icons/turf/flooring/wood.dmi'


/turf/simulated/floor/holofloor/grass
	icon_state = "grass0"
	icon = 'icons/turf/flooring/grass.dmi'

	base_name = "grass"
	base_desc = "Do they smoke grass out in space, Bowie? Or do they smoke AstroTurf?"

	base_icon_state = "grass0"
	base_icon = 'icons/turf/flooring/grass.dmi'

	initial_flooring = /decl/flooring/grass


/turf/simulated/floor/holofloor/snow
	name = "snow"

	icon_state = "snow"
	icon = 'icons/turf/floors.dmi'


/turf/simulated/floor/holofloor/space
	name = "\proper space"

	icon_state = "0"
	icon = 'icons/turf/space.dmi'

/turf/simulated/floor/holofloor/space/Initialize(mapload, ...)
	. = ..()
	icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"


/turf/simulated/floor/holofloor/reinforced
	name = "reinforced floor"
	desc = "Heavily reinforced with steel plating."

	icon_state = "reinforced"
	icon = 'icons/turf/flooring/tiles.dmi'


/turf/simulated/floor/holofloor/beach
	desc = "Uncomfortably gritty for a hologram."

	icon = 'icons/misc/beach.dmi'

/turf/simulated/floor/holofloor/beach/sand
	name = "sand"

	icon_state = "desert0"

/turf/simulated/floor/holofloor/beach/coastline
	name = "coastline"

	icon_state = "beach"

/turf/simulated/floor/holofloor/beach/water
	name = "water"

	icon_state = "seashallow"


/turf/simulated/floor/holofloor/desert
	name = "desert sand"
	desc = "Uncomfortably gritty for a hologram."

	icon_state = "sand0"
	icon = 'icons/turf/flooring/sand.dmi'

/turf/simulated/floor/holofloor/desert/Initialize(mapload, ...)
	. = ..()
	if(prob(10))
		AddOverlays("asteroid[rand(0, 9)]")
