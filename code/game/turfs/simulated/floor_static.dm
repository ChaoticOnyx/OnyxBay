// This type of flooring cannot be altered short of being destroyed and rebuilt.
// Use this to bypass the flooring system entirely ie. event areas, holodeck, etc.

/turf/simulated/floor/misc/fixed
	name = "floor"
	icon = 'icons/turf/flooring/tiles.dmi'
	icon_state = "steel"
	initial_flooring = null

/turf/simulated/floor/misc/fixed/attackby(obj/item/C, mob/user)
	if(istype(C, /obj/item/stack) && !isCoil(C))
		return
	return ..()

/turf/simulated/floor/misc/fixed/update_icon()
	return

/turf/simulated/floor/misc/fixed/is_plating()
	return 0

/turf/simulated/floor/misc/fixed/set_flooring()
	return

/turf/simulated/floor/misc/fixed/alium
	name = "alien plating"
	desc = "This obviously wasn't made for your feet."
	icon = 'icons/turf/flooring/alium.dmi'
	icon_state = "jaggy"

/turf/simulated/floor/misc/fixed/vox
	name = "alien plating"
	desc = "This obviously wasn't made for your feet."
	icon = 'icons/turf/flooring/alium.dmi'
	icon_state = "voxbase"
	initial_gas = list("nitrogen" = MOLES_N2STANDARD * 1.2)

/turf/simulated/floor/misc/fixed/vox/vox2
	name = "alien plating"
	desc = "This obviously wasn't made for your feet."
	icon = 'icons/turf/flooring/alium.dmi'
	icon_state = "voxbase2"

/turf/simulated/floor/misc/fixed/vox/vox3
	name = "alien plating"
	desc = "This obviously wasn't made for your feet."
	icon = 'icons/turf/flooring/alium.dmi'
	icon_state = "voxplating1"

/turf/simulated/floor/misc/fixed/vox/vox4
	name = "alien plating"
	desc = "This obviously wasn't made for your feet."
	icon = 'icons/turf/flooring/alium.dmi'
	icon_state = "voxplating2"

/turf/simulated/floor/misc/fixed/alium/attackby(obj/item/C, mob/user)
	if(isCrowbar(C))
		to_chat(user, "<span class='notice'>There aren't any openings big enough to pry it away...</span>")
		return
	return ..()

/turf/simulated/floor/misc/fixed/alium/New()
	..()
	var/material/A = get_material_by_name(MATERIAL_ALIUMIUM)
	if(!A)
		return
	color = A.icon_colour
	icon_state = "[A.icon_base][(x*y) % 7]"

/turf/simulated/floor/misc/fixed/alium/airless
	initial_gas = null
	temperature = TCMB

/turf/simulated/floor/misc/fixed/alium/ex_act(severity)
	var/material/A = get_material_by_name(MATERIAL_ALIUMIUM)
	if(prob(A.explosion_resistance))
		return
	if(severity == 1)
		ChangeTurf(get_base_turf_by_area(src))
