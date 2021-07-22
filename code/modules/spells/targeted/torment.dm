/datum/spell/targeted/torment
	name = "Torment"
	desc = "this spell causes pain to all those in its radius."
	feedback = "TM"
	school = "illusion"
	charge_max = 150
	spell_flags = 0
	invocation = "Rai Di-Kaal!"
	invocation_type = SPI_SHOUT
	range = 5
	level_max = list(SP_TOTAL = 3, SP_SPEED = 0, SP_POWER = 3)
	cooldown_min = 50
	message = "<span class='danger'>So much pain! All you can hear is screaming!</span>"

	max_targets = 0
	compatible_mobs = list(/mob/living/carbon/human)

	var/loss = 30

	icon_state = "wiz_horse"

/datum/spell/targeted/torment/cast(list/targets, mob/user)
	gibs(user.loc)
	for(var/mob/living/carbon/human/H in targets)
		H.adjustHalLoss(loss)

/datum/spell/targeted/torment/empower_spell()
	if(!..())
		return 0

	loss += 30

	return "[src] will now cause more pain."
