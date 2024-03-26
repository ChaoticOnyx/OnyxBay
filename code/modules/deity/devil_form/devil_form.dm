GLOBAL_LIST_INIT(devil_spells_persistent, list(/datum/spell/targeted/summon_conract, /datum/spell/targeted/equip_item/pitchfork))
GLOBAL_LIST_INIT(devil_spells_1lvl, list(/datum/spell/toggled/pride/regen_form, /datum/spell/toggled/pride/mobility_form, /datum/spell/toggled/pride/tank_form, /datum/spell/toggled/pride/melee_form))

/datum/deity_form/devil
	name = "Devil"
	desc = "What’s better than a devil you don’t know? A devil you do."
	form_state = "devil"

	buildables = list(/datum/deity_power/structure/devil_teleport)

	phenomena = list(/datum/deity_power/phenomena/conversion)

	boons = list()

	resources = list(/datum/deity_resource/souls)

	/// Path an associated bane
	var/bane

	var/mob/living/carbon/current_devil_shell

/datum/deity_form/devil/take_charge(mob/living/user, charge)
	charge = max(5, charge/100)
	if(prob(charge))
		to_chat(user, SPAN_DANGER("Your body burns!"))
	user.adjustFireLoss(charge)
	return TRUE

/datum/deity_form/devil/setup_form(mob/living/deity/D)
	. = ..()
	bane = pick(DEVIL_BANES)

	var/datum/map_template/devil_level/dlevel = new /datum/map_template/devil_level()
	dlevel.load_new_z()
	var/mob/living/carbon/human/devil_new = new /mob/living/carbon/human(get_turf(pick(GLOB.devilspawns)))
	D.mind.deity = D
	current_devil_shell = devil_new
	ADD_TRAIT(devil_new, bane)
	D.mind?.transfer_to(devil_new)
	grant_spells(devil_new, GLOB.devil_spells_1lvl)
	grant_spells(devil_new, GLOB.devil_spells_persistent)

/datum/deity_form/devil/proc/grant_spells(mob/living/human_shell, list/spells)
	for(var/spell in spells)
		var/datum/spell/spell_to_add = new spell()
		human_shell.add_spell(spell_to_add, deity = src.deity)
		human_shell.ability_master.reskin_devil()

/datum/deity_resource/souls
	name = "Souls"
