/datum/mind
	var/list/learned_spells = list()

/mob/get_actions_for_statpanel()
	. = ..()

	if(ability_master?.spell_objects)
		for(var/atom/movable/screen/ability/spell/screen in ability_master.spell_objects)
			var/datum/spell/S = screen.spell

			if(!S.connected_button)
				continue

			var/displayed_name
			switch(S.charge_type)
				if(SP_RECHARGE)
					displayed_name = "[S.name] [S.charge_counter/10.0]/[S.charge_max/10]"
				if(SP_CHARGES)
					displayed_name = "[S.name] [S.charge_counter]/[S.charge_max]"
				if(SP_HOLDVAR)
					displayed_name = "[S.name] [S.holder_var_type] [S.holder_var_amount]"

			. += list(list(
				S.panel,
				"",
				displayed_name,
				ref(S.connected_button),
			))

/proc/restore_spells(mob/H)
	if(!H.mind?.learned_spells)
		return

	var/list/spells = list()
	for(var/datum/spell/spell_to_remove in H.mind.learned_spells) //remove all the spells from other people.
		if(istype(spell_to_remove.holder, /mob))
			var/mob/M = spell_to_remove.holder
			spells += spell_to_remove
			M.remove_spell(spell_to_remove)

	for(var/datum/spell/spell_to_add in spells)
		H.add_spell(spell_to_add)

	H.ability_master.update_abilities(0, H)

/mob/proc/add_spell(datum/spell/spell_to_add, spell_base = "wiz_spell_ready", mob/living/deity/deity = null)
	if(!ability_master)
		ability_master = new()
	spell_to_add.holder = src
	if(mind)
		if(!mind.learned_spells)
			mind.learned_spells = list()
		mind.learned_spells |= spell_to_add
	ability_master.add_spell(spell_to_add, spell_base)
	spell_to_add.spell_learned(src)
	if(deity)
		spell_to_add.connected_god = deity
	return 1

/mob/proc/remove_spell(datum/spell/spell_to_remove)
	if(!spell_to_remove || !istype(spell_to_remove))
		return

	mind?.learned_spells -= spell_to_remove
	ability_master?.remove_ability(ability_master.get_ability_by_spell(spell_to_remove))

	return 1

/mob/proc/silence_spells(amount = 0)
	if(amount < 0)
		return

	ability_master?.silence_spells(amount)
