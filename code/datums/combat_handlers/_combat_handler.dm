
/datum/combat_handler
	var/name = "Combat Handler"
	var/desc = "DO NOT USE!"

	var/poise_mult = 1.0 // Completely disables poise handling if FALSE (also forces things like grabs and disarm bashes to use legacy handling)
	var/poise_regen_mult = 1.0
	var/melee_mult = 1.0
	var/ranged_mult = 1.0

	var/allow_blocking = TRUE // Toggleable blocking if TRUE, legacy random-based system if FALSE
	var/allow_parrying = TRUE // Hits with GRAB intent turn into parry attempts if TRUE
	var/allow_advanced = TRUE // Forbids new-age features like dynamic attack speed and shooting items outta hands if FALSE
	var/allow_bashing = TRUE // Forces disarming with weapons to use normal attacks instead of bashing if FALSE
	var/allow_poise

/datum/combat_handler/New()
	poise_mult = max(0, poise_mult)
	if(poise_mult && poise_regen_mult <= 0)
		poise_regen_mult = 1.0 // Let's just make sure
	melee_mult = max(0, melee_mult)
	ranged_mult = max(0, ranged_mult)
	if(!poise_mult)
		allow_poise = FALSE
		allow_bashing = FALSE
	else
		allow_poise = TRUE

/datum/combat_handler/proc/handle_parry(mob/living/carbon/human/defender, mob/living/attacking_mob, obj/item/weapon_atk)
	if(!allow_parrying)
		defender.parrying = 0
		return FALSE // Shouldn't happen but hey

	if(world.time > defender.parrying)
		return FALSE

	if(!ishuman(attacking_mob))
		defender.parrying = 0
		return FALSE

	var/failing = FALSE

	var/mob/living/carbon/human/attacker = attacking_mob
	if(defender.get_active_hand())
		var/obj/item/weapon_def = defender.get_active_hand()
		if(!weapon_def.force)
			defender.parrying = 0
			defender.visible_message(SPAN("warning", "[defender] pointlessly attempts to parry [attacker]'s [weapon_atk.name] with their [weapon_def]."))
			return FALSE // For the case of candles and dices lmao

		if(weapon_def.mod_reach > 1.25)
			if((weapon_def.mod_reach - weapon_atk.mod_reach) > 1.0)
				failing = TRUE
		else if(weapon_def.mod_reach < 0.75)
			if((weapon_atk.mod_reach - weapon_def.mod_reach) > 1.0)
				failing = TRUE

		if(failing)
			defender.visible_message(SPAN("warning", "[defender] fails to parry [attacker]'s [weapon_atk.name] with their [weapon_def.name]."))
			defender.parrying = 0
			return FALSE

		defender.next_move = world.time+1 //Well I'd prefer to use setClickCooldown but it ain't gonna work here.
		defender.damage_poise(2.5+(weapon_atk.mod_weight*1.5))

		attacker.setClickCooldown(weapon_atk.update_attack_cooldown()*2)
		attacker.damage_poise(17.5+(weapon_atk.mod_weight*7.5))

		defender.visible_message(SPAN("warning", "[defender] parries [attacker]'s [weapon_atk.name] with their [weapon_def.name]."))

		if(allow_poise) // Poise-based
			if(attacker.poise <= 5)
				weapon_atk.knocked_out(attacker, TRUE, 3)
			else if(attacker.poise <= 20)
				weapon_atk.knocked_out(attacker)
		else
			if(prob(35)) // Random-based
				weapon_atk.knocked_out(attacker, TRUE, 3)
			else
				weapon_atk.knocked_out(attacker)

		playsound(defender.loc, 'sound/weapons/parry.ogg', 50, 1, -1) // You know what's gonna happen next, eh?
		defender.parrying = 0

	return TRUE

