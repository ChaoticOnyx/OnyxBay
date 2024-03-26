/datum/deity_power/structure/thalamus/trap
	name = "Trap"
	desc = "An upgraded tendril with a large boney spike at the end"
	power_path = /obj/structure/deity/thalamus/trap
	resource_cost = list(
		/datum/deity_resource/thalamus/nutrients = 10
	)

/obj/structure/deity/thalamus/trap
	name = "trap"
	desc = "a pit filled with teeth, capable of biting at those who step on it."
	icon_state = "trap"
	var/damage = 14

/obj/structure/deity/thalamus/trap/Crossed(atom/movable/O)
	if(is_valid_target(O))
		bite(O)

/obj/structure/deity/thalamus/trap/proc/is_valid_target(mob/living/victim)
	if(!istype(victim))
		return FALSE

	return TRUE

/obj/structure/deity/thalamus/trap/proc/bite(mob/living/victim)
	if(!Adjacent(victim)) // Smth went wrong, our target is not on the tile anymore
		return
