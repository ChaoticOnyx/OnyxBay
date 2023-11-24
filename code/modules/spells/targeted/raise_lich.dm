/datum/spell/targeted/raiseundead/lichify
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

	level_max = list(SP_TOTAL = 3, SP_SPEED = 0, SP_POWER = 0)

	compatible_mobs = list(/mob/living/carbon/human)

	icon_state = "wiz_lichify"

	should_lichify = TRUE

	override_base = "const"

/datum/spell/targeted/raiseundead/lichify/perform(mob/user = usr, skipcharge = TRUE)
	if(user.mind.wizard.lich)
		to_chat(user, SPAN_WARNING("You can only have one lich!"))
		return

	return ..()

/datum/spell/targeted/raiseundead/lichify/choose_targets(mob/user = usr)
	var/list/possible_targets = list()

	for(var/mob/living/target in view(world.view, user))
		if(target.mind?.wizard? && (target.mind?.wizard? in user.mind.wizard.thralls))
			possible_targets += target
			continue

		if(!target.is_ic_dead() || target.isSynthetic())
			continue

		possible_targets += target

	var/mob/target = tgui_input_list(user, "Choose the target for the spell.", "Targeting", possible_targets)

	return target
