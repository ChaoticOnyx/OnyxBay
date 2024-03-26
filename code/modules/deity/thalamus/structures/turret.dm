/obj/machinery/turret/thalamus
	idle_power_usage = 0
	active_power_usage = 0
	traverse = 120
	hostility = /datum/hostility/thalamus
	installed_gun = /obj/item/gun/energy/mindflayer
	icon = 'icons/obj/thalamus.dmi'
	icon_state = "turret"

/obj/machinery/turret/thalamus/fire_weapon(atom/resolved_target)
	installed_gun?.Fire(resolved_target, src)

/datum/hostility/thalamus
	var/static/threat_level_threshold = 4

/datum/hostility/thalamus/can_special_target(atom/holder, mob/target)
	if(!istype(holder))
		log_error("Thalamus turret hostility referenced with a non turret holder: [holder]!")
		return

	if(!ismob(target))
		return FALSE

	if(target.invisibility >= INVISIBILITY_LEVEL_ONE)
		return FALSE

	return TRUE

/obj/machinery/turret/thalamus/enhanced
