/datum/spell/targeted/raiselich
	name = "Raise Lich"
	desc = "This spell turns your undead to a powerful lich that can learn spells and will serve you as a reserve vessel for your soul should your original body decease."
	feedback = "" /// IDK WHAT IT DOES, TODO: understand var/feedback
	school = "necromancy"
	spell_flags = SELECTABLE | NEEDSCLOTHES
	invocation = "De sepulchro suscitate et servite mihi!"
	invocation_type = SPI_SHOUT

	max_targets = 1
	charge_max = 2
	cooldown_min = 1

	//level_max = list(SP_TOTAL = 3, SP_SPEED = 0, SP_POWER = 3)

	compatible_mobs = list(/mob/living/carbon/human)

	icon_state = "wiz_lichify"

/datum/spell/targeted/raiselich/perform(mob/user = usr)
	if(user.mind.wizard.lich)
		to_chat(user, SPAN_WARNING("You can only have one lich!"))
		return FALSE

	return ..()

/datum/spell/targeted/raiselich/choose_targets(mob/user = usr)
	var/list/possible_targets = list()

	for(var/mob/living/target in user.mind.wizard.thralls)
		if(!target.mind.wizard || !istype(target.mind.wizard, /datum/wizard/undead))
			continue
		if(get_dist(user, target) > world.view)
			continue
		possible_targets += target

	var/mob/target = tgui_input_list(user, "Choose the target for the spell.", "Targeting", possible_targets)
	if(!target)
		return

	return target

/datum/spell/targeted/raiselich/cast(mob/living/target)
	var/datum/wizard/undead/undead = target.mind.wizard
	undead.lichify()
