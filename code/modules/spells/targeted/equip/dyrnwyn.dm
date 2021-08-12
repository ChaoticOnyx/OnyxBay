/spell/targeted/equip_item/dyrnwyn
	name = "Summon Dyrnwyn"
	desc = "Summons the legendary sword of Rhydderch Hael, said to draw in flame when held by a worthy man."
	feedback = "SD"
	charge_type = Sp_RECHARGE
	school = "conjuration"
	invocation = "Anrhydeddu Fi!"
	invocation_type = SpI_SHOUT
	spell_flags = INCLUDEUSER
	cooldown_min = 100
	range = 0
	duration = 0
	level_max = list(Sp_TOTAL = 1, Sp_SPEED = 0, Sp_POWER = 1)
	equipped_summons = list("active hand" = /obj/item/weapon/material/sword)
	max_targets = 1
	holder_var_amount = 0
	delete_old = TRUE
	single_item = TRUE
	hud_state = "gen_immolate"
/obj/item/weapon/melee/energy/sword/dyrnwyn
	name = "Dyrnwyn"
	desc = "Legendary sword of Rhydderch Hael, said to draw in flame when held by a worthy man."
	hitsound = 'sound/weapons/bladeslice.ogg'
	icon_state = "dyrwyn"
	w_class = ITEM_SIZE_HUGE
	slot_flags = SLOT_BELT
	damtype = BRUTE
	clumsy_unaffected = FALSE
	active_force = 36
	active_throwforce = 35
	force = 30
	throwforce = 25
	throw_speed = 1
	throw_range = 10
	mod_weight_a = 1.25
	mod_reach_a = 1.35
	mod_handy_a = 1.35
	mod_shield_a = 2.0
	brightness_color = "#ff5959"
	activate_sound = 'sound/effects/explosions/fuel_explosion3.ogg'
	deactivate_sound = 'sound/effects/explosions/fuel_explosion3.ogg'

/obj/item/weapon/melee/energy/sword/dyrnwyn/activate(mob/living/user)
	if(!active)
		to_chat(user, SPAN("notice", "\The [src] is engulfed in flames."))
	..()
	hitsound = 'sound/items/welder2.ogg'
	damtype = BURN
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	icon_state = "dyrwyn_active"
	set_light(l_max_bright = active_max_bright, l_outer_range = active_outer_range, l_color = brightness_color)


/obj/item/weapon/melee/energy/sword/dyrnwyn/deactivate(mob/living/user)
	if(active)
		to_chat(user, SPAN("notice", "\The [src] flames disappear!"))
	..()
	hitsound = 'sound/weapons/bladeslice.ogg'
	damtype = BRUTE
	attack_verb = list()
	icon_state = initial(icon_state)
	set_light(0)

/spell/targeted/equip_item/dyrnwyn/empower_spell()
	if(!..())
		return FALSE
	equipped_summons = list("active hand" = /obj/item/weapon/melee/energy/sword/dyrnwyn)
	return "Dyrnwyn full power is unlocked"
