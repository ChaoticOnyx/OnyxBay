/datum/modifier/bane_salt
	affected_chemicals = list(/datum/reagent/sodiumchloride)

/datum/modifier/bane_salt/trigger_chem_effect(mob/M, amount, chemical)
	M.reagents.add_reagent(/datum/reagent/toxin, amount * 2)

/datum/modifier/bane_iron
	affected_chemicals = list(/datum/reagent/iron)

/datum/modifier/bane_iron/trigger_chem_effect(mob/M, amount, chemical)
	M.reagents.add_reagent(/datum/reagent/toxin, amount * 2)

/datum/modifier/bane_silver
	affected_chemicals = list(/datum/reagent/silver)

/datum/modifier/bane_silver/trigger_chem_effect(mob/M, amount, chemical)
	M.reagents.add_reagent(/datum/reagent/toxin, amount * 2)

/datum/modifier/bane_toolbox
	affected_items = list(/obj/item/storage/toolbox)

/datum/modifier/bane_toolbox/run_item_damage(damage, damagetype, def_zone, blocked, damage_flags, used_weapon)
	return damage * 4
