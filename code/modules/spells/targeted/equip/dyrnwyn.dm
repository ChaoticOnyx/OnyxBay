/datum/spell/targeted/equip_item/dyrnwyn
	name = "Summon Dyrnwyn"
	desc = "Summons the legendary sword of Rhydderch Hael, said to draw in flame when held by a worthy man."
	feedback = "SD"
<<<<<<< HEAD

=======
	charge_type = SP_HOLDVAR
	holder_var_type = "fireloss"
	holder_var_amount = 10
>>>>>>> conflict-resolver
	school = "conjuration"
	invocation = "Anrhydeddu Fi!"
	invocation_type = SPI_SHOUT
	spell_flags = INCLUDEUSER
	cooldown_min = 100
	range = 0
<<<<<<< HEAD

=======
	level_max = list(SP_TOTAL = 1, SP_SPEED = 0, SP_POWER = 1)
	duration = 300 //30 seconds
	max_targets = 1
	equipped_summons = list("active hand" = /obj/item/weapon/material/sword)
	delete_old = 0
	var/material = MATERIAL_GOLD

	icon_state = "gen_immolate"

/datum/spell/targeted/equip_item/dyrnwyn/summon_item(new_type)
	var/obj/item/weapon/W = new new_type(null,material)
	W.SetName("\improper Dyrnwyn")
	W.damtype = BURN
	W.hitsound = 'sound/items/welder2.ogg'
	W.slowdown_per_slot[slot_l_hand] = 1
	W.slowdown_per_slot[slot_r_hand] = 1
	return W
>>>>>>> conflict-resolver

/datum/spell/targeted/equip_item/dyrnwyn/empower_spell()
	if(!..())
		return FALSE
	equipped_summons = list("active hand" = /obj/item/weapon/melee/energy/sword/dyrnwyn)
	return "Dyrnwyn full power is unlocked"
