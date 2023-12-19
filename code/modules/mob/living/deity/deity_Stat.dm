/mob/living/deity/observer/get_status_tab_items()
	. = ..()
	. += "Health [health]/[maxHealth]"
	. += "Power [mob_uplink.uses]"
	. += "Power Minimum [power_min]"
	. += "Structure Num [structures.len]"
	. += "Minion Num [minions.len]"
	var/boon_name = "None"
	if(current_boon)
		if(istype(current_boon, /datum/spell))
			var/datum/spell/S = current_boon
			boon_name = S.name
		else
			var/obj/O = current_boon
			boon_name = O.name
	. += "Current Boon [boon_name]"
