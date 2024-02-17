/datum/spell/targeted/summon_conract
	name = "Summon infernal contract"
	desc = "Skip making a contract by hand, just do it by magic.."
	feedback = "SIC"
	school = "conjuration"

	invocation_type = SPI_NONE

	spell_flags = SELECTABLE
	range = 7
	max_targets = 1

	charge_max = 30 SECONDS

	icon_state = "wiz_disint"

	cast_sound = 'sound/effects/drop/paper.ogg'

/datum/spell/targeted/summon_conract/choose_targets(mob/user = usr)
	var/list/possible_targets = list()
	for(var/mob/living/target in view(world.view, user))
		if(target.is_ic_dead() || target.isSynthetic())
			continue

		possible_targets += target

	var/mob/target = tgui_input_list(user, "Choose the target for the spell.", "Targeting", possible_targets)
	return target

/datum/spell/targeted/summon_conract/cast(mob/living/target, mob/user)
	var/contracttype = tgui_input_list(user, "Choose the contract's type.", "Conract's type", list(SIN_LUST, SIN_GLUTTONY, SIN_GREED, SIN_SLOTH, SIN_WRATH, SIN_ENVY, SIN_PRIDE))
	target.pick_or_drop(new /obj/item/paper/infernal_contract(target, user.mind?.deity, contracttype))
