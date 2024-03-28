/datum/deity_power/boon
	expected_type = /mob/living

/datum/deity_power/boon/manifest(mob/living/target, mob/living/deity/D)
	if(!..())
		return

	if(istype(power_path, /datum/spell))
		var/datum/spell/spell_to_add = new power_path
		spell_to_add.connected_god = D
		target.add_spell(spell_to_add)
		to_chat(target, "Your deity has granted you the spell [spell_to_add]!")
	else if(istype(power_path, /obj/item))
		var/obj/item/I = new power_path(target)
		if(!target.put_in_any_hand_if_possible(I))
			I.dropInto(get_turf(target))
