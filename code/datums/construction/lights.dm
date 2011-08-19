
/datum/construction_UI/light_fixture
	states = list("tube-empty&dir=1", "tube-empty&dir=2", "tube-empty&dir=4", "tube-empty&dir=8")

	icon = 'lighting.dmi'
	default_state = "tube-empty"

	var/obj/item/weapon/light_fixture/parts
	var/turf/initial_loc
	var/light_type = /obj/machinery/light {status = 1 /*LIGHT_EMPTY*/}


/datum/construction_UI/light_fixture/small
	states = list("bulb-empty&dir=1", "bulb-empty&dir=2", "bulb-empty&dir=4", "bulb-empty&dir=8")

	default_state = "bulb-empty"
	light_type = /obj/machinery/light/small {status = 1 /*LIGHT_EMPTY*/}



/datum/construction_UI/light_fixture/New(atom/loc, mob/user, obj/item/weapon/light_fixture/parts)
	src.parts = parts
	initial_loc = user.loc
	..()

/datum/construction_UI/light_fixture/Topic(href, href_list[])
	if(!user || !initial_loc || !parts || user.loc != initial_loc)
		del(src)
	else
		return ..()

/datum/construction_UI/light_fixture/build(state, dir)
	var/obj/light = new light_type(loc)
	light.dir = dir
	del(parts)



/obj/item/weapon/light_fixture
	icon = 'lighting.dmi'
	icon_state = "tube-empty"
	pixel_y = 16
	name = "spare light fixture"

/obj/item/weapon/light_fixture/small
	icon = 'lighting.dmi'
	icon_state = "bulb-empty"

/obj/item/weapon/light_fixture/proc/build_light(mob/user, turf/location)
	spawn()
		if(type == /obj/item/weapon/light_fixture/small)
			new /datum/construction_UI/light_fixture/small(location, user, src)
		else
			new /datum/construction_UI/light_fixture(location, user, src)