/datum/combat_handler/proc/handle_block(mob/living/carbon/human/defender, mob/living/attacking_mob, obj/item/weapon_atk)
	if(!allow_blocking)
		return FALSE

	if(!defender.blocking)
		return FALSE

	var/d_mult = 1
	if(!ishuman(attacking_mob))
		return TRUE

	var/mob/living/carbon/human/attacker = attacking_mob
	var/obj/item/weapon_def

	if(defender.blocking_hand && defender.get_inactive_hand())
		weapon_def = defender.get_inactive_hand()
	else if(defender.get_active_hand())
		weapon_def = defender.get_active_hand()

	if(weapon_def)
		if(!weapon_def.force)
			defender.useblock_off()
			defender.visible_message(SPAN("warning", "[defender] pointlessly attempts to block [attacker]'s [weapon_atk.name] with [weapon_def]."))
			return FALSE //For the case of candles and dices lmao

		if(weapon_def.mod_reach < weapon_atk.mod_reach)
			if(((weapon_atk.mod_reach + weapon_atk.mod_weight)/2 - weapon_def.mod_reach) > 0)
				d_mult = ((weapon_atk.mod_reach + weapon_atk.mod_weight)/2 - weapon_def.mod_reach)/0.25
		else if(weapon_def.mod_weight < weapon_atk.mod_weight)
			d_mult = (weapon_atk.mod_weight - weapon_def.mod_weight)/0.5

		defender.damage_poise((4.0+(weapon_atk.mod_weight*2.5 + weapon_atk.mod_reach)) + (weapon_atk.mod_weight*2.5 + weapon_atk.mod_reach)*d_mult/weapon_def.mod_shield)
		attacker.damage_poise(2.0+(weapon_atk.mod_weight*2 + (1-weapon_atk.mod_handy)*2))

		defender.visible_message(SPAN("warning", "[defender] blocks [attacker]'s [weapon_atk.name] with their [weapon_def.name]!"))
		defender.last_block = world.time

		if(defender.poise <= 5.0)
			weapon_def.knocked_out(defender, TRUE, 3)
		else if(defender.poise <= 12.5)
			weapon_def.knocked_out(defender)

		playsound(defender.loc, 'sound/effects/fighting/Genhit.ogg', 50, 1, -1)
	else
		defender.damage_poise(2.5 + weapon_atk.mod_weight*10 + weapon_atk.mod_reach*5)
		attacker.damage_poise(weapon_atk.mod_weight*2 + (1-weapon_atk.mod_handy)*2)

		if((weapon_atk.sharp || weapon_atk.edge) && weapon_atk.force >= 10)
			defender.visible_message(SPAN("warning", "[defender] blocks [attacker]'s [weapon_atk.name] with their bare hands! Ouch."))
			defender.apply_damage((weapon_atk.force*0.2), weapon_atk.damtype, BP_R_HAND, 0, 0, used_weapon=weapon_atk)
			defender.apply_damage((weapon_atk.force*0.2), weapon_atk.damtype, BP_L_HAND, 0, 0, used_weapon=weapon_atk)
		else
			defender.visible_message(SPAN("warning", "[defender] blocks [attacker]'s [weapon_atk.name] with their bare hands!"))

		defender.last_block = world.time

		if(defender.poise <= 10.0)
			defender.visible_message(SPAN("warning", "[defender] falls down, unable to keep balance!"))
			defender.apply_effect(3, WEAKEN, 0)
			defender.useblock_off()

	return TRUE

/datum/combat_handler/proc/handle_block_unarmed(mob/living/carbon/human/defender, mob/living/attacking_mob, atk_dmg = 5.0)
	if(!allow_blocking)
		return FALSE

	if(!defender.blocking)
		return FALSE

	if(!(ishuman(attacking_mob) || istype(attacking_mob,/mob/living/simple_animal)))
		return FALSE

	var/mob/living/attacker = attacking_mob
	var/obj/item/weapon_def

	if(defender.blocking_hand && defender.get_inactive_hand())
		weapon_def = defender.get_inactive_hand()
	else if(defender.get_active_hand())
		weapon_def = defender.get_active_hand()

	if(weapon_def)
		if(!weapon_def.force)
			defender.useblock_off()
			defender.visible_message(SPAN("warning", "[defender] pointlessly attempts to block [attacker]'s attack with [weapon_def]."))
			return FALSE //For the case of candles and dices lmao

		defender.damage_poise(atk_dmg / ((weapon_def.mod_handy+weapon_def.mod_reach) / 2))
		if(istype(attacker,/mob/living/carbon/human))
			var/mob/living/carbon/human/human_attacker = attacker
			human_attacker.damage_poise(5.0 + weapon_def.mod_weight*2 + weapon_def.mod_handy*3)

		defender.visible_message(SPAN("warning", "[defender] blocks [attacker]'s attack with their [weapon_def.name]!"))
		defender.last_block = world.time

		if(defender.poise < 0)
			weapon_def.knocked_out(defender, TRUE, 3)
		else if(defender.poise < 10.0)
			weapon_def.knocked_out(defender)

		playsound(defender.loc, 'sound/effects/fighting/Genhit.ogg', 50, 1, -1)
	else
		if(istype(attacker,/mob/living/carbon/human))
			var/mob/living/carbon/human/human_attacker = attacker
			defender.damage_poise(7.5)
			human_attacker.damage_poise(5.0)
		else
			defender.damage_poise(atk_dmg)

		defender.visible_message(SPAN("warning", "[defender] blocks [attacker]'s attack!"))
		defender.last_block = world.time

		if(defender.poise <= atk_dmg)
			defender.visible_message(SPAN("warning", "[defender] falls down, unable to keep balance!"))
			defender.apply_effect(3, WEAKEN, 0)
			defender.useblock_off()

	return TRUE

/datum/combat_handler/proc/handle_block_thrown(mob/living/carbon/human/defender, obj/O, throw_damage)
	if(!allow_blocking)
		return FALSE

	if(!defender.blocking)
		return FALSE

	var/obj/item/weapon_def
	if(defender.blocking_hand && defender.get_inactive_hand())
		weapon_def = defender.get_inactive_hand()
	else if(defender.get_active_hand())
		weapon_def = defender.get_active_hand()

	if(!weapon_def)
		return FALSE

	if(weapon_def.force && weapon_def.w_class >= O.w_class)
		var/dir = get_dir(defender, O)
		O.throw_at(get_edge_target_turf(defender, dir), 1)

		defender.visible_message(SPAN("warning", "[defender] blocks [O] with [weapon_def]!"))
		playsound(defender, 'sound/effects/fighting/Genhit.ogg', 50, 1, -1)

		defender.damage_poise(throw_damage / weapon_def.mod_shield)
		if(allow_poise && (defender.poise < throw_damage / weapon_def.mod_shield))
			defender.visible_message(SPAN("warning", "[defender] falls down, unable to keep balance!"))
			defender.apply_effect(2, WEAKEN, 0)
			defender.useblock_off()
		return TRUE

/datum/combat_handler/proc/weapon_hit_effects(mob/living/carbon/human/defender, mob/living/attacking_mob, obj/item/weapon_atk)


/datum/combat_handler/default
	name = "Default"
	desc = "Default Combat Handler. Uses standard values for everything."

/datum/combat_handler/softcore
	name = "Softcore"
	desc = "Slightly reduces the amount of damage."
	melee_mult = 0.75
	ranged_mult = 0.75
	poise_regen_mult = 1.2

/datum/combat_handler/peaceful
	name = "Peaceful"
	desc = "Drastically reduces the amount of damage."
	melee_mult = 0.4
	ranged_mult = 0.4
	poise_regen_mult = 1.5

/datum/combat_handler/menofsteel
	name = "Men of Steel"
	desc = "Ranged and melee damage levels are borderline nonexistent."
	melee_mult = 0.1
	ranged_mult = 0.1
	poise_regen_mult = 3.0

/datum/combat_handler/hardcore
	name = "Hardcore"
	desc = "Increases the amount of damage by 150%."
	melee_mult = 1.5
	ranged_mult = 1.5

/datum/combat_handler/bloodbath
	name = "Bloodbath"
	desc = "Doubles the amount of damage."
	melee_mult = 3.0
	ranged_mult = 3.0

/datum/combat_handler/onepunch
	name = "One Punch Mode"
	desc = "Pretty much anything is lethal."
	melee_mult = 10.0
	ranged_mult = 10.0

/datum/combat_handler/bullethell
	name = "Bullet Hell"
	desc = "Double range damage."
	ranged_mult = 2.0

/datum/combat_handler/fightclub
	name = "Fight Club"
	desc = "Double melee damage, less poise."
	poise_mult = 0.75
	melee_mult = 2.0

/datum/combat_handler/wildwest
	name = "Wild West"
	desc = "Projectiles deal enermous damage."
	ranged_mult = 3.0

/datum/combat_handler/highlander
	name = "Highlanders"
	desc = "Enermous melee damage and poise, reduced ranged damage."
	melee_mult = 2.5
	ranged_mult = 0.5
	poise_mult = 1.5
	poise_regen_mult = 2.0

/datum/combat_handler/legacy
	name = "Legacy 2012"
	desc = "Default SS13 combat."

	poise_mult = 0

	allow_blocking = FALSE
	allow_parrying = FALSE
	allow_advanced = FALSE

/datum/combat_handler/legacy/bay
	name = "Legacy 2018"
	desc = "What we had right after forking from BayStation in 2018. The Great Nerffest, if you will."
	melee_mult = 0.7
	ranged_mult = 0.7

/datum/combat_handler/pseudolegacy
	name = "Pseudolegacy"
	desc = "Not actually legacy. Basically, the default combat handler, but without the poise system."

	poise_mult = 0
